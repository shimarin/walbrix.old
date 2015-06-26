from __future__ import print_function
import re
import shutil
import os
import os.path
import sys
import stat
import time
import subprocess
import hashlib
import shlex
import shutil

if __name__ != '__main__':
    import system,cli

srcdir="SRCDIR"
destdir="DESTDIR"
distfiles="./distfiles"
elf = re.compile('.*ELF.+dynamically linked.*')
processed_files = {}
processed_listfiles = {}
copied_up_paths = {}

vars = {}
if "KERNEL_VERSION" in os.environ:
    vars["KERNEL_VERSION"] = os.environ.get("KERNEL_VERSION") 

usage = "srcdir dstdir [lstfiles...]"

def check_output(cmd):
    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    rst = process.communicate()
    if process.returncode != 0: raise Exception(cmd + ":" + rst[1])
    # else
    return rst[0]

def exec_command(*cmdline):
    cmdline = map(lambda x:str(x), cmdline)
    rst = subprocess.Popen(cmdline, shell=False, close_fds=True).wait()
    if rst != 0: raise Exception(' '.join(cmdline) + ":" + rst)

def copy_up(path):
    if path in copied_up_paths: return
    exec_command("touch","-ahc",path)
    copied_up_paths[path] = True

def pause(message=None):
    if message: print(message)
    raw_input()

def finish_path(path, stack):
    def touch(path):
        if path == None or path == "": return
        copy_up(path)
        touch(os.path.split(path)[0])
    touch(path)

    if path == "": path = "."
    for d in reversed(stack):
        path = path + "/" + d[0]
        corresponding_dir = None if d[1] == None or d[1] == "" else d[1]
        if corresponding_dir != None and os.path.islink(corresponding_dir):
            print("%s->%s(copy symlink)" % (corresponding_dir, path))
            exec_command("cp","-a",corresponding_dir, path)
            linkdst = os.readlink(d[1])
            if linkdst.startswith('/'):
                path = os.path.join(destdir, linkdst)
            else:
                path = os.path.join(os.path.dirname(path), linkdst)
            if os.path.islink(path):
                raise Exception("Multi-level symlink is not supported.")
        if not os.path.isdir(path):
            print("mkdir(%s)" % path)
            os.mkdir(path)
        if corresponding_dir != None:
            statinfo = os.stat(d[1])
            mode = stat.S_IMODE(statinfo[stat.ST_MODE])
            uid = statinfo[stat.ST_UID]
            gid = statinfo[stat.ST_GID]
            os.chmod(path, mode)
            os.chown(path, uid, gid)
            print("%s(%s)->%s" % (d[1], str(mode), path))

def process_path(srcpath, dstpath, stack = None):
    if stack == None: stack = []
    if os.path.isdir(dstpath) or dstpath == "":
        finish_path(dstpath, stack)
        return
    #else
    srcleft, srcright = os.path.split(srcpath)
    dstleft, dstright = os.path.split(dstpath)
    stack.append((dstright,srcpath))
    process_path(srcleft, dstleft, stack)

def link_or_copy_file(src, dest):
    process_path(os.path.normpath(os.path.dirname(src)), os.path.normpath(os.path.dirname(dest)))

    if os.path.isfile(src) and not os.path.islink(src) and os.stat(src).st_dev == os.stat(os.path.dirname(dest)).st_dev:
        if os.path.exists(dest): os.unlink(dest)
        print("Create hard link %s -> %s" % (src, dest))
        os.link(src, dest)
    else:
        if os.path.exists(dest):
            print("Copy-up %s" % dest)
            copy_up(dest)
        else:
            exec_command("cp", "-av", src, dest)

def process_file(filename):
    if filename in processed_files: return

    src = os.path.normpath("%s%s" % (srcdir, filename))
    dest = os.path.normpath("%s%s" % (destdir, filename))
    if not os.path.lexists(src): raise Exception("%s:file not found" % (src))
    if os.path.isdir(src) and not os.path.islink(src): raise Exception("%s:dir cannot be specified" % (src))
    #_destdir = os.path.dirname(dest)
    #if not os.path.exists(_destdir): os.makedirs(_destdir)

    link_or_copy_file(src, dest)
    processed_files[filename] = True

    if os.path.islink(dest):
        path = os.readlink(dest)
        if not path.startswith("/"):
            path = os.path.normpath(os.path.dirname(filename) + "/" + path)
        if path.startswith("/proc/"): return

        if os.path.islink(srcdir + "/" + path):
            linkdst = os.readlink(srcdir + "/" + path)
            if not linkdst.startswith("/"):
                linkdst = os.path.normpath(os.path.dirname(path) + "/" + linkdst)
            if os.path.lexists(srcdir + "/" + linkdst): process_file(path)

        elif os.path.exists(srcdir + "/" + path) and not os.path.isdir(srcdir + "/" + path):
            process_file(path)

        return

    filep = subprocess.Popen(["file", dest], shell=False, close_fds=True, stdout=subprocess.PIPE)
    filetype = filep.stdout.read().strip().decode("utf-8")
    if filep.wait() != 0: raise Exception("Error while examining file type")
    if elf.match(filetype):
        try:
            lddout = check_output("chroot %s ldd %s" % (srcdir, filename))
            for line in lddout.split("\n"):
                libfile = re.sub(r' *\(0x.+\)$', "", re.sub(r'.*=> +', "", line)).strip()
                if libfile.startswith("/"):
                    process_file(libfile)
        except Exception as e:
            print(e)

def apply_variables(str):
    if str == None: return None
    if "ARCH" in vars: str = str.replace("$(ARCH)", vars["ARCH"])
    if "KERNEL_VERSION" in vars: str = str.replace("$(KERNEL_VERSION)", vars["KERNEL_VERSION"])
    if "REGION" in vars: str = str.replace("$(REGION)", vars["REGION"])
    if "LANGUAGE" in vars: str = str.replace("$(LANGUAGE)", vars["LANGUAGE"])
    return str

def process_line(line):
    if line == "": return
    filename = apply_variables(re.sub(r'^\./', "/", line))

    process_file(filename)

def parse_require(current_file, line):
    target_filename = apply_variables(line.split(" ")[1].strip())
    dirname = os.path.dirname(current_file)
    if dirname == "": return target_filename
    #else
    return os.path.normpath(dirname + "/" + target_filename)

def directive_portage(args):
    args = args.split(' ', 1)
    target_package = args[0]
    contents_file = os.path.normpath("%s/var/db/pkg/%s/CONTENTS" % (srcdir, target_package))
    def is_needed(filename):
        exclude_prefixes = ["/usr/share/doc/", "/usr/share/info/", "/usr/share/gtk-doc/", "/usr/share/man/", "/usr/include/", "/usr/lib/pkgconfig/", "/usr/lib64/pkgconfig/","/dev/"]
        for pfx in exclude_prefixes:
            if filename.startswith(pfx): return False

        exclude_patterns = [r"^/usr/lib(64)?/.*lib.+\.a$",r"^/usr/share/locale/(?!ja).+?/"]
        if len(args) > 1: exclude_patterns.append(' '.join(args[1:]))
        for ptn in exclude_patterns:
            if re.compile(ptn).match(filename): return False
        return True

    with open(contents_file) as f:
        line = f.readline()
        while line:
            splitted = line.strip().split(' ')
            ent_type = splitted[0] if len(splitted) > 0 else None
            filename = None
            if ent_type == "obj":
                filename = ' '.join(splitted[1:-2])
            elif ent_type == "sym":
                filename = ' '.join(splitted[1:-1]).split(" -> ")[0]
            if filename is not None and is_needed(filename):
                process_file(filename)
            line = f.readline()

def directive_copy(args):
    if len(args) != 2: raise Exception("#copy directive must have 2 args")
    src = os.path.normpath(distfiles + "/" + apply_variables(args[0]))
    dest = os.path.normpath("%s%s" % (destdir, apply_variables(args[1])))
    if not os.path.lexists(src): raise Exception("%s:file not found" % (src))
    if os.path.isdir(src): raise Exception("%s:dir cannot be specified as source" % (src))
    if os.path.isdir(dest): raise Exception("%s:dir cannot be specified as destination" % (dest))
    exec_command("cp","-av",src, dest)
    os.chown(dest, 0, 0)

    link_or_copy_file(src, dest)

def directive_need(args):
    if len(args) != 1: raise Exception("#need directive must have 1 arg")
    src = src = os.path.normpath("%s%s" % (srcdir, apply_variables(args[0])))
    if not os.path.lexists(src): raise Exception("%s:file not found" % (src))
    print("%s:ok" % src)

def generateExtractorBySuffix(source, target):
    for k,v in {".tar":["/bin/tar","xpf",source,"-C",target], ".tar.gz":["/bin/tar","zxpf",source,"-C",target], ".tar.bz2":["/bin/tar","jxpf",source,"-C",target],".tar.lzma":["/bin/tar","Jxpf",source,"-C",target],".tar.xz":["/bin/tar","Jxpf",source,"-C",target],".zip":["/usr/bin/unzip",source,"-d",target]}.items():
        if source.endswith(k): return v
    return ""

def directive_extract(args):
    if len(args) != 2: raise Exception("#extract directive gets 2 arguments")
    archive = os.path.normpath("%s/%s" % (distfiles, apply_variables(args[0])))
    target = os.path.normpath("%s/%s" % (destdir, apply_variables(args[1])))
    extractor = generateExtractorBySuffix(archive, target)
    print("Extracting %s into %s" % (archive, target))
    rst = subprocess.Popen(extractor, shell=False, close_fds=True).wait()
    if rst != 0: raise Exception("Error during extracting archive")

def directive_swap(args):
    if len(args) != 2: raise Exception("#swap directive gets 2 arguments")
    swapfile = os.path.normpath("%s/%s" % (destdir, apply_variables(args[0])))
    size = int(args[1])
    os.system("dd if=/dev/zero of=%s bs=1M count=%d" % (swapfile, size))
    os.system("mkswap %s" % (swapfile))

def directive_kernel(args):
    if len(args) != 1: raise Exception("#kernel directive gets 1 argument")
    s = system.getSystem()
    kernelfile = os.path.normpath("%s/%s" % (srcdir, apply_variables(args[0])))
    print("Getting KERNEL_VERSION from %s" % kernelfile)
    vars["KERNEL_VERSION"] = s.getKernelVersionString(kernelfile)
    print("KERNEL_VERSION set to %s" % vars["KERNEL_VERSION"])

def directive_copytree(args):
    if len(args) != 2: raise Exception("#copytree directive gets 2 arguments")
    src = os.path.normpath("%s/%s" % (srcdir, apply_variables(args[0])))
    dest = os.path.normpath("%s/%s" % (destdir, apply_variables(args[1])))
    print("Copying tree: %s -> %s" % (src, dest))
    os.system("cp -a %s %s" % (src, dest))

def directive_findexec(args):
    if len(args) < 3: raise Exception("#findexec directive gets at least 3 arguments")
    target = os.path.normpath("%s/%s" % (destdir, apply_variables(args[0])))
    if not os.path.isdir(target):
        raise Exception("Directory %s missing or not a directory" % target)
    pattern = apply_variables(args[1])
    cmdline = apply_variables(" ".join(args[2:]))
    print("findexec: directory=%s, pattern=%s, command=%s" % (target, pattern, cmdline))
    os.system("find %s -name '%s' | xargs %s" % (target, pattern, cmdline))

def chrootexec(cmdline):
    if subprocess.Popen(["chroot", destdir, "sh", "-c", cmdline], shell=False, close_fds=True).wait() != 0:
        raise Exception("chrootexec returned an error")

def directive_chrootexec(args,shm=False):
    if len(args) < 1: raise Exception("#chrootexec directive gets at least 1 argument")
    cmdline = apply_variables(" ".join(args))
    print("chrootexec: executing %s" % cmdline)
    s = system.getSystem()
    if shm:
        shmdir = "%s/dev/shm" % destdir
        if not os.path.exists(shmdir):
            os.mkdir(shmdir)
        with s.temporaryMount("/dev/shm", shmdir, "bind"):
            with s.temporaryMount("/proc", "%s/proc" % (destdir), "bind"):
                chrootexec(cmdline)
    else:
        with s.temporaryMount("/proc", "%s/proc" % (destdir), "bind"):
            chrootexec(cmdline)

def directive_detectarch(args):
    if len(args) != 1: raise Exception("#detecharch directive gets 1 argument")
    s = system.getSystem()
    elf = os.path.normpath("%s/%s" % (srcdir, apply_variables(args[0])))
    print("Checking %s" % elf)
    bits = s.getExecutableBitWidth(elf)

    if bits == 32:
        print("ARCH set to i686")
        vars["ARCH"] = "i686"
    elif bits == 64:
        print("ARCH set to x86_64")
        vars["ARCH"] = "x86_64"

def directive_sed(args):
    if len(args) < 2: raise Exception("#sed directive gets at least 2 arguments")
    target = os.path.normpath("%s/%s" % (destdir, apply_variables(args[0])))
    expression = apply_variables(" ".join(args[1:]))
    print("Applying sed expression %s to %s" % (expression, target))
    result = check_output("sed '%s' %s" % (expression, target))
    statinfo = os.stat(target)
    mode = stat.S_IMODE(statinfo[stat.ST_MODE])
    uid = statinfo[stat.ST_UID]
    gid = statinfo[stat.ST_GID]
    os.unlink(target)
    with open(target, "wb") as f:
        f.write(result)
    os.chmod(target, mode)
    os.chown(target, uid, gid)

def directive_patchsinglefile(args):
    if len(args) != 2: raise Exception("#patchsinglefile directive gets 2 arguments")
    target = os.path.normpath("%s/%s" % (destdir, apply_variables(args[0])))
    patchfile = os.path.normpath("%s/%s" % (distfiles, apply_variables(args[1])))
    print("Applying patch %s to %s..." % (patchfile, target))
    statinfo = os.stat(target)
    mode = stat.S_IMODE(statinfo[stat.ST_MODE])
    uid = statinfo[stat.ST_UID]
    gid = statinfo[stat.ST_GID]
    if os.system("patch --binary '%s' '%s'" % (target, patchfile)) != 0:
        raise Exception("Patch failed.")
    os.chmod(target, mode)
    os.chown(target, uid, gid)

def directive_appendline(args):
    if len(args) < 2: raise Exception("#appendline directive needs at least 2 arguments")
    target = os.path.normpath("%s/%s" % (destdir, apply_variables(args[0])))
    line = apply_variables(" ".join(args[1:]))
    print("Appending line %s to %s..." % (line, target))
    statinfo = os.stat(target)
    mode = stat.S_IMODE(statinfo[stat.ST_MODE])
    uid = statinfo[stat.ST_UID]
    gid = statinfo[stat.ST_GID]
    with open(target) as f: contents = f.read()
    if contents[-1] != '\n': contents += '\n'
    os.unlink(target)
    with open(target, "w") as f:
        f.write(contents)
        f.write(line)
        f.write('\n')
    os.chmod(target, mode)
    os.chown(target, uid, gid)

def directive_symlink(args):
    if len(args) != 2: raise Exception("#symlink directive must have 2 args")
    name = "%s%s" % (destdir, apply_variables(args[0]))
    src = apply_variables(args[1])
    print("Create symlink: %s(%s)" % (name, src))
    if os.path.lexists(name): os.unlink(name)
    os.symlink(src, name)

def process_listfile(listfile):
    if listfile in processed_listfiles: return
    print("Processing %s..." % listfile)
    with open(listfile) as f:
        line = f.readline()
        while line:
            if line.startswith("#"):
                if line.startswith("#require "):
                    process_listfile(parse_require(listfile, line))
                elif line.startswith("#portage "):
                    args = apply_variables(line.split(" ",1)[1].strip())
                    directive_portage(args)
                elif line.startswith("#dir "):
                    target_dirname = apply_variables(line.split(" ")[1].strip())
                    if target_dirname != None and target_dirname != "":
                        dirname = destdir + target_dirname
                        if os.path.isdir(dirname):
                            copy_up(dirname)
                            print("Directory %s already exists. copy-up." % dirname)
                        else:
                            print("Create directory: %s" %  dirname)
                            rst = os.makedirs(dirname)
                elif line.startswith("#copy "):
                    args = line.strip().split(" ")[1:]
                    directive_copy(args)
                elif line.startswith("#need "):
                    args = line.strip().split(" ")[1:]
                    directive_need(args)
                elif line.startswith("#symlink "):
                    args = line.strip().split(" ")[1:]
                    directive_symlink(args)
                elif line.startswith("#extract "):
                    args = line.strip().split(" ")[1:]
                    directive_extract(args)
                elif line.startswith("#swap "):
                    args = line.strip().split(" ")[1:]
                    directive_swap(args)
                elif line.startswith("#kernel "):
                    args = line.strip().split(" ")[1:]
                    directive_kernel(args)
                elif line.startswith("#copytree "):
                    args = line.strip().split(" ")[1:]
                    directive_copytree(args)
                elif line.startswith("#findexec "):
                    args = line.strip().split(" ")[1:]
                    directive_findexec(args)
                elif line.startswith("#chrootexec "):
                    args = shlex.split(line.strip())
                    directive_chrootexec(args[1:], False)
                elif line.startswith("#chrootexec_shm "):
                    args = shlex.split(line.strip())
                    directive_chrootexec(args[1:], True)
                elif line.startswith("#detectarch "):
                    args = line.strip().split(" ")[1:]
                    directive_detectarch(args)
                elif line.startswith("#sed "):
                    args = line.strip().split(" ")[1:]
                    directive_sed(args)
                elif line.startswith("#patchsinglefile "):
                    args = line.strip().split(" ")[1:]
                    directive_patchsinglefile(args)
                elif line.startswith("#appendline "):
                    args = line.strip().split(" ")[1:]
                    directive_appendline(args)
            else:
                process_line(line.strip())
            line = f.readline()
    processed_listfiles[listfile] = None

def process_listfiles(listfiles):
    for listfile in listfiles:
        process_listfile(listfile)

def filedb_process_dir(basedir, dir, filedb):
    for item in os.listdir(basedir + '/' + dir):
        k = basedir + '/' + dir + '/' + item
        if os.path.isfile(k) and not os.path.islink(k):
            m = hashlib.md5()
            with open(k) as f:
                m.update(f.read())
                filedb["%s/%s" % (dir, item)] = m.hexdigest()
        elif os.path.isdir(k) and not os.path.islink(k):
            filedb_process_dir(basedir, "%s/%s" % (dir, item), filedb)
        else:
            filedb["%s/%s" % (dir, item)] = None

def setupOptions(parser):
    parser.add_option("-d", "--distfiles", dest="distfiles", help="Specify distfiles directory", default="./distfiles")
    parser.add_option("-J", "--output-tarxz", dest="output_tarxz", help="Output to tar.xz archive file", default=None)
    parser.add_option("-c", "--output-cpioxz", dest="output_cpioxz", help="Output to cpio+xz archive file", default=None)
    parser.add_option("-f", "--filedb", dest="filedb", help="Generate filedb in specified filename inside destdir", default=None)
    parser.add_option("-b", "--cleanup-before", dest="cleanup_before", action="store_true", help="Delete directory before output")
    parser.add_option("-r", "--cleanup-after", dest="cleanup_after", action="store_true", help="Delete directory after output(probably used with -J/-c)")
    parser.add_option("-g", "--region", dest="region", help="Region name", default="jp")
    parser.add_option("-l", "--language", dest="language", help="Language name", default=None)
    parser.add_option("-a", "--arch", dest="arch", help="Architecture(x86_64/i686)", default=os.environ.get("ARCH") if "ARCH" in os.environ else os.uname()[4])
    parser.add_option("-U", "--diable-aufs", dest="disable_aufs", action="store_true")

def create_filedb(filedb_file):
    filedb = {}
    filedb_process_dir(destdir, "", filedb)
    filedb_file = os.path.normpath("%s/%s" % (destdir, filedb_file))
    filedb_dir = os.path.dirname(filedb_file)
    if not os.path.isdir(filedb_dir): os.makedirs(filedb_dir)
    with open(filedb_file, "w") as f:
        print("Writing filedb to %s" % filedb_file)
        for k in sorted(filedb.keys()):
            if filedb[k] == None:
                f.write("%s\n" % k)
            else:
                f.write("%s\t%s\n" % (k, filedb[k]))

def determine_use_aufs(options, listfiles):
    need_aufs = False
    no_aufs = False
    re_need_aufs = re.compile(r'^#needaufs\s*$', re.MULTILINE)
    re_no_aufs = re.compile(r'^#noaufs\s*$', re.MULTILINE)
    for listfile in listfiles:
        contents = open(listfile).read()
        if re_need_aufs.search(contents): need_aufs = True
        if re_no_aufs.search(contents): no_aufs = True

    if need_aufs and no_aufs:
        raise cli.Error("Both of #needaufs and #noaufs cannot be specified at the same time.")

    if no_aufs: return False

    aufs_available = not options.disable_aufs and os.system("grep -wq aufs /proc/filesystems") == 0
    if need_aufs and not aufs_available:
        raise cli.Error("#needaufs is given but aufs is not available.")

    return aufs_available

def run(options, args):
    if len(args) < 2: raise Exception("Insufficient parameters")
    if os.getuid() != 0: raise Exception("You must be a root user.")

    global srcdir, destdir, listfiles, distfiles
    srcdir = args[0]
    destdir = args[1]
    listfiles = args[2:]
    distfiles = options.distfiles
    vars["ARCH"] = options.arch
    vars["REGION"] = options.region
    vars["LANGUAGE"] = options.language if options.language != None else ("ja" if options.region == "jp" else "en")

    if not os.path.isdir(srcdir): raise Exception("Invalid srcdir %s" % srcdir)

    use_aufs = determine_use_aufs(options, listfiles)

    if use_aufs:
        aufs_dir = "%s.aufs" % destdir
        print("aufs available. using %s as a layer" % aufs_dir)

    if options.cleanup_before and os.path.isdir(destdir):
        if os.system("mountpoint -q %s" % destdir) == 0:
            print("%s is a mountpoint! attempting umount..." % destdir)
            os.system("umount %s" % destdir)
            if os.system("mountpoint -q %s" % destdir) == 0:
                print("%s is still a mount point dispite trying unmount. abort.")
                return
        print("Deleting destination dir...")
        shutil.rmtree(destdir)
        if use_aufs and os.path.isdir(aufs_dir):
            print("Deleting aufs layer...")
            shutil.rmtree(aufs_dir)

    if use_aufs:
        if not os.path.isdir(aufs_dir): os.mkdir(aufs_dir)
        if not os.path.isdir(destdir): os.mkdir(destdir)
        if os.system("mountpoint -q %s" % destdir) == 0:
            print("Something is mounted already. attempting umount...")
            os.system("umount %s" % destdir)
        print("Mounting aufs...")
        if os.system("mount -t aufs -o noxino,br=%s:%s=ro aufs %s" % (aufs_dir,srcdir,destdir)) != 0:
            print("Mounting aufs failed.")
            return

    process_listfiles(listfiles)

    if use_aufs:
        print("Removing source layer from aufs...")
        for i in [1,2,3,4,5]:
            rst = os.system("mount -o remount,del:%s %s" % (srcdir, destdir)) == 0
            if rst: break
            #else
            time.sleep(1)
        if not rst:
            print("Removing source layer failed")
            return

    options.filedb != None and create_filedb(options.filedb)

    if options.output_tarxz != None:
        print("Generating tar.xz archive...")
        os.system("tar Jcvpf %s --numeric-owner -C %s ." % (options.output_tarxz, destdir))

    if options.output_cpioxz != None:
        print("Generating cpio+xz archive...")
        os.system("(cd %s && find .|cpio -o -H newc) | xz -c --check=crc32 > %s" % (destdir, options.output_cpioxz))

    if use_aufs:
        os.system("umount %s && rmdir %s" % (destdir, destdir))

    if options.cleanup_after:
        if os.path.isdir(destdir):
            print("Deleting destination dir...")
            shutil.rmtree(destdir)
        if use_aufs and os.path.isdir(aufs_dir):
            print("Deleting aufs dir...")
            shutil.rmtree(aufs_dir)

    print("end")

if __name__ == '__main__':
    import optparse
    sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/..')
    import system
    parser = optparse.OptionParser()
    setupOptions(parser)
    (options, args) = parser.parse_args(sys.argv[1:])
    run(options, args)

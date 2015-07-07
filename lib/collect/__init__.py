# -*- coding:utf-8 -*-
import os,re,glob,struct,stat,shutil,subprocess,argparse,shlex,json,base64,hashlib
import chardet # emerge dev-python/chardet
import magic # emerge python-magic
import lxml.etree
import kernelver,catalog2vadesc

import execute,kernel

_elf = re.compile('.*ELF.+dynamically linked.*')

class Context:
    def __init__(self, source, destination, vars = {}):
        self.source = source
        self.destination = destination
        self.vars = vars
        self.collected_files = set()
        self.processed_lstfiles = set()
        self.copied_up_paths = set()
    def is_lstfile_already_processed(self, lstfile):
        return lstfile in self.processed_lstfiles
    def mark_lstfile_as_processed(self, lstfile):
        self.processed_lstfiles.add(lstfile)
    def is_file_already_collected(self, filename):
        return filename in self.collected_files
    def mark_file_as_collected(self, filename):
        self.collected_files.add(filename)
    def is_path_already_copied_up(self, path):
        return path in self.copied_up_paths
    def mark_path_as_copied_up(self, path):
        self.copied_up_paths.add(path)
    def set_variable(self, key, value):
        self.vars[key] = value
    def get_variable(self, key):
        return self.vars.get(key)
    def apply_variables(self, str):
        if str == None: return None
        for key, value in self.vars.iteritems():
            str = str.replace("$(%s)" % key, value)
        return str

def mkdir_p(path):
    if not os.path.isdir(path):
        print("mkdir(%s)" % path)
        subprocess.check_call(["mkdir","-p",path])

def copy_up(context, path):
    if context.is_path_already_copied_up(path): return
    subprocess.check_call(["touch","-ahc",path])
    context.mark_path_as_copied_up(path)

def is_executable(filename):
    return os.path.isfile(filename) and os.access(filename, os.X_OK)

def env_with_root_path():
    new_env = os.environ.copy()
    new_env["PATH"] = "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/bin"
    return new_env

def finish_path(context, path, stack):
    def touch(context, path):
        if path == None or path == "": return
        copy_up(context, path)
        touch(context, os.path.split(path)[0])
    touch(context, path)

    if path == "": path = "."
    for d in reversed(stack):
        path = path + "/" + d[0]
        corresponding_dir = None if d[1] == None or d[1] == "" else d[1]
        if corresponding_dir != None and os.path.islink(corresponding_dir):
            print("%s->%s(copy symlink)" % (corresponding_dir, path))
            subprocess.check_call(["cp","-a",corresponding_dir, path])
            linkdst = os.readlink(d[1])
            if linkdst.startswith('/'):
                path = os.path.join(context.destination, linkdst)
            else:
                path = os.path.join(os.path.dirname(path), linkdst)
            if os.path.islink(path):
                raise Exception("Multi-level symlink is not supported.")
        mkdir_p(path)
        if corresponding_dir != None:
            statinfo = os.stat(d[1])
            mode = stat.S_IMODE(statinfo[stat.ST_MODE])
            uid = statinfo[stat.ST_UID]
            gid = statinfo[stat.ST_GID]
            os.chmod(path, mode)
            os.chown(path, uid, gid)
            print("%s(%s)->%s" % (d[1], str(mode), path))

def process_path(context, srcpath, dstpath, stack = None):
    if stack == None: stack = []
    if os.path.isdir(dstpath) or dstpath == "":
        finish_path(context, dstpath, stack)
        return
    #else
    srcleft, srcright = os.path.split(srcpath)
    dstleft, dstright = os.path.split(dstpath)
    stack.append((dstright,srcpath))
    process_path(context, srcleft, dstleft, stack)
        
def process_file(context, filename):
    if context.is_file_already_collected(filename): return

    src = os.path.normpath("%s%s" % (context.source, filename))
    dest = os.path.normpath("%s%s" % (context.destination, filename))
    if not os.path.lexists(src): raise Exception("%s:file not found" % (src))
    
    process_path(context, os.path.normpath(os.path.dirname(src)), os.path.normpath(os.path.dirname(dest)))

    if os.path.isdir(src) and not os.path.islink(src): # process directory recursively
        for root, dirs, files in os.walk(src):
            for file in files:
                process_file(context, os.path.join(root, file)[len(context.source):])
        return

    if os.path.isdir(dest):
        if os.path.islink(dest): os.unlink(dest)
        else: shutil.rmtree(dest)

    subprocess.check_call(["cp","-av",src, dest])
    context.mark_file_as_collected(filename)

    if os.path.islink(dest): # follow if link
        path = os.readlink(dest)
        if not path.startswith("/"): path = os.path.normpath(os.path.dirname(filename) + "/" + path)
        if path.startswith("/proc/"): return # ignore /proc tree

        if os.path.islink(context.source + "/" + path):
            linkdst = os.readlink(context.source + "/" + path)
            if not linkdst.startswith("/"): linkdst = os.path.normpath(os.path.dirname(path) + "/" + linkdst)
            if os.path.lexists(context.source + "/" + linkdst): process_file(context, path)
        elif os.path.exists(context.source + "/" + path) and not os.path.isdir(context.source + "/" + path):
            process_file(context, path)
        return

    # check file type
    
    filetype = magic.from_file(dest) if chardet.detect(dest)["encoding"] == 'ascii' else ""  # non-ascii filename is not acceptable in magic
    if _elf.match(filetype):
        try:
            lddout = subprocess.check_output(["chroot",context.source,"ldd",filename])
            for line in lddout.split("\n"):
                libfile = re.sub(r' *\(0x.+\)$', "", re.sub(r'.*=> +', "", line)).strip()
                if libfile.startswith("/"):
                    process_file(context, libfile)
        except Exception as e:
            print(e)

def process_package(context, package_dir, exclude_patterns, expected_use_flags):
    def is_needed(filename, exclude_patterns):
        exclude_prefixes = ["/usr/share/doc/", "/usr/share/info/", "/usr/share/gtk-doc/", "/usr/share/man/", "/usr/include/", "/usr/lib/pkgconfig/", "/usr/lib64/pkgconfig/","/usr/share/pkgconfig/","/dev/","/etc/portage/"]
        for pfx in exclude_prefixes:
            if filename.startswith(pfx): return False

        for ptn in exclude_patterns + [r"^/usr/lib(64)?/.*lib.+\.a$",r"^/usr/share/locale/(?!ja).+?/"]:
            if re.compile(ptn).match(filename): return False
        return True

    # Check USE flag requirements
    use_flags = open("%s/USE" % package_dir).read().split()
    for u in expected_use_flags:
        if u.startswith('-'):
            if u[1:] in use_flags: raise Exception("USE flag %s is set when it shouldn't be." % u[1:])
        elif u not in use_flags: raise Exception("USE flag %s is missing when it should be." % u)

    with open("%s/CONTENTS" % package_dir) as f:
        line = f.readline()
        while line:
            splitted = line.strip().split(' ')
            ent_type = splitted[0] if len(splitted) > 0 else None
            filename = None
            if ent_type == "obj":
                filename = ' '.join(splitted[1:-2])
            elif ent_type == "sym":
                filename = ' '.join(splitted[1:-1]).split(" -> ")[0]
            if filename is not None and is_needed(filename, exclude_patterns):
                process_file(context, filename)
            line = f.readline()

def process_lstfile(context, lstfile):
    def require(args):
        dirname = os.path.dirname(lstfile)
        required_lstfile = context.apply_variables(args[0])
        if dirname != "": required_lstfile = os.path.normpath(dirname + "/" + required_lstfile)
        process_lstfile(context, required_lstfile)

    def package(args):
        parser = argparse.ArgumentParser()
        parser.add_argument("--exclude", action="append", default=[], help="exclude pattern(can be used multiple times)")
        parser.add_argument("--use", type=str, default="", help="USE flags to be expected")
        parser.add_argument("package", type=str, help="package name")
        args = parser.parse_args(args)
        target_package = context.apply_variables(args.package)
        match = glob.glob(os.path.normpath("%s/var/db/pkg/%s/CONTENTS" % (context.source, target_package)))
        if len(match) < 1:
            match = glob.glob(os.path.normpath("%s/var/db/pkg/%s-[0-9]*/CONTENTS" % (context.source, target_package)))
        if len(match) < 1:
            raise Exception("Package doesn't match: '%s'" % target_package)
        elif len(match) > 1:
            raise Exception("Package anbiguous: '%s', %d packages match" % (target_package, len(match)))
        process_package(context, os.path.dirname(match[0]), args.exclude, args.use.split())
        
    def _kernel(args):
        kernel.apply(context, args)
        
    def _execute(args):
        execute.apply(context, args)

    def mkdir(args):
        if len(args) < 1: raise Exception("$mkdir directive gets at least 1 argument")
        for arg in args:
            if not arg.startswith('/'): raise Exception("Directory name must start with '/'")
            name = "%s%s" % (context.destination, context.apply_variables(arg))
            print "$mkdir '%s'" % arg
            mkdir_p(name)

    def deltree(args):
        if len(args) < 1: raise Exception("$deltree directive gets at least 1 argument")
        for arg in args:
            if not arg.startswith('/'): raise Exception("Directory name must start with '/'")
            name = "%s%s" % (context.destination, context.apply_variables(arg))
            print "$deltree '%s'" % arg
            shutil.rmtree(name)

    def mv(args):
        if len(args) != 2: raise Exception("$mv directive must have 2 args")
        if not args[0].startswith('/'): raise Exception("Filename must start with '/'")
        if not args[1].startswith('/'): raise Exception("Filename must start with '/'")
        src = "%s%s" % (context.destination, context.apply_variables(args[0]))
        dst = "%s%s" % (context.destination, context.apply_variables(args[1]))
        print "Move file/dir: %s -> %s" % (src, dst)
        subprocess.check_call(["/bin/mv",src,dst])
        
    def symlink(args):
        if len(args) != 2: raise Exception("$symlink directive must have 2 args")
        if not args[0].startswith('/'): raise Exception("Filename must start with '/'")
        name = "%s%s" % (context.destination, context.apply_variables(args[0]))
        src = context.apply_variables(args[1])
        print "Create symlink: %s(%s)" % (name, src)
        if os.path.lexists(name): os.unlink(name)
        os.symlink(src, name)

    def sed(args):
        if len(args) != 2: raise Exception("$sed directive gets 2 args")
        if not args[0].startswith('/'): raise Exception("Filename must start with '/'")
        name = "%s%s" % (context.destination, context.apply_variables(args[0]))
        print "$sed '%s' to '%s'" % (args[1], name)
        subprocess.check_call(["/bin/sed","-i",args[1],name])

    def touch(args):
        if len(args) < 1: raise Exception("$touch directive needs at least one arg")
        for arg in args:
            if not arg.startswith('/'): raise Exception("Filename must start with '/'")
            name = "%s%s" % (context.destination, context.apply_variables(arg))
            print "$touch '%s'" % arg
            subprocess.check_call(["/usr/bin/touch", name])

    def write(args):
        parser = argparse.ArgumentParser()
        parser.add_argument("--append", action="store_true", help="append instead of overwrite")
        parser.add_argument("name", type=str, help="filename")
        parser.add_argument("text", type=str, help="text to write to file (in echo -e format)")
        args = parser.parse_args(args)
        if not args.name.startswith('/'): raise Exception("File name must start with '/'")
        name = "%s%s" % (context.destination, context.apply_variables(args.name))
        text = context.apply_variables(args.text)
        print "$write '%s' to '%s" % (text, name)
        with open(name, "a" if args.append else "w") as f:
            subprocess.check_call(["echo","-e",text], stdout=f)

    def copy(args):
        if len(args) != 2: raise Exception("$copy directive gets 2 args")
        src = os.path.normpath("files/" + context.apply_variables(args[0]))
        dest = os.path.normpath("%s%s" % (context.destination, context.apply_variables(args[1])))
        if not os.path.lexists(src): raise Exception("%s:file not found" % (src))
        if os.path.isdir(src): raise Exception("%s:dir cannot be specified as source" % (src))
        if os.path.isdir(dest): raise Exception("%s:dir cannot be specified as destination" % (dest))
        subprocess.check_call(["cp","-av",src, dest])
        os.chown(dest, 0, 0)

    def patch(args):
        if len(args) != 2: raise Exception("$patch directive gets 2 args")
        if not args[0].startswith('/'): raise Exception("Target file/dirname must start with '/'")
        target = os.path.normpath("%s%s" % (context.destination, context.apply_variables(args[0])))
        patchfile = os.path.normpath("files/" + context.apply_variables(args[1]))
        print "$patch applying '%s' to '%s'" % (patchfile, target)

        statinfo = os.stat(target)
        mode = stat.S_IMODE(statinfo[stat.ST_MODE])
        uid = statinfo[stat.ST_UID]
        gid = statinfo[stat.ST_GID]
        subprocess.check_call(["patch","-p1","-i",patchfile,target])
        os.chmod(target, mode)
        os.chown(target, uid, gid)

    def device(args):
        parser = argparse.ArgumentParser()
        parser.add_argument("--nonroot-friendly", action="store_true", help="make its mode 0666")
        parser.add_argument("type", type=str, help="device type(b or c)")
        parser.add_argument("name", type=str, help="device filename")
        parser.add_argument("major", type=int, help="major device number")
        parser.add_argument("minor", type=int, help="minor device number")
        args = parser.parse_args(args)
        if not args.name.startswith('/'): raise Exception("Device file name must start with '/'")
        mode = 0666 if args.nonroot_friendly else 0600
        if args.type == "b": mode |= stat.S_IFBLK
        elif args.type == "c": mode |= stat.S_IFCHR
        else: raise Exception("Unknown device type '%s'" % args.type)
        name = "%s%s" % (context.destination, args.name)
        if os.path.exists(name): os.unlink(name)
        os.mknod(name, mode, os.makedev(args.major, args.minor))
        if args.nonroot_friendly:
            # According to https://www.soljerome.com/blog/2011/08/26/python-umask-inconsistencies/ , os.mknod is affected by running process' umask so we need to adjust its mode afterwards
            os.chmod(name, 0666)

    def setvar(args):
        if len(args) != 2: raise Exception("$set directive gets 2 args")
        context.set_variable(args[0], context.apply_variables(args[1]))

    def vadesc(args):
        if len(args) != 0: raise Exception("$vadesc directive doesn't take args")
        catalog_file = "catalog/%s-%s-%s.json" % (context.get_variable("ARTIFACT"), context.get_variable("ARCH"), context.get_variable("REGION"))
        catalog = json.load(open(catalog_file))
        etree = catalog2vadesc.run(catalog)
        with open("%s/etc/wb-va.xml" % context.destination, "w") as f:
            etree.write(f, pretty_print=True, encoding='UTF-8', xml_declaration=True)

    def download(args):
        parser = argparse.ArgumentParser()
        parser.add_argument("--filename", type=str, help="filename to save")
        parser.add_argument("url", type=str, help="URL to download")
        args = parser.parse_args(args)
        url = context.apply_variables(args.url)
        filename = os.path.basename(url) if args.filename is None else args.filename
        cache_file = "download_cache/%s" % filename
        progress_file = "download_cache/_download_in_progress"
        if not os.path.exists(cache_file):
            mkdir_p("download_cache")
            subprocess.check_call(["wget","-O",progress_file,url])
            os.rename(progress_file, cache_file)
        mkdir_p("%s/tmp/download" % context.destination)
        shutil.copy(cache_file, "%s/tmp/download/%s" % (context.destination, filename))

    def debootstrap(args):
        parser = argparse.ArgumentParser()
        parser.add_argument("--include", type=str, help="additional packages(comma separated)")
        parser.add_argument("dist", type=str, help="name of distribution such as 'jessie'")
        args = parser.parse_args(args)
        dist = context.apply_variables(args.dist)
        include = context.apply_variables(args.include)
        arch = {"x86_64":"amd64","i686":"i386"}[context.get_variable("ARCH")]
        include_hash = "none" if include is None else base64.b32encode(hashlib.sha1(include).digest())[:8]
        cache_file = "download_cache/debootstrap-%s-%s-%s.tar.gz" % (dist, arch, include_hash)
        if not os.path.isfile(cache_file):
            debootstrap_dir = os.path.normpath(context.destination) + ".debootstrap"
            mkdir_p(debootstrap_dir)
            try:
                subprocess.check_call(["debootstrap","--no-check-gpg","--arch=%s" % arch,"--include=%s" % args.include,dist,debootstrap_dir], env=env_with_root_path())
                subprocess.check_call(["chroot", debootstrap_dir, "apt-get","clean"])
                progress_file = "download_cache/_debootstrap_in_progress"
                subprocess.check_call(["tar","zcvpf",progress_file,"-C",debootstrap_dir,"."])
                os.rename(progress_file, cache_file)
            finally:
                shutil.rmtree(debootstrap_dir)
        subprocess.check_call(["tar","zxvpf",cache_file,"-C",context.destination])

    directives = {
        "$require":require,
        "$package":package,
        "$kernel":_kernel,
        "$exec":_execute,
        "$mkdir":mkdir,
        "$deltree":deltree,
        "$symlink":symlink,
        "$sed":sed,
        "$touch":touch,
        "$write":write,
        "$copy":copy,
        "$mv":mv,
        "$patch":patch,
        "$device":device,
        "$set":setvar,
        "$vadesc":vadesc,
        "$download":download,
        "$debootstrap":debootstrap
    }
    
    if context.is_lstfile_already_processed(lstfile): return
    print "Processing %s" % (lstfile)
    with open(lstfile) as f:
        line = f.readline()
        while line:
            if line.startswith("$"): # directive
                directive_line = shlex.split(line, True)
                if directive_line[0] not in directives:
                    raise Exception("Invalid directive '%s' in %s" % (directive_line[0], lstfile))
                directives[directive_line[0]](directive_line[1:])
            elif not line.startswith("#"):
                filename = line.strip()
                if filename != "": process_file(context, context.apply_variables(filename))
            line = f.readline()
    context.mark_lstfile_as_processed(lstfile)
        
def run(lstfile, context):
    print "lstfile=%s, source=%s, destination=%s" % (lstfile, context.source, context.destination)
    mkdir_p(context.destination)
    process_lstfile(context, lstfile)

    # Cleanup /tmp
    tmpdir = "%s/tmp" % context.destination
    if os.path.isdir(tmpdir):
        for item in os.listdir(tmpdir):
            filename = "%s/%s" % (tmpdir, item)
            if os.path.islink(filename) or not os.path.isdir(filename): os.unlink(filename)
            else: shutil.rmtree(filename)

    # execute ldconfig if exists
    ldconfig = "%s/sbin/ldconfig" % context.destination
    if is_executable(ldconfig):
        print "Executing /sbin/ldconfig..."
        subprocess.check_call(["chroot", context.destination, "/sbin/ldconfig"])

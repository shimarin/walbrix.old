# -*- coding:utf-8 -*-
import os,re,glob,struct,stat,shutil,subprocess,argparse,shlex,chardet
import magic # emerge python-magic
import kernelver

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

def process_path(srcpath, dstpath, stack = None):
    if stack == None: stack = []
    if os.path.isdir(dstpath) or dstpath == "":
        finish_path(context, dstpath, stack)
        return
    #else
    srcleft, srcright = os.path.split(srcpath)
    dstleft, dstright = os.path.split(dstpath)
    stack.append((dstright,srcpath))
    process_path(srcleft, dstleft, stack)
        
def process_file(context, filename):
    if context.is_file_already_collected(filename): return

    src = os.path.normpath("%s%s" % (context.source, filename))
    dest = os.path.normpath("%s%s" % (context.destination, filename))
    if not os.path.lexists(src): raise Exception("%s:file not found" % (src))
    
    process_path(os.path.normpath(os.path.dirname(src)), os.path.normpath(os.path.dirname(dest)))

    if os.path.isdir(src) and not os.path.islink(src): # process directory recursively
        for root, dirs, files in os.walk(src):
            for file in files:
                process_file(context, os.path.join(root, file)[len(context.source):])
        return

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

def process_package(context, contents_file): # todo: support exclude patterns
    def is_needed(filename):
        exclude_prefixes = ["/usr/share/doc/", "/usr/share/info/", "/usr/share/gtk-doc/", "/usr/share/man/", "/usr/include/", "/usr/lib/pkgconfig/", "/usr/lib64/pkgconfig/","/dev/"]
        for pfx in exclude_prefixes:
            if filename.startswith(pfx): return False

        exclude_patterns = [r"^/usr/lib(64)?/.*lib.+\.a$",r"^/usr/share/locale/(?!ja).+?/"]
        # todo: support exclude patterns
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
                process_file(context, filename)
            line = f.readline()

def process_lstfile(context, lstfile):
    def require(args):
        dirname = os.path.dirname(lstfile)
        required_lstfile = context.apply_variables(args[0])
        if dirname != "": required_lstfile = os.path.normpath(dirname + "/" + required_lstfile)
        process_lstfile(context, required_lstfile)

    def package(args):
        if len(args) != 1: raise Exception("$package directive gets 1 argument")
        target_package = args[0]
        match = glob.glob(os.path.normpath("%s/var/db/pkg/%s/CONTENTS" % (context.source, target_package)))
        if len(match) < 1:
            match = glob.glob(os.path.normpath("%s/var/db/pkg/%s-[0-9]*/CONTENTS" % (context.source, target_package)))
        if len(match) < 1:
            raise Exception("Package doesn't match: '%s'" % target_package)
        elif len(match) > 1:
            raise Exception("Package anbiguous: '%s', %d packages match" % (target_package, len(match)))
        process_package(context, match[0])
        
    def kernel(args):
        if len(args) != 1: raise Exception("$kernel directive gets 1 argument")
        kernelfile = os.path.normpath("%s/%s" % (context.source, context.apply_variables(args[0])))
        print("Getting KERNEL_VERSION from %s" % kernelfile)
        kernel_version = kernelver.get_kernel_version_string(kernelfile)
        context.set_variable("KERNEL_VERSION", kernel_version)
        print("KERNEL_VERSION set to %s" % kernel_version)
        
    def execute(args):
        if len(args) != 1: raise Exception("$exec directive gets 1 argument")
        command = context.apply_variables(args[0])
        print "$exec '%s'" % command
        subprocess.check_call(["chroot", context.destination, "/bin/sh", "-c", command])

    def mkdir(args):
        if len(args) < 1: raise Exception("$mkdir directive gets at least 1 argument")
        for arg in args:
            if not arg.startswith('/'): raise Exception("Directory name must start with '/'")
            name = "%s%s" % (context.destination, context.apply_variables(arg))
            print "$mkdir '%s'" % arg
            mkdir_p(name)

    def deltree(args):
        if len(args) != 1: raise Exception("$deltree directive gets at least 1 argument")
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

    def copy(args):
        if len(args) != 2: raise Exception("$copy directive gets 2 args")
        src = os.path.normpath("files/" + context.apply_variables(args[0]))
        dest = os.path.normpath("%s%s" % (context.destination, context.apply_variables(args[1])))
        if not os.path.lexists(src): raise Exception("%s:file not found" % (src))
        if os.path.isdir(src): raise Exception("%s:dir cannot be specified as source" % (src))
        if os.path.isdir(dest): raise Exception("%s:dir cannot be specified as destination" % (dest))
        subprocess.check_call(["cp","-av",src, dest])
        os.chown(dest, 0, 0)

    directives = {
        "$require":require,
        "$package":package,
        "$kernel":kernel,
        "$exec":execute,
        "$mkdir":mkdir,
        "$deltree":deltree,
        "$symlink":symlink,
        "$sed":sed,
        "$touch":touch,
        "$copy":copy,
        "$mv":mv
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

def parse_var(arg):
    kv = arg.split('=', 1)
    if len(kv) < 2: raise Exception("Invalid variable format (KEY=VALUE expected)")
    return (kv[0].strip(), kv[1].strip())

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=str, default="/", help="source directory")
    parser.add_argument("--var", type=str, action="append", help="variable")
    parser.add_argument("lstfile", type=str, help=".lst file")
    parser.add_argument("destination", type=str, help="destination directory")
    args = parser.parse_args()
    context = Context(args.source, args.destination, dict(map(lambda x:parse_var(x), args.var)))
    run(args.lstfile, context)

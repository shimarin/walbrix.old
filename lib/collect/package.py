import os,re,argparse,glob
import collect

def process_package(context, package_dir, exclude_patterns, expected_use_flags, no_copy = False):
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
            if u[1:] in use_flags: raise Exception("%s: USE flag %s is set when it shouldn't be." % (package_dir, u[1:]))
        elif u not in use_flags: raise Exception("%s: USE flag %s is missing when it should be." % (package_dir, u))

    if no_copy: return

    #else
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

            src = os.path.normpath("%s%s" % (context.source, filename))
            dest = os.path.normpath("%s%s" % (context.destination, filename))

            if filename is not None and is_needed(filename, exclude_patterns) and (os.path.exists(src) or not os.path.exists(dest)):
                collect.process_file(context, filename)
            line = f.readline()

def apply(context, args, dry_run = False):
    parser = argparse.ArgumentParser()
    parser.add_argument("--exclude", action="append", default=[], help="exclude pattern(can be used multiple times)")
    parser.add_argument("--use", type=str, default="", help="USE flags to be expected")
    parser.add_argument("--no-copy", action="store_true", help="just make sure that package exists")
    parser.add_argument("--optional", action="store_true", help="just ignore if not exist")
    parser.add_argument("package", type=str, help="package name")
    args = parser.parse_args(args)
    target_package = context.apply_variables(args.package)
    match = glob.glob(os.path.normpath("%s/var/db/pkg/%s/CONTENTS" % (context.source, target_package)))
    if len(match) < 1:
        match = glob.glob(os.path.normpath("%s/var/db/pkg/%s-[0-9]*/CONTENTS" % (context.source, target_package)))
    if len(match) < 1:
        if args.optional:
            print "Package doesn't match: '%s'" % target_package
            return None
        raise Exception("Package doesn't match: '%s'" % target_package)
    elif len(match) > 1:
        raise Exception("Package anbiguous: '%s', %d packages match" % (target_package, len(match)))

    process_package(context, os.path.dirname(match[0]), args.exclude, args.use.split(), args.no_copy or dry_run)
    return match[0]

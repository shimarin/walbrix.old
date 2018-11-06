import argparse,subprocess,os,re,shutil,base64,hashlib
import collect,execute

def apply(context, args):
    parser = argparse.ArgumentParser()
    parser.add_argument("--arch", type=str, help="target architecture (this directive is ignored if arch differents from $(ARCH))")
    parser.add_argument("--include", type=str, help="additional packages(space separated)")
    parser.add_argument("releaserpm", type=str, help="URL of release rpm") # e.g. http://ftp.kddilabs.jp/pub/Linux/distributions/CentOS/7.1.1503/os/x86_64/Packages/centos-release-7-1.1503.el7.centos.2.8.x86_64.rpm
    args = parser.parse_args(args)
    if args.arch is not None and args.arch != context.get_variable("ARCH"): return
    releaserpm = context.apply_variables(args.releaserpm)
    include = context.apply_variables(args.include)
    prefix = ["i386"] if context.get_variable("ARCH") == "i686" else []
    release_name = re.sub('\.rpm$','', os.path.basename(releaserpm))

    include_hash = "none" if include is None else base64.b32encode(hashlib.sha1(include).digest())[:8]
    cache_file = "download_cache/%s-%s.tar.gz" % (release_name, include_hash)
    if not os.path.isfile(cache_file):
        rpmbootstrap_dir = os.path.normpath(context.destination) + ".rpmbootstrap"
        collect.mkdir_p("%s/var/lib/rpm" % rpmbootstrap_dir)
        try:
            subprocess.check_call(prefix + ["rpm","--root",rpmbootstrap_dir,"--initdb"])
            subprocess.check_call(prefix + ["rpm","-ivh","--nodeps","--root",os.path.abspath(rpmbootstrap_dir),releaserpm])
            subprocess.check_call(prefix + ["yum","--nogpgcheck","--installroot",os.path.abspath(rpmbootstrap_dir),"install","-y","yum"])
            shutil.rmtree("%s/var/lib/rpm" % rpmbootstrap_dir)
            collect.mkdir_p("%s/var/lib/rpm" % rpmbootstrap_dir)
            shutil.rmtree("%s/var/cache/yum"  % rpmbootstrap_dir)
            with open("%s/etc/resolv.conf" % rpmbootstrap_dir, "w") as f:
                f.write("nameserver 8.8.8.8\n")
            env_with_root_path = collect.env_with_root_path()
            execute.do_chroot(rpmbootstrap_dir, "rpm --initdb", envvars=env_with_root_path)
            execute.do_chroot(rpmbootstrap_dir, "rpm -ivh %s --nodeps" % releaserpm, envvars=env_with_root_path)
            execute.do_chroot(rpmbootstrap_dir, "yum install -y yum", envvars=env_with_root_path)
            if include is not None:
                execute.do_chroot(rpmbootstrap_dir,"yum install -y %s" % include, envvars=env_with_root_path)
            execute.do_chroot(rpmbootstrap_dir,"yum clean -y all", envvars=env_with_root_path)
            shutil.rmtree("%s/var/cache/yum/base/packages" % rpmbootstrap_dir, True)
            collect.mkdir_p("%s/var/cache/yum/base/packages" % rpmbootstrap_dir)
        
            progress_file = "download_cache/_rpmbootstrap_in_progress"
            subprocess.check_call(["tar","zcvpf",progress_file,"--xattrs","--xattrs-include=*","-C",rpmbootstrap_dir,"."])
            os.rename(progress_file, cache_file)
        finally:
            shutil.rmtree(rpmbootstrap_dir, True)

    subprocess.check_call(["tar","zxvpf",cache_file,"--xattrs","--xattrs-include=*","-C",context.destination])

import argparse,json,urllib2,urlparse,subprocess,os,errno,contextlib,signal,time,crypt,re
import cli2.create_install_disk as util,cli2.list as cli_list

@contextlib.contextmanager
def process_for_output(cmdline):
    if signal.getsignal(signal.SIGTERM) in [None, signal.SIG_DFL]:
        signal.signal(signal.SIGTERM, signal.default_int_handler)

    p = subprocess.Popen(cmdline, shell=not isinstance(cmdline, list), stdin=subprocess.PIPE,close_fds=True)
    try:
        yield p.stdin
        p.stdin.close()
    except:
        p.terminate()
        raise
    finally:
        rst = p.wait()
        if rst not in [0, -signal.SIGTERM]: raise Exception("Process returned exit code %d" % rst)

@contextlib.contextmanager
def input_stream(urlOrFilename):
    if urlOrFilename.startswith("http://") or urlOrFilename.startswith("https://"):
        try:
            source = urllib2.urlopen(urlOrFilename)
            content_length = source.headers.getheader("Content-length")
            length = int(content_length) if content_length is not None else None
        except urllib2.HTTPError as e:
            raise IOError(e)
    else:
        try:
            length = os.path.getsize(urlOrFilename)
            source = open(urlOrFilename)
        except OSError as e:
            raise IOError(e)

    try:
        yield source, length
    finally:
        source.close()

def get_tar_decompression_option(url):
    filetypes = {
        "tar":"",
        "tar.gz":"z",
        "tgz":"z",
        "tar.bz2":"j",
        "tbz2":"j",
        "tar.lzma":"J",
        "tar.xz":"J"
    }
    for suffix,option in filetypes.iteritems():
        if url.endswith(suffix): return option
    #else
    return None

def is_tarball(url):
    return get_tar_decompression_option(url) is not None

def is_squashfs(url):
    return url.endswith(".squashfs")

def load_json(url):
    if urlparse.urlparse(url).scheme == '': # local file
        return (json.load(open(url)), url)
    #else
    network_res = urllib2.urlopen(url)
    json_content = json.load(network_res)
    return (json_content, network_res.geturl())

def select_vg(size):
    vgs = [ x.split() for x in subprocess.check_output(["vgs","@wbvg","--noheadings","--units=g","--nosuffix","-o","vg_name,vg_free,vg_size,lv_count"],close_fds=True).splitlines() ]

    #vgs.append(["hoge","10","10", "4"])

    vgs = filter(lambda x:float(x[1]) >= size, vgs)

    if len(vgs) == 0: raise Exception("There's no usable VolumeGourp")

    if len(vgs) == 1: return vgs[0][0]
    #else

    row_format ="{:<3} {:<15} {:>6} {:1}{:>6} {:>6}"
    print row_format.format("#","VG_NAME","FREE","/","TOTAL","# LV")
    print "-------------------------------------------"
    for i in range(len(vgs)):
        free = int(float(vgs[i][1]))
        total = int(float(vgs[i][2]))
        print row_format.format(i+1,vgs[i][0],"%dG" % free,"/","%dG" % total,int(vgs[i][3]))
    while True:
        user_input = raw_input("Which VG do you want to use: ")
        if user_input == "": return None
        try:
            num = int(user_input)
        except ValueError:
            print "Please enter a number."
            continue
        if num > len(vgs) or num < 1:
            print "Number out of range(1-%d)." % len(vgs)
        else:
            break
    return vgs[num - 1][0]

def get_available_vm_name(name):
    all_domain_names = set([x["name"] for x in cli_list.get_all_domains().values()])
    if name not in all_domain_names: return name
    for num in range(2,10):
        name_candidate = "%s%d" % (name, num)
        if name_candidate not in all_domain_names: return name_candidate

    raise Exception("VM name couldn't be determined automatically")

def resolve_relative_path(origin, relative):
    origin = urlparse.urlparse(origin)
    relative = urlparse.urlparse(relative)
    if relative.path == '':
        raise ValueError('path part of URL is empty.')
    resolved = (
        relative.scheme if relative.scheme != '' else origin.scheme,
        relative.netloc if relative.netloc != '' else origin.netloc,
        os.path.normpath(os.path.join(os.path.dirname(origin.path),relative.path)),
        '','',''
    )
    return urlparse.urlunparse(resolved)

def create_xen_conf(rootdir, ram=None, vcpus=None):
    xen_conf_dir = os.path.join(rootdir, "etc/xen")
    if not os.path.isdir(xen_conf_dir):
        if os.path.exists(xen_conf_dir): os.unlink(xen_conf_dir)
        os.makedirs(xen_conf_dir)
    xen_conf_file = os.path.join(xen_conf_dir, "config")

    vals = {}
    if os.path.exists(xen_conf_file):
        exec open(xen_conf_file).read() in None, vals

    if ram is not None: vals["memory"] = ram
    if vcpus is not None: vals["vcpus"] = vcpus

    with open(xen_conf_file, "w") as f:
        for key, value in vals.iteritems():
            f.write("%s=%s\n" % (key, repr(value)))

def set_hostname(rootdir, hostname):
    debian = os.path.join(rootdir, "etc/hostname") # debian(generic UNIX)
    redhat = os.path.join(rootdir, "etc/sysconfig/network") # RedHat
    gentoo = os.path.join(rootdir, "etc/conf.d/hostname") # Gentoo

    done = False

    if os.path.isfile(debian):
        with open(debian, "w") as f:
            f.write(hostname)
        done = True

    if os.path.isfile(redhat):
        with open(redhat, "w") as f:
            f.write("NETWORKING=yes\nNETWORKING_IPV6=yes\nHOSTNAME=%s.local" % (hostname))
        done = True

    if os.path.isfile(gentoo):
        with open(gentoo, "w") as f:
            f.write("hostname=\"%s\"" % (hostname))
        done = True

    return done

def set_root_password(rootdir, password):
    crypted = crypt.crypt(password, password[0]+password[-1])
    return subprocess.call(["sed","-i","s/^root:[^:]*\(.*\)/root:%s\\1/" % re.escape(crypted),os.path.join(rootdir, "etc/shadow")]) == 0

def copy_public_keys(rootdir):
    root = os.path.join(rootdir, "root")
    dot_ssh = os.path.join(root, ".ssh")
    if os.path.exists(dot_ssh):
        if not os.path.isdir(dot_ssh): raise Exception(".ssh must be a directory!")
    else:
        if not os.path.exists(root): os.mkdir(root, 0700)
        os.mkdir(dot_ssh, 0700)

    with open(os.path.join(rootdir, os.path.join(dot_ssh, "authorized_keys")), "a") as authorized_keys:
        for pubkeyfile in ["/root/.ssh/id_rsa.pub", "/root/.ssh/id_dsa.pub", "/root/.ssh/authorized_keys"]:
            if not os.path.isfile(pubkeyfile): continue
            pubkey = open(pubkeyfile).read()
            if len(pubkey) < 1: continue
            if pubkey[-1] != '\n': pubkey += '\n'
            authorized_keys.write(pubkey)

def copy_archive(archive, out):
    with input_stream(archive) as (src, size):
        copied = 0
        buf = src.read(4096)
        while buf != "":
            out.write(buf)
            copied += len(buf)
            buf = src.read(4096)

def setup_vm_info(rootdir, vmname, ram, vcpus=1, root_password=None,copy_pubkey=False):
    create_xen_conf(rootdir, ram, vcpus)
    set_hostname(rootdir, vmname)
    if root_password is not None:
        set_root_password(rootdir, root_password)
    if copy_pubkey:
        copy_public_keys(rootdir)

def install(rootdir, archive, vmname,size,ram,vcpus=1,root_password=None,verbose=False,copy_pubkey=False):
    if archive[1] == "tar":
        with process_for_output(["tar",get_tar_decompression_option(archive[0]) + ("xvpf" if verbose else "xpf"),"-","--xattrs","--xattrs-include=*","-C",rootdir]) as tar:
            copy_archive(archive[0], tar)
        setup_vm_info(rootdir, vmname, ram, vcpus, root_password, copy_pubkey)
    elif archive[1] == "squashfs":
        ro_layer = "system"
        rw_layer = "rw"
        ro_file = os.path.join(rootdir, ro_layer)
        rw_dir = os.path.join(rootdir, rw_layer)
        work_dir = os.path.join(rootdir, "work")
        os.makedirs(rw_dir)
        os.makedirs(work_dir)
        with open(ro_file, "w") as f:
            copy_archive(archive[0], f)
        os.makedirs(os.path.join(rootdir, "boot/grub"))
        with open(os.path.join(rootdir, "boot/grub/grub.cfg"),"w") as f:
            f.write("set WALBRIX_RO_LAYER=/%s\n" % ro_layer)
            f.write("set WALBRIX_RW_LAYER=/%s\n" % rw_layer)
            f.write("loopback loop ${WALBRIX_RO_LAYER}\n")
            f.write("set root=loop\n")
            f.write("normal /boot/grub/grub.cfg")

        with util.tempmount(ro_file, "loop,ro", "squashfs") as tmpdir1:
            with util.tempmount("overlay", "lowerdir=%s,upperdir=%s,workdir=%s" % (tmpdir1, rw_dir, work_dir), "overlay") as tmpdir2:
                setup_vm_info(tmpdir2, vmname, ram, vcpus, root_password, copy_pubkey)
    else:
        raise Exception("Unknown archive type:%s" % archive[1])

def run(url, vg, name,size,btrfs,ram,vcpus=1,root_password=None,verbose=False,copy_pubkey=False):
    archive = None

    if is_tarball(url): archive = (url, "tar")
    elif is_squashfs(url): archive = (url, "squashfs")
    else:
        vainfo, origin = load_json(url)
        id = vainfo.get("id")
        name = name or id
        if name is None: raise Exception("'id' field not found from VA info")
        minimum_ram = vainfo.get("minimum_ram")
        minimum_hd = vainfo.get("minimum_hd")
        ram = ram or minimum_ram
        if ram is None: raise Exception("'minimum_ram' field not found from VA info")
        size = size or minimum_hd
        if size is None: raise Exception("'minimum_hd' field not found from VA info")
        if "squashfs" in vainfo: # detect squashfs first
            archive = (resolve_relative_path(origin, vainfo["squashfs"]), "squashfs")
        elif "tarball" in vainfo:
            archive = (resolve_relative_path(origin, vainfo["tarball"]), "tar")

    if archive is None: raise Exception("Archive file couldn't be determined")

    if name is None:
        basename = os.path.basename(archive[0])
        if '-' not in basename: raise Exception("Could not determine VA name from tar filename '%s'" % basename)
        name = basename.split('-')[0]

    vmname = get_available_vm_name(name)
    if verbose: print "VM name: %s, Source archive: %s" % (vmname, archive[0])
    if archive[0].startswith("http://") or archive[0].startswith("https://"):
        pass # TODO: check if resource exists
    else:
        if not os.path.isfile(archive[0]): raise Exception("Archive file '%s' does not exist" % archive[0])

    vg = vg or select_vg(size)
    if vg == None:
        print "Cancelled."
        return

    subprocess.check_call(["lvcreate","--yes","--addtag=@wbvm","-n",vmname,"-L","%dG" % size,vg], close_fds=True)
    device = "/dev/%s/%s" % (vg, vmname)
    print "Logical volume %s created." % device
    success = False
    try:
        if btrfs:
            subprocess.check_call(["mkfs.btrfs",device])
        else:
            metadata_opts = ["-m","crc=0"] if "-i686" in archive[0] and archive[1] == "tar" else [] # because grub1 cannot recognize crc
            subprocess.check_call(["mkfs.xfs","-f"] + metadata_opts + [device])
        with util.tempmount(device, None if btrfs else "inode32", "btrfs" if btrfs else "xfs") as tmpdir:
            install(tmpdir, archive, vmname, size, ram, vcpus, root_password,verbose,copy_pubkey)
        success = True
    finally:
        if not success:
            for i in range(5):
                if subprocess.call(["lvremove", "-f", device],close_fds=True) == 0: break
                time.sleep(1)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--vg", type=str, help="Volume group name to install VA default=automatically chosen")
    parser.add_argument("-n", "--name", type=str, help="VM name to create default=determined from filename", default=None)
    parser.add_argument("-L", "--size", type=int, help="size of logical volume for the application(in gigabytes)")
    parser.add_argument("--btrfs", action="store_true", help="Use btrfs instead of xfs")
    parser.add_argument("-r", "--ram", type=int, help="RAM size for new VM in megabytes")
    parser.add_argument("-u", "--vcpus", type=int, default=1, help="Number of virtual CPU cores")
    parser.add_argument("-p", "--root-password", type=str, help="Set root password after extraction")
    parser.add_argument("-v", "--verbose", action="store_true", help="Verbose mode")
    parser.add_argument("-k", "--copy-pubkey", action="store_true", help="Copy ssh public keys(id_rsa/dsa.pub, authorized_keys) to extracted VM's /root/.ssh/authorized_keys")
    parser.add_argument("url", type=str, help="Virtual Appliance (JSON|archive) (URL|filename)")
    args = parser.parse_args()

    if (is_tarball(args.url) or is_squashfs(args.url)) and args.size is None:
        raise Exception("--size must be specified when importing archive file directly")

    run(args.url,args.vg, args.name,args.size,args.btrfs,args.ram,args.vcpus,args.root_password,args.verbose,args.copy_pubkey)

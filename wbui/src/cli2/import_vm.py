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
        "tar.bz2":"j",
        "tar.lzma":"J",
        "tar.xz":"J"
    }
    for suffix,option in filetypes.iteritems():
        if url.endswith(suffix): return option
    #else
    return None

def is_tarball(url):
    return get_tar_decompression_option(url) is not None

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

def create_xen_conf(rootdir, ram, vcpus):
    xen_conf_dir = os.path.join(rootdir, "etc/xen")
    if not os.path.isdir(xen_conf_dir):
        if os.path.exists(xen_conf_dir): os.unlink(xen_conf_dir)
        os.makedirs(xen_conf_dir)
    with open(os.path.join(xen_conf_dir, "config"), "w") as f:
        f.write("memory=%d\n" % ram)
        f.write("vcpus=%d\n" % vcpus)

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

def install(rootdir, tarball, vmname,size,ram,vcpus=1,root_password=None,verbose=False,copy_pubkey=False):
    with process_for_output(["tar",get_tar_decompression_option(tarball) + ("xvpf" if verbose else "xpf"),"-","-C",rootdir]) as tar:
        with input_stream(tarball) as (src, size):
            copied = 0
            buf = src.read(4096)
            while buf != "":
                tar.write(buf)
                copied += len(buf)
                buf = src.read(4096)
    create_xen_conf(rootdir, ram, vcpus)
    set_hostname(rootdir, vmname)
    if root_password is not None:
        set_root_password(rootdir, root_password)
    if copy_pubkey:
        copy_public_keys(rootdir)

def run(url, vg, name,size,ram,vcpus=1,root_password=None,verbose=False,copy_pubkey=False):
    if is_tarball(url):
        tarball = url
        if name is None:
            basename = os.path.basename(tarball)
            if '-' not in basename: raise Exception("Could not determine VA name from tar filename '%s'" % basename)
            name = basename.split('-')[0]
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
        if "tarball" not in vainfo: raise Exception("'tarball' field not found from VA info")
        tarball = resolve_relative_path(origin, vainfo["tarball"])

    vmname = get_available_vm_name(name)
    if verbose: print "VM name: %s, Source tarball: %s" % (vmname, tarball)
    if tarball.startswith("http://") or tarball.startswith("https://"):
        pass # TODO: check if resource exists
    else:
        if not os.path.isfile(tarball): raise Exception("Archive file '%s' does not exist" % tarball)

    vg = vg or select_vg(size)
    if vg == None:
        print "Cancelled."
        return

    subprocess.check_call(["lvcreate","--yes","--addtag=@wbvm","-n",vmname,"-L","%dG" % size,vg], close_fds=True)
    device = "/dev/%s/%s" % (vg, vmname)
    print "Logical volume %s created." % device
    success = False
    try:
        subprocess.check_call(["mkfs.xfs","-m","crc=0","-f",device])
        with util.tempmount(device, "inode32", "xfs") as tmpdir:
            install(tmpdir, tarball, vmname, size, ram, vcpus, root_password,verbose,copy_pubkey)
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
    parser.add_argument("-r", "--ram", type=int, help="RAM size for new VM in megabytes")
    parser.add_argument("-u", "--vcpus", type=int, default=1, help="Number of virtual CPU cores")
    parser.add_argument("-p", "--root-password", type=str, help="Set root password after extraction")
    parser.add_argument("-v", "--verbose", action="store_true", help="Verbose mode")
    parser.add_argument("-k", "--copy-pubkey", action="store_true", help="Copy ssh public keys(id_rsa/dsa.pub, authorized_keys) to extracted VM's /root/.ssh/authorized_keys")
    parser.add_argument("url", type=str, help="Virtual Appliance (JSON|tarball) (URL|filename)")
    args = parser.parse_args()

    if is_tarball(args.url) and (args.ram is None or args.size is None):
        raise Exception("--size and --ram must be specified when installing tarball")

    run(args.url,args.vg, args.name,args.size,args.ram,args.vcpus,args.root_password,args.verbose,args.copy_pubkey)

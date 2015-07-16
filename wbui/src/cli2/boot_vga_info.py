import glob,os,json,subprocess,re

def get_boot_vga():
    return (map(lambda x:os.path.dirname(x), filter(lambda x:open(x).read().strip() == "1", glob.glob("/sys/bus/pci*/devices/*/boot_vga"))) or [None])[0]

def get_boot_vga_info():
    vga_info = get_boot_vga()
    if vga_info is None: return {}

    def read(filename):
        filename = "%s/%s" % (vga_info, filename)
        if not os.path.isfile(filename): return None
        return open(filename).read().strip()

    vendor_id, device_id = (read("vendor"), read("device"))
    info = {"device_dir":vga_info, "vendor_id":vendor_id, "device_id":device_id}

    try:
        lspci = subprocess.check_output(["lspci","-k","-d","%s:%s" % (vendor_id,device_id)])
        modules_match = re.search(r'^\s*Kernel modules: ([a-z0-9_\-]+)', lspci, re.M)
        module = modules_match and modules_match.groups()[0]
        if module is not None:
            info["module"] = module
            modinfo = subprocess.check_output(["modinfo",module,"-p"])
            info["modeset"] = re.search(r'^modeset:', modinfo, re.M) is not None
    except OSError:
        print "Failed to execute lspci or modinfo"
    except subprocess.CalledProcessError:
        print "lspci or modinfo failed(exit status != 0)"
    return info

if __name__ == '__main__':
    print json.dumps(get_boot_vga_info())

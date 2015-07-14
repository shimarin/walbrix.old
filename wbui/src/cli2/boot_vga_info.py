import glob,os,json

def get_boot_vga():
    return (map(lambda x:os.path.dirname(x), filter(lambda x:open(x).read().strip() == "1", glob.glob("/sys/bus/pci*/devices/*/boot_vga"))) or [None])[0]

def get_boot_vga_info():
    vga_info = get_boot_vga()
    if vga_info is None: return {}

    def read(filename):
        filename = "%s/%s" % (vga_info, filename)
        if not os.path.isfile(filename): return None
        return open(filename).read().strip()
    
    return {"device_dir":vga_info, "vendor_id":read("vendor"), "device_id":read("device")}

if __name__ == '__main__':
    print json.dumps(get_boot_vga_info())

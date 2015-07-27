import argparse,subprocess
import cli2.create as create

def make_sure_newname_is_usable(newname):
    lvs = set([ x.strip() for x in subprocess.check_output(["lvs","--noheadings","-o","lv_name"],close_fds=True).splitlines() ])
    if newname in lvs: raise Exception("New VM name '%s' is not usable" % newname)

def run(name, newname):
    device, name = create.get_device_and_vmname(name)
    make_sure_newname_is_usable(newname)
    create.make_sure_device_is_not_being_used(device)
    subprocess.check_call(["lvrename",device,newname],close_fds=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("name", type=str, help="VM name or device")
    parser.add_argument("newname", type=str, help="New VM name")
    args = parser.parse_args()
    run(args.name, args.newname)

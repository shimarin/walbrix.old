import argparse,os,subprocess
import cli2.create as create

def run(name, yes = False):
    device, name = create.get_device_and_vmname(name)
    create.make_sure_device_is_not_being_used(device)

    if not yes:
        if raw_input("Are you sure to remove VM %s on %s? ('yes' if you're sane): " % (name, device)) != "yes": return False

    subprocess.check_call(["lvremove", "-f", device],close_fds=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--yes", action="store_true", help="Proceed without confirmation")
    parser.add_argument("name", type=str, help="VM name or device")
    args = parser.parse_args()
    run(args.name, args.yes)

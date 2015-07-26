import argparse,subprocess
import cli2.create as create,cli2.list as cli_list

def get_autostart_domains():
    return [ x["name"] for x in filter(lambda x:x["autostart"], cli_list.get_all_domains().values())]

def is_autostart(name):
    return name in get_autostart_domains()

def set_autostart(name, autostart):
    device = create.get_device(name)
    action = {True:"add",False:"del"}[autostart]
    subprocess.check_call(["lvchange","--%stag=@autostart" % action,device], close_fds=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("name", type=str, nargs='?', help="VM name")
    parser.add_argument("onoff", type=str, nargs='?', help="'on' or 'off'")
    args = parser.parse_args()

    if args.name is None:
        for name in get_autostart_domains():
            print name
    elif args.onoff is None:
        print "on" if is_autostart(args.name) else "off"
    else:
        autostart = {"on":True,"off":False}.get(args.onoff)
        if autostart is None: raise Exceprion("You must specify 'on' or 'off'")
        set_autostart(args.name, autostart)

import argparse,subprocess,sys,os
import create

def run(name, cmdline):
    env = {}
    shell = os.environ.get("SHELL")
    term = os.environ.get("TERM")
    if shell: env["SHELL"] = shell
    if term: env["TERM"] = term

    with create.mount_vm(name) as tempdir:
        if len(cmdline) == 0 and shell is not None:
            if not os.path.isfile(os.path.join(tempdir, shell.strip('/'))):
                env["SHELL"] = "/bin/sh"
        return subprocess.call(["chroot",tempdir] + cmdline, env=env)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("name", type=str, help="VM name or device")
    parser.add_argument("cmdline", nargs=argparse.REMAINDER,help="command to execute")
    args = parser.parse_args()
    sys.exit(run(args.name, args.cmdline))

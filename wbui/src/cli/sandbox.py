import os
import subprocess
import time
import fcntl
import termios
import pty
import stat

import cli

def setupOptions(parser):
    parser.add_option("-r", "--root-group", dest="root_group", action="store_true", help="Give root group privilege", default=False)

def chroot_exec(rootdir, cmd, root_group = False):
    os.chroot(rootdir)
    groups = [5,27,17,18,19,65534]
    if root_group: groups.append(0) # for reading mouse, sucks
    os.setgroups(groups)
    os.setgid(65534)
    os.setreuid(65534, 0)
    #os.setsid()
    #fd = os.open('/dev/tty1', os.O_RDWR)
    #fcntl.ioctl(fd, termios.TIOCSCTTY, 0)
    #fcntl.ioctl(0, termios.TIOCSCTTY, 1)
    os.putenv("HOME", "/home/nobody")
    os.chdir("/home/nobody")
    os.execv("/bin/sh", ["/bin/sh", "-c"] + cmd)

def run(options, args):
    if len(args) < 1: raise cli.Error("Insufficient parameters")
    cmd = ["/init"] if len(args) < 2 else args[1:]
    rootdir = args[0]

    #pid = os.fork()
    #if pid == 0: 
    chroot_exec(rootdir, cmd, options.root_group)
    # else
    #return os.waitpid(pid, 0) [1]


#!/usr/bin/python2.7
import fcntl,os,array,struct,argparse,json

FBIOGET_VSCREENINFO = 0x4600
FBIOGET_FSCREENINFO = 0x4602

FB_VAR_SCREENINFO_SZ = 160
FB_FIX_SCREENINFO_SZ = 68

DEFAULT_FBDEV="/dev/fb0"

def apply(fbdev):
    try:
        fd = os.open(fbdev, os.O_RDONLY)
        try:
            var = array.array('B', [0] * FB_VAR_SCREENINFO_SZ)
            fix = array.array('c', [chr(0)] * FB_FIX_SCREENINFO_SZ)
            fcntl.ioctl(fd, 0x4600, var, 1)
            fcntl.ioctl(fd, 0x4602, fix, 1)
        finally:
            os.close(fd)
    except:
        return None

    var = struct.unpack("40I",var)
    xres, yres, bpp = (var[0], var[1], var[6])
    dev_id = fix[:16].tostring().split('\0', 1)[0]
    return (dev_id, xres, yres, bpp)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("fbdev", type=str, nargs='?', default=DEFAULT_FBDEV, help="Framebuffer device")
    args = parser.parse_args()
    rst = apply(args.fbdev)
    print json.dumps([] if rst is None else rst)



import argparse,struct

def get_kernel_version_string(filename):
    ver = ""
    with open(filename) as f:
        f.seek(526,0)
        f.seek(struct.unpack('<H', f.read(2))[0] + 0x200,0)
        c = f.read(1)
        while c and c != '\0' and c != ' ':
            ver += c
            c = f.read(1)
    return ver

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("kernel", type=str, help="kernel file")
    parser.add_argument("-n", "--number-only", action="store_true", help="number part only (no trailing -gentoo or something)")
    args = parser.parse_args()
    kernel_version = get_kernel_version_string(args.kernel)
    print kernel_version.split('-', 1)[0] if args.number_only else kernel_version


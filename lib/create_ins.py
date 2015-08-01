#!/usr/bin/python2.7
import argparse,os,tempfile,shutil,subprocess,re

cn_pattern = re.compile(r'^subject=.*/CN=(.+?)($|\/)')

def run(outfile, key=None, cert=None, authorized_keys=None):

    cn = None

    if cert is not None:
        if key is None: raise Exception("Key must be specified when cert is")
        key_mod = subprocess.check_output(["openssl","rsa","-noout","-modulus","-in",key]).strip()
        cert_mod = subprocess.check_output(["openssl","x509","-noout","-modulus","-in",cert]).strip()
        if key_mod != cert_mod: raise Exception("SSL key and cert mismatch")
        cn_match = cn_pattern.search(subprocess.check_output(["openssl","x509","-in",cert,"-subject","-noout"]))
        if cn_match is not None: cn = cn_match.groups()[0]

    outfile = outfile or ("%s.ins" % cn) if cn is not None else "-"
    
    tmpdir = tempfile.mkdtemp()
    try:
        if cert is not None:
            os.makedirs(os.path.join(tmpdir, "etc/openvpn"))
            shutil.copy(key, os.path.join(tmpdir, "etc/openvpn/client.key"))
            shutil.copy(cert, os.path.join(tmpdir, "etc/openvpn/client.crt"))
        if cn is not None:
            os.makedirs(os.path.join(tmpdir, "etc/conf.d"))
            with open(os.path.join(tmpdir, "etc/conf.d/hostname"),"w") as f:
                f.write('hostname="%s"\n' % cn)
        if authorized_keys is not None:
            os.makedirs(os.path.join(tmpdir, "root/.ssh"))
            os.chmod(os.path.join(tmpdir, "root"), 0700)
            os.chmod(os.path.join(tmpdir, "root/.ssh"), 0700)
            shutil.copy(authorized_keys, os.path.join(tmpdir, "root/.ssh/authorized_keys"))
        subprocess.check_call(["tar","zcvf",outfile,"--owner=root","--group=root","-C",tmpdir,"."])
    finally:
        shutil.rmtree(tmpdir)

    if outfile != "-": print "'%s' generated." % outfile

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--key", type=str, help="SSL key file")
    parser.add_argument("--cert", type=str, help="SSL cert file")
    parser.add_argument("--authorized-keys", type=str, nargs='?', const=os.path.expanduser("~/.ssh/authorized_keys"), help="SSH public key files")
    parser.add_argument("outfile", type=str, nargs='?', help="File to output")
    args = parser.parse_args()
    run(args.outfile, args.key, args.cert, args.authorized_keys)

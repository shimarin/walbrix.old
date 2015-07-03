import argparse,subprocess,json
import docker

def run(tarball):
    c = docker.Client()
    print "Importing image..."
    image_id = json.loads(c.import_image_from_file(tarball,repository="va"))["status"]
    try:
        print "Running container..."
        p = subprocess.Popen(["docker","run","--rm","--privileged","--name=va","-v","/tmp:/mnt","-p","5000:80","-p","5022:22",image_id,"sh","-c","cp -a /mnt/. / && exec /sbin/init"])
        try:
            p.wait()
        except KeyboardInterrupt:
            print "Terminating container..."
            p.terminate()
            p.wait()
    finally:
        c.remove_image(image_id)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("tarball", type=str, help="va tarball")
    args = parser.parse_args()
    run(args.tarball)

import argparse,subprocess,json,time,readline,shlex,sys,tempfile,shutil,os
import docker

def run(tarball):
    c = docker.Client()
    print "Importing image..."
    image_id = json.loads(c.import_image_from_file(tarball,repository="va"))["status"]
    try:
        print "Running container..."
        tmpdir = tempfile.mkdtemp()
        host_config = docker.utils.create_host_config(privileged=True, binds={tmpdir:"/mnt"},port_bindings={80:5000,22:5022})
        container = c.create_container(image=image_id, host_config=host_config, volumes=["/mnt"], ports=[80,22], command='/sbin/init')
        container_id = container[u"Id"]
        try:
            c.start(container_id)
            print "Container %s started. tmpdir=%s" % (container_id[:8], tmpdir)
            term = os.environ["TERM"] if "TERM" in os.environ else "dumb"
            subprocess.call(["docker","exec","-ti",container_id,"env","TERM=%s" % term,"/bin/bash"])
        finally:
            print "Stopping container..."
            c.stop(container_id)
            c.wait(container_id)
            print "Removing container..."
            c.remove_container(container_id)
            shutil.rmtree(tmpdir)
    finally:
        print "Removing image..."
        c.remove_image(image_id)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("tarball", type=str, help="va tarball")
    args = parser.parse_args()
    run(args.tarball)

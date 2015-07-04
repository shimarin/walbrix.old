import argparse,subprocess,json,time,readline,shlex,sys,tempfile,shutil,os
import docker

def exec_command(client, container_id, command):
    exec_id = client.exec_create(container_id, cmd=command, tty=True)["Id"]
    for n in client.exec_start(exec_id, stream=True):
        sys.stdout.write(n)

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
            while True:
                line = shlex.split(raw_input("> "), True)
                if not line or len(line) == 0: continue
                if line[0] in ["quit","exit"]: break
                #else
                exec_command(c, container_id, line)
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

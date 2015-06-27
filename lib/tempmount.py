import subprocess

class TemporaryMount:
    def __init__(self, partition, mount_point = None, mount_options = None):
        self.partition = partition
        self.mount_point = mount_point
        self.mount_options = mount_options
    
    def __enter__(self):
        self.real_mount_point = self.mount_point if self.mount_point != None else tempfile.mkdtemp()
        mount_cmd = ["/bin/mount"]
        if self.partition in ("/dev/shm", "tmpfs"): mount_cmd += ["-t","tmpfs"]
        if self.mount_options != None: mount_cmd += ["-o",self.mount_options]
        mount_cmd += [self.partition,self.real_mount_point]
        subprocess.check_call(mount_cmd)
        return self.real_mount_point

    def __exit__(self, exc_type, exc_value, traceback):
        result = subprocess.call(["/bin/umount", self.real_mount_point])
        if self.mount_point is None: os.rmdir(self.real_mount_point)
        if exc_type: return False
        return True

def do(partition, mountPoint=None, mountOptions=None):
    return TemporaryMount(partition, mountPoint, mountOptions)

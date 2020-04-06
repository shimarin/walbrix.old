#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <dirent.h>
#include <fcntl.h>
#include <sys/mount.h>
#include <sys/stat.h>
#include <blkid/blkid.h>
#include <libmount/libmount.h>
#include <linux/limits.h>
#include <sys/reboot.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/statvfs.h>
#include <sys/sysmacros.h>

#ifdef INIFILE
#include <iniparser.h>
#endif

struct partition_struct {
  char device[PATH_MAX];
  char type[PATH_MAX];
};

#define S_755 (S_IRUSR | S_IWUSR | S_IXUSR | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH)
#define S_700 (S_IRUSR | S_IWUSR | S_IXUSR)

#ifndef MS_MOVE
#define MS_MOVE 8192
#endif

#define CP "/bin/cp"
#define CAT "/bin/cat"
#define TAR "/bin/tar"
#define SWITCH_ROOT "/sbin/switch_root"
#define SWAPON "/sbin/swapon"
#define MKSWAP "/sbin/mkswap"
#define UMOUNT "/bin/umount"
#define MKFS_XFS "/sbin/mkfs.xfs"
#define XFS_REPAIR "/sbin/xfs_repair"
#define PASSWD "/usr/bin/passwd"
#define CHPASSWD "/usr/sbin/chpasswd"
#define BTRFS "/sbin/btrfs"
#define MKFS_BTRFS "/sbin/mkfs.btrfs"

#define F1(x, y, z) (z ^ (x & (y ^ z)))
#define F2(x, y, z) F1(z, x, y)
#define F3(x, y, z) (x ^ y ^ z)
#define F4(x, y, z) (y ^ (x | ~z))

#define MD5STEP(f, w, x, y, z, data, s) \
	( w += f(x, y, z) + data, w &= 0xffffffff, w = w<<s | w>>(32-s), w += x )

uint32_t getu32 (const unsigned char *addr)
{
	return (((((uint32_t)addr[3] << 8) | addr[2]) << 8)
		| addr[1]) << 8 | addr[0];
}

void putu32 (uint32_t data, uint8_t *addr)
{
	addr[0] = (uint8_t)data;
	addr[1] = (uint8_t)(data >> 8);
	addr[2] = (uint8_t)(data >> 16);
	addr[3] = (uint8_t)(data >> 24);
}

void MD5Transform(uint32_t buf[4], const uint8_t inraw[64])
{
	register uint32_t a, b, c, d;
	uint32_t in[16];
	int i;

	for (i = 0; i < 16; ++i)
		in[i] = getu32 (inraw + 4 * i);

	a = buf[0];
	b = buf[1];
	c = buf[2];
	d = buf[3];

	MD5STEP(F1, a, b, c, d, in[ 0]+0xd76aa478,  7);
	MD5STEP(F1, d, a, b, c, in[ 1]+0xe8c7b756, 12);
	MD5STEP(F1, c, d, a, b, in[ 2]+0x242070db, 17);
	MD5STEP(F1, b, c, d, a, in[ 3]+0xc1bdceee, 22);
	MD5STEP(F1, a, b, c, d, in[ 4]+0xf57c0faf,  7);
	MD5STEP(F1, d, a, b, c, in[ 5]+0x4787c62a, 12);
	MD5STEP(F1, c, d, a, b, in[ 6]+0xa8304613, 17);
	MD5STEP(F1, b, c, d, a, in[ 7]+0xfd469501, 22);
	MD5STEP(F1, a, b, c, d, in[ 8]+0x698098d8,  7);
	MD5STEP(F1, d, a, b, c, in[ 9]+0x8b44f7af, 12);
	MD5STEP(F1, c, d, a, b, in[10]+0xffff5bb1, 17);
	MD5STEP(F1, b, c, d, a, in[11]+0x895cd7be, 22);
	MD5STEP(F1, a, b, c, d, in[12]+0x6b901122,  7);
	MD5STEP(F1, d, a, b, c, in[13]+0xfd987193, 12);
	MD5STEP(F1, c, d, a, b, in[14]+0xa679438e, 17);
	MD5STEP(F1, b, c, d, a, in[15]+0x49b40821, 22);

	MD5STEP(F2, a, b, c, d, in[ 1]+0xf61e2562,  5);
	MD5STEP(F2, d, a, b, c, in[ 6]+0xc040b340,  9);
	MD5STEP(F2, c, d, a, b, in[11]+0x265e5a51, 14);
	MD5STEP(F2, b, c, d, a, in[ 0]+0xe9b6c7aa, 20);
	MD5STEP(F2, a, b, c, d, in[ 5]+0xd62f105d,  5);
	MD5STEP(F2, d, a, b, c, in[10]+0x02441453,  9);
	MD5STEP(F2, c, d, a, b, in[15]+0xd8a1e681, 14);
	MD5STEP(F2, b, c, d, a, in[ 4]+0xe7d3fbc8, 20);
	MD5STEP(F2, a, b, c, d, in[ 9]+0x21e1cde6,  5);
	MD5STEP(F2, d, a, b, c, in[14]+0xc33707d6,  9);
	MD5STEP(F2, c, d, a, b, in[ 3]+0xf4d50d87, 14);
	MD5STEP(F2, b, c, d, a, in[ 8]+0x455a14ed, 20);
	MD5STEP(F2, a, b, c, d, in[13]+0xa9e3e905,  5);
	MD5STEP(F2, d, a, b, c, in[ 2]+0xfcefa3f8,  9);
	MD5STEP(F2, c, d, a, b, in[ 7]+0x676f02d9, 14);
	MD5STEP(F2, b, c, d, a, in[12]+0x8d2a4c8a, 20);

	MD5STEP(F3, a, b, c, d, in[ 5]+0xfffa3942,  4);
	MD5STEP(F3, d, a, b, c, in[ 8]+0x8771f681, 11);
	MD5STEP(F3, c, d, a, b, in[11]+0x6d9d6122, 16);
	MD5STEP(F3, b, c, d, a, in[14]+0xfde5380c, 23);
	MD5STEP(F3, a, b, c, d, in[ 1]+0xa4beea44,  4);
	MD5STEP(F3, d, a, b, c, in[ 4]+0x4bdecfa9, 11);
	MD5STEP(F3, c, d, a, b, in[ 7]+0xf6bb4b60, 16);
	MD5STEP(F3, b, c, d, a, in[10]+0xbebfbc70, 23);
	MD5STEP(F3, a, b, c, d, in[13]+0x289b7ec6,  4);
	MD5STEP(F3, d, a, b, c, in[ 0]+0xeaa127fa, 11);
	MD5STEP(F3, c, d, a, b, in[ 3]+0xd4ef3085, 16);
	MD5STEP(F3, b, c, d, a, in[ 6]+0x04881d05, 23);
	MD5STEP(F3, a, b, c, d, in[ 9]+0xd9d4d039,  4);
	MD5STEP(F3, d, a, b, c, in[12]+0xe6db99e5, 11);
	MD5STEP(F3, c, d, a, b, in[15]+0x1fa27cf8, 16);
	MD5STEP(F3, b, c, d, a, in[ 2]+0xc4ac5665, 23);

	MD5STEP(F4, a, b, c, d, in[ 0]+0xf4292244,  6);
	MD5STEP(F4, d, a, b, c, in[ 7]+0x432aff97, 10);
	MD5STEP(F4, c, d, a, b, in[14]+0xab9423a7, 15);
	MD5STEP(F4, b, c, d, a, in[ 5]+0xfc93a039, 21);
	MD5STEP(F4, a, b, c, d, in[12]+0x655b59c3,  6);
	MD5STEP(F4, d, a, b, c, in[ 3]+0x8f0ccc92, 10);
	MD5STEP(F4, c, d, a, b, in[10]+0xffeff47d, 15);
	MD5STEP(F4, b, c, d, a, in[ 1]+0x85845dd1, 21);
	MD5STEP(F4, a, b, c, d, in[ 8]+0x6fa87e4f,  6);
	MD5STEP(F4, d, a, b, c, in[15]+0xfe2ce6e0, 10);
	MD5STEP(F4, c, d, a, b, in[ 6]+0xa3014314, 15);
	MD5STEP(F4, b, c, d, a, in[13]+0x4e0811a1, 21);
	MD5STEP(F4, a, b, c, d, in[ 4]+0xf7537e82,  6);
	MD5STEP(F4, d, a, b, c, in[11]+0xbd3af235, 10);
	MD5STEP(F4, c, d, a, b, in[ 2]+0x2ad7d2bb, 15);
	MD5STEP(F4, b, c, d, a, in[ 9]+0xeb86d391, 21);

	buf[0] += a;
	buf[1] += b;
	buf[2] += c;
	buf[3] += d;
}


int md5(const char *filename, char hash_in_hex[33], int first_block_only)
{
  uint32_t ctx_buf[4] = {0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476},
    ctx_bits[2] = {0, 0};
  uint8_t ctx_in[64];
  uint8_t digest[16];
  size_t count;
  uint8_t *p;

  FILE *f = fopen(filename, "r");
  if (!f) return -1;

  // else
  while ( 1 ) {
    uint8_t read_buf[4096];
    uint32_t t;
    size_t read_len = fread(read_buf, 1, sizeof(read_buf), f);
    size_t len = read_len;
    const uint8_t* buf = read_buf;

    if (read_len == 0) break;
    //else

  	t = ctx_bits[0];
  	if ((ctx_bits[0] = (t + ((uint32_t)len << 3)) & 0xffffffff) < t)
  		ctx_bits[1]++;
  	ctx_bits[1] += len >> 29;

  	t = (t >> 3) & 0x3f;
  	if ( t ) {
  		uint8_t *p = ctx_in + t;

  		t = 64-t;
  		if (len < t) {
  			memcpy(p, buf, len);
  			goto next;
  		}
  		memcpy(p, buf, t);
  		MD5Transform(ctx_buf, ctx_in);
  		buf += t;
  		len -= t;
  	}
  	while (len >= 64) {
  		memcpy(ctx_in, buf, 64);
  		MD5Transform(ctx_buf, ctx_in);
  		buf += 64;
  		len -= 64;
  	}
  	memcpy(ctx_in, buf, len);
  next:;
    if (read_len < sizeof(read_buf) || first_block_only) break;
  }

  fclose(f);

	count = (ctx_bits[0] >> 3) & 0x3F;
	p = ctx_in + count;
	*p++ = 0x80;
	count = 64 - 1 - count;
	if (count < 8) {
		memset(p, 0, count);
		MD5Transform(ctx_buf, ctx_in);
		memset(ctx_in, 0, 56);
	} else {
		memset(p, 0, count-8);
	}

	putu32(ctx_bits[0], ctx_in + 56);
	putu32(ctx_bits[1], ctx_in + 60);

	MD5Transform(ctx_buf, ctx_in);
	putu32(ctx_buf[0], digest);
	putu32(ctx_buf[1], digest + 4);
	putu32(ctx_buf[2], digest + 8);
	putu32(ctx_buf[3], digest + 12);

  hash_in_hex[0] = '\0';
  for (count = 0; count < 16; count++) {
    char hex[3];
    sprintf(hex, "%02x", digest[count]);
    strcat(hash_in_hex, hex);
  }

  return 0;
}

int fork_exec_wait(const char *cmd, ...)
{
  va_list list;
  int i = 0, pid, rst;
  char *argv[32];

  argv[i++] = (char*)cmd; // first arg to be cmd. removing const qualifier is unavoidable...

  va_start(list, cmd);
  while ((argv[i] = va_arg(list, char *)) != NULL && i < 31) {
    i++;
  }
  argv[i] = NULL;
  va_end(list);

  pid = fork();
  switch (pid) {
    case 0:
      if (execv(cmd, argv) < 0) _exit(-1);
      break; // never reach here
    case -1:
      return -1;
    default:
      waitpid(pid, &rst, 0);
      break;
  }
  return WIFEXITED(rst)? WEXITSTATUS(rst) : -1;
}

int fork_chroot_exec_wait(const char *rootdir, const char *cmd, ...)
{
  va_list list;
  int i = 0, pid, rst;
  char *argv[32];

  argv[i++] = (char*)cmd; // first arg to be cmd. removing const qualifier is unavoidable...

  va_start(list, cmd);
  while ((argv[i] = va_arg(list, char *)) != NULL && i < 31) {
    i++;
  }
  argv[i] = NULL;
  va_end(list);

  pid = fork();
  switch (pid) {
    case 0:
      if (chroot(rootdir) < 0) _exit(-1);
      if (execv(cmd, argv) < 0) _exit(-1);
      break; // never reach here
    case -1:
      return -1;
    default:
      waitpid(pid, &rst, 0);
      break;
  }
  return WIFEXITED(rst)? WEXITSTATUS(rst) : -1;
}

int fork_exec_write_wait(const char *data, const char *cmd, ...)
{
  va_list list;
  int i = 0, pid, rst;
  char *argv[32];
  int fd[2];

  argv[i++] = (char*)cmd; // first arg to be cmd. removing const qualifier is unavoidable...

  va_start(list, cmd);
  while ((argv[i] = va_arg(list, char *)) != NULL && i < 31) {
    i++;
  }
  argv[i] = NULL;
  va_end(list);

  pipe(fd);
  pid = fork();
  switch (pid) {
    case 0:
      close(fd[1]);
      if (dup2(fd[0], STDIN_FILENO) < 0) _exit(-1);
      close(fd[0]);
      if (execv(cmd, argv) < 0) _exit(-1);
      break; // never reach here
    case -1:
      return -1;
    default:
      close(fd[0]);
      write(fd[1], data, strlen(data));
      close(fd[1]);
      waitpid(pid, &rst, 0);
      break;
  }
  return WIFEXITED(rst)? WEXITSTATUS(rst) : -1;
}

int fork_chroot_exec_write_wait(const char *rootdir, const char *data, const char *cmd, ...)
{
  va_list list;
  int i = 0, pid, rst;
  char *argv[32];
  int fd[2];

  argv[i++] = (char*)cmd; // first arg to be cmd. removing const qualifier is unavoidable...

  va_start(list, cmd);
  while ((argv[i] = va_arg(list, char *)) != NULL && i < 31) {
    i++;
  }
  argv[i] = NULL;
  va_end(list);

  pipe(fd);
  pid = fork();
  switch (pid) {
    case 0:
      close(fd[1]);
      if (dup2(fd[0], STDIN_FILENO) < 0) _exit(-1);
      close(fd[0]);
      if (chroot(rootdir) < 0) _exit(-1);
      if (execv(cmd, argv) < 0) _exit(-1);
      break; // never reach here
    case -1:
      return -1;
    default:
      close(fd[0]);
      write(fd[1], data, strlen(data));
      close(fd[1]);
      waitpid(pid, &rst, 0);
      break;
  }
  return WIFEXITED(rst)? WEXITSTATUS(rst) : -1;
}

void halt()
{
  reboot(RB_HALT_SYSTEM);
}

void mkdir_p(const char *dir)
{
  const char *psrc = dir;
  char *buf = (char *)malloc(strlen(dir) + 1);
  char *pdst = buf;
  *buf = '\0';
  while (*psrc) {
    if (*psrc == '/' && strlen(buf) > 0) {
      mkdir(buf, S_755);
    }
    *pdst++ = *psrc++;
    *pdst = '\0';
  }
  mkdir(buf, S_755);
  free(buf);
}

int mount_procdevsys()
{
  mkdir("/proc", S_755);
  if (mount("proc", "/proc", "proc", MS_NOEXEC|MS_NOSUID|MS_NODEV, "") < 0) return -1;
  mkdir("/dev", S_755);
  if (mount("udev", "/dev", "devtmpfs", MS_NOSUID, "mode=0755,siz=10M") < 0) return -1;
  mkdir("/sys", S_755);
  return mount("sysfs", "/sys", "sysfs", MS_NOEXEC|MS_NOSUID|MS_NODEV, "");
}

void mount_procdevsys_or_die()
{
  if (mount_procdevsys() < 0) {
    perror("mount_procdevsys");
    halt();
  }
}

int get_partition_info_by_dev(blkid_dev dev, struct partition_struct *partition)
{
  blkid_tag_iterate tag_iter;
  const char *_type, *_value;
  strcpy(partition->device, blkid_dev_devname(dev));
  partition->type[0] = '\0';
  tag_iter = blkid_tag_iterate_begin(dev);
  while (blkid_tag_next(tag_iter, &_type, &_value) == 0) {
    if (strcmp(_type,"TYPE") == 0) {
      strcpy(partition->type, _value);
      break;
    }
  }
  blkid_tag_iterate_end(tag_iter);
  return 0;
}

int get_partition_info_by_devname(const char* devname, struct partition_struct *partition)
{
  blkid_dev dev;
  blkid_cache cache;
  int rst;
  blkid_get_cache(&cache, "/dev/null");
  blkid_probe_all(cache);
  dev = blkid_get_dev(cache, devname, 0);
  if (!dev) {
    errno = ENOENT;
    rst = -1;
    goto exit;
  }
  //else
  rst = get_partition_info_by_dev(dev, partition);

exit:;
  blkid_put_cache(cache);
  return rst;
}

int search_partition(const char *type, const char *value, struct partition_struct *partition)
{
  blkid_dev dev = NULL;
  blkid_dev_iterate iter;
  blkid_cache cache;
  int rst;
  blkid_get_cache(&cache, "/dev/null");
  blkid_probe_all(cache);
  iter = blkid_dev_iterate_begin(cache);
  blkid_dev_set_search(iter, type, value);
  while (blkid_dev_next(iter, &dev) == 0) {
    dev = blkid_verify(cache, dev);
    if (dev) break;
  }
  blkid_dev_iterate_end(iter);

  if (!dev) {
    errno = ENOENT;
    rst = -1;
    goto exit;
  }

  rst = get_partition_info_by_dev(dev, partition);

exit:;
  blkid_put_cache(cache);
  return rst;
}

int search_partition_by_uuid(const char *uuid, struct partition_struct *partition)
{
  return search_partition("UUID", uuid, partition);
}

int search_partition_by_fstype(const char *fstype, struct partition_struct *partition)
{
  return search_partition("TYPE", fstype, partition);
}

int search_boot_partition(struct partition_struct *partition, int max_retry)
{
  int retry_count;
  const char *boot_partition_uuid;
  boot_partition_uuid = getenv("boot_partition_uuid");
  if (!boot_partition_uuid) {
    errno = ENOENT;
    return -1;
  }
  // else

  for (retry_count = 0 ; retry_count < max_retry + 1; retry_count++) {
    if (search_partition_by_uuid(boot_partition_uuid, partition) == 0) break;
    // else
    sleep(retry_count);
  }

  if (retry_count == max_retry + 1) {
    errno = ENOENT;
    return -1;
  }
  // else
  return 0;
}

void search_partition_by_fstype_or_die(const char *fstype, struct partition_struct *partition, int max_retry)
{
  int retry_count;
  for (retry_count = 0 ; retry_count < max_retry + 1; retry_count++) {
    if (search_partition_by_fstype(fstype, partition) == 0) break;
    // else
    sleep(retry_count);
  }

  if (retry_count == max_retry + 1) {
    perror("search_partition_by_fstype");
    halt();
  }
}

void mount_or_die(const char *source, const char *target,
                 const char *filesystemtype, unsigned long mountflags,
                 const void *data)
{
  mkdir_p(target);
  if (mount(source, target, filesystemtype, mountflags, data) < 0) {
    char *buf = (char *)malloc(strlen(target) + 7);
    if (buf) {
      strcpy(buf, "mount ");
      strcat(buf, target);
      perror(buf);
      free(buf);
    }
    halt();
  }
  // else
  printf("%s mounted.\n", target);
}

// mnt_context_mount() == 0 doesn't mean success
int mnt_context_mount_and_check_result(struct libmnt_context *ctx)
{
  int rst = mnt_context_mount(ctx);
  if (rst != 0) {
    if (rst > 1) perror("mnt_context_mount");
    return rst;
  }
  //else
  return mnt_context_get_status(ctx) == 1? 0 : -1;
}

int mount2(const char *source, const char *target,
                 const char *filesystemtype, unsigned long mountflags,
                 const void *data)
{
  struct libmnt_context *ctx;
  int rst = -1;
  ctx = mnt_new_context();
  if (!ctx) {
    errno = ENOMEM;
    return -1;
  }
  // else
  mnt_context_set_fstype_pattern(ctx, filesystemtype);
  mnt_context_set_source(ctx, source);
  mnt_context_set_target(ctx, target);
  mnt_context_set_mflags(ctx, mountflags);
  mnt_context_set_options(ctx, data);
  rst = mnt_context_mount_and_check_result(ctx);
  mnt_free_context(ctx);

  return rst;
}

void mount_or_die2(const char *source, const char *target,
                 const char *filesystemtype, unsigned long mountflags,
                 const void *data)
{
  int rst;
  mkdir_p(target);

  rst = mount2(source, target, filesystemtype, mountflags, data);
  if (rst != 0) {
    printf("%s could not be mounted on %s (%d).\n", source, target, rst);
    halt();
  }
}

int mount_overlay(const char *lowerdir, const char *upperdir, const char *workdir, const char *mountpoint)
{
  char buf[PATH_MAX * 5];
  sprintf(buf, "lowerdir=%s,upperdir=%s,workdir=%s", lowerdir, upperdir, workdir);
  return mount("overlay", mountpoint, "overlay", MS_RELATIME, buf);
}

void mount_overlay_or_die(const char *lowerdir, const char *upperdir, const char *workdir, const char *mountpoint)
{
  mkdir_p(upperdir);
  mkdir_p(workdir);
  mkdir_p(mountpoint);
  if (mount_overlay(lowerdir, upperdir, workdir, mountpoint) < 0) {
    perror("mount_overlay");
    halt();
  }
  // else
  printf("Overlayfs(lowerdir=%s,upperdir=%s,workdir=%s) mounted on %s.\n", lowerdir, upperdir, workdir, mountpoint);
}

int create_whiteout(const char* name)
{
  return mknod(name, S_IFCHR, makedev(0, 0));
}

int move_mount(const char *old, const char *new)
{
  return mount(old, new, NULL, MS_MOVE, NULL);
}

void move_mount_or_die(const char *old, const char *new)
{
  mkdir_p(new);
  if (move_mount(old, new) < 0) {
    perror("move_mount");
    halt();
  }
  // else
  printf("Mountpoint moved from %s to %s.\n", old, new);
}

int mount_loop(const char *imgfile, const char *mountpoint, int mflags, int offset)
{
  struct libmnt_context *ctx;
  int rst = -1;
  char options[32];
  ctx = mnt_new_context();
  if (!ctx) {
    errno = ENOMEM;
    return -1;
  }
  // else
  mnt_context_set_fstype_pattern(ctx, "auto");
  mnt_context_set_source(ctx, imgfile);
  mnt_context_set_target(ctx, mountpoint);
  mnt_context_set_mflags(ctx, mflags);
  sprintf(options, "loop,offset=%d", offset);
  mnt_context_set_options(ctx, options);
  rst = mnt_context_mount_and_check_result(ctx);
  mnt_free_context(ctx);
  return rst;
}

int mount_ro_loop(const char *imgfile, const char *mountpoint, int offset)
{
  mkdir_p(mountpoint);
  return mount_loop(imgfile, mountpoint, MS_RDONLY, offset);
}

void mount_ro_loop_or_die(const char *imgfile, const char *mountpoint, int offset)
{
  if (mount_ro_loop(imgfile, mountpoint, offset) != 0) {
    perror("mount_ro_loop");
    halt();
  }
  // else
  printf("Filesystem image %s mounted on %s.\n", imgfile, mountpoint);
}

int mount_rw_loop(const char *imgfile, const char *mountpoint)
{
  mkdir_p(mountpoint);
  return mount_loop(imgfile, mountpoint, MS_RELATIME, 0);
}

int mount_rw_loop_btrfs(const char *imgfile, const char *mountpoint, int compress)
{
  struct libmnt_context *ctx;
  int rst = -1;
  char options[64];

  mkdir_p(mountpoint);
  ctx = mnt_new_context();
  if (!ctx) {
    errno = ENOMEM;
    return -1;
  }
  // else
  mnt_context_set_fstype_pattern(ctx, "btrfs");
  mnt_context_set_source(ctx, imgfile);
  mnt_context_set_target(ctx, mountpoint);
  mnt_context_set_mflags(ctx, MS_RELATIME);
  sprintf(options, "loop%s", (compress? ",compress=zstd":"") );
  mnt_context_set_options(ctx, options);
  rst = mnt_context_mount_and_check_result(ctx);
  mnt_free_context(ctx);

  if (rst == 0) {
    // extend file system size up to loopbak filesize
    fork_exec_wait(BTRFS, "filesystem", "resize", "max", mountpoint, NULL);
  }
  return rst;
}

int switch_root(const char *newroot)
{
  return execl(SWITCH_ROOT, SWITCH_ROOT, newroot, "/sbin/init", NULL);
}

void switch_root_or_die(const char *newroot)
{
  if (switch_root(newroot) < 0) {
    perror("switch_root");
    halt();
  }
}

int exists(const char *path)
{
  struct stat st;
  return (stat(path, &st) == 0);
}

int is_file(const char *path)
{
  struct stat st;
  if (stat(path, &st) < 0) return 0;
  return S_ISREG(st.st_mode);
}

int is_dir(const char *path)
{
  struct stat st;
  if (stat(path, &st) < 0) return 0;
  return S_ISDIR(st.st_mode);
}

int is_block(const char* path)
{
  struct stat st;
  if (stat(path, &st) < 0) return 0;
  return S_ISBLK(st.st_mode);
}

int is_mounted(const char *path)
{
  struct libmnt_table *tb = mnt_new_table_from_file("/proc/self/mountinfo");
	struct libmnt_cache *cache = mnt_new_cache();
	struct libmnt_fs *fs;
  int rst = 0;
  mnt_table_set_cache(tb, cache);
	mnt_unref_cache(cache);
  fs = mnt_table_find_target(tb, path, MNT_ITER_BACKWARD);
  rst = (fs && mnt_fs_get_target(fs));
  mnt_unref_table(tb);
  return rst;
}

int get_source_device_from_mountpoint(const char *path, char device[PATH_MAX])
{
  struct libmnt_table *tb = mnt_new_table_from_file("/proc/self/mountinfo");
	struct libmnt_cache *cache = mnt_new_cache();
	struct libmnt_fs *fs;
  int rst = -1;
  mnt_table_set_cache(tb, cache);
	mnt_unref_cache(cache);
  fs = mnt_table_find_target(tb, path, MNT_ITER_BACKWARD);
  if (fs) {
    const char *srcpath = mnt_fs_get_srcpath(fs);
    if (srcpath) {
      strcpy(device, srcpath);
      rst = 0;
    }
  }
  mnt_unref_table(tb);
  return rst;
}

int is_nonexist_or_empty(const char *path)
{
  struct stat st;
  if (stat(path, &st) != 0) return 1;
  return (st.st_size == 0);
}

int cp_a(const char *src, const char *dst)
{
  return fork_exec_wait(CP, "-a", src, dst, NULL);
}

void setup_initramfs_shutdown(const char *newroot)
{
  char buf[PATH_MAX];
  sprintf(buf, "%s/run/initramfs/bin", newroot);
  mkdir_p(buf);
  cp_a("/bin/.", buf);

  if (is_dir("/lib")) {
    sprintf(buf, "%s/run/initramfs/lib", newroot);
    mkdir_p(buf);
    cp_a("/lib/.", buf);
  }

  if (is_dir("/usr/lib")) {
    sprintf(buf, "%s/run/initramfs/usr/lib", newroot);
    mkdir_p(buf);
    cp_a("/usr/lib/.", buf);
  }

  if (is_dir("/lib64")) {
    sprintf(buf, "%s/run/initramfs/lib64", newroot);
    mkdir_p(buf);
    cp_a("/lib64/.", buf);
  }

  if (is_dir("/usr/lib64")) {
    sprintf(buf, "%s/run/initramfs/usr/lib64", newroot);
    mkdir_p(buf);
    cp_a("/usr/lib64/.", buf);
  }

  if (is_dir("/usr/sbin")) {
    sprintf(buf, "%s/run/initramfs/usr/sbin", newroot);
    mkdir_p(buf);
    cp_a("/usr/sbin/.", buf);
  }

  sprintf(buf, "%s/run/initramfs/shutdown", newroot);
  cp_a("/init", buf);
}

#ifdef INIFILE
typedef dictionary *inifile_t;

int process_inifile(const char *inifile, void (callback)(inifile_t))
{
  dictionary *ini = NULL;
  if (is_file(inifile)) {
    ini = iniparser_load(inifile);
  }
  if (!ini) {
    ini = dictionary_new(0);
  }

  callback(ini);

  iniparser_freedict(ini);
  return 0;
}

const char *ini_string(inifile_t d, const char *key, char *def)
{
  return iniparser_getstring((dictionary *)d, key, def);
}

int ini_int(inifile_t d, const char *key, int notfound)
{
  return iniparser_getint((dictionary *)d, key, notfound);
}

int ini_bool(inifile_t d, const char *key, int notfound)
{
  return iniparser_getboolean((dictionary *)d,key, notfound);
}

int ini_exists(inifile_t d, char *entry)
{
  return iniparser_find_entry((dictionary *)d, entry);
}
#endif

int extract_archive(const char *rootdir, const char *archive, const char *path, int strip_components)
{
  char buf[PATH_MAX];
  sprintf(buf, "%s%s", rootdir, path);
  mkdir_p(buf);
  sprintf(buf, "--strip-components=%d", strip_components);
  return fork_chroot_exec_wait(rootdir, TAR, "xf", archive, buf, "-C", path, NULL);
}

int cat(const char *file)
{
  return fork_exec_wait(CAT, file, NULL);
}

int umount_recursive(const char *path)
{
  return fork_exec_wait(UMOUNT, "-R", "-n", path, NULL);
}

uint64_t get_free_disk_space(const char *mountpoint)
{
  struct statvfs s;
  int rst;
  rst = statvfs(mountpoint, &s);
  if (rst < 0) return rst;
  //else
  return (uint64_t)s.f_bsize * s.f_bfree;
}

int create_zero_filled_file(const char *path, off_t length)
{
  int fd, rst;
  fd = creat(path, S_IRUSR | S_IWUSR);
  if (fd < 0) return fd;
  //else
  rst = ftruncate(fd, length);
  close(fd);
  return rst;
}

int create_xfs_imagefile(const char *imagefile, off_t length)
{
  int rst = create_zero_filled_file(imagefile, length);
  if (rst != 0) return rst;
  //else
  return fork_exec_wait(MKFS_XFS, "-f", "-q", imagefile, NULL);
}

int repair_xfs_imagefile(const char *imagefile)
{
  return fork_exec_wait(XFS_REPAIR, "-L", "-f", imagefile, NULL);
}

int create_btrfs_imagefile(const char *imagefile, off_t length)
{
  int rst = create_zero_filled_file(imagefile, length);
  if (rst != 0) return rst;
  // else
  return fork_exec_wait(MKFS_BTRFS, "-f", "-q", imagefile, NULL);
}

int repair_btrfs_imagefile(const char *imagefile)
{
  return fork_exec_wait(BTRFS, "check", "--repair", "--force", imagefile, NULL);
}

int btrfs_scan()
{
  return fork_exec_wait(BTRFS, "device", "scan", NULL);
}

int repair_fat(const char *device)
{
  return fork_exec_wait("/usr/sbin/fsck.fat", "-a", "-w", device, NULL);
}

int create_swapfile(const char* swapfile, off_t length)
{
  int rst = create_zero_filled_file(swapfile, length);
  if (rst < 0) return rst;
  //else
  return fork_exec_wait(MKSWAP, swapfile, NULL);
}

int activate_swap(const char *swapfile)
{
  if (fork_exec_wait(SWAPON, swapfile, NULL) != 0) {
    printf("Broken swapfile? performing mkswap...\n");
    if (fork_exec_wait(MKSWAP, swapfile, NULL) == 0) {
      fork_exec_wait(SWAPON, swapfile, NULL);
    }
  }
}

int generate_default_hostname(char* hostname)
{
  FILE *f;
  uint16_t randomnumber;
  f = fopen("/dev/urandom", "r");
  if (!f) return -1;
  //else
  fread(&randomnumber, sizeof(randomnumber), 1, f);
  fclose(f);
  sprintf(hostname, "host-%04x", randomnumber);
  return 0;
}

int set_hostname(const char *rootdir, const char *hostname)
{
  FILE *f;
  char buf[PATH_MAX];
  sprintf(buf, "%s/etc/hostname", rootdir);
  f = fopen(buf, "w");
  if (!f) return -1;
  //else
  fprintf(f, "%s", hostname);
  return fclose(f);
}

int set_root_password(const char *rootdir, const char *password/* NULL to remove password*/)
{
  char buf[128 + 5];

  if (!password || password[0] == '\0') {
    return fork_chroot_exec_wait(rootdir, PASSWD, "-d", "root", NULL);
  }
  // else
  if (strlen(password) > 127) return -1;
  strcpy(buf, "root:");
  strcat(buf, password);
  return fork_chroot_exec_write_wait(rootdir, buf, CHPASSWD, NULL);
}

int set_timezone(const char *rootdir, const char *timezone)
{
  FILE *f;
  char buf1[PATH_MAX], buf2[PATH_MAX];
  sprintf(buf1, "../usr/share/zoneinfo/%s", timezone);
  sprintf(buf2, "%s/etc/localtime", rootdir);
  unlink(buf2);
  return symlink(buf1, buf2);
}

int set_keymap(const char *rootdir, const char *keymap)
{
  FILE *f;
  char buf[PATH_MAX];
  sprintf(buf, "%s/etc/vconsole.conf", rootdir);
  f = fopen(buf, "w");
  if (!f) return -1;
  //else
  fprintf(f, "KEYMAP=%s\n", keymap);
  return fclose(f);
}

int enable_autologin(const char *rootdir)
{
  FILE *f;
  char buf[PATH_MAX];
  sprintf(buf, "%s/etc/systemd/system/getty@tty1.service.d", rootdir);
  mkdir_p(buf);
  sprintf(buf, "%s/etc/systemd/system/getty@tty1.service.d/autologin.conf", rootdir);
  f = fopen(buf, "w");
  if (!f) return -1;
  //else
  fputs("[Service]\nExecStart=\nExecStart=-/sbin/agetty -o '-p -- \\\\u' --autologin root --noclear %I $TERM", f);
  return fclose(f);
}

int set_static_ip_address(const char *interface, const char *ip_address, const char *gateway, const char *dns, const char *fallback_dns,
  const char *ipv6_address, const char *ipv6_gateway, const char *ipv6_dns, const char *ipv6_fallback_dns)
{
  FILE *f;
  char network_config_file[PATH_MAX];
  mkdir_p("/newroot/run/initramfs/rw/root/etc/systemd/network");
  sprintf(network_config_file, "/newroot/run/initramfs/rw/root/etc/systemd/network/50-%s.network", interface);
  f = fopen(network_config_file, "w");
  if (!f) return -1;
  // else
  fprintf(f, "[Match]\nName=%s\n[Network]\n", interface);

  if (ip_address) {
    fprintf(f, "Address=%s\n", ip_address);
    if (gateway) {
      fprintf(f, "Gateway=%s\n", gateway);
    }
    if (dns) {
      fprintf(f, "DNS=%s\n", dns);
      if (fallback_dns) {
        fprintf(f, "FallbackDNS=%s\n", fallback_dns);
      }
    } else if (gateway) {
      fprintf(f, "DNS=8.8.8.8\nFallbackDNS=8.8.4.4\n");
    }
  } else {
    fprintf(f, "DHCP=yes\n");
  }

  if (ipv6_address) {
    fprintf(f, "Address=%s\n", ipv6_address);
    if (ipv6_gateway) {
      fprintf(f, "Gateway=%s\n", ipv6_gateway);
    }
    if (ipv6_dns) {
      fprintf(f, "DNS=%s\n", ipv6_dns);
      if (ipv6_fallback_dns) {
        fprintf(f, "FallbackDNS=%s\n", ipv6_fallback_dns);
      }
    } else if (ipv6_gateway){
      fprintf(f, "DNS=2001:4860:4860::8888\nFallbackDNS=2001:4860:4860::8844\n");
    }
  }

  fprintf(f, "MulticastDNS=yes\nLLMNR=yes", f);
  return fclose(f);
}

int setup_wifi(const char *rootdir, const char *ssid, const char *key)
{
  FILE *f;
  char buf[PATH_MAX];
  sprintf(buf, "%s/etc/wpa_supplicant/wpa_supplicant-wlan0.conf", rootdir);
  f = fopen(buf, "w");
  if (!f) return -1;
  // else
  fprintf(f, "network={\n");
  fprintf(f, "\tssid=\"%s\"\n", ssid);
  fprintf(f, "\tpsk=\"%s\"\n", key);
  fprintf(f, "}\n");
  if (fclose(f) != 0) return -1;
  //else
  sprintf(buf, "%s/etc/systemd/network/51-wlan0-dhcp.network", rootdir);
  f = fopen(buf, "w");
  if (!f) return -1;
  //else
  fprintf(f, "[Match]\nName=wlan0\n[Network]\nDHCP=yes\nMulticastDNS=yes\nLLMNR=yes\n");
  if (fclose(f) != 0) return -1;
  // else
  sprintf(buf, "%s/etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service", rootdir);
  unlink(buf);
  return symlink("/lib/systemd/system/wpa_supplicant@.service", buf);
}

void setup_hostname_according_to_inifile(const char *rootdir, inifile_t ini)
{
  const char *hostname = ini_string(ini, ":hostname", NULL);
  if (hostname) {
    if (set_hostname(rootdir, hostname) == 0) {
      printf("hostname: %s\n", hostname);
    } else {
      printf("Hostname setup failed.\n");
    }
  }
}

void set_generated_hostname_if_not_set(const char *rootdir)
{
  char buf[PATH_MAX];
  sprintf(buf, "%s/run/initramfs/rw/root/etc/hostname", rootdir);
  if (!is_file(buf)) {
    char default_hostname[10];
    if (generate_default_hostname(default_hostname) < 0) {
      strcpy(default_hostname, "localhost");
    }
    if (set_hostname(rootdir, default_hostname) == 0) {
      printf("hostname: %s (generated)\n", default_hostname);
    } else {
      printf("Hostname setup failed.\n");
    }
  }
}

void setup_timezone_according_to_inifile(const char *rootdir, inifile_t ini)
{
  const char *timezone = ini_string(ini, ":timezone", NULL);
  if (timezone) {
    if (set_timezone(rootdir, timezone) == 0) {
      printf("Timezone set to %s.\n", timezone);
    } else {
      printf("Timezone could not be configured.\n");
    }
  }
}

void setup_keymap_according_to_inifile(const char *rootdir, inifile_t ini)
{
  const char *keymap = ini_string(ini, ":keymap", NULL);
  if (keymap) {
    if (set_keymap(rootdir, keymap) == 0) {
      printf("Keymap set to %s.\n", keymap);
    } else {
      printf("Keymap configuration failed.\n");
    }
  }
}

void setup_wifi_according_to_inifile(const char *rootdir, inifile_t ini)
{
  const char *wifi_ssid = ini_string(ini, ":wifi_ssid", NULL);
  const char *wifi_key = ini_string(ini, ":wifi_key", "");

  if (wifi_ssid) {
    if (setup_wifi(rootdir, wifi_ssid, wifi_key) == 0) {
      printf("WiFi SSID: %s\n", wifi_ssid);
    } else {
      printf("WiFi setup failed.\n");
    }
  }
}

void setup_password_according_to_inifile(const char *rootdir, inifile_t ini)
{
  const char *password = ini_string(ini, ":password", NULL);

  if (password) {
    if (set_root_password(rootdir, password) == 0) {
      printf("Root password configured.\n");
    } else {
      printf("Failed to set root password.\n");
    }
  }
}

int enable_lvm()
{
  return fork_exec_wait("/sbin/vgchange", "-ay", "--sysinit", NULL);
}

void init();
void shutdown();

int main(int argc, char *argv[])
{
  if (strcmp(argv[0], "/init") == 0) {
    init();
    return 0; // should not reach here
  }
  //else
  if (strcmp(argv[0], "/shutdown") != 0) {
    printf("Not a valid program name.\n");
    halt();
  }
  //else
  shutdown();

  if (strcmp(argv[1], "poweroff") == 0) {
    reboot(RB_POWER_OFF);
  } else if (strcmp(argv[1], "reboot") == 0) {
    reboot(RB_AUTOBOOT);
  } else {
    halt();
  }
  return 0;
}

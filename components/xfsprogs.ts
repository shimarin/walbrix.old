import {f,pkg} from "./collect.ts"

pkg("util-linux")
f(
  "/sbin/fsck.xfs",
  "/sbin/mkfs.xfs",
  "/sbin/xfs_repair",
  "/usr/sbin/xfs_admin",
  "/usr/sbin/xfs_copy",
  "/usr/sbin/xfs_db",
  "/usr/sbin/xfs_growfs",
  "/usr/sbin/xfs_info"
)

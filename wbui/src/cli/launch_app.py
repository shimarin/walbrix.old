# -*- coding:utf-8 -*-

import os
import stat
import shutil
from optparse import OptionParser

import system
import cli

def run_app(tmpdir, metadata, prefer_x11 = False):
	if os.path.isdir("%s/proc" % (tmpdir)):
		system.exec_shell("mount -o bind /proc %s/proc" % (tmpdir))

	if os.path.isdir("%s/dev" % (tmpdir)):
		if system.exec_shell("mount -o bind /dev %s/dev" % (tmpdir)) == 0:
			# chromiumが /dev/shmへのアクセスを要求するため
			os.chmod("%s/dev/shm" % (tmpdir), stat.S_IRWXO | stat.S_IRWXU | stat.S_IRWXG)
	if os.path.isdir("%s/sys" % (tmpdir)):
		system.exec_shell("mount -o bind /sys %s/sys" % (tmpdir))

	# /etc/localtimeがなければコピーする
	if not os.path.exists("%s/etc/localtime" % (tmpdir)):
		shutil.copyfile("/etc/localtime", "%s/etc/localtime" % (tmpdir))

	try:
		use_x11 = False
		if metadata != None:
			x11 = metadata.getroot().get("x11")
			if x11 == "required" or x11 == "recommended" or (prefer_x11 and x11 == "compatible"):
				use_x11 = True
		else:
			use_x11 = prefer_x11
		if use_x11:
			return system.exec_shell("xinit %s/sandbox %s -- -quiet" % (cli.wbui_path(), tmpdir))
		else:
			return system.exec_shell("%s/sandbox %s" % (cli.wbui_path(), tmpdir))
	finally:
		if os.path.ismount("%s/proc" % (tmpdir)):
			system.exec_shell("umount %s/proc" % (tmpdir))
		if os.path.ismount("%s/dev" % (tmpdir)):
			system.exec_shell("umount %s/dev" % (tmpdir))
		if os.path.ismount("%s/sys" % (tmpdir)):
			system.exec_shell("umount %s/sys" % (tmpdir))

def run():
	parser = OptionParser(usage="usage: %prog [appname]", version="%prog 1.0")
	parser.add_option("-x", "--prefer-x11", dest="prefer_x11", action="store_true", help="Use X11 unless not compatible", default=False)
	(options, args) = parser.parse_args()

	device = None
	if len(args) > 0:
		appname = args[0]
		apps = system.get_apps()
		for app in apps:
			if app["name"] == appname:
				device = app["device"]
				break;
		if device == None:
			raise cli.Error("Application %s doesn't exist" % (appname))
	elif os.path.exists(system.runapp_link):
		mode = os.stat(system.runapp_link)[stat.ST_MODE]
		if not stat.S_ISBLK(mode):
			raise cli.Error("Symlink %s is not pointing a block device" % (system.runapp_link))
		device = os.path.realpath(system.runapp_link)
	
	if device == None:
		raise cli.Error("Appname must be specified unless %s symlink does exist." % (system.runapp_link))

	with system.Mount(device) as tmpdir:
		metadata = system.get_metadata_from_cache(device)
		if metadata == None: metadata = system.get_app_metadata(device, tmpdir)
		run_app(tmpdir, metadata, options.prefer_x11)

# -*- coding: utf-8 -*-
import os,sys,re,subprocess,traceback

import pygame

import system
import gui
import gui.progressbar
import subprocess_progressbar
import dialogbox
import installer
import resource_loader
window = None

# string resources
gui.res.register("string_installer_upgrade_upgrade",resource_loader.l({"en":u"Upgrading...", "ja":u"アップグレード中..."}))
gui.res.register("string_installer_upgrade_check",resource_loader.l({"en":u"Checking existing system for upgrade...", "ja":u"アップグレード対象を確認中..."}))

gui.res.register("string_installer_upgrade_failed",resource_loader.l({"en":u"Failed to upgrade(%s)", "ja":u"アップグレードに失敗しました(%s)"}))
gui.res.register("string_installer_upgrade_completed",resource_loader.l({"en":u"Upgrade has been completed. Please remove the installation disk from the drive. Do you want to restart your computer?", "ja":u"アップグレードが完了しました。インストールディスクをドライブから取り出してください。コンピュータを再起動しますか？"}))

string_copying_boot_files = resource_loader.l({"en":u"Copying boot files...", "ja":u"ブートファイルをコピー中..."})

def delete(targetDir, delfiles):
    for delfile in delfiles:
        try:
            os.unlink("%s/%s" % (targetDir, delfile))
        except OSError, e:
            pass

def show_progress(progress_bar, subprocess):
    s = system.getSystem()
    nbr = s.getNonblockingReader(subprocess.stdout)
    line = nbr.readline()
    while line != "":
        if line != None and re.match(r'^\d+/\d+$', line):
            (n, m) = map(lambda a: float(a), line.split('/'))
            progress_bar.setProgress(n / m if m > 0 else 0)
        gui.yieldFrame()
        line = nbr.readline()

def run(source_device, esp, device, arch):
    s = system.getSystem()
    try:
        mount_option = "loop" if os.path.isfile(source_device) else None
        with s.temporaryMount(source_device, mount_option, "ro") as sourceDir:
            with s.temporaryMount(device) as targetDir:
                delfiles = []
                with s.temporaryFile() as tmpFileName: # excludeFile
                    with open(tmpFileName, "w") as tmpFile:
                        with dialogbox.messagebox.open(gui.res.string_installer_upgrade_check) as pb:
                            tarball = "%s/wb-%s.tar.xz" % (sourceDir, arch)
                            with s.openWbForInput("compare_files", [tarball, targetDir]) as compare_files:
                                nbr = s.getNonblockingReader(compare_files.stdout)
                                line = nbr.readline()
                                while line != "":
                                    if line != None:
                                        #print line
                                        if line.startswith("X "): tmpFile.write(".%s" % line[2:])
                                        elif line.startswith("D "): delfiles.append(line[2:].rstrip())
                                    else:
                                        gui.yieldFrame()
                                    line = nbr.readline()

                    with dialogbox.progressbar.open(gui.res.string_installer_upgrade_upgrade) as progress_bar:
                        with s.openWbForInput("extract_archive", ("-x", tmpFileName, tarball, targetDir)) as extract_archive:
                            show_progress(progress_bar, extract_archive)

                # delete removed files
                delete(targetDir, delfiles)
                # install wbui
                installer.copyWBUI(sourceDir, targetDir)

            with dialogbox.progressbar.open(string_copying_boot_files) as progress_bar: 
                with s.temporaryMount(esp) as boot_dir:
                    with s.openWbForInput("copy_boot_files", ("%s/EFI/Walbrix" % sourceDir, "%s/EFI/Walbrix" % boot_dir)) as copy_boot_files:
                        show_progress(progress_bar, copy_boot_files)
                    s.installGrubEFI(boot_dir)
                    disk = s.getDiskFromPartition(esp) # get the disk which ESP belongs to
                    if s.isBiosCompatibleDisk(disk):
                        s.installGrub(disk, boot_dir)

    except Exception, e:
        traceback.print_exc(file=sys.stderr)
        dialogbox.messagebox.execute(gui.res.string_installer_upgrade_failed % (e), None, gui.res.caution_sign)
        return False
    
    if not os.path.isfile(source_device): s.eject(source_device)
    if dialogbox.messagebox.execute(gui.res.string_installer_upgrade_completed, dialogbox.DialogBox.OKCANCEL()) == "ok":
        os.unlink("/var/run/utmp")
        s.reboot()

    return True

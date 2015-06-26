# -*- coding: utf-8 -*-

import os,sys,re,json,subprocess,select,signal,fcntl,traceback,shutil
from array import array

import pygame

import system
import gui
import dialogbox.messagebox
import dialogbox.progressbar

import installer
import resource_loader
window = None


# string resources

gui.res.register("string_installation_not_done",resource_loader.l({"en":u"installation cannot be done because device could not be found", "ja":u"インストール先として使用できそうなデバイスが見つかりませんでした"}))
gui.res.register("string_install_destination",resource_loader.l({"en":u"Select the install destination", "ja":u"インストール先の選択"}))

gui.res.register("string_install_space",resource_loader.l({"en":u"During installation of space ...", "ja":u"インストール先の領域を確保中..."}))

gui.res.register("string_Canceled_by_user",resource_loader.l({"en":u"Canceled by the user", "ja":u"ユーザーによるキャンセル"}))
gui.res.register("string_installing_",resource_loader.l({"en":u"Installing ...", "ja":u"インストール中..."}))

gui.res.register("string_installation_description_",resource_loader.l({"en":u"Install the system on a %s disk (model: %s, device name: %s). Do you want?（All contents of the disk will be erased!!）", "ja":u"%sBのディスク(モデル:%s, デバイス名:%s)にシステムをインストールします。よろしいですか？（このディスクの内容は全て消去されます！！）"}))

gui.res.register("string_inst_installation_failed",resource_loader.l({"en":u"Installation failed (%s)", "ja":u"インストールに失敗しました(%s)"}))

gui.res.register("string_inst_reboot_desc",resource_loader.l({"en":u"Please remove the installation disk from the drive. To start the system installed you may have to change the boot device in the BIOS settings. Restart the computer?", "ja":u"インストールディスクをドライブから取り出してください。インストールされたシステムを起動するには BIOS設定で起動デバイスを変更しなければならない場合があります。コンピュータを再起動しますか？"}))

gui.res.register("string_installer_launch_desc",resource_loader.l({"en":u"Walbrix 2.6.33(2010) to launch the installer. This version of the old computer to around 2003 only to use. Do you want to allow this?", "ja":u"Walbrix 2.6.33(2010年製)のインストーラを起動します。このバージョンは2003年前後までの古いコンピュータでのみご使用下さい。よろしいですか？"}))

string_setup_entire_disk_fail = resource_loader.l({"en":u"Disk setup failed.", "ja":u"ディスクのセットアップに失敗しました"})
string_copying_boot_files = resource_loader.l({"en":u"Copying boot files...", "ja":u"ブートファイルをコピー中..."})

def select_disk(source_device_to_exclude):
    s = system.getSystem()
    disks = filter(lambda x:"/dev/" + x["logicalname"] != source_device_to_exclude and not s.partitionBelongsTo(source_device_to_exclude, "/dev/" + x["logicalname"]), s.listAvailableDisks())
    if len(disks) == 0:
        dialogbox.messagebox.execute(gui.res.string_installation_not_done, None, gui.res.caution_sign)
        return None
    
    options = []
    disks_by_name = {}
    for disk in disks:
        logicalname = disk["logicalname"]
        product = disk["product"]
        size = disk["size"]
        options.append({"id":logicalname,"label":u"%s:%s(%sB)" % (logicalname, product, size)})
        disks_by_name[logicalname] = [product, size]

    logicalname = gui.selectbox.execute(gui.res.string_install_destination,options)

    if logicalname is None: return None

    product = disks_by_name[logicalname][0]
    size = disks_by_name[logicalname][1]

    return (logicalname, product, size)

def setup_etc(target_dir):
    # region/language support
    etc_wb_dir = "%s/etc/wb" % target_dir
    if not os.path.isdir(etc_wb_dir) and not os.path.exists(etc_wb_dir):
        os.mkdir(etc_wb_dir)
    if os.path.isfile("/etc/wb/region"):
        shutil.copyfile("/etc/wb/region", "%s/region" % etc_wb_dir)
    if os.path.isfile("/etc/wb/language"):
        shutil.copyfile("/etc/wb/language", "%s/language" % etc_wb_dir)
    if os.path.islink("/etc/localtime"):
        if os.path.lexists("%s/etc/localtime" % target_dir):
            os.unlink("%s/etc/localtime" % target_dir)
        os.symlink(os.readlink("/etc/localtime"), "%s/etc/localtime" % target_dir)
    # use jp106 keymap as default if region == jp
    if system.region() == "jp":
        os.system("sed -i 's/^keymap=\"us\"$/keymap=\"jp106\"/' %s/etc/conf.d/keymaps" % target_dir)

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

def execInstall(source_device, device, arch, createVg):
    s = system.getSystem()
    rootPartition = "%s1" % (device)

    with dialogbox.messagebox.open(gui.res.string_install_space) as progressBar:
        cmdline = ["/usr/sbin/wb","setup_entire_disk"]
        if createVg: 
            cmdline.append("-s")
            cmdline.append(str(2))
        cmdline.append(device)
        setup_entire_disk = subprocess.Popen(cmdline, shell=False, stdout=subprocess.PIPE,stderr=subprocess.PIPE,close_fds=True)
        tick = gui.util.Tick(1000 / gui.getFrameRate())
        some_string = setup_entire_disk.stdout.readline().strip()
        while some_string:
            if tick.exceeded() or select.select([setup_entire_disk.stdout],[],[],0) == ([],[],[]):
                tick.reset()
                if gui.yieldFrame():
                    setup_entire_disk.send_signal(signal.SIGINT)
                    break
            some_string = setup_entire_disk.stdout.readline().strip()
        setup_entire_disk.stdout.close()
        exit_status = setup_entire_disk.wait()
        if exit_status == 130: raise Exception(gui.res.string_Canceled_by_user)
        elif exit_status != 0: 
            err = setup_entire_disk.stderr.read()
            raise Exception(err)

    with dialogbox.progressbar.open(gui.res.string_installing_) as progressBar2:
        with s.temporaryMount(rootPartition) as targetDir:
            mount_option = "loop" if os.path.isfile(source_device) else None
            with s.temporaryMount(source_device, mount_option, "ro") as sourceDir:
                tarball = "%s/wb-%s.tar.xz" % (sourceDir, arch)
                with s.openWbForInput("extract_archive", (tarball, targetDir)) as extract_archive:
                    show_progress(progressBar2, extract_archive)
                # install wbui
                installer.copyWBUI(sourceDir, targetDir)
                # install rescue image
                installer.copyRescueImage(sourceDir, {"x86_64":64,"i686":32}[arch], targetDir)

            installer.createGrubMenu(rootPartition, targetDir,{"x86_64":"512M","i686":"256M"}[arch])
            s.installGrub(device, targetDir)
            s.getFilesystemFromDevice(rootPartition).label(rootPartition, "whitebase")
            setup_etc(targetDir)

def exec_install_efi(source_device, device, arch):
    s = system.getSystem()

    result = ""

    with dialogbox.messagebox.open(gui.res.string_install_space) as progressBar:
        with s.openWbForInput("setup_entire_disk_efi", [device]) as setup_entire_disk:
            nbr = s.getNonblockingReader(setup_entire_disk.stdout)
            line = nbr.readline()
            while line != "":
                if line != None: # some output from subprocess there
                    if line.startswith("//"): # line is comment
                        pass
                    else:
                        result += line
                if gui.yieldFrame():
                    setup_entire_disk.send_signal(signal.SIGINT)
                    break
                line = nbr.readline()

            exit_status = setup_entire_disk.wait()
            if exit_status == 130:
                raise Exception(gui.res.string_Canceled_by_user)
            elif exit_status != 0: 
                err = setup_entire_disk.stderr.read()
                raise Exception(err)

    result = json.loads(result)
    if "boot_partition" not in result or "root_partition" not in result or "bios_compatible" not in result:
        raise Exception(string_setup_entire_disk_fail)

    boot_partition = result["boot_partition"]
    root_partition = result["root_partition"]
    bios_compatible = result["bios_compatible"]

    mount_option = "loop" if os.path.isfile(source_device) else None
    with s.temporaryMount(source_device, mount_option, "ro") as sourceDir:
        with dialogbox.progressbar.open(gui.res.string_installing_) as progressBar:
            # extract system
            with s.temporaryMount(root_partition) as targetDir:
                tarball = "%s/wb-%s.tar.xz" % (sourceDir, arch)
                with s.openWbForInput("extract_archive", (tarball, targetDir)) as extract_archive:
                    show_progress(progressBar, extract_archive)
                # install wbui
                installer.copyWBUI(sourceDir, targetDir)
                setup_etc(targetDir)

        with dialogbox.progressbar.open(string_copying_boot_files) as progress_bar:
            # setup boot partition for EFI/BIOS
            with s.temporaryMount(boot_partition) as boot_dir:
                with s.openWbForInput("copy_boot_files", ("%s/EFI/Walbrix" % sourceDir, "%s/EFI/Walbrix" % boot_dir)) as copy_boot_files:
                    show_progress(progress_bar, copy_boot_files)
                # install rescue image
                installer.createGrubMenu(root_partition, boot_dir, {"x86_64":64,"i686":32}[arch], {"x86_64":"512M","i686":"256M"}[arch])
                # grub efi install
                s.installGrubEFI(boot_dir)
                if bios_compatible: # disk size <= 2T and msdos partition table
                    s.installGrub(device, boot_dir)

        s.getFilesystemFromDevice(root_partition).label(root_partition, "whitebase")

def run(source_device, arch):
    yn = None
    while yn != "ok":
        device = select_disk(source_device)
        if device == None: return False
    
        block_name = device[0]
        logical_name = "/dev/block/%s" % open("/sys/block/%s/dev" % block_name).read().strip()
        product = device[1]
        size = device[2]
        yn = dialogbox.messagebox.execute(gui.res.string_installation_description_ % (size, product, block_name), dialogbox.DialogBox.OKCANCEL(), gui.res.caution_sign)

    s = system.getSystem()
    try:
        if not(installer.efi or s.isBiosCompatibleDisk(logical_name)):
            pass # TODO: warn
        exec_install_efi(source_device, logical_name, arch)
    except Exception, e:
        traceback.print_exc(file=sys.stderr)
        dialogbox.messagebox.execute(gui.res.string_inst_installation_failed % (e), None, gui.res.caution_sign)
        return False

    if not os.path.isfile(source_device): s.eject(source_device)
    if dialogbox.messagebox.execute(gui.res.string_inst_reboot_desc, dialogbox.DialogBox.OKCANCEL()) == "ok":
        os.unlink("/var/run/utmp")
        s.reboot()

    return True

def run2633(source_device):
    if gui.messagebox.execute(gui.res.string_installer_launch_desc, ["ok", "cancel"]) != "ok": return False

    s= system.getSystem()
    vbe_mode = None
    bit_depth = installer.fb_bit_depth
    if bit_depth == None:
        vbe_mode = installer.determineSVGAVideoMode([0x310,0x311,0x312,0x331,0x33f])
        if vbe_mode == None: vbe_mode = "0x312"
    pygame.quit()

    print "Loading Walbrix 2.6.33 Installer..."
    try :
        with s.temporaryMount(source_device, None, "ro") as sourceDir:
            kernel = "%s/boot/vmlinuz.26" % sourceDir
            kernel_args = ("vga=%s" % vbe_mode) if vbe_mode != None else None
            initrd = "%s/boot/initrd.26" % sourceDir
            cmdline = installer.kexec_cmdline(kernel, kernel_args, initrd)
            rst = subprocess.Popen(cmdline, shell=False, close_fds=True).wait()

        if rst != 0: raise Exception("Failed to load kernel")
        os.execv("/usr/sbin/kexec", ("/usr/sbin/kexec", "-e"))
    except:
        traceback.print_exc(file=sys.stderr)
        exit(1) # since pygame is alredy gone, there is no way recover

    return True # though nobody comes here

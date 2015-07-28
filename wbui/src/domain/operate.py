# -*- coding:utf-8 -*-
import os,sys,subprocess,traceback,re,stat,threading,traceback,multiprocessing

import pygame

import footer
import wbui
import system
import domain
import vm
import gui
import gui.selectbox
import gui.progressbar
import gui.messagebox
import gui.propertybox
import gui.inputbox
import dialogbox

import create
import resource_loader

import cli2.create as cli_create,cli2.autostart as cli_autostart,cli2.edit as cli_edit,cli2.rename as cli_rename,cli2.install_va as cli_install_va,cli2.remove_vm as cli_remove_vm

# string resources
gui.res.register("string_config_info",resource_loader.l({"en":u"Configuration information of the virtual machine %s could not be found.Do you want to create it?", "ja":u"仮想マシン %s の設定情報が見つかりません。作成しますか？"}))
gui.res.register("string_allocated_memory",resource_loader.l({"en":u"Allocated memory(MB)", "ja":u"割当メモリ(MB)"}))
gui.res.register("string_new_set",resource_loader.l({"en":u"%s's new settings", "ja":u"%s の新しい設定"}))
gui.res.register("string_memory_assign_desc",resource_loader.l({"en":u"Please assign the memory of 32MB or more", "ja":u"32MB以上のメモリを割り当てて下さい"}))
gui.res.register("string_confi_info",resource_loader.l({"en":u"Created the %s virtual machine configuration information ", "ja":u"仮想マシン %s の設定情報を作成しました"}))
string_starting = resource_loader.l({"en":u"Starting virtual machine ...", "ja":u"仮想マシンを開始しています..."})
string_not_start = resource_loader.l({"en":u"Could not start the virtual machine", "ja":u"仮想マシンを開始できませんでした"})
gui.res.register("string_vm_connect_desc",resource_loader.l({"en":u"Do you want to connect to the console of the virtual machine %s?", "ja":u"仮想マシン %s のコンソールに接続しますか？"}))
gui.res.register("string_exit_desc",resource_loader.l({"en":u"Do you want to issue shutdown command to the virtual machine %s?", "ja":u"仮想マシン %s に終了命令を発行しますか？"}))
gui.res.register("string_domain_issued",resource_loader.l({"en":u"Shutdown command has been issued to the virtual machine", "ja":u"仮想マシンに終了命令を発行しました"}))
gui.res.register("string_unable",resource_loader.l({"en":u"Unable to issue shutdown command to the virtual machine", "ja":u"仮想マシンに終了命令を発行できませんでした"}))
gui.res.register("string_restart_ins",resource_loader.l({"en":u"Do you want to issue reboot command to the virtual machine %s?", "ja":u"仮想マシン %s に再起動命令を発行しますか？"}))
gui.res.register("string_unable_restart_ins",resource_loader.l({"en":u"Unable to issue reboot command to the virtual machine", "ja":u"仮想マシンに再起動命令を発行できませんでした"}))
gui.res.register("string_kill_vm",resource_loader.l({"en":u"Do you want to kill the virtual machine %s?", "ja":u"仮想マシン %s を強制終了しますか？"}))
gui.res.register("string_terminated",resource_loader.l({"en":u"Virtual machine was killed.", "ja":u"仮想マシンを強制終了しました"}))
gui.res.register("string_not_killed",resource_loader.l({"en":u"Could not kill the virtual machine", "ja":u"仮想マシンを強制終了できませんでした"}))

gui.res.register("string_delete_desc",resource_loader.l({"en":u"Are you sure to delete the virtual machine %s? (You can not revert)", "ja":u"仮想マシン %s を本当に削除しますか？(戻すことはできません)"}))



gui.res.register("string_vm_del",resource_loader.l({"en":u"Virtual machine was deleted ", "ja":u"仮想マシンを削除しました"}))
gui.res.register("string_vm_not_del",resource_loader.l({"en":u"Could not delete a virtual machine", "ja":u"仮想マシンを削除できませんでした"}))
gui.res.register("string_vm_name",resource_loader.l({"en":u"The virtual machine name", "ja":u"仮想マシン名"}))
gui.res.register("string_allocated",resource_loader.l({"en":u"Allocated memory(MB)", "ja":u"割当メモリ(MB)"}))
gui.res.register("string_vm_name_exists",resource_loader.l({"en":u"Virtual machine %s is already exists. Please choose another name.", "ja":u"仮想マシン %s は既に存在しています。他の名前を指定してください。"}))
gui.res.register("string_allocation_desc",resource_loader.l({"en":u"Please allocate at least 32MB of memory.", "ja":u"少なくとも32MBのメモリを割り当てて下さい。"}))
string_vm_change = resource_loader.l({"en":u"Change the virtual machine", "ja":u"仮想マシンの変更"})
string_vm_changed = resource_loader.l({"en":u"Virtual machine has been changed", "ja":u"仮想マシンが変更されました"})
string_vm_change_failed = resource_loader.l({"en":u"Error changing virtual machine: %s", "ja":u"仮想マシンの変更でエラーが発生しました: %s"})
gui.res.register("string_new_size",resource_loader.l({"en":u"The new size(GB)", "ja":u"新しいサイズ(GB)"}))
gui.res.register("string_size_desc",resource_loader.l({"en":u"Must be greater than current size", "ja":u"現在のサイズより大きくしなければなりません"}))
gui.res.register("string_free_space_desc",resource_loader.l({"en":u"Unable to extend the size of disk allocation.Please make sure have enough free space.", "ja":u"ディスクの割り当てサイズを拡張できませんでした。領域の空きが十分か確認してください。"}))

gui.res.register("string_assign_desc",resource_loader.l({"en":u"Expanding filesystem's capacity(xfs_growfs) failed even though expanding disk capacity has been done.", "ja":u"ディスクの割り当てサイズを拡張しましたが、ファイルシステムの拡張(xfs_growfs)に失敗しました。"}))

gui.res.register("string_enhanced",resource_loader.l({"en":u"disk allocation size has been extended.", "ja":u"ディスクの割り当てサイズを拡張しました。"}))
gui.res.register("string_cloning",resource_loader.l({"en":u"Cloning a virtual machine ...", "ja":u"仮想マシンを複製中..."}))
gui.res.register("string_operation_desc",resource_loader.l({"en":u"Source is running. Are you ok with the snapshot replication?", "ja":u"複製元が稼働中です。スナップショットの複製となりますがよろしいですか？"}))
gui.res.register("string_duplicate",resource_loader.l({"en":u"Destination virtual machine:", "ja":u"複製先仮想マシン"}))
gui.res.register("string_duplicate_fail",resource_loader.l({"en":u"Failed to replicate the virtual machine. You may not have enough space in the volume of destination", "ja":u"仮想マシンの複製に失敗しました。複製先の領域に十分な空きが無い可能性があります"}))
gui.res.register("string_duplication_description",resource_loader.l({"en":u"Replicate the virtual machine %s as volume=%s/name=%s as(HD %dGB)...", "ja":u"仮想マシン%sを領域%s上の%sとして複製(HD%dGB)..."}))

gui.res.register("string_replicate_fails",resource_loader.l({"en":u"failed to replicate the virtual machine. (%s).", "ja":u"仮想マシンの複製に失敗しました。(%s)"}))

gui.res.register("string_duplicate_complete",resource_loader.l({"en":u"Duplicating virtual machine has been completed", "ja":u"仮想マシンの複製が完了しました"}))

gui.res.register("string_connection_desc",resource_loader.l({"en":u"This virtual machine is either not valid or does not support the VPN connection, PASSWORD_SAVE of OpenVPN is not enabled.", "ja":u"この仮想マシンは有効でないか、VPN接続をサポートしていないか、OpenVPNの PASSWORD_SAVEが有効になっていません。"}))

gui.res.register("string_destination_host",resource_loader.l({"en":u"Host to connect", "ja":u"接続先ホスト"}))
gui.res.register("string_con_id",resource_loader.l({"en":u"Connection ID", "ja":u"接続ID"}))

gui.res.register("string_con_password",resource_loader.l({"en":u"Connection password", "ja":u"接続パスワード"}))
gui.res.register("string_vpn_setting",resource_loader.l({"en":u"VPN connection settings", "ja":u"VPN接続設定"}))

gui.res.register("string_setting_desc",resource_loader.l({"en":u"Host: %s, connection ID: %s, connection password: (hidden) VPN connection settings. If you have an existing connection settings will be overwritten, but do you want?", "ja":u"接続先ホスト:%s, 接続ID:%s, 接続パスワード:(非表示) でVPN接続を設定します。既存の接続設定がある場合は上書きされますが、よろしいですか？"}))

gui.res.register("string_setting_fail",resource_loader.l({"en":u"To apply the VPN settings failed.(%s).", "ja":u"VPN設定の適用に失敗しました。(%s)"}))
gui.res.register("string_manually_start",resource_loader.l({"en":u"(please set openvpn autostart manually)", "ja":u"(openvpnの自動起動設定は手動で行って下さい)"}))

gui.res.register("string_vpn_vm_setting",resource_loader.l({"en":u"In the virtual machine %s, VPN config has been saved.%s", "ja":u"仮想マシン %s にVPNを設定しました。%s"}))

gui.res.register("string_domain_operate_start",resource_loader.l({"en":u"Start", "ja":u"起動する"}))
gui.res.register("string_console",resource_loader.l({"en":u"Connect to the console", "ja":u"コンソールに接続する"}))

gui.res.register("string_ins_ends",resource_loader.l({"en":u"Issue shutdown command", "ja":u"終了命令を発行する"}))

gui.res.register("string_restart",resource_loader.l({"en":u"Issue restart command", "ja":u"再起動命令を発行する"}))
gui.res.register("string_stop",resource_loader.l({"en":u"Force to stop", "ja":u"強制停止する"}))

gui.res.register("string_can_automatic",resource_loader.l({"en":u"Cancel the automatic start", "ja":u"自動起動を解除する"}))

gui.res.register("string_auto_start",resource_loader.l({"en":u"Start automatically", "ja":u"自動起動にする"}))

gui.res.register("string_name_ram",resource_loader.l({"en":u"Name/RAM capacity changes", "ja":u"名前/RAM容量を変更する"}))

gui.res.register("string_extend_space",resource_loader.l({"en":u"Extend the disk space", "ja":u"ディスク容量を拡張する"}))

gui.res.register("string_vpn_config",resource_loader.l({"en":u"Configure a VPN connection", "ja":u"VPN接続を設定する"}))

gui.res.register("string_remove",resource_loader.l({"en":u"Delete", "ja":u"削除する"}))

gui.res.register("string_replicate",resource_loader.l({"en":u"Replicate", "ja":u"複製する"}))

gui.res.register("string_learn",resource_loader.l({"en":u"Confirm how to use", "ja":u"利用方法を確認する"}))

string_vm_autostart = resource_loader.l({"en":u"Virtual machine %s has been set to Automatic startup", "ja":u"仮想マシン%sを自動起動に設定しました"})

string_vm_no_autostart = resource_loader.l({"en":u"Virtual Machine %s has been set to Manual startup", "ja":u"仮想マシン%sの自動起動を解除しました"})

string_cant_across_2tb = resource_loader.l({"en":u"Disk size can't be expanded across 2TB border.","ja":u"2TBの境界をまたがってディスク容量を拡張することはできません"})

def determine_device_name(domain_name):
    lvs = subprocess.Popen("lvs --noheadings --separator='|'", shell=True, stdout=subprocess.PIPE,close_fds=True)
    line = lvs.stdout.readline() 
    vgname = None
    while line:
        splitted = line.split('|')
        if splitted[0].strip() == domain_name:
            vgname = splitted[1].strip()
            break
        line = lvs.stdout.readline()
    lvs.wait()
    return "/dev/%s/%s"  % (vgname, domain_name) if vgname != None else None

def get_va_metadata_from_cache(name):
    if not name.startswith("/dev/"):
        name = determine_device_name(name)
    if name == None: return None

    return system.get_metadata_from_cache(name)

def rescue_orphaned_domain(domain):
    name = domain["name"]
    yn = dialogbox.messagebox.execute(gui.res.string_config_info % (name), dialogbox.DialogBox.OKCANCEL())
    if yn != "ok": return False
    fields = [{"id":"memory","label":gui.res.string_allocated_memory,"value":64,"type":"int"}]
    memory = None
    while memory == None:
        values = gui.propertybox.execute(gui.res.string_new_set % (name) ,fields)
        if values == None: return False

        memory = values["memory"]
        fields[0]["value"] = memory
        if memory < 32:
            dialogbox.messagebox.execute(gui.res.string_memory_assign_desc,None, gui.res.caution_sign)
            memory = None

    vmm = vm.getVirtualMachineManager()
    vmm.createVMConfigFile(name, memory, system.guest_kernel, 1, domain["device"])
    domain["configfile"] = True
    dialogbox.messagebox.execute(gui.res.string_confi_info % (name))
    return True

def start_domain(name):
    def wb_create(q):
        try:
            cli_create.run(name)
            q.put(True)
        except Exception, e:
            traceback.print_exc(file=sys.stderr)
            q.put(e)

    try:
        q = multiprocessing.Queue()
        p = multiprocessing.Process(target=wb_create, args=(q,))
        p.start()
        with dialogbox.messagebox.open(string_starting):
            while p.is_alive():
                gui.yieldFrame()
        p.join()
        rst = q.get_nowait()
        if isinstance(rst, Exception): raise rst
    except:
        traceback.print_exc(file=sys.stderr)
        dialogbox.messagebox.execute(string_not_start, None, gui.res.caution_sign)
        wbui.play_sound("fail")
        return False

    return True

def start(domain):
    return start_domain(domain["name"])

def console(domain):
    if dialogbox.messagebox.execute(gui.res.string_vm_connect_desc % (domain["name"]), dialogbox.DialogBox.OKCANCEL()) != "ok": return False
    pygame.quit()
    if os.path.exists("/usr/bin/fbterm"):
        os.system("/usr/bin/openvt -wsl -- /usr/bin/fbterm -- /usr/sbin/wb xen_console_with_message %s" % domain["name"])
    else:
        os.system("clear")
        os.system("/usr/bin/openvt -wsl -- /usr/sbin/xl console %s" % domain["name"])
    wbui.restart()
    return True # not reached

def shutdown(domain):
    if dialogbox.messagebox.execute(gui.res.string_exit_desc % (domain["name"]), dialogbox.DialogBox.OKCANCEL()) != "ok": return False
    ret = os.system("xl shutdown %s" % (domain["name"]))
    if ret != 0:
        wbui.play_sound("fail")
        dialogbox.messagebox.execute(gui.res.string_unable,None, gui.res.caution_sign)
        return False

    footer.window.setText(gui.res.string_domain_issued)
    return True

def reboot(domain):
    if dialogbox.messagebox.execute(gui.res.string_restart_ins % (domain["name"]), dialogbox.DialogBox.OKCANCEL()) != "ok": return False

    ret = os.system("xl reboot %s" % (domain["name"]))
    if ret != 0:
        wbui.play_sound("fail")
        dialogbox.messagebox.execute(gui.res.string_unable_restart_ins,None, gui.res.caution_sign)
        return False
    return True

def destroy(domain):
    if dialogbox.messagebox.execute(gui.res.string_kill_vm % (domain["name"]), dialogbox.DialogBox.OKCANCEL(), gui.res.caution_sign) != "ok": return False
    ret = os.system("xl destroy %s" % (domain["name"]))
    if ret != 0:
        wbui.play_sound("fail")
        dialogbox.messagebox.execute(gui.res.string_not_killed,None, gui.res.caution_sign)
        return False
    #else
    footer.window.setText(gui.res.string_terminated)
    return True

def delete(domain):
    if dialogbox.messagebox.execute(gui.res.string_delete_desc % (domain["name"]), dialogbox.DialogBox.OKCANCEL(), gui.res.caution_sign) != "ok": return False

    try:
        cli_remove_vm.run(domain["device"], True)
    except:
        dialogbox.messagebox.execute(gui.res.string_vm_not_del,None, gui.res.caution_sign)
        return False

    footer.window.setText(gui.res.string_vm_del)
    return True

'''
["hostname"] = hostname
["memory"] = memory
'''
def edit_existing_domain(title, hostname, memory):
    orig_hostname = hostname
    fields = [{"id":"hostname","label":gui.res.string_vm_name,"value":hostname},{"id":"memory","label":gui.res.string_allocated,"value":memory,"type":"int"}]
    while True:
        values = gui.propertybox.execute(title,fields)
        if values == None: break
        #else
        hostname = values["hostname"]
        memory = values["memory"]

        fields[0]["value"] = hostname
        fields[1]["value"] = memory

        if domain.exists(hostname) and hostname != orig_hostname:
            dialogbox.messagebox.execute(gui.res.string_vm_name_exists % (hostname), None, gui.res.caution_sign)
            continue

        if memory < 32:
            dialogbox.messagebox.execute(gui.res.string_allocation_desc, None, gui.res.caution_sign)
            continue

        return {"name":hostname, "memory":memory}

    return None

def rename(name, device):
    values = cli_edit.read(device)
    memory = values.get("memory") or 128
    rst = edit_existing_domain(string_vm_change, name, memory)
    if rst is None: return False
    #else
    newname = rst["name"]
    newmemory = rst["memory"]

    changed = False

    try:
        if newmemory != memory:
            values["memory"] = newmemory
            cli_edit.write(device, values)
            changed = True

        if newname != name:
            cli_rename.run(device, newname)
            changed = True
    except Exception, e:
        traceback.print_exc(file=sys.stderr)
        dialogbox.messagebox.execute(string_vm_change_failed % (e), None, gui.res.caution_sign)
        return False

    if changed:
        domain.refresh()
        dialogbox.messagebox.execute(string_vm_changed)

    return False # because domain.refresh() already called even if changed

def expand(domain):
    s = system.getSystem()
    device = domain["device"]
    orig_disk = domain.get("size") or s.determineLogicalVolumeSizeInGB(device)
    min_disk = int(orig_disk) + 1
    disk = gui.inputbox.TextInputBox(gui.res.string_new_size, min_disk, None, 1, 5, "0123456789").execute(gui.getDesktop())
    if disk == None: return False
    disk = int(disk)
    if disk < min_disk:
        gui.messagebox.execute(gui.res.string_size_desc, ["ok"], gui.res.color_dialog_negative)
        return False
    if min_disk < 2048 and disk >= 2048:
        gui.messagebox.execute(string_cant_across_2tb, ["ok"], gui.res.color_dialog_negative)
        return False

    if subprocess.Popen("lvextend -L %dG %s" % (disk, device), shell=True, close_fds=True).wait() != 0:
        gui.messagebox.execute(gui.res.string_free_space_desc, ["ok"], gui.res.color_dialog_negative)
        return False

    with s.temporaryMount(device, None, "inode32") as tmpdir:
        if subprocess.Popen("xfs_growfs %s" % tmpdir, shell=True, close_fds=True).wait() != 0:
            gui.messagebox.execute(gui.res.string_assign_desc, ["ok"], gui.res.color_dialog_negative)
            return False
    
    gui.messagebox.execute(gui.res.string_enhanced, ["ok"])
    return True

def exec_duplicate(src, dest, hostname, kernel, vcpus):
    s = system.getSystem()
    with gui.progressbar.SyncedProgressBar(gui.res.string_cloning) as pb:
        try:
            with s.openCancellableProcessForInput(["xfs_copy", src, dest]) as xfs_copy:
                nbr = s.getNonblockingReader(xfs_copy.stdout)
                output = ""
                percentage_pattern = re.compile('[0-9]{1,3}%')
                str = nbr.read()
                while str != "":
                    pb.yieldFrame()
                    if str != None: 
                        output += str
                        progress = float(percentage_pattern.findall(output)[-1][0:-1]) / 100.0
                        pb.setProgress(progress)
                    str = nbr.read()
        except system.ProcessKilled:
            pass # killed is proper result

        with s.temporaryMount(dest, None, "inode32") as tmpdir:
            # growfsする
            subprocess.Popen("xfs_growfs %s" % tmpdir, shell=True, close_fds=True).wait()
            # ホスト名をつける
            cli_install_va.set_hostname(tmpdir, hostname)
            # VAのメタデータを得る
            metadata = system.get_va_metadata(dest, tmpdir)

def duplicate(domain):
    name = domain["name"]
    src_device = domain["device"]
    use_snapshot = domain.get("open") != False
    if use_snapshot:
        if dialogbox.messagebox.execute(gui.res.string_operation_desc, dialogbox.DialogBox.OKCANCEL()) != "ok": return

    s = system.getSystem()
    lvsize = domain.get("size") or s.determineLogicalVolumeSizeInGB(src_device)
    min_disk = int(lvsize + 1) if int(lvsize) < lvsize else int(lvsize)
    new_domain = create.edit_new_domain(gui.res.string_duplicate, name, 128, min_disk)
    if new_domain == None: return

    hostname = new_domain["hostname"]
    vgname = new_domain["vgname"]
    disk = new_domain["disk"]
    kernel = system.guest_kernel
    vcpus = 1

    lvname = hostname
    device_name = system.create_logical_volume_in_GB(vgname, lvname, disk, True, "@wbvm")
    if device_name == None:
        wbui.play_sound("fail")
        gui.messagebox.execute(gui.res.string_duplicate_fail, ["ok"], gui.res.color_dialog_negative)
        return

    metadata = None # /etc/wb-va.xml

    # マーキーに作成中の仮想マシンに関する情報を表示
    footer.window.setText(gui.res.string_duplication_description % (name,vgname,hostname,disk) )

    try:
        if use_snapshot:
            with s.openSnapshot(src_device, 1) as snapshot:
                exec_duplicate(snapshot, device_name, hostname, kernel, vcpus)
        else:
            exec_duplicate(src_device, device_name, hostname, kernel, vcpus)
    except Exception, e:
        s.removeLogicalVolume(device_name)
        wbui.play_sound("fail")
        traceback.print_exc(file=sys.stderr)
        gui.messagebox.execute(gui.res.string_replicate_fails % (e), ["ok"], gui.res.color_dialog_negative)
        return False

    wbui.play_sound("success")
    gui.messagebox.execute(gui.res.string_duplicate_complete)
    return True

def vpn(domain):
    device = domain["device"]
    s = system.getSystem()
    try:
        with s.temporaryMount(device, None, "ro") as tmpdir:
            rst = subprocess.check_output(["/bin/egrep", "ENABLE_PASSWORD_SAVE|enable_password_save=yes", "%s/usr/sbin/openvpn" % tmpdir], shell=False, close_fds=True)
    except:
        #traceback.print_exc(file=sys.stderr)
        dialogbox.messagebox.execute(gui.res.string_connection_desc, None, gui.res.caution_sign)
        return False

    fields = [{"id":"hostname", "label":gui.res.string_destination_host, "value":""},{"id":"id", "label":gui.res.string_con_id, "value":""}, {"id":"password", "label":gui.res.string_con_password, "value":"", "password":True}]
    while True:
        values = gui.propertybox.execute(gui.res.string_vpn_setting, fields)
        if values == None: return False
        if dialogbox.messagebox.execute(gui.res.string_setting_desc % (values["hostname"], values["id"]), dialogbox.DialogBox.OKCANCEL()) == "ok": break

    autostart_done = False
    try:
        with s.temporaryMount(device, None, "inode32") as tmpdir:
            with open("%s/etc/openvpn/openvpn.conf" % tmpdir, "w") as f:
                f.write("client\n")
                f.write("dev tun\n")
                f.write("remote %s\n" % values["hostname"])
                cert_filename = "/etc/ssl/certs/ca-certificates.crt"
                if not os.path.exists("%s%s" % (tmpdir, cert_filename)):
                    cert_filename = "/etc/ssl/certs/ca-bundle.crt"
                f.write("ca %s\n" % cert_filename)
                f.write("fragment 1300\n")
                f.write("mssfix\n")
                f.write("nobind\n")
                f.write("float\n")
                f.write("ping 60\n")
                f.write("auth-user-pass auth.txt\n")
            with open("%s/etc/openvpn/auth.txt" % tmpdir, "w") as f:
                f.write("%s\n%s\n" % (values["id"], values["password"]))
	    os.chmod("%s/etc/openvpn/auth.txt" % tmpdir, stat.S_IRUSR|stat.S_IWUSR)
            if os.path.isdir("%s/etc/runlevels/default" % tmpdir):
                if not os.path.lexists("%s/etc/runlevels/default/openvpn" % tmpdir):
                    os.symlink("/etc/init.d/openvpn", "%s/etc/runlevels/default/openvpn" % tmpdir)
                autostart_done = True
	    elif os.path.isdir("%s/etc/rc3.d" % tmpdir):
	    	if not os.path.lexists("%s/etc/rc3.d/S24openvpn" % tmpdir):
		    os.symlink("../init.d/openvpn", "%s/etc/rc3.d/S24openvpn" % tmpdir)
		autostart_done = True
            elif os.path.isdir("%s/etc/systemd/system/multi-user.target.wants" % tmpdir):
                if not os.path.lexists("%s/etc/systemd/system/multi-user.target.wants/openvpn.service" % tmpdir):
                    os.symlink("/usr/lib/systemd/system/openvpn@.service", "%s/etc/systemd/system/multi-user.target.wants/openvpn@openvpn.service" % tmpdir)
                autostart_done = True

    except Exception as e:
        dialogbox.messagebox.execute(gui.res.string_setting_fail % e.message, None, gui.res.caution_sign)
        return False

    autostart_msg = "" if autostart_done else gui.res.string_manually_start
    dialogbox.messagebox.execute(gui.res.string_vpn_vm_setting % (domain["name"], autostart_msg))
    return True

def run(domain):
    # orphanなdomainの処理
    #if not domain["configfile"] and "device" in domain:
    #    if rescue_orphaned_domain(domain) == False: return

    operations = []
    memory = domain.get("memory")
    domain_name = domain["name"]
    s = system.getSystem()
    if memory is None:
        operations.append({"id":"start","label":gui.res.string_domain_operate_start})
    else:
        if s.isRunningAsGetty(): 
            operations.append({"id":"console","label":gui.res.string_console})
        operations.append({"id":"shutdown","label":gui.res.string_ins_ends})
        operations.append({"id":"reboot","label":gui.res.string_restart})
        operations.append({"id":"destroy","label":gui.res.string_stop})
    if domain["autostart"]:
        operations.append({"id":"noautostart","label":gui.res.string_can_automatic})
    else:
        operations.append({"id":"autostart","label":gui.res.string_auto_start})

    modifiable = domain.get("writable") and not domain.get("open") and domain.get("fstype") == "xfs"
    
    if memory == None:
        if modifiable: 
            operations.append({"id":"rename", "label":gui.res.string_name_ram})
            operations.append({"id":"expand", "label":gui.res.string_extend_space})
            operations.append({"id":"vpn", "label":gui.res.string_vpn_config})
        operations.append({"id":"delete","label":gui.res.string_remove})
    operations.append({"id":"duplicate", "label":gui.res.string_replicate})

    metadata = get_va_metadata_from_cache(domain_name)
    instruction = None
    if metadata != None:
        instructions = metadata.findall("./instruction")
        if len(instructions) > 0:
            instruction = instructions[0].text

    if instruction != None:
        operations.append({"id":"instruction","label":gui.res.string_learn})

    operation = gui.selectbox.execute(domain_name, operations)

    if operation == "start":
        return start(domain)
    elif operation == "console":
        return console(domain)
    elif operation == "shutdown":
        return shutdown(domain)
    elif operation == "reboot":
        return reboot(domain)
    elif operation == "destroy":
        return destroy(domain)
    elif operation == "delete":
        return delete(domain)
    elif operation == "rename":
        return rename(domain["name"],domain["device"])
    elif operation == "expand":
        return expand(domain)
    elif operation == "duplicate":
        return duplicate(domain)
    elif operation == "vpn":
        return vpn(domain)
    elif operation == "autostart":
        cli_autostart.set_autostart(domain_name, True)
        footer.window.setText(string_vm_autostart % (domain_name))
        return True

    elif operation == "noautostart":
        cli_autostart.set_autostart(domain_name, False)
        footer.window.setText(string_vm_no_autostart % (domain_name))
        return True

    elif operation == "instruction":
        dialogbox.messagebox.execute(instruction)
    return False

# -*- coding: utf-8 -*-

import subprocess,multiprocessing

import pygame

import system
import gui
import dialogbox.messagebox
import dialogbox.progressbar

import resource_loader

from cli2 import install as cli_install


window = None

# string resources

gui.res.register("string_install_space",resource_loader.l({"en":u"During installation of space ...", "ja":u"インストール先の領域を確保中..."}))

gui.res.register("string_Canceled_by_user",resource_loader.l({"en":u"Canceled by the user", "ja":u"ユーザーによるキャンセル"}))
string_installing = resource_loader.l({"en":u"Installing ...", "ja":u"インストール中..."})
string_installation_description = resource_loader.l({"en":u"Install the system on a %s disk (model: %s, device name: %s). Do you want?（All contents of the disk will be erased!!）", "ja":u"%sのディスク(モデル:%s, デバイス名:%s)にシステムをインストールします。よろしいですか？（このディスクの内容は全て消去されます！！）"})
string_inst_installation_failed = resource_loader.l({"en":u"Installation failed (%s)", "ja":u"インストールに失敗しました(%s)"})

gui.res.register("string_inst_reboot_desc",resource_loader.l({"en":u"Please remove the installation disk from the drive. To start the system installed you may have to change the boot device in the BIOS settings. Restart the computer?", "ja":u"インストールディスクをドライブから取り出してください。インストールされたシステムを起動するには BIOS設定で起動デバイスを変更しなければならない場合があります。コンピュータを再起動しますか？"}))

string_setup_entire_disk_fail = resource_loader.l({"en":u"Disk setup failed.", "ja":u"ディスクのセットアップに失敗しました"})
string_copying_boot_files = resource_loader.l({"en":u"Copying boot files...", "ja":u"ブートファイルをコピー中..."})

def exec_install(disk, image, q):
    try:
        q.put(cli_install.run(disk["name"], image, True))
    except Exception, e:
        q.put(e)

def run(disk, image):
    block_name = disk["name"]
    product = "%s %s" % (disk["vendor"], disk["model"])
    size = disk["size_str"]
    if dialogbox.messagebox.execute(string_installation_description % (size, product, block_name), dialogbox.DialogBox.OKCANCEL(), gui.res.caution_sign) != "ok":
        return False

    with dialogbox.messagebox.open(string_installing):
        q = multiprocessing.Queue()
        p = multiprocessing.Process(target=exec_install, args=(disk, image, q))
        p.start()
        while p.is_alive():
            gui.yieldFrame()
        p.join()
        try:
            rst = q.get_nowait()
        except Exception, e:
            rst = e

    if isinstance(rst, Exception):
        dialogbox.messagebox.execute(string_inst_installation_failed % (rst), None, gui.res.caution_sign)
        return False

    if dialogbox.messagebox.execute(gui.res.string_inst_reboot_desc, dialogbox.DialogBox.OKCANCEL()) == "ok":
        subprocess.call(["reboot","-f"])

    return True

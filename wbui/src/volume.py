# -*- coding:utf-8 -*-

import subprocess
import os
import sys
import time
import threading
import pygame
import traceback
from xml.etree import ElementTree

import wbui
import system
import pygamehelper
import gui.util
import gui.progressbar
import gui.messagebox
import gui.selectbox
import gui.propertybox

import dialogbox.messagebox

import system
import resource_loader

canvas = None
create_new = None
active = None
cursor = None
alpha = None
dalpha = None
blink_count = None
vglist = None
progress = None


# string resources
string_searching_useable_disks = resource_loader.l({"en":u"Searching useable disks...", "ja":u"利用可能なディスクの捜索中..."})
gui.res.register("string_volume_new",resource_loader.l({"en":u"New Volume", "ja":u"新規作成"}))
gui.res.register("string_in_free",resource_loader.l({"en":u"%s In %s free","ja":u"%s中%s空き"}))
gui.res.register("string_volume_remove",resource_loader.l({"en":u"Delete", "ja":u"削除する"}))
gui.res.register("string_logic_volume",resource_loader.l({"en":u"Confirmation of the logical volume", "ja":u"論理ボリュームの確認"}))
gui.res.register("string_volume_del_area",resource_loader.l({"en":u"You want to delete the %s area.Are you sure.?", "ja":u"領域 %s を削除しますか？"}))
gui.res.register("string_volume_deleted",resource_loader.l({"en":u"%s has been deleted region", "ja":u"領域 %s を削除しました"}))
gui.res.register("string_not_remove",resource_loader.l({"en":u"%s Area could not be deleted", "ja":u"領域 %s を削除できませんでした"}))
gui.res.register("string_logical_volume_included",resource_loader.l({"en":u"%s area is included in the Logical Volumes", "ja":u"領域 %s に含まれている論理ボリュームは"}))
gui.res.register("string_do_not",resource_loader.l({"en":u"Do not have", "ja":u"ありません"}))
gui.res.register("string_other",resource_loader.l({"en":u"other%d", "ja":u"他%d"}))
gui.res.register("string_disk_description",resource_loader.l({"en":u"New areas will be used as a hard disk could not be found", "ja":u"新たな領域として使用できそうなハードディスクが見つかりませんでした"}))
gui.res.register("string_lps",resource_loader.l({"en":u"%s %s(%sB)", "ja":u"%s %s(%sB)"}))
gui.res.register("string_volume_choice",resource_loader.l({"en":u"Select the hard disk", "ja":u"ハードディスクの選択"}))
gui.res.register("string_domain_name",resource_loader.l({"en":u"Volume name", "ja":u"領域名"}))
gui.res.register("string_volume_used_area",resource_loader.l({"en":u"%s Used as a new volume", "ja":u"%s を新しい領域として使用"}))
gui.res.register("string_used_domain_name",resource_loader.l({"en":u"%s volume name is already in use. Please use another name. ", "ja":u"領域名 %s は既に使用されています。他の名前を使用してください。"}))
gui.res.register("string_erase_msg",resource_loader.l({"en":u"%s of hard disk(model:%s, device name:%s) space used as %s volume. Do you want to allow this?(The contents of this hard disk will be erased!)", "ja":u"%sBのハードディスク(モデル:%s, デバイス名:%s)を領域%sとして使用します。よろしいですか？（このハードディスクの内容は全て消去されます！！）"}))
gui.res.register("string_disk_partition",resource_loader.l({"en":u"Creating a partition ...", "ja":u"パーティションを作成しています..."}))
gui.res.register("string_volume_fail",resource_loader.l({"en":u"Failed to create the volume (%s)", "ja":u"領域の作成に失敗しました(%s)"}))
gui.res.register("string_volume_success",resource_loader.l({"en":u"Successfully created the volume %s", "ja":u"領域 %s の作成に成功しました"}))






def init():
    global canvas, create_new, active, cursor, alpha, dalpha, blink_count
    canvas = pygame.Surface((400, 409), pygame.SRCALPHA, 32)
    create_new = wbui.smallfont.render(gui.res.string_volume_new, True, (255,255,255))
    active = False
    cursor = pygame.Surface((canvas.get_width(), wbui.smallfont.get_height()))
    cursor.fill((255,255,128))

    alpha = 50
    dalpha = 2

    blink_count = 0

def exec_parted_command(command, logicalname):
    return subprocess.Popen("parted --script %s '%s'" % (logicalname, command), shell=True, close_fds=True).wait()

def wait_for_device(device_name):
    count = 0
    while not os.path.exists(device_name):
        time.sleep(1)
        count += 1
        if count >= 10:
            return False
    time.sleep(1)
    return True

def list_vgs():
    vgs = subprocess.Popen(["/sbin/vgs","--noheadings"], shell=False, stdout=subprocess.PIPE,close_fds=True)
    line = vgs.stdout.readline() 
    vglist = []
    while line:
        splitted = line.split()
        vginfo = {"name":splitted[0], "pv":splitted[1], "lv":splitted[2], "size":splitted[5], "free":splitted[6] }
        vglist.append(vginfo)
        line = vgs.stdout.readline()
    vgs.wait()
    return vglist

def vg_exists(vgname):
    if vglist == None: return False
    for vg in vglist:
        if vg["name"] == vgname: return True
    return False

def refresh():
    global vglist
    vglist = list_vgs()
    selected = 0

def draw_item(num, name, size, free):
    hdr_img = wbui.smallfont.render(name, True, (255, 255, 255))
    value_img = wbui.smallfont.render(gui.res.string_in_free % (size, free), True, (96, 255, 96))
    y = num * wbui.smallfont.get_height()
    canvas.blit(hdr_img, (0, y) )
    canvas.blit(value_img, (canvas.get_width() - value_img.get_width(), y))

def update():
    canvas.fill((0,0,0,0))
    canvas.blit(gui.res.contents_panel, (0, 0))

    global alpha, dalpha, blink_count
    # カーソル描画
    if active:
        alpha = gui.util.get_cycling_value_by_time((16,128), 2000)
        cursor.set_alpha(alpha)
        canvas.blit(cursor, (0, selected * cursor.get_height()))

    # 新規作成
    canvas.blit(create_new, (0, 0))

    # VG一覧
    i = 0
    for vg in vglist:
        draw_item(i + 1, vg["name"], vg["size"], vg["free"])
        i += 1

    # カーソルの上下矢印描画
    if active and gui.util.get_cycling_bool_by_time(1500):
        if is_able_to_go_up():
            canvas.blit(wbui.up_arrow, pygamehelper.center_to_lefttop(wbui.up_arrow, (canvas.get_width() / 2, selected * cursor.get_height()) ))
        if is_able_to_go_down():
            canvas.blit(wbui.down_arrow, pygamehelper.center_to_lefttop(wbui.down_arrow, (canvas.get_width() / 2, (selected + 1) * cursor.get_height() - 1) ))

    
    alpha += dalpha
    if alpha > 127:
        alpha = 127
        dalpha *= -1
    elif alpha < 50:
        alpha = 50
        dalpha *= -1

    blink_count += 1
    if blink_count >= 30: blink_count = 0

def get_canvas():
    return canvas

def get_vglist():
    return vglist

def activate():
    global active, selected 
    refresh()
    active = True
    selected = 0
    return True

def deactivate():
    global active
    active = False
#string_new_area
def is_active():
    return active

def enter():
    if selected == 0:
        wbui.play_sound("click")
        create_vg()
        return
    else:
        # vgに対するオペレーションメニューを表示
        wbui.play_sound("click")
        vg = vglist[selected - 1]["name"]
        lvs = subprocess.Popen("lvs --noheadings --separator='|' %s" % (vg), shell=True, stdout=subprocess.PIPE, close_fds=True)
        line = lvs.stdout.readline()
        lv_list = []
        while line:
            lv = line.split("|")[0].strip()
            lv_list.append(lv)
            line = lvs.stdout.readline()
        lvs.wait()
        operations = [{"label":gui.res.string_volume_remove},{"label":gui.res.string_logic_volume,"id":"lvs"}]
        if len(lv_list) == 0:
            operations[0]["id"] = "remove"

        operation = gui.selectbox.execute(vg, operations)
        if operation == "remove":
            if dialogbox.messagebox.execute(gui.res.string_volume_del_area % (vg), dialogbox.DialogBox.OKCANCEL()) != "ok":
                return None
            if system.exec_shell("vgremove -f %s" % (vg)) == 0:
                dialogbox.messagebox.execute(gui.res.string_volume_deleted % (vg))
            else:
                dialogbox.messagebox.execute(gui.res.string_not_remove % (vg), None, gui.res.caution_sign)
            refresh()
        elif operation == "lvs":
            max_show = 20
            msg = gui.res.string_logical_volume_included % (vg)
            if len(lv_list) == 0:
                msg += gui.res.string_do_not
            else:
                for i in range(0, min(len(lv_list),max_show)):
                    if i > 0:
                        msg += ","
                    msg += lv_list[i]
                if i < len(lv_list) - 1:
                    msg += (gui.res.string_other % (len(lv_list) - max_show))
            dialogbox.messagebox.execute(msg)

def escape():
    return False # 制御をメインメニューに戻す

def is_able_to_go_up():
    return selected > 0

def is_able_to_go_down():
    return selected < len(vglist)

def up():
    global selected
    if is_able_to_go_up():
        wbui.play_sound("move")
        selected -= 1
        update()
        return True
    return False

def down():
    global selected
    if is_able_to_go_down():
        wbui.play_sound("move")
        selected += 1
        update()
        return True
    return False

def list_available_disks():
    useable_disks = []
    s = system.getSystem()
    with dialogbox.messagebox.open(string_searching_useable_disks):
        with s.openWbForInput("list_useable_disks") as list_useable_disks:
            nbr = s.getNonblockingReader(list_useable_disks.stdout)
            line = nbr.readline()
            while line != "":
                if line != None: 
                    cols = line.split('\t')
	            useable_disks.append({"logicalname":cols[0],"size":cols[1],"product":cols[2],"sectorSize":int(cols[3])})
                gui.yieldFrame()
                line = nbr.readline()

    return useable_disks

def determine_new_vg_name():
    vglist = list_vgs()
    vg_num = 0
    while True:
        vgname = "vg" if vg_num == 0 else ("vg%d" % vg_num)
        found = False
        for vg in vglist:
            if vg["name"] == vgname:
                found = True
                break
        if found == False:
            return vgname
        vg_num += 1

def select_disk():
    disks = list_available_disks()
    if len(disks) == 0:
        wbui.play_sound("fail")
        dialogbox.messagebox.execute(gui.res.string_disk_description, dialogbox.DialogBox.OK(), gui.res.caution_sign)
        return None

    # ディスク選択
    options = []
    disks_by_name = {}
    for disk in disks:
        logicalname = disk["logicalname"]
        product = disk["product"]
        size = disk["size"]
        options.append({"id":logicalname,"label":gui.res.string_lps % (logicalname, product, size)})
        disks_by_name[logicalname] = [product, size]

    logicalname = gui.selectbox.execute(gui.res.string_volume_choice,options)
    if logicalname == None: return None

    product = disks_by_name[logicalname][0]
    size = disks_by_name[logicalname][1]

    return ("/dev/" + logicalname, product, size)

def input_vg_name(logicalname):
    vgname = determine_new_vg_name()

    fields = [{"id":"vgname","label":gui.res.string_domain_name,"value":vgname}]
    while True:
        values = gui.propertybox.execute(gui.res.string_volume_used_area % (logicalname), fields)
        if values == None: return False

        vgname = values["vgname"]
        fields[0]["value"] = vgname

        if vg_exists(vgname):
            dialogbox.messagebox.execute(gui.res.string_used_domain_name % (vgname), None, gui.res.caution_sign)
        else:
            return vgname

def create_vg():
    # ディスク選択
    selected_disk = select_disk()
    if selected_disk == None: return
    logicalname = selected_disk[0]
    product = selected_disk[1]
    size = selected_disk[2]

    # VGの名前をユーザーに決めてもらう
    vgname = input_vg_name(logicalname)
    if vgname == None: return

    if dialogbox.messagebox.execute(gui.res.string_erase_msg % (size, product, logicalname,vgname), dialogbox.DialogBox.OKCANCEL(), gui.res.caution_sign) != "ok":
        return

    try:
        with gui.progressbar.SyncedProgressBar(gui.res.string_disk_partition) as progressBar:
            s = system.getSystem()
            with s.openWbForInput("initialize_disk", [logicalname, vgname]) as initialize_disk:
                nbr = s.getNonblockingReader(initialize_disk.stdout)
                line = nbr.readline()
                while line != "":
                    if line != None: 
                        (x, y) = (float(x) for x in line.rstrip().split('/'))
                        progressBar.setProgress(x / y)
                    progressBar.yieldFrame()
                    line = nbr.readline()

    except Exception as e:
        traceback.print_exc(file=sys.stderr)
        wbui.play_sound("fail")
        dialogbox.messagebox.execute(gui.res.string_volume_fail % e.message, None, gui.res.caution_sign)
        return None

    refresh()
    wbui.play_sound("success")
    gui.messagebox.execute(gui.res.string_volume_success % (vgname))
    return vgname

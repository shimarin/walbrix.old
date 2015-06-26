# -*- coding:utf-8 -*-
import os
import sys
import subprocess
import pygame
import traceback
import json
import io
import signal

import pygame.display

import wbui
import domain # to borrow virtualappliancedescription class
import volume # to use list_vg func
import footer
import dialogbox
import gui
import gui.selectbox
import system
import http_client

import pygamehelper
import resource_loader

# string resources

gui.res.register("string_app_download",resource_loader.l({"en":u"Application Download", "ja":u"ダウンロード"}))
gui.res.register("string_app_start",resource_loader.l({"en":u"Start", "ja":u"起動する"}))
gui.res.register("string_app_remove",resource_loader.l({"en":u"Remove", "ja":u"削除する"}))

gui.res.register("string_launch_apps",resource_loader.l({"en":u"Do you want to launch the app %s?", "ja":u"アプリ %s を起動しますか？"}))

gui.res.register("string_apps_not_started",resource_loader.l({"en":u"The application could not be started(%s).", "ja":u"アプリを開始できませんでした(%s)"}))

gui.res.register("string_apps_delete",resource_loader.l({"en":u"Are you sure to delete the application %s? (You can not revert)", "ja":u"アプリ %s を本当に削除しますか？(戻すことはできません)"}))
gui.res.register("string_apps_deleted",resource_loader.l({"en":u"The app has been deleted", "ja":u"アプリを削除しました"}))

gui.res.register("string_apps_not_del",resource_loader.l({"en":u"The application couldn't be deleted(%s).", "ja":u"アプリを削除できませんでした(%s)"}))
gui.res.register("string_app_code",resource_loader.l({"en":u"Enter the code for the application", "ja":u"アプリケーションのコードを入力"}))
gui.res.register("string_app_code_check",resource_loader.l({"en":u"Checking code ...", "ja":u"コードを確認中..."}))
gui.res.register("string_code_invalid",resource_loader.l({"en":u"Specified code is not valid", "ja":u"コード指定が正しくありません"}))
gui.res.register("string_app_canceled",resource_loader.l({"en":u"Canceled", "ja":u"キャンセルされました"}))
gui.res.register("string_app_comm_error",resource_loader.l({"en":u"Communication error: %s (%s).", "ja":u"通信エラー: %s (%s)"}))
gui.res.register("string_app_not_supported",resource_loader.l({"en":u"This application is not compatible with your architecture %s.", "ja":u"このアプリケーションはお使いのアーキテクチャ %s に対応していません。"}))
gui.res.register("string_apps_details",resource_loader.l({"en":u"Getting the details of the application ...", "ja":u"アプリケーションの詳細を取得中..."}))
gui.res.register("string_app_can",resource_loader.l({"en":u"Cancel", "ja":u"キャンセル"}))

gui.res.register("string_downl_capacity",resource_loader.l({"en":u"Download capacity%.1fMB ", "ja":u"ダウンロード容量%.1fMB"}))
gui.res.register("string_app_minimum_hd",resource_loader.l({"en":u"Minimum HD capacity %dMB", "ja":u"最低HD容量%dMB"}))

gui.res.register("string_app_exists",resource_loader.l({"en":u"Application %s is already exists.", "ja":u"アプリケーション %s は既に存在しています。"}))
gui.res.register("string_app__select_area",resource_loader.l({"en":u"Select volume to download", "ja":u"ダウンロード先領域の選択"}))
gui.res.register("string_app_area_creation_failed_desc",resource_loader.l({"en":u"Failed to create the area for the application.You may or may not have enough free space, or the region of the same name already exists", "ja":u"アプリケーション用領域の作成に失敗しました。領域に十分な空きが無いか、既に同名の領域が存在する可能性があります"}))
gui.res.register("string_app_apps_area",resource_loader.l({"en":u"Downloading the application %s to volume %s ...", "ja":u"アプリケーション%sを領域%sにダウンロード中..."}))
gui.res.register("string_app_while_downloading",resource_loader.l({"en":u"Downloading the application ...", "ja":u"アプリケーションのダウンロード中..."}))
gui.res.register("string_app_download_failed",resource_loader.l({"en":u"Failed to download the application.(%s)", "ja":u"アプリケーションのダウンロードに失敗しました。(%s)"}))
gui.res.register("string_app_download_copmlete",resource_loader.l({"en":u"Application download complete", "ja":u"アプリケーションのダウンロードが完了しました"}))



apps = None
window = None
download = None

def run_app(app):
    driver = pygame.display.get_driver()
    pygame.quit()

    s = system.getSystem()
    with s.temporaryMount(app["device"]) as tmpdir:
        with s.temporaryMount("/dev", "%s/dev" % (tmpdir), "bind"):
            with s.temporaryMount("/proc", "%s/proc" % (tmpdir), "bind"):
                cmdline = ("wb", "sandbox", "-r", tmpdir) if driver == "x11" else ("openvt", "-sw", "--", "wb", "sandbox", "-r", tmpdir)
                subprocess.Popen(cmdline, shell=False, close_fds=True).wait()

    wbui.restart()

def init():
    gui.res.register("font_app_list", gui.res.font_system.getFont(20))

    global window
    window = gui.list.List(gui.res.contents_panel.get_size())
    window.setBgImage(gui.res.contents_panel)

    global download
    download = gui.list.TextListItem(gui.res.string_app_download, gui.res.font_app_list)

def refresh():
    global apps

    # アプリを列挙
    apps = system.get_apps()
    window.clearItem()
    window.addItem(download)
    for app in apps:
    	window.addItem(gui.list.TextListItem(app["name"], gui.res.font_app_list, None, None, app))

def exists(name):
    if apps == None: return False
    for a in apps:
        if a["name"] == name:
            return True
    return False

def operate_app(app):
    operations = [{"id":"run", "label":gui.res.string_app_start},{"id":"delete", "label":gui.res.string_app_remove}]
    app_name = app["name"]
    operation = gui.selectbox.execute(app_name, operations)

    if operation == "run":
        if dialogbox.messagebox.execute(gui.res.string_launch_apps % (app["name"]), dialogbox.DialogBox.OKCANCEL()) == "ok":
            try:
                run_app(app)
            except Exception, e:
                wbui.play_sound("fail")
                dialogbox.messagebox.execute(gui.res.string_apps_not_started % e, None, gui.res.caution_sign)
    elif operation == "delete":
        if dialogbox.messagebox.execute(gui.res.string_apps_delete % (app["name"]), dialogbox.DialogBox.OKCANCEL(), gui.res.caution_sign) == "ok":
            try:
                delete_app(app)
                footer.window.setText(gui.res.string_apps_deleted)
            except Exception, e:
                dialogbox.messagebox.execute(gui.res.string_apps_not_del % e,None, gui.res.caution_sign)

def delete_app(app):
    s = system.getSystem()
    s.removeLogicalVolume(app["device"])
    refresh()
    return True

def create():
    code = dialogbox.inputbox.TextInputBox(gui.res.string_app_code, "", 5, 32, "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").execute()
    if code == None: return None
    json_url = "http://goo.gl/" + code # e.g. lLj8Q

    try:
        with dialogbox.messagebox.open(gui.res.string_app_code_check):
            rst = http_client.nonblockHttpGet(json_url)
            app = json.loads(rst)
            for key in ["id", "title","type"]: 
                if not key in app: raise ValueError("Invalid data")
            if app["type"] != "app":
                raise ValueError("type must be app")
    except ValueError:
        dialogbox.messagebox.execute(gui.res.string_code_invalid, None, gui.res.caution_sign)
        return None
    except http_client.Cancelled:
        dialogbox.messagebox.execute(gui.res.string_app_canceled)
        return None
    except http_client.CurlException as e:
        dialogbox.messagebox.execute(gui.res.string_app_comm_error % (e.getError(), e.getURL()), None, gui.res.caution_sign)
        return None

    images = app["images"] if "images" in app else None
    tarball = app["tarball"] if "tarball" in app else None
    minimum_hd = app["minimum_hd"] if "minimum_hd" in app else None
    title = app["title"] if "title" in app else None
    description = app["description"] if "description" in app else None

    s = system.getSystem()
    if not s.checkIfArchitectureIsSupported(app["arch"] if "arch" in app else "i686"):
         dialogbox.messagebox.execute(gui.res.string_app_not_supported % s.getArchitectureString(), None, gui.res.caution_sign)
         return False

    try:
        with dialogbox.messagebox.open(gui.res.string_apps_details):
            image_url = images[0]["url"] if images != None and len(images) > 0 and "url" in images[0] else None

            if image_url != None: 
                rst = http_client.nonblockHttpGet(image_url)
                image = pygame.image.load(io.BytesIO(rst)).convert_alpha()
            else:
                image = None

            contentLength = None
            if tarball != None:
                headers = http_client.nonblockingHttpHead(tarball)
                if "content-length" in headers:
                    contentLength = headers["content-length"]
    except http_client.Cancelled:
        dialogbox.messagebox.execute(gui.res.string_app_canceled)
        return False
    except http_client.CurlException as e:
        dialogbox.messagebox.execute(gui.res.string_app_comm_error % (e.getError(), e.getURL()), None, gui.res.caution_sign)
        return False

    buttons = []
    if tarball != None: buttons.append({ "id":"download", "icon":gui.res.icon_ok, "text":gui.res.string_app_download })
    buttons.append({ "id":"cancel", "icon":gui.res.icon_cancel, "text":gui.res.string_app_can})
    specs = []
    if contentLength != None: specs.append(gui.res.string_downl_capacity % (float(contentLength) / 1024 / 1024))
    if minimum_hd != None: specs.append(gui.res.string_app_minimum_hd % minimum_hd)

    apd = domain.create.VirtualApplianceDescription(title, image, description, " ".join(specs))

    if dialogbox.DialogBox(apd, buttons).execute() != "download": return False

    if exists(app["id"]):
        dialogbox.messagebox.execute(gui.res.string_app_exists % app["id"], None, gui.res.caution_sign)
        return False

    
    vgname = None

    while vgname == None:
        options = []
        for vg in volume.list_vgs():
            options.append({"id":vg["name"], "label":vg["name"]})
        vgname = gui.selectbox.execute(gui.res.string_app__select_area, options)
        if vgname == None: return False

        lvname = app["id"]
        try:
            device_name = s.createLogicalVolumeInMB(vgname, lvname, int(minimum_hd), "@wbapp")
        except Exception, e:
            traceback.print_exc(file=sys.stderr)
            dialogbox.messagebox.execute(gui.res.string_app_area_creation_failed_desc, None, gui.res.caution_sign)
            vgname = None

    # マーキーに作成中の仮想マシンに関する情報を表示
    footer.window.setText(gui.res.string_app_apps_area % (app["id"],vgname) )

    try:
        xfs = s.getFilesystem("xfs")
        xfs.mkfs(device_name)
        with s.temporaryMount(device_name) as tmpdir:
            with dialogbox.progressbar.open(gui.res.string_app_while_downloading) as pb:
                with s.openWbForInput("extract_archive", (tarball, tmpdir)) as extract_archive:
                    nbr = s.getNonblockingReader(extract_archive.stdout)
                    line = nbr.readline()
                    while line != "":
                        if line != None:
                            (n, m) = map(lambda a: float(a), line.split('/'))
                            pb.setProgress(n / m)
                        if gui.yieldFrame():
                            extract_archive.send_signal(signal.SIGINT)
                            #raise Exception(u"ユーザーによるキャンセル")
                        line = nbr.readline()
                    #extract_archive.wait()
                    #extract_archive.stdout.close()
    except Exception, e:
        s.removeLogicalVolume(device_name)
        traceback.print_exc(file=sys.stderr)
        dialogbox.messagebox.execute(gui.res.string_app_download_failed % (e), None, gui.res.caution_sign)
        return False

    dialogbox.messagebox.execute(gui.res.string_app_download_copmlete)
    return True

def main():
    refresh()
    while True:
    	if gui.eventLoop(window) == None: break
	if window.getSelectedIndex() == 0:
	    if create(): refresh()
	else:
	    if operate_app(window.getSelected().getData()):
	    	refresh()


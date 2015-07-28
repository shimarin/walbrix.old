# -*- coding:utf-8 -*-
import sys,os,io,xml,json,crypt,traceback,signal

import pygame

import domain,domain.operate as operate,volume,status
import gui
import wbui
import footer
import system
import catalog
import vaconfig

import dialogbox,dialogbox.inputbox,dialogbox.progressbar,dialogbox.messagebox

import http_client
import resource_loader

import cli2.install_va as cli_install_va

# string resources
gui.res.register("string_located",resource_loader.l({"en":u"'%s' is set to the serial number for the system", "ja":u"'%s'はシステムのシリアルナンバーにしてあります"}))
gui.res.register("string_domain_failed",resource_loader.l({"en":u"Failed to create the virtual machine. You may not have enough free space", "ja":u"仮想マシンの作成に失敗しました。領域に十分な空きが無い可能性があります"}))
gui.res.register("string_area_description",resource_loader.l({"en":u"Virtual Machine %s is being created in volume %s (RAM %dMB HD %dGB) ...", "ja":u"仮想マシン%sを領域%sに作成(RAM%dMB HD%dGB)..."}))
gui.res.register("string_download_description",resource_loader.l({"en":u"Downloading a virtual machine ...", "ja":u"仮想マシンのダウンロード中..."}))
gui.res.register("string_create_failed",resource_loader.l({"en":u"Failed to create the virtual machine. (%s)", "ja":u"仮想マシンの作成に失敗しました。(%s)"}))
gui.res.register("string_creation_completed",resource_loader.l({"en":u"Creation of a virtual machine has been completed", "ja":u"仮想マシンの作成が完了しました"}))
gui.res.register("string_create_region",resource_loader.l({"en":u"There is no volumes that can be used to create the virtual machine. Do you want to create a volume?(You will need to erase any hard drive)", "ja":u"仮想マシンの作成に使用できる領域がありません。領域を作成しますか？（ハードディスクをどれか消去する必要があります）"}))
gui.res.register("string_machine_name",resource_loader.l({"en":u"The virtual machine name", "ja":u"仮想マシン名"}))
gui.res.register("string_allocated_memory",resource_loader.l({"en":u"Allocated memory(MB)", "ja":u"割当メモリ(MB)"}))
gui.res.register("string_domain_area",resource_loader.l({"en":u"Volume", "ja":u"領域"}))
gui.res.register("string_allocation_hd",resource_loader.l({"en":u"Allocation HD(GB)", "ja":u"割当HD(GB)"}))
gui.res.register("string_vm_already_exists",resource_loader.l({"en":u"The virtual machine %s already exists. Please choose another name. ", "ja":u"仮想マシン %s は既に存在しています。他の名前を指定してください。"}))
gui.res.register("string_vm_creation_description",resource_loader.l({"en":u"At least assign a %dMB memory to create a virtual machine.", "ja":u"この仮想マシンを作成するには少なくとも%dMBのメモリを割り当てて下さい。"}))
gui.res.register("string_vm_allocation_desc",resource_loader.l({"en":u"Please allocate at least 32MB of memory.", "ja":u"少なくとも32MBのメモリを割り当てて下さい。"}))
gui.res.register("string_vm_space_desc",resource_loader.l({"en":u"At least assign a %dGB disk space to create this virtual machine.", "ja":u"この仮想マシンを作成するには少なくとも%dGBのディスク領域を割り当てて下さい。"}))
gui.res.register("string_domain_desc",resource_loader.l({"en":u"Volume %s does not exist. Please specify the correct volume name.", "ja":u"領域 %s は存在しません。正しい領域名を指定してください。"}))
gui.res.register("string_get_detail",resource_loader.l({"en":u"Getting the details of the virtual appliance ...", "ja":u"仮想アプライアンスの詳細を取得中..."}))
gui.res.register("string_comm_error",resource_loader.l({"en":u"Communication error:%s (%s)", "ja":u"通信エラー: %s (%s)"}))
gui.res.register("string_domain_download",resource_loader.l({"en":u"Download", "ja":u"ダウンロード"}))
gui.res.register("string_download_capacity",resource_loader.l({"en":u"%.1fMB download capacity", "ja":u"ダウンロード容量%.1fMB"}))
gui.res.register("string_capacity_atleast",resource_loader.l({"en":u"%dGB HD capacity at least", "ja":u"最低HD容量%dGB"}))
gui.res.register("string_minimum_ram",resource_loader.l({"en":u"Minimum RAM capacity %dMB", "ja":u"最低RAM容量%dMB"}))
gui.res.register("string_virtual_appliance_code",resource_loader.l({"en":u"Enter the code for the virtual appliance ", "ja":u"仮想アプライアンスのコードを入力"}))
gui.res.register("string_code_check",resource_loader.l({"en":u"Checking the code ...", "ja":u"コードを確認中..."}))
gui.res.register("string_code_not_correct",resource_loader.l({"en":u"Specified code is not valid", "ja":u"コード指定が正しくありません"}))
gui.res.register("string_create_new_vm",resource_loader.l({"en":u"Create a new virtual machine", "ja":u"仮想マシンの新規作成"}))
gui.res.register("string_catalog",resource_loader.l({"en":u"Loading a catalog of virtual machines ...", "ja":u"仮想マシンのカタログを読み込んでいます..."}))
gui.res.register("string_incorrect_format",resource_loader.l({"en":u"The format of the catalog is incorrect (XML parse error)", "ja":u"カタログの書式が不正です（XMLパースエラー）"}))
gui.res.register("string_enter_code",resource_loader.l({"en":u"Enter the code", "ja":u"コードを入力"}))

gui.res.register("string_domain_sys_error",resource_loader.l({"en":u"System error: unsupported architecture %s", "ja":u"システムエラー：サポートされていないアーキテクチャ %s"}))
gui.res.register("string_domain_support_error",resource_loader.l({"en":u"Sorry, this virtual appliance doesn't support your architecture. (required=%s, yours=%s)", "ja":u"申し訳ございませんが、この仮想アプライアンスあなたのアーキテクチャをサポートしていません。(%sが必要、あなたのアーキテクチャは%s)"}))
string_starting = resource_loader.l({"en":u"Starting virtual machine ...", "ja":u"仮想マシンを開始しています..."})

string_cancel =  resource_loader.l({"en":u"Cancel", "ja":u"キャンセル"})
string_cancelled = resource_loader.l({"en":u"Cancelled", "ja":u"キャンセルされました"})

def set_root_password(rootdir, password):
    shadow_file = rootdir + "/etc/shadow"
    if not os.path.isfile(shadow_file):
        return False

    try:
        newshadow = ""
        with open(shadow_file, "r") as shadow:
            line = shadow.readline()
            while line:
                if line.startswith("root:"):
                    cols = line.split(':')
                    if len(cols) > 2:
                        cols[1] = crypt.crypt(password, password[0]+password[-1])
                        line = ':'.join(cols)
                newshadow += line
                line = shadow.readline()
        with open(shadow_file, "w") as shadow:
            shadow.write(newshadow)
    except Exception, err:
        print err
        return False

    return True

# type=vncpasswdの設定アイテムに対するアクション
def configure_vncpasswd(config, name, item):
    # さしあたりWBのシリアルナンバー(ホスト名)をつける
    serialnum = status.get_serial_number()
    config.set_config_item_value(name, serialnum)
    label = vaconfig.get_label_from_config_item(item)
    return gui.res.string_located % (label)

# ダウンロードしたVAのメタデータから、設定アイテムの情報を読み出し処理する
def configure_va(metadata, root_path):
    config = vaconfig.VAConfiguration(metadata)
    items = config.get_config_items()
    messages = []
    for item_name in items: # itemはXMLノード
        item = items[item_name]
        type = item.get("type") # @type
        if type == "vncpasswd": 
            messages.append(configure_vncpasswd(config, item_name, item))

    config.apply_configuration(root_path)
    return messages

def create_new_domain(args):
    hostname = args["hostname"]
    vgname = args["vgname"]
    tarball = args["tarball"]
    memory = args["memory"]
    disk = args["disk"]
    vcpus = 1

    lvname = hostname
    device_name = system.create_logical_volume_in_GB(vgname, lvname, disk, True, "@wbvm")
    if device_name == None:
        wbui.play_sound("fail")
        dialogbox.messagebox.execute(gui.res.string_domain_failed, None, gui.res.caution_sign)
        return

    metadata = None # /etc/wb-va.xml
    configuration_messages = None

    # マーキーに作成中の仮想マシンに関する情報を表示
    footer.window.setText(gui.res.string_area_description % (hostname,vgname,memory,disk) )

    try:
        s = system.getSystem()
        with s.temporaryMount(device_name, None, "inode32") as tmpdir:
            with dialogbox.progressbar.open(gui.res.string_download_description) as pb:
                with s.openWbForInput("extract_archive", (tarball, tmpdir)) as extract_archive:
                    nbr = s.getNonblockingReader(extract_archive.stdout)
                    line = nbr.readline()
                    while line != "":
                        if line != None:
                            (n, m) = map(lambda a: float(a), line.split('/'))
                            pb.setProgress(n / m)
                        if gui.yieldFrame():
                            extract_archive.send_signal(signal.SIGINT)
                        line = nbr.readline()

            cli_install_va.set_hostname(tmpdir, hostname)

            # https://github.com/wbrxcorp/walbrix/issues/39
            xen_conf_dir = os.path.join(tmpdir, "etc/xen")
            if not os.path.isdir(xen_conf_dir):
                if os.path.exists(xen_conf_dir): os.unlink(xen_conf_dir)
                os.makedirs(xen_conf_dir)
            with open(os.path.join(xen_conf_dir, "config"), "w") as f:
                f.write("memory=%d\n" % memory)
                f.write("vcpus=%d\n" % vcpus)

            # rootのパスワードをつける
            serialnum = status.get_serial_number()
            set_root_password(tmpdir, serialnum)

            # VAのメタデータを得る
            metadata = system.get_va_metadata(device_name, tmpdir)

            # メタデータを元に、コンフィギュレーションを行う
            if metadata != None:
                configuration_messages = configure_va(metadata, tmpdir)

    except Exception, e:
        s = system.getSystem()
        s.removeLogicalVolume(device_name)
        wbui.play_sound("fail")
        traceback.print_exc(file=sys.stderr)
        dialogbox.messagebox.execute(gui.res.string_create_failed % (e), None, gui.res.caution_sign)
        return False

    if not operate.start_domain(hostname): return False

    wbui.play_sound("success")
    dialogbox.messagebox.execute(gui.res.string_creation_completed)

    if configuration_messages != None:
        for msg in configuration_messages:
            dialogbox.messagebox.execute(msg)

    if metadata != None:
        instructions = metadata.findall("./instruction")
        if len(instructions) > 0:
            dialogbox.messagebox.execute(instructions[0].text)

    return True

def determine_new_domain_name(dom_base_name):
    domain.refresh()
    dom_num = 1
    while True:
        dom_name = dom_base_name if dom_num == 1 else ("%s%d" % (dom_base_name, dom_num))
        if domain.exists(dom_name):
            dom_num += 1
            continue
        return dom_name

'''
["hostname"] = hostname
["vgname"] = vgname
["memory"] = memory
["disk"] = disk
'''
def edit_new_domain(title, hostname, default_memory, min_disk, min_memory = None):
    vgname = None
    vglist = volume.list_vgs()
    if len(vglist) == 0:
        if dialogbox.messagebox.execute(gui.res.string_create_region, dialogbox.DialogBox.OKCANCEL(), gui.res.caution_sign) == "ok":
            vgname = volume.create_vg()
        if vgname == None: return None
    else:
        vgname = vglist[0]["name"]

    fields = [{"id":"hostname","label":gui.res.string_machine_name,"value":hostname},{"id":"memory","label":gui.res.string_allocated_memory,"value":default_memory,"type":"int"},{"id":"vgname","label":gui.res.string_domain_area,"value":vgname},{"id":"disk","label":gui.res.string_allocation_hd,"value":min_disk,"type":"int"}]
    while True:
        values = gui.propertybox.execute(title,fields)
        if values == None: break
        #else
        hostname = values["hostname"]
        memory = values["memory"]
        vgname = values["vgname"]
        disk = values["disk"]

        fields[0]["value"] = hostname
        fields[1]["value"] = memory
        fields[2]["value"] = vgname
        fields[3]["value"] = disk

        if domain.exists(hostname):
            dialogbox.messagebox.execute(gui.res.string_vm_already_exists % (hostname), None, gui.res.caution_sign)
            continue

        if min_memory != None and memory < min_memory:
            dialogbox.messagebox.execute(gui.res.string_vm_creation_description % (min_memory), None, gui.res.caution_sign)
            continue
        if memory < 32:
            dialogbox.messagebox.execute(gui.res.string_vm_allocation_desc, None, gui.res.caution_sign)
            continue

        if disk < min_disk:
            dialogbox.messagebox.execute(gui.res.string_vm_space_desc % (min_disk), None, gui.res.caution_sign)
            continue

        if not volume.vg_exists(vgname):
            dialogbox.messagebox.execute(gui.res.string_domain_desc % (vgname), None, gui.res.caution_sign)
            continue

        return {"hostname":hostname, "vgname":vgname, "memory":memory, "disk":disk}

    return None

class VirtualApplianceDescription(dialogbox.DialogBoxContents):
    def __init__(self, title, image, description, specs):
        self.title = gui.util.render_font_with_shadow(gui.res.font_system.getFont(24), title, (0,0,0), (128, 128, 128))
        self.image = image
        self.description = self.renderText(description) if description != None else None
        self.specs = self.renderText(specs, gui.res.font_system.getFont(16)) if specs != None else None

        items = (self.title, self.image, self.description, self.specs)

        width = max(map(lambda x: x.get_width() if x != None else 0, items))
        height = sum(map(lambda x: x.get_height() if x != None else 0, items)) + (sum(map(lambda x: 1 if x != None else 0, items)) - 1) * 10
        size = (width, height)

        dialogbox.DialogBoxContents.__init__(self, size)
    def draw(self, surface):
        y = 0
        surface.blit(self.title, (0, y))
        y += self.title.get_height() + 10
        if self.image != None:
            surface.blit(self.image, ((surface.get_width() - self.image.get_width()) / 2, y))
            y += self.image.get_height() + 10
        if self.description != None:
            surface.blit(self.description, (0, y))
            y += self.description.get_height() + 10
        if self.specs != None:
            surface.blit(self.specs, (0, y))

def showVirtualApplianceDialog(title, images, description, tarball, minimum_hd, minimum_ram):
    try:
        with dialogbox.messagebox.open(gui.res.string_get_detail):
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
        dialogbox.messagebox.execute(string_cancelled)
        return False
    except http_client.CurlException as e:
        dialogbox.messagebox.execute(gui.res.string_comm_error % (e.getError(), e.getURL()), None, gui.res.caution_sign)
        return False

    buttons = []
    if tarball != None: buttons.append({ "id":"download", "icon":gui.res.icon_ok, "text":gui.res.string_domain_download })
    buttons.append({ "id":"cancel", "icon":gui.res.icon_cancel, "text":string_cancel})
    specs = []
    if contentLength != None: specs.append(gui.res.string_download_capacity % (float(contentLength) / 1024 / 1024))
    if minimum_hd != None: specs.append(gui.res.string_capacity_atleast % minimum_hd)
    if minimum_ram != None: specs.append(gui.res.string_minimum_ram % minimum_ram)

    vad = VirtualApplianceDescription(title, image, description, " ".join(specs))

    return dialogbox.DialogBox(vad, buttons).execute() == "download"

def getVirtualApplianceByCode():
    code = dialogbox.inputbox.TextInputBox(gui.res.string_virtual_appliance_code, "", 5, 32, "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").execute()
    if code == None: return None
    json_url = "http://goo.gl/" + code # e.g. DoIX3

    try:
        with dialogbox.messagebox.open(gui.res.string_code_check):
            rst = http_client.nonblockHttpGet(json_url)
            va = json.loads(rst)
            for key in ["id", "title"]: 
                if not key in va: raise ValueError("Invalid data")
    except ValueError:
        dialogbox.messagebox.execute(gui.res.string_code_not_correct, None, gui.res.caution_sign)
        return None
    except http_client.Cancelled:
        dialogbox.messagebox.execute(string_cancelled)
        return None
    except http_client.CurlException as e:
        dialogbox.messagebox.execute(gui.res.string_comm_error % (e.getError(), e.getURL()), None, gui.res.caution_sign)
        return None

    # architecture check
    required_arch = va["arch"] if "arch" in va else "i686"
    supported_arch = {"i686":["i686"], "x86_64":["i686", "x86_64"]}
    s = system.getSystem()
    arch = s.getArchitectureString()
    if arch not in supported_arch:
        dialogbox.messagebox.execute(gui.res.string_domain_sys_error % arch, None, gui.res.caution_sign)
        return None
    if required_arch not in supported_arch[arch]:
        dialogbox.messagebox.execute(gui.res.string_domain_support_error % (required_arch, arch), None, gui.res.caution_sign)
        return None

    return va

def download_va(id, tarball, minimum_hd, minimum_ram):
    args = edit_new_domain(gui.res.string_create_new_vm, id, minimum_ram, minimum_hd, minimum_ram)
    if args == None: return None
    args["tarball"] = tarball
    return create_new_domain(args)

def main(stackPanel):
    try:
        with dialogbox.messagebox.open(gui.res.string_catalog):
            rst = http_client.nonblockHttpGet(catalog.getURL())
    except http_client.Cancelled:
        dialogbox.messagebox.execute(string_cancelled)
        return False
    except http_client.CurlException as e:
        dialogbox.messagebox.execute(gui.res.string_comm_error % (e.getError(), e.getURL()), None, gui.res.caution_sign)
        return False

    try:
        items = catalog.parse(io.BytesIO(rst))
    except xml.etree.ElementTree.ParseError:
        dialogbox.messagebox.execute(gui.res.string_incorrect_format, None, gui.res.caution_sign)
        return False

    valist = gui.list.List(stackPanel.getSize())
    font = gui.res.font_system.getFont(20)
    valist.addItem(gui.list.TextListItem(gui.res.string_enter_code, font))
    for item in items:
        valist.addItem(gui.list.TextListItem(item["title"], font, None, None, item))
    stackPanel.push(valist)
    try:
        while True:
            rst =  gui.eventLoop(valist)
            if rst == 0:
                va = getVirtualApplianceByCode()
            elif rst != None:
                va = valist.getSelected().getData()
                if "image" in va: va["images"] = [{"url":va["image"]}]
                if "minimum_hd" in va: va["minimum_hd"] = int(va["minimum_hd"])
                if "minimum_ram" in va: va["minimum_ram"] = int(va["minimum_ram"])
            else: break
            if va == None: continue

            title = va["title"]
            images = va["images"] if "images" in va else None
            description = va["description"] if "description" in va else None
            tarball = va["tarball"] if "tarball" in va else None
            minimum_hd = va["minimum_hd"] if "minimum_hd" in va else None
            minimum_ram = va["minimum_ram"] if "minimum_ram" in va else None
            if showVirtualApplianceDialog(title, images, description, tarball, minimum_hd, minimum_ram):
                if download_va(va["id"], tarball, minimum_hd, minimum_ram):
                    return True
    finally:
        stackPanel.pop()
    return False

# -*- coding:utf-8 -*-
from __future__ import absolute_import
import argparse,subprocess,sys,codecs,os
import installer

parser = argparse.ArgumentParser()
parser.add_argument("--gui", action="store_true", help="GUI Installer")
parser.add_argument("--poweroff", action="store_true", help="Power off at exit")
parser.add_argument("--image", type=str, help="System image file to install")
args = parser.parse_args()

if args.gui:
    installer.main(args.image, args.poweroff)
    sys.exit(0)

#else
sys.stdout = codecs.getwriter('utf_8')(sys.stdout)

version = os.uname()[2].split('-',1)[0]

print (u"=== Walbrix %s のインストール " % version) + '=' * (51 - len(version))
print u"Walbrixをインストールするには、wb install と入力して下さい。"
print u"  - 対象のHDDを消去して良いか確認を求められますので yes と入力してください。"
print u"  - インストール対象として選択可能なHDDが複数ある場合は wb install /dev/sda の"
print u"    ようにして、対象となるHDDを指定してください。"
print u"インストールが完了したら、コンピュータを再起動するか電源を切って入れ直して"
print u"下さい。"
print u"  - 電源を切るにはコンピュータの電源ボタンを押すか poweroff と入力します。"
print u"  - 再起動するには、rebootと入力するか Ctrl-Alt-Delを押します。"
print u"  - 次回起動時にはインストールに使用した媒体を取り外して下さい。"
print u"何か問題があれば、フォーラム http://forum.walbrix.net をご覧いただくか、"
print u"Twitterで @wbsupportに質問してください。"
print u"==============================================================================="
print ""
rst = subprocess.call(["/bin/bash"],close_fds=True)

sys.exit(rst)

from __future__ import print_function
import os
import io
import sys
import base64
import traceback

import system
import installer
import resource_loader

usage =""

COMMITID_FILE = "/usr/share/wbui/commit-id"

string_inst_unknown = u"Unknown"
string_inst_shutdown = u"[Press Enter key]"
string_inst_error = u"An error has occurred in Walbrix installer. We regret any inconvenience. If possible, please disclose to us at Twitter @wbsupport photos of this screen."

def setupOptions(parser):
    parser.add_option("-n", "--no-check-source", dest="no_check_source", action="store_true", help="Don't check source media", default=False)
	
def run(options, args):
    exc = None
    try:
        installer.main(options, args)
    except Exception, e:
        exc = traceback.format_exc()
    if exc == None: sys.exit()

    uname = string_inst_unknown
    commit_id = string_inst_unknown
    try:
        uname = " ".join(os.uname())
        if os.path.isfile(COMMITID_FILE):
            with open(COMMITID_FILE) as f:
                commit_id = f.read().strip()
    except:
        pass

    msg = io.BytesIO()
    print(exc.strip(), file=msg)
    print((u"uname=%s, wbui version=%s, commit id=%s\n" % (uname, system.version, commit_id)).encode("utf-8"), file=msg)
    print(string_inst_error.encode("utf-8"), file=msg)
    msg.write(string_inst_shutdown.encode("utf-8"))

    encoded_msg = base64.b64encode(msg.getvalue())

    os.execv("/usr/sbin/wb", ("wb", "show_message_and_wait", encoded_msg))

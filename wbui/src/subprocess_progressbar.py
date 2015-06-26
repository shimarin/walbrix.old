import subprocess
import select
import signal

import gui

class Cancelled(Exception):
    def __init__(self, message):
        Exception.__init__(self, message)

def exec_progressive(cmd, title, line_callback):
    with gui.progressbar.SyncedProgressBar(title) as progressBar:
        proc = subprocess.Popen(cmd, shell=False, stdout=subprocess.PIPE,stderr=subprocess.PIPE,close_fds=True)
        try:
            tick = gui.util.Tick(1000 / gui.getFrameRate())
            progressBar.yieldFrame()
            proc_str = proc.stdout.readline()
            while proc_str:
                if tick.exceeded() or select.select([proc.stdout],[],[], 0) == ([],[],[]):
                    tick.reset()
                    if progressBar.yieldFrame(): # cancel
                        proc.send_signal(signal.SIGINT)
                        break
                if line_callback != None: 
                    progress = line_callback(proc_str.strip())
                    if progress != None: progressBar.setProgress(progress)
                proc_str = proc.stdout.readline()
            proc.stdout.close()
            exit_status = proc.wait()
            if exit_status == 130: raise Cancelled("Cancelled.")
            elif exit_status != 0: 
                err = proc.stderr.read()
                raise Exception(err)
        except Exception, e:
            raise

    

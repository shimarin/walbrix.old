'''
Created on 2011/05/23

@author: shimarin
'''

import vm

usage = ""

def setupOptions(parser):
    pass

def run(options, args):
    v = vm.getVirtualMachineManager()
    vmconfigs = v.listVMConfigs()
    for vmconfig in vmconfigs:
        print vmconfig["name"]

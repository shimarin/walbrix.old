'''
Created on 2011/05/23

@author: shimarin
'''

import vm
import cli

usage = "vmname"

def setupOptions(parser):
    pass

def run(options, args):
    if len(args) < 1: raise cli.Error("VM name must be specified.")

    vmname = args[0]

    v = vm.getVirtualMachineManager()
    print v.determineVMDeviceName(vmname)

# -*- coding: utf-8 -*-
'''
Created on 2011/05/22

@author: shimarin
'''

import string
import system
import vm
import cli

usage = "[options] vmname"

def setupOptions(parser):
    parser.add_option("-f", "--force", dest="force", action="store_true", help="Perform without prompt", default=False)

def run(options, args):
    if len(args) < 1: raise cli.Error("VM name must be specified.")

    vmname = args[0]

    s = system.getSystem()
    v = vm.getVirtualMachineManager()
    
    deviceName = v.determineVMDeviceName(vmname)
    if not s.isBlockSpecial(deviceName): raise cli.Error("Device '%s' is incorrect." % deviceName)
    
    yes = raw_input("Are you really sure to remove VM called '%s'(%s)?\nType 'yes' to proceed:" % (vmname, deviceName))
    if string.lower(yes) != "yes": raise cli.Error("Cancelled.")

    print "Removing Logical Volime '%s'..." % deviceName
    s.removeLogicalVolume(deviceName)    

    print "Removing VM config file..."
    v.removeVMConfigFile(vmname)
    
    print "Done."



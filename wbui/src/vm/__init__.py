# -*- coding: utf-8 -*-

import os
import vm_xen

vmm = vm_xen.Xen()

def setVirtualMachineManager(_vmm):
    global vmm
    vmm = _vmm

def getVirtualMachineManager():
    return vmm

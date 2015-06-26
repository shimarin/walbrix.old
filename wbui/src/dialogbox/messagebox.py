# -*- coding: utf-8 -*-
import pygame
import gui
import dialogbox

def open(text, header_image = None):
    message = dialogbox.DialogBox.MESSAGE(text, header_image)
    myDialog = dialogbox.DialogBox(message)
    return gui.getDesktop().openDialog(myDialog)

def execute(text, buttons = None, header_image = None):
    if buttons == None: buttons = dialogbox.DialogBox.OK()
    message = dialogbox.DialogBox.MESSAGE(text, header_image)
    myDialog = dialogbox.DialogBox(message, buttons)
    return myDialog.execute()

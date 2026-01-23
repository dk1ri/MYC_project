"""
name : ld_command_handling.py
last edited: 20250309
LD commands
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""

import v_logicdevice

def command_0():
    v_logicdevice.inputline = "".join(hex(ord(char)) for char in "0;m;DK1RI,logic device;V01.0;1;145;1;3;1-1")
    return


def command_1():
    v_logicdevice.inputline = "01"
    return


def command_2():
    # this will not send: used to get rules form CR as infos
    return


def command_253():
    v_logicdevice.inputline = "0401"
    return

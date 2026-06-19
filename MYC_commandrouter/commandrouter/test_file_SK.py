"""
name : test_file_SK.py
Author: DK1RI
Version 01.0, 20260601
call with: test_file_SK.py
Purpose :
control the CR using the file-interface test1
enter the command (each byte as 2 byte figures "0" - "9" "A" - "D", upper case)
 and send the command by pressing "enter"
"""
# general
import os
import msvcrt
import time
from time import sleep


def sk_terminal_in(da):
   # getch = msvcrt.getch()
    t = None
    if msvcrt.kbhit():
        t = msvcrt.getwch()

    if t != None:
        if ord(t) == 13:
            if len(da) != 0:
                print ("send", da)
                f = open(to_cr0, "a")
                f.write(da)
                f.close()
                da = ""
            else:
                print("nothing sent")
        else:
            if t >= "0" and t <= "9" or t >= "A" and t <= "F":
                da += t
    return da

print("USE UPPERCASE A - F!")
dir = "file_interface"
# from here write to file (CR)!!!
from_cr0 = dir + "/from_CR0"
# read file (CR) and write here!!!
to_cr0 = dir + "/to_CR0"
da = ""
while 1:
    # read terminal and send
    da = sk_terminal_in(da)
    # read file and print
    if os.path.exists(from_cr0):
        f = open(from_cr0)
        dat = f.readline()
        f.close()
        if len(dat) != 0:
            print ("received: " + dat)
        try:
            os.remove(from_cr0)
        except:
            sleep(.1)
            try:
                os.remove(to_cr0)
            except:
                pass

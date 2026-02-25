"""
name : random.py
Author: DK1RI
Version 01.0, 20260224
call with: ramdom.py (CR must be running)
Purpose :
test programm. generate random data (up to 5 character) sk side
simulate SK
The CR should not chrash
"""
# general
import os
from time import sleep

import random

def write_file(io, dat):
    try:
        f = open(io, "w")
        f.write(dat)
        f.close()
        print (data)
    except:
        pass
    return

def read_file (_io):
    if os.path.exists(io):
        f = open(_io, "r")
        dat = f.readline()
        f.close()
        if len(dat) != 0:
            print ("received: " + dat)
        else:
            print ("command not valid")
        os.remove(_io)
    return

_dir = "./file_interface"
if not os.path.exists(_dir):
    os.mkdir(_dir)

to_sk = _dir + "/to_sk"
from_sk = _dir + "/from_sk"
io = 0
while 1:
    number = random.randint(1, 5)
    i = 0
    data = ""
    while i < number:
        value = random.randint(0, 255)
        data += chr(value)
        i += 1
    write_file(from_sk, data)
    sleep(1)
    read_file(to_sk)

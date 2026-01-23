"""
name : random.py
Author: DK1RI
Version 01.0, 202512
call with: ramdom.py
Purpose :
test programm. generate random data (up to 5 character) for dev and sk side
valid commands are echoed , othrs not
The CR should not chrash
"""
# general
import os
from time import sleep

import random

def write_file(io, dat):
        f = open(io, "w")
        f.write(dat)
        f.close()

def read_file (io):
    if os.path.exists(io):
        f = open(io, "r")
        dat = f.readline()
        f.close()
        if len(dat) != 0:
            print ("received: " + dat)
        else:
            print ("command not valid")
        os.remove(io)

dir = "./file_interface"
if not os.path.exists(dir):
    os.mkdir(dir)

to_dev = dir + "/to_dev"
from_dev = dir + "/from_dev"
to_sk = dir + "/to_sk"
from_sk = dir + "/from_sk"
io = 0
while 1:
    number = random.randint(1, 5)
    i = 0
    while i < number:
        data = ""
        value = random.randint(0, 255)
        data = data + chr(value)
    if io == 0:
        write_file(to_sk)
    else:
        write_file(to_dev)
    sleep(0,1)
    if io == 0:
        read_file(to_dev)
    else:
        read_file(to_sk)

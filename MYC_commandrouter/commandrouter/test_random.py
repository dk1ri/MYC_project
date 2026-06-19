"""
name : random.py
Author: DK1RI
Version 01.0, 20260224
call with: tst_ramdom.py (CR must be running)
Purpose :
test programm. generate random data (up to 5 character) for sk side
simulate SK or a device
The CR should not crash
#The program will hang during init in dev mode, if CR do nogt deliver correct data
"""
# general
import os
import sys
import time

import random
from time import sleep


def write_file(io):
    data_sent = 0
    data = bytearray()
    data.append(random.randint(1, 200))
    number = random.randint(1, 5)
    i = 0
    while i < number:
        data.append(random.randint(0, 255))
        i += 1
    if not os.path.exists(io):
        f = open(io, "wb")
        f.write(data)
        f.close()
        data_sent = 1
    return data_sent

def init_read_file(io_r):
    data = ""
    if os.path.exists(io_r):
        f = open(io_r, "rb")
        data = f.read()
        f.close()
        sleep(0.2)
        if os.path.exists(io_r):
            os.remove(io_r)
    return data

def init_write_file(io, data):
    if not (os.path.exists(io)):
        f = open(io, "wb")
        f.write(data)
        f.close()
    else:
        print("file not removed", io)
        sys.exit()
    return

def initdevice(io, io_r):
    dev_announce = {}
    f = open("./commandrouter_config/announce_for_randomtest_dev", "rb")
    index = 0
    for lines in f.readlines():
        dev_announce[index] = lines
        index += 1
    if os.path.exists(io_r):
        os.remove(io_r)
    if os.path.exists(io):
        os.remove(io)
    last = 0
    all_done = 0
    waitloop = 0
    while waitloop < 10000:
        data = init_read_file(io_r)
        if len(data) > 0:
            if data[0] == 0xfd:
                init_write_file(io, bytes([0xfd,0x04]))
            elif data[0] == 0x00:
                init_write_file(io, "$0;m;DK1RI;test3;V01.0;1;124;1;122;1-1".encode("utf-8"))
            elif data[0] == 0xf0:
                announce_number = data[1]
                if announce_number < 122:
                    l = len(dev_announce[announce_number])
                    d = bytes([0xF0, announce_number, 1, l])
                    d += dev_announce[announce_number]
                    sleep(.1)
                    init_write_file(io,d)
                else:
                    print("wrong data", data)
                    sys.exit()
            elif data[0] == 0xff:
                if data[1] == 0:
                    init_write_file(io, bytes([0xff,0x00,0x02,0x74,0x31]))
                elif data[1] == 1:
                    init_write_file(io, bytes([0xff, 0x31]))
                    waitloop = 1
        if waitloop > 0:
            waitloop += 1
    return

_dir = "./file_interface"
if not os.path.exists(_dir):
    os.mkdir(_dir)
if sys.argv[1] == "sk":
    io = _dir + "/from_sk"
elif sys.argv[1] == "dev":
    io = _dir + "/from_test1"
    io_r = _dir + "/to_test1"
    initdevice(io, io_r)
else:
    print("test_random dev or test_random sk")
    sys.exit()
j = 0
print ("start random")
sent = 0
t = time.time()
sleep(1)
while 1:
    sent = write_file(io)
    if sent == 1:
        j += 1
        sent = 0
    if j == 1000:
        print(time.time() - t)
        t = time.time()
        j = 0
    sleep(0.2)

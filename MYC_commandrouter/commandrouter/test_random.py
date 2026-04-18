"""
name : random.py
Author: DK1RI
Version 01.0, 20260224
call with: tst_ramdom.py (CR must be running)
Purpose :
test programm. generate random data (up to 5 character) for sk side
simulate SK
The CR should not crash
"""
# general
import os
import sys
import time

import random

def write_file(io, data_sent, data):
    if data_sent == 0:
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
        print(data)
    return data_sent, data

_dir = "./file_interface"
if not os.path.exists(_dir):
    os.mkdir(_dir)

if sys.argv[1] == "sk":
    io = _dir + "/from_sk"
elif sys.argv[1] == "dev":
    io = _dir + "/from_test1"
else:
    print("test_random dev or test_random sk")
    sys.exit()
j = 0
sent = 0
data = bytes()
t = time.time()
while 1:
    sent, data = write_file(io, sent, data)
    if sent == 1:
        j += 1
        sent = 0
    if j == 1000:
        print(time.time() - t)
        t = time.time()
        j = 0

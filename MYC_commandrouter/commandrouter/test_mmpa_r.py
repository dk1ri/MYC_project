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
from time import sleep

import mmap

import v_io


def mmap_io(filename):
    with open(filename, mode="r", encoding="utf8") as file_obj:
        with mmap.mmap(file_obj.fileno(), length=0, access=mmap.ACCESS_READ) as mmap_obj:
            text = mmap_obj.read()
            print(text)
    return
j = 0
while 1:
    mmap_io("test")
    sleep(0.2)

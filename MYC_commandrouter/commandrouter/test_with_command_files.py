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
import sys


def read_command_file(file_name):
    if os.path.exists(file_name):
        command_file_data = []
        f = open(file_name, "r")
        for line in f:
            if line[0] != "#":
                command_file_data.append(line)
    else:
        print("commandfile missing")
        sys.exit()
    return command_file_data

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
    if os.path.exists(_io):
        f = open(io, "r")
        dat = f.readline()
        f.close()
        if len(dat) != 0:
            print ("received: " + dat)
        else:
            print ("command not valid")
        os.remove(_io)
    return

if len(sys.argv) == 2:
    c_file = "commandfiles/"+ sys.argv[1]
    print(c_file)
else:
    print("commandfile missing")
    sys.exit()
command_file_data = read_command_file(c_file)
print("comandfile and the used announcement testfile must habe the same name")
print ("CR must run!!")
print(" ")
_dir = "./file_interface"
if not os.path.exists(_dir):
    os.mkdir(_dir)

to_sk = _dir + "/to_sk"
from_sk = _dir + "/from_sk"
io = 0
i = 0
element = 0
while i < len(command_file_data):
    match element:
        case 0:
            print("line of command file ", i)
            print(command_file_data[i].rstrip())
        case 1:
            print ("send: " + command_file_data[i].rstrip())
            data = command_file_data[i].rstrip()
            write_file(from_sk, data)
            sleep(1)
            read_file(to_sk)
        case 3:
            print ("should be: " + command_file_data[i])
        case 4:
            print(command_file_data[i])
            print(" ")
    element += 1
    if element == 4:
        element = 0
    i += 1
    sleep(1)

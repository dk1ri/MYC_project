"""
name : misc_functions.py
last edited: 202512
misc functions
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""

import time
import os
import v_cr_params
import v_configparameter
import v_ld
import v_sk


def str_to_bytearray(string):
    # for string s: length with length l
    c = bytearray([])
    i = 0
    while i < len(string):
        c.extend(bytearray([ord(string[i])]))
        i += 1
    return c


def ba_to_str(ba):
    # bytearray to string
    string = ""
    i = 0
    while i < len(ba):
        string += str(ba[i])
        i += 1
    return string


def ba_to_str2(ba):
    string = ""
    i = 0
    while i < len(ba):
        string += chr(ba[i])
        i += 1
    return string


def integerstring_to_ba(string):
    # convert a string of 1 byte integers, separateted by space, to a bytearray
    c = bytearray([])
    i = 0
    tempi = ""
    while i < len(string):
        temp = string[i]
        if temp == " ":
            c.extend(bytearray([(int(tempi))]))
            tempi = ""
        else:
            tempi += temp
        i += 1
    if tempi != "":
        c.extend(bytearray([(int(tempi))]))
    return c


def add_length_to_str(string, length):
    # add the length of a string to the start
    # the length of "length" depend on calling parameter length
    return int_to_bytes(len(string), length) + string


def add_length_to_ba(ba, l):
    # add the length of a (string) bytearray to the start
    # the length of "length" depend on calling parameter l
    b = []
    # bytearray with length
    b.extend(map(ord, int_to_bytes(len(ba), l)))
    return b.extend(ba)


def length_of_int(i):
    # return the number of bytes to be used ( 1, 2, 3, 4) depending on i
    if i > 0xFFFFFFFF:
        return 5
    if i > 0xFFFFFF:
        return 4
    elif i > 0xFFFF:
        return 3
    elif i > 0xFF:
        return 2
    else:
        return 1


def int_to_bytes(integ, length):
    # convert a integer to a string of bytes (0-255)
    # length 0: use CR tokenlength
    if length == 0:
        length = v_cr_params.length_commandtoken
    s = ""
    i = 0
    while i < length:
        s += chr(integ & 0xFF)
        integ >>= 8
        i += 1
    # reverse
    s2 = ""
    i = 0
    while i < length:
        s2 += s[length - i - 1]
        i += 1
    return s2


def int_to_ba(integ, length):
    # convert a integer to a bytearray of of int (0-255) with a length  ( 1, 2, 4, 8 )
    # length 0: use CR tokenlength
    if length == 0:
        length = v_cr_params.length_commandtoken
    ba = bytearray([])
    i = 0
    while i < length:
        ba.append(0)
        i += 1
    i = 0
    while i < length:
        ba[length - i - 1] = integ & 0xFF
        integ >>= 8
        i += 1
    return ba


def bytes_to_int_ba(ba):
    i = len(ba) - 1
    z = 1
    temp = 0
    while i >= 0:
        temp += ba[i] * z
        z *= 256
        i -= 1
    return temp


def device_length_of_commandtoken(number):
    # for devices only
    # number is highest tokennumber of other devices with a device for check with given value
    multi = 256
    # length_of_commandtoken:
    length_commandtoken = 1
    while number + 16 >= multi:
        multi = multi * 256
        length_commandtoken += 1
    return length_commandtoken


def length_of_typ(c_type):
    # c_type is parameter - type: a, b, L d, .... or number for string
    # return 1st element: n|s   2nd element: length of parameter or length of stringlength, 3rd element: max value
    # without <des>
    if c_type in v_cr_params.length_of_par:
        # as lin,...
        return "n", v_cr_params.length_of_par[c_type], v_cr_params.max_of_par[c_type]
    if c_type == "c":
        # commands
        return "n", v_cr_params.length_commandtoken,
    else:
        # string
        return "s", length_of_int(int(c_type)), int(c_type)

def write_log(line):
    # remove after tests
    with open(v_configparameter.logfile) as file:
        i = len(file.readlines())
    if i > v_configparameter.max_log_lines:
        os.remove(v_configparameter.logfile)
    if v_configparameter.test_mode == 1:
        print(line)
    handle = open(v_configparameter.logfile, "a")
    handle.write(str(time.time()) + " " + line + "\n")
    handle.close()
    return


def strip_des_chapter(announcement):
    # strip <des> and CHAPTER
    # returns list
    i = 0
    a = announcement.split(";")
    stripped = []
    while i < len(a):
        drop = 0
        item = a[i].split(",")
        if len(item) > 1:
            if (item[1] == "CHAPTER"):
                drop = 1
        if drop == 0:
            stripped.append(item[0])
        i += 1
    return stripped


def stacklength(stripped):
    # return the number of bytes required for stacks if stack is > 1
    stacks = int(stripped[2])
    # value 0 is not allowed -> 1; transmitted value i "0" based:
    if stacks == 0:
        stacks = 1
    stacks -= 1
    if stacks == 0:
        # nothing transmitted
        stack_length = 0
    else:
        stack_length = length_of_int(stacks)
    return  stacks, stack_length

def finish_sk(input_device, to_ld):
    # transfer data
    # send command to LD as listelement containing data for one command
    if to_ld == 1:
        v_ld.from_sk_to_ld.extend(v_sk.inputline[input_device][:v_sk.len[input_device][0]])
        print ("to ld ")
        print (v_ld.from_sk_to_ld)
    # reset some values of v_sk after command finished
    v_sk.inputline[input_device] = v_sk.inputline[input_device][v_sk.len[input_device][0]:]
    v_sk.len[input_device] = [0,0,0,0,0,0,0]
    v_sk.starttime[input_device] = 0
    # avoid channel timeout
 #   if v_sk.multi_channel == 1:
  #      v_sk.channel_timeout[input_device] = time.time()
  #  if len(v_sk.inputline[input_device]) > v_cr_params.sk_buffer_limit_low:
   #     if len(v_sk.inputline[input_device]) > v_cr_params.sk_buffer_limit:
    #        v_sk.active[input_device] = 2
   # else:
    #    v_sk.active[input_device] = 1
    return
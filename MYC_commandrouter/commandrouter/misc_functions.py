"""
name : misc_functions.py
last edited:
misc functions
"""

import time

import v_cr_params
import v_configparameter


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
    # return the number of bytes to be used ( 1, 2, 3) depending on i
    k = 256
    l = 256
    j = 1
    while l - 1 < i:
        l *= k
        j += 1
    return j


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


def calculate_length_of_commandtoken(number):
    # for CR only
    # number is highest tokennumber of other devices in full CR announcelist
    multi = 256
    # length_of_commandtoken:
    v_cr_params.length_commandtoken = 1
    # avoid 0 as first byte:
    v_cr_params.startnumber = 1
    while number + 32 >= multi:
        multi = multi * 256
        v_cr_params.startnumber = v_cr_params.startnumber * 256
        v_cr_params.length_commandtoken += 1
    # adder for 0hxxFx commands: n + f0 = 0hxxf0
    v_cr_params.adder = multi - 0x100
    # reserved commandtoken last 16 reserved
    v_cr_params.reserved_token_start = multi - 0x10

    v_cr_params.startindex = v_cr_params.startnumber - 1
    return


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
    # c_type is parameter - type: a, b, L d, .... or numner for string
    # return 1st element: n|s|e   2nd element: length of parameter or length of stringlength, 3rd element: max value
    if c_type == "c":
        # commands
        return "n", v_cr_params.length_commandtoken
    else:
        try:
            # numeric: temp[1]: parameterlength
            return "n", v_cr_params.length_of_par[c_type],v_cr_params.max_of_par[c_type]
        except KeyError:
            # string
            try:
                # temp[1] length of stringlength
                return "s", length_of_int(int(c_type)), int(c_type)
            except ValueError:
                # error
                Exit("length of typ error ",ctype)

def write_log(line):
    # remove after tests
    if v_configparameter.test_mode == 1:
        print(line)
    handle = open(v_configparameter.logfile, "a")
    handle.write(str(time.time()) + " " + line + "\n")
    handle.close()
    return


def strip_dimension(announcement):
    #strip <des>
    i = 0
    stripped = announcement.split(";")
    number_of_items = 0
    while i < len(stripped):
        item = stripped[i].split(",")
        if len(item) > 1:
            if (item[1] != "DIMENSION") and (item[1] != "CHAPTER"):
                number_of_items += 1
        else:
            number_of_items += 1
        stripped[i] = item[0]
        i += 1
    return number_of_items, stripped


def stacklength(stripped):
    # return the number of bytes required for stacks if stack is > 1
    stacks = int(stripped[2])
    # value 0 is not allowed -> 1; transmitted value i "0" based:
    if stacks == 0:
        stacks = 1
    stacks -= 1
    if stacks == 0:
        stack_length = 0
    else:
        stack_length = length_of_int(stacks)
    return  stacks, stack_length
"""
name : misc_functions.py
last edited: 20190312
misc functions
"""

import time

import v_Ic7300_vars

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

def add_length_to_str(string, length):
    # add the length of a string to the start
    # the length of "length" depend on calling parameter length
    return int_to_bytes(len(string), length) + string

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

def write_log(line):
    #check number of lines
    handle = open(v_Ic7300_vars.log_file)
    i = 0
    log = []
    for lines in handle:
        log.append(lines)
        i += 1
    handle.close()
    if i > v_Ic7300_vars.logfilesize:
        # delete 23 %
        handle = open(v_Ic7300_vars.log_file, "w")
        pos = i // 1.3
        pos = int(pos)
        while pos < i:
            handle.write(log[pos])
            pos += 1
        handle.close()
    temp = time.asctime(time.localtime(time.time())) + " messagenumber: " + str(v_Ic7300_vars.error_cmd_no) + " : " + line
    if v_Ic7300_vars.test_mode == 1:
        print(temp)
    handle = open(v_Ic7300_vars.log_file, "a")
    handle.write(temp + "\n")
    handle.close()
    return

def bcd_to_int(a):
    # 0 - 99 bcd
    temp1 = (a >> 4) * 10 + (a & 0x0F)
    return temp1

def bcd_to_int2(a):
    # 0 - 9999 bcd (2 byte ba) to int
    temp1 = a[0]
    temp1 = (temp1 >> 4) * 10 + (temp1 & 0x0F)
    temp2 = temp1 * 100
    temp1 = a[1]
    temp1 = (temp1 >> 4) * 10 + (temp1 & 0x0F)
    return temp1 + temp2

def bcd_to_ba_2(a, adder):
    # 0 - 9999 bcd (2 byte bcd to 2 byte ba)
    temp1 = a[0]
    temp1 = ((temp1 >> 4) * 10 + (temp1 & 0x0F)) * 100
    temp2 = a[1]
    temp1 += (temp2 >> 4) * 10 + (temp2 & 0x0F) + adder
    return bytearray([temp1 // 256, temp1 % 256])

def int_to_bcd(a, figures):
    # return ba
    bcd = bytearray([])
    if figures == 2:
        b = a // 100
        temp1 = (b//10 * 16) + b % 10
        bcd.extend(bytearray([temp1]))
        a = a % 100
    temp1 = (a // 10 * 16) + a % 10
    bcd.extend(bytearray([temp1]))
    return bcd

def int_to_bcd_int(a):
    # return 1 byte (< 256) int
    bcd = (a // 10 * 16) + a % 10
    return bcd

def int_to_3bcd(a):
    # return ba
    instr = str(a)
    length = len(instr)
    temp1 = 1
    s  = ""
    zeros = 7 - length
    while temp1 < 7:
        if temp1 < zeros:
            s += "0"
        else:
            s += instr[temp1 - zeros]
        temp1 += 1
    bcd = bytearray([0x00,0x00,0x00])
    temp = int(s[4:6])
    bcd[0] = (temp // 10 * 16) + temp % 10
    temp = int(s[2:4])
    bcd[1] = (temp // 10 * 16) + temp % 10
    temp  = int(s[0:2])
    bcd[2] = (temp // 10 * 16) + temp % 10
    return bcd

def int_to_bcd_plusminus(line, max, bcdbytes, multiplier):
    # max is maximum for abs value -> max_int = 2 * max (0 base)
    # for 2 byte int values
    # for bcdbytes bcd digits, bcd reverse: low byte first
    int_value = line[2] * 256 +line[3]
    if int_value > 2 * max:
        return 2, 0
    if int_value > max:
        # positive
        int_value -= max
        negative = 0
    else:
        # 0 is negative
        int_value = max - int_value
        negative = 1
    int_value *= multiplier
    decimal_string = str(int_value)
    digits = [int(c) for c in decimal_string]
    civ_byte = 0
    source = len(digits)
    temp = bytearray([])
    while civ_byte < bcdbytes:
        # high nibble
        if source > 1:
            temp1 = int(digits[source - 2]) * 16
        else:
            temp1 = 0
        # add low nibble
        if source > 0:
            temp1 += int(digits[source - 1])
            temp.extend(bytearray([temp1]))
            source -= 2
        else:
            temp.extend(bytearray([0x00]))
        civ_byte += 1
    temp.extend(bytearray([negative]))
    return 1, temp

def bcd_plusminus_to_int(line, start, max, bcdbytes, commandbytes, divisor):
    # bcdbytes bcd values (lsb first) + polarity
    # convert to commandbytes bytes ba
    temp1 = start
    intvalue = 0
    multiplier = 1
    while temp1 < (start + bcdbytes):
        temp2 = bcd_to_int(line[temp1])
        intvalue = intvalue + multiplier * temp2
        multiplier *= 100
        temp1 += 1
    intvalue //= divisor
    if line[start + bcdbytes] == 0:
        intvalue += max
    else:
        intvalue = max - intvalue
    temp1 = int_to_ba(intvalue, commandbytes)
    return temp1

def cwchars(cw, keyer):
    ok = 0
    if 0x2f < cw < 0x3a or 0x40 < cw < 0x5b:
        ok = 1
    if keyer == 1:
        # for cw messages
        if  cw in [0x20, 0x2a, 0x2c, 0x2e, 0x2f, 0x3f, 0x40, 0xff, 0x5e]:
            ok = 1
    elif keyer == 2:
        # for memory keyer
        if cw in  [0x20, 0x2a, 0x2c, 0x2e, 0x2f, 0x3f, 0x40, 0x5e]:
            ok = 1
    else:
        # for name
        if 0x60 < cw < 0x7f or 0x20 < cw < 0x30 or 0x39 < cw < 0x41 or 0x5aa < cw < 0x61:
            ok = 1
    return ok
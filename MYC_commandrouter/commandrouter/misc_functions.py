"""
name : misc_functions.py
last edited: 20260224
misc functions
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""

import os
from lib2to3.fixes.fix_print import FixPrint

from buffer_handling import *
from command_handling import *

import v_announcelist
import v_cr_params
import v_configparameter
import v_ld
import v_linelength
import v_sk
import v_token_params
import v_time_values

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
    # for positions etc
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
        length = v_announcelist.length_of_full_elements
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
        length = v_announcelist.length_of_full_elements
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
        return "n", v_announcelist.length_of_full_elements,
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
            if item[1] == "CHAPTER":
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

def split_rule(line):
    typ = " IF"
    if " UNLESS " in line:
        typ = " UNLESS "
    li_ = line.split(typ)
    left = li_[0]
    if len(li_) > 1:
        right = li_[1]
    else:
        right = ""
    return left, right, typ

def split_input_line_for_oa(tok, input_):
    # for sk / dev to ld: list of hex parameters
    # split tok
    # for oa aa only: convert numeric to int for use by LD
    # oa aa only
    # strip tok
    ct = v_announcelist.full[tok][1].split(",")[0]
    if ct == "oa" or ct == "aa":
        if len(v_linelength.command[tok]) == 5:
            # no position: one parameter
            if v_announcelist.full[tok][2].split(",")[0].isdigit:
                # string
                result = input_
            else:
                # numeric
                result = int.from_bytes(input_)
        else:
            # more than one parameter
            pos_len = v_linelength.command[tok][3]
            pos = int.from_bytes(input_[:pos_len])
            # strip pos_len
            input_ = input_[pos_len:]
            result = [pos]
            pos_in_linelength = 4 + pos * 3
            n_s = v_linelength.command[tok][pos_in_linelength]
            print ("n_s",n_s)
            if n_s == 0:
                result.append(int.from_bytes(input_))
            else:
                result.append(input_[v_announcelist.length_of_full_elements:])
    else:
        result = input_
    print("result",result)
    return result

def default_data():
    for tok in v_ld.right_tok:
        ct = v_announcelist.full[tok][1]
        announce = v_announcelist.full[tok][2:]
        # nothing done for "ou", "oo", "xm", "xn" and "xf"
        if not tok in v_ld.actual_status:
            v_ld.actual_status[tok] = {}
        match ct:
            case "os" | "as" | "rs" | "ss":
                # less than 256 positions only
                if int(announce[0]) == 1:
                    # no stack
                    v_ld.actual_status[tok] = -1
                    if tok in v_token_params.o_to_a:
                        v_ld.actual_status[v_token_params.o_to_a[tok]] = -1
                    if tok in v_token_params.a_to_o:
                        v_ld.actual_status[v_token_params.a_to_o[tok]] = -1
                else:
                    # with stack
                    stack = 0
                    while stack < int(announce[0]):
                        v_ld.actual_status[tok][stack] = -1
                        if tok in v_token_params.o_to_a:
                            v_ld.actual_status[v_token_params.o_to_a[tok]][stack][stack] = -1
                        if tok in v_token_params.a_to_o:
                            v_ld.actual_status[v_token_params.a_to_o[tok]][stack][stack] = -1
                        stack += 1
            case "or" | "ar" | "rr"| "sr":
                if int(announce[0]) == 1:
                    # no stack
                    pos = 0
                    while pos < len(announce) - 1:
                        v_ld.actual_status[tok][pos] = -1
                        if tok in v_token_params.o_to_a:
                            v_ld.actual_status[v_token_params.o_to_a[tok]][pos] = -1
                        if tok in v_token_params.a_to_o:
                            v_ld.actual_status[v_token_params.a_to_o[tok]][pos] = -1
                        pos += 1
                else:
                    # with stack
                    stack = 0
                    while stack < int(announce[0]):
                        v_ld.actual_status[tok][stack] = []
                        pos = 0
                        while pos < len(announce) -1:
                            v_ld.actual_status[tok][stack].append([])
                            v_ld.actual_status[tok][stack][pos] = -1
                            if tok in v_token_params.o_to_a:
                                v_ld.actual_status[v_token_params.o_to_a[tok]][stack][pos] = -1
                            if tok in v_token_params.a_to_o:
                                v_ld.actual_status[v_token_params.a_to_o[tok]][stack][pos] = -1
                            pos += 1
                        stack += 1

            case "op" |"ap"  | "rp"| "sp":
                if int(announce[0]) == 1:
                    # no stack
                    k = 0
                    p = 1
                    while p < len(announce):
                        # all values
                        v_ld.actual_status[tok][k] = -1
                        if tok in v_token_params.o_to_a:
                            v_ld.actual_status[v_token_params.o_to_a[tok]][k]= -1
                        if tok in v_token_params.a_to_o:
                            v_ld.actual_status[v_token_params.a_to_o[tok]][k] = -1
                        k += 1
                        p += 3
                else:
                    # with stack
                    stack = 0
                    while stack < int(announce[0]):
                        if not stack in v_ld.actual_status[tok]:
                            v_ld.actual_status[tok][stack] = {}
                        k = 0
                        p = 1
                        while p < len(announce):
                            v_ld.actual_status[tok][stack][k] = -1
                            if tok in v_token_params.o_to_a:
                                v_ld.actual_status[v_token_params.o_to_a[tok]][stack][k] = -1
                            if tok in v_token_params.a_to_o:
                                v_ld.actual_status[v_token_params.a_to_o[tok]][stack][k] = -1
                            k += 1
                            p += 3
                        stack += 1

            case "oa" | "aa"  | "ra"| "sa":
                pos = 0
                while pos < len(announce):
                    c_type, length, c = length_of_typ(announce[pos])
                    if c_type == "s":
                        v = ""
                    else:
                        v = -1
                    v_ld.actual_status[tok][pos] = v
                    if tok in v_token_params.o_to_a:
                        v_ld.actual_status[v_token_params.o_to_a[tok]][pos] = v
                    if tok in v_token_params.a_to_o:
                        v_ld.actual_status[v_token_params.a_to_o[tok]][pos] = v
                    pos += 1
    return

def create_len_of_string_length():
    # for xa und xb commands only
    for tok in v_announcelist.full:
        line = v_announcelist.full[tok]
        ct =  line[1].split(",")[0]
        if ct == "oa" or ct == "aa" or ct == "ob" or ct == "ab":
            i = 2
            if not tok in v_announcelist.string_length_ab:
                v_announcelist.string_length_ab[tok] = []
            while i < len(line):
                val = line[i].split(",")[0]
                if val.isdigit():
                    val = int(val)
                    v_announcelist.string_length_ab[tok].append(val)
                else:
                    v_announcelist.string_length_ab[tok].append(-1)
                i  += 1
    return

def handle_check():
    # handling of commandfiles
    # for auto # delete!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if v_time_values.terminal == 255:
        # find terminal
        j = 0
        while j < len(v_sk.interface_type):
            j += 1
            if v_sk.interface_type[j - 1] == "TERMINAL":
                v_time_values.terminal = j
    if v_time_values.terminal == 255:
        v_time_values.auto = 0
        v_time_values.part = 0
        print("no Terminal found")
        return
    while v_time_values.check_number < len(v_time_values.from_sk):
        v_sk.inputline[v_time_values.terminal] = bytearray([])
        v_sk.len[v_time_values.terminal] = [0,0,0,0,0,0,0]
        v_sk.starttime[v_time_values.terminal] = 0
        # avoid user timeout
        # avoid user timeout
        v_sk.channel_timeout[v_time_values.terminal] = time.time()
        v_time_values.part = 1
        v_time_values.data = bytearray([])

        # line 1 and 2
        v_time_values.check_line_finished = 0
        print("")
        print(v_time_values.check_number,"announcement: ", v_time_values.announcement[v_time_values.check_number])
        v_time_values.last_checktime = time.time()
        v_sk.inputline[v_time_values.terminal] = v_time_values.from_sk[v_time_values.check_number]
        tok = 0
        if v_time_values.from_sk[v_time_values.check_number][0] != 0:
            tok = int.from_bytes(v_time_values.from_sk[v_time_values.check_number][:v_announcelist.length_of_full_elements], byteorder='big', signed=False)
        # find corresponding output device
        v_time_values.out_device = 0
        if tok != 0:
            if tok < v_cr_params.number_of_commands_noCR:
                # normal cr_commands
                v_time_values.out_device = v_token_params.device[tok]
            else:
                v_time_values.out_device = v_token_params.device[v_token_params.index_of_cr_commands[tok]]

        poll_input_buffer()
        # fehlt? send_to_ld()
        send_to_device()
        # next: check data to device:
        # line 3: check data to dev
        if v_time_values.data == v_time_values.to_dev[v_time_values.check_number]:
            v_time_values.all += 1
            if v_time_values.errormsg[v_time_values.check_number] == "should be ok":
                v_time_values.number_of_ok += 1
                print("ok", v_time_values.errormsg[v_time_values.check_number])
            else:
                if v_time_values.errormsg[v_time_values.check_number] == "should produce an error":
                    v_time_values.number_of_ok_nok += 1
                    print ("should produce an error, but is ok")
                else:
                    if v_time_values.errormsg[v_time_values.check_number] != "":
                        print("wrong errormsg")
        else:
            print(v_time_values.check_number, "to_dev nok:", v_time_values.data,v_time_values.to_dev[v_time_values.check_number])
            v_time_values.all += 1
            if v_time_values.errormsg[v_time_values.check_number] == "should produce an error":
                v_time_values.number_of_ok += 1
                print("ok",v_time_values.errormsg[v_time_values.check_number])
            else:
                if v_time_values.errormsg[v_time_values.check_number] == "should be ok":
                    v_time_values.number_of_nok += 1
                    print("should be ok, but is nok")
                else:
                    if v_time_values.errormsg[v_time_values.check_number] != "":
                        print("wrong errormsg")

        v_time_values.check_number += 1

    else:
        # stop
        v_time_values.auto = 0
        print("commands from file finished. ok:",v_time_values.number_of_ok, "of:",v_time_values.all, " Number of errors:", v_time_values.number_of_nok, "number of wrong errors:", v_time_values.number_of_ok_nok)

    return

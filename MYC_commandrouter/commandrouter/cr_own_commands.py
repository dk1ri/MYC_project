"""
name: cr_own_commands.py
last edited: 201803
handling of commands for CR
line contain complete data
output to v_sk_info_to_all
"""


import time

from misc_functions import *

import v_cr_params
import v_announcelist
import v_linelength
import v_sk
import v_token_params

# answers of all CR own command are send directly to SK (not via LD -> return 2

def com240(line, token, input_device):
    le = v_cr_params.length_commandtoken + 2 * v_announcelist.length_of_full_elements
    if len(line) < le:
        return 0
    v_sk.len[input_device][0] = le
    tok = v_token_params.index_of_cr_commands[token]
    temp = v_cr_params.length_commandtoken + v_linelength.command[tok][5]
    start_line = int.from_bytes(line[v_cr_params.length_commandtoken:temp], byteorder='big', signed=False)
    if start_line >= v_announcelist.length_of_full_elements:
        write_log("startline for announcecommand too high: " + str(start_line) + " should be " + str(v_announcelist.full_elements))
        # bytes to delete:
        v_sk.len[input_device][0] =le
        return 2
    number_of_lines = int.from_bytes(line[temp: temp + v_linelength.command[tok][5]], byteorder='big', signed=False)
    if number_of_lines > v_announcelist.full_elements:
        write_log("number of lines for announcecommand too high: " + str(number_of_lines) + " should be " + str(v_announcelist.full_elements))
        # bytes to delete:
        v_sk.len[input_device][0] = le
        return 2
    output = int_to_ba(token + v_cr_params.adder, v_cr_params.length_commandtoken)
    i = 0
    while i < number_of_lines:
        item = v_announcelist.full[start_line].split(";")
        if len(item) > 1:
            item1 = item[1].split(",")
            if item1[0][0] == "r" or item1[0][0] == "s":
                # empty string for r and s commands
                output.extend(int_to_ba(0, v_linelength.command[tok][5]))
            else:
                strl = len(v_announcelist.full[start_line])
                output.extend(int_to_ba(strl, v_linelength.command[tok][5]))
                output.extend(str_to_bytearray((v_announcelist.full[start_line])))
        i += 1
        start_line += 1
        if start_line >= v_linelength.command[tok][4]:
            # end of memory
            start_line = 0
    v_sk.info_to_all.extend(output)
    # bytes to delete:
    v_sk.len[input_device][0] = le
    return 2


def com241(line, token, input_device):
    le = v_cr_params.length_commandtoken + 2 * v_announcelist.length_of_basic_elements
    if len(line) < le:
        return 0
    v_sk.len[input_device][0] = le
    tok = v_token_params.index_of_cr_commands[token]
    temp = v_cr_params.length_commandtoken + v_linelength.command[tok][5]
    start_line = int.from_bytes(line[v_cr_params.length_commandtoken:temp], byteorder='big', signed=False)
    if start_line >= v_announcelist.length_of_basic_elements:
        write_log("startline for basic announcecommand too high: " + str(start_line) + " should be " + str(v_announcelist.basic_elements))
        # bytes to delete:
        v_sk.len[input_device][0] = le
        return 2
    number_of_lines = int.from_bytes(line[temp: temp + v_linelength.command[tok][5]], byteorder='big', signed=False)
    if number_of_lines > v_announcelist.basic_elements:
        write_log("number of lines for announcecommand too high: " + str(number_of_lines) + " should be " + str(v_announcelist.basic_elements))
        # bytes to delete:
        v_sk.len[input_device][0] = le
        return 2
    output = int_to_ba(token + v_cr_params.adder, v_cr_params.length_commandtoken)
    i = 0
    while i < number_of_lines:
        strl = len(v_announcelist.full[start_line])
        output.extend(int_to_ba(strl, v_linelength.command[tok][5]))
        output.extend(str_to_bytearray((v_announcelist.basic[start_line])))
        i += 1
        start_line += 1
        if start_line >= v_linelength.command[tok][4]:
            # end of memory
            start_line = 0
    v_sk.info_to_all.extend(output)
    # bytes to delete:
    v_sk.len[input_device][0] = le
    return 2


def com249(line, token, input_device):
    # 249;oa,SK-FEATURE;255,ANSWERS
    # Answers in announcement: 255 -> 1 Byte
    if len(line) < v_cr_params.length_commandtoken + v_cr_params.length_of_c_249_elements:
        print("249_1", v_cr_params.length_commandtoken + v_cr_params.length_of_c_249_elements)
        return 0
    length = int.from_bytes(line[v_cr_params.length_commandtoken:v_cr_params.length_commandtoken + v_cr_params.length_of_c_249_elements], byteorder='big', signed=False)
    v_sk.len[input_device][0] = v_cr_params.length_commandtoken + 1 + v_cr_params.length_of_c_249_elements
    if length > v_cr_params.c_249_elements:
        write_log("length of string of 249 command too high: " + str(length) + "should be: "+ str(v_cr_params.c_249_elements))
        return 2
    v_sk.len[input_device][0] += length
    if len(line) < v_sk.len[input_device][0]:
        print("249_2",v_sk.len[input_device][0] )
        return 0
    # missing : user
    v_sk.len[input_device][0] = v_cr_params.length_commandtoken
    return 2


def com251(line, token, input_device):
    # 251;ob,LOGON;b,mode;20,name;20,password
    # ##############################
    # not ready
    # data must be send to RU
    # ################################
    # start, elements and 1 additional byte required as min
    if len(line) < v_cr_params.length_commandtoken + 2:
        return 0
    start = int.from_bytes(line[v_cr_params.length_commandtoken:(v_cr_params.length_commandtoken + 1)], byteorder='big', signed=False)
    elements = int.from_bytes(line[v_cr_params.length_commandtoken + 1:(v_cr_params.length_commandtoken + 2)], byteorder='big', signed=False)
    if start > 3 or elements > 3:
        write_log("logon values too high " + str(start) + str(elements) + "should be 3" )
        v_sk.len[input_device][0] = v_cr_params.length_commandtoken + 2
        return 2
    i = start
    j = 0
    mode = 0
    name = ""
    password = ""
    # point to firstlement
    pointer = v_cr_params.length_commandtoken + 2
    length_of_activ_input = v_cr_params.length_commandtoken + 2
    # set length of name /passwd
    set_length = 0
    while j < elements:
        if len(line) > pointer:
            if i == 2:
                if set_length == 2:
                    password = ba_to_str(line[pointer:pointer + passwordlength])
                    i = 0
                    set_length = 0
                elif set_length == 1:
                    passwordlength = ord(line[pointer:(pointer + 1)])
                    if passwordlength >  v_cr_params.c_251_password_length:
                        write_log("password too long")
                        v_sk.len[input_device][0] = length_of_activ_input
                        return 2
                    pointer += passwordlength
                    length_of_activ_input += passwordlength
                    set_length = 2
                else :
                    pointer += 1
                    length_of_activ_input += 1
                    set_length = 1

            elif i == 1:
                if set_length == 2:
                    name = ba_to_str(line[pointer:pointer + namelength])
                    i = 2
                    set_length = 0
                elif set_length == 1:
                    namelength = ord(line[pointer:(pointer + 1)])
                    if namelength >  v_cr_params.c_251_name_length:
                        write_log("name too long")
                        v_sk.len[input_device][0] = length_of_activ_input
                        return 2
                    pointer += namelength
                    length_of_activ_input += namelength
                    set_length = 2
                else :
                    pointer += 1
                    length_of_activ_input += 1
                    set_length = 1

            elif i == 0:
                if set_length == 1:
                    mode = ord(line[pointer:pointer + 1])
                    set_length = 0
                    i = 1
                else:
                    pointer += 1
                    set_length = 1
                    length_of_activ_input += 1
            j += 1
        else:
            return 0
    v_sk.len[input_device][0] = length_of_activ_input
    print(mode, name, password)
    return 2


def com252(line, token, input_device):
    # LAST ERROR
    v_sk.info_to_all.extend(int_to_ba(token + v_cr_params.adder, v_cr_params.length_commandtoken))
    v_sk.info_to_all.extend(int_to_ba(len(v_sk.last_error[input_device]), 1))
    v_sk.info_to_all.extend(str_to_bytearray(v_sk.last_error[input_device]))
    v_sk.len[input_device][0] = v_cr_params.length_commandtoken
    return 2


def com253(line, token, input_device):
    if len(line) < v_cr_params.length_commandtoken + 1:
        return  0
    temp = line[v_cr_params.length_commandtoken:v_cr_params.length_commandtoken + 1]
    if temp == 0:
        # INFO
        v_sk.info_to_all.extend(int_to_ba(token + v_cr_params.adder, v_cr_params.length_commandtoken))
        v_sk.info_to_all.extend(bytearray([0, 4]))
    elif temp == 1:
        # USER
        # reply empty usernumber
        if v_sk.multiuser[input_device] == 2:
            # this is the first command on this interface
            v_sk.multiuser = 1
            v_sk.user_timeout[input_device][0] = time.time()
            v_sk.info_to_all.extend(bytearray([1, 0]))
            # do not activate a real cahnnel now
        elif v_sk.multiuser[input_device] == 1:
            i = 1
            while i < 255:
                if v_sk.user_active[input_device][i] == 0:
                    v_sk.user_active[input_device][i] = 1
                    v_sk.info_to_all.extend(bytearray([1, i]))
                    break
        else:
            # single user mode
            v_sk.info_to_all.extend(bytearray([1, 0]))
    v_sk.len[input_device][0] = v_cr_params.length_commandtoken + 1
    return 2

def com255(line, token, input_device):
    if len(line) < v_cr_params.length_commandtoken + 1:
        return  0
    temp = line[v_cr_params.length_commandtoken:v_cr_params.length_commandtoken + 1]
    if temp == 0:
        v_sk.info_to_all.extend(int_to_ba(token + v_cr_params.adder, v_cr_params.length_commandtoken))
        v_sk.info_to_all.extend(bytearray([0, 4]))
    v_sk.len[input_device][0] = v_cr_params.length_commandtoken + 1
    return 2

# cr_commands = [ 0x00, 0xf0, 0xfc, 0xfd, 0xfff0, 0xfffc, 0xfffd, 0xfffffff0, 0xfffffffc, 0xfffffffd]


cr_own_command = {0xf0: 240,
        0xf1: 241,
        0xf9: 249,
        0xfa: 250,
        0xfb: 251,
        0xfc: 252,
        0xfd: 253,
        0xff: 255,
        0xfff0: 240,
        0xfff1: 241,
        0xfff9: 249,
        0xfffb: 251,
        0xfffc: 252,
        0xfffd: 253,
        0xffff: 255,
        0xfffff0: 240,
        0xfffff1: 241,
        0xfffff9: 249,
        0xfffffb: 251,
        0xfffffc: 252,
        0xfffffd: 253,
        0xffffff: 255,
        0xfffffff0: 240,
        0xfffffff1: 241,
        0xfffffff9: 249,
        0xfffffffb: 251,
        0xfffffffc: 252,
        0xfffffffd: 253,
        0xffffffff: 255,
        0xfffffffff0: 240,
        0xfffffffff1: 241,
        0xfffffffff9: 249,
        0xfffffffffb: 251,
        0xfffffffffc: 252,
        0xfffffffffd: 253,
        0xffffffffff: 255,
        0xfffffffffff0: 240,
        0xfffffffffff1: 241,
        0xfffffffffff9: 249,
        0xfffffffffffb: 251,
        0xfffffffffffc: 252,
        0xfffffffffffd: 253,
        0xffffffffffff: 255,
        0xfffffffffffff0: 240,
        0xfffffffffffff1: 241,
        0xfffffffffffff9: 249,
        0xfffffffffffffb: 251,
        0xfffffffffffffc: 252,
        0xfffffffffffffd: 253,
        0xffffffffffffff: 255,
        0xfffffffffffffff0: 240,
        0xfffffffffffffff1: 241,
        0xfffffffffffffff9: 249,
        0xfffffffffffffffb: 251,
        0xfffffffffffffffc: 252,
        0xfffffffffffffffd: 253,
        0xffffffffffffffff: 255,
        }

cr_own = {0xf0: com240,
        0xf1: com241,
        0xf9: com249,
        0xfb: com251,
        0xfc: com252,
        0xfd: com253,
        0xff: com255,
        }

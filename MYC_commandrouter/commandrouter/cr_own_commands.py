"""
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


def com240(line, tok, token, input_device, user):
    # parameters are checked before
    temp = v_cr_params.length_commandtoken + v_linelength.command[tok][3]
    start_line = int.from_bytes(line[v_cr_params.length_commandtoken:temp], byteorder='big', signed=False)
    number_of_lines = int.from_bytes(line[temp: temp + v_linelength.command[tok][3]], byteorder='big', signed=False)
    output = int_to_ba(token + v_cr_params.adder, v_cr_params.length_commandtoken)
    i = 0
    while i < number_of_lines:
        item = v_announcelist.full[start_line].split(";")
        if len(item) > 1:
            item1 = item[1].split(",")
            if item1[0][0] == "r" or item1[0][0] == "s":
                # empty string
                output.extend(int_to_ba(0, v_linelength.command[tok][5]))
            else:
                strl = len(v_announcelist.full[start_line])
                output.extend(int_to_ba(strl, v_linelength.command[tok][5]))
                output.extend(str_to_bytearray((v_announcelist.full[start_line])))
        i += 1
        start_line += 1
        if start_line > v_linelength.command[tok][4]:
            # end of memory
            start_line = 0
    v_sk.info_to_all.extend(output)
    # return bytes to delete (2 * v_linelength.command[tok][3])
    return


def com241(line, tok, token, input_device, user):
    # parameters are checked before
    temp = v_cr_params.length_commandtoken + v_linelength.command[tok][3]
    start_line = int.from_bytes(line[v_cr_params.length_commandtoken:temp], byteorder='big', signed=False)
    number_of_lines = int.from_bytes(line[temp: temp + v_linelength.command[tok][3]], byteorder='big', signed=False)
    output = int_to_ba(token + v_cr_params.adder, v_cr_params.length_commandtoken)
    i = 0
    while i < number_of_lines:
        strl = len(v_announcelist.full[start_line])
        output.extend(int_to_ba(strl, v_linelength.command[tok][5]))
        output.extend(str_to_bytearray((v_announcelist.basic[start_line])))
        i += 1
        start_line += 1
        if start_line > v_linelength.command[tok][2]:
            # end of memor<
            start_line = 0
    v_sk.info_to_all.extend(output)
    # return bytes to delete (2 * v_linelength.command[tok][3])
    return


def com249(line, tok, token, input_device, user):
    # 249;oa,SK-FEATURE;255,ANSWERS
    # Answers in announcement: 255 -> 1 Byte
    length = ord(line[v_cr_params.length_commandtoken:(v_cr_params.length_commandtoken + 1)])
    i = v_cr_params.length_commandtoken + length
    v_sk.user_answer_token[input_device][user] = bytearray([])
    while i < len(line):
        v_sk.user_answer_token[input_device][user].extend(line[i:i+v_cr_params.length_commandtoken])
        i += v_cr_params.length_commandtoken
    output = int_to_ba(token + v_cr_params.adder, v_cr_params.length_commandtoken)
    return


def com250(line, tok, token, input_device, user):
    # FEATURE
    output = int_to_ba(token + v_cr_params.adder, v_cr_params.length_commandtoken)
    return


def com251(line, tok, token, input_device, user):
    # 251;ob,LOGON;b,mode;20,name;20,password
    # ##############################
    # not ready
    # data must be send to RU
    # ################################
    start = ord(line[v_cr_params.length_commandtoken:(v_cr_params.length_commandtoken + 1)])
    elements = ord(line[v_cr_params.length_commandtoken + 1:(v_cr_params.length_commandtoken + 2)])
    i = start
    j = 0
    mode = 0
    name = ""
    password = ""
    # point to next stringposition
    stringpointer = v_cr_params.length_commandtoken + 2
    while j < elements:
        if i == 0:
            mode = ord(line[stringpointer:(stringpointer + 1)])
            stringpointer += 1
        elif i == 1:
            namelength = ord(line[stringpointer:(stringpointer + 1)])
            stringpointer += 1
            name = ba_to_str(line[stringpointer: stringpointer + namelength])
            stringpointer += namelength
        elif i == 2:
            passwordlength = ord(line[stringpointer:(stringpointer + 1)])
            stringpointer += 1
            password = ba_to_str(line[stringpointer: stringpointer + passwordlength])
            stringpointer += passwordlength
        i += 1
        if i == 3:
            i = 0
        j += 1
    print(mode, name, password)
    return


def com252(line, tok, token, input_device, user):
    print("CRLasrerror")
    # LAST ERROR
    v_sk.info_to_all.extend(int_to_ba(token + v_cr_params.adder, v_cr_params.length_commandtoken))
    v_sk.info_to_all.extend(int_to_ba(len(v_sk.last_error[input_device]),1))
    v_sk.info_to_all.extend(str_to_bytearray(v_sk.last_error[input_device]))
    return


def com253(line, tok, token, input_device, user):
    # INFO
    v_sk.info_to_all.extend(int_to_ba(token + v_cr_params.adder, v_cr_params.length_commandtoken))
    line = line[v_cr_params.length_commandtoken:]
    # paramenter:
    if line[0] == 0:
        # busy info
        v_sk.info_to_all.extend(bytearray([0, 4]))
    elif line[0] == 1:
        # reply empty usernumber
        if v_sk.multiuser[input_device] == 2:
            #this is the first command on this interface
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
    # return bytes to delete
    return v_cr_params.length_commandtoken + v_linelength.command[tok][3]


# cr_commands = [ 0x00, 0xf0, 0xfc, 0xfd, 0xfff0, 0xfffc, 0xfffd, 0xfffffff0, 0xfffffffc, 0xfffffffd]


command = {0xf0: com240,
        0xf1: com241,
        0xf9: com249,
        0xfa: com250,
        0xfb: com251,
        0xfc: com252,
        0xfd: com253,
        0xfff0: com240,
        0xfff1: com241,
        0xfff9: com249,
        0xfffa: com250,
        0xfffb: com251,
        0xfffc: com252,
        0xfffd: com253,
        0xfffff0: com240,
        0xfffff1: com241,
        0xfffff9: com249,
        0xfffffa: com250,
        0xfffffb: com251,
        0xfffffc: com252,
        0xfffffd: com253,
        0xfffffff0: com240,
        0xfffffff1: com241,
        0xfffffff9: com249,
        0xfffffffa: com250,
        0xfffffffb: com251,
        0xfffffffc: com252,
        0xfffffffd: com253,
        0xfffffffff0: com240,
        0xfffffffff1: com241,
        0xfffffffff9: com249,
        0xfffffffffa: com250,
        0xfffffffffb: com251,
        0xfffffffffc: com252,
        0xfffffffffd: com253,
        0xfffffffffff0: com240,
        0xfffffffffff1: com241,
        0xfffffffffff9: com249,
        0xfffffffffffa: com250,
        0xfffffffffffb: com251,
        0xfffffffffffc: com252,
        0xfffffffffffd: com253,
        0xfffffffffffff0: com240,
        0xfffffffffffff1: com241,
        0xfffffffffffff9: com249,
        0xfffffffffffffa: com250,
        0xfffffffffffffb: com251,
        0xfffffffffffffc: com252,
        0xfffffffffffffd: com253,
        0xfffffffffffffff0: com240,
        0xfffffffffffffff1: com241,
        0xfffffffffffffff9: com249,
        0xfffffffffffffffa: com250,
        0xfffffffffffffffb: com251,
        0xfffffffffffffffc: com252,
        0xfffffffffffffffd: com253,
        }
"""
name: cr_own_commands.py
last edited: 202512
handling of commands for CR
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""

from misc_functions import *

import v_cr_params
import v_announcelist
import v_linelength
import v_sk
import v_token_params

# answers of all CR own command are send directly to SK

def com240(line, token, input_device):
    com_a(line, token, input_device)
    return 2

def com241(line, token, input_device):
    com_a(line, token, input_device)
    return 2

def com242(line, token, input_device):
    com_a(line, token, input_device)
    return 2

def com_a(tok, line, input_device):
    # token, start  and number_of_elment have samee length
    if len(line) < v_announcelist.length_of_full_elements * 2:
        return 0
    le = len(line)
    start_line = int.from_bytes(line[:v_announcelist.length_of_full_elements], byteorder='big', signed=False)
    if start_line >= v_announcelist.full_elements:
        write_log("startline for announcecommand too high: " + str(start_line) + " should be " + str(v_announcelist.full_elements))
        # bytes to delete:
        v_sk.len[input_device][0] = le
        return 2
    line = line[v_announcelist.full_elements:]
    number_of_lines = int.from_bytes(line[:v_announcelist.full_elements], byteorder='big', signed=False)
    if number_of_lines > v_announcelist.full_elements:
        write_log("number of lines for announcecommand too high: " + str(number_of_lines) + " should be " + str(v_announcelist.full_elements))
        # bytes to delete:
        v_sk.len[input_device][0] = le
        return 2
    output = int_to_ba(tok, v_announcelist.full_elements)
    output.extend(int_to_ba(start_line,v_announcelist.full_elements))
    output.extend(int_to_ba(number_of_lines, v_announcelist.full_elements))
    i = 0
    while i < number_of_lines:
        strl = len(v_announcelist.full[start_line])
        output.extend(int_to_ba(strl, v_linelength.command[tok][5]))
        output.extend(str_to_bytearray((v_announcelist.full[start_line])))
        start_line += 1
        if start_line >= v_linelength.command[tok][4]:
            # end of memory
            start_line = 0
        i += 1
    v_sk.info_to_all += output
    # bytes to delete:
    v_sk.len[input_device][0] = le
    return 2

def com249(line, token, input_device):
    # 249;oa,SK-FEATURE;255,ANSWERS
    # Answers in announcement: 255 -> 1 Byte
    if len(line) < v_announcelist.full_elements + v_cr_params.length_of_c_249_elements:
        print("249_1", v_announcelist.full_elements + v_cr_params.length_of_c_249_elements)
        return 0
    length = int.from_bytes(line[v_announcelist.full_elements:v_announcelist.full_elements + v_cr_params.length_of_c_249_elements], byteorder='big', signed=False)
    v_sk.len[input_device][0] = v_announcelist.full_elements + 1 + v_cr_params.length_of_c_249_elements
    if length > v_cr_params.c_249_elements:
        write_log("length of string of 249 command too high: " + str(length) + "should be: "+ str(v_cr_params.c_249_elements))
        return 2
    v_sk.len[input_device][0] += length
    if len(line) < v_sk.len[input_device][0]:
        print("249_2",v_sk.len[input_device][0] )
        return 0
    # missing : user
    v_sk.len[input_device][0] = v_announcelist.full_elements
    return 2


def com251(line, token, input_device):
    # 251;ob,LOGON;b,mode;20,name;20,password
    # ##############################
    # not ready
    # data must be send to RU
    # ################################
    # start, elements and 1 additional byte required as min
    if len(line) < v_announcelist.full_elements + 2:
        return 0
    start = int.from_bytes(line[v_announcelist.full_elements:(v_announcelist.full_elements + 1)], byteorder='big', signed=False)
    elements = int.from_bytes(line[v_announcelist.full_elements + 1:(v_announcelist.full_elements + 2)], byteorder='big', signed=False)
    if start > 3 or elements > 3:
        write_log("logon values too high " + str(start) + str(elements) + "should be 3" )
        v_sk.len[input_device][0] = v_announcelist.full_elements + 2
        return 2
    i = start
    j = 0
    mode = 0
    name = ""
    password = ""
    # point to firstlement
    pointer = v_announcelist.full_elements + 2
    length_of_activ_input = v_announcelist.full_elements + 2
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

def com252(token, input_device):
    # LAST ERROR
    v_sk.info_to_all += int_to_ba(token, v_announcelist.full_elements)
    v_sk.info_to_all += int_to_ba(len(v_sk.last_error[input_device]), 1)
    v_sk.info_to_all += str_to_bytearray(v_sk.last_error[input_device])
    v_sk.len[input_device][0] = v_announcelist.full_elements
    return 2


def com253(line, token, input_device):
    if len(line) < v_announcelist.full_elements + 1:
        return  0
    temp = line[v_announcelist.full_elements:v_announcelist.full_elements + 1]
    if temp == 0:
        # INFO
        v_sk.info_to_all += int_to_ba(token, v_announcelist.full_elements)
        v_sk.info_to_all += bytearray([0, 4])
    elif temp == 1:
        # USER
        # reply empty usernumber
        if v_sk.multiuser[input_device] == 2:
            # this is the first command on this interface
            v_sk.multiuser = 1
            v_sk.user_timeout[input_device][0] = time.time()
            v_sk.info_to_all += bytearray([1, 0])
            # do not activate a real cahnnel now
        elif v_sk.multiuser[input_device] == 1:
            i = 1
            while i < 255:
                v_sk.info_to_all += bytearray([1, i])
        else:
            # single user mode
            v_sk.info_to_all += bytearray([1, 0])
    v_sk.len[input_device][0] = v_announcelist.full_elements + 1
    return 2

def com255(line, token, input_device):
    if len(line) < v_announcelist.full_elements + 1:
        return  0
    temp = line[v_announcelist.full_elements:v_announcelist.full_elements + 1]
    if temp == 0:
        v_sk.info_to_all += int_to_ba(token , v_announcelist.full_elements)
        v_sk.info_to_all+= bytearray([0, 4])
    v_sk.len[input_device][0] = v_announcelist.full_elements + 1
    return 2

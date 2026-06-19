"""
name: cr_own_commands.py
last edited: 20260225
handling of commands for CR
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""
from os.path import join

import misc_functions
import v_cr_params
import v_announcelist
import v_sk

# answers of all CR own command are send directly to SK
# return (finish) 0: not ready, 1: ok finished, 2: error

def cr_own(tok, input_device):
    ret = 0
    if tok == 0:
        ret = com_basic(0, input_device)
    elif tok in v_announcelist.basic:
        ret = com_basic(tok, input_device)
    else:
        if tok < 0x100:
            tok += 0
        elif tok < 0x10000:
            tok -= 0xff00
        elif tok < 0x1000000:
            tok -= 0xffff00
        elif tok < 0x100000000:
            tok -= 0xffffff00
        else:
            # not allowed
            tok += 0xffffffff
        match tok:
            case 240:
                ret = com_a(input_device)
            case 241:
                ret =  com_a(input_device)
            case 251:
                ret = com_251(input_device)
            case 252:
                ret = com_252(input_device)
            case 253:
                ret = com_253(input_device)
            case 254:
                ret = com_254(input_device)
            case 255:
                ret = com_255(input_device)
            case _:
                ret = 10

    return ret

def com_basic(tok, input_device):
    # CR basic command: directly answered, not sent to LD
    v_sk.info_to_all = bytearray(misc_functions.tok_to_bytes(tok, v_announcelist.length_of_full_elements))
    v_sk.info_to_all.extend(v_announcelist.basic[tok])
    # necessary to delete token:
    v_sk.data_len[input_device][0] = v_announcelist.length_of_full_elements
    return 10

def com_a(input_device):
    line = v_sk.inputline[input_device]
    # token, start  and number_of_elements have same length
    if len(line) < v_announcelist.length_of_full_elements * 3:
        return 0
    le = len(line)
    # for short:
    s = v_announcelist.length_of_full_elements
    start_line = int.from_bytes(line[s:2 * s], byteorder='big', signed=False)
    number_of_lines = int.from_bytes(line[2 * s:3 * s], byteorder='big', signed=False)
    if start_line >= v_announcelist.full_elements or number_of_lines > v_announcelist.full_elements:
        misc_functions.write_log("startline or number of elements for announcecommand too high: " + str(start_line) + " should be " + str(v_announcelist.full_elements))
        # bytes to delete:
        v_sk.data_len[input_device][0] = le
        return 2
    output = line
    i = 0
    while i < number_of_lines:
        output.extend(bytes(v_announcelist.full_240[start_line], 'utf-8'))
        start_line += 1
        if start_line >= v_announcelist.full_elements:
            start_line = 0
        i += 1
    v_sk.info_to_all.extend(output)
    # bytes to delete:
    v_sk.data_len[input_device][0] = le
    return 1

def com_251(input_device):
    line = v_sk.inputline[input_device]
    # not used now
    # 251;ob,LOGON;b,mode;20,name;20,password
    # ##############################
    # data must be send to RU
    # ################################
    # start, elements and 3 additional byte required as min
    start = v_announcelist.full_elements
    if len(line) < start + 3:
        return 0
    if int(line[start + 1]) != 0 or int(line[start + 2]) != 3:
        misc_functions.write_log("logon wrong parameters")
        v_sk.data_len[input_device][0] = len(line)
        return 2
    change_mode = line[start + 3]
    user_name_len = line[start + 3]
    if len(line) < user_name_len + start + 4:
        return 0
    password_len = line(user_name_len + start + 4)
    if len(line) < password_len + start + 4 + user_name_len:
        return 0
    if user_name_len < 7 or password_len < 7:
        misc_functions.write_log("logonusernam or password too short")
        v_sk.data_len[input_device][0] = len(line)
        return 2
    user_name = line[start + 4: start + 4 + user_name_len]
    password = line[start + 5 + user_name_len:start + 5 + user_name_len + password_len]

    # send to RU (file only)
    ru_file_out(change_mode, user_name, password)
    return 1

def com_252(input_device):
    v_sk.info_to_all = v_sk.inputline[input_device]
    v_sk.info_to_all.append(len(v_sk.last_error))
    v_sk.info_to_all.extend(map(ord, v_sk.last_error))
    v_sk.data_len[input_device][0] = v_announcelist.length_of_full_elements
    return 1

def com_253(input_device):
    line = v_sk.inputline[input_device]
    v_sk.info_to_all.extend(line)
    v_sk.info_to_all.append(4)
    v_sk.data_len[input_device][0] = v_announcelist.length_of_full_elements
    return 1

def com_254(input_device):
    # the program uses these date at start only. Therefore they are rewritten to the CR file if changed
    # must be modified if CR 254 255 lines are modified
    line = v_sk.inputline[input_device]
    if len(line) < v_announcelist.length_of_full_elements + 2:
        return  0
    c254_line = v_cr_params.c254_line.split(";")
    c255_line = v_cr_params.c255_line.split(";")
    if line[v_announcelist.length_of_full_elements] > 8:
        misc_functions.write_log("parameter too high " + str(line[1]) + "\n")
        v_sk.data_len[input_device][0] = v_announcelist.length_of_full_elements + 1
        return 2
    mods = 0
    length_adder = 1
    par = line[v_announcelist.length_of_full_elements]
    match par:
        case 0:
            mods, length_adder,  c254_line, c255_line = new_string(2, line, c254_line, c255_line)
        case 6:
            mods, length_adder,  c254_line, c255_line = new_string(8, line, c254_line, c255_line)
        case 8:
            mods, length_adder,  c254_line, c255_line = new_string(10, line, c254_line, c255_line)
        case _:
            mods, c254_line, c255_line = modify(par +2, c254_line, c255_line, line[v_announcelist.length_of_full_elements + 1])
    if mods == 2:
        misc_functions.write_log("255:parameter too high or wrong")
    if mods == 1:
        # write back to commandrouter_config/CR
        all = []
        fi = open("commandrouter_config/CR", "r")
        for line in fi:
            if line[:3] == "254" or line[:3] == "255":
                pass
            else:
                all.append(line)
        fi.close()
        fi = open("commandrouter_config/CR", "w")
        for line in all:
            fi.write(line)
        fi.write(c254_line + "\n")
        fi.write( c255_line)
        fi.close()
        v_sk.data_len[input_device][0] = v_announcelist.length_of_full_elements + length_adder
        if mods > 0:
            v_sk.data_len[input_device][0] = v_announcelist.length_of_full_elements + length_adder
    return mods

def new_string(n, line, c254_line, c255_line):
    length = line[v_announcelist.length_of_full_elements + 1]
    if length == 0 or length > 20:
        ok =  2
    else:
        g_len = v_announcelist.length_of_full_elements + 2 + length
        if len(line) < g_len:
            # not ready
            ok = 0
            pass
        else:
            ok = 1
            i = v_announcelist.length_of_full_elements + 2
            # skip length as well
            name = ""
            while i < len(line) and ok == 1:
                if line[i] > 47 and line[i] < 57:\
                    name += chr(line[i])
                elif line[i] > 64 and line[i] < 91:
                    name += chr(line[i])
                elif line[i] > 97 and line[i] < 123:
                    name += chr(line[i])
                elif line[i] ==  47 and line[i] == 95:
                    name += chr(line[i])
                else:
                    ok = 2
                i += 1
            if ok == 1:
                c54 = c254_line[n].split(",")
                c54[2] = name
                c254_line[n] = ",".join(c54)
                c55 = c255_line[n].split(",")
                c55[2] = name
                c255_line[n] = ",".join(c55)
    line254 = ";".join(c254_line)
    line255 = ";".join(c255_line)
    return ok, length + 1, line254, line255

def modify(n, c254_line,c255_line, line):
    ok = 1
    if n > 10:
        ok = 2
    if n != 5:
        # all except USB Port
        if int(line) > 1:
            ok = 2
    if ok == 1:
        c4 = c254_line[n].split(",")
        c4[2] = str(line)
        c5 = c255_line[n].split(",")
        c5[2] = str(line)
        c254_line[n] = ",".join(c4)
        c255_line[n] = ",".join(c5)
        c254_line = ";".join(c254_line)
        c255_line = ";".join(c255_line)
    return ok, c254_line, c255_line

def com_255(input_device):
    # bytearray
    line = v_sk.inputline[input_device]
    c255_line = v_cr_params.c255_line.split(";")
    if len(line) < v_announcelist.length_of_full_elements + 1:
        return  0
    if line[v_announcelist.length_of_full_elements] > 9:
        misc_functions.write_log("parameter too high " + str(line[1]) + "\n")
        v_sk.data_len[input_device][0] = v_announcelist.length_of_full_elements + 1
        return 2
    v_sk.info_to_all = line
    match line[v_announcelist.length_of_full_elements]:
        case 0:
            v_sk.info_to_all.append(len(c255_line[2].split(",")[2]))
            v_sk.info_to_all.extend(misc_functions.str_to_bytearray(c255_line[2].split(",")[2]))
        case 1:
            v_sk.info_to_all.append(int(c255_line[3].split(",")[2]))
        case 2:
            # USB
            v_sk.info_to_all.append(int(c255_line[4].split(",")[2]))
        case 3:
            v_sk.info_to_all.append(int(c255_line[5].split(",")[2]))
        case 4:
            # telnet
            v_sk.info_to_all.append(int(c255_line[6].split(",")[2]))
        case 5:
            # FILE 0
            v_sk.info_to_all.append(int(c255_line[7].split(",")[2]))
        case 6:
            v_sk.info_to_all.append(len(c255_line[8].split(",")[2]))
            v_sk.info_to_all.extend(misc_functions.str_to_bytearray(c255_line[8].split(",")[2]))
        case 7:
            # FILE 1
            v_sk.info_to_all.append(int(c255_line[9].split(",")[2]))
        case 8:
            v_sk.info_to_all.append(len(c255_line[10].split(",")[2]))
            v_sk.info_to_all.extend(misc_functions.str_to_bytearray(c255_line[10].split(",")[2]))
        case 9:
            # terminal
            v_sk.info_to_all.append(int(c255_line[11].split(",")[2]))
    v_sk.data_len[input_device][0] = v_announcelist.length_of_full_elements + 1
    return 1
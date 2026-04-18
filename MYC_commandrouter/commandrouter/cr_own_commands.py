"""
name: cr_own_commands.py
last edited: 20260225
handling of commands for CR
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""
import misc_functions
import v_cr_params
import v_announcelist
import v_sk

# answers of all CR own command are send directly to SK

def cr_own(tok, input_device):
    if tok == 0:
        return com_basic(0, input_device)
    elif tok in v_announcelist.basic:
        return com_basic(tok, input_device)
    else:
        if tok < 0x100:
            tok += 0
        elif tok < 0x10000:
            tok += 0xff
        elif tok < 0x1000000:
            tok += 0xffff
        elif tok < 0x100000000:
            tok += 0xffffff
        else:
            # not allowed
            tok += 0xffffffff
    match tok:
        case 240:
            return com_a(input_device)
        case 241:
            return com_a(input_device)
        case 251:
            return com_251(input_device)
        case 252:
            return com_252(input_device)
        case 253:
            return com_253(input_device)
        case 255:
            return com_255(input_device)
    return

def com_basic(tok, input_device):
    # CR basic command: directly answered, not sent to LD
    v_sk.info_to_all = bytearray(misc_functions.tok_to_bytes(tok, v_announcelist.length_of_full_elements))
    v_sk.info_to_all.extend(v_announcelist.basic[tok])
    # necessary to delete token:
    v_sk.data_len[input_device][0] = v_announcelist.length_of_full_elements
    return 1

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
        output.extend(v_announcelist.full_240[start_line])
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

def com_255(input_device):
    line = v_sk.inputline[input_device]
    if len(line) < v_announcelist.length_of_full_elements + 1:
        return  0
    if line[1] > 5:
        misc_functions.write_log("parameter too high " + str(line[1]) + "\n")
        return 2
    data = ""
    match line[1]:
        case 0:
            data = v_cr_params.name
        case 1:
            data = ord(v_cr_params.number)
        case 2:
            data = v_cr_params.usb_active
        case 3:
            data = v_cr_params.file_active
        case 4:
            data = v_cr_params.telnet_active
        case 5:
            data = v_cr_params.terminal_active
    v_sk.info_to_all = line
    if line[1]  == 0:
        v_sk.info_to_all.append(len(data))
        v_sk.info_to_all.extend(map(ord, data))
    else:
        v_sk.info_to_all.append(data)
    v_sk.data_len[input_device][0] = v_announcelist.length_of_full_elements + 1
    return 1

"""
name: commands.py
last edited: 201903012
handling of sk input commands
output to civ
"""


import time

from misc_functions import *
from init import create_config_file

import v_announcelist
import v_sk
import v_Ic7300_vars
import v_error_msg

def nop(line, input_device, tokennumber):
    v_sk.len[input_device][0] = len(line)
    return  1

def command_initial_data():
    if v_Ic7300_vars.init_content > 0:
        # send answer command
        if v_Ic7300_vars.init_content == 1:
            if v_Ic7300_vars.memory_to_check < 101:
                command_memoryx(v_Ic7300_vars.memory_to_check)
                v_Ic7300_vars.memory_to_check += 1
                v_Ic7300_vars.init_content = 2
            else:
                # memory finished
                v_Ic7300_vars.init_content = 10
        elif v_Ic7300_vars.init_content == 3:
            # initialize memory, should deliver answer "ok"
            v_Ic7300_vars.Civ_out = bytearray([0xfe, 0xfe, 0x94, 0xe0, 0x1a, 0x00])
            v_Ic7300_vars.Civ_out.extend(int_to_bcd(v_Ic7300_vars.memory_to_check, 2))
            v_Ic7300_vars.Civ_out.extend(v_Ic7300_vars.actual_memory_content)
            v_Ic7300_vars.init_content = 4
        else:
            actual_status = v_Ic7300_vars.init_content
            if actual_status % 2 == 0:
                # even: send next command
                if v_Ic7300_vars.init_content == 10:
                    # ask for mode
                    v_Ic7300_vars.Civ_out = bytearray([0xfe, 0xfe, 0x94, 0xe0, 0x04, 0xfd])
                    v_Ic7300_vars.init_content = 11
                    # This will finish initialization:
                    v_Ic7300_vars.init_content = 0
                    v_Ic7300_vars.input_locked = 0
    return 1

def header(tokennumber):
    v_Ic7300_vars.Civ_out = bytearray([0xfe, 0xfe, 0x94, 0xe0])
    v_Ic7300_vars.Civ_out.extend(v_Ic7300_vars.token_civ_code[tokennumber])
    return

def answercommand_xx(line, input_device, tokennumber, length, limit, parameter, adder):
    #
    if len(line) < length:
        return 0
    v_sk.len[input_device][0] = len(line)
    header (tokennumber)
    if len(line) > 2:
        if line[2] > limit:
            return 2
        # for scope edge
        if parameter < 100:
            v_Ic7300_vars.Civ_out.extend(bytearray([parameter, line[2] + adder]))
        elif parameter == 100:
            v_Ic7300_vars.Civ_out.extend(bytearray([line[2] + adder]))
        else:
            #255
            v_Ic7300_vars.Civ_out.extend(bytearray([line[2] + adder]))
        v_sk.parameter = line[2]
    else:
        if limit == 1:
            v_Ic7300_vars.Civ_out.extend(bytearray([0x00]))
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    return 1

def answercommand(line, input_device, tokennumber):
    # no parameter
    return answercommand_xx(line, input_device, tokennumber, 2, 0, 0, 0)

def answercommand_am(line, input_device, tokennumber):
    # no parameter if mode == AM
    if v_Ic7300_vars.actual_mode_filter_content[0] == 2:
        return answercommand_xx(line, input_device, tokennumber, 2, 0, 0, 0)
    else:
        return 2

def answercommand_non_am(line, input_device, tokennumber):
    # no paramter, non AM mode
    if v_Ic7300_vars.actual_mode_filter_content[0] != 2:
        return answercommand_xx(line, input_device, tokennumber, 2, 0, 0, 0)
    else:
        return 2

def answercommand00(line, input_device, tokennumber):
    # add 0x00 to CIV command
    return answercommand_xx(line, input_device, tokennumber, 2, 1, 0, 0)

def answercommand_1_2(line, input_device, tokennumber):
    # 1 command parameter, limit 1, adder 0
    return answercommand_xx(line, input_device, tokennumber, 3, 1, 255, 0)

def answercommand_1_8(line, input_device, tokennumber):
    # 1 command parameter, limit 8, adder 1
    return answercommand_xx(line, input_device, tokennumber, 3, 8, 255, 1)

def answercommand_1_30(line, input_device, tokennumber):
    # 1 command parameter, limit 20, adder 1
    return answercommand_xx(line, input_device, tokennumber, 3, 30, 255, 1)

def answercommand_memory(line, input_device, tokennumber):
    # takes 1 parameter, limit 100, convert to 2byte bcd
    if len(line) < 3:
        return 0
    if line[2] > 100:
        return 2
    header(tokennumber)
    v_sk.len[input_device][0] = len(line)
    v_Ic7300_vars.Civ_out.extend(int_to_bcd(line[2] + 1, 2))
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    return 1

def answercommand_band_stack(line, input_device, tokennumber):
    # takes 2 parameter, limit 102, convert to 2byte bcd
    if len(line) < 3:
        return 0
    if line[2] > 32:
        return 2
    header(tokennumber)
    temp = int_to_bcd_int((line[2] % 11) + 1)
    v_Ic7300_vars.Civ_out.extend(bytearray([temp, (line[2] // 11) + 1, 0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1

def answercommand_scope_edge_1(line, input_device, tokennumber):
    # command 1a050152 +
    if len(line) < 3:
        return 0
    if line[2] > 2:
        return 2
    header(tokennumber)
    v_sk.parameter = line[2]
    v_Ic7300_vars.Civ_out[7] = v_Ic7300_vars.Civ_out[7] + v_sk.parameter
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 3
    return 1

def command_1_b_x(line, input_device, tokennumber, limit, adder):
    # for commands with one databyte, limit for data is limit convert data to 1 byte bcd, bcd base "adder"
    # command has 3 bytes always
    if len(line) < 3:
        return 0
    if line[2] < limit:
        header(tokennumber)
        v_Ic7300_vars.Civ_out.extend(int_to_bcd(line[2] + adder, 1))
        v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
        v_sk.len[input_device][0] = len(line)
    else:
        return 2
    return 1

def command_1_b_xx(line, input_device, tokennumber, limit, adder):
    # for commands with one databyte, limit for data is limit convert data to 2 byte bcd, bcd base "adder"
    # command has 3 bytes always
    if len(line) < 3:
        return 0
    if line[2] < limit:
        header(tokennumber)
        temp1 = int_to_bcd(line[2] +  adder, 2)
        v_Ic7300_vars.Civ_out.extend(temp1)
        v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
        v_sk.len[input_device][0] = len(line)
    else:
        return 2
    return 1

def command_1_b_1(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd, limit for data is 1
    return command_1_b_x(line, input_device, tokennumber, 1, 0)

def command_1_b_2(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd, limit for data is 2
    return command_1_b_x(line, input_device, tokennumber, 2, 0)

def command_1_b_3(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd, limit for data is 3
    return command_1_b_x(line, input_device, tokennumber, 3, 0)

def command_1_b_3_1(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd, limit for data is 3
    return command_1_b_x(line, input_device, tokennumber, 3, 1)

def command_1_b_4(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd, limit for data is 4
    return command_1_b_x(line, input_device, tokennumber, 4, 0)

def command_1_b_5(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd, limit for data is 5
    return command_1_b_x(line, input_device, tokennumber, 5, 0)

def command_1_b_6(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd, limit for data is 6
    return command_1_b_x(line, input_device, tokennumber, 6, 0)

def command_1_b_8(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd, limit for data is 8
    return command_1_b_x(line, input_device, tokennumber, 8, 0)

def command_1_b_8_1(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd base 1, limit for data is 8
    ret = command_1_b_x(line, input_device, tokennumber, 8, 1)
    return ret

def command_1_b_9(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd, limit for data is 9
    return command_1_b_x(line, input_device, tokennumber, 9,0)

def command_1_b_10(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd, limit for data is 10
    return command_1_b_x(line, input_device, tokennumber, 10, 0)

def command_1_b_11(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd, limit for data is 11
    return command_1_b_x(line, input_device, tokennumber, 11, 0)

def command_1_b_15_1(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd base 1, limit for data is 15
    return command_1_b_x(line, input_device, tokennumber, 15, 1)

def command_1_b_18_28(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd base 28, limit for data is 18
    return command_1_b_x(line, input_device, tokennumber, 18, 28)

def command_1_b_21(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 1 byte bcd, limit for data is 21
    return command_1_b_x(line, input_device, tokennumber, 21, 0)

def command_1_b_60_1(line, input_device, tokennumber):
    # for commands with one databyte, limit for data is 60 convert data to 1 byte bcd base 1
    return command_1_b_x(line, input_device, tokennumber, 60, 1)

def command_1_b_2_0_2(line, input_device, tokennumber):
    # for commands with one databyte, limit for data is 2 convert data to 2 byte bcd base 0
    return command_1_b_xx(line, input_device, tokennumber, 2, 0)

def command_1_b_3_0_2(line, input_device, tokennumber):
    # for commands with one databyte, limit for data is 3 convert data to 2 byte bcd base 0
    return command_1_b_xx(line, input_device, tokennumber, 3, 0)

def command_1_b_3_1_2(line, input_device, tokennumber):
    # for commands with one databyte, limit for data is 3 convert data to 2 byte bcd base 1
    return command_1_b_xx(line, input_device, tokennumber, 3, 1)

def command_1_b_256_0_2(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 2 byte bcd base 0, limit for data is 255
    return command_1_b_xx(line, input_device, tokennumber, 256, 0)

def command_1_b_224_0_2(line, input_device, tokennumber):
    # for commands with one databyte, convert data to 2 byte bcd base 0, limit for data is 224
    ret = command_1_b_xx(line, input_device, tokennumber, 224, 0)
    return ret

def command_2_b_9999(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    number = line[2]* 256 + line[3]
    if number < 9999:
        header(tokennumber)
        v_sk.len[input_device][0] = len(line)
        v_Ic7300_vars.Civ_out.extend(int_to_bcd(number + 1, 2))
        v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
        v_sk.len[input_device][0] = len(line)
    else:
        return 2
    return 1

def command_2_b_4(line, input_device, tokennumber):
    # for commands with two databyte, convert data to 2 byte bcd each, limit for data is 4 for both data bytes
    if len(line) < 4:
        return 0
    if line[2] > 3 or line[3] > 3:
        return 2
    header(tokennumber)
    v_sk.len[input_device][0] = len(line)
    v_Ic7300_vars.Civ_out.extend(bytearray([line[2] * 16 + line[3]]))
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    return 1

def command_1_n_x(line, input_device, tokennumber, limit, adder):
    # for commands with one databyte, not converted 1byte data , limit for data is limit
    if len(line) < 3:
        return 0
    if line[2] < limit:
        header(tokennumber)
        v_Ic7300_vars.Civ_out.extend([line[2] + adder, 0xfd])
        v_sk.len[input_device][0] = len(line)
    else:
        return 2
    return 1

def command_1_n_7_161(line, input_device, tokennumber):
    # for commands with one databyte, not converted 1byte data , limit for data is 8
    return command_1_n_x(line, input_device, tokennumber, 7, 161)

def command_stringxx(line, input_device, tokennumber, max_length):
    if len(line) < 3:
        return 0
    length = line[2]
    if length > max_length:
        return 2
    if len(line) < length + 3:
        return 0
    header(tokennumber)
    temp1 = 3
    while temp1 < length + 3:
        str_char = str(line[temp1])
        if  not str_char.isupper and not str_char.isnumeric:
            if str_char not in ["-","/",".","@"]:
                continue
        v_Ic7300_vars.Civ_out.extend(bytearray([line[temp1]]))
        temp1 += 1
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1

def command_string10(line, input_device, tokennumber):
    #for commands with string with 20 chars
    return command_stringxx(line, input_device, tokennumber, 10)

def command_ou(line, input_device, tokennumber):
    header(tokennumber)
    try:
        v_Ic7300_vars.Civ_out.extend([v_Ic7300_vars.parameter[tokennumber]])
    except KeyError:
        pass
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1

def command_frequencyxx(line, b, limit, adder, civbytes):
    # convert b bytes of line with limit  to civbytes bcd LSB first
    # return ba
    tempa = b
    multiplier = 1
    frequency = 0
    while tempa > 0:
        tempb = line[tempa - 1] * multiplier
        frequency += tempb
        multiplier *= 256
        tempa -= 1
    if frequency > limit:
        return 2, 0
    frequency += adder
    decimal_string = str(frequency)
    digits = [int(c) for c in decimal_string]
    # fill preceeding "0"
    temp = 0
    diff = 2* civbytes - len(digits)
    dig =[]
    while temp < 8:
        if temp < diff:
            dig.append(0)
        else:
            dig.append(digits[temp - diff])
        temp += 1
    source = len(dig)
    destination = 0
    temp = bytearray([])
    while destination < civbytes:
        temp.extend([dig[source - 2]* 16 + dig[source -1]])
        source -= 2
        destination += 1
    return 1, temp

def command_modexx(line, length):
    if len(line) < length:
        return 0, 0
    if line[length  - 1] > 7 :
        return 2, 0
    temp = line[length - 1]
    if line[length - 1] > 5:
        temp = line[length - 1] + 1
    return 1, temp

def command_mode_filterx(line, input_device, tokennumber, length, mode_filter):
    ret, temp = command_modexx(line, length)
    if ret != 1:
        return ret
    header(tokennumber)
    v_Ic7300_vars.actual_mode_filter_content[mode_filter] = temp
    v_Ic7300_vars.Civ_out.extend(v_Ic7300_vars.actual_mode_filter_content)
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1

def command_frequency(line, input_device, tokennumber):
    if len(line) < 6:
        return 0
    ret, temp = command_frequencyxx(line[2:6], 4, 69969999, 30000, 4)
    if ret != 1:
        return ret
    else:
        header(tokennumber)
        try:
            v_Ic7300_vars.Civ_out.extend(bytearray([v_Ic7300_vars.parameter[tokennumber]]))
        except KeyError:
           pass
        v_Ic7300_vars.Civ_out.extend(temp)
        v_Ic7300_vars.Civ_out.extend(bytearray([0x00,0xfd]))
        v_sk.len[input_device][0] = len(line)
    return 1

def command_frequency_u_sel(line, input_device, tokennumber):
    if len(line) < 7:
        return 0
    if line[2]  > 1:
        return 2
    ret, temp = command_frequencyxx(line[3:7], 4, 69969999, 30000, 4)
    if ret != 1:
        return ret
    else:
        header(tokennumber)
        v_Ic7300_vars.Civ_out.extend(bytearray([line[2]]))
        v_Ic7300_vars.Civ_out.extend(temp)
        v_Ic7300_vars.Civ_out.extend(bytearray([0x00,0xfd]))
        v_sk.len[input_device][0] = len(line)
    return 1

def command_mode(line, input_device, tokennumber):
    return command_mode_filterx(line, input_device, tokennumber, 3, 0)

def command_mode1(line, input_device, tokennumber):
    return command_mode_filterx(line, input_device, tokennumber, 4, 0)

def command_set_vfo(line, input_device, tokennumber):
    header(tokennumber)
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    v_Ic7300_vars.actual_v_m = 0
    v_sk.len[input_device][0] = len(line)
    return 1

def command_set_memory(line, input_device, tokennumber):
    header(tokennumber)
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    v_Ic7300_vars.actual_v_m = 1
    v_sk.len[input_device][0] = len(line)
    return 1

def command_filter_bw(line, input_device, tokennumber, v_m):
    if v_Ic7300_vars.actual_mode_filter_content[0] == 2 and v_m == 2:
        # AM
        ret = command_1_b_x(line, input_device, tokennumber, 50, 0)
    elif v_Ic7300_vars.actual_mode_filter_content[0] != 2 and v_m != 2:
        ret = command_1_b_x(line, input_device, tokennumber, 50, 0)
    else:
        return 2
    return ret

def command_filter_bw_am(line, input_device, tokennumber):
    return command_filter_bw(line, input_device, tokennumber, 2)

def command_filter_bw_non_am(line, input_device, tokennumber):
    return command_filter_bw(line, input_device, tokennumber, 0)

def command_agc(line, input_device, tokennumber, v_m):
    if v_Ic7300_vars.actual_mode_filter_content[0] == 2 and v_m == 2:
        # AM
        ret = command_1_b_x(line, input_device, tokennumber, 14, 0)
    elif v_Ic7300_vars.actual_mode_filter_content[0] != 2 and v_m != 2:
        ret = command_1_b_x(line, input_device, tokennumber, 14, 0)
    else:
        return 2
    return ret

def command_agc_am(line, input_device, tokennumber):
    return command_agc(line, input_device, tokennumber, 2)

def command_agc_non_am(line, input_device, tokennumber):
    return command_agc(line, input_device, tokennumber, 0)
def command_vfo_mode(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 3:
        return 2
    header(tokennumber)
    v_sk.len[input_device][0] = len(line)
    if line[2] < 2:
        v_Ic7300_vars.Civ_out.extend([line[2]])
    elif line[2] == 2:
        v_Ic7300_vars.Civ_out.extend(0xa0)
    else:
         v_Ic7300_vars.Civ_out.extend([0xb0])
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    return 1

def command_sel_memory(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 100:
        return 2
    header(tokennumber)
    v_sk.len[input_device][0] = len(line)
    line[2] += 1
    if line[2] < 100:
        v_Ic7300_vars.Civ_out.extend(int_to_bcd(line[2], 2))
    elif line[2] == 100:
        v_Ic7300_vars.Civ_out.extend(bytearray([0x01, 0x00]))
    else:
        v_Ic7300_vars.Civ_out.extend(bytearray([0x01, 0x01]))
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    return 1

def command_scan_mode(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 7:
        return 2
    header(tokennumber)
    v_sk.len[input_device][0] = len(line)
    if line[2] < 4:
        v_Ic7300_vars.Civ_out.extend([line[2]])
    elif line[2] < 6:
        v_Ic7300_vars.Civ_out.extend([line[2] + 14])
    else:
        v_Ic7300_vars.Civ_out.extend([line[2] + 28])
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    return 1

def command_scan_resume(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 1:
        return 2
    header(tokennumber)
    v_sk.len[input_device][0] = len(line)
    if line[2]  == 0:
        v_Ic7300_vars.Civ_out.extend([0xd0, 0xfd])
    else:
        v_Ic7300_vars.Civ_out.extend([0xd3, 0xfd])
    return 1

def command_att(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 1:
        return 2
    header(tokennumber)
    v_sk.len[input_device][0] = len(line)
    if line[2] == 0:
        v_Ic7300_vars.Civ_out.extend([0x00, 0xfd])
    else:
        v_Ic7300_vars.Civ_out.extend([0x20, 0xfd])
    return 1

def command_cw(line, input_device, tokennumber, adder, adder2):
    v_sk.len[input_device][0] = len(line)
    if len(line) < 3 + adder:
        return 0
    cwlen = line[2 + adder]
    if cwlen == 0 or cwlen > 30 + adder2:
        return 2
    if adder == 1 and line[2] > 7:
        # for memory keyer
        return 2
    if len(line) < (cwlen + 3 + adder):
        return 0
    v_sk.len[input_device][0] = len(line)
    header(tokennumber)
    if adder == 1:
        # for memory keyer
        v_Ic7300_vars.Civ_out.extend(bytearray([line[2] + 1]))
    v_sk.len[input_device][0] = len(line)
    temp1 = 0
    temp2 = 3 + adder
    while temp1 < cwlen:
        if cwchars(line[temp2], 1 + adder):
            v_Ic7300_vars.Civ_out.extend(bytearray([line[temp2]]))
        temp1 += 1
        temp2 +=1
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    return 1

def command_cw_text(line, input_device, tokennumber):
    return command_cw(line, input_device, tokennumber, 0, 0)

def command_memory_keyer(line, input_device, tokennumber):
    return command_cw(line, input_device, tokennumber, 1, 40)

def command_on(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 1:
        return 2
    v_sk.len[input_device][0] = len(line)
    if line[2] == 0:
        header(tokennumber)
        v_Ic7300_vars.Civ_out.extend([0x00, 0xfd])
        v_sk.len[input_device][0] = len(line)
    else:
        v_Ic7300_vars.Civ_out = bytearray([0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE,0xFE, 0x94, 0xE0,0x18,0x01,0xFD])
    return 1

def command_hpf_lpf(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    if line[2] > 20 or line[3] > 20 or line[2] >= line[3]:
        return 2
    header(tokennumber)
    v_Ic7300_vars.Civ_out.extend(int_to_bcd(line[2],1))
    v_Ic7300_vars.Civ_out.extend(int_to_bcd(line[3] + 5,1))
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1

def command_offset_frequenz(line, input_device, tokennumber ):
    # offset
    if len(line) < 4:
        return 0
    header(tokennumber)
    ret, bcd = int_to_bcd_plusminus(line, 9999, 3, 10)
    if ret == 1:
        v_Ic7300_vars.Civ_out.extend(bcd)
        v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
        v_sk.len[input_device][0] = len(line)
    else:
        return ret
    return 1

def command_date(line, input_device, tokennumber):
    if len(line) < 5:
        return 0
    if line[2] > 99 or line[3] > 11 or line[4] > 30:
        return 2
    header(tokennumber)
    v_Ic7300_vars.Civ_out.extend(bytearray([32]))
    v_Ic7300_vars.Civ_out.extend(int_to_bcd(line[2], 1))
    v_Ic7300_vars.Civ_out.extend(int_to_bcd(line[3] + 1, 1))
    v_Ic7300_vars.Civ_out.extend(int_to_bcd(line[4] + 1, 1))
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1

def command_time(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    if line[2] > 23 or line[3] > 59:
        return 2
    header(tokennumber)
    v_Ic7300_vars.Civ_out.extend(int_to_bcd(line[2], 1))
    v_Ic7300_vars.Civ_out.extend(int_to_bcd(line[3], 1))
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1

def command_utc(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    minutes = line[2] * 256 + line[3]
    if minutes > 1680:
        return 2
    header(tokennumber)
    negative = 0
    if minutes > 840:
        # positve
        minutes = minutes - 840
        v_Ic7300_vars.Civ_out.extend(int_to_bcd(minutes // 60, 1))
        v_Ic7300_vars.Civ_out.extend(int_to_bcd(minutes % 60, 1))
    else:
        minutes = 840 - minutes
        v_Ic7300_vars.Civ_out.extend(int_to_bcd(minutes // 60, 1))
        v_Ic7300_vars.Civ_out.extend(int_to_bcd(minutes % 60, 1))
        negative = 1
    v_Ic7300_vars.Civ_out.extend(bytearray([negative]))
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1

def command_color(line, input_device, tokennumber):
    if len(line) < 5:
        return 0
    header(tokennumber)
    v_Ic7300_vars.Civ_out.extend(int_to_bcd(line[2], 2))
    v_Ic7300_vars.Civ_out.extend(int_to_bcd(line[3], 2))
    v_Ic7300_vars.Civ_out.extend(int_to_bcd(line[4], 2))
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 5
    return 1

def command_scope_edge_xx(line, input_device, tokennumber):
    # for scope edge commands 1a01xx
    if len(line) < 7:
        return 0
    if line[2] > 2:
        return 2
    lf = line[3] * 256 + line[4]
    span = line[5] * 256 + line[6]
    if span > 995:
        return 2
    # real span:
    span  += 5
    min = v_Ic7300_vars.number_frequency_range[v_Ic7300_vars.tokennumber_frequency_range_number[tokennumber]][0]
    max = v_Ic7300_vars.number_frequency_range[v_Ic7300_vars.tokennumber_frequency_range_number[tokennumber]][1]
    if lf > max - min - span:
        return 2
    header(tokennumber)
    v_Ic7300_vars.Civ_out[7] = v_Ic7300_vars.Civ_out[7] + line[2]
    v_Ic7300_vars.Civ_out.extend(int_to_3bcd((lf + min) * 10))
    v_Ic7300_vars.Civ_out.extend(int_to_3bcd((lf + min + span) * 10))
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 7
    return 1

def command_data_mode(line, input_device, tokennumber ):
    if len(line) < 3:
        return 0
    if line[2] > 3:
        return 2
    header(tokennumber)
    if line[2] == 0:
        v_Ic7300_vars.Civ_out.extend([0x00,0x00])
    else:
        v_Ic7300_vars.Civ_out.extend([0x01])
        v_Ic7300_vars.Civ_out.extend([line[2]])
    v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1

def command_tone_frequency(line, input_device, tokennumber ):
    if len(line) < 3:
        return 0
    if line[2] > 49:
        return 2
    header(tokennumber)
    v_Ic7300_vars.Civ_out.extend(bytearray(v_Ic7300_vars.tone_frequency[line[2]]))
    v_Ic7300_vars.Civ_out.extend([0xfd])
    v_sk.len[input_device][0] = len(line)
    return 1

def command_rit(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    header(tokennumber)
    ret, temp = int_to_bcd_plusminus(line, 9999, 2, 1)
    if ret == 1:
        v_Ic7300_vars.Civ_out.extend(temp)
        v_Ic7300_vars.Civ_out.extend(bytearray([0xfd]))
        v_sk.len[input_device][0] = len(line)
    else:
        return ret
    return 1

def command_scope_span(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 7:
        return 2
    span = bytearray([0x00, 0x00])
    if line[2] == 0:
        span = bytearray([0x25, 0x00])
    elif line[2] == 1:
        span = bytearray([0x50, 0x00])
    elif line[2] == 2:
        span = bytearray([0x00, 0x01])
    elif line[2] == 3:
        span = bytearray([0x50, 0x02])
    elif line[2] == 4:
        span = bytearray([0x00, 0x05])
    elif line[2] == 5:
        span = bytearray([0x00, 0x10])
    elif line[2] == 6:
        span = bytearray([0x00, 0x25])
    elif line[2] == 7:
        span = bytearray([0x00, 0x50])
    header(tokennumber)
    v_Ic7300_vars.Civ_out.extend(bytearray([0x00,0x00, span[0], span[1], 0x00, 0x00, 0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1

def command_mode_data_filter(line, input_device, tokennumber):
    if len(line) < 5:
        return  0
    if line[2] > 1 or line[3] > 11 or line[4] > 2:
        return 2
    mode_data = 0
    mode = line[3]
    if mode > 7:
        # Data
        mode_data = 1
        mode -= 8
        if mode == 3:
            mode= 5
    header(tokennumber)
    v_Ic7300_vars.Civ_out.extend(bytearray([line[2]]))
    v_Ic7300_vars.Civ_out.extend(bytearray([mode, mode_data,line[4] + 1, 0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1

def command_scope_reference_level(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 80:
        return 2
    intvalue = line[2]
    negative = 0
    if intvalue> 40:
        intvalue -= 40
    else:
        intvalue = 40 - intvalue
        negative = 1
    header(tokennumber)
    v_Ic7300_vars.Civ_out.extend(bytearray([0x00]))
    v_Ic7300_vars.Civ_out.extend(int_to_bcd((intvalue // 2), 1))
    if intvalue % 2 == 0:
        v_Ic7300_vars.Civ_out.extend(bytearray([0x00]))
    else:
        v_Ic7300_vars.Civ_out.extend(bytearray([0x50]))
    v_Ic7300_vars.Civ_out.extend(bytearray([negative, 0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1

def command_memoryx(memory):
    # request memory data
    temp = int_to_bcd(memory + 1, 2)
    v_Ic7300_vars.Civ_out = bytearray([0xFE, 0xFE, 0x94, 0xE0, 0x1a, 0x00, temp[0], temp[1], 0xfd])
    return

def command_memory_x(line, length):
    if len(line) < length:
        return 0
    if line[2] > 101:
        return 2
    return 1

def command_memory_xx(line, input_device, tokennumber):
    if v_Ic7300_vars.ask_content == 0:
        command_memoryx(line[2])
        v_Ic7300_vars.ask_content = 1
        return 3
    elif v_Ic7300_vars.ask_content == 1:
        return 0
    else:
        # old memory content available
        header(tokennumber)
        v_Ic7300_vars.Civ_out.extend(v_Ic7300_vars.actual_memory_content)
        v_sk.len[input_device][0] = len(line)
        v_Ic7300_vars.ask_content = 0
        if v_Ic7300_vars.actual_v_m == 1:
            v_Ic7300_vars.update_memory = 1
    return 1

def command_memory_frequency_x(line, input_device, tokennumber, adder):
    ret = command_memory_x(line, 7)
    if ret != 1:
        return ret
    ret, freq = command_frequencyxx(line[3:7], 4, 69000000, 30000, 4)
    if ret == 2:
        return ret
    ret = command_memory_xx(line, input_device, tokennumber)
    if ret != 1:
        return  ret
    v_Ic7300_vars.Civ_out[9 + adder:13 + adder] = freq
    return 1

def command_memory_frequency(line, input_device, tokennumber):
    return command_memory_frequency_x(line, input_device, tokennumber, 0)

def command_memory_frequency_split(line, input_device, tokennumber):
    return command_memory_frequency_x(line, input_device, tokennumber, 14)

def command_memory_mode_x(line, input_device, tokennumber, adder):
    ret = command_memory_x(line, 4)
    if ret != 1:
        return ret
    ret, mode = command_modexx(line, 4)
    if ret == 2:
        return ret
    ret = command_memory_xx(line, input_device, tokennumber)
    if ret != 1:
        return ret
    v_Ic7300_vars.Civ_out[14 +  adder] = mode
    return 1

def command_memory_mode(line, input_device, tokennumber):
    return command_memory_mode_x(line, input_device, tokennumber, 0)

def command_memory_mode_split(line, input_device, tokennumber):
    return command_memory_mode_x(line, input_device, tokennumber, 14)

def command_memory_filter_x(line, input_device, tokennumber, adder):
    ret = command_memory_x(line, 4)
    if ret != 1:
        return ret
    if line[3] > 2:
        return 2
    ret = command_memory_xx(line, input_device, tokennumber)
    if ret != 1:
        return ret
    v_Ic7300_vars.Civ_out[15+ adder] = line[3] + 1
    return 1

def command_memory_filter(line, input_device, tokennumber):
    return command_memory_filter_x(line, input_device, tokennumber, 0)

def command_memory_filter_split(line, input_device, tokennumber):
    return command_memory_filter_x(line, input_device, tokennumber, 14)

def command_memory_tone_x(line, input_device, tokennumber, adder):
    ret = command_memory_x(line, 4)
    if ret != 1:
        return ret
    if line[3] > 2:
        return 2
    ret = command_memory_xx(line, input_device, tokennumber)
    if ret != 1:
        return ret
    # low nibble
    v_Ic7300_vars.Civ_out[16 + adder] = (v_Ic7300_vars.Civ_out[16 + adder] & 0xf0) + line[3]
    v_sk.len[input_device][0] = len(line)
    v_Ic7300_vars.ask_content = 0
    return 1

def command_memory_tone(line, input_device, tokennumber):
    return command_memory_tone_x(line, input_device, tokennumber, 0)

def command_memory_tone_split(line, input_device, tokennumber):
    return command_memory_tone_x(line, input_device, tokennumber, 14)

def command_memory_data_mode_x(line, input_device, tokennumber, adder):
    ret = command_memory_x(line, 4)
    if ret != 1:
        return ret
    if line[3] > 1:
        return 2
    ret = command_memory_xx(line, input_device, tokennumber)
    if ret != 1:
        return ret
    # high nibble
    v_Ic7300_vars.Civ_out[16+ adder] = (v_Ic7300_vars.Civ_out[16 + adder] & 0x0f) + line[3] * 16
    v_sk.len[input_device][0] = len(line)
    v_Ic7300_vars.ask_content = 0
    return 1

def command_memory_data_mode(line, input_device, tokennumber):
    return command_memory_data_mode_x(line, input_device, tokennumber, 0)

def command_memory_data_mode_split(line, input_device, tokennumber):
    return command_memory_data_mode_x(line, input_device, tokennumber, 14)

def command_memory_tone_frequency_x(line, input_device, tokennumber, adder):
    ret = command_memory_x(line, 4)
    if ret != 1:
        return ret
    if line[3] > 49:
        return 2
    ret = command_memory_xx(line, input_device, tokennumber)
    if ret != 1:
        return ret
    v_Ic7300_vars.Civ_out[18 + adder:20 + adder] = v_Ic7300_vars.tone_frequency[line[3]]
    v_sk.len[input_device][0] = len(line)
    v_Ic7300_vars.ask_content = 0
    return 1

def command_memory_tone_frequency(line, input_device, tokennumber):
    return command_memory_tone_frequency_x(line, input_device, tokennumber, 0)

def command_memory_tone_frequency_split(line, input_device, tokennumber):
    return command_memory_tone_frequency_x(line, input_device, tokennumber, 14)

def command_memory_tone_squelch_x(line, input_device, tokennumber, adder):
    ret = command_memory_x(line, 4)
    if ret != 1:
        return ret
    if line[3] > 50:
        return 2
    ret = command_memory_xx(line, input_device, tokennumber)
    if ret != 1:
        return ret
    v_Ic7300_vars.Civ_out[21 + adder:23 + adder] = v_Ic7300_vars.tone_frequency[line[3]]
    v_sk.len[input_device][0] = len(line)
    v_Ic7300_vars.ask_content = 0
    return 1

def command_memory_tone_squelch(line, input_device, tokennumber):
    return command_memory_tone_squelch_x(line, input_device, tokennumber, 0)

def command_memory_tone_squelch_split(line, input_device, tokennumber):
    return command_memory_tone_squelch_x(line, input_device, tokennumber, 14)

def command_memory_name(line, input_device, tokennumber):
    ret = command_memory_x(line, 4)
    if ret != 1:
        return ret
    length = line[3]
    if length == 0:
        return 1
    if length > 10:
        return 2
    if len(line) < length + 4:
        return 0
    # fill rest with space
    temp = 0
    name = bytearray([])
    while temp < 10:
        if temp < length:
            ok = cwchars((line[temp + 4]), 0)
            if ok == 1:
                name.extend([line[temp + 4]])
        else:
            name.extend([0x20])
        temp += 1
    name.extend([0xfd])
    ret = command_memory_xx(line, input_device, tokennumber)
    if ret != 1:
        return ret
    v_Ic7300_vars.Civ_out[37:] = name
    v_sk.len[input_device][0] = len(line)
    v_Ic7300_vars.ask_content = 0
    return 1

def command_copy_band_stack(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    if line[2] > 1 or line[3] >  10:
        return 2
    if v_Ic7300_vars.ask_content == 0:
        header(tokennumber)
        temp = int_to_bcd_int((line[3] % 11) + 1)
        v_Ic7300_vars.Civ_out.extend(bytearray([temp, line[2] + 2, 0xfd]))
        v_sk.len[input_device][0] = len(line)
        v_Ic7300_vars.ask_content = 1
        return 3
    elif v_Ic7300_vars.ask_content == 1:
        pass
    elif v_Ic7300_vars.ask_content == 2:
        # the command must not have the register code parameter (1 - 3; latest...)
        header(tokennumber)
        print(v_Ic7300_vars.Civ_out, v_Ic7300_vars.band_stack)
        v_Ic7300_vars.Civ_out.extend(v_Ic7300_vars.band_stack)
        # copy to lastest stack
        v_Ic7300_vars.Civ_out[7] = 1
        v_Ic7300_vars.ask_content = 0
    return 1

def com240(line, input_device, tokennumber):
    if len(line) < 6:
        return 0
    start_line = line[2] * 256 + line[3]
    if start_line >= v_announcelist.number_of_lines:
        write_log("startline for announcecommand too high: " + str(start_line))
        return 2
    number_of_lines = line[4] * 256 + line[5]
    if number_of_lines > v_announcelist.number_of_lines:
        write_log("number of lines for announcecommand too high: " + str(number_of_lines))
        return 2
    if number_of_lines > 0:
        output = bytearray([0xff, 0xf0])
        output.extend(line[2:6])
        i = 0
        while i < number_of_lines:
            output.extend(str_to_bytearray(v_announcelist.full[start_line]))
            i += 1
            start_line += 1
            if start_line >= v_announcelist.number_of_lines:
                start_line = 0
        v_sk.info_to_all.extend(output)
    v_sk.len[input_device][0] = len(line)
    return 1

def com252(line, input_device, tokennumber):
    v_sk.info_to_all = bytearray([0xff, 0xfc])
    if v_Ic7300_vars.error_cmd_no == 255:
        temp = "no error"
    else:
        temp = "command: " + str(v_Ic7300_vars.command_no) + " last error at command: " + str(v_Ic7300_vars.error_cmd_no)
        temp += " : " + v_Ic7300_vars.last_error_msg
    v_sk.info_to_all.extend(bytearray([len(temp)]))
    v_sk.info_to_all.extend(str_to_bytearray(temp))
    v_sk.len[input_device][0] = len(line)
    return 2

def com253(line, input_device, tokennumber):
    v_sk.info_to_all = bytearray([0xff, 0xfd, 0x04])
    v_sk.len[input_device][0] = len(line)
    return 1

def com254(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    if line[2] >  5:
        return 2
    if line[2] == 0:
        length = line[3]
        if length > 20 or length == 0:
            return 2
        if len(line) < length + 4:
            return 0
        if len(line) > length + 4:
            return 2
        v_Ic7300_vars.device_name = ba_to_str(line[5:])
    if line[2] == 1:
       v_Ic7300_vars.device_number  = line[3]
    if line[2] == 2:
        if line[3]  > 1:
            return 2
        if line[3]  == 0 and v_Ic7300_vars.telnet_active == 0:
            # not both inactive
            return 2
        v_Ic7300_vars.terminal_activ = line[3]
    if line[2] == 3:
        if line[3]  > 1:
            return 2
        if line[3]  == 0 and v_Ic7300_vars.terminal_activ == 0:
            # not both inactive
            return 2
        v_Ic7300_vars.telnet_active = line[3]
    if line[2] == 4:
        if len(line) < 5:
            return 0
        v_Ic7300_vars.telnet_port = line[3] * 256 + line[4]
    if line[2] == 5:
        v_Ic7300_vars.comport = line[3]
    v_sk.len[input_device][0] = len(line)
    create_config_file(v_Ic7300_vars.config_file, "w")
    return 1

def com255(line, input_device, tokennumber):
    if len(line) < 3:
        return  0
    if line[2] > 5:
        return 2
    v_sk.info_to_all = bytearray([0xff,0xff, line[2]])
    if line[2] == 0:
        v_sk.info_to_all.extend(bytearray([len(v_Ic7300_vars.device_name)]))
        v_sk.info_to_all.extend(str_to_bytearray(v_Ic7300_vars.device_name))
    elif line[2] == 1:
        v_sk.info_to_all.extend(bytearray([v_Ic7300_vars.device_number]))
    elif line[2] == 2:
        v_sk.info_to_all.extend(bytearray([v_Ic7300_vars.terminal_activ]))
    elif line[2] == 3:
        v_sk.info_to_all.extend(bytearray([v_Ic7300_vars.telnet_active]))
    elif line[2] == 4:
        v_sk.info_to_all.extend(bytearray([v_Ic7300_vars.telnet_port]))
    elif line[2] == 5:
        v_sk.info_to_all.extend(bytearray([v_Ic7300_vars.comportnumber]))
    v_sk.len[input_device][0] = len(line)
    return 1

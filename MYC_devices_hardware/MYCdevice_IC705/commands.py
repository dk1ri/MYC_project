"""
name: commands.py IC705
last edited: 20240311
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)
handling of sk input commands
output to civ
"""


import time

from misc_functions import *
from init import create_config_file


import v_announcelist
import v_sk
import v_icom_vars
import v_error_msg
import serial
import v_fix_tables


def nop(line, input_device, tokennumber):
    return 1


def header(tokennumber):
    v_icom_vars.Civ_out = bytearray([0xfe, 0xfe, v_icom_vars.civ_address, 0xe0])
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[2] == 0:
        # add command and up to three subcommands
        v_icom_vars.Civ_out.extend(bytearray([temp[3]]))
        try:
            v_icom_vars.Civ_out.extend(bytearray([temp[4]]))
            try:
                v_icom_vars.Civ_out.extend(bytearray([temp[5]]))
                try:
                    v_icom_vars.Civ_out.extend(bytearray([temp[6]]))
                except IndexError:
                    pass
            except IndexError:
                pass
        except IndexError:
            pass
    elif temp[2] == 1:
        # add command and up to three subcommands
        v_icom_vars.Civ_out.extend(bytearray([temp[6]]))
        try:
            v_icom_vars.Civ_out.extend(bytearray([temp[7]]))
            try:
                v_icom_vars.Civ_out.extend(bytearray([temp[8]]))
                try:
                    v_icom_vars.Civ_out.extend(bytearray([temp[9]]))
                except IndexError:
                    pass
            except IndexError:
                pass
        except IndexError:
            pass
    elif temp[2] == 2:
        # add command and up to three subcommands
        v_icom_vars.Civ_out.extend(bytearray([temp[8]]))
        try:
            v_icom_vars.Civ_out.extend(bytearray([temp[9]]))
            try:
                v_icom_vars.Civ_out.extend(bytearray([temp[10]]))
                try:
                    v_icom_vars.Civ_out.extend(bytearray([temp[11]]))
                except IndexError:
                    pass
            except IndexError:
                pass
        except IndexError:
            pass
    elif temp[2] == 3:
        # add command and up to three subcommands
        v_icom_vars.Civ_out.extend(bytearray([temp[10]]))
        try:
            v_icom_vars.Civ_out.extend(bytearray([temp[11]]))
            try:
                v_icom_vars.Civ_out.extend(bytearray([temp[12]]))
                try:
                    v_icom_vars.Civ_out.extend(bytearray([temp[13]]))
                except IndexError:
                    pass
            except IndexError:
                pass
        except IndexError:
            pass
    elif temp[2] == 9:
        # add command and up to three subcommands
        v_icom_vars.Civ_out.extend(bytearray([temp[6]]))
        try:
            v_icom_vars.Civ_out.extend(bytearray([temp[7]]))
            try:
                v_icom_vars.Civ_out.extend(bytearray([temp[8]]))
                try:
                    v_icom_vars.Civ_out.extend(bytearray([temp[9]]))
                except IndexError:
                    pass
            except IndexError:
                pass
        except IndexError:
            pass
    elif temp[2] == 10:
        # add command and up to two subcommands
        v_icom_vars.Civ_out.extend(bytearray([temp[4]]))
        try:
            v_icom_vars.Civ_out.extend(bytearray([temp[5]]))
            try:
                v_icom_vars.Civ_out.extend(bytearray([temp[6]]))
                try:
                    v_icom_vars.Civ_out.extend(bytearray([temp[7]]))
                except IndexError:
                    pass
            except IndexError:
                pass
        except IndexError:
            pass
    elif temp[2] == 11:
        # add command and up to two subcommands
        v_icom_vars.Civ_out.extend(bytearray([temp[4]]))
        try:
            v_icom_vars.Civ_out.extend(bytearray([temp[5]]))
            try:
                v_icom_vars.Civ_out.extend(bytearray([temp[6]]))
                try:
                    v_icom_vars.Civ_out.extend(bytearray([temp[7]]))
                except IndexError:
                    pass
            except IndexError:
                pass
        except IndexError:
            pass
    return


def check_country(country):
    if country == 0:
        return 1
    elif country == v_icom_vars.country:
        return 1
    else:
        return 2


def u_command1(line, input_device, tokennumber):
    # for commands with one byte parameter or variable subcommand without parameter
    # no gaps in parameter or subcommand
    # up to 3 parameter
    if len(line) < 2:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if check_country(temp[0]) == 2:
        return 2
    if temp[2] != 11:
        if len(line) < temp[1]:
            return 0
        if temp[2] == 0:
            header(tokennumber)
            v_icom_vars.Civ_out.extend(bytearray([0xfd]))
        elif temp[2] == 1:
            # one parameter
            if line[2] > temp[4]:
                return 2
            header(tokennumber)
            line[2] += temp[5]
            if temp[3] == 0:
                v_icom_vars.Civ_out.extend(bytearray([line[2]]))
            elif temp[3] == 1:
                v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 1))
            elif temp[3] == 2:
                v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 2))
            v_icom_vars.Civ_out.extend(bytearray([0xfd]))
            v_sk.parameter = line[2]
        elif temp[2] == 2:
            # two parameter
            if line[2] > temp[4]:
                return 2
            if line[3] > temp[6]:
                return 2
            header(tokennumber)
            line[2] += temp[5]
            line[3] += temp[7]
            if temp[3] == 0:
                v_icom_vars.Civ_out.extend(bytearray([line[2]]))
                v_icom_vars.Civ_out.extend(bytearray([line[3]]))
            elif temp[3] == 1:
                v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 1))
                v_icom_vars.Civ_out.extend(int_to_bcd(line[3], 1))
            elif temp[3] == 2:
                v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 2))
                v_icom_vars.Civ_out.extend(int_to_bcd(line[3], 2))
            v_icom_vars.Civ_out.extend(bytearray([0xfd]))
            v_sk.parameter = line[2]
        elif temp[2] == 3:
            # three parameter
            if line[2] > temp[4]:
                return 2
            if line[3] > temp[6]:
                return 2
            if line[4] > temp[8]:
                return 2
            header(tokennumber)
            line[2] += temp[5]
            line[3] += temp[7]
            line[4] += temp[9]
            # add three parameters
            if temp[3] == 0:
                v_icom_vars.Civ_out.extend(bytearray([line[2]]))
                v_icom_vars.Civ_out.extend(bytearray([line[3]]))
                v_icom_vars.Civ_out.extend(bytearray([line[4]]))
            elif temp[3] == 1:
                v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 1))
                v_icom_vars.Civ_out.extend(int_to_bcd(line[3], 1))
                v_icom_vars.Civ_out.extend(int_to_bcd(line[4], 1))
            elif temp[3] == 2:
                v_icom_vars.Civ_out.extend(bytearray(int_to_bcd(line[2], 2)))
                v_icom_vars.Civ_out.extend(bytearray(int_to_bcd(line[3], 2)))
                v_icom_vars.Civ_out.extend(bytearray(int_to_bcd(line[4], 2)))
            v_icom_vars.Civ_out.extend(bytearray([0xfd]))
            v_sk.parameter = line[2]
        elif temp[2] == 9:
            # one 2 byte parameter
            temp1 = line[2] * 256 + line[3]
            temp2 = temp[4] * 256 + temp[5]
            if temp1 > temp2:
                return 2
            header(tokennumber)
            temp1 += temp[6]
            if temp[3] == 3:
                v_icom_vars.Civ_out.extend(int_to_bcd(temp1, 3))
            else:
                if temp[3] == 2:
                    v_icom_vars.Civ_out.extend(int_to_bcd(temp1, 2))
            v_icom_vars.Civ_out.extend(bytearray([0xfd]))
        elif temp[2] == 10:
            header(tokennumber)
            # add commnd and up two subcommands
            v_icom_vars.Civ_out.extend(bytearray([temp[4]]))
            try:
                v_icom_vars.Civ_out.extend(bytearray([temp[5]]))
            except IndexError:
                pass
            try:
                v_icom_vars.Civ_out.extend(bytearray([temp[6]]))
            except IndexError:
                pass
            # add value
            v_icom_vars.Civ_out.extend(bytearray([temp[3]]))
            v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    else:
        # string
        if len(line) > 2:
            length = line[2]
            if length != 0:
                if length > temp[1]:
                    return 2
                if len(line) < length + 3:
                    return 0
                header(tokennumber)
                temp2 = 0
                temp1 = 3
                one_min = 0
                while temp2 < length:
                    if check_and_convert_alphabet(line[temp1], temp[3]) != 255:
                        v_icom_vars.Civ_out.extend([line[temp1]])
                        one_min = 1
                    temp1 += 1
                    temp2 += 1
                if one_min == 1:
                    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
                else:
                    v_icom_vars.Civ_out.extend([0])
        else:
            return 0
    return 1


def u_command2(line, input_device, tokennumber):
    # for commands with two byte parameter up to 9999 to 2byte bcd
    # no adder possible
    # up to 3 parameter
    if len(line) < 2:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if check_country(temp[0]) == 2:
        return 2
    if len(line) < temp[1]:
        return 0
    # temp[2]: number of parameters
    if temp[2] == 0:
        # not used
        header(tokennumber)
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    elif temp[2] == 1:
        limit1 = temp[4] * 256 + temp[5]
        parameter1 = line[2] * 256 + line[3]
        if parameter1 > limit1:
            return 2
        header(tokennumber)
        v_icom_vars.Civ_out.extend(int_to_bcd(parameter1, 2))
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
        v_sk.parameter = line[2]
    elif temp[2] == 2:
        limit1 = temp[4] * 256 + temp[5]
        limit2 = temp[6] * 256 + temp[7]
        parameter1 = line[2] * 256 + line[3]
        parameter2 = line[4] * 256 + line[5]
        if parameter1 > limit1:
            return 2
        if parameter2 > limit2:
            return 2
        header(tokennumber)
        parameter1 += temp[5]
        parameter2 += temp[5]
        # add two parameters
        v_icom_vars.Civ_out.extend(int_to_bcd(parameter1, 2))
        v_icom_vars.Civ_out.extend(int_to_bcd(parameter2, 2))
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
        v_sk.parameter = line[2]
    elif temp[2] == 3:
        limit1 = temp[4] * 256 + temp[5]
        limit2 = temp[6] * 256 + temp[7]
        limit3 = temp[8] * 256 + temp[9]
        parameter1 = line[2] * 256 + line[3]
        parameter2 = line[4] * 256 + line[5]
        parameter3 = line[6] * 256 + line[7]
        if parameter1 > limit1:
            return 2
        if parameter2 > limit2:
            return 2
        if parameter3 > limit3:
            return 2
        header(tokennumber)
        parameter1 += temp[5]
        parameter2 += temp[5]
        parameter3 += temp[5]
        # add three parameters
        v_icom_vars.Civ_out.extend(int_to_bcd(parameter1, 2))
        v_icom_vars.Civ_out.extend(int_to_bcd(parameter2, 2))
        v_icom_vars.Civ_out.extend(int_to_bcd(parameter3, 2))
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
        v_sk.parameter = line[2]
    return 1


def u_command3(line, input_device, tokennumber):
    # for commands with one two byte parameter up to 999999 to 3byte bcd
    # no adder possible
    if len(line) < 2:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if check_country(temp[0]) == 2:
        return 2
    if len(line) < temp[1]:
        return 0
    limit1 = temp[4] * 256 + temp[5]
    parameter1 = line[2] * 256 + line[3]
    if parameter1 > limit1:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd(parameter1 * 10, 3))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.parameter = line[2]
    return 1


def command_frequency(line, limit, adder, civbytes):
    # line contain frequency only
    # convert line with limit to civbytes bcd LSB first
    # return ba
    frequency = frequency_from_line((line))
    if frequency > limit:
        return 2, 0
    # < 200MHz
    if frequency < 199970000:
        frequency += adder
    else:
        # 400000000 - 199970000
        frequency += 200000000 + adder
    decimal_string = str(frequency)
    digits = [int(c) for c in decimal_string]
    # fill preceeding "0"
    source = len(bytearray(digits))
    destination = 0
    temp = bytearray(civbytes)
    while source > 0:
        if source == 1:
            temp[destination] = digits[source - 1]
        else:
            temp[destination] = digits[source - 2] * 16 + digits[source - 1]
        source -= 2
        destination += 1
    return 1, temp


def frequency_from_line(line):
    tempa = len(line)
    multiplier = 1
    frequency = 0
    while tempa > 0:
        tempb = line[tempa - 1] * multiplier
        frequency += tempb
        multiplier *= 256
        tempa -= 1
    return frequency


def command_frequency_from_int(frequency):
    #
    # convert line with limit to 5 bytes bcd LSB first
    # return ba
    decimal_string = str(frequency)
    digits = [int(c) for c in decimal_string]
    # fill preceeding "0"
    source = len(bytearray(digits))
    destination = 0
    temp = bytearray(5)
    while source > 0:
        if source == 1:
            temp[destination] = digits[source - 1]
        else:
            temp[destination] = digits[source - 2] * 16 + digits[source - 1]
        source -= 2
        destination += 1
    return temp


def command_memory(line, input_device, tokennumber):
    # generate the ask command
    if len(line) < 4:
        return 0
    # loading the memory content
    temp = line[2] * 256 + line[3]
    if tokennumber == 401 or tokennumber == 402:
        # no split for name
        if temp > 10003:
            return 2
    else:
        if temp > 20007:
            return 2
    # split the memoryaddress
    if v_icom_vars.ask_content == 99:
        # raw (no split)
        if temp < 10000:
            # no call no split 0 - 9999
            v_icom_vars.vfo_split = 0
            group = int_to_bcd(temp // 100, 2)
            memory = int_to_bcd(temp % 100, 2)
        else:
            group = [0x01, 0x00]
            memory = [0x0,temp - 10000]
    else:
        if temp < 10000:
            # no call no split 0 - 9999
            v_icom_vars.vfo_split = 0
            group = int_to_bcd(temp // 100, 2)
            memory = int_to_bcd(temp % 100, 2)
        elif temp < 20000:
            # no call, split 10000 - 19999
            v_icom_vars.vfo_split = 1
            temp -= 10000
            group = int_to_bcd(temp // 100, 2)
            memory = int_to_bcd(temp % 100, 2)
        elif temp < 20003:
            # call  no split 20000 - 10002
            v_icom_vars.vfo_split = 0
            group = [0x01, 0x00]
            memory = [0x0, temp - 20000]
        else:
            # call split, 20003 - 20005
            v_icom_vars.vfo_split = 1
            group = [0x01, 0x00]
            memory = [temp - 20003]
    # start getting memorycontent
    header(tokennumber)
    v_icom_vars.Civ_out.extend(group)
    v_icom_vars.Civ_out.extend(memory)
    v_icom_vars.Civ_out.extend([0xfd])
    if v_icom_vars.ask_content == 0:
        v_icom_vars.ask_content = 1
    return 1


def commandou(line, input_device, tokennumber):
    # for simple ou (0  and 1 only) no civ parameter
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if check_country(temp[0]) == 2:
        return 2
    if line[2] > 1:
        return 2
    if line[2] == 0:
        return 1
    else:
        header(tokennumber)
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
        return 1

def command_frequency4(frequency):
    # convert kHz with b bytes starting at pos with limit to 4 bcd LSB first
    # return ba
    # 100 Hz must be set to 0
    decimal_string = str(frequency * 10)
    fstring = [int(c) for c in decimal_string]
    # fill preceeding "0"
    temp = 0
    diff = 8 - len(fstring)
    dig = []
    while temp < 8:
        if temp < diff:
            dig.append(0)
        else:
            dig.append(fstring[temp - diff])
        temp += 1
    source = len(dig)
    destination = 0
    temp = bytearray([])
    while destination < 4:
        temp.extend([dig[source - 2] * 16 + dig[source - 1]])
        source -= 2
        destination += 1
    return temp


def command_frequency00(line, input_device, tokennumber):
    # frequenz
    if len(line) < 6:
        return 0
    ret, temp = command_frequency(line[2:7], 269970000, 30000, 5)
    if ret != 1:
        return ret
    else:
        header(tokennumber)
        v_icom_vars.Civ_out.extend(temp)
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_mode(line, input_device, tokennumber):
    # mode
    if len(line) < 4:
        return 0
    if line[2] > 9:
        return 2
    if line[2] == 9:
        line[2] = 0x17
    if line[3] > 2:
        return 2
    v_icom_vars.last_mode = line[2]
    header(tokennumber)
    v_icom_vars.Civ_out.extend([line[2]])
    v_icom_vars.Civ_out.extend([line[3] + 1])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_icom_vars.last_mode = line[2]
    return 1


def command_vfo_memory(line, input_device, tokennumber):
    # vfo / memory
    if len(line) < 3:
        return 0
    if line[2] > 1:
        return 2
    header(tokennumber)
    if line[2] == 0:
        # vfo
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    else:
        # memory
        v_icom_vars.Civ_out[4] = 8
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_icom_vars.last_vfo_mem = line[2]
    return 1


def command_vfo_mode(line, input_device, tokennumber):
    # vfo mode
    if len(line) < 3:
        return 0
    if line[2] > 3:
        return 2
    header(tokennumber)
    if line[2] < 2:
        v_icom_vars.Civ_out.extend([line[2]])
    elif line[2] == 2:
        v_icom_vars.Civ_out.extend([0xa0])
    else:
        v_icom_vars.Civ_out.extend([0xb0])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    if line[2] == 0 or line[2] == 1:
        v_icom_vars.last_vfo_mem = line[2]
    return 1


def command_select_memory(line, input_device, tokennumber):
    # select memory
    if len(line) < 3:
        return 0
    if line[2] > 103:
        return 2
    header(tokennumber)
    if line[2] < 100:
        # set last memory group
        v_icom_vars.Civ_out.extend([0x00, int.from_bytes (int_to_bcd(v_icom_vars.last_memory_group, 1),"big"), 0xfd])
        v_icom_vars.Civ_out.extend([0xfe, 0xfe, v_icom_vars.civ_address, 0xe0,0x08,0x00,line[2]])
    else:
        # set call group
        v_icom_vars.Civ_out.extend([0x01, 0x00, 0xfd])
        v_icom_vars.Civ_out.extend([0xfe, 0xfe, v_icom_vars.civ_address, 0xe0, 0x08, 0x00, line[2] - 100])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_select_memory_group(line, input_device, tokennumber):
    # select memory group
    if len(line) < 3:
        return 0
    if line[2] > 100:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend([0x00, int.from_bytes(int_to_bcd(line[2], 1),"big")])
    v_icom_vars.start_memory_no = line[2]
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_icom_vars.last_memory_group = line[2]
    return 1


def command_memory_fuction(line, input_device, tokennumber):
    # vfo memory function
    if len(line) < 3:
        return 0
    if line[2] > 3:
        return 2
    if line[2] == 0:
        return 1
    else:
        header(tokennumber)
        if line[2] == 1:
            v_icom_vars.Civ_out[4] = 0x09
        elif line[2] == 2:
            v_icom_vars.Civ_out[4] = 0x0a
        elif line[2] == 3:
            v_icom_vars.Civ_out[4] = 0x0b
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
        return 1


def commandoffset_f(line, input_device, tokennumber):
    # offset frequency
    if len(line) < 5:
        return 0
    ret, temp = command_frequency(line[2:6], 99999, 0, 3)
    if ret != 1:
        return ret
    header(tokennumber)
    v_icom_vars.Civ_out.extend(temp)
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_scan_mode(line, input_device, tokennumber):
    # scan mode
    if len(line) < 3:
        return 0
    if line[2] > 8:
        return 2
    header(tokennumber)
    if line[2] < 4:
        v_icom_vars.Civ_out.extend([line[2]])
    elif line[2] < 6:
        v_icom_vars.Civ_out.extend([line[2] + 14])
    else:
        v_icom_vars.Civ_out.extend([line[2] + 28])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1

def set_clear_select_chanal(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 8:
        return 2
    header(tokennumber)
    if line[2] == 1:
        v_icom_vars.Civ_out = bytearray([0xfe, 0xfe, v_icom_vars.civ_address, 0xe0, 0x0e, 0xB0, 0xfd])
    else:
        v_icom_vars.Civ_out = bytearray([0xfe, 0xfe, v_icom_vars.civ_address, 0xe0, 0x0e, 0xB1, 0xfd])
    return 1

def command_scan_resume(line, input_device, tokennumber):
    # scan resume
    if len(line) < 3:
        return 0
    if line[2] > 1:
        return 2
    header(tokennumber)
    if line[2] == 0:
        v_icom_vars.Civ_out.extend([0xd0, 0xfd])
    else:
        v_icom_vars.Civ_out.extend([0xd3, 0xfd])
    return 1


def command_split(line, input_device, tokennumber):
    # split
    if len(line) < 3:
        return 0
    if line[2] > 4:
        return 2
    header(tokennumber)
    if line[2] < 2:
        v_icom_vars.Civ_out.extend([line[2], 0xfd])
    else:
        v_icom_vars.Civ_out.extend([line[2] + 14, 0xfd])
    return 1


def command_attenuator(line, input_device, tokennumber):
    # attenuator
    if len(line) < 3:
        return 0
    if line[2] > 1:
        return 2
    header(tokennumber)
    if line[2] == 0:
        v_icom_vars.Civ_out.extend([0x00, 0xfd])
    else:
        v_icom_vars.Civ_out.extend([0x20, 0xfd])
    return 1

def speach(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 3:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend([line[2] - 1, 0xfd])

def command_tone_squelch(line, input_device, tokennumber):
    # tone squelch
    if len(line) < 3:
        return 0
    if line[2] > 8:
        return 2
    header(tokennumber)
    if line[2] < 4:
        v_icom_vars.Civ_out.extend([line[2], 0xfd])
    else:
        v_icom_vars.Civ_out.extend([line[2] + 2, 0xfd])
    return 1


def command_memory_keyer(line, input_device, tokennumber):
    # 8 chanal memory keyer
    if len(line) < 4:
        return 0
    if line[2] > 7:
        return 2
    cwlen = line[3]
    if len(line) < (cwlen + 4):
        return 0
    if cwlen == 0 or cwlen > 70:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(bytearray([line[2] + 1]))
    temp1 = 0
    temp2 = 4
    while temp1 < cwlen:
        if check_and_convert_alphabet(line[temp2], 5):
            v_icom_vars.Civ_out.extend(bytearray([line[temp2]]))
        temp1 += 1
        temp2 += 1
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_memory_raw(line, input_device, tokennumber):
    # send raw memory
    if len(line) < 111:
        return 0
    mem = line[2] * 256 + line[3]
    if mem > 10004:
        return 2
    header(tokennumber)
    if mem <= 10000:
        group = mem // 100
        memory = mem % 100
        v_icom_vars.Civ_out.extend(group.to_bytes(2, byteorder="big"))
        v_icom_vars.Civ_out.extend(memory.to_bytes(2, byteorder="big"))
    else:
        v_icom_vars.Civ_out.extend(0x01, 0x00)
        memory = mem - 10000
        v_icom_vars.Civ_out.extend(memory.to_bytes(2, byteorder="big"))
    v_icom_vars.Civ_out.extend(line[4:111])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def answercommand_memory(line, input_device, tokennumber):
    # send memory ask command
    if tokennumber == 372:
        # raw data
        v_icom_vars.ask_content = 99
    else:
        v_icom_vars.ask_content = 4
    ret = command_memory(line, input_device, tokennumber)
    return ret

def for_all_command_memory(line, input_device, tokennumber):
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        return v_icom_vars.ask_content

def command_memory_frequency(line, input_device, tokennumber):
    # memory frequency
    ret = for_all_command_memory(line, input_device, tokennumber)
    if ret != 2:
        return ret
    else:
        if len(line) < 8:
            return 0
        frequ = line[4] * 16777216 + line[5] * 65536 + line[6] * 256 + line[7]
        if frequ > 269970000:
            return 2
        header(tokennumber)
        # modify content
        ret, frequ = command_frequency(line[4:8], 470000000, 30000, 5)
        if ret == 1:
            v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
            pointer = 11 + v_icom_vars.vfo_split * 47
            v_icom_vars.Civ_out[pointer:pointer +5] = frequ
            v_icom_vars.ask_content = 0
            return 1
        else:
            return ret


def command_memory_split_select(line, input_device, tokennumber):
    # memory split select
    ret = for_all_command_memory(line, input_device, tokennumber)
    if ret != 2:
        return ret
    else:
        if len(line) < 6:
            return 0
        if line[4] > 1 or line[5] > 3:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        # modify content
        temp = line[4] * 16 + line[5]
        pointer = 11 + v_icom_vars.vfo_split * 47
        v_icom_vars.Civ_out[pointer] = temp
        v_icom_vars.ask_content = 0
        return 1


def command_memory_mode(line, input_device, tokennumber):
    # memory mode filter
    ret = for_all_command_memory(line, input_device, tokennumber)
    if ret != 2:
        return ret
    else:
        if len(line) < 5:
            return 0
        if line[4] > 9:
            return 2
        if line[5] > 2:
            return 2
        header(tokennumber)
        # modify content
        pointer = 16 + v_icom_vars.vfo_split * 47
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        if line[4] == 9:
            line[4] = 0x17
        v_icom_vars.Civ_out[pointer] = line[4]
        v_icom_vars.Civ_out[pointer + 1] = line[5] + 1
        v_icom_vars.ask_content = 0
        return 1


def command_memory_data_mode(line, input_device, tokennumber):
    # memory data mode
    ret = for_all_command_memory(line, input_device, tokennumber)
    if ret != 2:
        return ret
    else:
        if len(line) < 5:
            return 0
        if line[4] > 1:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        if v_icom_vars.command_storage == 0:
            v_icom_vars.Civ_out[18] = line[4]
        else:
            v_icom_vars.Civ_out[65] = line[4]
        v_icom_vars.ask_content = 0
        return 1


def command_memory_duplex_tone(line, input_device, tokennumber):
    # memory duplex tone
    ret = for_all_command_memory(line, input_device, tokennumber)
    if ret != 2:
        return ret
    else:
        if len(line) < 6:
            return 0
        if line[4] > 2 or line[5] > 3:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        temp = line[4] * 16 + line[5]
        if v_icom_vars.command_storage == 0:
            v_icom_vars.Civ_out[19] = temp
        else:
            v_icom_vars.Civ_out[66] = temp
        v_icom_vars.ask_content = 0
        return 1


def command_memory_digital_squelch(line, input_device, tokennumber):
    # memory digital squelch
    ret = for_all_command_memory(line, input_device, tokennumber)
    if ret != 2:
        return ret
    else:
        if len(line) < 5:
            return 0
        if line[4] > 1:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        if line[4] == 1:
            line[4] = 0x10
        if v_icom_vars.command_storage == 0:
            v_icom_vars.Civ_out[20] = line[4]
        else:
            v_icom_vars.Civ_out[67] = line[4] + 16
        v_icom_vars.ask_content = 0
        return 1


def command_memory_repeater_tone(line, input_device, tokennumber):
    # memory memory repeater tone
    ret = for_all_command_memory(line, input_device, tokennumber)
    if ret != 2:
        return ret
    else:
        if len(line) < 5:
            return 0
        if line[4] > 49:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        if v_icom_vars.command_storage == 0:
            v_icom_vars.Civ_out[21] = 0
            v_icom_vars.Civ_out[22:24] = v_fix_tables.tone_frequency[line[4]]
        else:
            v_icom_vars.Civ_out[68] = 0
            v_icom_vars.Civ_out[69:71] = v_fix_tables.tone_frequency[line[4]]
        v_icom_vars.ask_content = 0
        return 1


def command_memory_tone_squelch(line, input_device, tokennumber):
    # memory memory tone squelch
    ret = for_all_command_memory(line, input_device, tokennumber)
    if ret != 2:
        return ret
    else:
        if len(line) < 5:
            return 0
        if line[4] > 49:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        if v_icom_vars.command_storage == 0:
            v_icom_vars.Civ_out[24] = 0
            v_icom_vars.Civ_out[25:27] = v_fix_tables.tone_frequency[line[4]]
        else:
            v_icom_vars.Civ_out[71] = 0
            v_icom_vars.Civ_out[72:74] = v_fix_tables.tone_frequency[line[4]]
        v_icom_vars.ask_content = 0
        return 1


def command_memory_dcts(line, input_device, tokennumber):
    # memory DTCS frequncy
    ret = for_all_command_memory(line, input_device, tokennumber)
    if ret != 2:
        return ret
    else:
        if len(line) < 6:
            return 0
        if line[4] > 3 or line[5] > 103:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        if v_icom_vars.command_storage == 0:
            v_icom_vars.Civ_out[27] = v_fix_tables.dtcs_pol[line[4]]
            v_icom_vars.Civ_out[28:30] = v_fix_tables.dtcs_frequency[line[5]]
        else:
            v_icom_vars.Civ_out[74] = v_fix_tables.dtcs_pol[line[4]]
            v_icom_vars.Civ_out[75:77] = v_fix_tables.dtcs_frequency[line[5]]
        v_icom_vars.ask_content = 0
        return 1


def command_memory_digital_code(line, input_device, tokennumber):
    # memory DV digital code
    ret = for_all_command_memory(line, input_device, tokennumber)
    if ret != 2:
        return ret
    else:
        if len(line) < 5:
            return 0
        if line[4] > 99:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        if v_icom_vars.command_storage == 0:
            v_icom_vars.Civ_out[30] = int_to_bcd_int(line[4])
        else:
            v_icom_vars.Civ_out[77] = int_to_bcd_int(line[4])
        v_icom_vars.ask_content = 0
        return 1


def command_duplex_offset(line, input_device, tokennumber):
    # memory duplex offset frequency
    ret = for_all_command_memory(line, input_device, tokennumber)
    if ret != 2:
        return ret
    else:
        if len(line) < 7:
            return 0
        frequency = line[4] * 65536 + line[5] * 256 + line[6]
        if frequency > 99999:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        ret, frequ = command_frequency(line[4:7], 99999, 0, 3)
        if v_icom_vars.command_storage == 0:
            v_icom_vars.Civ_out[31:34] = frequ
        else:
            v_icom_vars.Civ_out[78:81] = frequ
        v_icom_vars.ask_content = 0
        return 1

def command_memory_strings(line, input_device, tokennumber, length, alph, start, split):
    # memory strings
    ret = for_all_command_memory(line, input_device, tokennumber)
    if ret != 2:
        return ret
    else:
        if len(line) < 5:
            return 0
        if line[4] > length:
            return 2
        if len(line) < line[4] + 5:
            return 0
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        temp = bytearray(length)
        temp1 = 0
        while temp1 < length:
            if temp1 < line[4]:
                if check_and_convert_alphabet(line[temp1 + 5], alph) != 255:
                    temp[temp1] = line[temp1 + 5]
                else:
                    temp[temp1] = 0x20
            else:
                temp[temp1] = 0x20
            temp1 += 1
        if split == 0:
            v_icom_vars.Civ_out[start:start + length] = temp
        else:
            v_icom_vars.Civ_out[start + 47:start + 47 + length] = temp
        v_icom_vars.ask_content = 0
        return 1


def command_memory_UR(line, input_device, tokennumber):
    # UR
    return command_memory_strings(line, input_device, tokennumber, 8, 4, 34, 1)


def command_memory_R1(line, input_device, tokennumber):
    # R1
    return command_memory_strings(line, input_device, tokennumber, 8, 4, 42, 1)


def command_memory_R2(line, input_device, tokennumber):
    # R2
    return command_memory_strings(line, input_device, tokennumber, 8, 4, 50, 1)


def command_memory_name(line, input_device, tokennumber):
    # memory name
    return command_memory_strings(line, input_device, tokennumber, 16, 0, 105, 0)


def answer_commandbandstack(line, input_device, tokennumber):
    # read bandstack
    if len(line) < 2:
        return 0
    if line[2] > 14:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd((line[2] % 15) + 1, 1))
    v_icom_vars.Civ_out.extend([(line[2] // 15) + 1, 0xfd])
    return 1


def command_copy_bandstack(line, input_device, tokennumber):
    # copy bandstack
    if len(line) < 4:
        return 0
    if line[2] > 1 or line[3] > 14:
        return 2
    if v_icom_vars.ask_content == 0:
        header(tokennumber)
        v_icom_vars.Civ_out.extend(int_to_bcd(line[3] + 1, 1))
        v_icom_vars.Civ_out.extend([line[2] + 2, 0xfd])
        v_icom_vars.ask_content = 1
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 2:
        header(tokennumber)
        v_icom_vars.Civ_out.extend(bytearray(int_to_bcd(line[3] + 1, 1)))
        v_icom_vars.Civ_out.extend([1])
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        v_icom_vars.ask_content = 0
    return 1


def command_hpf_lpf(line, input_device, tokennumber):
    # HPF / LPF SSB
    if len(line) < 4:
        return 0
    if line[2] > 20 or line[3] > 20 or line[2] >= line[3]:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 1))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[3] + 5, 1))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_tx_bw(line, input_device, tokennumber):
    # SSB Tx wide bandwidth
    if len(line) < 4:
        return 0
    if line[2] > 3 or line[3] > 3:
        return 2
    header(tokennumber)
    line[3] *= 16
    line[3] += line[2]
    v_icom_vars.Civ_out.extend([line[3]])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_split_offset(line, input_device, tokennumber):
    # split offset
    if len(line) < 4:
        return 0
    header(tokennumber)
    ret, bcd = int_to_bcd_plusminus(line, 9999, 3, 10)
    if ret == 1:
        v_icom_vars.Civ_out.extend(bcd)
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    else:
        return ret
    return 1


def command_date(line, input_device, tokennumber):
    # date
    if len(line) < 5:
        return 0
    if line[2] > 79 or line[3] > 11 or line[4] > 30:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(bytearray([32]))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2] + 20, 1))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[3] + 1, 1))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[4] + 1, 1))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_time(line, input_device, tokennumber):
    # time
    if len(line) < 4:
        return 0
    if line[2] > 23 or line[3] > 59:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 1))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[3], 1))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_utc(line, input_device, tokennumber):
    # UTC offset
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
        v_icom_vars.Civ_out.extend(int_to_bcd(minutes // 60, 1))
        v_icom_vars.Civ_out.extend(int_to_bcd(minutes % 60, 1))
    else:
        minutes = 840 - minutes
        v_icom_vars.Civ_out.extend(int_to_bcd(minutes // 60, 1))
        v_icom_vars.Civ_out.extend(int_to_bcd(minutes % 60, 1))
        negative = 1
    v_icom_vars.Civ_out.extend(bytearray([negative]))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_scope_edge(line, input_device, tokennumber):
    # scope edge commands
    if len(line) < 7:
        return 0
    if line[2] > 3:
        return 2
    lf = line[3] * 256 + line[4]
    span = line[5] * 256 + line[6] + 5
    if span > 1000:
        return 2
    min = v_icom_vars.number_frequency_range[v_icom_vars.tokennumber_frequency_range_number[tokennumber]][0]
    max = v_icom_vars.number_frequency_range[v_icom_vars.tokennumber_frequency_range_number[tokennumber]][1]
    lf += min
    # in kHz:
    if lf > max:
        return 2
    # should not exceed maximum
    if lf + span > max:
        return 2
    header(tokennumber)
    # one sk comand for 4 civ commands:
    # overwrite
    if line[2] != 3:
        civ_code = bcd_to_int2([v_icom_vars.token_civ_code[tokennumber][5], v_icom_vars.token_civ_code[tokennumber][6]])
        civ_code += line[2]
        v_icom_vars.Civ_out[6:8] = int_to_bcd(civ_code, 2)
    else:
        civ_code = v_icom_vars.number_civcommand_chanal4[tokennumber]
        v_icom_vars.Civ_out[6:8] = civ_code
    # in 100Hz now:
    lf *=10
    span *= 10
    lfb = int_to_4bcd_reverse(lf)
    v_icom_vars.Civ_out.extend(lfb)
    mf = lf + span
    mfb = int_to_4bcd_reverse(mf)
    v_icom_vars.Civ_out.extend(mfb)
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_answer_scope_edge(line, input_device, tokennumber):
    # answercommand for scope edge commands
    if len(line) < 3:
        return 0
    if line[2] > 3:
        return 2
    header(tokennumber)
    # modify civ command depending on chanal
    if line[2] != 3:
        civ_code = bcd_to_int2([v_icom_vars.Civ_out[6], v_icom_vars.Civ_out[7]])
        civ_code += line[2]
        civ_ = int_to_bcd(civ_code, 2)
    else:
        civ_ = bytearray(v_icom_vars.number_civcommand_chanal4[v_icom_vars.tokennumber_frequency_range_number[tokennumber]])
    v_icom_vars.Civ_out[6:8] = civ_
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    # store chanal for answer
    v_icom_vars.command_storage = line[2]
    return 1


def command_present_number(line,  input_device, tokennumber):
    # present number
    if len(line) < 4:
        return 0
    num = line[2] * 256 + line[3]
    if num > 9998:
        return 2
    header(tokennumber)
    num += 1
    v_icom_vars.Civ_out.extend(int_to_bcd(num, 2))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_manual_gps_pos(line, input_device, tokennumber):
    # command for gps position
    v_icom_vars.Civ_out = bytearray([])
    if len(line) < 12:
        return 0
    if line[5] > 1 or line[9] > 1:
        return 2
    if line[2] > 89:
        return 2
    if line[3] > 59:
        return 2
    if line[4] > 99:
        return 2
    if line[6] > 179:
        return 2
    if line[7] > 59:
        return 2
    if line[8] > 99:
        return 2
    hight = (256 * line[10]) + line[11]
    if hight > 20001:
        return 2
    if line[12] > 9:
        return 2
    header(tokennumber)
    # long
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2] ,1))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[3], 1))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[4], 1))
    v_icom_vars.Civ_out.extend([0x00])
    v_icom_vars.Civ_out.extend(int_to_bcd(line[5], 1))
    # lat
    v_icom_vars.Civ_out.extend(int_to_bcd(line[6], 2))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[7], 1))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[8], 1))
    v_icom_vars.Civ_out.extend([0x00])
    v_icom_vars.Civ_out.extend([line[9]])
    # alt
    if hight > 10000:
        hight -= 10000
        plus_minus = 0
    else:
        hight = 10000 - hight
        plus_minus = 1
    hight *= 10
    hight += line[12]
    v_icom_vars.Civ_out.extend(int_to_bcd(hight, 3))
    v_icom_vars.Civ_out.extend([plus_minus, 0xfd])
    return 1


def command_gps_(line, tokennumber, x):
    header(tokennumber)
    if x != 2:
        v_icom_vars.Civ_out[7] += line[2]
    a = check_and_convert_alphabet(line[x], 7)
    if a == 255 :
        return 2
    else:
        v_icom_vars.Civ_out.extend([a])
    a = check_and_convert_alphabet(line[x + 1], 6)
    if a == 255:
        return 2
    else:
        v_icom_vars.Civ_out.extend([a, 0xfd])
    return 1

def command_gps_symboln(line, inputdevice, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 3:
        return 2
    if line[3] > 74:
        return 2
    v_icom_vars.Civ_out = bytearray([0xfe, 0xfe, v_icom_vars.civ_address, 0xe0,0x1a,0x05, 0x02])
    if line[2] == 0:
        v_icom_vars.Civ_out.extend([0x91])
    elif line[2] == 1:
        v_icom_vars.Civ_out.extend([0x92])
    elif line[2] == 2:
        v_icom_vars.Civ_out.extend([0x93])
    elif line[2] == 3:
        v_icom_vars.Civ_out.extend([0x94])
    v_icom_vars.Civ_out.extend(v_icom_vars.gps_sympbol_translate[line[3]])
    v_icom_vars.Civ_out.extend([0xfd])


def command_gps_symboln1(line, inputdevice, tokennumber):
    if len(line) < 2:
        return 0
    if line[2] > 74:
        return 2
    v_icom_vars.Civ_out = bytearray([0xfe, 0xfe, v_icom_vars.civ_address, 0xe0,0x1a,0x05, 0x03, 0x10])
    v_icom_vars.Civ_out.extend(v_icom_vars.gps_sympbol_translate[line[2]])
    v_icom_vars.Civ_out.extend([0xfd])


def command_gps_symboln2(line, inputdevice, tokennumber):
    if len(line) < 2:
        return 0
    if line[2] > 74:
        return 2
    v_icom_vars.Civ_out = bytearray([0xfe, 0xfe, v_icom_vars.civ_address, 0xe0,0x1a,0x05, 0x03, 0x24])
    v_icom_vars.Civ_out.extend(v_icom_vars.gps_sympbol_translate[line[2]])
    v_icom_vars.Civ_out.extend([0xfd])


def command_gps_symboln3(line, inputdevice, tokennumber):
    if len(line) < 2:
        return 0
    if line[2] > 74:
        return 2
    v_icom_vars.Civ_out = bytearray([0xfe, 0xfe, v_icom_vars.civ_address, 0xe0,0x1a,0x05, 0x03, 0x35])
    v_icom_vars.Civ_out.extend(v_icom_vars.gps_sympbol_translate[line[2]])
    v_icom_vars.Civ_out.extend([0xfd])


def answer_command_gps_symbol(line, input_device, tokennumber):
    # gps symbol
    if len(line) < 3:
        return 0
    if line[2] > 3:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out[7] += line[2]
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_comment(line, input_device, tokennumber):
    # comment (string) for 3 different subcommands or 1 (no first parameter)
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[3] != 255:
        # 3 subcommands 1 paramter + string
        if len(line) < 4:
            return 0
        if line[2] > temp[4]:
            return 2
        if line[3] == 0:
            return 1
        if len(line) < line[3] + 4:
            return 0
        if line[3] > temp[6]:
            return 2
    else:
        # 1 civ command (string only)
        if line[2] == 0:
            return 1
        if len(line) < line[2] + 3:
            return 0
        if line[2] > temp[4]:
            return 2
    header(tokennumber)
    if temp[3] != 255:
        subcommand = temp[10] * 100 + bcd_to_int(temp[11])
        subcommand += line[2]
        subcommand_s = int_to_bcd(subcommand, 2)
        v_icom_vars.Civ_out[6] = subcommand_s[0]
        v_icom_vars.Civ_out[7] = subcommand_s[1]
        temp2 = 4
        temp1 = 0
        one_min = 1
        while temp1 < line[3]:
            if check_and_convert_alphabet(line[temp2], 0) != 255:
                v_icom_vars.Civ_out.extend([line[temp2]])
                one_min = 1
            temp2 += 1
            temp1 += 1
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    else:
        temp2 = 3
        temp1 = 0
        one_min = 1
        while temp1 < line[2]:
            if check_and_convert_alphabet(line[temp2], 0) != 255:
                v_icom_vars.Civ_out.extend([line[temp2]])
                one_min = 1
                temp1 += 1
                temp2 += 1
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    if one_min == 0:
        v_icom_vars.Civ_out = []
        return 2
    return 1


def answer_command_comment(line, input_device, tokennumber):
    # comment
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if line[2] > temp[4]:
        return 2
    header(tokennumber)
    subcommand = temp[8] * 100 + bcd_to_int(temp[9])
    subcommand += line[2]
    subcommand_s = int_to_bcd(subcommand, 2)
    v_icom_vars.Civ_out[6] = subcommand_s[0]
    v_icom_vars.Civ_out[7] = subcommand_s[1]
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_alarm_group(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    if line[2] > 59:
        return  2
    if line[3] > 99:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 1))
    num = bytes(int_to_bcd(line[3], 1))[0]
    v_icom_vars.Civ_out.extend([num,0x00])
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def comamnd_data_mode(line, input_device, tokennumber):
    # data_mode
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if line[2] > 1:
        return 2
    if line[3] > 2:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend([line[2]])
    line[3] +=  1
    if line[2] == 0:
        line[3] = 0
    v_icom_vars.Civ_out.extend([line[3]])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def comamnd_repeater_tone_sql(line, input_device, tokennumber):
    # repeater /tone T-SQL
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if line[2] > 49:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(bytearray(v_fix_tables.tone_frequency[line[2]]))
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def command_dtcs(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if line[2] > 3:
        return 2
    if line[3] > 103:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend([v_fix_tables.dtcs_pol[line[2]]])
    v_icom_vars.Civ_out.extend(v_fix_tables.dtcs_frequency[line[3]])
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def command_user_bandedge(line, input_device, tokennumber):
    # user-set TX band edge frequencies
    if len(line) < 11:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if line[2] > 29:
        return 2
    #
    limits = v_icom_vars.user_band_edge[line[2]]
    header(tokennumber)
    error, fmin = command_frequency(line[3:7], limits[1] * 1000 -30000, 30000, 5)
    fmin_ = frequency_from_line(line[3:7])
    if fmin_ + 30000 < limits[0] * 1000:
        return 2
    error, fmax = command_frequency(line[7:11], limits[1] * 1000- 30000, 30000, 5)
    fmax_ = frequency_from_line(line[7:11])
    if fmax_ + 30000 > limits[1] * 1000:
        return  2
    header(tokennumber)
    v_icom_vars.Civ_out.extend([line[2] + 1])
    v_icom_vars.Civ_out.extend(fmin)
    v_icom_vars.Civ_out.extend([0x2d])
    v_icom_vars.Civ_out.extend(fmax)
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_mycall(line, input_device, tokennumber):
    if len(line) < 3:
        return  0
    if len(line) < line[2]:
        return  0
    if len(line) > line[2] + 3:
        return  2
    temp = v_icom_vars.token_civ_code[tokennumber]
    header(tokennumber)
    temp2 = 0
    temp1 = 3
    while temp2 < line[2]:
        if check_and_convert_alphabet(line[temp1], temp[3]) != 255:
            v_icom_vars.Civ_out.extend([line[temp1]])
            temp1 += 1
        temp2 += 1
    start = len(v_icom_vars.Civ_out)
    if start < 7:
        return 2
    while start < 18:
        v_icom_vars.Civ_out.extend([0x20])
        start += 1
    v_icom_vars.Civ_out.extend([0xfd])
    return  1

def command_dv_tx_call(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    act_len_pos = 3
    data_start = act_len_pos + 1
    act_len = line[act_len_pos]
    if (act_len > 8):
        return  2
    linelen = 4 + act_len
    if len((line)) < linelen:
        return 0
    if act_len > 0:
        c1 = add_space_to_8(line[data_start:data_start + act_len])
    else:
        c1 = [0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20]
    # UR ready
    act_len_pos += 4 + act_len
    data_start = act_len_pos + 1
    act_len = line[act_len_pos]
    if (act_len > 8):
        return  2
    linelen += 4 + act_len
    if len(line) < linelen:
        return  0
    if act_len > 0:
        c2 = add_space_to_8(line[data_start:data_start + act_len])
    else:
        c2 = [0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20]
    # R1 ready
    act_len_pos += 4 + act_len
    data_start = act_len_pos + 1
    act_len = line[act_len_pos]
    if (act_len > 8):
        return 2
    linelen += 4 + act_len
    if len(line) < linelen:
        return  0
    if act_len > 0:
        c3 = add_space_to_8(line[data_start:data_start + act_len + 1])
    else:
        c3 = [0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20]
    header(tokennumber)
    v_icom_vars.Civ_out.extend(c1)
    v_icom_vars.Civ_out.extend(c2)
    v_icom_vars.Civ_out.extend(c3)
    v_icom_vars.Civ_out.extend([0xfd])
    return 1

def add_space_to_8(data)  :
    i = len(data)
    while i < 8:
        data.extend([0x20])
        i+=1
    return data

def command_dv_rx_call_sign_data(line, input_device, tokennumber):
    # DV RX Call signs for transceive
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    ret, len1, len2, len3, len4, len5 = check_length(line, 5, 4, 8, 4, 8, 8, 8)
    if ret == 0:
        return 0
    elif ret == 2:
        return 2
    else:
        # all got
        header(tokennumber)
        v_icom_vars.Civ_out.extend([line[2] & 0x1f])
        v_icom_vars.Civ_out.extend([line[3] & 0x07])
        copy_and_fill(line, 3, len1, 8, 4)
        copy_and_fill(line, 4 + len1, len2, 4, 0)
        copy_and_fill(line, 5 + len1 + len2, len3, 8, 4)
        copy_and_fill(line, 6 + len1 + len2 + len3, len4, 8, 4)
        copy_and_fill(line, 7 + len1 + len2 + len3 + len4, len5, 8, 4)
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_dv_rx_message(line, input_device, tokennumber):
    # DV RX message for transceive
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    ret, len1, len2, len3, len4, len5 = check_length(line, 3, 2, 20, 8, 4, 0, 0)
    if ret == 0:
        return 0
    elif ret == 2:
        return 2
    else:
        # all got
        header(tokennumber)
        copy_and_fill(line, 3, len1, 20, 0)
        copy_and_fill(line, 4 + len1, len2, 8, 0)
        copy_and_fill(line, 5 + len1 + len2, len3, 4, 0)
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_position(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 11:
        return 2
    header(tokennumber)
    # send no parameter -> store instead
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_icom_vars.command_storage = line[2]
    return 1


def command_object(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 13:
        return 2
    header(tokennumber)
    # send no parameter -> store instead
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_icom_vars.command_storage = line[2]
    return 1


def command_item(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 15:
        return 2
    header(tokennumber)
    # send no parameter -> store instead
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_icom_vars.command_storage = line[2]
    return 1


def command_weather(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 15:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(bytearray([line[3:len(line)-2]]))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_icom_vars.command_storage = line[2]
    return 1


def command_dv_rx_gps_dprs_message(line, input_device, tokennumber):
    # DV RX GPS/D-PRS message for transceive
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    ret, len1, len2, len3, len4, len5 = check_length(line, 2, 2, 9, 43, 0, 0, 0)
    if ret == 0:
        return 0
    elif ret == 2:
        return 2
    else:
        # all got
        header(tokennumber)
        copy_and_fill(line, 3, len1, 9, 4)
        copy_and_fill(line, 4 + len1, len2, 43, 4)
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_rit(line, input_device, tokennumber):
    # rit
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if len(line) < 4:
        return 0
    header(tokennumber)
    ret, temp = int_to_bcd_plusminus(line, 9999, 2, 1)
    if ret == 1:
        v_icom_vars.Civ_out.extend(temp)
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    else:
        return ret
    return 1


def command_gps_select(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if line[2] > 2:
        return 2
    header(tokennumber)
    if line[2] == 0:
        v_icom_vars.Civ_out.extend([line[2]])
    else:
        v_icom_vars.Civ_out.extend([line[2] + 1])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_sel_unsel_f(line, input_device, tokennumber):
    # sel / unsel frequency
    if len(line) < 7:
        return 0
    header(tokennumber)
    ret, freq = command_frequency(line[3:8], 269970000, 30000, 5)
    if ret == 1:
        v_icom_vars.Civ_out.extend([line[2]])
        v_icom_vars.Civ_out.extend(freq)
        v_icom_vars.Civ_out.extend([0xfd])
    else:
        v_icom_vars.Civ_out = bytearray([])
    return 1


def command_sel_unsel_mode_filter(line, input_device, tokennumber):
    # sel / unsel mode - filter
    if len(line) < 5:
        return 0
    if line[2] > 1 or line[3] > 13 or line[4] > 2:
        return 2
    header(tokennumber)
    dta = 0
    if line[3] == 9:
        line[3] = 0x17
    elif line[3] > 9:
        line[3] -= 10
        dta = 1
    v_icom_vars.Civ_out.extend(line[2:4])
    v_icom_vars.Civ_out.extend([dta, line[4] + 1, 0xfd])
    return 1


def command_scope_span_center_mode(line, input_device, tokennumber):
    # span for center mode
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if line[2] > 7:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(v_icom_vars.span_center_mode[line[2]])
    return 1


def command_scope_reference(line, input_device, tokennumber):
    # scope reference level
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if line[2] > 80:
        return 2
    header(tokennumber)
    db_05 = line[2] % 2
    pm = 0
    line[2] //= 2
    if line[2] > 19:
        # + (20 - 20: 0 - +20)
        line[2] -= 20
    else:
        # - (0 - 19 : -20 - -1)
        pm = 1
        line[2] = 20 - line[2]
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 1))
    v_icom_vars.Civ_out.extend([db_05])
    v_icom_vars.Civ_out.extend(bytearray([pm, 0xfd]))
    return 1

def radio_version(line, input_device, tokennumber):
    v_icom_vars.Civ_out = bytearray([])
    v_sk.info_to_all.extend([0x01,0x9f,int(v_icom_vars.radio_version)])
    return 1

def com240(line, input_device, tokennumber):
    # ANNOUCEMENTS
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
    elif number_of_lines > 0:
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
    return 1


def com250(line, input_device, tokennumber):
    # FEATURE
    v_sk.info_to_all = bytearray([0xff, 0xfa, 0x00])
    return 1

def com252(line, input_device, tokennumber):
    # ERROR
    v_sk.info_to_all = bytearray([0xff, 0xfc])
    if v_icom_vars.error_cmd_no == 255:
        temp = "no error"
    else:
        temp = "command: " + str(v_icom_vars.command_no) + " last error at command: " + str(v_icom_vars.error_cmd_no)
        temp += " : " + v_icom_vars.last_error_msg
    v_sk.info_to_all.extend(bytearray([len(temp)]))
    v_sk.info_to_all.extend(str_to_bytearray(temp))
    return 1


def com253(line, input_device, tokennumber):
    # BUSY
    v_sk.info_to_all = bytearray([0xff, 0xfd, 0x04])
    return 1


def com254(line, input_device, tokennumber):
    # INDIVIDUALIZATION
    if len(line) < 4:
        return 0
    if line[2] > 5:
        return 2
    if line[2] == 0:
        length = line[3]
        if length > 20 or length == 0:
            return 2
        if len(line) < length + 4:
            return 0
        if len(line) > length + 4:
            return 2
        v_icom_vars.device_name = ba_to_str(line[5:])
    if line[2] == 1:
        v_icom_vars.device_number = line[3]
    if line[2] == 2:
        if len(line) < 5:
            return 0
        v_icom_vars.telnet_port = line[3] * 256 + line[4]
    if line[2] == 3:
        v_icom_vars.comportnumber = line[3]
        v_icom_vars.comport = "COM" + str(line[3])
        # try again with this com port
        try:
            v_icom_vars.icom_usb = serial.Serial(v_icom_vars.comport, 19200, timeout=1, parity=serial.PARITY_NONE,
                                     bytesize=serial.EIGHTBITS, stopbits=serial.STOPBITS_ONE, rtscts=0)
            v_icom_vars.check_usb_again = 0
        except serial.serialutil.SerialException:
            write_log("com port " + v_icom_vars.comport + " not found")
            # USB is is locked until fffe05 is called again
            v_icom_vars.check_usb_again = 1
    if line[2] == 4:
        if len(line) < line[4]+ 4:
            return 0
        if line[4] > 50:
            return 2
        if len(line) > line[4] + 4:
            return 2
        v_icom_vars.control_data_in = ba_to_str(line[5:])
    if line[2] == 5:
        if len(line) < line[4] + 4:
            return 0
        if line[4] > 50:
            return 2
        if len(line) > line[4] + 4:
            return 2
        v_icom_vars.control_data_out = ba_to_str(line[5:])
    create_config_file(v_icom_vars.config_file, "w")
    return 1


def com255(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 8:
        return 2
    v_sk.info_to_all = bytearray([0xff, 0xff, line[2]])
    if line[2] == 0:
        v_sk.info_to_all.extend(bytearray([len(v_icom_vars.device_name)]))
        v_sk.info_to_all.extend(bytearray(v_icom_vars.device_name, encoding='utf8'))
    elif line[2] == 1:
        v_sk.info_to_all.extend(bytearray([v_icom_vars.device_number]))
    elif line[2] == 2:
        v_sk.info_to_all.extend(bytearray([v_icom_vars.terminal_activ]))
    elif line[2] == 3:
        v_sk.info_to_all.extend(bytearray([v_icom_vars.telnet_active]))
    elif line[2] == 4:
        v_sk.info_to_all.extend(bytearray([v_icom_vars.telnet_port]))
    elif line[2] == 5:
        print (v_icom_vars.comportnumber)
        v_sk.info_to_all.extend(bytearray([v_icom_vars.comportnumber]))
    elif line[2] == 6:
        v_sk.info_to_all.extend(bytearray([1]))
    elif line[2] == 7:
        v_sk.info_to_all.extend(bytearray([len(v_icom_vars.control_data_in)]))
        v_sk.info_to_all.extend(bytearray(v_icom_vars.control_data_in, encoding='utf8'))
    elif line[2] == 8:
        v_sk.info_to_all.extend(bytearray([len(v_icom_vars.control_data_out)]))
        v_sk.info_to_all.extend(bytearray(v_icom_vars.control_data_out, encoding='utf8'))
    return 1

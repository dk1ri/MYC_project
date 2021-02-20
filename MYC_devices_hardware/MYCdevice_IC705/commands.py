"""
name: commands.py
last edited: 20210220
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


def nop(line, input_device, tokennumber):
    v_sk.len[input_device][0] = len(line)
    return 1


def header(tokennumber):
    v_icom_vars.Civ_out = bytearray([0xfe, 0xfe, v_icom_vars.civ_address, 0xe0])
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[2] == 0:
        # add commnd and up three subcommands
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
        # add commnd and up three subcommands
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
        # add commnd and up three subcommands
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
        # add commnd and up three subcommands
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
    elif temp[2] == 10:
        # add commnd and up two subcommands
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
        # add commnd and up two subcommands
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


def u_command1(line, input_device, tokennumber):
    # for commands with one byte parameter or variable subcommand without parameter
    # no gaps in parameter or subcommand
    # up to 3 parameter
    if len(line) < 2:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
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
        v_sk.len[input_device][0] = temp[1]
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
                while temp2 < line[2]:
                    if check_and_convert_alphabet(line[temp1], temp[3]) != 255:
                        v_icom_vars.Civ_out.extend([line[temp1]])
                        temp1 += 1
                        one_min = 1
                    temp2 += 1
                if one_min == 1:
                    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
                else:
                    v_icom_vars.Civ_out = bytearray([])
            v_sk.len[input_device][0] = length + 3
    return 1


def u_command2(line, input_device, tokennumber):
    # for commands with two byte parameter up to 9999 to 2byte bcd
    # no adder possible
    # up to 3 parameter
    if len(line) < 2:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
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
    v_sk.len[input_device][0] = temp[1]
    return 1


def u_command3(line, input_device, tokennumber):
    # for commands with one two byte parameter up to 999999 to 3byte bcd
    # no adder possible
    if len(line) < 2:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
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
    v_sk.len[input_device][0] = temp[1]
    return 1


def command_frequency4(frequency):
    # convert kHz (int) )to 4 bcd LSB first
    # return ba
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


def command_frequency(line, limit, adder, civbytes):
    # line contain frequency only
    # convert line with limit to civbytes bcd LSB first
    # return ba
    tempa = len(line)
    multiplier = 1
    frequency = 0
    while tempa > 0:
        tempb = line[tempa - 1] * multiplier
        frequency += tempb
        multiplier *= 256
        tempa -= 1
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


def command_memory(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    # loading the memory content
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    temp = line[2] * 256 + line[3]
    if tokennumber == 1139 or tokennumber == 1140 or tokennumber == 1165 or tokennumber == 1166:
        # no split
        if temp > 10003:
            return 2
    else:
        if temp > 20007:
            return 2
    # split the memoryadrress
    if temp > 20003:
        # call split, 20004 - 20007
        v_icom_vars.vfo_split = 1
        group = [0x01, 0x00]
        memory = [temp - 2004]
    elif temp > 1003:
        # no call, 10004 - 20003
        v_icom_vars.vfo_split = 1
        group = int_to_bcd((temp - 1003) // 100, 2)
        memory = int_to_bcd((temp - 1003) % 100, 2)
    elif temp > 1999:
        # call  no split 10000 - 10003
        v_icom_vars.vvfo_split = 0
        group = [0x01, 0x00]
        memory = [0x0, temp - 1999]
    else:
        # no call no split 0 - 9999
        v_icom_vars.vfo_split = 0
        group = int_to_bcd(temp // 100, 2)
        memory = int_to_bcd(temp % 100, 2)
        v_icom_vars.command_storage = vfo_split
    # start getting memorycontent
    header(tokennumber)
    v_icom_vars.Civ_out.extend(group)
    v_icom_vars.Civ_out.extend(memory)
    v_icom_vars.Civ_out.extend([0xfd])
    v_icom_vars.ask_content = 1
    return 1


def command256(line, input_device, tokennumber):
    # frequenz
    if len(line) < 6:
        return 0
    ret, temp = command_frequency(line[2:7], 2699970000, 30000, 5)
    if ret != 1:
        return ret
    else:
        header(tokennumber)
        v_icom_vars.Civ_out.extend(temp)
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
        v_sk.len[input_device][0] = len(line)
    return 1


def command258(line, input_device, tokennumber):
    # frequency
    if len(line) < 4:
        return 0
    if line[2] > 9:
        return 2
    if line[3] > 2:
        return 2
    if line[2] == 9:
        line[2] = 0x17
    line[3] += 1
    header(tokennumber)
    v_icom_vars.Civ_out.extend(line[2:4])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1


def command261(line, input_device, tokennumber):
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
    v_sk.len[input_device][0] = 3
    return 1


def command262(line, input_device, tokennumber):
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
    v_sk.len[input_device][0] = 3
    return 1


def command264(line, input_device, tokennumber):
    # select memory
    if len(line) < 3:
        return 0
    if line[2] > 103:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2] + 1, 2))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 3
    return 1


def command265(line, input_device, tokennumber):
    # vfo memory function
    if len(line) < 3:
        return 0
    if line[2] > 3:
        return 2
    header(tokennumber)
    if line[2] == 0:
        v_icom_vars.Civ_out = bytearray([])
    elif line[2] == 1:
        v_icom_vars.Civ_out[4] = 0x09
    elif line[2] == 2:
        v_icom_vars.Civ_out[4] = 0x0a
    elif line[2] == 3:
        v_icom_vars.Civ_out[4] = 0x0b
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 3
    return 1


def command266(line, input_device, tokennumber):
    # offset frequency
    if len(line) < 5:
        return 0
    ret, temp = command_frequency(line[2: 6], 99999, 0, 3)
    if ret != 1:
        return ret
    header(tokennumber)
    v_icom_vars.Civ_out.extend(temp)
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 5
    return 1


def command268(line, input_device, tokennumber):
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
    v_sk.len[input_device][0] = 3
    return 1


def command273(line, input_device, tokennumber):
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
    v_sk.len[input_device][0] = 3
    return 1


def command274(line, input_device, tokennumber):
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
    v_sk.len[input_device][0] = 3
    return 1


def command278(line, input_device, tokennumber):
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
    v_sk.len[input_device][0] = 3
    return 1


def command363(line, input_device, tokennumber):
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
        if check_and_convert_alphabet(line[temp2], 3):
            v_icom_vars.Civ_out.extend(bytearray([line[temp2]]))
        temp1 += 1
        temp2 += 1
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = cwlen + 4
    return 1


def command373(line, input_device, tokennumber):
    # HPF / LPF SSB
    if len(line) < 4:
        return 0
    if line[2] > 20 or line[3] > 20 or line[2] >= line[3]:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 1))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[3] + 5, 1))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 4
    return 1


def command409(line, input_device, tokennumber):
    # SSB Tx wide bandwidth
    if len(line) < 4:
        return 0
    if line[2] > 3 or line[3] > 3:
        return 2
    header(tokennumber)
    line[2] *= 16
    line[2] += line[3]
    v_icom_vars.Civ_out.extend([line[2]])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 4
    return 1


def command461(line, input_device, tokennumber):
    # split offset
    if len(line) < 4:
        return 0
    header(tokennumber)
    ret, bcd = int_to_bcd_plusminus(line, 9999, 3, 10)
    if ret == 1:
        v_icom_vars.Civ_out.extend(bcd)
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
        v_sk.len[input_device][0] = len(line)
    else:
        return ret
    return 1


def command697(line, input_device, tokennumber):
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
    v_sk.len[input_device][0] = len(line)
    return 1


def command699(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    if line[2] > 23 or line[3] > 59:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 1))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[3], 1))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = len(line)
    return 1


def command707(line, input_device, tokennumber):
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
    v_sk.len[input_device][0] = len(line)
    return 1


def command743(line, input_device, tokennumber):
    # scope edge commands 1a0188 - 235 + 36x for chanal 4
    if len(line) < 7:
        return 0
    if line[2] > 3:
        return 2
    lf = line[3] * 256 + line[4]
    span = line[5] * 256 + line[6]
    return command743_775(line, lf, span, tokennumber, input_device)


def command775(line, input_device, tokennumber):
    # scope edge
    if len(line) < 8:
        return 0
    if line[2] > 2:
        return 2
    lf = (line[3] * 256 + line[4]) * 256
    lf += line[5]
    span = line[6] * 256 + line[7]
    return commad743_775(line, lf, span, tokennumber, input_device)


def command743_775(line, lf, span, tokennumber, input_device):
    # fixed mode scope edge frequencies
    if span > 995:
        return 2
    # real span:
    span += 5
    min = v_icom_vars.number_frequency_range[v_icom_vars.tokennumber_frequency_range_number[tokennumber]][0]
    max = v_icom_vars.number_frequency_range[v_icom_vars.tokennumber_frequency_range_number[tokennumber]][1]
    # should not exceed maximum
    if lf > max - min - span:
        return 2
    header(tokennumber)
    # one sk comand for 4 civ commands:
    if line[2] != 3:
        temp1 = bcd_to_int(v_icom_vars.Civ_out[7]) + line[2]
    else:
        v_icom_vars.Civ_out[7] = 3
        temp1 = v_icom_vars.number_civcommand_chanal.tokennumber_frequency_range_number[tokennumber]
    v_icom_vars.Civ_out[7] = int_to_bcd_int(temp1)
    v_icom_vars.Civ_out.extend(command_frequency4(lf + min))
    v_icom_vars.Civ_out.extend(command_frequency4(lf + min + span))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 7
    return 1


def command744(line, input_device, tokennumber):
    # answercommamnnd for scope edge commands 1a0188 - 236
    if len(line) < 3:
        return 0
    if line[2] > 2:
        return 2
    header(tokennumber)
    # modify civ command depending on chanal
    temp1 = bcd_to_int(v_icom_vars.Civ_out[7]) + line[2]
    v_icom_vars.Civ_out[7] = int_to_bcd_int(temp1)
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 3
    return 1


def command795(line, input_device, tokennumber):
    # command for 2byte HI parameter and 2 byte CiV BCD (up to 9999
    # present number
    if len(line) < 4:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    number = line[2] * 256 + line[3]
    max = temp[4] * 256 + temp[6]
    if number > max:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd(number + temp[7], 2))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 3
    return 1


def command871(line, input_device, tokennumber):
    # gps position
    if len(line) < 13:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[5] > 1 or line[9] > 1:
        return 2
    lat = (line[2] * 256 + line[3]) * 256 + line[4]
    long = (line[6] * 256 + line[7]) * 256 + line[8]
    if lat > 5400000 or long > 10800000:
        return 2
    hight = (line[10] * 256 + line[11]) * 256 + line[12]
    hight_o = hight
    if hight > 200001:
        return 2
    header(tokennumber)
    lat_deg = lat // 60000
    lat_min = lat % 60000
    long_deg = long // 60000
    long_min = long % 60000
    if hight > 100000:
        hight -= 100000
        plusminus = 0
    else:
        hight = 100000 - hight
        plusminus = 1
    v_icom_vars.Civ_out.extend(int_to_bcd(lat_deg, 1))
    v_icom_vars.Civ_out.extend(int_to_bcd(lat_min * 10, 3))
    v_icom_vars.Civ_out.extend([line[5]])
    v_icom_vars.Civ_out.extend(int_to_bcd(long_deg, 2))
    v_icom_vars.Civ_out.extend(int_to_bcd(long_min * 10, 3))
    v_icom_vars.Civ_out.extend([line[9]])
    if hight_o < 200001:
        v_icom_vars.Civ_out.extend(int_to_bcd(hight * 1, 3))
        v_icom_vars.Civ_out.extend(bytearray([plusminus, 0xfd]))
    else:
        v_icom_vars.Civ_out.extend([0xff, 0xff, 0xff, 0xfd])
    v_sk.len[input_device][0] = 13
    return 1


def command881(line, input_device, tokennumber):
    # symbol for nummber (1st paramter) or no number (255 as temp[1])
    if len(line) < 4:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if temp[3] != 255:
        # more than one CIV codes
        if len(line) < 5:
            return 0
        if line[2] > temp[4] or line[3] > temp[6] or line[4] > temp[8]:
            return 2
        if check_and_convert_alphabet(line[3], 1) == 255:
            return 2
        if check_and_convert_alphabet(line[4], 0) == 255:
            return 2
    else:
        if check_and_convert_alphabet(line[2], 1) == 255:
            return 2
        if check_and_convert_alphabet(line[3], 0) == 255:
            return 2
    header(tokennumber)
    if temp[3] != 255:
        # more than one CIV codes
        v_icom_vars.Civ_out[7] += line[2]
        v_icom_vars.Civ_out.extend([line[3]])
        v_icom_vars.Civ_out.extend([line[4]])
    else:
        v_icom_vars.Civ_out.extend([line[2]])
        v_icom_vars.Civ_out.extend([line[3]])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 4
    return 1


def answer882(line, input_device, tokennumber):
    # symbol
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > temp[4]:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out[7] += line[2]
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 4
    return 1


def command887(line, input_device, tokennumber):
    # comment (string) for 3 different subcommands or 1 (no first parameter)
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
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
        v_sk.len[input_device][0] = line[3] + 4
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
        v_sk.len[input_device][0] = line[3] + 3
    if one_min == 0:
        v_icom_vars.Civ_out = []
        return 2
    return 1


def answer888(line, input_device, tokennumber):
    # comment
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > temp[4]:
        return 2
    header(tokennumber)
    subcommand = temp[8] * 100 + bcd_to_int(temp[9])
    subcommand += line[2]
    subcommand_s = int_to_bcd(subcommand, 2)
    v_icom_vars.Civ_out[6] = subcommand_s[0]
    v_icom_vars.Civ_out[7] = subcommand_s[1]
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 4
    return 1


def command979(line, input_device, tokennumber):
    # alarm group
    # comment
    if len(line) < 4:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    group = line[2] * 256 + line[3]
    if group > 5991:
        return 2
    header(tokennumber)
    group += 8
    group *= 100
    v_icom_vars.Civ_out.extend(int_to_bcd(group, 3))
    v_icom_vars.Civ_out.extend([0xfd])
    v_sk.len[input_device][0] = 4
    return 1


def comamnd1017(line, input_device, tokennumber):
    # data_mode
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 3:
        return 2
    header(tokennumber)
    if line[2] == 0:
        v_icom_vars.Civ_out.extend([0x00, 0x00])
    else:
        v_icom_vars.Civ_out.extend([0x01])
        v_icom_vars.Civ_out.extend([line[2]])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 4
    return 1


def command1026(line, input_device, tokennumber):
    # tone T-SQL
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 49:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(bytearray(v_icom_vars.tone_frequency[line[2]]))
    v_icom_vars.Civ_out.extend([0xfd])
    v_sk.len[input_device][0] = 3
    return 1


def command1030(line, input_device, tokennumber):
    # DTCS
    if len(line) < 4:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 3:
        return 2
    if line[3] > 103:
        return 2
    header(tokennumber)
    if line[2] == 0:
        v_icom_vars.Civ_out.extend([0])
    elif line[2] == 1:
        v_icom_vars.Civ_out.extend([0x01])
    elif line[2] == 2:
        v_icom_vars.Civ_out.extend([0x10])
    elif line[2] == 3:
        v_icom_vars.Civ_out.extend([0x11])
    v_icom_vars.Civ_out.extend(bytearray(v_icom_vars.dtcs_frequency[line[3]]))
    v_icom_vars.Civ_out.extend([0xfd])
    v_sk.len[input_device][0] = 4
    return 1


def command1044(line, input_device, tokennumber):
    # user-set TX band edge frequencies; not used, no simple announcement found yet
    if len(line) < 11:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 29:
        return 2
    lf = line[3] * 256 + line[4]
    span = line[5] * 256 + line[6]
    if span > 995:
        return 2
    # real span:
    span += 5
    min = v_icom_vars.number_frequency_range[v_icom_vars.tokennumber_frequency_range_number[tokennumber]][0]
    max = v_icom_vars.number_frequency_range[v_icom_vars.tokennumber_frequency_range_number[tokennumber]][1]
    if lf > max - min - span:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out[7] = v_icom_vars.Civ_out[7] + line[2]
    v_icom_vars.Civ_out.extend(int_to_3bcd((lf + min) * 10))
    v_icom_vars.Civ_out.extend(int_to_3bcd((lf + min + span) * 10))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_sk.len[input_device][0] = 7
    return 1


def command1054(line, input_device, tokennumber):
    # DV RX Call signs for transceive
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
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
    v_sk.len[input_device][0] = 4 + len1 + len2 + len3 + len4 + len5
    return 1


def command1059(line, input_device, tokennumber):
    # DV RX message for transceive
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
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
    v_sk.len[input_device][0] = 4 + len1 + len2 + len3
    return 1


def command1069(line, input_device, tokennumber):
    # DV RX GPS/D-PRS message for transceive
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
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
    v_sk.len[input_device][0] = 4 + len1 + len2 + len3 + len4 + len5
    return 1


def command1072(line, input_device, tokennumber):
    # rit
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if len(line) < 4:
        return 0
    header(tokennumber)
    ret, temp = int_to_bcd_plusminus(line, 9999, 2, 1)
    if ret == 1:
        v_icom_vars.Civ_out.extend(temp)
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
        v_sk.len[input_device][0] = len(line)
    else:
        return ret
    return 1


def command1094(line, input_device, tokennumber):
    # gps select
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 2:
        return 2
    header(tokennumber)
    if line[2] == 2:
        v_icom_vars.Civ_out.extend(bytearray([0x03, 0xfd]))
    else:
        v_icom_vars.Civ_out.extend(bytearray([line[2], 0xfd]))
    v_sk.len[input_device][0] = 3
    return 1


def command1102(line, input_device, tokennumber):
    # sel / unsel frequency
    if len(line) < 7:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    frequency = 16777216 * line[3] + 65536 * line[4] + 256 * line[5] + line[6]
    if line[2] > 1 or frequency > 269970000:
        return 2
    header(tokennumber)
    ret, freq = command_frequency(line[3:8], 269970000, 30000, 5)
    v_icom_vars.Civ_out.extend([line[2]])
    v_icom_vars.Civ_out.extend(freq)
    v_icom_vars.Civ_out.extend([0xfd])
    v_sk.len[input_device][0] = 7
    return 1


def command1104(line, input_device, tokennumber):
    # sel / unsel mode - filter
    if len(line) < 5:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 1 or line[3] > 13 or line[4] > 2:
        return 2
    header(tokennumber)
    dta = 0
    if line[3] == 9:
        line[3] = 0x17
        dta = 0
    elif line[3] > 9:
        line[3] -= 10
        dta = 1
    v_icom_vars.Civ_out.extend(line[2:4])
    v_icom_vars.Civ_out.extend([dta, line[4] + 1, 0xfd])
    v_sk.len[input_device][0] = 5
    return 1


def command1115(line, input_device, tokennumber):
    # span for center mode
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 7:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(v_icom_vars.span_center_mode[line[2]])
    v_sk.len[input_device][0] = 3
    return 1


def command1121(line, input_device, tokennumber):
    # scope reference level
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
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
    v_sk.len[input_device][0] = 5
    return 1


def answercommand_1136(line, input_device, tokennumber):
    # send civ command
    v_icom_vars.ask_content = 0
    ret = command_memory(line, input_device, tokennumber)
    v_icom_vars.ask_content = 4
    v_sk.len[input_device][0] = 4
    return ret


def command1137(line, input_device, tokennumber):
    # memory frequency
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
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
            if v_icom_vars.command_storage == 0:
                v_icom_vars.Civ_out[11:16] = frequ
            else:
                v_icom_vars.Civ_out[58:63] = frequ
            v_sk.len[input_device][0] = 8
            v_icom_vars.ask_content = 0
            return 1
        else:
            return ret


def command1139(line, input_device, tokennumber):
    # memory split select
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
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
        if v_icom_vars.command_storage == 0:
            v_icom_vars.Civ_out[10] = temp
        else:
            v_icom_vars.Civ_out[57] = temp
        v_sk.len[input_device][0] = 6
        v_icom_vars.ask_content = 0
        return 1


def command1141(line, input_device, tokennumber):
    # memory mode filter
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 6:
            return 0
        if line[4] > 9 or line[5] > 2:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        if line[4] == 9:
            line[4] = 0x17
        if v_icom_vars.command_storage == 0:
            v_icom_vars.Civ_out[16:18] = [line[4], line[5] + 1]
        else:
            v_icom_vars.Civ_out[63:65] = [line[4], line[5] + 1]
        v_sk.len[input_device][0] = 6
        v_icom_vars.ask_content = 0
        return 1


def command1143(line, input_device, tokennumber):
    # memory data mode
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
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
        v_sk.len[input_device][0] = 5
        v_icom_vars.ask_content = 0
        return 1


def command1145(line, input_device, tokennumber):
    # memory duplex tone
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
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
        v_sk.len[input_device][0] = 6
        v_icom_vars.ask_content = 0
        return 1


def command1147(line, input_device, tokennumber):
    # memory digital squelch
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
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
        v_sk.len[input_device][0] = 5
        v_icom_vars.ask_content = 0
        return 1


def command1149(line, input_device, tokennumber):
    # memory memory repeater tone
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
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
            v_icom_vars.Civ_out[22:24] = v_icom_vars.tone_frequency[line[4]]
        else:
            v_icom_vars.Civ_out[68] = 0
            v_icom_vars.Civ_out[69:71] = v_icom_vars.tone_frequency[line[4]]
        v_sk.len[input_device][0] = 5
        v_icom_vars.ask_content = 0
        return 1


def command1151(line, input_device, tokennumber):
    # memory memory repeater tone
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
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
            v_icom_vars.Civ_out[25:27] = v_icom_vars.tone_frequency[line[4]]
        else:
            v_icom_vars.Civ_out[71] = 0
            v_icom_vars.Civ_out[72:74] = v_icom_vars.tone_frequency[line[4]]
        v_sk.len[input_device][0] = 5
        v_icom_vars.ask_content = 0
        return 1


def command1153(line, input_device, tokennumber):
    # memory DTCS frequncy
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 6:
            return 0
        if line[4] > 3 or line[5] > 103:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        if v_icom_vars.command_storage == 0:
            v_icom_vars.Civ_out[27] = v_icom_vars.dtcs_pol[line[4]]
            v_icom_vars.Civ_out[28:30] = v_icom_vars.dtcs_frequency[line[5]]
        else:
            v_icom_vars.Civ_out[74] = v_icom_vars.dtcs_pol[line[4]]
            v_icom_vars.Civ_out[75:77] = v_icom_vars.dtcs_frequency[line[5]]
        v_sk.len[input_device][0] = 6
        v_icom_vars.ask_content = 0
        return 1


def command1155(line, input_device, tokennumber):
    # memory DV digital code
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
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
        v_sk.len[input_device][0] = 5
        v_icom_vars.ask_content = 0
        return 1


def command1157(line, input_device, tokennumber):
    # memory duplex offset frequency
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
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
        v_sk.len[input_device][0] = 5
        v_icom_vars.ask_content = 0
        return 1


def command1159_65(line, input_device, tokennumber, length, alph, start, split):
    # memory strings
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
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
        if v_icom_vars.command_storage == 0:
            v_icom_vars.Civ_out[start:start + length] = temp
        else:
            if split == 0:
                v_icom_vars.Civ_out[start:start + length] = temp
            else:
                v_icom_vars.Civ_out[start + 47:start + 47 + length] = temp
        v_sk.len[input_device][0] = 5 + line[4]
        v_icom_vars.ask_content = 0
        return 1


def command1159(line, input_device, tokennumber):
    # UR
    return command1159_65(line, input_device, tokennumber, 8, 4, 34, 1)


def command1161(line, input_device, tokennumber):
    # R1
    return command1159_65(line, input_device, tokennumber, 8, 4, 42, 1)


def command1163(line, input_device, tokennumber):
    # R2
    return command1159_65(line, input_device, tokennumber, 8, 4, 50, 1)


def command1165(line, input_device, tokennumber):
    # memory name
    return command1159_65(line, input_device, tokennumber, 16, 0, 105, 0)


def command1167(line, input_device, tokennumber):
    # read bandstack
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 44:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd((line[2] % 15) + 1, 1))
    v_icom_vars.Civ_out.extend([(line[2] // 15) + 1, 0xfd])
    v_sk.len[input_device][0] = 4
    return 1


def command1168(line, input_device, tokennumber):
    # copy bandstack
    if len(line) < 4:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 14 or line[3] > 1:
        return 2
    if v_icom_vars.ask_content == 0:
        header(tokennumber)
        if line[3] == 0:
            v_icom_vars.Civ_out.extend(int_to_bcd(line[2] + 1, 1))
            v_icom_vars.Civ_out.extend([1, 0xfd])
        else:
            v_icom_vars.Civ_out.extend(int_to_bcd(line[2] + 1, 1))
            v_icom_vars.Civ_out.extend([3, 0xfd])
        v_icom_vars.ask_content = 1
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 2:
        header(tokennumber)
        v_icom_vars.Civ_out.extend(bytearray(int_to_bcd(line[2] + 1, 1)))
        v_icom_vars.Civ_out.extend([2])
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        v_icom_vars.ask_content = 0
        v_sk.len[input_device][0] = 4
    return 1


def command1183(line, input_device, tokennumber):
    # tone squelch function
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 7:
        return 2
    header(tokennumber)
    if line[2] < 4:
        v_icom_vars.Civ_out.extend([line[2]])
    else:
        v_icom_vars.Civ_out.extend([line[2] + 2])
    v_icom_vars.Civ_out.extend([0xfd])
    v_sk.len[input_device][0] = 4
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
    v_sk.len[input_device][0] = 6
    return 1


def com252(line, input_device, tokennumber):
    v_sk.info_to_all = bytearray([0xff, 0xfc])
    if v_icom_vars.error_cmd_no == 255:
        temp = "no error"
    else:
        temp = "command: " + str(v_icom_vars.command_no) + " last error at command: " + str(v_icom_vars.error_cmd_no)
        temp += " : " + v_icom_vars.last_error_msg
    v_sk.info_to_all.extend(bytearray([len(temp)]))
    v_sk.info_to_all.extend(str_to_bytearray(temp))
    v_sk.len[input_device][0] = 2
    return 2


def com253(line, input_device, tokennumber):
    v_sk.info_to_all = bytearray([0xff, 0xfd, 0x04])
    v_sk.len[input_device][0] = 2
    return 1


def com254(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    if line[2] > 5:
        return 2
    v_sk.len[input_device][0] = 4
    if line[2] == 0:
        length = line[3]
        if length > 20 or length == 0:
            return 2
        if len(line) < length + 4:
            return 0
        if len(line) > length + 4:
            return 2
        v_icom_vars.device_name = ba_to_str(line[5:])
        v_sk.len[input_device][0] = 4 + length
    if line[2] == 1:
        v_icom_vars.device_number = line[3]
    if line[2] == 2:
        if line[3] > 1:
            return 2
        if line[3] == 0 and v_icom_vars.telnet_active == 0:
            # not both inactive
            return 2
        v_icom_vars.terminal_activ = line[3]
    if line[2] == 3:
        if line[3] > 1:
            return 2
        if line[3] == 0 and v_icom_vars.terminal_activ == 0:
            # not both inactive
            return 2
        v_icom_vars.telnet_active = line[3]
    if line[2] == 4:
        if len(line) < 5:
            return 0
        v_icom_vars.telnet_port = line[3] * 256 + line[4]
    if line[2] == 5:
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
    create_config_file(v_icom_vars.config_file, "w")
    return 1


def com255(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    if line[2] > 5:
        return 2
    v_sk.info_to_all = bytearray([0xff, 0xff, line[2]])
    if line[2] == 0:
        v_sk.info_to_all.extend(bytearray([len(v_icom_vars.device_name)]))
        v_sk.info_to_all.extend(str_to_bytearray(v_icom_vars.device_name))
    elif line[2] == 1:
        v_sk.info_to_all.extend(bytearray([v_icom_vars.device_number]))
    elif line[2] == 2:
        v_sk.info_to_all.extend(bytearray([v_icom_vars.terminal_activ]))
    elif line[2] == 3:
        v_sk.info_to_all.extend(bytearray([v_icom_vars.telnet_active]))
    elif line[2] == 4:
        v_sk.info_to_all.extend(bytearray([v_icom_vars.telnet_port]))
    elif line[2] == 5:
        v_sk.info_to_all.extend(bytearray([v_icom_vars.comportnumber]))
    v_sk.len[input_device][0] = 3
    return 1

"""
name: commands.py IC7300
last edited: 20210306
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
    return 1


def command_frequency4(frequency):
    # convert kHz (int) ) to 4 bcd LSB first
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
    if len(line) < 3:
        return 0
    # loading the memory content
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 101:
        return 2
    # start getting memorycontent
    header(tokennumber)
    v_icom_vars.command_storage = 0
    if tokennumber > 378:
        # for split add 14 to position
        v_icom_vars.command_storage = 14
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2] + 1, 2))
    v_icom_vars.Civ_out.extend([0xfd])
    v_icom_vars.ask_content = 1
    return 1


def commandou(line, input_device, tokennumber):
    # for simple ou (0  and 1 only) no civ parameter
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 1:
        return 2
    if line[2] == 0:
        return 1
    else:
        header(tokennumber)
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
        return 1


def command256(line, input_device, tokennumber):
    # frequency
    if len(line) < 6:
        return 0
    ret, temp = command_frequency(line[2:6], 74770000, 30000, 5)
    if ret != 1:
        return ret
    else:
        header(tokennumber)
        v_icom_vars.Civ_out.extend(temp)
        v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command258(line, input_device, tokennumber):
    # mode
    if len(line) < 4:
        return 0
    if line[2] > 7:
        return 2
    if line[3] > 4:
        return 2
    if line[2] > 5:
        line[2] += 1
    line[3] += 1
    header(tokennumber)
    v_icom_vars.Civ_out.extend(line[2:4])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    v_icom_vars.last_mode = line[2]
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
    v_icom_vars.last_vfo_mem = line[2]
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
    if line[2] == 0 or line[2] == 1:
        v_icom_vars.last_vfo_mem = line[2]
    return 1


def command264(line, input_device, tokennumber):
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


def command265(line, input_device, tokennumber):
    # scan mode
    if len(line) < 3:
        return 0
    if line[2] > 7:
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


def command270(line, input_device, tokennumber):
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


def command275(line, input_device, tokennumber):
    # attenuator
    if len(line) < 3:
        return 0
    if line[2] > 1:
        return 2
    header(tokennumber)
    if line[2] == 0:
        v_icom_vars.Civ_out.extend([0x0, 0xfd])
    else:
        v_icom_vars.Civ_out.extend([0x20, 0xfd])
    return 1


def command361(line, input_device, tokennumber):
    # power off / on
    if len(line) < 3:
        return 0
    if line[2] > 2:
        return 2
    header(tokennumber)
    if line[2] == 0:
        v_icom_vars.Civ_out.extend([0x0, 0xfd])
    else:
        v_icom_vars.Civ_out = bytearray([0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe,
        0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe,
                                         0xfe, 0xfe, 0xfe, v_icom_vars.civ_address, 0xe0, 0x18, 0x01, 0xfd])

    return 1


def answercommand364(line, input_device, tokennumber):
    # for memory commands
    v_icom_vars.ask_content = 0
    ret = command_memory(line, input_device, tokennumber)
    v_icom_vars.ask_content = 4
    return ret


def command365(line, input_device, tokennumber):
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
            v_icom_vars.Civ_out[9 + v_icom_vars.command_storage:14 + v_icom_vars.command_storage] = frequ
            v_icom_vars.ask_content = 0
            return 1
        else:
            return ret


def command367(line, input_device, tokennumber):
    # memory split select
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
        if line[3] > 1 or line[4] > 3:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        # modify content
        temp = line[3] * 16 + line[4]
        v_icom_vars.Civ_out[8 + v_icom_vars.command_storage] = temp
        v_icom_vars.ask_content = 0
        return 1


def command369(line, input_device, tokennumber):
    # memory mode filter
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
        if line[3] > 7 or line[4] > 2:
            return 2
        header(tokennumber)
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        # modify content
        if line[3] > 5:
            line[3] += 1
        v_icom_vars.Civ_out[14 + v_icom_vars.command_storage:16 + v_icom_vars.command_storage] = [line[3], line[4] + 1]
        return 1


def command371(line, input_device, tokennumber):
    # memory data mode
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 4:
            return 0
        if line[3] > 1:
            return 2
        header(tokennumber)
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        # modify content
        temp1 = v_icom_vars.Civ_out[16 + v_icom_vars.command_storage] & 0x0f
        temp1 = temp1 | (line[3] << 4)
        v_icom_vars.Civ_out[16 + v_icom_vars.command_storage] = temp1
        v_icom_vars.ask_content = 0
        return 1


def command373(line, input_device, tokennumber):
    # memory tone
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 4:
            return 0
        if line[3] > 3:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        temp1 = v_icom_vars.Civ_out[16 + v_icom_vars.command_storage] & 0xf0
        temp1 = temp1 | line[3]
        v_icom_vars.Civ_out[16 + v_icom_vars.command_storage] = temp1
        v_icom_vars.ask_content = 0
        return 1


def command375(line, input_device, tokennumber):
    # memory memory repeater tone
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 4:
            return 0
        if line[3] > 49:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        v_icom_vars.Civ_out[17 + v_icom_vars.command_storage] = 0
        v_icom_vars.Civ_out[18 + v_icom_vars.command_storage:20 + v_icom_vars.command_storage] = v_icom_vars.tone_frequency[line[3]]
        v_icom_vars.ask_content = 0
        return 1


def command377(line, input_device, tokennumber):
    # memory memory tone squelch
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 4:
            return 0
        if line[3] > 49:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        v_icom_vars.Civ_out[20] = 0
        v_icom_vars.Civ_out[21 + v_icom_vars.command_storage:23 + v_icom_vars.command_storage] = v_icom_vars.tone_frequency[line[3]]
        v_icom_vars.ask_content = 0
        return 1


def command391(line, input_device, tokennumber):
    # memory name
    # return command1159_65(line, input_device, tokennumber, 16, 0, 105, 0)
    if v_icom_vars.ask_content == 0:
        return command_memory(line, input_device, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 4:
            return 0
        if line[3] > 10:
            return 2
        if len(line) < line[3] + 4:
            return 0
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        temp = bytearray(10)
        temp1 = 0
        while temp1 < 10:
            if temp1 < line[3]:
                if check_and_convert_alphabet(line[temp1 + 4], 3) != 255:
                    temp[temp1] = line[temp1 + 4]
                else:
                    temp[temp1] = 0x20
            else:
                temp[temp1] = 0x20
            temp1 += 1
        v_icom_vars.Civ_out[37:47] = temp
        v_icom_vars.ask_content = 0
        return 1


def command393(line, input_device, tokennumber):
    # read bandstack
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 32:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd((line[2] // 3) + 1, 1))
    v_icom_vars.Civ_out.extend([(line[2] % 3) + 1, 0xfd])
    return 1


def command394(line, input_device, tokennumber):
    # copy bandstack
    if len(line) < 4:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 10 or line[3] > 1:
        return 2
    if v_icom_vars.ask_content == 0:
        header(tokennumber)
        v_icom_vars.Civ_out.extend(int_to_bcd(line[2] + 1, 1))
        v_icom_vars.Civ_out.extend([line[3] * 3, 0xfd])
        v_icom_vars.ask_content = 1
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 2:
        header(tokennumber)
        v_icom_vars.Civ_out.extend(bytearray(int_to_bcd(line[2] + 1, 1)))
        v_icom_vars.Civ_out.extend([2])
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        v_icom_vars.ask_content = 0
    return 1


def command395(line, input_device, tokennumber):
    # 8 chanal memory keyer
    if len(line) < 4:
        return 0
    if line[2] > 7:
        return 2
    cwlen = line[3]
    if cwlen == 0 or cwlen > 70:
        return 2
    if len(line) < (cwlen + 4):
        return 0
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


def command397(line, input_device, tokennumber):
    # filter width
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if tokennumber == 397 and line[2] > 49:
        return 2
    if tokennumber == 399 and line[2] > 40:
        return 2
    if tokennumber == 397 and v_icom_vars.last_mode != 2:
        # mode is not AM
        return 2
    if tokennumber == 399 and v_icom_vars.last_mode == 2:
        # mode is AM
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 1))
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def command401(line, input_device, tokennumber):
    # agc
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 13:
        return 2
    if tokennumber == 401 and v_icom_vars.last_mode != 2:
        # mode is not AM
        return 2
    if tokennumber == 403 and v_icom_vars.last_mode == 2:
        # mode is AM
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 1))
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def command405(line, input_device, tokennumber):
    # HPF / LPF
    if len(line) < 4:
        return 0
    if line[2] > 20 or line[3] > 20 or line[2] >= line[3]:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 1))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[3] + 5, 1))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command431(line, input_device, tokennumber):
    # SSB Tx bandwidth
    if len(line) < 4:
        return 0
    if line[2] > 3 or line[3] > 3:
        return 2
    header(tokennumber)
    line[2] *= 16
    line[2] += line[3]
    v_icom_vars.Civ_out.extend([line[2]])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command465(line, input_device, tokennumber):
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


def command589(line, input_device, tokennumber):
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


def command591(line, input_device, tokennumber):
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


def command593(line, input_device, tokennumber):
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


def command627(line, input_device, tokennumber):
    # scope edge commands 1a0112 - 252 + 36x for chanal 4
    if len(line) < 7:
        return 0
    if line[2] > 3:
        return 2
    lf = line[3] * 256 + line[4]
    span = line[5] * 256 + line[6]
    if span > 995:
        return 2
    min = v_icom_vars.number_frequency_range[v_icom_vars.tokennumber_frequency_range_number[tokennumber]][0]
    max = v_icom_vars.number_frequency_range[v_icom_vars.tokennumber_frequency_range_number[tokennumber]][1]
    if lf > max - min - 5:
        return 2
    # real lf, span in kHz:
    lf += min
    span += 5
    # should not exceed maximum
    if lf + span > max:
        lf = max - span
    header(tokennumber)
    # one sk comand for 4 civ commands:
    if line[2] != 3:
        civ_code = bcd_to_int2([v_icom_vars.Civ_out[6], v_icom_vars.Civ_out[7]])
        civ_code += line[2]
    else:
        civ_code = 200 + v_icom_vars.number_civcommand_chanal4[v_icom_vars.tokennumber_frequency_range_number[tokennumber]]
    v_icom_vars.Civ_out[6:8] = int_to_bcd(civ_code, 2)
    # in 100Hz now
    lf *= 10
    span *= 10
    ret, f = command_frequency(lf.to_bytes(3, byteorder="big"), max * 10, 0, 3)
    v_icom_vars.Civ_out.extend(f)
    ret, f = command_frequency((lf + span).to_bytes(3, byteorder="big"), max * 10, 0, 3)
    v_icom_vars.Civ_out.extend(f)
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command628(line, input_device, tokennumber):
    # answercommand for scope edge commands 1a12 - 2154
    if len(line) < 3:
        return 0
    if line[2] > 3:
        return 2
    header(tokennumber)
    # modify civ command depending on chanal
    if line[2] != 3:
        civ_code = bcd_to_int2([v_icom_vars.Civ_out[6], v_icom_vars.Civ_out[7]])
        civ_code += line[2]
    else:
        civ_code = 200 + v_icom_vars.number_civcommand_chanal4[v_icom_vars.tokennumber_frequency_range_number[tokennumber - 1]]
    v_icom_vars.Civ_out[6:8] = int_to_bcd(civ_code, 2)
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    # store chanal for answer
    v_icom_vars.command_storage = line[2]
    return 1


def command663(line,  input_device, tokennumber):
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


def comamnd757(line, input_device, tokennumber):
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
    return 1


def comamnd761(line, input_device, tokennumber):
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
    return 1


def command777(line, input_device, tokennumber):
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
    return 1


def command779(line, input_device, tokennumber):
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
    else:
        return ret
    return 1


def command785(line, input_device, tokennumber):
    # sel / unsel frequency
    if len(line) < 7:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    frequency = 16777216 * line[3] + 65536 * line[4] + 256 * line[5] + line[6]
    if line[2] > 1 or frequency > 74800000:
        return 2
    header(tokennumber)
    ret, freq = command_frequency(line[3:8], 269970000, 30000, 5)
    v_icom_vars.Civ_out.extend([line[2]])
    v_icom_vars.Civ_out.extend(freq)
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def command787(line, input_device, tokennumber):
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
    if line[3] == 6 or line[3] == 7:
        line[3] += 1
        dta = 0
    elif line[3] > 7:
        line[3] -= 8
        dta = 1
    v_icom_vars.Civ_out.extend(line[2:4])
    v_icom_vars.Civ_out.extend([dta, line[4] + 1, 0xfd])
    return 1


def command798(line, input_device, tokennumber):
    # span for scroll-c mode
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 7:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(v_icom_vars.span_center_mode[line[2]])
    return 1


def command804(line, input_device, tokennumber):
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
    return 1


def command818(line, input_device, tokennumber):
    # send to sk directly
    v_sk.info_to_all = bytearray([0x03, 0x32])
    v_sk.info_to_all.extend([v_icom_vars.last_vfo_mem])
    return 1


def command819(line, input_device, tokennumber):
    # send to sk directly
    v_sk.info_to_all = bytearray([0x03, 0x33])
    v_sk.info_to_all.extend([v_icom_vars.last_mode])
    return 1


def command820(line, input_device, tokennumber):
    # send to sk directly
    v_sk.info_to_all = bytearray([0x03, 0x34, 0x0])
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
    return 2


def com253(line, input_device, tokennumber):
    v_sk.info_to_all = bytearray([0xff, 0xfd, 0x04])
    return 1


def com254(line, input_device, tokennumber):
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
    return 1

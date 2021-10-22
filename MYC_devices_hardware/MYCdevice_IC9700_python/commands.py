"""
name: commands.py IC9700
last edited: 20211020
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
        # add commAnd and up three subcommands
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
        # add command and up three subcommands
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
        # add command and up three subcommands
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
        # add command and up three subcommands
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
        # add commnd and up three subcommands
        v_icom_vars.Civ_out.extend(bytearray([temp[7]]))
        try:
            v_icom_vars.Civ_out.extend(bytearray([temp[8]]))
            try:
                v_icom_vars.Civ_out.extend(bytearray([temp[9]]))
                try:
                    v_icom_vars.Civ_out.extend(bytearray([temp[10]]))
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
        elif temp[2] == 9:
            # one 2 byte parameter
            temp1 = line[2] * 256 + line[3]
            temp2 = temp[4] * 256 + temp[5]
            if temp1 > temp2:
                return 2
            header(tokennumber)
            print(temp2)
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
    if adder == 0:
        # < 146 MHz (< 2000000)
        if frequency < 2000000:
            frequency += 144000000
        else:
            # 430 - 439.999999 (< 12000000 -> f + 430M - 2M)
            if frequency < 12000000:
                frequency += 428000000
            else:
                # f + 1240M - 2M - 10M
                frequency += 1228000000
    else:
        # used for memory frequency
        frequency += adder
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


def command_memory_f(line, tokennumber, band):
    # loading the memory content for frequency
    # start getting memorycontent
    if len(line) < 3:
        return 0
    if line[2] > 213:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend([band])
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2] // 2 + 1, 2))
    v_icom_vars.Civ_out.extend([0xfd])
    # split (used for answer and command:
    v_icom_vars.command_storage = line[2] % 2
    if v_icom_vars.ask_content != 4:
        # not for answer command
        v_icom_vars.ask_content = 1
    return 1


def command_memory_n(line, tokennumber):
    # loading the memory content for name
    # line[2] line[3] : band and chanal
    # start getting memorycontent
    if len(line) < 4:
        return 0
    temp1 = line[2] * 256 + line[3]
    if temp1 > 321:
        return 2
    header(tokennumber)
    if temp1 < 107:
        band = 1
    elif temp1 < 214:
        band = 2
        temp1 = temp1 - 107
    else:
        band = 3
        temp1 = temp1 - 214
    v_icom_vars.command_storage = 0
    command_memory(band, temp1)
    return 1


def command_memory_sel(line, tokennumber):
    # loading the memory content for  select
    # line[2] line[3] : band and chanal
    # start getting memorycontent
    if len(line) < 4:
        return 0
    temp1 = line[2] * 256 + line[3]
    if temp1 > 296:
        return 2
    header(tokennumber)
    if temp1 < 100 :
        band = 1
    elif temp1 < 199:
        band = 2
        temp1 = temp1 - 99
    else:
        band = 3
        temp1 = temp1 - 198
        v_icom_vars.command_storage = 0
    command_memory(band, temp1)
    return 1


def command_memory_o(line, tokennumber):
    # loading the memory content for others than f and select and name
    # line[2] line[3] : band and chanal and split
    # start getting memorycontent
    if len(line) < 4:
        return 0
    temp1 = line[2] * 256 + line[3]
    if temp1 > 641:
        return 2
    header(tokennumber)
    temp2 = temp1
    if temp1 < 214:
        # 0 ... 106 * 2 + 1
        band = 1
        temp1 = temp1  //  2
    elif temp1 < 428:
        # 107 to 213 * 2 + 1
        band = 2
        temp1 = (temp1 - 214) // 2
    else:
        band = 3
        temp1 = (temp1 - 428) // 2
    v_icom_vars.command_storage = temp2 % 2
    command_memory(band, temp1)
    return 1


def command_memory(band, chanal):
    v_icom_vars.Civ_out.extend([band])
    v_icom_vars.Civ_out.extend(int_to_bcd(chanal + 1, 2))
    v_icom_vars.Civ_out.extend([0xfd])
    if v_icom_vars.ask_content != 4:
        # not for answer command
        v_icom_vars.ask_content = 1
    return



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


def command_frequency1(line, input_device, tokennumber):
    # frequency
    if len(line) < 6:
        return 0
    ret, temp = command_frequency(line[2:6], 71999999, 0, 5)
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
    v_icom_vars.last_mode = line[2]
    if line[3] > 2:
        return 2
    if line[2] > 5:
        if line[2] == 8:
            line[2] = 0x17
        elif line[2]== 9:
            line[2] = 0x22
        else:
            line[2] += 1
    line[3] += 1
    header(tokennumber)
    v_icom_vars.Civ_out.extend(line[2:4])
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


def command_offset_frequency(line, input_device, tokennumber):
    # offset frequency
    if len(line) < 5:
        return 0
    line = line[2:5]
    tempa = len(line)
    multiplier = 1
    frequency = 0
    while tempa > 0:
        tempb = line[tempa - 1] * multiplier
        frequency += tempb
        multiplier *= 256
        tempa -= 1
    if frequency > 999999:
        return 2
    decimal_string = str(frequency)
    digits = [int(c) for c in decimal_string]
    # fill preceeding "0"
    source = len(bytearray(digits))
    destination = 0
    temp = bytearray(3)
    while source > 0:
        if source == 1:
            temp[destination] = digits[source - 1]
        else:
            temp[destination] = digits[source - 2] * 16 + digits[source - 1]
        source -= 2
        destination += 1
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


def command_scan_resume(line, input_device, tokennumber):
    # scan resume
    if len(line) < 3:
        return 0
    if line[2] > 1:
        return 2
    header(tokennumber)
    if line[2] == 1:
        v_icom_vars.Civ_out[5] = 0xd3
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def command_split_duplex(line, input_device, tokennumber):
    # split
    if len(line) < 3:
        return 0
    if line[2] > 5:
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
        v_icom_vars.Civ_out.extend([0x0, 0xfd])
    else:
        v_icom_vars.Civ_out.extend([0x10, 0xfd])
    return 1


def command_sql(line, input_device, tokennumber):
    # attenuator
    if len(line) < 3:
        return 0
    if line[2] > 7:
        return 2
    header(tokennumber)
    if line[2] > 3:
        line[2] += 2
    v_icom_vars.Civ_out.extend([line[2], 0xfd])
    return 1


def command_Power_on_off1(line, input_device, tokennumber):
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


def answercommand_memory144(line, input_device, tokennumber):
    v_icom_vars.ask_content = 4
    return command_memory_f(line, tokennumber, 1)


def answercommand_memory430(line, input_device, tokennumber):
    v_icom_vars.ask_content = 4
    return command_memory_f(line, tokennumber, 2)


def answercommand_memory1230(line, input_device, tokennumber):
    v_icom_vars.ask_content = 4
    return command_memory_f(line, tokennumber, 3)


def answercommand_memory_select(line, input_device, tokennumber):
    # for select memory command
    v_icom_vars.ask_content = 4
    return command_memory_sel(line, tokennumber)


def answercommand_memory_others(line, input_device, tokennumber):
    # for memory commands except f and select
    v_icom_vars.ask_content = 4
    return command_memory_o(line, tokennumber)


def command_memory_select(line, input_device, tokennumber):
    # memory select
    if v_icom_vars.ask_content == 0:
        return command_memory_sel(line, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 5:
            return 0
        if line[4] > 3:
            return 2
        header(tokennumber)
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        # modify content
        v_icom_vars.Civ_out[9] = line[4]
        v_icom_vars.ask_content = 0
        return 1


def command_memory_frequency(line, input_device, tokennumber, band):
    # memory frequency
    if len(line) < 3:
        return 0
    if v_icom_vars.ask_content == 0:
        return command_memory_f(line, tokennumber, band)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        frequ = 0
        if band == 1:
            if len(line) < 6:
                return 0
            frequ = line[3] * 65536 + line[4] * 256 + line[5]
            if frequ > 1999999:
                return 2
        elif band == 2:
            if len(line) < 6:
                return 0
            frequ = line[3] * 65536 + line[4] * 256 + line[5]
            if frequ > 9999999:
                return 2
        elif Band == 3:
            if len(line) < 7:
                return 0
            frequ = line[3] * 16777216 + line[4] * 65536 + line[5] * 256 + line[6]
            if frequ > 59999999:
                return 2
        header(tokennumber)
        # modify content of answer_storage
        ret = 2
        if band == 1:
            ret, frequ = command_frequency(line[3:6], 2000000, 144000000, 5)
        elif band == 2:
            ret, frequ = command_frequency(line[4:7], 10000000, 430000000, 5)
        elif band == 3:
            ret, frequ = command_frequency(line[4:7], 40000000, 1230000000, 5)
        if ret == 1:
            v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
            v_icom_vars.Civ_out[10 + v_icom_vars.command_storage * 47:15 + v_icom_vars.command_storage * 47] = frequ
            v_icom_vars.ask_content = 0
            return 1
        else:
            return ret


def command_memory_frequency144(line, input_device, tokennumber):
    # memory frequency 144MHz
    return command_memory_frequency(line, input_device, tokennumber, 1)


def command_memory_frequency430(line, input_device, tokennumber):
    # memory frequency 144MHz
    return command_memory_frequency(line, input_device, tokennumber, 2)


def command_memory_frequency1230(line, input_device, tokennumber):
    # memory frequency 144MHz
    return command_memory_frequency(line, input_device, tokennumber, 3)


def command_memory_mode_filter(line, input_device, tokennumber):
    # memory mode filter
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
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
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        # modify content
        if line[4] > 5:
            line[4] += 1
        if line[4] == 9:
            line[4] = 0x17
        if line[4] == 10:
            line[4]= 0x22
        v_icom_vars.Civ_out[15 + v_icom_vars.command_storage * 49:17 + v_icom_vars.command_storage * 49] = [line[4], line[5] + 1]
        return 1


def command_memory_data_mode(line, input_device, tokennumber):
    # memory data mode
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
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
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        # modify content
        v_icom_vars.Civ_out[17 + v_icom_vars.command_storage * 49] = line[4]
        v_icom_vars.ask_content = 0
        return 1


def command_memory_tone(line, input_device, tokennumber):
    # memory tone_tsql_dtcs
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 5:
            return 0
        if line[4] > 3:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        temp1 = v_icom_vars.Civ_out[18 + v_icom_vars.command_storage * 49] & 0xf0
        temp1 = temp1 | line[4]
        v_icom_vars.Civ_out[18 + v_icom_vars.command_storage] = temp1
        v_icom_vars.ask_content = 0
        return 1


def command_memory_duplex(line, input_device, tokennumber):
    # memory duplex
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 5:
            return 0
        if line[4] > 3:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        temp1 = (v_icom_vars.Civ_out[18 + v_icom_vars.command_storage * 49] & 0x0f) | (line[4] << 4)
        v_icom_vars.Civ_out[18 + v_icom_vars.command_storage] = temp1
        v_icom_vars.ask_content = 0
        return 1


def command_memory_dsql(line, input_device, tokennumber):
    # memory dqsl
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 5:
            return 0
        if line[4] > 2:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        v_icom_vars.Civ_out[19 + v_icom_vars.command_storage * 49] = (line[4] << 4)
        v_icom_vars.ask_content = 0
        return 1


def command_memory_repeater_tone(line, input_device, tokennumber):
    # memory repeater tone
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
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
        v_icom_vars.Civ_out[21 + v_icom_vars.command_storage * 49:23 + v_icom_vars.command_storage * 49] = v_icom_vars.tone_frequency[line[4]]
        v_icom_vars.ask_content = 0
        return 1


def command_memory_tone_squelch(line, input_device, tokennumber):
    # memory tone squelch
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
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
        v_icom_vars.Civ_out[24 + v_icom_vars.command_storage * 49:26 + v_icom_vars.command_storage * 49] = v_icom_vars.tone_frequency[line[4]]
        v_icom_vars.ask_content = 0
        return 1


def command_memory_dtcs(line, input_device, tokennumber):
    # memory dtcs
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 5:
            return 0
        if line[4] > 103:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        v_icom_vars.Civ_out[27 + v_icom_vars.command_storage * 49:29 + v_icom_vars.command_storage * 49] = v_icom_vars.dtcs_frequency[line[4]]
        v_icom_vars.ask_content = 0
        return 1


def command_memory_dtcs_pol(line, input_device, tokennumber):
    # memory dtcs polarity
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 5:
            return 0
        if line[4] > 3:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        if line[4] == 2:
            line[4] = 0x10
        if line[4] == 3:
            line[4] = 0x11
        v_icom_vars.Civ_out[26 + v_icom_vars.command_storage * 49] = line[4]
        v_icom_vars.ask_content = 0
        return 1


def command_memory_dv_code(line, input_device, tokennumber):
    # memory dv code
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
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
        v_icom_vars.Civ_out[29 + v_icom_vars.command_storage] = int.from_bytes(int_to_bcd(line[4], 1), "big")
        v_icom_vars.ask_content = 0
        return 1


def command_memory_duplex_offset_frequency(line, input_device, tokennumber):
    # memory duplex offset frequency
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 5:
        # empty memory
        return 2
    else:
        if len(line) < 7:
            return 0
        line = line[4:6]
        tempa = len(line)
        multiplier = 1
        frequency = 0
        while tempa > 0:
            tempb = line[tempa - 1] * multiplier
            frequency += tempb
            multiplier *= 256
            tempa -= 1
        if frequency > 999999:
            return 2
        decimal_string = str(frequency)
        digits = [int(c) for c in decimal_string]
        # fill preceeding "0"
        source = len(bytearray(digits))
        destination = 0
        temp = bytearray(3)
        while source > 0:
            if source == 1:
                temp[destination] = digits[source - 1]
            else:
                temp[destination] = digits[source - 2] * 16 + digits[source - 1]
            source -= 2
            destination += 1
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        v_icom_vars.Civ_out[27 + v_icom_vars.command_storage * 49:29 + v_icom_vars.command_storage * 49] = temp
        v_icom_vars.ask_content = 0
        return 1


def command_memory_UR(line, input_device, tokennumber):
    # memory UR
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
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
        if line[4] > 3:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        temp1 = v_icom_vars.Civ_out[16 + v_icom_vars.command_storage] & 0xf0
        temp1 = temp1 | line[3]
        v_icom_vars.Civ_out[16 + v_icom_vars.command_storage] = temp1
        v_icom_vars.ask_content = 0
        return 1


def command_memory_R1(line, input_device, tokennumber):
    # memory UR
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
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
        if line[4] > 3:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        temp1 = v_icom_vars.Civ_out[16 + v_icom_vars.command_storage] & 0xf0
        temp1 = temp1 | line[3]
        v_icom_vars.Civ_out[16 + v_icom_vars.command_storage] = temp1
        v_icom_vars.ask_content = 0
        return 1


def command_memory_R2(line, input_device, tokennumber):
    # memory UR
    if v_icom_vars.ask_content == 0:
        return command_memory_o(line, tokennumber)
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
        if line[4] > 3:
            return 2
        header(tokennumber)
        # modify content
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        temp1 = v_icom_vars.Civ_out[16 + v_icom_vars.command_storage] & 0xf0
        temp1 = temp1 | line[3]
        v_icom_vars.Civ_out[16 + v_icom_vars.command_storage] = temp1
        v_icom_vars.ask_content = 0
        return 1


def command_memory_name(line, input_device, tokennumber):
    # memory name
    # return command1159_65(line, input_device, tokennumber, 16, 0, 105, 0)
    if v_icom_vars.ask_content == 0:
        return command_memory_n(line, tokennumber)
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


def answer_bandstack(line, input_device, tokennumber):
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


def command_copy_bandstack(line, input_device, tokennumber):
    # copy bandstack
    if len(line) < 4:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 2 or line[3] > 1:
        return 2
    if line[3] == 0:
        line[3] = 1
    else:
        line[3] = 3
    if v_icom_vars.ask_content == 0:
        header(tokennumber)
        v_icom_vars.Civ_out.extend([line[2] + 1])
        v_icom_vars.Civ_out.extend([line[3] , 0xfd])
        v_icom_vars.ask_content = 1
    elif v_icom_vars.ask_content == 1:
        return 0
    elif v_icom_vars.ask_content == 2:
        header(tokennumber)
        v_icom_vars.Civ_out.extend(v_icom_vars.answer_storage)
        v_icom_vars.Civ_out[7] = 2
        # to middle
        v_icom_vars.Civ_out[7] = 2
        v_icom_vars.ask_content = 0
    return 1


def command_memory_keyer(line, input_device, tokennumber):
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


def command_hpf_lpf(line, input_device, tokennumber):
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


def commandtx_bw(line, input_device, tokennumber):
    # Tx bandwidth
    if len(line) < 4:
        return 0
    if line[2] > 3 or line[3] > 3:
        return 2
    header(tokennumber)
    temp = line[2] << 4
    temp = temp | line[3]
    v_icom_vars.Civ_out.extend([temp, 0xfd])
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


def  command_network_address(line, input_device, tokennumber):
    # network address
    if len(line) < 6:
        return 0
    if line[5] == 255:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2], 2))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[3], 2))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[4], 2))
    v_icom_vars.Civ_out.extend(int_to_bcd(line[5], 2))
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
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
    # in kHz:
    lf += min
    # should not exceed maximum
    if lf + span > max:
        lf = max - span
    header(tokennumber)
    # one sk comand for 4 civ commands:
    if line[2] != 3:
        civ_code = bcd_to_int2([v_icom_vars.Civ_out[6], v_icom_vars.Civ_out[7]])
        civ_code += line[2]
    else:
        civ_code = v_icom_vars.number_civcommand_chanal4[tokennumber]
    v_icom_vars.Civ_out[6:8] = int_to_bcd(civ_code, 2)
    # in 100Hz now
    lf *=10
    span *= 10
    f = int_to_4bcd_reverse(lf)
    v_icom_vars.Civ_out.extend(f)
    f = int_to_4bcd_reverse(lf + span)
    v_icom_vars.Civ_out.extend(f)
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
    else:
        civ_code = v_icom_vars.number_civcommand_chanal4[tokennumber]
    v_icom_vars.Civ_out[6:8] = int_to_bcd(civ_code, 2)
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


def commandmanual_gps_pos(line, input_device, tokennumber):
    # command for gps position
    if len(line) < 13:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[5] > 1 or line[9] > 1 or line[12] > 1:
        return 2
    if line[2] > 90:
        return 2
    if line[2] == 90 and line[3] != 0 and line[4]!= 0:
        return 2
    if 256 *line[3] + line[4] > 5999:
        return 2
    if line[6] > 180:
        return 2
    if line[6] == 180 and line[7] != 0 and line[8]!= 0:
        return 2
    if 256 *line[7] + line[8] > 5999:
        return 2
    if 256 * line[10] + line[11] > 10000:
        return 2
    header(tokennumber)
    # long
    v_icom_vars.Civ_out.extend(int_to_bcd(line[2] ,1))
    v_icom_vars.Civ_out.extend(int_to_bcd(256 * line[3] + line[4], 2))
    v_icom_vars.Civ_out.extend([0x00, line[5]])
    # lat
    v_icom_vars.Civ_out.extend(int_to_bcd(line[6], 2))
    v_icom_vars.Civ_out.extend(int_to_bcd(256 * line[7] + line[8], 2))
    v_icom_vars.Civ_out.extend([0x00, line[9]])
    # alt
    v_icom_vars.Civ_out.extend(int_to_bcd(10 * (256 * line[10] + line[11]), 3))
    v_icom_vars.Civ_out.extend([line[12], 0xfd])
    return 1


def command_gps_symbol(line, input_device, tokennumber):
    if len(line) < 6:
        return 0
    header(tokennumber)
    a = check_and_convert_alphabet(line[3], 7)
    print (a, line[3])
    if a == 255 :
        return 2
    else:
        v_icom_vars.Civ_out.extend([a])
    a = check_and_convert_alphabet(line[5], 6)
    if a == 255:
        return 2
    else:
        v_icom_vars.Civ_out.extend([a, 0xfd])
    return 1


def command_alarm_group(line, input_device, tokennumber):
    if len(line) < 4:
        return 0
    num = line[2] * 256 + line[3]
    if num > 5991:
        return 2
    header(tokennumber)
    num += 8
    v_icom_vars.Civ_out.extend(int_to_bcd(num, 2))
    v_icom_vars.Civ_out.extend([0x00,0xfd])
    return 1


def comamnd_data_mode_wth_filter(line, input_device, tokennumber):
    # data_mode with filter
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


def comamnd_repeater_tone_sql(line, input_device, tokennumber):
    # repeater /tone T-SQL
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


def command_dtcs(line, input_device, tokennumber):
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
    v_icom_vars.Civ_out.extend([v_icom_vars.dtcs_pol[line[2]]])
    v_icom_vars.Civ_out.extend(v_icom_vars.dtcs_frequency[line[3]])
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def command_user_bandedge(line, input_device, tokennumber):
    # user-set TX band edge frequencies
    if len(line) < 11:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 29:
        return 2
    f1 = line[3] * 16777216 + line[4] * 65536 + line[5] * 256 + line[6]
    if f1 > 112000003:
        return 2
    f2 = line[7] * 16777216 + line[8] * 65536 + line[9] * 256 + line[10]
    if f2 > 112000003:
        return 2
    if f2 <= f1:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend([line[2] + 1])
    ret, temp = command_frequency(line[3:7], 113000000, 0, 5)
    print(temp,len(temp))
    v_icom_vars.Civ_out.extend(temp)
    v_icom_vars.Civ_out.extend(bytearray([0x2d]))
    ret, temp = command_frequency(line[8:11], 113000000, 0, 5)
    print(temp)
    v_icom_vars.Civ_out.extend(temp)
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_rit(line, input_device, tokennumber):
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


def command_main_f(line, input_device, tokennumber):
    # sel / unsel frequency (main)
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


def command_main_mode(line, input_device, tokennumber):
    # sel / unsel mode - filter (main)
    if len(line) < 5:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] >2 or line[3] > 13 or line[4] > 2:
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


def command_main_mode2(line, input_device, tokennumber):
    # sel / unsel mode - filter (main) and data
    if len(line) < 6:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 1 or line[3] > 10 or line[4] > 1 or line[5] > 2:
        return 2
    header(tokennumber)
    dta = 0
    if line[3] == 8:
        line[3] = 8
    elif  line[3] == 9:
        line[3] = 9
    elif line[3] > 5:
        line[3] += 1
    if line[4] == 1:
        line[5] = 0
    else:
        line[5] += 1
    v_icom_vars.Civ_out.extend(line[2:6])
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def command_scope_mode(line, input_device, tokennumber):
    # scope mode
    if len(line) < 4:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 1 or line[3] > 3:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(line[2:4])
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def command_scope_hold(line, input_device, tokennumber):
    # scope hold
    ret = command_scope_hold_(line, input_device, tokennumber, 1)
    return ret


def command_scope_sweep_speed(line, input_device, tokennumber):
    # sweep speed
    ret = command_scope_hold_(line, input_device, tokennumber, 2)
    return ret


def command_scope_hold_(line, input_device, tokennumber, par):
    if len(line) < 4:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 1 or line[3] > par:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend(line[2:4])
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def command_scope_span(line, input_device, tokennumber):
    # span
    if len(line) < 4:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 1 or line[3] > 7:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend([line[2]])
    v_icom_vars.Civ_out.extend(v_icom_vars.span_center_mode[line[3]])
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def command_scope_edge_number(line, input_device, tokennumber):
    # edge number
    if len(line) < 4:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 1 or line[3] > 4:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend([line[2]])
    v_icom_vars.Civ_out.extend([line[3] + 1])
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def command_scope_reference(line, input_device, tokennumber):
    # scope reference level
    if len(line) < 4:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 1 or line[3] > 80:
        return 2
    header(tokennumber)
    print(line[3])
    pm = 0
    if line[3] == 40:
        line[3] = 0
    else:
        if line[3] > 40:
            # + (20 - 20: 0 - +20)
            line[3] -= 40
        else:
            # - (0 - 19 : -20 - -1)
            pm = 1
            line[3] = 40 - line[3]
    print(line[3])
    val = line[3] * 50
    print(val)
    v_icom_vars.Civ_out.extend([line[2]])
    v_icom_vars.Civ_out.extend(int_to_bcd(val, 2))
    v_icom_vars.Civ_out.extend(bytearray([pm, 0xfd]))
    return 1


def command_gps_select(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 2:
        return 2
    header(tokennumber)
    if line[2] == 0:
        v_icom_vars.Civ_out.extend([line[2]])
    else:
        v_icom_vars.Civ_out.extend([line[2] + 1])
    v_icom_vars.Civ_out.extend(bytearray([0xfd]))
    return 1


def command_fixed_scope_edge_144(line, input_device, tokennumber):
    if len(line) < 7:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 3:
        return 2
    frequency1 = line[3] * 256 + line[4]
    if frequency1> 1995:
        return 2
    frequency2 = line[5] * 256 + line[6]
    if frequency2 > 995:
        return 2
    frequency2 += frequency1 + 5
    if frequency2 > 2000:
        return 2
    header(tokennumber)
    frequency1 = 144000000 + frequency1 * 1000
    frequency2 = 144000000 + frequency2 * 1000
    v_icom_vars.Civ_out.extend([1, line[2] + 1])
    v_icom_vars.Civ_out.extend(command_frequency_from_int(frequency1))
    v_icom_vars.Civ_out.extend(command_frequency_from_int(frequency2))
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def c_answer_fixed_scope_edge_144(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 3:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend([1, line[2] + 1, 0xfd])
    return 1


def command_fixed_scope_edge_430(line, input_device, tokennumber):
    if len(line) < 7:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 3:
        return 2
    frequency1 = line[3] * 256 + line[4]
    if frequency1> 9995:
        return 2
    frequency2 = line[5] * 256 + line[6]
    if frequency2 > 995:
        return 2
    frequency2 += frequency1 + 5
    if frequency2 > 10000:
        return 2
    header(tokennumber)
    frequency1 = 430000000 + frequency1 * 1000
    frequency2 = 430000000 + frequency2 * 1000
    v_icom_vars.Civ_out.extend([2, line[2] + 1])
    v_icom_vars.Civ_out.extend(command_frequency_from_int(frequency1))
    v_icom_vars.Civ_out.extend(command_frequency_from_int(frequency2))
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def c_answer_fixed_scope_edge_430(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 3:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend([2, line[2] + 1, 0xfd])
    return 1


def command_fixed_scope_edge_1240(line, input_device, tokennumber):
    if len(line) < 7:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 3:
        return 2
    frequency1 = line[3] * 256 + line[4]
    if frequency1> 59995:
        return 2
    frequency2 = line[5] * 256 + line[6]
    if frequency2 > 995:
        return 2
    frequency2 += frequency1 + 5
    if frequency2 > 600000:
        return 2
    header(tokennumber)
    frequency1 = 1240000000 + frequency1 * 1000
    frequency2 = 1240000000 + frequency2 * 1000
    v_icom_vars.Civ_out.extend([3, line[2] + 1])
    v_icom_vars.Civ_out.extend(command_frequency_from_int(frequency1))
    v_icom_vars.Civ_out.extend(command_frequency_from_int(frequency2))
    v_icom_vars.Civ_out.extend([0xfd])
    return 1


def c_answer_fixed_scope_edge_1240(line, input_device, tokennumber):
    if len(line) < 3:
        return 0
    temp = v_icom_vars.token_civ_code[tokennumber]
    if temp[0] != v_icom_vars.country:
        return 2
    if line[2] > 3:
        return 2
    header(tokennumber)
    v_icom_vars.Civ_out.extend([3, line[2] + 1, 0xfd])
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

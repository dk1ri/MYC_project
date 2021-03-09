"""
name: answers.py IC7300
last edited: 20210304
handling of answers from the radio
"""

import time

from misc_functions import *
from commands import *

import v_sk
import v_icom_vars


def answer_nop(line):
    return 1


def find_token(line):
    # tokennumbers must not have gaps
    # if there are operate and answer commands: answer must immediately follow the operate command
    # not used now; cannot be used, if calls are used by multiple commands
    temp = 255
    second = 0
    while temp < 790 and second != 2:
        temp += 1
        if second == 1:
            if v_icom_vars.token_civ_code[temp] != line:
                temp -= 1
            second = 2
        if second == 0 and v_icom_vars.token_civ_code[temp] == line:
            second = 1
    v_sk.info_to_all = temp.to_bytes(2, byteorder="big")
    return


def frequency_for_answer(line, adder, par, actual_f):
    # line contain frequency only:
    # 5 bytes: 1 Hz resolution up tp GHz
    # 3 bytes: 100Hz resolution: up to 99MHz
    # lsb first
    # convert to bytearray with par parameter bytes
    temp1 = 0
    frequency = 0
    multiplier = 1
    while temp1 < len(line):
        temp2 = bcd_to_int(line[temp1])
        frequency = frequency + multiplier * temp2
        multiplier *= 100
        temp1 += 1
    # 400M - 470M
    if frequency > 199999999:
        frequency -= 200000000
    frequency -= adder
    if actual_f == 1:
        v_icom_vars.last_frequency = frequency
    temp1 = frequency.to_bytes(par, byteorder="big")
    return temp1


def answer_frequency_scope_edge(line):
    # line contain 3 bytes
    # convert 3 bcd bytes of frequency (lsb first) of line to integer frequency
    temp1 = 0
    frequency = 0
    multiplier = 1
    while temp1 < 3:
        temp2 = bcd_to_int(line[temp1])
        frequency += multiplier * temp2
        multiplier *= 100
        temp1 += 1
    frequency //= 10
    return frequency


def answer_x_1_b_x(line, adder, position):
    # used for all answers x CIV commandbytes, one byte bcd coded parameter at "position" with base "adder"
    v_sk.info_to_all = v_sk.answer_token
    v_sk.info_to_all.extend([bcd_to_int(line[position]) + adder])
    return 1


def answer_1_1_b(line):
    # used for all answers: 1 CIV  commandbyte, one byte bcd coded parameter with base 0
    return answer_x_1_b_x(line, 0, 5)


def answer_2_1_b(line):
    # used for all answers: 2 CIV commandbytes, one byte bcd coded parameter with base 0
    return answer_x_1_b_x(line, 0, 6)


def answer_2_1_b_1(line):
    # used for all answers: 2 CIV commandbytes, one byte bcd coded parameter with base 1
    return answer_x_1_b_x(line, -1, 6)


def answer_3_1_b(line):
    # used for all answers: 3 CIV commandbytes, one byte bcd coded parameter with base 0
    return answer_x_1_b_x(line, 0, 7)


def answer_4_1_b(line):
    # used for all answers: 4 CIV commandbytes, one byte bcd coded parameter with base 0
    return answer_x_1_b_x(line, 0, 8)


def answer_4_1_b_1(line):
    # used for all answers 4 CIV commandbytes, one byte bcd coded parameter with base 1
    return answer_x_1_b_x(line, -1, 8)


def answer_x_2_b_x(line, position, adder, myc):
    # used for all answers: x  CIV commandbytes, two byte bcd coded parameter with base "adder"
    # to myc byte MYC parameter
    v_sk.info_to_all = v_sk.answer_token
    if myc == 1:
        v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[position:2 + position]) + adder]))
    else:
        v_sk.info_to_all.extend(bcd_to_ba_2(line[position:2 + position], adder))
    return 1


def answer_2_2_b_0_1(line):
    # used for all answers: 2 commandbytes, two byte bcd coded parameter with base 0 to 1 byte MYC parameter
    return answer_x_2_b_x(line, 6, 0, 1)


def answer_2_2_b_1_1(line):
    # used for all answers: 2 commandbytes, two byte bcd coded parameter with base 1 to 1 byte MYC parameter
    return answer_x_2_b_x(line, 6, -1, 1)


def answer_4_2_b_0(line):
    # used for all answers: 4 commandbytes, two byte bcd coded parameter  with base 0 to 2 byte MYC parameter
    return answer_x_2_b_x(line, 8, 0, 2)


def answer_4_2_b_0_1(line):
    # used for all answers 4 commandbytes, two byte bcd coded parameter  with base 0 to 1 byte MYC parameter
    return answer_x_2_b_x(line, 8, 0, 1)


def answer_4_2_b_1(line):
    # used for all answers: 4 commandbytes, two byte bcd coded parameter  with base 1 to 2 byte MYC parameter
    return answer_x_2_b_x(line, 8, -1, 2)


def answer_4_1_b_28(line):
    # used for all answers: 4 CIV commandbytes, one byte bcd coded parameter with base 28
    return answer_x_1_b_x(line, -28, 8)


def answer_string(line):
    # aswers with one string
    v_sk.info_to_all = v_sk.answer_token
    start = v_icom_vars.civ_command_length + 4
    v_sk.info_to_all.extend([0])
    stringcount = 0
    end = line.find(0xfd)
    while start < end:
        # -1 because of "fd"
        v_sk.info_to_all.extend(bytearray([line[start]]))
        stringcount += 1
        start += 1
    v_sk.info_to_all[2] = stringcount
    return 1


def answer00(line):
    # frequency
    v_sk.info_to_all = bytearray([0x01, 0x01])
    v_sk.info_to_all.extend(frequency_for_answer(line[5:10], 30000, 4, 1))
    return 1


def answer01(line):
    # mode and filter
    v_sk.info_to_all = bytearray([0x01, 0x03])
    if line[5] > 5:
        line[5] -= 1
    v_sk.info_to_all.extend([line[5]])
    line[6] -= 1
    v_sk.info_to_all.extend([line[6]])
    v_icom_vars.last_mode = line[5]
    return 1


def answer02(line):
    # scope edge
    v_sk.info_to_all = bytearray([0x01, 0x4])
    v_sk.info_to_all.extend(frequency_for_answer(line[5:10], 30000, 4, 0))
    v_sk.info_to_all.extend(frequency_for_answer(line[11:16], 30000, 4, 0))
    return 1


def answer11(line):
    # attenuator
    v_sk.info_to_all = bytearray([0x01, 0x16])
    if line[5] == 0:
        v_sk.info_to_all.extend([0x00])
    else:
        v_sk.info_to_all.extend([0x01])
    return 1


def answer17(line):
    # cw message
    v_sk.info_to_all = v_sk.answer_token
    if line[5] == 0:
        v_sk.info_to_all.extend([0x00])
    else:
        v_sk.info_to_all.extend([0x01])
    return 1


def answer1a00(line):
    # memory
    if v_icom_vars.ask_content != 4:
        # store data for following command
        if v_icom_vars.ask_content == 1:
            if len(line) > 12:
                v_icom_vars.answer_storage = line[6:]
                v_icom_vars.ask_content = 2
            else:
                # memory empty
                # 5 means error
                v_icom_vars.ask_content = 5
                return 2
        else:
            return 0
    else:
        # analyze data
        v_sk.info_to_all = v_sk.last_token[:]
        v_sk.info_to_all.extend([line[6] * 256 + line[7] - 1])
        if v_sk.last_token == bytearray([0x01, 0x6c]):
            # raw data
            length = len(line[8:-1])
            v_sk.info_to_all.extend([length])
            v_sk.info_to_all.extend(line[6:-1])
        elif v_sk.last_token == bytearray([0x01, 0x6e]) or v_sk.last_token == bytearray([0x01, 0x7c]):
            # frequency
            v_sk.info_to_all.extend(frequency_for_answer(line[v_icom_vars.command_storage + 9:v_icom_vars.command_storage + 14], 30000, 4, 0))
        elif v_sk.last_token == bytearray([0x01, 0x70]):
            # split select
            v_sk.info_to_all.extend([(line[v_icom_vars.command_storage + 8] & 0xf0) >> 4])
            v_sk.info_to_all.extend([line[v_icom_vars.command_storage + 8] & 0x0f])
        elif v_sk.last_token == bytearray([0x01, 0x72]) or v_sk.last_token == bytearray([0x01, 0x7e]):
            # mode
            mode = bcd_to_int((line[v_icom_vars.command_storage + 14]))
            if mode > 5:
                mode -= 1
            filter = (line[v_icom_vars.command_storage + 15]) - 1
            v_sk.info_to_all.extend(bytearray([mode, filter]))
        elif v_sk.last_token == bytearray([0x01, 0x74]) or v_sk.last_token == bytearray([0x01, 0x80]):
            # data mode
            data_mode = (line[v_icom_vars.command_storage + 16] & 0xf0) >> 4
            v_sk.info_to_all.extend(bytearray([data_mode]))
        elif v_sk.last_token == bytearray([0x01, 0x76]) or v_sk.last_token == bytearray([0x01, 0x82]):
            # tone tqsl
            sql = line[v_icom_vars.command_storage + 16] & 0x0f
            v_sk.info_to_all.extend(bytearray([sql]))
        elif v_sk.last_token == bytearray([0x01, 0x78]) or v_sk.last_token == bytearray([0x01, 0x84]):
            # tone frequency
            temp = 0
            tone1 = line[v_icom_vars.command_storage + 18]
            tone2 = line[v_icom_vars.command_storage + 19]
            while temp < 50 and ([tone1, tone2] != v_icom_vars.tone_frequency[temp]):
                temp += 1
            v_sk.info_to_all.extend(bytearray([temp]))
        elif v_sk.last_token == bytearray([0x01, 0x7a]) or v_sk.last_token == bytearray([0x01, 0x86]):
            # tone squelch frequency
            temp = 0
            tone1 = line[v_icom_vars.command_storage + 21]
            tone2 = line[v_icom_vars.command_storage + 22]
            while temp < 50 and ([tone1, tone2] != v_icom_vars.tone_frequency[temp]):
                temp += 1
            v_sk.info_to_all.extend(bytearray([temp]))
        elif v_sk.last_token == bytearray([0x01, 0x88]):
            # memory name
            v_sk.info_to_all.extend([16])
            v_sk.info_to_all.extend(line[35:45])
        v_icom_vars.ask_content = 0
    return 1


def answer1a01(line):
    # band stack
    if v_icom_vars.ask_content == 0:
        v_sk.info_to_all = v_sk.answer_token
        v_sk.info_to_all.extend([line[6] * 10 + line[7]])
        v_sk.info_to_all.extend([len(line) - 8])
        v_sk.info_to_all.extend(line[8: len(line) - 1])
    elif v_icom_vars.ask_content == 1:
        # store data for following command
        v_icom_vars.answer_storage = line[8:]
        v_icom_vars.ask_content = 2
    return 1


def answer1a02(line):
    # keyer memory
    v_sk.info_to_all = v_sk.answer_token
    # memory number:
    v_sk.info_to_all.extend(bytearray([line[6] - 1]))
    length = len(line) - 8
    v_sk.info_to_all.extend(bytearray([length]))
    temp1 = 0
    temp2 = 7
    while temp1 < length:
        v_sk.info_to_all.extend(bytearray([line[temp2]]))
        temp1 += 1
        temp2 += 1
    return 1


def answer1a050001(line):
    # used for all hpf_lpf_answers
    v_sk.info_to_all = v_sk.answer_token
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[8])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[9]) - 5]))
    return 1


def answer1a050014(line):
    # used for all answers with one parameter with  modification for 1a050x commands
    v_sk.info_to_all = v_sk.answer_token
    v_sk.info_to_all.extend([(line[8] & 0xf0) >> 4])
    v_sk.info_to_all.extend([line[8] & 0x0f])
    return 1


def answer1a050031(line):
    # split offset
    v_sk.info_to_all = v_sk.answer_token
    v_sk.info_to_all.extend(bcd_plusminus_to_int(line, 8, 9999, 3, 2, 10))
    return 1


def answer1a050094(line):
    # date
    v_sk.info_to_all = v_sk.answer_token
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[8:10]) - 2020]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[10] - 1)]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[11] - 1)]))
    return 1


def answer1a050095(line):
    # time
    v_sk.info_to_all = v_sk.answer_token
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[8])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[9])]))
    return 1


def answer1a050096(line):
    # utc
    minutes = bcd_to_int(line[8]) * 60 + bcd_to_int(line[9])
    if line[10] == 0:
        # plus
        minutes += 840
    else:
        minutes = 840 - minutes
    v_sk.info_to_all = v_sk.answer_token
    v_sk.info_to_all.extend(minutes.to_bytes(2, byteorder="big"))
    return 1


def answer1a050104(line):
    # color
    v_sk.info_to_all = v_sk.answer_token
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[8:10])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[10:12])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[12:14])]))
    return 1


def answer1a050112(line):
    # scope band edge
    v_sk.info_to_all = v_sk.answer_token
    v_sk.info_to_all.extend([v_icom_vars.command_storage])
    tokennumber = v_sk.last_token[0] * 256 + v_sk.last_token[1]
    min = v_icom_vars.number_frequency_range[v_icom_vars.tokennumber_frequency_range_number[tokennumber]][0]
    flow = answer_frequency_scope_edge(line[8:11]) - min
    temp1 = flow.to_bytes(2, byteorder="big")
    v_sk.info_to_all.extend(temp1)
    span = (answer_frequency_scope_edge(line[11:14]) - min - flow - 5)
    temp1 = span.to_bytes(2, byteorder="big")
    v_sk.info_to_all.extend(temp1)
    return 1


def answer1a06(line):
    # Data mode
    v_sk.info_to_all = v_sk.answer_token
    temp1 = 0
    if line[6] == 1:
        temp1 = line[7]
    v_sk.info_to_all.extend(bytearray([temp1]))
    return 1


def answer1b00(line):
    # tone frequncy
    v_sk.info_to_all = v_sk.answer_token
    temp = 0
    while temp < 51 and [line[7], line[8]] != v_icom_vars.tone_frequency[temp]:
        temp += 1
    v_sk.info_to_all.extend(bytearray([temp]))
    return 1


def answer1b02(line):
    # DTCS code
    v_sk.info_to_all = v_sk.answer_token
    if line[6] == 0x00:
        v_sk.info_to_all.extend([0])
    elif line[6] == 0x01:
        v_sk.info_to_all.extend([1])
    elif line[6] == 0x10:
        v_sk.info_to_all.extend([2])
    elif line[6] == 0x11:
        v_sk.info_to_all.extend([3])
    temp = 0
    while temp < 104 and [line[7], line[8]] != v_icom_vars.dtcs_frequency[temp]:
        temp += 1
    v_sk.info_to_all.extend(bytearray([temp]))
    return 1


def answer1c03(line):
    # transmit frequency
    v_sk.info_to_all = bytearray([0x03, 0x03])
    v_sk.info_to_all.extend(frequency_for_answer(line[6:11], 30000, 4, 0))
    return 1


def answer1e01(line):
    #  TX band edge frequencies
    v_sk.info_to_all = v_sk.answer_token
    v_sk.info_to_all.extend([line[6]])
    if line[7] == 0xff:
        # empty
        v_sk.info_to_all.extend([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    else:
        temp1 = frequency_for_answer(line[7:12], 0, 4, 0)
        temp2 = 0
        while temp2 < 4:
            v_sk.info_to_all.extend(bytearray([temp1[temp2]]))
            temp2 += 1
        temp1 = frequency_for_answer(line[13:18], 0, 4, 0)
        temp2 = 0
        while temp2 < 4:
            v_sk.info_to_all.extend(bytearray([temp1[temp2]]))
            temp2 += 1
    return 1


def answer2100(line):
    # rit
    v_sk.info_to_all = v_sk.answer_token
    v_sk.info_to_all.extend(bcd_plusminus_to_int(line, 6, 9999, 2, 2, 1))
    return 1


def answer25(line):
    #  selected or unselected VFO frequency
    v_sk.info_to_all = v_sk.answer_token
    v_sk.info_to_all.extend(bytearray([line[5]]))
    v_sk.info_to_all.extend(frequency_for_answer(line[6:11], 30000, 4, 1))
    return 1


def answer26(line):
    # selected or unselected VFO’s operating mode and filter
    v_sk.info_to_all = v_sk.answer_token
    if line[6] > 5:
        line[6] -= 1
    if line[7] == 1:
        # data mode
        if line[6] < 5:
            line[6] += 8
        else:
            line[6] = 11
    line[8] -= 1
    v_sk.info_to_all.extend(line[5:7])
    v_sk.info_to_all.extend(bytearray([line[8]]))
    return 1


def answe2700(line):
    # answer of scope waveform output
    v_sk.info_to_all = bytearray([0x04, 0x52, len(line[6:-1])])
    v_sk.info_to_all.extend(line[6:-1])
    return 1


def answer2715(line):
    # Span setting in the Center mode Scope'
    v_sk.info_to_all = v_sk.answer_token
    span = line[8:10]
    value = 0
    if span == bytearray([0x25, 0x00]):
        value = 0
    elif span == bytearray([0x50, 0x00]):
        value = 1
    elif span == bytearray([0x00, 0x01]):
        value = 2
    elif span == bytearray([0x50, 0x02]):
        value = 3
    elif span == bytearray([0x00, 0x05]):
        value = 4
    elif span == bytearray([0x00, 0x10]):
        value = 5
    elif span == bytearray([0x00, 0x25]):
        value = 6
    elif span == bytearray([0x00, 0x50]):
        value = 7
    v_sk.info_to_all.extend(bytearray([value]))
    return 1


def answer2719(line):
    # Scope Reference level
    v_sk.info_to_all = v_sk.answer_token
    intvalue = bcd_to_int((line[7])) * 2
    if line[8] != 0:
        intvalue += 1
    if line[9] == 0:
        # positive
        intvalue += 40
    else:
        intvalue = 40 - intvalue
    v_sk.info_to_all.extend(intvalue.to_bytes(1, byteorder="big"))
    return 1

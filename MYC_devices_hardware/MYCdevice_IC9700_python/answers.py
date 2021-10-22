"""
name: answers.py IC9700
last edited: 20211020
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
    # used by poll_civ_input_buffer
    # check, if line (civ code) is valid
    # add token, if ok
    token = v_icom_vars.civ_code_to_token.get("".join('{:02x}'.format(x) for x in line))
    if token == None:
        return 2
    t = token.to_bytes(2, byteorder="big")
    v_sk.info_to_all = [t[0], t[1]]
    return 1


def frequency_for_answer(line, adder, par, actual_f):
    # line contain frequency only:
    # 5 bytes: 1 Hz resolution up to GHz
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
    if adder == 0:
        # 400M - 470M
        if frequency <= 146000000:
            # - 144M
            frequency -= 144000000
        else:
            if frequency <= 440000000:
                # + 2M - 430M
                frequency -= 428000000
            else:
                # + 2M + 10M - 1240M
                frequency -= 1228000000
    else:
        frequency -= adder
    if actual_f == 1:
        v_icom_vars.last_frequency = frequency
    temp1 = frequency.to_bytes(par, byteorder="big")
    return temp1


def frequency_for_answer_band_edge(line):
    # line contain frequency only:
    # 5 bytes: 1 Hz resolution up tp GHz
    # 3 bytes: 100Hz resolution: up to 99MHz
    # lsb first
    # convert to bytearray with par parameter bytes
    # necessary due to missmatch of bandedge and selectable frequencies
    temp1 = 0
    frequency = 0
    multiplier = 1
    while temp1 < len(line):
        temp2 = bcd_to_int(line[temp1])
        frequency = frequency + multiplier * temp2
        multiplier *= 100
        temp1 += 1
    # 400M - 470M
    if frequency <= 146000000:
        # - 144M
        frequency -= 144000000
    else:
        if frequency <= 440000000:
            # + 2M - 430M
            frequency -= 427999999
        else:
            # + 2M + 10M - 1200M
            frequency -= 1187999998
    temp1 = frequency.to_bytes(4, byteorder="big")
    return temp1


def answer_frequency_scope_edge(line):
    # line contain 4 bytes
    # convert 4 bcd bytes of frequency (lsb first) of line to integer frequency
    temp1 = 0
    frequency = 0
    multiplier = 1
    while temp1 < 4:
        temp2 = bcd_to_int(line[temp1])
        frequency += multiplier * temp2
        multiplier *= 100
        temp1 += 1
    frequency //= 10
    return frequency


def answer_x_1_b_x(line, adder, position):
    # used for all answers x CIV commandbytes, one byte bcd coded parameter at "position" with base "adder"
    v_sk.info_to_all.extend([bcd_to_int(line[position]) + adder])
    return 1


def answer_1_1_b(line):
    # used for all answers: 1 CIV  commandbyte, one byte bcd coded parameter with base 0
    return answer_x_1_b_x(line, 0, 5)


def answer_2_1_b(line):
    # used for all answers: 2 CIV commandbytes, one byte bcd coded parameter with base 0
    return answer_x_1_b_x(line, 0, 6)


def answer_2_1_b_last(line):
    # used for all answers: 2 CIV commandbytes, one byte bcd coded parameter with base 0
    v_sk.info_to_all = v_sk.last_token
    v_sk.info_to_all.extend([bcd_to_int(line[6])])
    return 1


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


def answer_2_2_b_2(line):
    # used for all answers: 2 commandbytes, two parameters (< 10) with base 0 to 2 MYC parameters
    v_sk.info_to_all.extend(line[6:8])
    return 1


def answer_2_2_b_2_1(line):
    # used for all answers: 2 commandbytes, two parameters (< 10) with base 0 to 2 MYC parameters; adder -1 to 2nd par
    line[7] -= 1
    v_sk.info_to_all.extend(line[6:8])
    return 1


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
    start = v_icom_vars.civ_command_length + 4
    v_sk.info_to_all.extend([0x00])
    stringcount = 0
    end = line.find(0xfd)
    while start < end:
        # -1 because of "fd"
        v_sk.info_to_all.extend(bytearray([line[start]]))
        stringcount += 1
        start += 1
    v_sk.info_to_all[2] = stringcount
    return 1


def answer_frequency(line):
    # frequency
    v_sk.info_to_all.extend(frequency_for_answer(line[5:10], 0, 4, 1))
    return 1


def answer_mode(line):
    # mode and filter
    if line[5] > 5:
        if line[5] == 0x17:
           line[5] = 8
        elif line[5] == 0x22:
            line[5] = 9
        else:
            line[5] -= 1
    v_sk.info_to_all.extend([line[5]])
    v_sk.info_to_all.extend([line[6] - 1])
    v_icom_vars.last_mode = line[5]
    return 1


def answer_bandedge(line):
    # band edge
    v_sk.info_to_all.extend(frequency_for_answer_band_edge(line[5:10]))
    v_sk.info_to_all.extend(frequency_for_answer_band_edge(line[11:16]))
    return 1


def answer_bandedge2(line):
    # band edge
    if line[7] == 0xff:
        v_sk.info_to_all.extend([0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00])
    else:
        v_sk.info_to_all.extend(frequency_for_answer_band_edge(line[7:12]))
        v_sk.info_to_all.extend(frequency_for_answer_band_edge(line[13:18]))
    return 1


def answer_subband(line):
    # sub band
    v_sk.info_to_all.extend(line[6:7])
    return 1

def answer_frequencyoffset(line):
    # frequency offset
    line = line[5:8]
    temp1 = 0
    frequency = 0
    multiplier = 1
    while temp1 < len(line):
        temp2 = bcd_to_int(line[temp1])
        frequency = frequency + multiplier * temp2
        multiplier *= 100
        temp1 += 1
    temp1 = frequency.to_bytes(3, byteorder="big")
    v_sk.info_to_all.extend(temp1)
    return 1

def answer_split_offset(line):
    # split / offset
    if line[5] < 2:
        a =line[5]
    else:
        a =line[5] - 14
    temp1 = a.to_bytes(1, byteorder="big")
    v_sk.info_to_all.extend(temp1)
    return 1


def answer_attenuator(line):
    # attenuator
    if line[5] == 0:
        v_sk.info_to_all.extend([0x00])
    else:
        v_sk.info_to_all.extend([0x01])
    return 1


def answer_sql(line):
    # SQL
    if line[6] > 5:
        line[6] -= 2
    v_sk.info_to_all.extend([line[6]])
    return 1


def answer_memory(line):
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
        # band
        band = line[6] - 1
        # chanal number (split included)
        chanal_number = (line[7] * 100 + line[8] - 1)
        if v_icom_vars.command_storage == 1:
            chanal_number *= 2
        # for others: band + chanal + split
        bcs = 214 * band + chanal_number + v_icom_vars.command_storage
        if v_sk.last_token == bytearray([0x01, 0x7f]):
            # memory select
            v_sk.info_to_all.extend((band * 99 + line[7]).to_bytes(2, byteorder="big"))
            v_sk.info_to_all.extend([line[9]])
        elif v_sk.last_token == bytearray([0x01, 0x81]):
            # frequency 144MHz
            v_sk.info_to_all.extend([chanal_number])
            v_sk.info_to_all.extend(frequency_for_answer(line[10 + v_icom_vars.command_storage * 49:15 + v_icom_vars.command_storage * 49], 144000000, 4, 0))
        elif v_sk.last_token == bytearray([0x01, 0x83]):
            # frequency 430MHz
            v_sk.info_to_all.extend([chanal_number])
            v_sk.info_to_all.extend(frequency_for_answer(line[10 + v_icom_vars.command_storage * 49:15 + v_icom_vars.command_storage * 49], 430000000, 4, 0))
        elif v_sk.last_token == bytearray([0x01, 0x85]):
            # frequency 1230MHz
            v_sk.info_to_all.extend([chanal_number])
            v_sk.info_to_all.extend(frequency_for_answer(line[10 + v_icom_vars.command_storage * 49:15 + v_icom_vars.command_storage * 49], 1230000000, 4, 0))
        else:
            v_sk.info_to_all.extend(bcs.to_bytes(2, byteorder="big"))
            if v_sk.last_token == bytearray([0x01, 0x87]):
                # mode
                mode = bcd_to_int((line[15 + v_icom_vars.command_storage * 49]))
                if mode > 5:
                    mode -= 1
                if mode == 0x17:
                    mode = 8
                if mode == 0x22:
                    mode = 9
                v_sk.info_to_all.extend(bytearray([mode, line[16 + v_icom_vars.command_storage * 49] - 1]))
            elif v_sk.last_token == bytearray([0x01, 0x89]):
                # data mode
                v_sk.info_to_all.extend(bytearray([line[17 + v_icom_vars.command_storage * 49]]))
            elif v_sk.last_token == bytearray([0x01, 0x8b]):
                # tone tqsl
                v_sk.info_to_all.extend(bytearray([(line[18 + v_icom_vars.command_storage * 49]) & 0x0f]))
            elif v_sk.last_token == bytearray([0x01, 0x8d]):
                # duplex
                v_sk.info_to_all.extend(bytearray([((line[18 + v_icom_vars.command_storage * 49]) & 0xf0) >> 4]))
            elif v_sk.last_token == bytearray([0x01, 0x8f]):
                # digital squelch
                v_sk.info_to_all.extend(bytearray([((line[19 + v_icom_vars.command_storage * 49]) & 0xf0) >> 4]))
            elif v_sk.last_token == bytearray([0x01, 0x91]):
                # tone frequency
                temp = 0
                tone1 = line[21 + v_icom_vars.command_storage * 49]
                tone2 = line[22 + v_icom_vars.command_storage * 49]
                while temp < 50 and ([tone1, tone2] != v_icom_vars.tone_frequency[temp]):
                    temp += 1
                v_sk.info_to_all.extend(bytearray([temp]))
            elif v_sk.last_token == bytearray([0x01, 0x93]):
                # tone squelch
                temp = 0
                tone1 = line[24 + v_icom_vars.command_storage * 49]
                tone2 = line[25 + v_icom_vars.command_storage * 49]
                while temp < 50 and ([tone1, tone2] != v_icom_vars.tone_frequency[temp]):
                    temp += 1
                v_sk.info_to_all.extend(bytearray([temp]))
            elif v_sk.last_token == bytearray([0x01, 0x95]):
                # DTCS
                temp = 0
                tone1 = line[27 + v_icom_vars.command_storage * 49]
                tone2 = line[28 + v_icom_vars.command_storage * 49]
                while temp < 104 and ([tone1, tone2] != v_icom_vars.dtcs_frequency[temp]):
                    temp += 1
                v_sk.info_to_all.extend(bytearray([temp]))
            elif v_sk.last_token == bytearray([0x01, 0x97]):
                # DTCS polarity
                temp = line[26 + v_icom_vars.command_storage * 49]
                if line[26 + v_icom_vars.command_storage * 49] == 0x10:
                    temp = 2
                if line[26 + v_icom_vars.command_storage * 49] == 0x11:
                    temp = 3
                v_sk.info_to_all.extend(bytearray([temp]))
            elif v_sk.last_token == bytearray([0x01, 0x99]):
                # DV code squelch
                v_sk.info_to_all.extend(bytearray([bcd_to_int( line[29 + v_icom_vars.command_storage * 49])]))
            elif v_sk.last_token == bytearray([0x01, 0x9B]):
                # duplex offset frequency
                line = line[30 + v_icom_vars.command_storage * 49:33 + v_icom_vars.command_storage * 49]
                temp1 = 0
                frequency = 0
                multiplier = 1
                while temp1 < len(line):
                    temp2 = bcd_to_int(line[temp1])
                    frequency = frequency + multiplier * temp2
                    multiplier *= 100
                    temp1 += 1
                temp1 = frequency.to_bytes(3, byteorder="big")
                v_sk.info_to_all.extend(temp1)
            elif v_sk.last_token == bytearray([0x01, 0x9D]):
                # UR
                v_sk.info_to_all.extend(line[33 + v_icom_vars.command_storage * 49:41 + v_icom_vars.command_storage * 49])
            elif v_sk.last_token == bytearray([0x01, 0x9F]):
                # R1
                v_sk.info_to_all.extend(line[41 + v_icom_vars.command_storage * 49:49 + v_icom_vars.command_storage * 49])
            elif v_sk.last_token == bytearray([0x01, 0xA1]):
                # R2
                v_sk.info_to_all.extend(line[49 + v_icom_vars.command_storage * 49:57 + v_icom_vars.command_storage * 49])
            elif v_sk.last_token == bytearray([0x01, 0xA3]):
                # memory name
                v_sk.info_to_all.extend([10])
                v_sk.info_to_all.extend(line[57:67])
        v_icom_vars.ask_content = 0
    return 1


def answer_bandstack(line):
    # band stack
    if v_icom_vars.ask_content == 0:
        v_sk.info_to_all.extend([(line[6] -1) * 3 + line[7] -1])
        v_sk.info_to_all.extend([len(line) - 8])
        v_sk.info_to_all.extend(line[8: len(line) - 1])
    elif v_icom_vars.ask_content == 1:
        # store data for following command
        v_icom_vars.answer_storage = line[6:]
        v_icom_vars.ask_content = 2
    return 1


def answer_keyer_memory(line):
    # keyer memory
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


def answer_hpf_lpf(line):
    # used for all hpf_lpf_answers
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[8])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[9]) - 5]))
    return 1


def answer_tonecontrol(line):
    # tone control
    v_sk.info_to_all.extend([(line[8] & 0xf0) >> 4])
    v_sk.info_to_all.extend([line[8] & 0x0f])
    return 1


def answer_beepsound(line):
    # beep sound
    v_sk.info_to_all.extend([(line[8]* 100 + bcd_to_int(line[9])) - 50])
    return 1


def answer_split_offset1(line):
    # split offset
    v_sk.info_to_all.extend(bcd_plusminus_to_int(line, 8, 9999, 3, 2, 10))
    return 1


def answer_network_adrdress(line):
    # network address
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[8:10])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[10:12])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[12:14])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[14:16])]))
    return 1


def answer_port_number(line):
    # port number
    t, u = int_to_2_ele(bcdx_to_int(line[8:11],3) - 1)
    v_sk.info_to_all.extend([t])
    v_sk.info_to_all.extend([u])
    return 1


def answer_date(line):
    # date
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[8:10]) - 2020]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[10] - 1)]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[11] - 1)]))
    return 1


def answer_time(line):
    # time
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[8])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[9])]))
    return 1


def answer_utc(line):
    # utc
    minutes = bcd_to_int(line[8]) * 60 + bcd_to_int(line[9])
    if line[10] == 0:
        # plus
        minutes += 840
    else:
        minutes = 840 - minutes
    v_sk.info_to_all.extend(minutes.to_bytes(2, byteorder="big"))
    return 1


def answer_color(line):
    # color
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[8:10])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[10:12])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[12:14])]))
    return 1


def answer_scope_bandedge(line):
    # scope band edge
    v_sk.info_to_all.extend([v_icom_vars.command_storage])
    tokennumber = v_sk.last_token[0] * 256 + v_sk.last_token[1]
    min_ = v_icom_vars.number_frequency_range[v_icom_vars.tokennumber_frequency_range_number[tokennumber]][0]
    flow = answer_frequency_scope_edge(line[8:12]) - min_
    temp1 = flow.to_bytes(2, byteorder="big")
    v_sk.info_to_all.extend(temp1)
    span = (answer_frequency_scope_edge(line[12:16]) - min_ - flow - 5)
    temp1 = span.to_bytes(2, byteorder="big")
    v_sk.info_to_all.extend(temp1)
    return 1


def answer_gps_position(line):
    answer_gps_position_(line)
    return 1


def answer_gps_position2(line):
    # other command length (-2 byte)
    l = bytearray([0, 0,])
    l.extend(line)
    answer_gps_position_(l)
    return 1

def answer_gps_position_(line):
    # gps position
    # lat
    if line[6] == 0xff:
        v_sk.info_to_all.extend([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[8]), 1, byteorder="big"))
    v_sk.info_to_all.extend(int.to_bytes(bcdx_to_int(line[9:11], 2), 2, byteorder="big"))
    # N / S
    v_sk.info_to_all.extend([line[12]])
    # long
    v_sk.info_to_all.extend(int.to_bytes(bcd2_to_int(line[13:15]), 1, byteorder="big"))
    v_sk.info_to_all.extend(int.to_bytes(bcdx_to_int(line[15:18], 2), 2, byteorder="big"))
    # W / E
    v_sk.info_to_all.extend([line[18]])
    if line[19:22] == bytearray([0xff, 0xff, 0xff]):
         v_sk.info_to_all.extend([0x00,0x00])
    else:
        hight = bcdx_to_int(line[19:22], 3)
        hight //= 10
        v_sk.info_to_all.extend(int.to_bytes(hight, 2, byteorder="big"))
    v_sk.info_to_all.extend([line[22]])
    return 1


def answer_gps_symbol(line):
    # gps symbol
    v_sk.info_to_all.extend([1])
    v_sk.info_to_all.extend([line[8]])
    v_sk.info_to_all.extend([1])
    v_sk.info_to_all.extend([line[9]])
    return 1


def answer_alarm_group(line):
    # alarm group
    a = bcd_to_int(line[8]) * 100 + bcd_to_int(line[9]) - 8
    v_sk.info_to_all.extend(int.to_bytes(a, 2, byteorder="big"))
    return 1


def answer_data_mode_wth_filter(line):
    # Data mode with filter
    temp1 = 0
    if line[6] == 1:
        temp1 = line[7]
    v_sk.info_to_all.extend(bytearray([temp1]))
    return 1


def answer_repeater_tone_sql(line):
    # tone frequncy
    temp = 0
    while temp < 51 and [line[7], line[8]] != v_icom_vars.tone_frequency[temp]:
        temp += 1
    v_sk.info_to_all.extend(bytearray([temp]))
    return 1


def answer_dcts(line):
    # DTCS code
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


def answer_transmit_f(line):
    # transmit frequency
    v_sk.info_to_all = bytearray([0x04, 0xc3])
    v_sk.info_to_all.extend(frequency_for_answer(line[6:11], 0, 4, 0))
    return 1


def answeruser_bandedge(line):
    #  TX band edge frequencies
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


def answer_rit(line):
    # rit
    v_sk.info_to_all.extend(bcd_plusminus_to_int(line, 6, 9999, 2, 2, 1))
    return 1


def answer_gps_select(line):
    # gps select
    if line[6] == 0:
        v_sk.info_to_all.extend([line[6]])
    else:
        v_sk.info_to_all.extend([line[6] - 1])
    return 1


def answer_main_f(line):
    #  selected or unselected VFO frequency
    v_sk.info_to_all.extend(bytearray([line[5]]))
    v_sk.info_to_all.extend(frequency_for_answer(line[6:11], 0, 4, 1))
    return 1


def answer_main_mode(line):
    # selected or unselected VFO’s operating mode and filter
    if line[6] == 23:
        line[6] = 8
    elif line[6] == 34:
        lin[6] = 9
    else:
        if line[6] > 5:
            line[6] -= 1
    if line[7] == 0:
        # non data mode
        line[8] = 0
    else:
        line[8] -= 1
    v_sk.info_to_all.extend(line[6:9])
    return 1


def answer_scope(line):
    # answer of scope waveform output
    v_sk.info_to_all = bytearray([0x04, 0x52, len(line[6:-1])])
    v_sk.info_to_all.extend(line[6:-1])
    return 1


def answer_scope_span(line):
    # Span setting in the Center mode Scope'
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


def answer_scope_reference(line):
    # Scope reference level
    intvalue = bcd_to_int2((line[7:9]))
    intvalue //= 50
    if intvalue == 0:
        intvalue= 40
    else:
        if line[9] == 0:
            # positive
            intvalue += 40
        else:
            intvalue = 40 - intvalue
    v_sk.info_to_all.extend([line[6]])
    v_sk.info_to_all.extend(intvalue.to_bytes(1, byteorder="big"))
    return 1


def answer_scope_fixed_edges(line):
    if line[6] == 1:
        v_sk.info_to_all[1] = 0xcd
    elif line[6] == 2:
        v_sk.info_to_all[1] = 0xcf
    elif line[6] == 3:
        v_sk.info_to_all[1] = 0xd0
    v_sk.info_to_all.extend([line[7] - 1])
    f1 = ba_to_int(frequency_for_answer(line[8:13], 0, 3, 0)) // 1000
    v_sk.info_to_all.extend(f1.to_bytes(2, byteorder="big"))
    f2 = ba_to_int(frequency_for_answer(line[13:18], 0, 3, 0)) // 1000
    diff = f2 - f1 - 5
    v_sk.info_to_all.extend(diff.to_bytes(2, byteorder="big"))
    return 1

def answer_gps_status(line):
    # gps status (my Position)
    # lat
    if line[6] == 0xff:
        v_sk.info_to_all.extend([0, 0, 0, 0, 0, 0, 0, 0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0, 0, 0])
    else:
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[6]), 1, byteorder="big"))
        v_sk.info_to_all.extend(int.to_bytes(bcdx_to_int(line[7:9], 2), 2, byteorder="big"))
        # N / S
        v_sk.info_to_all.extend([line[10]])
        # long
        v_sk.info_to_all.extend(int.to_bytes(bcd2_to_int(line[11:13]), 1, byteorder="big"))
        v_sk.info_to_all.extend(int.to_bytes(bcdx_to_int(line[13:15], 2), 2, byteorder="big"))
        # W / E
        v_sk.info_to_all.extend([line[16]])
        # hight 0- 10000
        if line[17:20] == bytearray([0xff, 0xff,0xff]):
             v_sk.info_to_all.extend([0x00,0x00])
        else:
            hight = bcdx_to_int(line[17:20], 3)
            hight //= 10
            v_sk.info_to_all.extend(int.to_bytes(hight, 3, byteorder="big"))
        # course 0 - 3600
        if line[21:23] == bytearray([0xff, 0xff]):
             v_sk.info_to_all.extend([0x00,0x00])
        else:
            course = bcdx_to_int(line[21:23], 2)
            v_sk.info_to_all.extend(int.to_bytes(course, 2, byteorder="big"))
        # speed
        if line[23:26] == bytearray([0xff, 0xff, 0xff]):
            v_sk.info_to_all.extend([0x00, 0x00])
        else:
            speed = bcdx_to_int(line[23:26], 3)
            v_sk.info_to_all.extend(int.to_bytes(speed, 2, byteorder="big"))
        # date
        if line[26:33] == bytearray([0xff, 0xff, 0xff, 0xff, 0xff, 0xff,0xff]):
            v_sk.info_to_all.extend([0x00, 0x00, 0x00, 0x00,0x00, 0x00, 0x00])
        else:
            v_sk.info_to_all.extend(int.to_bytes(bcdx_to_int(line[26:28], 2), 2, byteorder="big"))
            v_sk.info_to_all.extend(int.to_bytes(bcdx_to_int(line[28:29], 1) - 1, 1, byteorder="big"))
            v_sk.info_to_all.extend(int.to_bytes(bcdx_to_int(line[29:30], 1) - 1, 1, byteorder="big"))
            v_sk.info_to_all.extend(int.to_bytes(bcdx_to_int(line[30:31], 1), 1, byteorder="big"))
            v_sk.info_to_all.extend(int.to_bytes(bcdx_to_int(line[31:32], 1), 1, byteorder="big"))
            v_sk.info_to_all.extend(int.to_bytes(bcdx_to_int(line[32:33], 1), 1, byteorder="big"))
    return 1

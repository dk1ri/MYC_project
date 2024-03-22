"""
name: answers.py IC705
last edited: 20240311
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)
handling of answers from the radio
output to v_sk_info_to_all
"""

import time

from misc_functions import *
from commands import *

import v_sk
import v_icom_vars
import v_fix_tables


def answer_nop(line):
    return 1


def find_token(line):
    # used by poll_civ_input_buffer
    # check, if line (civ code) is valid
    # add token, if ok
    token = v_icom_vars.civ_code_to_token.get("".join('{:02x}'.format(x) for x in line))
    if token is None:
        return 2
    t = token.to_bytes(2, byteorder="big")
    v_sk.info_to_all = [t[0], t[1]]
    return 1


def frequency_for_answer(line, adder, par, actual_f):
    # line contain frequency only:
    # 5 bytes: 1 Hz resolution up to GHz
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


def answer_frequency_fixed_edge(line):
    # line contain 4 bytes
    # convert 4 bcd bytes of line of frequency lsb first
    # convert to bytearray
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


def answer_x_1_b_x(line, adder, position_):
    # used for all answers x CIV commandbytes, one byte bcd coded parameter at "position" with base "adder"
    v_sk.info_to_all.extend([bcd_to_int(line[position_]) + adder])
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


def answer_x_2_b_x(line, position_, adder, myc):
    # used for all answers: x  CIV commandbytes, two byte bcd coded parameter with base "adder"
    # to myc byte MYC parameter
    if myc == 1:
        v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[position_:2 + position_]) + adder]))
    else:
        v_sk.info_to_all.extend(bcd_to_ba_2(line[position_:2 + position_], adder))
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


def answer_commentn(line):
    if line[7] == 0x97:
        v_sk.info_to_all.extend([0])
    elif line[7] == 0x98:
        v_sk.info_to_all.extend([1])
    elif line[7] == 0x99:
        v_sk.info_to_all.extend([2])
    elif line[7] == 0x00:
        v_sk.info_to_all.extend([3])
    start = 8
    v_sk.info_to_all.extend([0])
    stringcount = 0
    end = line.find(0xfd)
    while start < end:
        # -1 because of "fd"
        v_sk.info_to_all.extend(bytearray([line[start]]))
        stringcount += 1
        start += 1
    v_sk.info_to_all[3] = stringcount
    return 1


def answer_string(line):
    # aswers with one string
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


def answer_frequency(line):
    # frequency
    v_sk.info_to_all = bytearray([0x01, 0x01])
    v_sk.info_to_all.extend(frequency_for_answer(line[5:10], 30000, 4, 1))
    return 1


def answer_mode(line):
    # mode and filter
    if line[5] == 0x17:
        line[5] = 0x09
    v_sk.info_to_all.extend([line[5]])
    v_sk.info_to_all.extend([line[6] - 1])
    return 1


def answer_bandedge(line):
    # scope edge
    v_sk.info_to_all = bytearray([0x01, 0x4])
    v_sk.info_to_all.extend(frequency_for_answer(line[5:10], 30000, 4, 0))
    v_sk.info_to_all.extend(frequency_for_answer(line[11:16], 30000, 4, 0))
    return 1


def answer_frequency_offset(line):
    # frequency offset
    v_sk.info_to_all = bytearray([0x01, 0x0b])
    v_sk.info_to_all.extend(frequency_for_answer(line[5:8], 0, 3, 0))
    return 1


def answer_split_offset(line):
    # split
    v_sk.info_to_all = bytearray([0x01, 0x13])
    if line[5] < 2:
        v_sk.info_to_all.extend([line[5]])
    else:
        v_sk.info_to_all.extend([line[5] - 14])
    return 1


def answer_sql(line):
    # tone squelch
    if line[6] < 4:
        v_sk.info_to_all.extend([line[6]])
    else:
        v_sk.info_to_all.extend([line[6] - 2])
    return 1


def answer_cw_message(line):
    # cw message
    if line[5] == 0:
        v_sk.info_to_all.extend([0x00])
    else:
        v_sk.info_to_all.extend([0x01])
    return 1

def answer_id(line):
    v_sk.info_to_all.extend([line[6]])
    return 1

def answer_memory(line):
    # memory
    if v_icom_vars.ask_content == 4 or v_icom_vars.ask_content == 99:
        # analyze data, command was answercommand
        if line[10] == 0xff:
            # no valid memory
            return 2
        v_sk.info_to_all = v_sk.last_token[:]
        group = bcd2_to_int(line[6:8])
        if line[6:8] == [0x01, 0x00]:
            # chanal group
            # 20000 - - 20006
            if v_icom_vars.vfo_split == 0:
                group_memory = (20000 + bcd2_to_int(line[8:10]))
            else:
                group_memory = (20003 + bcd2_to_int(line[8:10]))
        else:
            # memory group 0 - 20003
            if v_icom_vars.vfo_split == 0:
                group_memory = 100 * group + bcd2_to_int(line[8:10])
            else:
                group_memory = (100 * group + bcd2_to_int(line[8:10])) + 10000
        v_sk.info_to_all.extend(int_to_list(group_memory, 2))
        read_token = v_sk.last_token[0] * 256 + v_sk.last_token[1]
        if read_token == 1194:
            # special
            # tone
            if line[10] == 0xff:
                v_sk.info_to_all.extend(bytearray([0x0]))
            else:
                tone = line[v_icom_vars.command_storage + 19] & 0x0f
                v_sk.info_to_all.extend(bytearray([tone]))
        else:
            read_token -= v_icom_vars.start_token_for_memory_read
            if read_token == 0:
                # raw data
                v_sk.info_to_all.extend(int_to_list(len(line) - 10, 1))
                v_sk.info_to_all.extend(line[8:-1])
            elif read_token == 2:
                # frequency
                pointer = 11 + v_icom_vars.vfo_split * 47
                v_sk.info_to_all.extend(frequency_for_answer(line[pointer:pointer + 5], 30000, 4, 0))
            elif read_token == 4:
                # split select
                pointer = 11 + v_icom_vars.vfo_split * 47
                v_sk.info_to_all.extend([(line[pointer] & 0xf0) >> 4])
                v_sk.info_to_all.extend([line[pointer] & 0x0f])
            elif read_token == 6:
                # mode
                pointer = 16 + v_icom_vars.vfo_split * 47
                mode = bcd_to_int((line[pointer]))
                if mode > 8:
                    mode = 9
                filter_ = (line[pointer + 1]) - 1
                v_sk.info_to_all.extend(bytearray([mode, filter_]))
            elif read_token == 8:
                # data mode
                pointer = 18 + v_icom_vars.vfo_split * 47
                data_mode = bcd_to_int((line[pointer]))
                v_sk.info_to_all.extend(bytearray([data_mode]))
            elif read_token == 10:
                # duplex, tone
                pointer = 19 + v_icom_vars.vfo_split * 47
                duplex = (line[pointer] & 0xf0) >> 4
                tone = line[pointer] & 0x0f
                v_sk.info_to_all.extend(bytearray([duplex, tone]))
            elif read_token == 12:
                # digital squelch
                pointer = 20 + v_icom_vars.vfo_split * 47
                squelch = bcd_to_int(line[pointer])
                if squelch == 10:
                    squelch = 1
                v_sk.info_to_all.extend(bytearray([squelch]))
            elif read_token == 14:
                # tone frequency
                pointer = 22 + v_icom_vars.vfo_split * 47
                temp = 0
                tone1 = line[pointer]
                tone2 = line[pointer + 1]
                while temp < 50 and ([tone1, tone2] != v_fix_tables.tone_frequency[temp]):
                    temp += 1
                v_sk.info_to_all.extend(bytearray([temp]))
            elif read_token == 16:
                # tone squelch frequency
                pointer = 25 + v_icom_vars.vfo_split * 47
                temp = 0
                tone1 = line[pointer]
                tone2 = line[pointer + 1]
                while temp < 50 and ([tone1, tone2] != v_fix_tables.tone_frequency[temp]):
                    temp += 1
                v_sk.info_to_all.extend(bytearray([temp]))
            elif read_token == 18:
                # DTCS frequency
                pointer = 27 + v_icom_vars.vfo_split * 47
                temp = 0
                pm = line[pointer]
                if pm == 0x00:
                    pm = 0
                elif pm == 0x01:
                    pm = 1
                elif pm == 0x10:
                    pm = 2
                elif pm == 0x11:
                    pm = 3
                tone1 = line[pointer + 1]
                tone2 = line[pointer + 2]
                while temp < 104 and ([tone1, tone2] != v_fix_tables.dtcs_frequency[temp]):
                    temp += 1
                v_sk.info_to_all.extend(bytearray([pm, temp]))
            elif read_token == 20:
                # DV digital code
                pointer = 30 + v_icom_vars.vfo_split * 47
                code = bcd_to_int(line[pointer])
                v_sk.info_to_all.extend([code])
            elif read_token == 22:
                # duplex offset frequency
                pointer = 31 + v_icom_vars.vfo_split * 47
                v_sk.info_to_all.extend(frequency_for_answer(line[pointer:pointer + 3], 0, 3, 0))
            elif read_token == 24:
                # UR destination callsign
                pointer = 34 + v_icom_vars.vfo_split * 47
                v_sk.info_to_all.extend([8])
                v_sk.info_to_all.extend(line[pointer:pointer + 8])
            elif read_token == 26:
                # R1 access repeater callsign
                pointer = 42 + v_icom_vars.vfo_split * 47
                v_sk.info_to_all.extend([8])
                v_sk.info_to_all.extend(line[pointer:pointer + 8])
            elif read_token == 28:
                # R2 Gateway callsign
                pointer = 50 + v_icom_vars.vfo_split * 47
                v_sk.info_to_all.extend([8])
                v_sk.info_to_all.extend(line[pointer:pointer + 8])
            elif read_token == 30:
                # memory name
                v_sk.info_to_all.extend([16])
                v_sk.info_to_all.extend(line[105:121])
            v_icom_vars.ask_content = 0
    else:
        # store data for following operating command
        if v_icom_vars.ask_content == 1:
            if len(line) > 12:
                v_icom_vars.answer_storage = line[6:]
                v_icom_vars.ask_content = 2
                v_sk.info_to_all = bytearray([])
            else:
                # memory empty
                return 2
        else:
            return 0
    return 1


def answer_bandstack(line):
    # band stack
    if v_icom_vars.ask_content == 0:
        v_sk.info_to_all.extend([(line[7] - 1) + (line[6] - 1)])
        v_sk.info_to_all.extend([len(line) - 8])
        v_sk.info_to_all.extend(line[8: len(line) - 1])
    elif v_icom_vars.ask_content == 1:
        # store data for following command
        v_icom_vars.answer_storage = line[8:]
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


def filter_bandwidth(line):
    # filter_bandwidth
    v_sk.info_to_all = v_sk.last_token[:]
    v_sk.info_to_all.extend(bytearray([line[6]]))
    return 1


def time_constant(line):
    # time constant
    v_sk.info_to_all = v_sk.last_token[:]
    v_sk.info_to_all.extend(bytearray([line[6]]))
    return 1

def answer_attenuator(line):
    # attenuator
    v_sk.info_to_all = bytearray([0x01, 0x17])
    if line[5] == 0:
        v_sk.info_to_all.extend([0x00])
    else:
        v_sk.info_to_all.extend([0x01])
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


def answer_split_offset1(line):
    # split offset
    v_sk.info_to_all.extend(bcd_plusminus_to_int(line, 8, 9999, 3, 2, 10))
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
    civ_cmd = bcd_to_int(line[6]) * 100 + bcd_to_int(line[7])
    if civ_cmd < 239:
        v_sk.info_to_all.extend([(civ_cmd - 188) % 3])
    else:
        v_sk.info_to_all.extend([4])
    tokennumber = v_sk.last_token[0] * 256 + v_sk.last_token[1]
    min_ = v_icom_vars.number_frequency_range[v_icom_vars.tokennumber_frequency_range_number[tokennumber]][0]
    # min frequency
    min_f = answer_frequency_fixed_edge(line[8:12])
    # span
    span = answer_frequency_fixed_edge(line[12:16])
    span -= min_f
    min_f -= min_
    if tokennumber != 817:
        v_sk.info_to_all.extend(min_f.to_bytes(2, byteorder="big"))
    else:
        # for 430MHz band
        v_sk.info_to_all.extend(min_f.to_bytes(3, byteorder="big"))
    v_sk.info_to_all.extend(span.to_bytes(2, byteorder="big"))
    return 1


def answer_gps_position(line):
    # gps position
    if line[6] == 0xff:
        v_sk.info_to_all.extend([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    else:
        # lat
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[6]), 1, byteorder="big"))
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[7]), 1, byteorder="big"))
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[8]), 1, byteorder="big"))
        # N/S
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[10]), 1, byteorder="big"))
        # long
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[11] * 10 + bcd_to_int(line[12])), 1, byteorder="big"))
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[13]), 1, byteorder="big"))
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[14]), 1, byteorder="big"))
        # W / E
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[16]),1, byteorder="big"))
        if line[18:20] == bytearray([0xff, 0xff, 0xff]):
            v_sk.info_to_all.extend([0x00, 0x00])
        else:
            hight = bcdx_to_int(line[17:20], 2)
            if line[20] == 0:
                hight *= 10000
            else:
                hight = 10000 - hight
            v_sk.info_to_all.extend(int.to_bytes(hight, 2, byteorder="big"))
        v_sk.info_to_all.extend([line[20]])
    return 1


def answer_gps_symbol(line):
    v_sk.info_to_all.extend([bcd_to_int(line[7]) - 91])
    i = 0
    found = 0
    while i < 74 or found == 0:
        if [line[8] , line[9]] == v_icom_vars.gps_sympbol_translate[i]:
            v_sk.info_to_all.extend([i])
            found =1
        i += 1
    return 1


def answer_gps_symboln1(line):
    i = 0
    found = 0
    while i < 74 or found == 0:
        if [line[8] , line[9]] == v_icom_vars.gps_sympbol_translate[i]:
            v_sk.info_to_all.extend([i])
            found =1
        i += 1
    return 1



def answer_alarm_group(line):
    # alarm group
    v_sk.info_to_all.extend([bcd_to_int(int(line[8]))])
    v_sk.info_to_all.extend([bcd_to_int(int(line[9]))])
    return 1


def answer_data_mode_wth_filter(line):
    # Data mode with filter
    v_sk.info_to_all.extend(bytearray([line[6], line[7]]))
    return 1


def answer_repeater_tone_sql(line):
    # tone frequncy
    temp = 0
    while temp < 51 and [line[7], line[8]] != v_fix_tables.tone_frequency[temp]:
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
    while temp < 104 and [line[7], line[8]] != v_fix_tables.dtcs_frequency[temp]:
        temp += 1
    v_sk.info_to_all.extend(bytearray([temp]))
    return 1


def answer_transmit_f(line):
    # transmit frequency
    v_sk.info_to_all = bytearray([0x04, 0x42])
    v_sk.info_to_all.extend(frequency_for_answer(line[6:11], 30000, 4, 1))
    return 1


def answer_user_bandedge(line):
    #  Tanswer_user_bandedgeX band edge frequencies
    v_sk.info_to_all.extend([bcd_to_int(line[6] -1)])
    if line[7] == 0xff:
        # empty
        v_sk.info_to_all.extend([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    else:
        temp1 = frequency_for_answer(line[7:12], 30000, 4, 1)
        temp2 = 0
        while temp2 < 4:
            v_sk.info_to_all.extend(bytearray([temp1[temp2]]))
            temp2 += 1
        temp1 = frequency_for_answer(line[13:18], 30000, 4, 1)
        temp2 = 0
        while temp2 < 4:
            v_sk.info_to_all.extend(bytearray([temp1[temp2]]))
            temp2 += 1
    return 1

def dv_tx_call(line):
    head = v_sk.info_to_all
    v_sk.info_to_all = [head[0], head[1]]
    #UR
    v_sk.info_to_all.extend([0,8])
    v_sk.info_to_all.extend(bytes(line[6:14]))
    # R1
    v_sk.info_to_all.extend([head[0],head[1],1, 8])
    v_sk.info_to_all.extend(bytes(line[14:22]))
    # R2
    v_sk.info_to_all.extend([head[0],head[1],2, 8])
    v_sk.info_to_all.extend(bytes(line[22:30]))
    return 1

def answer_dv_rx_call_sign(line):
    # DV RX call sign for transceive
    if len(line) < 46:
        v_sk.info_to_all.extend([v_sk.last_token[0], v_sk.last_token[1], 0, 0, 0, 0, 0])
    else:
        v_sk.info_to_all.extend(line[7:9] + bytes([8]) + line[9:17] + bytes([4]) + line[17:21] + bytes([8]) + line[21:29])
        v_sk.info_to_all.extend(bytes([8]) + line[29:37] + bytes([8]) + line[37:45])
    return 1


def answer_dv_rx_message(line):
    # DV RX message for transceive
    if line[7] == 0xff:
        v_sk.info_to_all.extend([0, 0, 0])
    else:
        v_sk.info_to_all.extend([0x14, line[7:27], 8, line[27:31], 8, line[31:39]])
    return 1


def dv_rx_status(line):
    head = v_sk.info_to_all
    i = 0
    mask = 1
    while i < 8:
        bit = line[8]&mask
        v_sk.info_to_all.extend([head,bit])
        mask *= 2
        i += 1

def dpsrs_postion(line):
    # DV RX D-PRS postion for transceive
    if line[8] == 0xff:
        v_sk.info_to_all.extend([line[2], 0])
    else:
        match v_icom_vars.command_storage:
            case 0:
                v_sk.info_to_all.extend([line[8]])
            case 1:
                v_sk.info_to_all.extend([line[9:18]])
            case 2:
                v_sk.info_to_all.extend([line[18:20]])
            case 3:
                # lat
                v_sk.info_to_all.extend([line[20], "d", line[21], ".", line[22:25]])
            case 4:
                # long
                v_sk.info_to_all.extend([line[25:27], "d", line[27], ".", line[28:31]])
            case 5:
                # alt
                if line[34] == 0:
                    v_sk.info_to_all.extend(["+"])
                else:
                    v_sk.info_to_all.extend(["+"])
                v_sk.info_to_all.extend([line[31:34]])
            case 6:
                # course
                v_sk.info_to_all.extend([line[35:37]])
            case 7:
                # speed
                v_sk.info_to_all.extend([line[37:40]])
            case 8:
                # date
                v_sk.info_to_all.extend(
                    [line[40:42], ":", line[42], ";", line[43], ":", line[44], ";", line[45], ":", line[46]])
            case 9:
                # power
                v_sk.info_to_all.extend([translate_power(line[47])])
            case 10:
                # hight
                v_sk.info_to_all.extend([translate_hight(line[48])])
            case 11:
                # gain
                v_sk.info_to_all.extend([line[49]])
            case 12:
                # dir
                v_sk.info_to_all.extend([translate_dir(bytes(line[50]))])
        data_length = len(line) - 4
        v_sk.info_to_all.extend(bytes([data_length]) + line[7:data_length - 1])
    return 1


def dprs_object_status(line):
    # DV RX D-PRS dprs_object_status for transceive
    v_sk.info_to_all.extend(bytes([v_icom_vars.command_storage]))
    if line[8] == 0xff:
        v_sk.info_to_all.extend([line[2], 0])
    else:
        match v_icom_vars.command_storage:
            case 0:
                v_sk.info_to_all.extend([line[8]])
            case 1:
                v_sk.info_to_all.extend([line[9:18]])
            case 2:
                v_sk.info_to_all.extend([line[18:20]])
            case 3:
                # lat
                v_sk.info_to_all.extend([line[20], "d", line[21], ".", line[22:25]])
            case 4:
                # long
                v_sk.info_to_all.extend([line[25:27], "d", line[27], ".", line[28:31]])
            case 5:
                # alt
                if line[34] == 0:
                    v_sk.info_to_all.extend(["+"])
                else:
                    v_sk.info_to_all.extend(["+"])
                v_sk.info_to_all.extend([line[31:34]])
            case 6:
                # course
                v_sk.info_to_all.extend([line[35:37]])
            case 7:
                # speed
                v_sk.info_to_all.extend([line[37:40]])
            case 8:
                #date
                v_sk.info_to_all.extend(
                    [line[40:42], ":", line[42], ";", line[43], ":", line[44], ";", line[45], ":", line[46]])
            case 9:
                # power
                v_sk.info_to_all.extend([translate_power(line[47])])
            case 10:
                # hight
                v_sk.info_to_all.extend([translate_hight(line[48])])
            case 11:
                # gain
                v_sk.info_to_all.extend([line[49]])
            case 12:
                # dir
                v_sk.info_to_all.extend([translate_dir(bytes(line[50]))])
            case 13:
                # name
                v_sk.info_to_all.extend(line[44:53])
            case 14:
                # type
                v_sk.info_to_all.extend(line[53])
        data_length = len(line) - 4
        v_sk.info_to_all.extend(bytes([data_length]) + line[7:data_length - 1])
    return 1


def dprs_item_status(line):
    # DV RX D-PRS dprs_item_status
    v_sk.info_to_all.extend(bytes([v_icom_vars.command_storage]))
    if line[8] == 0xff:
        v_sk.info_to_all.extend([line[2], 0])
    else:
        match v_icom_vars.command_storage:
            case 0:
                v_sk.info_to_all.extend([line[8]])
            case 1:
                v_sk.info_to_all.extend([line[9:18]])
            case 2:
                v_sk.info_to_all.extend([line[18:20]])
            case 3:
                # lat
                v_sk.info_to_all.extend([line[20], "d", line[21], ".", line[22:25]])
            case 4:
                # long
                v_sk.info_to_all.extend([line[25:27], "d", line[27], ".", line[28:31]])
            case 5:
                # alt
                if line[34] == 0:
                    v_sk.info_to_all.extend(["+"])
                else:
                    v_sk.info_to_all.extend(["+"])
                v_sk.info_to_all.extend([line[31:34]])
            case 6:
                # course
                v_sk.info_to_all.extend([line[35:37]])
            case 7:
                # speed
                v_sk.info_to_all.extend([line[37:40]])
            case 8:
                # power
                v_sk.info_to_all.extend([translate_power(line[41])])
            case 9:
                # hight
                v_sk.info_to_all.extend([translate_hight(line[42])])
            case 10:
                # gain
                v_sk.info_to_all.extend([line[43]])
            case 11:
                # dir
                v_sk.info_to_all.extend([translate_dir(bytes(line[44]))])
            case 12:
                # name
                v_sk.info_to_all.extend(line[44:53])
            case 13:
                # type
                v_sk.info_to_all.extend(line[53])
        data_length = len(line) - 4
        v_sk.info_to_all.extend(bytes([data_length]) + line[7:data_length - 1])
    return 1


def translate_power(dat):
    match dat:
        case 0:
            return 0
        case 1:
            return 1
        case 2:
            return 4
        case 3:
            return 9
        case 4:
            return 16
        case 5:
            return 25
        case 6:
            return 33
        case 7:
            return 49
        case 8:
            return 64
        case 9:
            return 81


def translate_hight(dat):
    match dat:
        case 0:
            return 3
        case 1:
            return 6
        case 2:
            return 12
        case 3:
            return 24
        case 4:
            return 49
        case 5:
            return 98
        case 6:
            return 195
        case 7:
            return 390
        case 8:
            return 780
        case 9:
            return 1561


def translate_dir(dat):
    match dat:
        case 0:
            return "omni"
        case 1:
            return "45NE"
        case 2:
            return "90E"
        case 3:
            return "135SE"
        case 4:
            return "180S"
        case 5:
            return "225SW"
        case 6:
            return "170W"
        case 7:
            return "315NW"
        case 8:
            return "360N"


def dprs_weather_status(line):
    # DV RX D-PRS dprs_weather_status
    v_sk.info_to_all.extend(bytes([v_icom_vars.command_storage]))
    if line[8] == 0xff:
        v_sk.info_to_all.extend([line[2], 0])
    else:
        match v_icom_vars.command_storage:
            case 0:
                v_sk.info_to_all.extend([line[8]])
            case 1:
                v_sk.info_to_all.extend([line[9:18]])
            case 2:
                v_sk.info_to_all.extend([line[18:20]])
            case 3:
                # lat
                v_sk.info_to_all.extend([line[20], "d",line[21],".",line[22:25]])
            case 4:
                # long
                v_sk.info_to_all.extend([line[25:27], "d",line[27],".",line[28:31]])
            case 5:
                # date
                v_sk.info_to_all.extend([line[31:33],":",line[33],";",line[34],":",line[35],";",line[36],":",line[37]])
            case 6:
                # wind dir
                v_sk.info_to_all.extend(line[38:40])
            case 7:
                # wind speed
                v_sk.info_to_all.extend(line[40:42])
            case 8:
                # gust speed
                v_sk.info_to_all.extend(line[42:44])
            case 9:
                # temp
                v_sk.info_to_all.extend(line[44:47])
            case 10:
                # rain
                v_sk.info_to_all.extend(line[47:49])
            case 11:
                # rain 24h
                v_sk.info_to_all.extend(line[48:51])
            case 12:
                # rain midnight
                v_sk.info_to_all.extend(line[51:53])
            case 13:
                # humidity
                v_sk.info_to_all.extend(line[53:55])
            case 14:
                # pressure
                v_sk.info_to_all.extend(line[55:58])
        data_length = len(line) - 4
        v_sk.info_to_all.extend(bytes([data_length]) + line[7:data_length - 1])
    return 1


def answer_dprs_message(line):
    # DV RX D-PRS message for transceive
    v_sk.info_to_all.extend([len(line)- 7])
    v_sk.info_to_all.extend(line[7:])
    return 1


def answer_rit(line):
    # rit
    v_sk.info_to_all.extend(bcd_plusminus_to_int(line, 6, 9999, 2, 2, 1))
    return 1


def answer_pos_speed_hight(line):
    # position, course, speed, time
    if len(line) < 9:
        v_sk.info_to_all.extend([0x0, 0x0, 0x0, 0x3, 0x0, 0x0, 0x0, 0x3, 0x03, 0x0d, 0x41, 0x16, 0x09, 0x00, 0x00, 0x00, 0x00])
    else:
        # lat,
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[6]), 1, byteorder="big"))
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[7]), 1, byteorder="big"))
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[8]), 1, byteorder="big"))
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[10]), 1, byteorder="big"))
        #long
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[11]) * 10 + bcd_to_int(line[12]), 1, byteorder="big"))
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[13]), 1, byteorder="big"))
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[14]), 1, byteorder="big"))
        # W / E
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[16]), 1, byteorder="big"))
        # alt
        if line[18:20] == bytearray([0xff, 0xff, 0xff]):
            v_sk.info_to_all.extend([0x00, 0x00])
        else:
            hight = bcdx_to_int(line[17:20], 2)
            if line[20] == 0:
                hight *= 10000
            else:
                hight = 10000 - hight
            v_sk.info_to_all.extend(int.to_bytes(hight, 2, byteorder="big"))
            v_sk.info_to_all.extend([line[20]])
        # course
        if line[21:23] == bytearray([0xff,0xff]):
            v_sk.info_to_all.extend(bytearray([0,0]))
        else:
            v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[21] * 100 + bcd_to_int(line[22])), 2, byteorder="big"))
        # speed
        if line[23:25] == bytearray([0xff,0xff]):
            v_sk.info_to_all.extend(bytearray([0,0]))
        else:
            v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[23]) * 100 + bcd_to_int(line[24]) * 10 + bcd_to_int(line[25]), 2, byteorder="big"))
        # year
        year = bcd_to_int(line[26]) * 100 + bcd_to_int(line[27])
        v_sk.info_to_all.extend(int.to_bytes(year, 2, byteorder="big"))
        # month
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[28]), 1, byteorder="big"))
        # day
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[29]), 1, byteorder="big"))
        # hour
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[30]), 1, byteorder="big"))
        # min
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[31]), 1, byteorder="big"))
        # sec
        v_sk.info_to_all.extend(int.to_bytes(bcd_to_int(line[32]), 1, byteorder="big"))
    return 1

def position(line,x):
    # missung !!!!
    return 1

def answer_gps_select(line):
    #  GPS Select
    if line[6] == 3:
        v_sk.info_to_all.extend([0x02])
    else:
        v_sk.info_to_all.extend([line[6]])
    return 1


def answer_sel_unsel_f(line):
    #  selected or unselected VFO frequency
    v_sk.info_to_all.extend(bytearray([line[5]]))
    v_sk.info_to_all.extend(frequency_for_answer(line[6:11], 30000, 4, 1))
    return 1


def answer_sel_unsel_mode(line):
    # selected or unselected VFO’s operating mode and filter
    if line[6] == 0x17:
        line[6] -= 9
    if line[7] == 1:
        # data mode
        if line[6] == 5:
            # FM-D
            line[6] = 13
        else:
            line[6] += 10
    line[8] -= 1
    v_sk.info_to_all.extend(line[5:7])
    v_sk.info_to_all.extend(bytearray([line[8]]))
    return 1


def answer_scope_output(line):
    # answer of scope waveform output
    v_sk.info_to_all = bytearray([0x04, 0x52, len(line[6:-1])])
    v_sk.info_to_all.extend(line[6:-1])
    return 1


def answer_span_center(line):
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
    # Scope Reference level
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

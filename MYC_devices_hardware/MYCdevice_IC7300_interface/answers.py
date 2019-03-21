"""
name: answers.py
last edited: 20190312
handling of answers from the radio
output to v_sk_info_to_all
"""

import time

from misc_functions import *
from commands import *

import v_sk
import v_Ic7300_vars

def answer_nop(line):
    return 1

def find_token(line):
    # tokennumbers must not have gaps
    # if there are operate and answer commands: answer must immediately folloe the oprerate command
    # not used now; cannot be used, if calls are used by multiple commands
    temp = 255
    second = 0
    while  temp < 790 and second != 2:
        temp += 1
        if second == 1:
            if v_Ic7300_vars.token_civ_code[temp] != line:
                temp -= 1
            second = 2
        if second == 0 and  v_Ic7300_vars.token_civ_code[temp] == line:
            second = 1
    v_sk.info_to_all = int_to_ba(temp, 2)
    return

def answer_x_1_b_x(line, adder, position):
    # used for all answers x CIV commandbytes, one byte bcd coded parameter at "position" with base "adder"
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    v_sk.info_to_all.extend([bcd_to_int(line[position]) + adder])
    return 1

def answer_1_1_b(line):
    # used for all answers 1CIV  commandbytes, one byte bcd coded parameter with base 0
    return answer_x_1_b_x(line, 0, 5)

def answer_2_1_b(line):
    # used for all answers 2 CIV commandbytes, one byte bcd coded parameter with base 0
    return answer_x_1_b_x(line, 0, 6)

def answer_4_1_b(line):
    # used for all answers 4 CIV commandbytes, one byte bcd coded parameter with base 0
    return answer_x_1_b_x(line, 0, 8)

def answer_4_1_b_1(line):
    # used for all answers 4 CIV commandbytes, one byte bcd coded parameter with base 1
    return  answer_x_1_b_x(line, -1, 8)

def answer_4_1_b_28(line):
    # used for all answers 4 CIV commandbytes, one byte bcd coded parameter with base 28
    return answer_x_1_b_x(line, -28, 8)

def answer_x_2_b_x(line, position, adder, myc):
    # used for all answers x  CIV commandbytes, two byte bcd coded parameter with base "adder" to myc byte MYC parameter
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    if myc == 1:
        v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[position: 2 + position]) + adder]))
    else:
        v_sk.info_to_all.extend(bcd_to_ba_2(line[position : 2 + position], adder))
    return 1

def answer_2_2_b_0_1(line):
    # used for all answers 2 commandbytes, two byte bcd coded parameter with base 0 to 1 byte MYC parameter
    return answer_x_2_b_x(line, 6, 0, 1)

def answer_2_2_b_1_1(line):
    # used for all answers 2 commandbytes, two byte bcd coded parameter with base 1 to 1 byte MYC parameter
    return answer_x_2_b_x(line, 6, -1, 1)

def answer_2_2_b_0(line):
    # used for all answers 2 commandbytes, two byte bcd coded parameter with base 0 to 2 byte MYC parameter
    return answer_x_2_b_x(line, 6, 0, 2)

def answer_4_2_b_0(line):
    # used for all answers 4 commandbytes, two byte bcd coded parameter  with base 0 to 2 byte MYC parameter
    return answer_x_2_b_x(line, 8, 0, 2)

def answer_4_2_b_0_1(line):
    # used for all answers 4 commandbytes, two byte bcd coded parameter  with base 0 to 1 byte MYC parameter
    return answer_x_2_b_x(line, 8, 0, 1)

def answer_4_2_b_1(line):
    # used for all answers 4 commandbytes, two byte bcd coded parameter  with base 1 to 2 byte MYC parameter
    return answer_x_2_b_x(line, 8, -1, 2)

def  answer_string(line):
    temp1 = line.find(0xfd) - 1
    # -1 because of "fd"
    end = 0
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1],0x00])
    stringcount = 0
    strinlength_pos = len(v_sk.info_to_all) - 1
    while temp1 < len(line):
        if line[temp1] == 253:
            end = 1
        else:
            v_sk.info_to_all.extend(bytearray([line[temp1]]))
            stringcount += 1
        temp1 += 1
    if end == 0:
        v_sk.info_to_all = bytearray([])
        return 0, line.find(0xfd)
    else:
        v_sk.info_to_all[strinlength_pos] = stringcount

        return 1

def answer_frequencyxx(line, adder, divide, par):
    # convert n bcd bytes of frequency lsb first
    # if low nible of LSB is not used: divide by divide (10)
    # convert to bytearray with par parameter bytes
    print (line)
    temp1 = 0
    frequency = 0
    multiplier = 1
    while temp1 < len(line):
        temp2 = bcd_to_int(line[temp1])
        frequency = frequency + multiplier * temp2
        multiplier *= 100
        temp1 += 1
    frequency //= divide
    frequency -= adder
    print(frequency)
    temp1 = int_to_ba(frequency, par)
    print (temp1,par)
    return temp1

def answer_mode_filterx(line, memory, mode_filter):
    if memory == 0:
        v_Ic7300_vars.actual_mode_filter_content = line
        if mode_filter == 0:
            if line[0] > 5:
                line[0] -= 1
            temp = line[0]
        else:
            temp = line[1] - 1
        v_sk.info_to_all.extend(bytearray([temp]))
    else:
        if mode_filter == 0:
            if line[0] > 5:
                line[0] -= 1
            return line[0]
        else:
            line[1] -= 1
            return line[1]
    return

def answer_frequency_tranceive(line):
    # for 00 (transceive command
    v_sk.info_to_all = bytearray([0x01,0x01])
    v_sk.info_to_all.extend(answer_frequencyxx(line[5:9], 30000, 1, 4))
    return 1

def answer_mode_filter4(line):
    # for command 4
    v_sk.info_to_all = bytearray([0x01,0x03])
    answer_mode_filterx(line[5:7], 0, 0)
    if v_Ic7300_vars.init_content > 0:
        v_Ic7300_vars.init_content += 1
    return 1

def answer_band_edgexx(line):
    token = v_sk.last_token[0] * 256 + v_sk.last_token[1]
    postion_adder = v_Ic7300_vars.parameter[token]
    temp1 = answer_frequencyxx(line[5 + postion_adder:9 + postion_adder], 0, 1, 4)
    temp2 = 0
    while temp2 < 4:
        v_sk.info_to_all.extend(bytearray([temp1[temp2]]))
        temp2 += 1
    temp1 = answer_frequencyxx(line[11 + postion_adder:15 + postion_adder], 0, 1, 4)
    temp2 = 0
    while temp2 < 4:
        v_sk.info_to_all.extend(bytearray([temp1[temp2]]))
        temp2 += 1
    return

def answer_band_edge(line):
    v_sk.info_to_all = bytearray([0x01, 0x4])
    answer_band_edgexx(line)
    return 1

def answer_band_edge1(line):
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1], line[6] - 1])
    answer_band_edgexx(line)
    return 1

def answer_frequency(line):
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    # start position of bcd varies, is given with last command
    try:
        par = v_Ic7300_vars.parameter[v_sk.last_token[0] * 256 + v_sk.last_token[1]]
    except KeyError:
        par = 0
    v_sk.info_to_all.extend(answer_frequencyxx(line[(5 + par):(9 + par)], 30000, 1, 4))
    return 1

def answer_frequency_sel(line):
    # civcommand 25
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    v_sk.info_to_all.extend(bytearray([line[5]]))
    v_sk.info_to_all.extend(answer_frequencyxx(line[6:10], 30000, 1, 4))
    return 1

def answer_att(line):
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    if line[5] == 0:
        v_sk.info_to_all.extend([0x00])
    else:
        v_sk.info_to_all.extend([0x01])
    return 1

def answer_memory_content(line):
    if v_Ic7300_vars.init_content > 0:
        # intialization
        # read complete content, temporary storage only
        if line[8:] == bytearray([0xff,0xfd]):
            if v_Ic7300_vars.init_content > 0:
                v_Ic7300_vars.init_content = 3
                if v_Ic7300_vars.memory_to_check == 0:
                    # if first memory is empty, fill with some default
                    v_Ic7300_vars.actual_memory_content = bytearray(b'\xfe\xfe\xe0\x94\x1a\x00\x00\x01\x00\x000$\x14\x00\x01\x02\x00\x00\x08\x85\x00\x08\x85\x000$\x14\x00\x01\x02\x00\x00\x08\x85\x00\x08\x85          \xfd')
        else:
            v_Ic7300_vars.actual_memory_content = line[8:]
            v_Ic7300_vars.init_content = 1
    elif v_Ic7300_vars.ask_content > 0:
        # momory number + data + 0xfd
        v_Ic7300_vars.actual_memory_content = line[6:]
        v_Ic7300_vars.ask_content = 3
    else:
        # analyze data
        v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
        v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[6:8]) - 1]))
        if v_sk.last_token == bytearray([0x02, 0xfd]):
            # frequency
            v_sk.info_to_all.extend(answer_frequencyxx(line[9:14],30000,1,4))
        elif v_sk.last_token == bytearray([0x02, 0xff]):
            # mode
            v_sk.info_to_all.extend(bytearray([answer_mode_filterx(line[14:16], 1, 0)]))
        elif v_sk.last_token == bytearray([0x03, 0x01]):
            # filter
            v_sk.info_to_all.extend(bytearray([answer_mode_filterx(line[14:16], 1, 1)]))
        elif v_sk.last_token == bytearray([0x03, 0x03]):
            # tone
            v_sk.info_to_all.extend(bytearray([line[16] & 0x0f]))
        elif v_sk.last_token == bytearray([0x03, 0x05]):
            # data mode
            v_sk.info_to_all.extend(bytearray([(line[16] & 0xf0) >> 4]))
        elif v_sk.last_token == bytearray([0x03, 0x07]):
            # tone frequency
            temp = 0
            while temp < 50 and ([line[18],line[19]] != v_Ic7300_vars.tone_frequency[temp]):
                temp +=1
            v_sk.info_to_all.extend(bytearray([temp]))
        elif v_sk.last_token == bytearray([0x03, 0x09]):
            # tone squelch
            temp = 0
            while temp < 50 and ([line[21],line[22]] != v_Ic7300_vars.tone_frequency[temp]):
                temp += 1
            v_sk.info_to_all.extend(bytearray([temp]))
        elif v_sk.last_token == bytearray([0x03, 0x0b]):
            # frequency split
            v_sk.info_to_all.extend(answer_frequencyxx(line[23:28],30000,1,4))
        elif v_sk.last_token == bytearray([0x03, 0x0d]):
            # mode split
            v_sk.info_to_all.extend(bytearray([answer_mode_filterx(line[28:30], 1, 0)]))
        elif v_sk.last_token == bytearray([0x03, 0x0f]):
            # filter split
            v_sk.info_to_all.extend(bytearray([answer_mode_filterx(line[28:30], 1, 1)]))
        elif v_sk.last_token == bytearray([0x03, 0x11]):
            # tone split
            v_sk.info_to_all.extend(bytearray([line[30] & 0x0f]))
        elif v_sk.last_token == bytearray([0x03, 0x13]):
            # data mode split
            v_sk.info_to_all.extend(bytearray([(line[30] & 0xf0) >> 4]))
        elif v_sk.last_token == bytearray([0x03, 0x15]):
            # tone frequency split
            temp = 0
            while temp < 50 and ([line[32],line[33]] != v_Ic7300_vars.tone_frequency[temp]):
                temp +=1
            v_sk.info_to_all.extend(bytearray([temp]))
        elif v_sk.last_token == bytearray([0x03, 0x17]):
            # tone squelch split
            temp = 0
            while temp < 50 and ([line[35],line[36]] != v_Ic7300_vars.tone_frequency[temp]):
                temp += 1
            v_sk.info_to_all.extend(bytearray([temp]))
        elif v_sk.last_token == bytearray([0x03, 0x19]):
            # name
            length = len(line[37:-1])
            v_sk.info_to_all.extend(bytearray([length]))
            v_sk.info_to_all.extend(line[37 : -1])
        elif v_sk.last_token == bytearray([0x03, 0x78]):
            # filter
            v_sk.info_to_all.extend(answer_mode_filterx(line[14:16], 1, 1))
    return 1

def answer_band_stack(line):
    print(v_Ic7300_vars.ask_content)
    if v_Ic7300_vars.ask_content == 0:
        v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
        print(line[7],(line[7] - 1) * 11, bcd_to_int(line[6] - 1))
        v_sk.info_to_all.extend(bytearray([(line[7] - 1) * 11 + bcd_to_int(line[6] - 1)]))
        v_sk.info_to_all.extend(bytearray([len(line[9:-1])]))
        v_sk.info_to_all.extend(line[8:-1])
    elif v_Ic7300_vars.ask_content == 1:
        v_Ic7300_vars.band_stack = line[7:]
        v_Ic7300_vars.ask_content = 3
    return 1

def answer_memory_keyer(line):
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    # memory number:
    v_sk.info_to_all.extend(bytearray([line[6]]))
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
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[8])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[9]) - 5]))
    return 1

def answer_ssb_passband(line):
    # used for all answers with one parameter with  modification for 1a050x commands
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    v_sk.info_to_all.extend([(line[8] & 0xf0 ) >> 4])
    v_sk.info_to_all.extend([line[8] & 0x0f])
    return 1

def answer_offset(line):
    # code 1a050031 and 1a050032
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    v_sk.info_to_all.extend(bcd_plusminus_to_int(line, 8, 9999, 3, 2, 10))
    return 1

def answer_date(line):
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[8:10]) - 2000]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[10] - 1)]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[11] - 1)]))
    return 1

def answer_time(line):
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[8])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int(line[9])]))
    return 1

def answer_utc(line):
    minutes = bcd_to_int(line[8]) * 60 + bcd_to_int(line[9])
    if line[10] == 0:
        # plus
        minutes  += 840
    else:
        minutes = 840 - minutes
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    v_sk.info_to_all.extend(int_to_ba(minutes, 2))
    return 1

def answer_scope_edgexx(line):
    # for commnad 1a01xx
    last_token = v_sk.last_token[0] * 256 + v_sk.last_token[1]
    adder = v_Ic7300_vars.number_frequency_range[v_Ic7300_vars.tokennumber_frequency_range_number[last_token]]
    temp1 = 8
    multiplier = 1
    lf = 0
    while temp1 < 11:
        lf += bcd_to_int(line[temp1]) * multiplier
        multiplier *= 100
        temp1 += 1
    # 100Hz ignored
    lf = (lf // 10) - adder[0]
    # result in kHz, offset subtracted
    temp1 = 11
    multiplier = 1
    hf = 0
    while temp1 < 14:
        hf += bcd_to_int(line[temp1]) * multiplier
        multiplier *= 100
        temp1 += 1
    hf = (hf // 10) - adder[0]
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    v_sk.info_to_all.extend(bytearray([v_sk.parameter]))
    v_sk.info_to_all.extend(int_to_ba(lf, 2))
    v_sk.info_to_all.extend(int_to_ba(hf - lf - 5, 2))
    return 1

def answer_color(line):
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[8:10])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[10:12])]))
    v_sk.info_to_all.extend(bytearray([bcd_to_int2(line[12:14])]))
    return 1

def answer_data_mode(line):
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    temp1 = 0
    if line[6] == 1:
        temp1 = line[7]
    v_sk.info_to_all.extend(bytearray([temp1]))
    return 1

def answer_tone_frequency(line):
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    temp = 0
    while temp < 50 and [line[7], line[8]] != v_Ic7300_vars.tone_frequency[temp]:
        temp +=1
    v_sk.info_to_all.extend(bytearray([temp]))
    return 1

def answer_rit(line):
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    v_sk.info_to_all.extend(bcd_plusminus_to_int(line, 6, 9999, 2, 2, 1))
    return 1

def answer_scope_span(line):
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    span = line[8:10]
    value = 0
    if span == bytearray([0x25,0x00]):
        value = 0
    elif span == bytearray([0x50,0x00]):
        value = 1
    elif span == bytearray([0x00, 0x01]):
        value = 2
    elif span == bytearray([0x50, 0x02]):
        value = 3
    elif span == bytearray([0x00, 0x05]):
        value = 4
    elif span == bytearray([0x00, 0x10]):
        value = 5
    elif span == bytearray([0x00,0x25]):
        value = 6
    elif span == bytearray([0x00,0x50]):
        value = 7
    v_sk.info_to_all.extend(bytearray([value]))
    return 1

def answer_scope_reference_level(line):
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    intvalue = bcd_to_int((line[7])) * 2
    if line[8] != 0:
        intvalue += 1
    if line[9] == 0:
        # positive
        intvalue += 40
    else:
        intvalue = 40 - intvalue
    v_sk.info_to_all.extend(int_to_ba(intvalue, 1))
    return 1

def answer_scope_edge00(line):
    # for command 271e
    last_token = v_sk.last_token[0] * 256 + v_sk.last_token[1]
    adder = number_frequency_range[tokennumber_frequency_range_number[last_token]][0]
    temp1 = 9
    # 10Hz and 100Hz ignored,
    multiplier = 1
    lf = 0
    while temp1 < 12:
        lf += bcd_to_int(line[temp1]) * multiplier
        multiplier *= 100
        temp1 += 1
    lf = (lf // 10) - adder
    # result in kHz, offset subtracted
    temp1 = 14
    multiplier = 1
    hf = 0
    while temp1 < 17:
        hf += bcd_to_int(line[temp1]) * multiplier
        multiplier *= 100
        temp1 += 1
    hf = (hf // 10) - adder
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    # edgenumber:
    v_sk.info_to_all.extend([line[7] - 1])
    v_sk.info_to_all.extend(int_to_ba(lf, 2))
    v_sk.info_to_all.extend(int_to_ba(hf, 2))
    return 1

def answer_mode_data_filter(line):
    # for command 25
    v_sk.info_to_all = bytearray([v_sk.last_token[0], v_sk.last_token[1]])
    if line[6] > 5:
        line[6] -= 1
    if line[7] == 1:
        # data mode
        line[6] += 8
    if line[6] == 13:
        # FM-D
        line[6] = 11
    line[8] -= 1
    v_sk.info_to_all.extend(line[5:7])
    v_sk.info_to_all.extend(bytearray([line[8]]))
    return 1
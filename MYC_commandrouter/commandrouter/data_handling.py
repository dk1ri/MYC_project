"""
name : data_handling.py
last edited: 202512
data handling subprograms for SK, and device
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""
import time
import v_announcelist
from misc_functions import *

# some switches, no parameters
def data_0(input_device):
    # v_sk.len / v_dev.len: not used
    finish_sk(input_device, 1)
    return

# switches, range commands. m, all answer commands
def data_1(line, got_bytes, sk, linelength):
    # used v_sk.len / v_dev.len: 0: actual wait
    finish = 0
    if got_bytes >= sk[0]:
        pos_in_linelength = 2
        pos_in_data = sk[1]
        while pos_in_linelength < len(linelength) and finish == 0:
            parameter = bytes_to_int_ba(line[pos_in_data + 1 :pos_in_data + 1 + linelength[pos_in_linelength + 1]])
            # check always
            if parameter > linelength[pos_in_linelength]:
                write_log("transfertype 1 value too high, " + str(parameter) + " should be " + str(linelength[pos_in_linelength]))
                finish = 2
            else:
                if pos_in_linelength + 4 >= len(linelength):
                    # all loops done
                    finish = 1

            # add length to actual pos
            pos_in_data += linelength[pos_in_linelength + 1]
            pos_in_linelength += 3
    return sk, finish

# on command / an answer
def data_2(line, got_bytes, sk, linelength):
    # sk: actual 0: wait, 1: number of calls (0 based)
    # 3: number of elements not yet transmitted, 4: 0 next stringlenth - 1 string,
    # 5: actual stringlength
    finish = 0
    if got_bytes >= sk[0]:
        if sk[1] == 0:
            # got position + elements
            pos_in_line = v_announcelist.length_of_full_elements
            # 1st parameter
            position = bytes_to_int_ba(line[pos_in_line:pos_in_line + linelength[3]])
            if position <= linelength[2]:
                elements = bytes_to_int_ba(line[sk[0] -1:sk[0] + linelength[6]])
                if elements == 0:
                    finish = 1
                elif elements <= linelength[5]:
                    # wait next (length of <ty>)
                    sk[0] += linelength[9]
                    # next call
                    sk[1] = 1
                    # elements not yet transmitted
                    sk[2] = elements
                else:
                    write_log("on element value too high:" + str(elements) + " should be " + str(linelength[5]))
                    finish = 2
            else:
                write_log("on position too high:" + str(position) + " should be " + str(linelength[2]))
                finish = 2
        elif sk[1] == 1:
            # got value or stringlength
            if linelength[10] == 0:
                # numeric
                value = bytes_to_int_ba(line[sk[0] - 1:sk[0] + linelength[9]])
                if value > linelength[8]:
                    write_log("on element value too high:" + str(value) + " should be " + str(linelength[8]))
                    finish = 2
                else:
                    if sk[2] == 1:
                        # all elements done
                        finish = 1
                    else:
                        # wait for all outstanding elements
                        sk[0] += linelength[9] * (sk[2] - 1)
                        sk[2] = 1
            else:
                # string
                if sk[3] == 0:
                    # stringlength
                    sk[0] += linelength[9]
                    sk[3]  = 1
                    stringlen = bytes_to_int_ba(line[sk[0]:sk[0] + linelength[9]])
                    sk[4] = stringlen
                else:
                    sk[0] += sk[4]
                    sk[2] -= 1
                    if sk[2] == 0:
                        sk[2] = -1
                    sk[3] = 0
                    sk[4] = 0
    return sk, finish

# oa command / aa answer
def data_3(line, got_bytes, sk, linelength):
    # called once for each parameter
    # sk: 0: len of line to wait, 1: number of calls (0 based), 2: 1st parameter, 3: pos in line to start actual.
    finish = 0
    if got_bytes >= sk[0]:
        if sk[1] == 0:
            # got position or data
            data_pos_value = int.from_bytes(line[sk[0] - 1:sk[0] - 1 + linelength[3]])
            if len(linelength) == 5:
                # one element only; got data
                if linelength[4] == 0:
                    # numeric
                    if data_pos_value <= linelength[2]:
                        finish = 1
                    else:
                        write_log("oa value too high:" + str(data_pos_value) + " should be " + str(linelength[2]))
                        finish = 2
                else:
                    # string
                    if data_pos_value <= linelength[2]:
                        if data_pos_value == 0:
                            # no data expected
                            finish = 1
                        else:
                            # add length to wait
                            sk[0] += data_pos_value
                            # next call
                            sk[1] = 1
                    else:
                        write_log("oa value for stringlength too high:" + str(data_pos_value) + " should be <= " + str(linelength[2]))
                        finish = 2
            else:
                # more than one element
                # position
                if data_pos_value <= linelength[2]:
                    # add length of (next) par or stringlength
                    sk[0] += linelength[9]
                    # next call
                    sk[1] = 1
                    # 1st parameter
                    sk[2] = data_pos_value
                else:
                    write_log("oa position too high:" + str(data_pos_value) + " should be <= " + str(linelength[2]))
                    finish = 2
        elif sk[1] == 1:
            if len(linelength) == 5:
                # one parameter in linelength only: string finished
                finish = 1
            else:
                # position for start of parameter block in linelength (numeric value or string length)
                pos_in_linelength = 2 + (sk[2] + 1) * 3
                # length of 2nd  parameter
                parameter_of_line = bytes_to_int_ba(line[sk[0] - 1:sk[0] - 1 + linelength[pos_in_linelength + 1]])
                if linelength[pos_in_linelength + 2] == 0:
                    # numeric
                    # linelength[pos_in_linelength]sk: max value
                    if parameter_of_line <= linelength[pos_in_linelength]:
                        finish = 1
                    else:
                        write_log("oa value too high:" + str(parameter_of_line) + " should be <= " + str(linelength[pos_in_linelength]))
                        finish = 2
                else:
                    # string
                    # linelength[pos_in_linelength]sk: max stringlength
                    if parameter_of_line <= linelength[pos_in_linelength]:
                        if linelength == 0:
                            # no data expected
                            finish = 1
                        else:
                            # string; add length of string
                            length_of_string = parameter_of_line
                            sk[0] += length_of_string
                            sk[1] = 2
                    else:
                        write_log("oa stringlength too high:" + str(parameter_of_line) + " should be <= " + str(linelength[pos_in_linelength]))
                        finish = 2
        else:
            # sk[1] == 2: got string
            finish = 1
    return sk, finish

# of command / af answer
def data_4(line, got_bytes, sk, linelength):
    # sk: 0: len of line to wait, 1: number of call (0 based),2:  1st parameter,
    #  3: 0:stringlength- 1: string.
    finish = 0
    if got_bytes >= sk[0]:
        if sk[1] == 0:
            # got number of elements
            number_of_elements = int.from_bytes(line[v_announcelist.length_of_full_elements:v_announcelist.length_of_full_elements + linelength[3]])
            if number_of_elements == 0:
                finish = 1
            elif number_of_elements <= linelength[2]:
                # add length of (next) par or stringlength
                sk[0] += linelength[6]
                # next call
                sk[1] = 1
                # 1st parameter
                sk[2] = number_of_elements
            else:
                write_log("of number of elements too high:" + str(number_of_elements) + " should be " + str(linelength[2]))
                finish = 2
        elif sk[1] == 1:
            if linelength[7] == 0:
                # numeric
                value = int.from_bytes(line[sk[0] - 1:sk[0] + linelength[6]])
                if value <= linelength[5]:
                    sk[0] += linelength[6]
                    # number of outstanding elements
                    sk[2] -= 1
                    if sk[2] < 1:
                        finish = 1
                else:
                    write_log("of value too high:" + str(value) + " should be <= " + str(linelength[5]))
                    finish = 2
            else:
                # string
                # stringlength
                # stringlength
                value = int.from_bytes(line[sk[0] - 1:sk[0] + linelength[6]])
                if value <= linelength[5]:
                    if value == 0:
                        # no data expected
                        finish = 1
                    else:
                        # string; add length of string
                        sk[0] += value
                        sk[1] = 2
                        sk[3] = 1
                else:
                    write_log("oa stringlength too high:" + str(value) + " should be " + str(linelength[5]))
                    finish = 2
        elif sk[1] == 2:
            # string
            # add length of stringlength
            sk[0] += linelength[6]
            sk[1] = 1
            sk[2] -= 1
            if sk[2] < 1:
                finish = 1
            sk[3] = 0
    return sk, finish

# ob command / ab answer
def data_5(line, got_bytes, sk, linelength):
    # sk: 0: len, 1: call, 2: number of not transmitted, 3: 0 normal, 1: additional call
    # 4: next pos in linelength
    finish = 0
    if got_bytes >= sk[0]:
        if sk[1] == 0:
            # got start and elements and 1st value
            sk[1] = 1
            par_start = v_announcelist.length_of_full_elements
            start = bytes_to_int_ba(line[par_start:par_start + linelength[3]])
            if start <= linelength[2]:
                par_start += linelength[3]
                elements = bytes_to_int_ba(line[par_start:par_start + linelength[6]])
                if elements == 0:
                    finish = 1
                if elements <= linelength[5]:
                    sk[2] = elements
                    par_start += linelength[6]
                    # add length of parameter of start
                    sk[0] = par_start + linelength[9 + start * 3]
                    sk[1] = 1
                    sk[2] = elements
                    # start pos for next element (value or stringlength) depend on start (0 based)
                    sk[4] = 8 + start * 3
                else:
                    write_log("ob elements too high:" + str(elements) + " should be <=" + str(linelength[5]))
                    finish = 2
            else:
                write_log("ob start value too high:" + str(start) + " should be <=" + str(linelength[2]))
                finish = 2
        elif sk[1] == 1:
            # got element or stringlength
            start_of_value = sk[0] - linelength[sk[4] + 1]
            value = bytes_to_int_ba(line[start_of_value:start_of_value + linelength[sk[4] + 1]])
            print(sk[4])
            if value <= linelength[sk[4]]:
                # actual value ok
                # numeric or string?
                if linelength[sk[4] + 2] == 0:
                    # numeric
                    sk[2] -= 1
                    if sk[2] < 1:
                        finish = 1
                    # get data for next block
                    if sk[4] + 3 > len(linelength) - 1:
                        # continue with first element
                        sk[4] = 8
                    else:
                        sk[4] += 3
                        # add next element or stringlength
                    sk[0] += linelength[sk[4] + 1]
                else:
                    # string: additional call
                    # value is length of string
                    sk[0] += value
                    sk[1] = 2
            else:
                write_log("ob value or stringlenth too high:" + str(value) + " should be <= " + str(linelength[sk[4] + 1]))
                finish = 2

        elif sk[1] == 2:
            # string
            sk[2] -= 1
            if sk[2] < 1:
                finish = 1
                # get data for next block
            if sk[4] + 3 > len(linelength) - 1:
                # continue with first element
                sk[4] = 8
            else:
                sk[4] += 3
                # add next element or stringlength
            sk[0] += linelength[sk[4] + 1]
            sk[1] = 1
    return sk, finish

# ob command / ab answer one element string
def data_6(line, got_bytes, sk, linelength):
    # sk: 0: len, 1: call
    finish = 0
    if got_bytes >= sk[0]:
        if sk[1] == 0:
            # got start and length of string
            par_start = v_announcelist.length_of_full_elements
            length_of_string = bytes_to_int_ba(line[par_start:par_start + linelength[3]])
            if length_of_string <= linelength[2]:
                sk[0] += length_of_string
                sk[1] = 1
            else:
                write_log("ob value too high:" + str(length_of_string) + " should be <=" + str(linelength[2]))
                finish = 2
        elif sk[1] == 1:
            finish = 1
    return sk, finish

# om command / am answer with strin
def data_7(line, got_bytes, sk, linelength):
    # sk: 0: len, 1: call
    finish = 0
    if got_bytes >= sk[0]:
        if sk[1] == 0:
            # got memoryposition and length of string
            position_start = v_announcelist.length_of_full_elements
            position = bytes_to_int_ba(line[position_start:position_start + linelength[3]])
            if position <= linelength[2]:
                stringlength_start = v_announcelist.length_of_full_elements + linelength[6]
                lengh_of_string = bytes_to_int_ba(line[stringlength_start:stringlength_start + linelength[3]])
                if lengh_of_string <= linelength[5]:
                    sk[0] += lengh_of_string
                    sk[1] = 1
                else:
                    write_log("om stringlength too high:" + str(lengh_of_string) + " should be <=" + str(linelength[5]))
                    finish = 2
            else:
                write_log("ob memoryposition too high:" + str(position) + " should be <=" + str(linelength[2]))
                finish = 2
        elif sk[1] == 1:
            finish = 1
    return sk, finish
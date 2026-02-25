"""
name : data_handling.py
last edited: 20260224
data handling subprograms for SK, and device
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""
import time
import v_announcelist
import v_ld
import v_sk
import misc_functions

# some switches, no parameters
def data_0(got_bytes, sk, input_device):
    # v_sk.len / v_dev.len: not used
    finish = 0
    if got_bytes >= sk[0]:
        v_sk.orig_to_ld = v_sk.inputline[input_device]
        finish = 1
    return finish

# switches, range commands. m, all answer commands
def data_1(tok, line, got_bytes, sk, linelength, input_device):
    # used v_sk.len / v_dev.len: 0: actual wait
    finish = 0
    if got_bytes >= sk[0]:
        pos_in_linelength = 2
        pos_in_data = sk[1]
        while pos_in_linelength < len(linelength) and finish == 0:
            parameter = int.from_bytes(line[pos_in_data + 1:pos_in_data + 1 + linelength[pos_in_linelength + 1]])
           # parameter = bytes_to_int_ba(line[pos_in_data + 1 :pos_in_data + 1 + linelength[pos_in_linelength + 1]])
            # check always
            if tok in v_ld.right_tok:
                if v_sk.input_as_parameter_list == []:
                    v_sk.input_as_parameter_list = parameter
                else:
                    v_sk.input_as_parameter_list.append(parameter)
            if parameter > linelength[pos_in_linelength]:
                misc_functions. write_log("transfertype 1 value too high, " + str(parameter) + " should be " + str(linelength[pos_in_linelength]))
                finish = 2
            else:
                if pos_in_linelength + 4 >= len(linelength):
                    # all loops done
                    v_sk.orig_to_ld = v_sk.inputline[input_device]
                    finish = 1
            # add length to actual pos
            pos_in_data += linelength[pos_in_linelength + 1]
            pos_in_linelength += 3
    return sk, finish

# on command / an answer
def data_2(line, got_bytes, sk, linelength, input_device):
    # sk: actual 0: wait, 1: number of calls (0 based)
    # 2: number of elements not yet transmitted, 3: 0 next stringlength - 1 string,
    # 5: actual got bytes
    # not used by LD: no input_as_parameter_list
    finish = 0
    if got_bytes >= sk[0]:
        if sk[1] == 0:
            # got position + elements
            pos_in_line = v_announcelist.length_of_full_elements
            # 1st parameter
            position = misc_functions.bytes_to_int_ba(line[pos_in_line:pos_in_line + linelength[3]])
            if position <= linelength[2]:
                elements = misc_functions.bytes_to_int_ba(line[sk[0] -1:sk[0] + linelength[6]])
                if elements == 0:
                    v_sk.orig_to_ld = v_sk.inputline[input_device]
                    finish = 1
                elif elements <= linelength[5]:
                    # wait next (length of <ty>)
                    if linelength[10] == 0:
                        # numeric all elements with same length
                        sk[0] += linelength[9]
                    else:
                        # length of stringlength
                        sk[0] += linelength[9]
                        # next is stringlength
                        sk[3] = 0
                    sk[4] = got_bytes
                    # next call
                    sk[1] = 1
                    sk[2] = elements
                else:
                    misc_functions.write_log("on element value too high:" + str(elements) + " should be " + str(linelength[5]))
                    finish = 2
            else:
                misc_functions.write_log("on position too high:" + str(position) + " should be <= " + str(linelength[2]))
                finish = 2
        elif sk[1] == 1:
            # got all elements or stringlength or string
            if linelength[10] == 0:
                new_data = misc_functions.bytes_to_int_ba(line[sk[4]: got_bytes])
                if new_data <= linelength[8]:
                    sk[0] += linelength[9]
                    sk[2] -= 1
                    sk[3] = 0
                    sk[4] = got_bytes
                    if sk[2] <= 0:
                        # all elements done
                        v_sk.orig_to_ld = v_sk.inputline[input_device]
                        finish = 1
                else:
                    misc_functions.write_log("on numeric parameter too high:" + str(new_data) + " should be <= " + str(linelength[8]))
                    finish = 2

            else:
                # string
                if sk[3] == 0:
                    # got stringlength
                    new_stringlen = misc_functions.bytes_to_int_ba(line[sk[4]: got_bytes])
                    if new_stringlen <= linelength[8]:
                        sk[0] += new_stringlen
                        sk[3] = 1
                    else:
                        misc_functions.write_log("on stringlength too high:" + str(new_stringlen) + " should be <= " + str(linelength[8]))
                        finish = 2
                else:
                    # got string
                    # add length of stringlength
                    sk[0] += linelength[9]
                    sk[2] -= 1
                    sk[3] = 0
                    sk[4] = got_bytes
                    if sk[2] == 0:
                        # all elements done
                        v_sk.orig_to_ld = v_sk.inputline[input_device]
                        finish = 1

    return sk, finish

# oa command / aa answer
def data_3(tok, line, got_bytes, sk, linelength,  input_device):
    # called once for each parameter
    # sk: 0: len of line to wait, 1: number of call (0 based), 2: 1st parameter, 3: pos in line to start actual.
    finish = 0
    if got_bytes >= sk[0]:
        if sk[1] == 0:
            # got position or data
            data_pos_value = int.from_bytes(line[sk[0] - 1:sk[0] - 1 + linelength[3]])
            if len(linelength) == 5:
                # one element only; got data, no pos
                if linelength[4] == 0:
                    # numeric
                    if data_pos_value <= linelength[2]:
                        if tok in v_ld.right_tok:
                            v_sk.input_as_parameter_list = data_pos_value
                        v_sk.orig_to_ld = v_sk.inputline[input_device]
                        finish = 1
                    else:
                        misc_functions.write_log("oa value too high:" + str(data_pos_value) + " should be " + str(linelength[2]))
                        finish = 2
                else:
                    # string
                    if data_pos_value <= linelength[2]:
                        if data_pos_value == 0:
                            # no data expected
                            v_sk.orig_to_ld = v_sk.inputline[input_device]
                            finish = 1
                        else:
                            # add length to wait
                            sk[0] += data_pos_value
                            # next call
                            sk[1] = 1
                    else:
                        misc_functions.write_log("oa value for stringlength too high:" + str(data_pos_value) + " should be <= " + str(linelength[2]))
                        finish = 2
            else:
                # more than one element
                # position
                if data_pos_value <= linelength[2]:
                    # add length of (next) par or stringlength
                    # wait for bytes given for parameter at position
                    sk[0] += linelength[6 + data_pos_value * 3]
                    # next call
                    sk[1] = 1
                    # 1st parameter
                    sk[2] = data_pos_value
                else:
                    misc_functions.write_log("oa position too high:" + str(data_pos_value) + " should be <= " + str(linelength[2]))
                    finish = 2
        elif sk[1] == 1:
            if len(linelength) == 5:
                # one parameter in linelength only: string finished
                if tok in v_ld.right_tok:
                    v_sk.input_as_parameter_list = line[v_announcelist.length_of_full_elements:]
                v_sk.orig_to_ld = v_sk.inputline[input_device]
                finish = 1
            else:
                # position for start of parameter block in linelength (numeric value or string length)
                pos_in_linelength = 2 + (sk[2] + 1) * 3
                # length of 2nd  parameter
                # sk[0} is pos of last byte
                pos_of_first_byte = sk[0] - linelength[pos_in_linelength + 1]
                parameter_of_line = misc_functions.bytes_to_int_ba(line[pos_of_first_byte:sk[0]])
                if linelength[pos_in_linelength + 2] == 0:
                    # numeric
                    # linelength[pos_in_linelength]sk: max value
                    if parameter_of_line <= linelength[pos_in_linelength]:
                        # position
                        if tok in v_ld.right_tok:
                            v_sk.input_as_parameter_list = [sk[2]]
                            # numeric data
                            v_sk.input_as_parameter_list.append(parameter_of_line)
                        v_sk.orig_to_ld = v_sk.inputline[input_device]
                        finish = 1
                    else:
                        misc_functions.write_log("oa value too high:" + str(parameter_of_line) + " should be <= " + str(linelength[pos_in_linelength]))
                        finish = 2
                else:
                    # string
                    # linelength[pos_in_linelength]sk: max stringlength
                    if parameter_of_line <= linelength[pos_in_linelength]:
                        if linelength == 0:
                            # no data expected
                            v_sk.orig_to_ld = v_sk.inputline[input_device]
                            finish = 1
                        else:
                            # string; add length of string
                            length_of_string = parameter_of_line
                            sk[0] += length_of_string
                            sk[1] = 2
                    else:
                        misc_functions.write_log("oa stringlength too high:" + str(parameter_of_line) + " should be <= " + str(linelength[pos_in_linelength]))
                        finish = 2
        else:
            # sk[1] == 2: got string
            v_sk.orig_to_ld = v_sk.inputline[input_device]
            finish = 1
    return sk, finish

# of command / af answer
def data_4(line, got_bytes, sk, linelength, input_device):
    # sk: 0: len of line to wait, 1: number of call (0 based),2:  1st parameter,
    #  3: 0:stringlength- 1: string.
    # not used by LD: no input_as_parameter_list
    finish = 0
    if got_bytes >= sk[0]:
        if sk[1] == 0:
            print(linelength)
            print (line[0])
            # got number of elements
            number_of_elements = int.from_bytes(line[v_announcelist.length_of_full_elements:v_announcelist.length_of_full_elements + linelength[3]])
            if number_of_elements == 0:
                v_sk.orig_to_ld = v_sk.inputline[input_device]
                finish = 1
            elif number_of_elements <= linelength[2]:
                # add length of (next) par or stringlength
                sk[0] += linelength[6]
                # next call
                sk[1] = 1
                # 1st parameter
                sk[2] = number_of_elements
            else:
                misc_functions.write_log("of number of elements too high:" + str(number_of_elements) + " should be " + str(linelength[2]))
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
                        v_sk.orig_to_ld = v_sk.inputline[input_device]
                        finish = 1
                else:
                    misc_functions.write_log("of value too high:" + str(value) + " should be <= " + str(linelength[5]))
                    finish = 2
            else:
                # string
                # stringlength
                # stringlength
                value = int.from_bytes(line[sk[0] - 1:sk[0] + linelength[6]])
                if value <= linelength[5]:
                    if value == 0:
                        # no data expected
                        v_sk.orig_to_ld = v_sk.inputline[input_device]
                        finish = 1
                    else:
                        # string; add length of string
                        sk[0] += value
                        sk[1] = 2
                        sk[3] = 1
                else:
                    misc_functions.write_log("oa stringlength too high:" + str(value) + " should be " + str(linelength[5]))
                    finish = 2
        elif sk[1] == 2:
            # string
            # add length of stringlength
            sk[0] += linelength[6]
            sk[1] = 1
            sk[2] -= 1
            if sk[2] < 1:
                v_sk.orig_to_ld = v_sk.inputline[input_device]
                finish = 1
            sk[3] = 0
    return sk, finish

# ob command / ab answer
def data_5(line, got_bytes, sk, linelength, input_device):
    # sk: 0: len, 1: call, 2: number of not transmitted, 3: 0 normal, 1: additional call
    # 4: next pos in linelength
    # not used by LD: no input_as_parameter_list
    finish = 0
    if got_bytes >= sk[0]:
        if sk[1] == 0:
            # got start and elements and 1st value
            sk[1] = 1
            par_start = v_announcelist.length_of_full_elements
            start = misc_functions.bytes_to_int_ba(line[par_start:par_start + linelength[3]])
            if start <= linelength[2]:
                par_start += linelength[3]
                elements = misc_functions.bytes_to_int_ba(line[par_start:par_start + linelength[6]])
                if elements == 0:
                    v_sk.orig_to_ld = v_sk.inputline[input_device]
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
                    misc_functions.write_log("ob elements too high:" + str(elements) + " should be <=" + str(linelength[5]))
                    finish = 2
            else:
                misc_functions.write_log("ob start value too high:" + str(start) + " should be <=" + str(linelength[2]))
                finish = 2
        elif sk[1] == 1:
            # got element or stringlength
            start_of_value = sk[0] - linelength[sk[4] + 1]
            value = misc_functions.bytes_to_int_ba(line[start_of_value:start_of_value + linelength[sk[4] + 1]])
            if value <= linelength[sk[4]]:
                # actual value ok
                # numeric or string?
                if linelength[sk[4] + 2] == 0:
                    # numeric
                    sk[2] -= 1
                    if sk[2] < 1:
                        v_sk.orig_to_ld = v_sk.inputline[input_device]
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
                misc_functions.write_log("ob value or stringlenth too high:" + str(value) + " should be <= " + str(linelength[sk[4]]))
                finish = 2

        elif sk[1] == 2:
            # string
            sk[2] -= 1
            if sk[2] < 1:
                v_sk.orig_to_ld = v_sk.inputline[input_device]
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
def data_6(line, got_bytes, sk, linelength, input_device):
    # sk: 0: len, 1: call
    # not used by LD: no input_as_parameter_list
    finish = 0
    if got_bytes >= sk[0]:
        if sk[1] == 0:
            # got start and length of string
            par_start = v_announcelist.length_of_full_elements
            length_of_string = misc_functions.bytes_to_int_ba(line[par_start:par_start + linelength[3]])
            if length_of_string <= linelength[2]:
                sk[0] += length_of_string
                sk[1] = 1
            else:
                misc_functions.write_log("ob value too high:" + str(length_of_string) + " should be <=" + str(linelength[2]))
                finish = 2
        elif sk[1] == 1:
            v_sk.orig_to_ld = v_sk.inputline[input_device]
            finish = 1
    return sk, finish

# om command / am answer with strin
def data_7(line, got_bytes, sk, linelength, input_device):
    # sk: 0: len, 1: call
    # not used by LD: no input_as_parameter_list
    finish = 0
    if got_bytes >= sk[0]:
        if sk[1] == 0:
            # got memoryposition and length of string
            position_start = v_announcelist.length_of_full_elements
            position = misc_functions.bytes_to_int_ba(line[position_start:position_start + linelength[3]])
            if position <= linelength[2]:
                stringlength_start = v_announcelist.length_of_full_elements + linelength[6]
                lengh_of_string = misc_functions.bytes_to_int_ba(line[stringlength_start:stringlength_start + linelength[3]])
                if lengh_of_string <= linelength[5]:
                    sk[0] += lengh_of_string
                    sk[1] = 1
                else:
                    misc_functions.write_log("om stringlength too high:" + str(lengh_of_string) + " should be <=" + str(linelength[5]))
                    finish = 2
            else:
                misc_functions.write_log("ob memoryposition too high:" + str(position) + " should be <=" + str(linelength[2]))
                finish = 2
        elif sk[1] == 1:
            v_sk.orig_to_ld = v_sk.inputline[input_device]
            finish = 1
    return sk, finish
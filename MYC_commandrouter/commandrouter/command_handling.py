# name : command_handling.py
# command handling subprograms for SK
# this is mainly identical to ld_commandhandling


from cr_own_commands import *
from misc_functions import *
# from length_of_commandtypes import *

import time

import v_announcelist
import v_cr_params
import v_linelength
import v_dev
import v_ld
import v_sk
import v_token_params
import v_time_values


# ------------------------------------------------
# start of commandhandling
# ------------------------------------------------


def poll_input_buffer():
    """
This part is senstive to speed; so this part is optimzed for speed, not for servicability
The same is valid for the device_handling for answers and info:
- analyze_length part is not a separate sub
- This sub may be called by each character coming in or by more chracters, which are handled in one rush in this case
- With single characters it is more effective not to copy the array elements to a simple variable, which is more effective
    with multiple characters
"""
    input_device = 0
    # something received from SK ... ?
    while input_device < len(v_sk.inputline):
        line = v_sk.inputline[input_device]
        # if input data is correct and complete appropriate action is called
        if len(line) > 0:
            user = 0
            if v_sk.multiuser[input_device] == 1:
                if v_sk.user_active[input_device][int(line[0])] == 1:
                    # valid user needed for CR_own_commands
                    user = line[:1]
                    line = line[1:]
                else:
                    # no valid user
                    write_log("no valid user")
                    finish_sk_error(input_device, user)
                    input_device += 1
                    continue
            if line[0] == 0:
                # necessary to delete token:
                v_sk.linelength_len[input_device] = v_cr_params.length_commandtoken
                finish_sk(input_device, user, 1)
                input_device += 1
                continue
            else:
                to_cr = 0
                # commandtoken ready?
                got_bytes = len(line)
                if got_bytes >= v_cr_params.length_commandtoken:
                    tokennumber = int.from_bytes(line[0:v_cr_params.length_commandtoken], byteorder='big', signed=False)
                    if tokennumber < v_cr_params.number_of_commands_noCR:
                        # these are normal commands: subtract v_cr_params.startindex
                        tok = tokennumber - v_cr_params.startindex
                        # basic announcements of other devices have device 0 as destination they should not be sent via LD
                        if v_token_params.device[tok] == 0:
                            to_cr = 1
                            v_sk.linelength_len[input_device] = v_cr_params.length_commandtoken
                            finish_sk(input_device, user, to_cr)
                            input_device += 1
                            continue
                    else:
                        # try CR own commands &HxxFx
                        try:
                            # index of other CR commands (final tok)
                            tok = v_token_params.index_of_cr_commands[tokennumber]
                            # send to device 0 (CR)
                            to_cr = 1
                        except KeyError:
                            write_log("from SK: no valid commandtoken " + str(tokennumber))
                            v_sk.linelength_len[input_device] = 1
                            finish_sk_error(input_device, user)
                            input_device += 1
                            continue
                else:
                    input_device += 1
                    continue
            # tok is a valid index to CR-tokennumber based lists now
            line_length_index_0 = v_linelength.command[tok][0]
            if v_sk.linelength_loop[input_device] == 0:
                v_sk.linelength_len[input_device] = v_linelength.command[tok][1]
            if v_sk.starttime[input_device][user] == 0:
                # set time for timeout
                v_sk.starttime[input_device][user] = time.time()
# start switches, range commands and om, am numeric, all memory answer commands
            if line_length_index_0 == "1":
                while got_bytes >= v_sk.linelength_len[input_device]:
                    if v_linelength.command[tok][2] == 0:
                        # ready
                        finish_sk(input_device, user, to_cr)
                        input_device += 1
                        break
                    # startindex of block (of v_linelength.command[tok])
                    start = 4 + 3 * v_sk.linelength_loop[input_device]
                    if v_linelength.command[tok][start + 2] == 2:
                        # check parameter
                        parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][start + 1]:v_sk.linelength_len[input_device]])
                        if parameter > v_linelength.command[tok][start]:
                            error = "SK switch parameter value too high, loop:" + str(v_sk.linelength_loop[input_device]) + " " + str(parameter) + " " + str(v_linelength.command[tok][start])
                            write_log(error)
                            finish_sk_error(input_device, user)
                            input_device += 1
                            # exit "while loop"
                            break
                    v_sk.linelength_loop[input_device] += 1
                    if v_sk.linelength_loop[input_device] == v_linelength.command[tok][2]:
                        # all loops done
                        finish_sk(input_device, user, to_cr)
                        input_device += 1
                        break
                    else:
                        # add next linelength
                        v_sk.linelength_len[input_device] += v_linelength.command[tok][start + 4]
                else:
                    # not enough bytes
                    input_device += 1
# end switches, range commands and om, am numeric
# start om string: identical to "1", except for loop = 2
            elif line_length_index_0 == "2":
                while got_bytes >= v_sk.linelength_len[input_device]:
                    # startindex of block (of v_linelength.command[tok])
                    start = 4 + 3 * v_sk.linelength_loop[input_device]
                    if v_linelength.command[tok][start + 2] == 2:
                        # check parameter
                        parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][start + 1]:v_sk.linelength_len[input_device]])
                        if parameter > v_linelength.command[tok][start]:
                            error = "SK om string parameter value too high, loop:" + str(v_sk.linelength_loop[input_device]) + " " + str(parameter) + " " + str(v_linelength.command[tok][start])
                            write_log(error)
                            finish_sk_error(input_device, user)
                            input_device += 1
                            # exit "while loop"
                            break
                        # must be stored
                        v_sk.linelength_other[input_device] = parameter
                    v_sk.linelength_loop[input_device] += 1
                    if v_sk.linelength_loop[input_device] == v_linelength.command[tok][2]:
                        # all loops done
                        finish_sk(input_device, user, to_cr)
                        input_device += 1
                        break
                    else:
                        # add next linelength
                        if v_sk.linelength_loop[input_device] == 2:
                            v_sk.linelength_len[input_device] += v_sk.linelength_other[input_device]
                        else:
                            v_sk.linelength_len[input_device] += v_linelength.command[tok][start + 4]
                else:
                    # not enough bytes
                    input_device += 1
# end om string
# start on numeric
            elif line_length_index_0 == "3":
                while got_bytes >= v_sk.linelength_len[input_device]:
                    # startindex of block (of v_linelength.command[tok])
                    start = 4 + 3 * v_sk.linelength_loop[input_device]
                    if v_linelength.command[tok][start + 2] == 2:
                        # check parameter
                        parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][start + 1]:v_sk.linelength_len[input_device]])
                        if parameter > v_linelength.command[tok][start]:
                            error = "SK on numeric parameter value too high, loop:" + str(v_sk.linelength_loop[input_device]) + " " + str(parameter) + " " + str(v_linelength.command[tok][start])
                            write_log(error)
                            finish_sk_error(input_device, user)
                            input_device += 1
                            # exit "while loop"
                            break
                        if v_sk.linelength_loop[input_device] == 1:
                            # remember next length (number of elements * length of element
                            v_sk.linelength_other[input_device] = parameter * v_linelength.command[tok][start + 4]
                    v_sk.linelength_loop[input_device] += 1
                    if v_sk.linelength_loop[input_device] == v_linelength.command[tok][2]:
                        # all elements done
                        finish_sk(input_device, user, to_cr)
                        input_device += 1
                        break
                    else:
                        if v_sk.linelength_loop[input_device] == 2:
                            v_sk.linelength_len[input_device] += v_sk.linelength_other[input_device]
                        else:
                            # add next linelength (+3+2)
                            v_sk.linelength_len[input_device] += v_linelength.command[tok][start + 4]
                else:
                    # not enough bytes
                    input_device += 1
# end on numeric
# start on string
            elif line_length_index_0 == "4":
                while got_bytes >= v_sk.linelength_len[input_device]:
                    if v_sk.linelength_loop[input_device] == 0:
                        # check parameter of startelement
                        parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][5]:v_sk.linelength_len[input_device]])
                        if parameter > v_linelength.command[tok][4]:
                            error = "SK on startelement parameter value too high:" + str(parameter) + " " + str(v_linelength.command[tok][4])
                            write_log(error)
                            finish_sk_error(input_device, user)
                            input_device += 1
                            # exit "while loop"
                            break
                        v_sk.linelength_loop[input_device] = 1
                        # add length of elementnumber
                        v_sk.linelength_len[input_device] += v_linelength.command[tok][8]
                    if v_sk.linelength_loop[input_device] == 1:
                        # check parameter of number of elements
                        parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][8]:v_sk.linelength_len[input_device]])
                        if parameter == 0 or parameter > v_linelength.command[tok][7]:
                            error = "SK on number of elements parameter 0 or value too high:" + str(parameter) + " " + str(v_linelength.command[tok][7])
                            write_log(error)
                            finish_sk_error(input_device, user)
                            input_device += 1
                            # exit "while loop"
                            break
                        # remember number of elements
                        v_sk.linelength_other[input_device] = parameter
                        v_sk.linelength_loop[input_device] = 2
                        # add length of stringlength
                        v_sk.linelength_len[input_device] += v_linelength.command[tok][11]
                    elif v_sk.linelength_loop[input_device] == 2:
                        if v_sk.linelength_other[input_device] <= 0:
                            # all elements done
                            finish_sk(input_device, user, to_cr)
                            input_device += 1
                            break
                        else:
                            # add length of stringlength:
                            parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][11]:v_sk.linelength_len[input_device]])
                            if parameter > v_linelength.command[tok][10]:
                                error = "SK ob length of stringlenth parameter value too high:" + str(parameter) + " " + str(v_linelength.command[tok][10])
                                write_log(error)
                                finish_sk_error(input_device, user)
                                input_device += 1
                                # exit "while loop"
                                break
                            v_sk.linelength_len[input_device] += parameter
                            v_sk.linelength_loop[input_device] = 3
                    else:
                        # v_sk-linelength_loop == 3
                        v_sk.linelength_other[input_device] -= 1
                        if v_sk.linelength_other[input_device] <= 0:
                            # all elements done
                            finish_sk(input_device, user, to_cr)
                            input_device += 1
                            break
                        v_sk.linelength_len[input_device] += v_linelength.command[tok][11]
                        v_sk.linelength_loop[input_device] = 2
                else:
                    # not enough bytes
                    input_device += 1
# end on  string
# start of numeric
            elif line_length_index_0 == "5":
                if v_sk.starttime[input_device][user] == 0:
                    # set time for timeout
                    v_sk.starttime[input_device][user] = time.time()
                while got_bytes >= v_sk.linelength_len[input_device]:
                    # one check in loop 0 only
                    if v_sk.linelength_loop[input_device] == 0:
                        # check parameter
                        parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][5]:v_sk.linelength_len[input_device]])
                        if parameter > v_linelength.command[tok][4]:
                            error = "SK of numeric parameter value too high, loop:" + str(v_sk.linelength_loop[input_device]) + " " + str(parameter) + " " + str(v_linelength.command[tok][4])
                            write_log(error)
                            finish_sk_error(input_device, user)
                            input_device += 1
                            # exit "while loop"
                            break
                        # remember next length (number of elements * length of element
                        v_sk.linelength_other[input_device] = parameter * v_linelength.command[tok][8]

                    v_sk.linelength_loop[input_device] += 1
                    if v_sk.linelength_loop[input_device] == 2:
                        # all elements done
                        finish_sk(input_device, user, to_cr)
                        input_device += 1
                        break
                    else:
                        # v_sk.linelength_loop[input_device] == 1:
                        v_sk.linelength_len[input_device] += v_sk.linelength_other[input_device]
                else:
                    # not enough bytes
                    input_device += 1
# end of numeric
# start of string
            elif line_length_index_0 == "6":
                while got_bytes >= v_sk.linelength_len[input_device]:
                    # startindex of block (of v_linelength.command[tok])
                    start = 4 + 3 * v_sk.linelength_loop[input_device]
                    if v_linelength.command[tok][start + 2] == 2:
                        # check parameter
                        parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][start + 1]:v_sk.linelength_len[input_device]])
                        if parameter > v_linelength.command[tok][start]:
                            error = "SK of string parameter value too high, loop:" + str(v_sk.linelength_loop[input_device]) + " " + str(parameter) + " " + str(v_linelength.command[tok][start])
                            write_log(error)
                            finish_sk_error(input_device, user)
                            input_device += 1
                            # exit "while loop"
                            break
                        if v_sk.linelength_loop[input_device] == 0:
                            # remember number of elements
                            v_sk.linelength_other[input_device] = parameter
                        if v_sk.linelength_loop[input_device] == 1 or v_sk.linelength_loop[input_device] == 3:
                            # remember length of string
                            v_sk.linelength_other1[input_device] = parameter
                    v_sk.linelength_loop[input_device] += 1
                    if v_sk.linelength_loop[input_device] == 5:
                        v_sk.linelength_loop[input_device] = 3
                    # add next linelength
                    if v_sk.linelength_loop[input_device] == 1 or v_sk.linelength_loop[input_device] == 3:
                        if v_sk.linelength_loop[input_device] > 0:
                            if v_sk.linelength_other[input_device] < 1:
                                # all elements done
                                finish_sk(input_device, user, to_cr)
                                input_device += 1
                                break
                            v_sk.linelength_other[input_device] -= 1
                        # add length of stringlength
                        v_sk.linelength_len[input_device] += v_linelength.command[tok][8]
                    else:
                        # add length of string
                        v_sk.linelength_len[input_device] += v_sk.linelength_other1[input_device]
                else:
                    # not enough bytes
                    input_device += 1
# end of string
# start oa
            elif line_length_index_0 == "7":
                while got_bytes >= v_sk.linelength_len[input_device]:
                    if v_linelength.command[tok][2] == 0:
                        # 0: no position parameter
                        if v_linelength.command[tok][6] == 1:
                            # 1: numeric, no check, got all data
                            finish_sk(input_device, user, to_cr)
                            input_device += 1
                            break
                        else:
                            # 3: string
                            if v_sk.linelength_loop[input_device] == 1:
                                # all elements done
                                finish_sk(input_device, user, to_cr)
                                input_device += 1
                                break
                            if v_linelength.command[tok][6] == 3:
                                # check length of stringlength
                                parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][5]:v_sk.linelength_len[input_device]])
                                if parameter > v_linelength.command[tok][4]:
                                    error = "SK oa stringlength value too high, loop:" + str(v_sk.linelength_loop[input_device]) + " " + str(parameter) + " " + str(v_linelength.command[tok][4])
                                    write_log(error)
                                    finish_sk_error(input_device, user)
                                    input_device += 1
                                    # exit "while loop"
                                    break
                                v_sk.linelength_len[input_device] += parameter
                                v_sk.linelength_loop[input_device] += 1
                            else:
                                # numeric # all elements done
                                finish_sk(input_device, user, to_cr)
                                input_device += 1
                                break
                    else:
                        # 1 : with position parameter
                        if v_sk.linelength_loop[input_device] == 0:
                            parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][5]:v_sk.linelength_len[input_device]])
                            if parameter > v_linelength.command[tok][4]:
                                error = "SK oa / aa parameter value too high, loop:" + str(v_sk.linelength_loop[input_device]) + " " + str(parameter) + " " + str(v_linelength.command[tok][4])
                                write_log(error)
                                finish_sk_error(input_device, user)
                                input_device += 1
                                # exit "while loop"
                                break
                            # remember the element to transfer (position in v_linelength)
                            v_sk.linelength_other[input_device] = 7 + parameter * 3
                            # add length of numeric or length of stringlength
                            v_sk.linelength_len[input_device] += v_linelength.command[tok][8 + parameter * 3]
                        else:
                            # loop == 1 or == 2
                            if v_linelength.command[tok][v_sk.linelength_other[input_device] + 2] == 1:
                                # numeric, ready now
                                finish_sk(input_device, user, to_cr)
                                input_device += 1
                                break
                            else:
                                # string
                                if v_sk.linelength_loop[input_device] == 1:
                                    # check length of stringlength
                                    parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][5]:v_sk.linelength_len[input_device]])
                                    if v_sk.linelength_other1[input_device] > v_linelength.command[tok][4]:
                                        error = "SK oa / aa parameter value too high, loop:" + str(v_sk.linelength_loop[input_device]) + " " + str(v_sk.linelength_other[input_device]) + " " + str(v_linelength.command[tok][4])
                                        write_log(error)
                                        finish_sk_error(input_device, user)
                                        input_device += 1
                                        # exit "while loop"
                                        break
                                    v_sk.linelength_len[input_device] += parameter
                                else:
                                    # all elements done
                                    finish_sk(input_device, user, to_cr)
                                    input_device += 1
                                    break
                        v_sk.linelength_loop[input_device] += 1
                else:
                    # not enough bytes
                    input_device += 1
# end oa
# start ob
            elif line_length_index_0 == "8":
                while got_bytes >= v_sk.linelength_len[input_device]:
                    # startindex of block (of v_linelength.command[tok])
                    if v_sk.linelength_loop[input_device] == 0:
                        # check parameter of startelement
                        parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][5]:v_sk.linelength_len[input_device]])
                        if parameter > v_linelength.command[tok][4]:
                            error = "SK ob / ab startelement parameter value too high:" + str(parameter) + " " + str(v_linelength.command[tok][4])
                            write_log(error)
                            finish_sk_error(input_device, user)
                            input_device += 1
                            # exit "while loop"
                            break
                        # remember start elements
                        v_sk.linelength_other[input_device] = parameter
                        v_sk.linelength_loop[input_device] += 1
                        v_sk.linelength_len[input_device] += v_linelength.command[tok][5]
                    if v_sk.linelength_loop[input_device] == 1:
                        # check parameter of number of elements
                        parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][8]:v_sk.linelength_len[input_device]])
                        if parameter == 0 or parameter > v_linelength.command[tok][7]:
                            error = "SK ob / ab number of elements parameter 0 or value too high:" + str(parameter) + " " + str(v_linelength.command[tok][7])
                            write_log(error)
                            finish_sk_error(input_device, user)
                            input_device += 1
                            # exit "while loop"
                            break
                        # remember number of elements
                        v_sk.linelength_other1[input_device] = parameter
                        v_sk.linelength_loop[input_device] += 1
                        # add length of 1st element or length of stringlength; linelength_other == 0 start with position 10
                        v_sk.linelength_len[input_device] += v_linelength.command[tok][3 * v_sk.linelength_other[input_device] +11]
                        if v_linelength.command[tok][3 * v_sk.linelength_other[input_device] + 12] == 3:
                            # string
                            v_sk.linelength_loop[input_device] = 3
                    elif v_sk.linelength_loop[input_device] == 2:
                        v_sk.linelength_other1[input_device] -= 1
                        if v_sk.linelength_other1[input_device] <= 0:
                            # all elements done
                            finish_sk(input_device, user, to_cr)
                            input_device += 1
                            break
                        else:
                            # add numeric numeric or length of stringlength:
                            v_sk.linelength_other[input_device] += 1
                            if v_sk.linelength_other[input_device] == v_linelength.command[tok][4]:
                                # overflow
                                v_sk.linelength_other[input_device] = 0
                            start = 3 * v_sk.linelength_other[input_device] + 11
                            v_sk.linelength_len[input_device] += v_linelength.command[tok][start]
                            if v_linelength.command[tok][start + 1] == 3:
                                # string
                                v_sk.linelength_loop[input_device] = 3
                    else:
                        # v_sk.linelength_loop = 3, got length of stringlength
                        # check parameter
                        start = 10 + 3 * v_sk.linelength_other[input_device]
                        parameter = bytes_to_int_ba(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][start + 1]:v_sk.linelength_len[input_device]])
                        if parameter > v_linelength.command[tok][start]:
                            error = "SK ob / ab length of stringlenth parameter value too high:" + str(parameter) + " " + str(v_linelength.command[tok][start])
                            write_log(error)
                            finish_sk_error(input_device, user)
                            input_device += 1
                            # exit "while loop"
                            break
                        v_sk.linelength_len[input_device] += parameter
                        v_sk.linelength_loop[input_device] = 2
                else:
                    # not enough bytes
                    input_device += 1
# end ob
# start error
            elif line_length_index_0 == "0":
                # error, not valid, delete commandtoken
                write_log(" from SK: commandtoken with no action" + str(tok))
                v_sk.linelength_len[input_device] = v_cr_params.length_commandtoken
                finish_sk_error(input_device, user)
                input_device += 1
                break
# end error
        else:
            # linelength = 0:
            input_device += 1
# end of for loop
    return


def finish_sk(input_device, user, to_cr):
    # transfer data
    if user == 0:
        s = v_sk.inputline[input_device][:v_sk.linelength_len[input_device]]
    else:
        s = v_sk.inputline[input_device][1:v_sk.linelength_len[input_device] + 1]
    if to_cr == 0:
        if len(s) > 0:
            # send command to LD (string)
            v_ld.data_to_ld += ba_to_str2(s)
    else:
        # send to  v_dev.data_to_device[0] (CR)
        if len(s) > 0:
            v_dev.data_to_device[0][v_dev.writepointer[0]] = s
            v_dev.user[0][v_dev.writepointer[0]] = user
            v_dev.writepointer[0] += 1
            if v_dev.writepointer[0] >= v_configparameter.device_ringbuffersize:
                v_dev.writepointer[0] = 0

    # reset some values of v_sk after command finished
    v_sk.inputline[input_device] = v_sk.inputline[input_device][v_sk.linelength_len[input_device]:]
    v_sk.linelength_len[input_device] = 0
    v_sk.linelength_loop[input_device] = 0
    v_sk.starttime[input_device][user] = 0
    # avoid user timeout
    v_sk.user_timeout[input_device][user] = time.time()
    v_sk.linelength_other[input_device] = 0
    v_sk.linelength_other1[input_device] = 0
    if v_sk.user_active[input_device][user] == 2:
        # single User mode
        v_sk.user_active[input_device][user] = 0
    return


def finish_sk_error(input_device, user):
    # reset some values of v_sk after command finished
    v_sk.inputline[input_device] = v_sk.inputline[input_device][v_sk.linelength_len[input_device]:]
    v_sk.linelength_len[input_device] = 0
    v_sk.linelength_loop[input_device] = 0
    v_sk.starttime[input_device][user] = 0
    # avoid user timeout
    v_sk.linelength_other[input_device] = 0
    v_sk.linelength_other1[input_device] = 0
    # avoid user timeout
    v_sk.user_timeout[input_device][user] = time.time()
    if v_sk.user_active[input_device][user] == 2:
        # single User mode
        v_sk.user_active[input_device][user] = 0
    return

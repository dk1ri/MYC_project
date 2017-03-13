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
    for line in v_sk.inputline:
        # if input data is correct and complete appropriate action is called
        if len(line) > 0:
            user = 0
            to_cr = 0
            if v_sk.multiuser[input_device] == 0:
                pass
            elif v_sk.multiuser[input_device] == 1:
                if v_sk.user_active[input_device][int(line[0])] == 1:
                    # valid user needed for CR_own_commands
                    user = line[:1]
                    line = line[1:]
                else:
                    finish_sk_error(input_device, user)
            else:
                pass
            got_bytes = len(line)
            if line[0] == 0:
                # necessary to delete token:
                v_sk.linelength_len[input_device] = 1
                to_cr = 1
                finish_sk(input_device, user, to_cr)
                input_device += 1
                continue
            else:
                # commandtoken ready?
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
                            v_sk.last_error[input_device] = "no valid commandtoken " + str(tokennumber)
                            finish_sk_error(input_device, user)
                            input_device += 1
                            continue
                else:
                    input_device += 1
                    continue
            # tok is a valid index to CR-tokennumber based lists now
            if v_sk.starttime[input_device] == 0:
                # set time for timeout
                v_sk.starttime[input_device] = time.time()
            while got_bytes >= v_sk.linelength_len[input_device]:
                # if fist loop initialize buffers
                if v_sk.linelength_actual_call[input_device] == 0:
                    # set length for 1st loop
                    v_sk.linelength_len[input_device] = v_linelength.command[tok][1]
                    v_sk.linelength_actual_call[input_device] = 1
                else:
# start switches, range commands and numeric om, am
                    if v_linelength.command[tok][0] == "1":
                        if v_linelength.command[tok][2] == 0:
                            # got all
                            finish_sk(input_device, user, to_cr)
                            input_device += 1
                            break
                        else:
                            # check parameter , number of parameter + 2 -> index to v_linelength.command[tok]
                            error = 0
                            block = 0
                            temp = v_sk.linelength_len[input_device]
                            temp_new = temp
                            # index of 1 block (start)
                            par_index = 3
                            while block < v_linelength.command[tok][2]:
                                # add length
                                length = v_linelength.command[tok][par_index + 1]
                                temp_new += length
                                if v_linelength.command[tok][par_index] > 0:
                                    # skip check if 0
                                    if bytes_to_int_ba(line[temp:temp_new]) > v_linelength.command[tok][par_index]:
                                        v_sk.linelength_len[input_device] = temp_new
                                        finish_sk_error(input_device, user)
                                        error = "SK switch parameter value too high "
                                        write_log(error)
                                        error = 1
                                        break
                                block += 1
                                temp = temp_new
                                par_index += 2
                            if error == 0:
                                v_sk.linelength_len[input_device] = temp_new
                                finish_sk(input_device, user, to_cr)
                            input_device += 1
                            break
# end switches, range commands and numeric om, am. no real time length calculation
# start om / am string
                    elif v_linelength.command[tok][0] == "2":
                        if v_sk.linelength_actual_call[input_device] == 1:
                            # add extracted stringlength
                            temp = v_sk.linelength_len[input_device]
                            stringlength = int.from_bytes(line[temp - v_linelength.command[tok][6]:temp], byteorder='big', signed=False)
                            if stringlength > v_linelength.command[tok][5]:
                                # string overflow
                                finish_sk_error(input_device, user)
                                error = "SK stringlength overflow"
                                write_log(error)
                                input_device += 1
                                break
                            v_sk.linelength_len[input_device] += stringlength
                            v_sk.linelength_actual_call[input_device] = 2
                        else:
                            # actual_call == 2, got all data
                            # check parameter , number of parameter + 2 -> index to v_linelength.coomand[tok]
                            par_index = v_linelength.command[tok][2] + 2
                            temp = v_cr_params.length_commandtoken
                            tempnew = temp
                            while par_index < v_linelength.command[tok][2]:
                                # op and oo command
                                # position in ba
                                tempnew += v_linelength.command[tok][par_index + 1]
                                if bytes_to_int_ba(line[temp:tempnew]) > v_linelength.command[tok][par_index]:
                                    finish_sk_error(input_device, user)
                                    input_device += 1
                                    break
                                par_index += 1
                                temp = tempnew
                            finish_sk(input_device, user, to_cr)
                            input_device += 1
                            break
# end om / am string
# start on / an of / af
                    elif v_linelength.command[tok][0] == "3":
                        if v_sk.linelength_actual_call[input_device] == 1:
                            # check startelement and number of elements for operate and answer command
                            # commandtoken:
                            temp1 = v_cr_params.length_commandtoken
                            # check elements and startpositiion
                            temp2 = temp1 + v_linelength.command[tok][3]
                            startposition = int.from_bytes(line[temp1:temp2], byteorder='big', signed=False)
                            if startposition > v_linelength.command[tok][2]:
                                finish_sk_error(input_device, user)
                                error = " SK on / an startposition value too high " + str(startposition) + " " + str(v_linelength.command[tok][2])
                                write_log(error)
                                input_device += 1
                                break
                            else:
                                if v_linelength.command[tok][7] == 0:
                                    # on / an
                                    # add length of number of elements
                                    temp1 = temp2 + v_linelength.command[tok][3]
                                    elements = int.from_bytes(line[temp2:temp1], byteorder='big', signed=False)
                                    if elements > v_linelength.command[tok][2]:
                                        finish_sk_error(input_device, user)
                                        error = "SK on / an element value too high" + elements + " " + v_linelength.command[tok][2]
                                        write_log(error)
                                        input_device += 1
                                        break
                                else:
                                    # of / af: there is no startposition
                                    elements = startposition
                            # values correct now
                            if v_linelength.command[tok][6] == 0:
                                # numeric:
                                if v_linelength.answer[tok][0] != "0":
                                    # answer command :finished
                                    finish_sk(input_device, user, to_cr)
                                    input_device += 1
                                    break
                                else:
                                    # operate command
                                    # add elements * length of element
                                    v_sk.linelength_len[input_device] += elements * v_linelength.command[tok][5]
                                    v_sk.linelength_actual_call[input_device] = 2
                            else:
                                # string:
                                if v_linelength.answer[tok][0] != "0":
                                    # answer command finished
                                    finish_sk(input_device, user, to_cr)
                                    input_device += 1
                                    break
                                else:
                                    # operate command
                                    v_sk.linelength_other[input_device] = elements
                                    v_sk.linelength_len[input_device] += v_linelength.command[tok][5]
                                    v_sk.linelength_actual_call[input_device] = 3
                        elif v_sk.linelength_actual_call[input_device] == 2:
                            # got everything: numeric operate
                            finish_sk(input_device, user, to_cr)
                            input_device += 1
                            break
                        elif v_sk.linelength_actual_call[input_device] == 3:
                            # string: extract stringlength
                            temp2 = v_sk.linelength_len[input_device]
                            temp1 = temp2 - v_linelength.command[tok][5]
                            stringlength = int.from_bytes(line[temp1:temp2], byteorder='big', signed=False)
                            if stringlength > v_linelength.command[tok][4]:
                                finish_sk_error(input_device, user)
                                error = "string overflow"
                                write_log(error)
                                input_device += 1
                                break
                            v_sk.linelength_len[input_device] += stringlength
                            v_sk.linelength_actual_call[input_device] = 4
                        elif v_sk.linelength_actual_call[input_device] == 4:
                            # actual element
                            v_sk.linelength_other[input_device] -= 1
                            if v_sk.linelength_other[input_device] == 0:
                                # finish
                                finish_sk(input_device, user, to_cr)
                                input_device += 1
                                break
                            else:
                                # add length of stringlength
                                v_sk.linelength_len[input_device] += v_linelength.command[tok][3]
                                v_sk.linelength_actual_call[input_device] = 3
# end on / an of / af
# start oa / aa
                    elif v_linelength.command[tok][0] == "4":
                        if v_sk.linelength_actual_call[input_device] == 1:
                            # got commandtoken + memoryposition
                            # memoryposition
                            position = 0
                            if v_linelength.command[tok][3] > 0:
                                # position transmitted
                                position = int.from_bytes(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][3]:v_sk.linelength_len[input_device]], byteorder='big', signed=False)
                                if position > v_linelength.command[tok][2]:
                                    finish_sk_error(input_device, user)
                                    error = " SK oa/aa value too high" + str(position) + " " + str(v_linelength.command[tok][2])
                                    write_log(error)
                                    input_device += 1
                                    break
                            # data correct
                            if v_linelength.answer[tok][0] != "0":
                                # answer command, got all
                                finish_sk(input_device, user, to_cr)
                                input_device += 1
                                break
                            else:
                                # operate command, add length of <ty> or length of sringlength
                                v_sk.linelength_len[input_device] += v_linelength.command[tok][3 * position + 5]
                                v_sk.linelength_other[input_device] = position
                                if v_linelength.command[tok][3 * position + 6] == 0:
                                    # numeric
                                    v_sk.linelength_actual_call[input_device] = 2
                                else:
                                    # string
                                    v_sk.linelength_actual_call[input_device] = 3
                        elif v_sk.linelength_actual_call[input_device] == 2:
                            # finish numeric
                            finish_sk(input_device, user, to_cr)
                            input_device += 1
                            break
                        elif v_sk.linelength_actual_call[input_device] == 3:
                            # got stringlength now
                            # stringlength:
                            stringlength = int.from_bytes(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][3* position + 6]:v_sk.linelength_len[input_device]], byteorder='big', signed=False)
                            if stringlength > v_linelength.command[tok][3 * v_sk.linelength_other[input_device] + 4]:
                                # string overflow
                                finish_sk_error(input_device, user)
                                error = "stringlength overflow"
                                write_log(error)
                                input_device += 1
                                break
                            # add number of bytes of string
                            v_sk.linelength_len[input_device] += stringlength
                            v_sk.linelength_actual_call[input_device] = 4
                        elif v_sk.linelength_actual_call[input_device] == 4:
                            finish_sk(input_device, user, to_cr)
                            input_device += 1
                            break
# end oa / aa
# start ob / ab
                    elif v_linelength.command[tok][0] == "5":
                        if v_sk.linelength_actual_call[input_device] == 1:
                            # got commandtoken (+ startpos + number of elements)
                            temp1 = v_cr_params.length_commandtoken
                            # check elements and startpositiion
                            temp2 = temp1 + v_linelength.command[tok][3]
                            startposition = int.from_bytes(line[temp1:temp2], byteorder='big', signed=False)
                            if startposition > v_linelength.command[tok][2]:
                                finish_sk_error(input_device, user)
                                error = "SK ob /ab startposition value too high"
                                write_log(error)
                                input_device += 1
                                break
                            else:
                                # add length of number of elements
                                temp1 = temp2 + v_linelength.command[tok][3]
                                elements = int.from_bytes(line[temp2:temp1], byteorder='big', signed=False)
                                if elements > v_linelength.command[tok][2]:
                                    finish_sk_error(input_device, user)
                                    error = "SK ob /ab element value too high" + str(elements) + " " + str(v_linelength.command[tok][2])
                                    write_log(error)
                                    input_device += 1
                                    break
                            # startnumber and elements correct
                            if v_linelength.answer[tok][0] != "0":
                                # answer command, got all
                                finish_sk(input_device, user, to_cr)
                                input_device += 1
                                break
                            else:
                                # operate command
                                if elements > 0:
                                    #  add length of <ty> or length of sringlength of first element
                                    # 2nd element (1) of n block 3 *n + 4 + 1 (n 0...x)
                                    v_sk.linelength_len[input_device] += v_linelength.command[tok][3 * startposition + 5]
                                    # remember position
                                    # v_linelength.answer block number for startnumenr and number of elements
                                    v_sk.linelength_other[input_device] = startposition
                                    v_sk.linelength_other1[input_device] = elements
                                    # 3rd element (2) of n block 3 *n + 1 + 2
                                    if v_linelength.command[tok][3 * startposition + 6] == 0:
                                        # numeric
                                        v_sk.linelength_actual_call[input_device] = 2
                                    else:
                                        # string
                                        v_sk.linelength_actual_call[input_device] = 4
                                else:
                                    finish_sk(input_device, user, to_cr)
                                    input_device += 1
                                    break
                        elif v_sk.linelength_actual_call[input_device] == 2:

                            # got numeric element
                            # elements:
                            v_sk.linelength_other1[input_device] -= 1
                            if v_sk.linelength_other1[input_device] == 0:
                                # finish numeric
                                finish_sk(input_device, user, to_cr)
                                input_device += 1
                                break
                            else:
                                # memory position
                                v_sk.linelength_other[input_device] += 1
                                if v_sk.linelength_other[input_device] > v_linelength.command[tok][2]:
                                    # memory position overflow
                                    v_sk.linelength_other[input_device] = 0
                                # add length of <ty> or length of linelength
                                v_sk.linelength_len[input_device] += v_linelength.command[tok][3 * v_sk.linelength_other[input_device] + 5]
                                if v_linelength.command[tok][3 * v_sk.linelength_other[input_device] + 6] == 1:
                                    # string
                                    v_sk.linelength_actual_call[input_device] = 4
                                # else: v_sk.linelength_actual_call[input_device] = 2
                        elif v_sk.linelength_actual_call[input_device] == 4:
                            # got length of next element string or numeric
                            stringlength = int.from_bytes(line[v_sk.linelength_len[input_device] - v_linelength.command[tok][3]:v_sk.linelength_len[input_device]], byteorder='big', signed=False)
                            if v_linelength.command[tok][3 * v_sk.linelength_other[input_device] + 6] == 1:
                                # string
                                if stringlength > v_linelength.command[tok][3 * v_sk.linelength_other[input_device] + 4]:
                                    # string overflow
                                    finish_sk_error(input_device, user)
                                    error = "SK ob / ab stringlength overflow "
                                    write_log(error)
                                    input_device += 1
                                    break
                            # add number of bytes of string
                            v_sk.linelength_len[input_device] += stringlength
                            v_sk.linelength_actual_call[input_device] = 5
                        elif v_sk.linelength_actual_call[input_device] == 5:
                            v_sk.linelength_other1[input_device] -= 1
                            if v_sk.linelength_other1[input_device] == 0:
                                # elements done
                                finish_sk(input_device, user, to_cr)
                                input_device += 1
                                break
                            else:
                                # get length of next element
                                # increment position in v_linelength
                                v_sk.linelength_other[input_device] += 1
                                if v_sk.linelength_other[input_device] > v_linelength.command[tok][2]:
                                    v_sk.linelength_other[input_device] = 0
                                stringlength = v_linelength.command[tok][3 * v_sk.linelength_other[input_device] + 5]
                                if v_linelength.command[tok][3 * v_sk.linelength_other[input_device] + 6] == 1:
                                    # string
                                    if stringlength > v_linelength.command[tok][3 * v_sk.linelength_other[input_device] + 4]:
                                        # string overflow
                                        finish_sk_error(input_device, user)
                                        error = "stringlength overflow "
                                        write_log(error)
                                        input_device += 1
                                        break
                                v_sk.linelength_len[input_device] += stringlength
                                if v_linelength.command[tok][3 * v_sk.linelength_other[input_device] + 6] == 0:
                                    # next element numeric
                                    v_sk.linelength_actual_call[input_device] = 2
                                else:
                                    v_sk.linelength_actual_call[input_device] = 4
# end ob / ab
# start error
                    elif v_linelength.command[tok][0] == "0":
                        # error, not valid, delete commandtoken
                        write_log(" from SK: no valid commandtoken " + str(tok))
                        finish_sk_error(input_device, user)
                        input_device += 1
                        break
# end error
        input_device += 1
    return


def finish_sk(input_device, user, to_cr):
    # transfer data
    if to_cr == 0:
        # send command to LD (string)
        v_ld.data_to_ld += ba_to_str2(v_sk.inputline[input_device][:v_sk.linelength_len[input_device]])
    else:
        # send to  v_dev.data_to_device[0] (CR)
        s = v_sk.inputline[input_device][:v_sk.linelength_len[input_device]]
        if len(s) > 0:
            v_dev.data_to_device[0][v_dev.writepointer[0]] = s
            v_dev.user[0][v_dev.writepointer[0]] = user
            v_dev.writepointer[0] += 1
            if v_dev.writepointer[0] >= v_configparameter.device_ringbuffersize:
                v_dev.writepointer[0] = 0

    # reset some values of v_sk after command finished
    v_sk.inputline[input_device] = v_sk.inputline[input_device][v_sk.linelength_len[input_device]:]
    v_sk.linelength_len[input_device] = 0
    v_sk.linelength_actual_call[input_device] = 0
    v_sk.starttime[input_device] = 0
    # avoid user timeout
    v_sk.user_timeout[input_device][user] = time.time()
    if v_sk.user_active == 2:
        # single User mode
        v_sk.user_active = 0
    return


def finish_sk_error(input_device, user):
    # reset some values of v_sk after command finished
    v_sk.inputline[input_device] = v_sk.inputline[input_device][v_sk.linelength_len[input_device]:]
    v_sk.linelength_len[input_device] = 0
    v_sk.linelength_actual_call[input_device] = 0
    v_sk.starttime[input_device] = 0
    # avoid user timeout
    v_sk.user_timeout[input_device][user] = time.time()
    if v_sk.user_active == 2:
        # single User mode
        v_sk.user_active = 0
    return

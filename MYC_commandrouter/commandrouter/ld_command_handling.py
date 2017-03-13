# name : ld_command_handling.py
# command handling subprograms
# this is mainly identical to commandhandling (for SK)


from cr_own_commands import *
from misc_functions import *
# from length_of_commandtypes import *

import time

import v_announcelist
import v_cr_params
import v_dev
import v_linelength
import v_ld
import v_ld
import v_token_params
import v_time_values


# ------------------------------------------------
# start of commandhandling
# ------------------------------------------------


def poll_ld():
    """
This part is senstive to speed; so this part is optimzed for speed, not for servicability
The same is valid for the device_handling for answers and info:
- analyze_length part is not a separate sub
- This sub may be called by each character coming in or by more chracters, which are handled in one rush in this case
- With single characters it is more effective not to copy the array elements to a simple variable, which is more effective
    with multiple characters
"""
    # something received from LD ... ?
    # v_cr_params.length_commandtoken + 1 (for 0xff / 0xfe) necessary
    if len(v_ld.data_to_cr) > v_cr_params.length_commandtoken:
        # a command is sent, strip command /info identifier
        to_def = int(v_ld.data_to_cr[0] - 0xfd)
        line = v_ld.data_to_cr[1:]
        got_bytes = len(line)
        if line[0] == 0:
            # CR basic announcement request for LD,  answer sent directly with added stringlength (1 byte)
            if v_ld.ld_available == 1:
                v_ld.data_to_ld = add_length_to_str(v_announcelist.full[0], 1)
            # necessary to delete token
            v_ld.linelength_len = 1
            finish_ld(0, 2, to_def)
            return
        else:
            # commandtoken ready?
            if got_bytes >= v_cr_params.length_commandtoken:
                tokennumber = int.from_bytes(line[0:v_cr_params.length_commandtoken], byteorder='big', signed=False)
                if tokennumber < v_cr_params.number_of_commands_noCR:
                    # for token > 0 and < v_cr_params.number_of_commands_noCR: subtract v_cr_params.startnumber
                    # token for other devices
                    tok = tokennumber - v_cr_params.startindex
                else:
                    # try CR own commands &HxxFx
                    try:
                        # index of other CR commands (final tok)
                        tok = v_cr_params.index_of_cr_commands[tokennumber]
                    except KeyError:
                        v_ld.last_error = "no valid commandtoken " + str(tokennumber)
                        finish_ld(0, 1, to_def)
            else:
                return
        # tok is a valid index to CR-tokennumber based lists now
        if v_ld.starttime == 0:
            # set time for timeout
            v_ld.starttime = time.time()
        while got_bytes >= v_ld.linelength_len:
            # if fist loop initialize buffers
            if v_ld.linelength_actual_call == 0:
                # set length for 1st loop
                v_ld.linelength_len = v_linelength.command[tok][1]
                v_ld.linelength_actual_call = 1
            else:
# start switches, range commNDS and numeric om, am. no real time length calculation
                if v_linelength.command[tok][0] == "1":
                    if v_linelength.command[tok][2] == 0:
                        # got all
                        finish_ld(tok, 0, 1)
                        break
                    else:
                        error = 0
                        # check parameter , number of parameter + 2 -> index to v_linelength.command[tok]
                        block = 0
                        temp = v_ld.linelength_len
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
                                    v_ld.linelength_len = temp_new
                                    finish_ld(tok, 1, 1)
                                    error = "LD switch parameter value too high"
                                    write_log(error)
                                    error = 1
                                    break
                            block += 1
                            temp = temp_new
                            par_index += 2
                        if error == 0:
                            v_ld.linelength_len = temp_new
                            finish_ld(tok, 0, 1)
                        break
# end switches, oq and numeric om, am. no real time length calculation
# start om / am string
                elif v_linelength.command[tok][0] == "2":
                    if v_ld.linelength_actual_call == 1:
                        # add extracted stringlength
                        temp = v_ld.linelength_len
                        stringlength = int.from_bytes(line[temp - v_linelength.command[tok][6]:temp], byteorder='big', signed=False)
                        if stringlength > v_linelength.command[tok][5]:
                            # string overflow
                            finish_ld(tok, 2, to_def)
                            error = "LD om / am stringlength overflow"
                            write_log(error)
                            break
                        v_ld.linelength_len += stringlength
                        v_ld.linelength_actual_call = 2
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
                                finish_ld(tok, 2, to_def)
                                break
                            par_index += 1
                            temp = tempnew
                        finish_ld(tok, 0, to_def)
                        break
# end om / am string
# start on / an of / af
                elif v_linelength.command[tok][0] == "3":
                    if v_ld.linelength_actual_call == 1:
                        # check startelement and number of elements for operate and answer command
                        # commandtoken:
                        temp1 = v_cr_params.length_commandtoken
                        # check elements and startpositiion
                        temp2 = temp1 + v_linelength.command[tok][3]
                        startposition = int.from_bytes(line[temp1:temp2], byteorder='big', signed=False)
                        if startposition > v_linelength.command[tok][2]:
                            finish_ld(tok, 2, to_def)
                            error = "LD on / an startposition value too high " + str(startposition) + " " + str(v_linelength.command[tok][2])
                            write_log(error)
                            break
                        else:
                            if v_linelength.command[tok][7] == 0:
                                # on / an
                                # add length of number of elements
                                temp1 = temp2 + v_linelength.command[tok][3]
                                elements = int.from_bytes(line[temp2:temp1], byteorder='big', signed=False)
                                if elements > v_linelength.command[tok][2]:
                                    finish_ld(tok, 2, to_def)
                                    error = "LD on / an element value too high" + elements + " " + v_linelength.command[tok][2]
                                    write_log(error)
                                    break
                            else:
                                # of / af: there is no startposition
                                elements = startposition
                        # values correct now
                        if v_linelength.command[tok][6] == 0:
                            # numeric:
                            if v_linelength.answer[tok][0] != "0":
                                # answer command :finished
                                # remember elements write to device
                                v_dev.linelength_other[v_token_params.device[tok]] = elements
                                finish_ld(tok, 0, to_def)
                                break
                            else:
                                # operate command
                                # add elements * length of element
                                v_ld.linelength_len += elements * v_linelength.command[tok][5]
                                v_ld.linelength_actual_call = 2
                        else:
                            # string:
                            if v_linelength.answer[tok][0] != "0":
                                # answer command finished
                                # remember the elements to follow
                                v_dev.linelength_other[v_token_params.device[tok]] = elements
                                finish_ld(tok, 0, to_def)
                                break
                            else:
                                # operate command
                                v_ld.linelength_other = elements
                                v_ld.linelength_len += v_linelength.command[tok][5]
                                v_ld.linelength_actual_call = 3
                    elif v_ld.linelength_actual_call == 2:
                        # got everything: numeric operate
                        finish_ld(tok, 0, to_def)
                        break
                    elif v_ld.linelength_actual_call == 3:
                        # string: extract stringlength
                        temp2 = v_ld.linelength_len
                        temp1 = temp2 - v_linelength.command[tok][5]
                        stringlength = int.from_bytes(line[temp1:temp2], byteorder='big', signed=False)
                        if stringlength > v_linelength.command[tok][4]:
                            finish_ld(tok, 2, to_def)
                            error = "LD on / an string overflow"
                            write_log(error)
                            break
                        v_ld.linelength_len += stringlength
                        v_ld.linelength_actual_call = 4
                    elif v_ld.linelength_actual_call == 4:
                        # actual element
                        v_ld.linelength_other -= 1
                        if v_ld.linelength_other == 0:
                            # finish
                            finish_ld(tok, 0, to_def)
                            break
                        else:
                            # add length of stringlength
                            v_ld.linelength_len += v_linelength.command[tok][3]
                            v_ld.linelength_actual_call = 3
# end on / an of / af
# start oa / aa
                elif v_linelength.command[tok][0] == "4":
                    if v_ld.linelength_actual_call == 1:
                        # got commandtoken + memoryposition
                        # memoryposition
                        position = 0
                        if v_linelength.command[tok][3] > 0:
                            # position transmitted
                            position = int.from_bytes(line[v_ld.linelength_len - v_linelength.command[tok][3]:v_ld.linelength_len], byteorder='big', signed=False)
                            if position > v_linelength.command[tok][2]:
                                finish_ld(tok, 1, to_def)
                                error = "LD oa / aa value too high" + str(position) + " " + str(v_linelength.command[tok][2])
                                write_log(error)
                                break
                        # data correct
                        if v_linelength.answer[tok][0] != "0":
                            # answer command, got all
                            # remember position
                            if v_linelength.command[tok][2] > 0:
                                # v_linelength.answer block number
                                v_dev.linelength_other[v_token_params.device[tok]] = position
                            finish_ld(tok, 0, to_def)
                            break
                        else:
                            # operate command, add length of <ty> or length of sringlength
                            v_ld.linelength_len += v_linelength.command[tok][3 * position + 5]
                            v_ld.linelength_other = position
                            if v_linelength.command[tok][3 * position + 6] == 0:
                                # numeric
                                v_ld.linelength_actual_call = 2
                            else:
                                # string
                                v_ld.linelength_actual_call = 3
                    elif v_ld.linelength_actual_call == 2:
                        # finish numeric
                        finish_ld(tok, 0, to_def)
                        break
                    elif v_ld.linelength_actual_call == 3:
                        # got stringlength now
                        # stringlength:
                        stringlength = int.from_bytes(line[v_ld.linelength_len - v_linelength.command[tok][3 * position + 6]:v_ld.linelength_len], byteorder='big', signed=False)
                        if stringlength > v_linelength.command[tok][3 * v_ld.linelength_other + 4]:
                            # string overflow
                            finish_ld(tok, 2, to_def)
                            error = "LD oa / aa stringlength overflow"
                            write_log(error)
                            break
                        # add number of bytes of string
                        v_ld.linelength_len += stringlength
                        v_ld.linelength_actual_call = 4
                    elif v_ld.linelength_actual_call == 4:
                        finish_ld(tok, 0, to_def)
                        break
# end oa / aa
# start ob / ab
                elif v_linelength.command[tok][0] == "5":
                    if v_ld.linelength_actual_call == 1:
                        # got commandtoken (+ startpos + number of elements)
                        # startposition and elements available
                        temp1 = v_cr_params.length_commandtoken
                        # check elements and startpositiion
                        temp2 = temp1 + v_linelength.command[tok][3]
                        startposition = int.from_bytes(line[temp1:temp2], byteorder='big', signed=False)
                        if startposition > v_linelength.command[tok][2]:
                            finish_ld(tok, 2, to_def)
                            error = "LD ob / ab startposition value too high"
                            write_log(error)
                            break
                        else:
                            # add length of number of elements
                            temp1 = temp2 + v_linelength.command[tok][3]
                            elements = int.from_bytes(line[temp2:temp1], byteorder='big', signed=False)
                            if elements > v_linelength.command[tok][2]:
                                finish_ld(tok, 2, to_def)
                                error = "LD ob / ab element value too high" + str(elements) + " " + str(v_linelength.command[tok][2])
                                write_log(error)
                                break
                        # position data correct
                        if v_linelength.answer[tok][0] != "0":
                            # answer command, got all
                            # remember position
                            # v_linelength.answer block number (0...) and number of elements
                            v_dev.linelength_other[v_token_params.device[tok]] = startposition
                            v_dev.linelength_other1[v_token_params.device[tok]] = elements
                            finish_ld(tok, 0, to_def)
                            break
                        else:
                            # operate command
                            if elements > 0:
                                #  add length of <ty> or length of sringlength of first element
                                # 2nd element (1) of n block 3 *n + 4 + 1 (n 0...x)
                                v_ld.linelength_len += v_linelength.command[tok][3 * startposition + 5]
                                # remember position
                                # v_linelength.answer block number for startnumenr and number of elements
                                v_ld.linelength_other = startposition
                                v_ld.linelength_other1 = elements
                                # 3rd element (2) of n block 3 *n + 1 + 2
                                if v_linelength.command[tok][3 * startposition + 6] == 0:
                                    # numeric
                                    v_ld.linelength_actual_call = 2
                                else:
                                    # string
                                    v_ld.linelength_actual_call = 3
                            else:
                                finish_ld(tok, 0, to_def)
                                break
                    elif v_ld.linelength_actual_call == 2:
                        # got numeric element
                        # elements:
                        v_ld.linelength_other1 -= 1
                        if v_ld.linelength_other1 == 0:
                            # finish numeric
                            finish_ld(tok, 0, to_def)
                            break
                        else:
                            # startposition
                            v_ld.linelength_other += 1
                            if v_ld.linelength_other > v_linelength.command[tok][2]:
                                # overflow
                                v_ld.linelength_other = 0
                            # add length of <ty> or length of linelength
                            v_ld.linelength_len += v_linelength.command[tok][3 * v_ld.linelength_other + 5]
                            if v_linelength.command[tok][3 * v_ld.linelength_other + 6] == 1:
                                # string
                                v_ld.linelength_actual_call = 3
                            # else: v_ld.linelength_actual_call = 2
                    elif v_ld.linelength_actual_call == 3:
                        # add stringlength
                        v_ld.linelength_actual_call = 4
                    elif v_ld.linelength_actual_call == 4:
                        # got length of next element string or numeric
                        stringlength = int.from_bytes(line[v_ld.linelength_len - v_linelength.command[tok][3]:v_ld.linelength_len], byteorder='big', signed=False)
                        if v_linelength.command[tok][3 * v_ld.linelength_other + 6] == 1:
                            # striing
                            if stringlength > v_linelength.command[tok][3 * v_ld.linelength_other + 4]:
                                # string overflow
                                finish_ld(tok, 2, to_def)
                                error = "LD ob / ab stringlength overflow "
                                write_log(error)
                                break
                        # add number of bytes of string
                        v_ld.linelength_len += stringlength
                        v_ld.linelength_actual_call = 5
                    elif v_ld.linelength_actual_call == 5:
                        v_ld.linelength_other1 -= 1
                        if v_ld.linelength_other1 == 0:
                            # elements done
                            finish_ld(tok, 0, to_def)
                            break
                        else:
                            # get length of next element
                            # increment position in v_linelength
                            v_ld.linelength_other += 1
                            if v_ld.linelength_other > v_linelength.command[tok][2]:
                                v_ld.linelength_other = 0
                            stringlength = v_linelength.command[tok][3 * v_ld.linelength_other + 5]
                            if v_linelength.command[tok][3 * v_ld.linelength_other + 6] == 1:
                                # string
                                if stringlength > v_linelength.command[tok][3 * v_ld.linelength_other + 4]:
                                    # string overflow
                                    finish_ld(tok, 2, to_def)
                                    error = "LD ob / ab stringlength overflow "
                                    write_log(error)
                                    break
                            v_ld.linelength_len += stringlength
                            if v_linelength.command[tok][3 * v_ld.linelength_other + 6] == 0:
                                # next element numeric
                                v_ld.linelength_actual_call = 2
                            else:
                                v_ld.linelength_actual_call = 3
# end ob / ab
# start error
                else:
                    # wrong data
                    v_ld.linelength_len = len(v_ld.data_to_cr)
                    finish_ld(tok, 1, to_def)
# end error
        else:
            # wrong data
            v_ld.data_to_cr = bytearray([])
    return


def finish_ld(tok, error, to_def):
    if error == 0:
        if to_def == 1:
            # send command to devicebuffer:
            # retranslate CR token to device-token -> bytearray
            ba = int_to_ba(v_token_params.dev_token[tok], v_cr_params.length_commandtoken)
            # add params
            v_ld.data_to_cr = v_ld.data_to_cr[1:]
            ba.extend(v_ld.data_to_cr[v_cr_params.length_commandtoken:v_ld.linelength_len])
            device = v_token_params.device[tok]
            # write to next element of ringbuffer
            v_dev.data_to_device[device][v_dev.writepointer[device]] = ba
            v_dev.writepointer[device] += 1
            if v_dev.writepointer[device] >= v_configparameter.device_ringbuffersize:
                v_dev.writepointer[device] = 0
        elif to_def == 2:
            # to SK
            v_sk.info_to_all.extend(v_ld.data_to_cr[1:])
        elif to_def == 0:
            # to CR
            v_dev.data_to_device[0][v_dev.writepointer[0]] = v_ld.data_to_cr[1:]
            v_dev.writepointer[0] += 1
            if v_dev.writepointer[0] > v_configparameter.device_ringbuffersize:
                v_dev.writepointer[0] = 0
    # else error == 2 : do nothing
    # called, before answer arrives
    # reset some values of v_ld after command finished
    v_ld.data_to_cr = v_ld.data_to_cr[v_ld.linelength_len:]
    v_ld.linelength_len = 0
    v_ld.linelength_actual_call = 0
    # starttime
    v_ld.starttime = 0
    return

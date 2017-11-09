"""
name : ld_command_handling.py
last edited: 1711
command handling subprograms
this is mainly identical to commandhandling (for SK)
"""

from cr_own_commands import *
from misc_functions import *

import v_announcelist
import v_cr_params
import v_dev
import v_linelength
import v_ld
import v_token_params


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
    with multiple characterscr
"""
    # something received from LD ... ?
    # v_cr_params.length_commandtoken + 1 (for 0xff / 0xfe) necessary
    if len(v_ld.data_to_cr) > 0:
        # a command is sent, strip command /info identifier to_def
        to_def = int(v_ld.data_to_cr[0] - 0xfd)
        line = v_ld.data_to_cr[1:]
        if len(line) > 0:
            if line[0] == 0:
                # CR basic announcement request for LD,  answer sent directly with added stringlength (1 byte)
                if v_ld.ld_available == 1:
                    v_ld.data_to_ld = add_length_to_str(v_announcelist.full[0], 1)
                # necessary to delete token
                v_ld.linelength_len = 1
                finish_ld(0, 2, to_def)
                return
            else:
                got_bytes = len(line)
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
                            tok = v_token_params.index_of_cr_commands[tokennumber]
                        except KeyError:
                            error = "LD no valid commandtoken " + str(tokennumber)
                            write_log(error)
                            v_ld.linelength_len = v_cr_params.length_commandtoken
                            finish_ld(0, 1, to_def)
                            return
                else:
                    return
                # tok is a valid index to CR-tokennumber based lists now
                line_length_index_0 = v_linelength.command[tok][0]
                if v_ld.linelength_loop == 0:
                    v_ld.linelength_len = v_linelength.command[tok][1]
# start switches, range commands and numeric om, am
                if line_length_index_0 == "1":
                    while got_bytes >= v_ld.linelength_len:
                        if v_linelength.command[tok][2] == 0:
                            # ready
                            finish_ld(tok, 0, to_def)
                            break
                        # startindex of block (of v_linelength.command[tok])
                        start = 4 + 3 * v_ld.linelength_loop
                        if v_linelength.command[tok][start + 2] == 2:
                            # check parameter
                            parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][start + 1]:v_ld.linelength_len])
                            if parameter > v_linelength.command[tok][start]:
                                finish_ld(tok, 1, to_def)
                                error = "LD switch parameter value too high, loop:" + str(v_ld.linelength_loop) + " " + str(parameter) + " " + str(v_linelength.command[tok][start])
                                write_log(error)
                                # exit while loop
                                break
                        v_ld.linelength_loop += 1
                        if v_ld.linelength_loop == v_linelength.command[tok][2]:
                            # all loops done
                            finish_ld(tok, 0, to_def)
                            break
                        else:
                            # add next linelength
                            v_ld.linelength_len += v_linelength.command[tok][start + 4]
                    else:
                        # not enough bytes
                        pass
# end switches, range commands and numeric om, am
# start om string, identical to "1" except loop = 2
                elif line_length_index_0 == "2":
                    while got_bytes >= v_ld.linelength_len:
                        # startindex of block (of v_linelength.command[tok])
                        start = 4 + 3 * v_ld.linelength_loop
                        if v_linelength.command[tok][start + 2] == 2:
                            # check parameter
                            parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][start + 1]:v_ld.linelength_len])
                            if parameter > v_linelength.command[tok][start]:
                                finish_ld(tok, 1, to_def)
                                error = "LD om / am parameter value too high, loop:" + str(v_ld.linelength_loop) + " " + str(parameter) + " " + str(v_linelength.command[tok][start])
                                write_log(error)
                                # exit while loop
                                break
                            # must be stored
                            v_ld.linelength_other = parameter
                        v_ld.linelength_loop += 1
                        if v_ld.linelength_loop == v_linelength.command[tok][2]:
                            # all loops done
                            finish_ld(tok, 0, to_def)
                            break
                        else:
                            # add next linelength
                            if v_ld.linelength_loop == 2:
                                v_ld.linelength_len += v_ld.linelength_other
                            else:
                                v_ld.linelength_len += v_linelength.command[tok][start + 4]
                    else:
                        # not enough bytes
                        pass
# end om string
# start on numeric
                elif line_length_index_0 == "3":
                    while got_bytes >= v_ld.linelength_len:
                        # startindex of block (of v_linelength.command[tok])
                        start = 4 + 3 * v_ld.linelength_loop
                        if v_linelength.command[tok][start + 2] == 2:
                            # check parameter
                            parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][start + 1]:v_ld.linelength_len])
                            if parameter > v_linelength.command[tok][start]:
                                finish_ld(tok, 1, to_def)
                                error = "LD switch parameter value too high, loop:" + str(v_ld.linelength_loop) + " " + str(parameter) + " " + str(v_linelength.command[tok][start])
                                write_log(error)
                                # exit while loop
                                break
                            if v_ld.linelength_loop == 1:
                                # remember next length (number of elements * length of element
                                v_ld.linelength_other = parameter * v_linelength.command[tok][start + 4]

                        v_ld.linelength_loop += 1
                        if v_ld.linelength_loop == v_linelength.command[tok][2]:
                            # all loops done
                            finish_ld(tok, 0, to_def)
                            break
                        else:
                            if v_ld.linelength_loop == 2:
                                v_ld.linelength_len += v_ld.linelength_other
                            else:
                                # add next linelength (+3+2)
                                v_ld.linelength_len += v_linelength.command[tok][start + 4]
                    else:
                        # not enough bytes
                        pass
# end on numeric
# start on string
                elif line_length_index_0 == "4":
                    while got_bytes >= v_ld.linelength_len:
                        if v_ld.linelength_loop == 0:
                            # check parameter
                            parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][5]:v_ld.linelength_len])
                            if parameter > v_linelength.command[tok][4]:
                                error = "LD on / an startelemt parameter value too high:" + " " + str(parameter) + " " + str(v_linelength.command[tok][4])
                                write_log(error)
                                finish_ld(tok, 1, to_def)
                                # exit "while loop"
                                break
                            v_ld.linelength_loop = 1
                            v_ld.linelength_len += v_linelength.command[tok][8]
                        if v_ld.linelength_loop == 1:
                            # check parameter
                            parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][8]:v_ld.linelength_len])
                            if parameter > v_linelength.command[tok][7]:
                                error = "LD on / an number of elements parameter value too high:" + str(parameter) + " " + str(v_linelength.command[tok][7])
                                write_log(error)
                                finish_ld(tok, 1, to_def)
                                # exit "while loop"
                                break
                            # remember number of elements
                            v_ld.linelength_other = parameter
                            v_ld.linelength_loop = 2
                            v_ld.linelength_len += v_linelength.command[tok][11]
                        elif v_ld.linelength_loop == 2:
                            if v_ld.linelength_other <= 0:
                                # all elements done
                                finish_ld(tok, 0, to_def)
                                break
                            else:
                                # add length of stringlength:
                                parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][11]:v_ld.linelength_len])
                                if parameter > v_linelength.command[tok][10]:
                                    error = "LD ob / ab length of stringlenth parameter value too high:" + str(parameter) + " " + str(v_linelength.command[tok][10])
                                    write_log(error)
                                    finish_ld(tok, 1, to_def)
                                    # exit "while loop"
                                    break
                                v_ld.linelength_loop = 3
                                v_ld.linelength_len += parameter
                        else:
                            # v_ld.linelength_loop == 3
                            v_ld.linelength_other -= 1
                            if v_ld.linelength_other <= 0:
                                # all elements done
                                finish_ld(tok, 0, to_def)
                                break
                            v_ld.linelength_loop = 2
                            v_ld.linelength_len += v_linelength.command[tok][11]
                    else:
                        # not enough bytes
                        pass
# end on string
# start of numeric
                elif line_length_index_0 == "5":
                    while got_bytes >= v_ld.linelength_len:
                        # one check in loop 0 only
                        if v_ld.linelength_loop == 0:
                            # check parameter
                            parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][5]:v_ld.linelength_len])
                            if parameter > v_linelength.command[tok][4]:
                                finish_ld(tok, 1, to_def)
                                error = "LD of parameter value too high, loop:" + str(v_ld.linelength_loop) + " " + str(parameter) + " " + str(v_linelength.command[tok][4])
                                write_log(error)
                                # exit while loop
                                break
                            if v_ld.linelength_loop == 0:
                                # remember next length (number of elements * length of element
                                v_ld.linelength_other = parameter * v_linelength.command[tok][8]

                        v_ld.linelength_loop += 1
                        # if v_ld.linelength_loop == v_linelength.command[tok][2]:
                        if v_ld.linelength_loop == 2:
                            # all loops done
                            finish_ld(tok, 0, to_def)
                            break
                        else:
                            # v_ld.linelength_loop == 1:
                            v_ld.linelength_len += v_ld.linelength_other
                    else:
                        # not enough bytes
                        pass
# end of numeric
# start of string
                elif line_length_index_0 == "6":
                    while got_bytes >= v_ld.linelength_len:
                        # startindex of block (of v_linelength.command[tok])
                        start = 4 + 3 * v_ld.linelength_loop
                        if v_linelength.command[tok][start + 2] == 2:
                            # check parameter
                            parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][
                                start + 1]:v_ld.linelength_len])
                            if parameter > v_linelength.command[tok][start]:
                                finish_ld(tok, 1, to_def)
                                error = "LD switch parameter value too high, loop:" + str(
                                    v_ld.linelength_loop) + " " + str(parameter) + " " + str(
                                    v_linelength.command[tok][start])
                                write_log(error)
                                # exit while loop
                                break
                            if v_ld.linelength_loop == 0:
                                # remember number of elements
                                v_ld.linelength_other = parameter
                            if v_ld.linelength_loop == 1 or v_ld.linelength_loop == 3:
                                # remember stringlength
                                v_ld.linelength_other1 = parameter
                        v_ld.linelength_loop += 1
                        if v_ld.linelength_loop == 5:
                            v_ld.linelength_loop = 3
                        # add next linelength
                        if v_ld.linelength_loop == 1 or v_ld.linelength_loop == 3:
                            if v_ld.linelength_loop > 0:
                                if v_ld.linelength_other < 1:
                                    # all loops done
                                    finish_ld(tok, 0, to_def)
                                    break
                                v_ld.linelength_other -= 1
                            # add length of stringlength
                            v_ld.linelength_len += v_linelength.command[tok][8]
                        else:
                            # v_ld.linelength_loop == 2 or == 4
                            # add length of string
                            v_ld.linelength_len += v_ld.linelength_other1
                    else:
                        # not enough bytes
                        pass
# end of string
# start oa
                elif v_linelength.command[tok][0] == "7":
                    while got_bytes >= v_ld.linelength_len:
                        if v_linelength.command[tok][2] == 0:
                            # no position parameter
                            if v_linelength.command[tok][6] == 1:
                                # numeric, no check, got all data
                                finish_ld(tok, 0, to_def)
                                break
                            else:
                                # string
                                if v_ld.linelength_loop == 1:
                                    # all elements done
                                    finish_ld(tok, 0, to_def)
                                    break
                                if v_linelength.command[tok][6] == 3:
                                    # check length of stringlength
                                    parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][5]:v_ld.linelength_len])
                                    if parameter > v_linelength.command[tok][4]:
                                        error = "LD oa / aa stringlength value too high, loop:" + str(v_ld.linelength_loop) + " " + str(parameter) + " " + str(v_linelength.command[tok][4])
                                        write_log(error)
                                        finish_ld(tok, 1, to_def)
                                        # exit "while loop"
                                        break
                                    v_ld.linelength_len += parameter
                                    v_ld.linelength_loop += 1
                                else:
                                    # all elements done
                                    finish_ld(tok, 0, to_def)
                                    break
                        else:
                            # with position parameter
                            if v_ld.linelength_loop == 0:
                                v_ld.linelength_len = v_linelength.command[tok][1]
                                parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][5]:v_ld.linelength_len])
                                if parameter > v_linelength.command[tok][4]:
                                    error = "LD oa / aa parameter value too high, loop:" + str(v_ld.linelength_loop) + " " + str(parameter) + " " + str(v_linelength.command[tok][4])
                                    write_log(error)
                                    finish_ld(tok, 1, to_def)
                                    # exit "while loop"
                                    break
                                # remember the element to transfer (position in v_linelength)
                                v_ld.linelength_other = 4 + parameter * 3
                                # add length of numeric or length of stringlength
                                v_ld.linelength_len += v_linelength.command[tok][5 + parameter * 3]
                            else:
                                # loop == 1 or == 2
                                if v_linelength.command[tok][v_ld.linelength_other + 2] == 1:
                                    # numeric, ready now
                                    finish_ld(tok, 0, to_def)
                                    break
                                else:
                                    # string
                                    if v_ld.linelength_loop == 1:
                                        # check length of stringlength
                                        parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][5]:
                                        v_ld.linelength_len])
                                        if v_ld.linelength_other1 > v_linelength.command[tok][4]:
                                            error = "LD oa / aa parameter value too high, loop:" + str(v_ld.linelength_other) + " " + str(v_linelength.command[tok][4])
                                            write_log(error)
                                            finish_ld(tok, 1, to_def)
                                            # exit "while loop"
                                            break
                                        v_ld.linelength_len += parameter
                                    else:
                                        # all elements done
                                        finish_ld(tok, 0, to_def)
                                        break
                            v_ld.linelength_loop += 1
                    else:
                        # not enough bytes
                        pass
# end oa
# start ob
                elif v_linelength.command[tok][0] == "8":
                    while got_bytes >= v_ld.linelength_len:
                        # startindex of block (of v_linelength.command[tok])
                        if v_ld.linelength_loop == 0:
                            # check parameter
                            parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][5]:v_ld.linelength_len])
                            if parameter > v_linelength.command[tok][4]:
                                error = "LD ob / ab startelemt parameter value too high:" + " " + str(parameter) + " " + str(v_linelength.command[tok][4])
                                write_log(error)
                                finish_ld(tok, 1, to_def)
                                # exit "while loop"
                                break
                            # remember start elements
                            v_ld.linelength_other = parameter
                            v_ld.linelength_loop = 1
                            v_ld.linelength_len += v_linelength.command[tok][5]
                        if v_ld.linelength_loop == 1:
                            # check parameter
                            parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][8]:v_ld.linelength_len])
                            if parameter > v_linelength.command[tok][7]:
                                error = "LD ob / ab number of elements parameter value too high:" + str(parameter) + " " + str(v_linelength.command[tok][7])
                                write_log(error)
                                finish_ld(tok, 1, to_def)
                                # exit "while loop"
                                break
                            # remember number of elements
                            v_ld.linelength_other1 = parameter
                            v_ld.linelength_loop = 2
                            v_ld.linelength_len += v_linelength.command[tok][3 * v_ld.linelength_other + 11]
                            if v_linelength.command[tok][3 * v_ld.linelength_other + 12] == 3:
                                # string
                                v_ld.linelength_loop = 3
                        elif v_ld.linelength_loop == 2:
                            v_ld.linelength_other1 -= 1
                            if v_ld.linelength_other1 <= 0:
                                # all elements done
                                finish_ld(tok, 0, to_def)
                                break
                            else:
                                # add numeric numeric or length of stringlength:
                                v_ld.linelength_other += 1
                                if v_ld.linelength_other == v_linelength.command[tok][4]:
                                    # overflow
                                    v_ld.linelength_other = 0
                                start = 3 * v_ld.linelength_other + 11
                                if v_linelength.command[tok][start + 1] == 3:
                                    # string
                                    v_ld.linelength_loop = 3
                                v_ld.linelength_len += v_linelength.command[tok][start]
                        else:
                            # v_ld.linelength_loop = 3, got length of stringlength
                            # check parameter
                            start = 10 + 3 * v_ld.linelength_other
                            parameter = bytes_to_int_ba(line[v_ld.linelength_len - v_linelength.command[tok][start + 1]:v_ld.linelength_len])
                            if parameter > v_linelength.command[tok][start]:
                                error = "LD ob / ab length of stringlenth parameter value too high:" + str(parameter) + " " + str(v_linelength.command[tok][start])
                                write_log(error)
                                finish_ld(tok, 1, to_def)
                                # exit "while loop"
                                break
                            v_ld.linelength_loop = 2
                            v_ld.linelength_len += parameter
# end ob
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
    v_ld.linelength_loop = 0
    v_ld.linelength_other = 0
    v_ld.linelength_other1 = 0
    v_ld.linelength_other2 = 0
    return

"""
name : command_handling.py
last edited: 1803
command handling subprograms for SK
"""

from cr_own_commands import *
from misc_functions import *
from data_handling import  *
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
This part is senstive to speed; so this part is optimized for speed, not for serviceability
- This sub may be called by each character coming in or by more chracters, which are handled in one rush in this case
"""
    input_device = 0
    # something received from SK ... ?
    while input_device < len(v_sk.inputline):
        line = v_sk.inputline[input_device]
        # if input data is correct and complete appropriate action is called
        if len(line) > 0:

            # check for basic command
            if line[0] == 0:
                # directly answered, not sent to LD
                announce_line = "0" + str(len(v_announcelist.full[0])) + v_announcelist.full[0]
                v_sk.info_to_all.extend(str_to_bytearray(announce_line))
                # necessary to delete token:
                v_sk.len[input_device][0] = v_cr_params.length_commandtoken
                finish = 2
            else:
                # commandtoken ready?
                got_bytes = len(line)
                if got_bytes >= v_cr_params.length_commandtoken:
                    tokennumber = int.from_bytes(line[0:v_cr_params.length_commandtoken], byteorder='big', signed=False)
                    if tokennumber < v_cr_params.number_of_commands_noCR:
                        # these are normal commands: subtract v_cr_params.startindex
                        tok = tokennumber - v_cr_params.startindex
                        # basic announcements of other devices have device 0 as destination they should not be sent via LD
                        if v_token_params.device[tok] == 0:
                            # other basic commands, directly answered, not sent to LD
                            tok = int.from_bytes(line[:v_cr_params.length_commandtoken], byteorder='big', signed=False)
                            index = v_token_params.announcements[tok]
                            announce_line = str(tok) + str(len(v_announcelist.full[index])) + v_announcelist.full[index]
                            v_sk.info_to_all.extend(str_to_bytearray(announce_line))
                            # necessary to delete token:
                            v_sk.len[input_device][0] = v_cr_params.length_commandtoken
                            finish = 1
                        else:
                            # normal command
                            # tok is a valid index to CR-tokennumber based lists now
                            # get "type" (0 - 4, 9)
                            line_length_index_0 = v_linelength.command[tok][0]
                            # after getting the commandtoken v_sk[input_device][0]  (loop) is 0
                            if v_sk.len[input_device][1] == 0:
                                # get the number of bytes for the fist loop
                                v_sk.len[input_device][0] = v_linelength.command[tok][1]
                                # set time for timeout
                                v_sk.starttime[input_device] = time.time()

                            # some switches, no parameters
                            if line_length_index_0 == "0":
                                v_sk.len[input_device][0] = v_cr_params.length_commandtoken
                                finish = 1

                            # switches, range commands, om / am, an, on numeric: all parameters numeric and fixed
                            elif line_length_index_0 == "1":
                                v_sk.len[input_device], finish = data_1(line, got_bytes, v_sk.len[input_device],v_linelength.command[tok])

                            # on string
                            elif line_length_index_0 == "2":
                                v_sk.len[input_device], finish = data_2(line, got_bytes, v_sk.len[input_device],v_linelength.command[tok])
                            # oa
                            elif line_length_index_0 == "3":
                                v_sk.len[input_device], finish = data_3(line, got_bytes, v_sk.len[input_device],v_linelength.command[tok])
                            # ob
                            elif line_length_index_0 == "4":
                                v_sk.len[input_device], finish = data_4(line, got_bytes, v_sk.len[input_device],v_linelength.command[tok])
                            # no action
                            elif line_length_index_0 == "5":
                                v_sk.len[input_device][0] = v_cr_params.length_commandtoken
                                finish = 2
                    else:
                        if tokennumber < v_cr_params.start_of_reserved_token:
                            write_log("command not valid " + str(tokennumber))
                            v_sk.len[input_device][0] = v_cr_params.length_commandtoken
                            finish = 2
                        else:
                            # reserved commands
                            # extact token to int:
                            token = int.from_bytes(line[:v_cr_params.length_commandtoken], byteorder='big',signed=False)
                            # call associated programm
                            try:
                                finish = cr_own[token](line, token, input_device)
                            except KeyError:
                                write_log("reserved command not valid " + str(tokennumber))
                                v_sk.len[input_device][0] = v_cr_params.length_commandtoken
                                finish = 2

            if finish == 0:
                pass
            elif finish == 1:
                finish_sk(input_device)
            else:
                clear_sk(input_device)
        input_device += 1

    return


def finish_sk(input_device):
    # transfer data
    # send command to LD as listelement containing data for one command
    # add  0xfe: CR -> LD -> device
    a = bytearray([0xfe])
    a[1:] = v_sk.inputline[input_device][:v_sk.len[input_device][0]]
    v_ld.data_to_ld.extend(a)
    # reset some values of v_sk after command finished
    v_sk.inputline[input_device] = v_sk.inputline[input_device][v_sk.len[input_device][0]:]
    v_sk.len[input_device] = [0,0,0,0,0]
    v_sk.starttime[input_device] = 0
    # avoid channel timeout
    if v_sk.multi_channel == 1:
        v_sk.channel_timeout[input_device] = time.time()
    if len(v_sk.inputline[input_device]) > v_cr_params.sk_buffer_limit_low:
        if len(v_sk.inputline[input_device]) > v_cr_params.sk_buffer_limit:
            v_sk.active[input_device] = 2
    else:
        v_sk.active[input_device] = 1
    return


def clear_sk(input_device):
    # reset some values of v_sk after command finished
    v_sk.inputline[input_device] = v_sk.inputline[input_device][v_sk.len[input_device][0]:]
    v_sk.len[input_device] = [0, 0, 0, 0, 0]
    v_sk.starttime[input_device] = 0
    # avoid channel timeout
    if v_sk.multi_channel == 1:
        v_sk.channel_timeout[input_device] = time.time()
    return

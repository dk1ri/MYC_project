"""
name : ld_command_handling.py
last edited: 1711
command handling subprograms
this is mainly identical to commandhandling (for SK)
"""

from cr_own_commands import *
from misc_functions import *
from data_handling import *

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
    # something received from LD ... ?
    # v_cr_params.length_commandtoken + 1 (for 0xfd, 0xfe, 0xff) necessary
    if len(v_ld.data_to_cr) > v_cr_params.length_commandtoken:
        # a command is sent, strip command / info identifier to_def
        #  to_def is the direction marker
        # fd: LD to / from CR (Busy command)
        # fe: CR -> LD -> device
        # ff: device -> LD -> SK
        to_def = int(v_ld.data_to_cr[0])
        if to_def > 0xfc:
            line = v_ld.data_to_cr[1:]
            finish = 0
            got_bytes = len(line)
            # there are no CR on tokens
            tokennumber = int.from_bytes(line[0:v_cr_params.length_commandtoken], byteorder='big', signed=False)
            if tokennumber < v_cr_params.number_of_commands_noCR:
                tok = tokennumber - v_cr_params.startindex
                # tok is a valid index to CR-tokennumber based lists now
                # get "type" (0 - 5)
                line_length_index_0 = v_linelength.command[tok][0]
                # after getting the commandtoken v_ld.linelength_loop[input_device] is 0
                if v_ld.len[0] == 0:
                    # get the number of bytes for the fist loop
                    v_ld.len[0] = v_linelength.command[tok][1]
# some switches, no parameters
                if line_length_index_0 == "0":
                    v_ld.len[0] = v_cr_params.length_commandtoken
                    finish = 1
# switches, range commands and om, am numeric, all paramters numeric and fixed
                elif line_length_index_0 == "1":
                    v_ld.len, finish = data_1(line, got_bytes, v_ld.len,v_linelength.command[tok])

# on string
                elif line_length_index_0 == "2":
                    v_ld.len, finish = data_2(line, got_bytes, v_ld.len, v_linelength.command[tok])

# oa
                elif line_length_index_0 == "3":
                    v_ld.len, finish = data_3(line, got_bytes, v_ld.len, v_linelength.command[tok])

# ob
                elif line_length_index_0 == "4":
                    v_ld.len, finish = data_4(line, got_bytes, v_ld.len, v_linelength.command[tok])

    # error
                else:
                    # wrong data
                    v_ld.len[0] = len(v_ld.data_to_cr)
                    finish = 2
            else:
                # should not happen, LD send normal commands only
                v_ld.len[0] = v_cr_params.length_commandtoken
                write_log("LD sent wrong command "+ str(tokennumber))
                finish = 2

            if finish == 0:
                pass
            else:
                if finish == 1:
                    # no error
                    if to_def == 0xfe:
                        # send command to devicebuffer:
                        # retranslate CR token to device-token -> bytearray
                        ba = int_to_ba(v_token_params.dev_token[tok], v_cr_params.length_commandtoken)
                        # add params
                        # v_ld_len[0] is calculated using line -> + 1
                        ba.extend(v_ld.data_to_cr[1 + v_cr_params.length_commandtoken:v_ld.len[0] + 1])
                        device = v_token_params.device[tok]
                        # append next element ba contain exactly one complete command
                        # using a list (append instead of extend), makes it easier to to send per command to dev
                        # if device do not support command caching
                        v_dev.data_to_device[device].append(ba)
                    elif to_def == 0xff:
                        # to SK
                        v_sk.info_to_all.extend(v_ld.data_to_cr[1:v_ld.len[0] + 1])
                    elif to_def == 0xfd:
                        # to CR
                        v_dev.data_to_device[0].append(v_ld.data_to_cr[1:])
                # else finish == 2 : error
                # reset some values of v_ld after command finished
                v_ld.data_to_cr = v_ld.data_to_cr[v_ld.len[0] + 1:]

                v_ld.len = [0, 0, 0, 0, 0]
        else:
            # wrong direction marker, delete it
            write_log("wrong direction identifier from LD")
            v_ld.data_to_cr = v_ld.data_to_cr[1:]
    return

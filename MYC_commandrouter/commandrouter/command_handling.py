"""
name : command_handling.py
last edited: 202512
command handling subprograms for SK
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""

from cr_own_commands import *
from data_handling import  *

import time
import v_announcelist
import v_cr_params
import v_linelength
import v_ld
import v_sk
import v_token_params


# ------------------------------------------------
# start of commandhandling
# ------------------------------------------------


def poll_input_buffer():
    """
This part is sensitive to speed; so this part is optimized for speed, not for serviceability
- This sub may be called by each character coming in or by more chracters, which are handled in one rush in this case
"""
    # input are bytes
    input_device = 0
    # something received from SK ... ?
    while input_device < len(v_sk.inputline):
        finish = 0
        line = v_sk.inputline[input_device]
        # if input data is correct and complete appropriate action is called
        if len(line) > 0:
            # check for basic command
            if line[0] == 0:
                # CR basic command: directly answered, not sent to LD
                announce_line = chr(0) + chr(len(v_announcelist.full[0])) + v_announcelist.full[0]
                v_sk.info_to_all += str_to_bytearray(announce_line)
                # necessary to delete token:
                v_sk.len[input_device][0] = v_announcelist.length_of_full_elements
                finish = 10
            else:
                got_bytes = len(line)
                if got_bytes >= v_announcelist.length_of_full_elements:
                    tok = int.from_bytes(line[:v_announcelist.length_of_full_elements], byteorder='big', signed=False)
                    if tok >= v_announcelist.start_of_reserved_token:
                        # reserved CR commands
                        if tok == v_announcelist.start_of_reserved_token:
                            finish = com240(tok, line[v_announcelist.length_of_full_elements:], input_device)
                        else:
                            finish = 2
                    else:
                        if not(tok in v_announcelist.all_token):
                                print ("unvalid")
                                finish = 2
                        else:
                            announce_line = v_announcelist.full[tok]
                            ct = announce_line[1]
                            if ct == "m" or ct == "c":
                                # other basic commands, directly answered, not sent to LD
                                v_sk.info_to_all += str_to_bytearray(hex(v_announcelist.start_of_cr_token))
                                v_sk.info_to_all += str_to_bytearray(hex(len(announce_line)))
                                v_sk.info_to_all += str_to_bytearray(";".join(announce_line))
                                # necessary to delete token:
                                v_sk.len[input_device][0] = v_announcelist.length_of_full_elements
                                finish = 10
                            else:
                                # normal command
                                # get "type" (0 - 9)
                                line_length_index_0 = v_linelength.command[tok][0]
                                # after getting the commandtoken v_sk[input_device][0]  (loop) is 0
                                if v_sk.len[input_device][1] == 0:
                                    # get the number of bytes for the fist loop
                                    v_sk.len[input_device][0] = v_linelength.command[tok][1]
                                    # set time for timeout
                                    v_sk.starttime[input_device] = time.time()
                                # some switches, no parameters
                                if line_length_index_0 == "0":
                                    v_sk.len[input_device][0] = v_announcelist.length_of_full_elements
                                    finish = 1
                                # switches, range commands, om / am, an, on numeric: all parameters numeric and fixed
                                elif line_length_index_0 == "1":
                                    v_sk.len[input_device], finish = data_1(line, got_bytes, v_sk.len[input_device],v_linelength.command[tok])
                                # on
                                elif line_length_index_0 == "2":
                                    v_sk.len[input_device], finish = data_2(line, got_bytes, v_sk.len[input_device],v_linelength.command[tok])
                                # oa
                                elif line_length_index_0 == "3":
                                    v_sk.len[input_device], finish = data_3(line, got_bytes, v_sk.len[input_device],v_linelength.command[tok])
                                # of
                                elif line_length_index_0 == "4":
                                    v_sk.len[input_device], finish = data_4(line, got_bytes, v_sk.len[input_device],v_linelength.command[tok])
                                # ob
                                elif line_length_index_0 == "5":
                                    v_sk.len[input_device], finish = data_5(line, got_bytes, v_sk.len[input_device],v_linelength.command[tok])
                                # ob one element string
                                elif line_length_index_0 == "6":
                                    v_sk.len[input_device], finish = data_6(line, got_bytes, v_sk.len[input_device],v_linelength.command[tok])
                                elif line_length_index_0 == "7":
                                    v_sk.len[input_device], finish = data_7(line, got_bytes, v_sk.len[input_device],v_linelength.command[tok])

            if finish == 0:
                pass
            elif finish == 1:
                finish_sk(input_device, 1)
            elif finish == 10:
                finish_sk(input_device, 0)
            else:
                # some error
                clear_sk(input_device)
        input_device += 1
    return

def clear_sk(input_device):
    # reset some values of v_sk after error
    v_sk.inputline[input_device] = []
    v_sk.len[input_device] = [0, 0, 0, 0, 0, 0, 0]
    v_sk.starttime[input_device] = 0
    # avoid channel timeout
 #   if v_sk.multi_channel == 1:
    v_sk.channel_timeout[input_device] = time.time()
    return

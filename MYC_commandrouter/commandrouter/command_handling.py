"""
name : command_handling.py
last edited: 20240414
command handling subprograms for SK
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""

from cr_own_commands import *
from data_handling import *

import time
import v_announcelist
import v_linelength
import v_sk
from ld_buffer_handling import ld_analyze


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
        line_of_input_device = v_sk.inputline[input_device]
        # if input data is correct and complete appropriate action is called
        if len(line_of_input_device) > 0:
            # check for basic command
            if line_of_input_device[0] == [0]:
                finish = cr_own(0, input_device)
            else:
                got_bytes = len(line_of_input_device)
                if got_bytes >= v_announcelist.length_of_full_elements:
                    tok = int.from_bytes(line_of_input_device[:v_announcelist.length_of_full_elements], byteorder='big', signed=False)
                    if not(tok in v_announcelist.all_token):
                        misc_functions.write_log ("unvalid token: " + str(tok))
                        finish = 2
                    else:
                        if tok in v_announcelist.cr_token:
                            # answered by CR
                            finish = cr_own(tok, input_device)
                        else:
                            # normal command
                            # get "type" (0 - 7)
                            # after getting the commandtoken v_sk[input_device].len[0] (wait) is 0
                            if v_sk.data_len[input_device][0] == 0:
                                # get the number of bytes for the fist loop
                                v_sk.data_len[input_device][0] = v_linelength.command[tok][1]
                                # set time for timeout
                                v_sk.starttime[input_device] = time.time()
                            if got_bytes >= v_sk.data_len[input_device][0]:
                                match  v_linelength.command[tok][0]:
                                    case 0:
                                        # some switches, no parameters
                                        finish = data_0(got_bytes, v_sk.data_len[input_device], input_device)
                                    case 1:
                                        # switches, range commands, om / am, an, on numeric: all parameters numeric and fixed
                                        v_sk.data_len[input_device], finish = data_1(tok, line_of_input_device, got_bytes, v_sk.data_len[input_device],v_linelength.command[tok], input_device)
                                    case 2:
                                        # on
                                        v_sk.data_len[input_device], finish = data_2(line_of_input_device, got_bytes, v_sk.data_len[input_device],v_linelength.command[tok], input_device)
                                    case 3:
                                        # oa
                                        v_sk.data_len[input_device], finish = data_3(tok, line_of_input_device, got_bytes, v_sk.data_len[input_device],v_linelength.command[tok], input_device)
                                    case 4:
                                        # of
                                        v_sk.data_len[input_device], finish = data_4(line_of_input_device, got_bytes, v_sk.data_len[input_device],v_linelength.command[tok], input_device)
                                    case 5:
                                        # ob
                                        v_sk.data_len[input_device], finish = data_5(line_of_input_device, got_bytes, v_sk.data_len[input_device],v_linelength.command[tok], input_device)
                                    case 6:
                                        # ob one element string
                                        v_sk.data_len[input_device], finish = data_6(line_of_input_device, got_bytes, v_sk.data_len[input_device],v_linelength.command[tok], input_device)
                                    case 7:
                                        v_sk.data_len[input_device], finish = data_7(line_of_input_device, got_bytes, v_sk.data_len[input_device], v_linelength.command[tok], input_device)
            if finish == 0:
                pass
            elif finish == 1:
                # ld_analyze must be called for each input buffer individually
                if v_sk.orig_to_ld != []:
                    ld_analyze()
                finish_sk(input_device)
            elif finish == 10:
                finish_sk(input_device)
            else:
                # some error
                clear_sk(input_device)
        input_device += 1
    return

def clear_sk(input_device):
    # reset some values of v_sk after error
    v_sk.inputline[input_device] = bytearray()
    v_sk.input_as_parameter_list = []
    v_sk.orig_to_ld = []
    v_sk.data_len[input_device] = [0, 0, 0, 0, 0, 0, 0]
    v_sk.starttime[input_device] = 0
    # avoid channel timeout
 #   if v_sk.multi_channel == 1:
    v_sk.channel_timeout[input_device] = time.time()
    return

def finish_sk(input_device):
    # transfer data
    # send command to LD as listelement containing data for one command (original hex)
    # reset some values of v_sk after command finished
    v_sk.inputline[input_device] = bytearray()
    v_sk.data_len[input_device] = [0,0,0,0,0,0,0]
    v_sk.starttime[input_device] = 0
    # avoid channel timeout
 #   if v_sk.multi_channel == 1:
  #      v_sk.channel_timeout[input_device] = time.time()
  #  if len(v_sk.inputline[input_device]) > v_cr_params.sk_buffer_limit_low:
   #     if len(v_sk.inputline[input_device]) > v_cr_params.sk_buffer_limit:
    #        v_sk.active[input_device] = 2
   # else:
    #    v_sk.active[input_device] = 1
    return
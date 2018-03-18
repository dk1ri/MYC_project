"""
name : device_handling.py
last edited: 1802
devicehandling subprograms
analyzes the answers and info and transfer to SK devices buffers
"""

#from cr_own_commands import *
from misc_functions import *
from data_handling import *

import v_linelength
import v_dev


def poll_device_buffer():
    # analyze data from device for completeness to transfer to SK
    # the input may occur in a way, that more than one loop are necessary to finish
    # or a answer or info may be complete immediately. in this case, the handling should be completed
    # before switching to the next device
    # input is a bytearray for each device
    # device 0 (CR)content is created by CR, inputs to CR are handled in send_device
    device = 0
    for line in v_dev.data_to_CR:
        #  all device

        # wait for complete commandtoken
        if len(line) < v_dev.length_commandtoken[device]:
            # not enough bytes
            device += 1
            continue
        device_tokennumber = int.from_bytes(line[:v_dev.length_commandtoken[device]], byteorder='big', signed=False)
        finish = 0
        # usually should be true:
        if device_tokennumber in v_dev.tok[device]:
            # cr_token
            try:
                tok = v_dev.dev_cr_tok[device][device_tokennumber]
            except KeyError:
                write_log("dev, no vaiid token")
                v_dev.len[device][0] = v_dev.length_commandtoken[device]
                finish = 2
            if finish == 0:
                if v_linelength.answer[tok] == "0":
                    v_dev.len[device]   [0] = v_dev.length_commandtoken
                    # device cannot send command answer : due to some error before
                    finish = 2
                    write_log("dev cannot send this answer")
                # got valid token now
                line_length_index_0 = v_linelength.answer[tok][0]

                # after geting the commandtoken loop is 0:
                if v_dev.len[device][1] == 0:
                    # get the number of bytes for the fist loop
                    v_dev.len[device][0] = v_linelength.answer[tok][1]
                    # set time for timeout
                    v_dev.start_time[device] = time.time()

                got_bytes = len(line)
# some switches without parameters
                if line_length_index_0 == "0":
                    finish = 1

# switches,range commands and numeric om, am
                elif line_length_index_0 == "1":
                    v_dev.len[device], finish = data_1(line,got_bytes,v_dev.len[device],v_linelength.answer[tok])

# an string
                elif line_length_index_0 == "2":
                    v_dev.len[device], finish = data_4(line, got_bytes,v_dev.len[device], v_linelength.answer[tok])

# aa
                elif line_length_index_0 == "3":
                    v_dev.len[device], finish = data_3(line, got_bytes,v_dev.len[device], v_linelength.answer[tok])

# ab
                elif line_length_index_0 == "4":
                    v_dev.len[device], finish = data_4(line, got_bytes,v_dev.len[device], v_linelength.answer[tok])
                else:
                    finish = 2
        else:
            v_dev.len[device][0] = v_dev.length_commandtoken[device]
            finish = 2

        if finish == 0:
            pass
        elif finish == 1:
            # tranfer to sk infobuffer
            # add # ff: device -> LD -> SK + tok
            a = bytearray([0xff])
            a.extend(int_to_ba(tok, v_cr_params.length_commandtoken))
            # add rest of line
            a.extend(v_dev.data_to_CR[device][:v_dev.len[device][0]])
            v_ld.data_to_ld.extend(a)
            # clear data
            v_dev.data_to_CR[device] = v_dev.data_to_CR[device][:v_dev.len[device][0]:]
            v_dev.len[device] = [0, 0, 0, 0, 0]
            v_dev.start_time[device] = 0
        else:
            # clear data
            v_dev.data_to_CR[device] = v_dev.data_to_CR[device][:v_dev.len[device][0]:]
            v_dev.len[device] = [0, 0, 0, 0, 0]
            v_dev.start_time[device] = 0

        device += 1
    return

def clear_dev(device):
    # same as above, needed for timedependent_tasks
    v_dev.data_to_CR[device] = v_dev.data_to_CR[device][:v_dev.len[device][0]:]
    v_dev.len[device] = [0, 0, 0, 0, 0]
    v_dev.start_time[device] = 0
    return
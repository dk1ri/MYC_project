"""
name : device_handling.py
last edited: 202504014
devicehandling subprograms
analyzes the answers and info and transfer to SK devices buffers
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""
from misc_functions import *
from ld_buffer_handling import *
import v_ld
import v_token_params

import v_linelength
import v_dev


def poll_device_buffer():
    # analyze data from device for completeness to transfer to LD (there should be no errors!)
    # the input may occur in a way, that more than one loop are necessary to finish
    # or an answer or info may be complete. in this case, the handling should be completed
    # before switching to the next device
    # input is a bytearray for each device
    for device in v_dev.data_to_CR:
        #  all devices
        # wait for complete commandtoke
        if len(v_dev.data_to_CR[device]) < v_dev.length_commandtoken[device]:
            device += 1
            continue

        line = v_dev.data_to_CR[device]
        device_tokennumber = int.from_bytes(line[:v_dev.length_commandtoken[device]], byteorder='big', signed=False)
        # usually should be true:
        if device_tokennumber in v_dev.all_answer_toks[device]:
            # devices will not den commands (RU????)
            if v_linelength.answer[device][device_tokennumber] == "0":
                v_dev.len[device][0] = v_dev.length_commandtoken
                # device cannot send command answer : due to some error before
                finish = 2
                write_log("dev cannot send this answer")
            else:
                # got valid token now
                line_length_index_0 = v_linelength.answer[device][device_tokennumber][0]

                # after geting the commandtoken loop is 0:
                if v_dev.len[device][1] == 0:
                    # get the number of bytes for the fist loop
                    v_dev.len[device][0] = v_linelength.answer[device][device_tokennumber][1]
                    # set time for timeout
                    v_dev.start_time[device] = time.time()

                got_bytes = len(line)
                # some switches without parameters
                if line_length_index_0 == "0":
                    finish = 1

                # switches,range commands and numeric om, am
                elif line_length_index_0 == "1":
                    v_dev.len[device], finish = data_1(device_tokennumber, line,got_bytes,v_dev.len[device],v_linelength.answer[device][device_tokennumber], device)

                # an string
                elif line_length_index_0 == "2":
                    v_dev.len[device], finish = data_4(line, got_bytes,v_dev.len[device], v_linelength.answer[device][device_tokennumber], device)

                # aa
                elif line_length_index_0 == "3":
                    v_dev.len[device], finish = data_3(device_tokennumber,line, got_bytes,v_dev.len[device], v_linelength.answer[device][device_tokennumber], device)

                # ab
                elif line_length_index_0 == "4":
                    v_dev.len[device], finish = data_4(line, got_bytes,v_dev.len[device], v_linelength.answer[device][device_tokennumber], device)
                else:
                    finish = 2
        else:
            v_dev.len[device][0] = v_dev.length_commandtoken[device]
            write_log("dev, no answer token for device " + str(device) + ": " + str(device_tokennumber))
            finish = 2

        if finish == 0:
            pass
        elif finish == 1:
            # transfer to to SK (skip LD) but store data
            # change dev token to CR token
            dev_tok = int.from_bytes(v_dev.data_to_CR[device][:v_dev.token_length])
            v_ld.from_ld_to_sk = v_token_params.cr_token[device][dev_tok].to_bytes(v_announcelist.length_of_full_elements, byteorder='big', signed=False)
            v_ld.from_ld_to_sk += (v_dev.data_to_CR[device][v_dev.token_length:])
            misc_functions.write_log("dev to ld" + v_ld.from_ld_to_sk)
            if v_ld.from_ld_to_sk[0] in v_ld.right_tok:
                store_data(v_ld.from_ld_to_sk[0], v_ld.from_ld_to_sk)
            # clear data
            v_dev.data_to_CR[device] = v_dev.data_to_CR[device][:v_dev.len[device][0]:]
            v_dev.len[device] = [0, 0, 0, 0, 0]
            v_dev.start_time[device] = 0
        else:
            # clear data
            clear_dev(device)
        device += 1
    return

def clear_dev(device):
    # same as above, needed for timedependent_tasks
    v_dev.data_to_CR[device] =  bytearray()
    v_dev.len[device] = [0, 0, 0, 0, 0]
    v_dev.start_time[device] = 0
    return
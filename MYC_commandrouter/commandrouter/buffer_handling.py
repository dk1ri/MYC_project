"""
name : buffer_handling.py
last edited:
misc functions
"""

from cr_own_commands import *
from io_handling import *
from misc_functions import *

import v_announcelist
import v_configparameter
import v_dev
import v_ld
import v_sk
import v_token_params


def poll_inputs():
    # input polling
    # inputs from SK, higher level CR...
    # Terminal and Telnet only up to now
    # data are send to v_sk.inputline
    input_buffer_number = 0
    while input_buffer_number < len(v_sk.name):
        if v_sk.interface_type[input_buffer_number] == "TERMINAL":
            # input_buffer_number,device_buffer_number
            win_terminal(input_buffer_number, 0)
        elif v_sk.interface_type[input_buffer_number] == "TELNET":
            # telnet is a separate thread, writimg directly to inputbuffer
            pass
        input_buffer_number += 1
    return


# poll inputbuffer see command_handling


# output to LD
def send_to_ld():
    # one bytearraylement (complete command) to LD
    if v_ld.data_to_ld != "":
        if v_ld.ld_available == 0:
            # copy to v_ld.data_to_cr
            # commands only here info not sent to LD
            v_ld.data_to_cr = str_to_bytearray(chr(0xfe) + v_ld.data_to_ld)
            v_ld.data_to_ld = ""
    else:
        # send to LD missing
        pass
    return


# poll inputbuffer see _ld_command_handling


def send_buffer_to_device():
    # output to normal devices
    # poll devicebuffer v_dev.data_to_device
    # up to now: send data as hex to terminal instead of sending to device
    device = 0
    # all devices
    while device < len(v_dev.interface_type):
        line = v_dev.data_to_device[device][v_dev.readpointer[device]]
        if len(line) > 0:
# ++++++++++++++++++++++++++++++++++++
            # for testphase only
            v_time_values.data = line
# ++++++++++++++++++++++++++++++++++++
            if device == 0:
                # got commands for CR
                if line[0] == 0:
                    tok = 0
                else:
                    tok = int.from_bytes(line[:v_cr_params.length_commandtoken], byteorder='big', signed=False)
                if tok <= v_cr_params.number_of_commands_noCR:
                    # this is a a basic announcement command
                    announce_line = v_announcelist.full[v_token_params.announcements[tok]]
                    # len(announceline) is 1 alswys
                    announce_line = int_to_bytes(len(announce_line), v_cr_params.length_commandtoken) + announce_line
                    # send directly ( not via v_dev.data_to_cr)
                    if tok == 0:
                        v_sk.info_to_all.extend(bytearray([0]*v_cr_params.length_commandtoken))
                    else:
                        v_sk.info_to_all.extend(int_to_ba(tok, v_cr_params.length_commandtoken))
                    v_sk.info_to_all.extend(str_to_bytearray(announce_line))
                else:
                    # original token
                    # extact token to int:
                    token = int.from_bytes(line[:v_cr_params.length_commandtoken], byteorder='big', signed=False)
                    # this is a valid value
                    user = v_dev.user[0][v_dev.readpointer[0]]
                    # call associated programm
                    command[token](line, v_token_params.index_of_cr_commands[token], token, v_dev.input_device[device], user)
            else:
                # other device
                out = v_dev.interface_type[device]
                if out == "I2C" or out == "RC5" or out == "RC6" or out == "TERMINAL":
                    # not yet ready, for test only
                    # use simple print now
                    b = ""
                    j = 0
                    while j < len(line):
                        b += hex(line[j])
                        j += 1
                    print("to device " + str(device) + " (hex): " + b)
                if v_dev.interface_type[device] == "TELNET":
                    # telnet is a separate threat,writimg directlx to inputbuffer
                    pass

            # must be empty, otherwise may be used again:
            v_dev.data_to_device[device][v_dev.readpointer[device]] = bytearray([])
            v_dev.readpointer[device] += 1
            if v_dev.readpointer[device] >= v_configparameter.device_ringbuffersize:
                v_dev.readpointer[device] = 0
        device += 1
    return


def poll_devices():
    # poll for input from devices (answer or info)
    # output is v_dev.data_to_CR
    device = 0
    while device < len(v_dev.interface_type):
        if device == 0:
            # This is the CR, if the CR has own info,they are put to v_dev.data_to_CR here
            # CR answers of commands are directly written to v_sk.info_to_all
            pass
        # 0: type
        if v_dev.interface_type[device] == "I2C":
            # not yet ready
            pass
        if v_dev.interface_type[device] == "TERMINAL":
            # input_buffer_number,device_buffer_number,input_device
            win_terminal(0, device)
        if v_dev.interface_type[device] == "TELNET":
            # telnet is a separate threat,writimg directlx to inputbuffer
            pass
        device += 1
    return


def send_to_all():
    # up to now: print only
    if v_sk.info_to_all != bytearray([]):
        print("info to all SK:", v_sk.info_to_all)
    v_sk.info_to_telnet = v_sk.info_to_all
    v_sk.info_to_all = bytearray([])
    return

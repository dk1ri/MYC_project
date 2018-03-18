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
import v_cr_params
import v_dev
import v_ld
import v_sk
import v_token_params

# poll inputs and command_handling operate by bytes
# the other subprograms use listelement: each element contain a complete command / answer / info

def poll_inputs():
    # input polling
    # inputs from SK, higher level CR...
    # Terminal and Telnet only up to now
    # data are send to v_sk.inputline
    input_buffer_number = 0
    while input_buffer_number < len(v_sk_interface.interface_type):
        if v_sk_interface.activ[input_buffer_number] == 1:
            if v_sk_interface.interface_type[input_buffer_number] == "TERMINAL":
                # input_buffer_number,device_buffer_number
                if v_sk.active[input_buffer_number] == 1:
                    win_terminal(input_buffer_number, 0)
            elif v_sk_interface.interface_type[input_buffer_number] == "TELNET":
                # telnet is a separate thread, writimg directly to inputbuffer
                pass
        input_buffer_number += 1
    return


# poll SK inputbuffer see command_handling


def send_to_ld():
    # copy(complete commands only) to LD
    if len(v_ld.data_to_ld) > 0:
        if v_ld.ld_available == 0:
            # mirror back to v_ld.data_to_cr
            v_ld.data_to_cr.extend(v_ld.data_to_ld)
            v_ld.data_to_ld = bytearray([])
        else:
            # not available now
            pass
    return


# poll LD inputbuffer see ld_command_handling


def send_buffer_to_device():
    # output to normal devices
    # poll devicebuffer v_dev.data_to_device
    # up to now: send data as hex to terminal instead of sending to devic
    # commands to CR (device == 0) were not sent to the buffer, but handled by command_handlling:
    device = 1
    # all devices
    while device < len(v_dev.interface_type):
        # v_dev.data_to_device use a list, makes it easier to to send per command to dev
        # if device do not support command caching
        # first (oldest) element:
        if len(v_dev.data_to_device[device]) > 0:
            line = v_dev.data_to_device[device][0]
            if len(line) > 0:
    # ++++++++++++++++++++++++++++++++++++
                # for testphase only
                v_time_values.data = line
    # ++++++++++++++++++++++++++++++++++++
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
                    if v_configparameter.test_mode == 1 :
                        print("to device " + str(device) + " (hex): " + b)
                if v_dev.interface_type[device] == "TELNET":
                    # telnet is a separate threat,writimg directlx to inputbuffer
                    pass

            # delete oldest element
            del v_dev.data_to_device[device][0]
        device += 1
    return


def poll_devices():
    # poll for input from devices (answer or info)
    # output is v_dev.data_to_CR
    # CR (device == 0) answers of commands and infos are directly written to v_sk.info_to_all
    device = 1
    while device < len(v_dev.interface_type):
        if v_dev.interface_type[device] == "I2C":
            # not yet ready
            pass
        if v_dev.interface_type[device] == "TERMINAL":
            # input_buffer_number,device_buffer_number
            win_terminal(0, device)
        if v_dev.interface_type[device] == "TELNET":
            # telnet is a separate threat,writimg directlx to inputbuffer
            pass
        device += 1
    return

# poll device inputbuffer see device_handling


def send_to_all():
    # up to now: print only
    if v_sk.info_to_all != bytearray([]):
        if v_configparameter.test_mode == 1:
            print("info to all SK:", v_sk.info_to_all)
    v_sk.info_to_telnet = v_sk.info_to_all
    v_sk.info_to_all = bytearray([])
    return

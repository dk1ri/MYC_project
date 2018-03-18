#

import time
import random

from device_handling import *
from buffer_handling import *
from command_handling import *
from ld_command_handling import *
from misc_functions import *

# import v_announcelist
# import v_configparameter
# import v_cr_params
import v_dev
# import v_device_announce
# import v_device_names_and_indiv
# import v_index_of_input_buffer
# import v_kbd_input
import v_linelength
import v_sk
import v_sk_interface
import v_time_values
# import v_token_params

# ------------------------------------------------
# subprograms for tests
# ------------------------------------------------


def handle_check():
    # handling of commandfiles
    if v_time_values.terminal == 255:
        # find terminal
        j = 0
        while j < len(v_sk_interface.interface_type):
            j += 1
            if v_sk_interface.interface_type[j - 1] == "TERMINAL":
                v_time_values.terminal = j
    if v_time_values.terminal == 255:
        v_time_values.auto = 0
        v_time_values.part = 0
        print("no Terminal found")
        return
    while v_time_values.check_number < len(v_time_values.from_sk):
        v_sk.inputline[v_time_values.terminal] = bytearray([])
        v_sk.len[v_time_values.terminal] = [0,0,0,0,0]
        v_sk.starttime[v_time_values.terminal] = 0
        # avoid user timeout
        # avoid user timeout
        v_sk.channel_timeout[v_time_values.terminal] = time.time()
        v_time_values.part = 1
        v_time_values.data = bytearray([])

        # line 1 and 2
        v_time_values.check_line_finished = 0
        print("")
        print(v_time_values.check_number,"announcement: ", v_time_values.announcement[v_time_values.check_number])
        v_time_values.last_checktime = time.time()
        v_sk.inputline[v_time_values.terminal] = v_time_values.from_sk[v_time_values.check_number]
        tok = 0
        if v_time_values.from_sk[v_time_values.check_number][0] != 0:
            tok = int.from_bytes(v_time_values.from_sk[v_time_values.check_number][:v_cr_params.length_commandtoken], byteorder='big', signed=False)
        # find corresponding output device
        v_time_values.out_device = 0
        if tok != 0:
            if tok < v_cr_params.number_of_commands_noCR:
                # normal cr_commands
                v_time_values.out_device = v_token_params.device[tok]
            else:
                v_time_values.out_device = v_token_params.device[v_token_params.index_of_cr_commands[tok]]

        poll_input_buffer()
        send_to_ld()
        poll_ld()
        send_buffer_to_device()
        # next: check data to device:
        # line 3: check data to dev
        if v_time_values.data == v_time_values.to_dev[v_time_values.check_number]:
            v_time_values.all += 1
            if v_time_values.errormsg[v_time_values.check_number] == "should be ok":
                v_time_values.number_of_ok += 1
                print("ok", v_time_values.errormsg[v_time_values.check_number])
            else:
                if v_time_values.errormsg[v_time_values.check_number] == "should produce an error":
                    v_time_values.number_of_ok_nok += 1
                    print ("should produce an error, but is ok")
                else:
                    if v_time_values.errormsg[v_time_values.check_number] != "":
                        print("wrong errormsg")
        else:
            print(v_time_values.check_number, "to_dev nok:", v_time_values.data,v_time_values.to_dev[v_time_values.check_number])
            v_time_values.all += 1
            if v_time_values.errormsg[v_time_values.check_number] == "should produce an error":
                v_time_values.number_of_ok += 1
                print("ok",v_time_values.errormsg[v_time_values.check_number])
            else:
                if v_time_values.errormsg[v_time_values.check_number] == "should be ok":
                    v_time_values.number_of_nok += 1
                    print("should be ok, but is nok")
                else:
                    if v_time_values.errormsg[v_time_values.check_number] != "":
                        print("wrong errormsg")

        v_time_values.check_number += 1

    else:
        # stop
        v_time_values.auto = 0
        print("commands from file finished. ok:",v_time_values.number_of_ok, "of:",v_time_values.all, " Number of errors:", v_time_values.number_of_nok, "number of wrong errors:", v_time_values.number_of_ok_nok)

    return


def random_data():
# send data with ram length to (random) SK, LD or device input
    if v_time_values.terminal == 255:
        # find terminal
        j = 0
        while j < len(v_sk_interface.interface_type):
            j += 1
            if v_sk_interface.interface_type[j - 1] == "TERMINAL":
                v_time_values.terminal = j
    if v_time_values.terminal == 255:
        v_time_values.auto = 0
        v_time_values.part = 0
        print("no Terminal found")
        return
    random_len = random.randint(1, v_time_values.random_k)
    direction = random.randint(0, 1)
# input from LD is not needed here, becauss output to LD copied to input from LD
    device = random.randint(0, 2)
    # must be lower then the number of devices
    j = 0
    v_time_values.mess_byte += random_len
    while j < random_len:
        ran_int = random.randint(0, 255)
        if direction == 0:
            v_sk.inputline[v_time_values.terminal].extend([ran_int])
        else:
            v_dev.data_to_CR[device].extend(([ran_int]))
        j += 1
    if direction == 0:
        print("random: SK",len(v_sk.inputline[v_time_values.terminal]))
    else:
        print("random; device:", device, len(v_dev.data_to_CR[device]))
# performance measurement corei7:
# with all prints: 398s
# one less: 378s
# no random prints: 285s
# error messages only 263s , 2499189 byte
#    v_time_values.random_time = time.time()
#    if v_time_values.mess == 0:
#        v_time_values.mess = time.time()
#    else:
    #   print ("s", v_time_values.random_i)
#        if v_time_values.random_i == 1000000:
#            print(v_time_values.mess - time.time(),v_time_values.mess_byte)
#            sys.exit()
#       else:
#            v_time_values.random_i += 1
    return

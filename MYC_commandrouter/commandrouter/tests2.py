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
import v_time_values
# import v_token_params

# ------------------------------------------------
# subprograms for tests
# ------------------------------------------------


def handle_check():
    if v_time_values.terminal == 255:
        # find terminal
        j = 0
        while j < len(v_sk.interface_type):
            j += 1
            if v_sk.interface_type[j - 1] == "TERMINAL":
                v_time_values.terminal = j
    if v_time_values.terminal == 255:
        v_time_values.auto = 0
        v_time_values.part = 0
        print("no Terminal found")
        return
    if v_time_values.check_number < len(v_time_values.from_sk):
            # not finished
        if v_time_values.part == 1:
            # line 1 and 2
            print("")
            print("announcement: ", v_time_values.announcememnt[v_time_values.check_number])
            v_time_values.last_checktime = time.time()
            # reset inputs
            v_sk.inputline[v_time_values.terminal] = bytearray([])
            # if there is no value with from_sk there is no with to_dev
            if v_time_values.from_sk[v_time_values.check_number] == bytearray([]):
                v_time_values.part = 3
            else:
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
                # do nextactions
                poll_input_buffer()
                send_to_ld()
                poll_ld()
                send_buffer_to_device()
                # next: check data to device:
                v_time_values.part = 2

        elif v_time_values.part == 2:
            # line 3: check data to dev
            if v_time_values.data == v_time_values.to_dev[v_time_values.check_number]:
                print(v_time_values.check_number, "to_dev ok: ", v_time_values.data)
                for lines in v_sk.inputline:
                    if lines != bytearray([]):
                        print("too many data: ", lines)
                # next: send data from device
                v_time_values.part = 3
            else:
                print(v_time_values.check_number, "to_dev nok:", v_time_values.data, v_time_values.to_dev[v_time_values.check_number])
                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                v_time_values.number_of_nok += 1
                # stop
                # may be, that timeout is not reset:
                v_sk.starttime[v_time_values.terminal][0] = 0
                v_sk.inputline[v_time_values.terminal] = bytearray([])
                v_time_values.part = 0
                v_time_values.check_number += 1
            v_time_values.data = bytearray([])

        elif v_time_values.part == 3:
            # send data from dev
            # if this is a info, the previous block of line must have set the out-device by a command.
            # There is no way to find a correct device at that time
            if v_time_values.from_dev[v_time_values.check_number] == "":
                # data_to_sk is empty as well
                # This was a operating command, there may data in info_to_all
                # poll_devices and poll_device_buffer should do nothing
                pass
            else:
                v_dev.data_to_CR[v_time_values.out_device].extend(v_time_values.from_dev[v_time_values.check_number])
            poll_device_buffer()
            v_time_values.part = 4

        elif v_time_values.part == 4:
            # all output data are send to info_to_all as bytearray
            check = v_time_values.to_sk[v_time_values.check_number]
            if check == bytearray(b''):
                check = v_time_values.to_sk_str[v_time_values.check_number]
            if v_sk.info_to_all == check:
                print(v_time_values.check_number, "to_sk ok: ", v_sk.info_to_all)
            else:
                print(v_time_values.check_number, "to_sk nok: ", v_sk.info_to_all, v_time_values.to_sk[v_time_values.check_number], v_time_values.to_sk_str[v_time_values.check_number])
                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                v_time_values.number_of_nok += 1
            v_time_values.check_number += 1
            v_time_values.part = 0
            send_to_all()
        else:
            # some error # stop
            v_time_values.auto = 0
            v_time_values.part = 0
            v_configparameter.time_for_command_timeout = v_configparameter.time_for_command_timeout * 10
            print("commands from file finished. Number of error:", v_time_values.number_of_nok)
    else:
        # stop
        v_time_values.auto = 0
        v_time_values.part = 0
        v_configparameter.time_for_command_timeout = v_configparameter.time_for_command_timeout * 10
        print("commands from file finished. Number of error:", v_time_values.number_of_nok)

    return


def random_data():
    if v_time_values.terminal == 255:
        # find terminal
        j = 0
        while j < len(v_sk.interface_type):
            j += 1
            if v_sk.interface_type[j - 1] == "TERMINAL":
                v_time_values.terminal = j
    if v_time_values.terminal == 255:
        v_time_values.auto = 0
        v_time_values.part = 0
        print("no Terminal found")
        return
    v_sk.inputline[v_time_values.terminal] = bytearray([])
    l = random.randint(1, v_time_values.random_k)
    direction = random.randint(0, 1)
    device = random.randint(0, 6)
    j = 0
    while j < l:
        ran_int = random.randint(0, 255)
        if direction == 0:
            v_sk.inputline[v_time_values.terminal].extend([ran_int])
        else:
            v_dev.data_to_CR[device] = bytearray([ran_int])
        j += 1
    if direction == 0:
        print("random: SK", v_sk.inputline[v_time_values.terminal])
    else:
        print("random; device:", device, v_dev.data_to_CR[device])
    v_time_values.random_time = time.time()
    v_time_values.random_i += 1
    if v_time_values.random_i == 500:
        v_time_values.random_i = 0
        v_time_values.random_k += 1
    if v_time_values.random_k == 20:
        v_time_values.auto = 0
        v_time_values.random_time = 0
        v_configparameter.time_for_command_timeout = v_time_values.random_timeout_temp
    return

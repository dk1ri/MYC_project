"""
name : analyze.py IC9700
last edited: 20211020
command handling, subprograms for sk and civ
"""

from commands import *
from misc_functions import *

import time
import v_sk
import v_icom_vars
import v_command_answer
import v_error_msg
from answers import *
from misc_functions import *


# ------------------------------------------------
# start of commandhandling
# ------------------------------------------------


def poll_sk_input_buffer():
    input_device = 0
    # something received from SK ... ?
    while input_device < len(v_sk.inputline):
        if v_icom_vars.ask_content == 2:
            # copy v_sk.last_command to input
            v_sk.inputline[input_device] = v_sk.last_command[input_device]
        line = v_sk.inputline[input_device]
        # if input data is correct and complete appropriate action is called
        if len(line) > 0:
            finish = 0
            # check for basic command
            if line[0] == 0:
                v_sk.info_to_all = bytearray([0x00, len(v_announcelist.full[0])])
                v_sk.info_to_all.extend([ord(el) for el in v_announcelist.full[0][1:]])
                # necessary to delete token:
                finish = 1
            else:
                # commandtoken ready?
                if len(line) >= 2:
                    tokennumber = int.from_bytes(line[0:2], byteorder='big', signed=False)
                    v_sk.last_token = bytearray([line[0], line[1]])
                    try:
                        finish = v_command_answer.command[tokennumber](line, input_device, tokennumber)
                    except KeyError:
                        finish = 2
                        write_log(v_error_msg.wrong__command + str(tokennumber))
            if finish == 0:
                # continue reading input
                pass
            elif finish == 3:
                # will not delete command
                pass
            else:
                if finish == 2:
                    # parameter error
                    temps = ""
                    count = 0
                    while count < len(v_sk.inputline[input_device]):
                        temp = v_sk.inputline[input_device][count]
                        temps += hex(temp)
                        count += 1
                    write_log(v_error_msg.parameter_error + temps)
                #else:
                    # finish == 1, correct
                # stop watchdog
                v_icom_vars.command_time = 0
                if v_icom_vars.ask_content == 1:
                    v_sk.last_command[input_device] = v_sk.inputline[input_device]
                v_sk.inputline[input_device] = bytearray([])
                v_icom_vars.command_no += 1
                v_icom_vars.command_no %= 255
                if v_icom_vars.error_cmd_no == v_icom_vars.command_no:
                    # no error
                    v_icom_vars.error_cmd_no = 255
                if v_icom_vars.ask_content == 2:
                    v_icom_vars.ask_content = 0
        input_device += 1
    return


def poll_civ_input_buffer():
    if v_icom_vars.Civ_in.find(0xfd) == -1:
        return
    # end found
    # finish = 1 : ok
    finish = 2
    # got answer:
    v_icom_vars.civ_watchdog_time = 0
    temp = str((v_sk.last_token[0] * 256 + v_sk.last_token[1]))
    if v_icom_vars.Civ_in[0:6] == v_icom_vars.nok_msg:
        if len(v_sk.last_token) >= 2:
            if temp == 471 or temp == 473:
                msg = v_error_msg.no_tuner
            elif temp == 719 or temp == 721:
                msg = v_error_msg.no_sd
            else:
                msg = v_error_msg.civ_wrong_parameter
            write_log(msg + temp)
            v_sk.info_to_all = bytearray([0x03, 0x34, 0x01])
    elif v_icom_vars.Civ_in[0:6] == v_icom_vars.ok_msg:
        if v_icom_vars.test_mode == 1:
            print("CIV: ok")
        finish = 1
    elif len(v_icom_vars.Civ_in) == 6:
        # should not happen
        write_log(v_error_msg.civ_other_error + " for command " + temp)
    else:
        # answer or info
        civ_command = int.from_bytes(v_icom_vars.Civ_in[4:5], byteorder='big', signed=False)
        v_icom_vars.civ_command_length = 1
        if civ_command < 20:
            if find_token(v_icom_vars.Civ_in[4:5]) == 1:
                finish = v_command_answer.answer[civ_command](v_icom_vars.Civ_in)
        elif civ_command == 20:
            if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                subcommand = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
                finish = v_command_answer.answer14[subcommand](v_icom_vars.Civ_in)
        elif civ_command == 21:
            if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                subcommand = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
                finish = v_command_answer.answer15[subcommand](v_icom_vars.Civ_in)
        elif civ_command == 22:
            if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                subcommand = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
                finish = v_command_answer.answer16[subcommand](v_icom_vars.Civ_in)
        elif civ_command == 25:
            # civ command 19
            if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                finish = answer_2_1_b(v_icom_vars.Civ_in)
        elif civ_command == 0x1a:
            subcommand1 = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
            if subcommand1 < 5:
                v_icom_vars.civ_command_length = 2
                if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                    finish = v_command_answer.answer1a[subcommand1](v_icom_vars.Civ_in)
            elif subcommand1 == 5:
                v_icom_vars.civ_command_length = 3
                subcommand2 = int.from_bytes(v_icom_vars.Civ_in[6:7], byteorder='big', signed=False)
                if subcommand2 == 0:
                    v_icom_vars.civ_command_length = 4
                    if find_token(v_icom_vars.Civ_in[4:8]) == 1:
                        subcommand3 = int.from_bytes(v_icom_vars.Civ_in[7:8], byteorder='big', signed=False)
                        finish = v_command_answer.answer1a0500[subcommand3](v_icom_vars.Civ_in)
                if subcommand2 == 1:
                    v_icom_vars.civ_command_length = 4
                    if find_token(v_icom_vars.Civ_in[4:8]) == 1:
                        subcommand3 = int.from_bytes(v_icom_vars.Civ_in[7:8], byteorder='big', signed=False)
                        finish = v_command_answer.answer1a0501[subcommand3](v_icom_vars.Civ_in)
                if subcommand2 == 2:
                    v_icom_vars.civ_command_length = 4
                    if find_token(v_icom_vars.Civ_in[4:8]) == 1:
                        subcommand3 = int.from_bytes(v_icom_vars.Civ_in[7:8], byteorder='big', signed=False)
                        print (subcommand3)
                        finish = v_command_answer.answer1a0502[subcommand3](v_icom_vars.Civ_in)
                if subcommand2 == 3:
                    v_icom_vars.civ_command_length = 4
                    if find_token(v_icom_vars.Civ_in[4:8]) == 1:
                        subcommand3 = int.from_bytes(v_icom_vars.Civ_in[7:8], byteorder='big', signed=False)
                        finish = v_command_answer.answer1a0503[subcommand3](v_icom_vars.Civ_in)
            else:
                if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                    v_icom_vars.civ_command_length = 2
                    finish = v_command_answer.answer_1a06_0b[subcommand1](v_icom_vars.Civ_in)
        elif civ_command == 0x1b:
            v_icom_vars.civ_command_length = 2
            if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                subcommand1 = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
                v_icom_vars.start_data = 6
                finish = v_command_answer.answer_1b[subcommand1](v_icom_vars.Civ_in)
        elif civ_command == 0x1c:
            v_icom_vars.civ_command_length = 2
            if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                subcommand1 = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
                finish = v_command_answer.answer_1c[subcommand1](v_icom_vars.Civ_in)
        elif civ_command == 0x1e:
            v_icom_vars.civ_command_length = 2
            if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                subcommand1 = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
                finish = v_command_answer.answer_1e[subcommand1](v_icom_vars.Civ_in)
        elif civ_command == 0x1f:
            v_icom_vars.civ_command_length = 2
            if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                subcommand1 = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
                finish = v_command_answer.answer_1f[subcommand1](v_icom_vars.Civ_in)
        elif civ_command == 0x20:
            subcommand1 = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
            if subcommand1 != 0x03:
                # 2000 - 02
                subcommand2 = int.from_bytes(v_icom_vars.Civ_in[6:7], byteorder='big', signed=False)
                if subcommand1 == 0x00:
                    if find_token(v_icom_vars.Civ_in[4:7]) == 1:
                        v_icom_vars.civ_command_length = 3
                        finish = v_command_answer.answer_2000[subcommand2](v_icom_vars.Civ_in)
                elif subcommand1 == 0x01:
                    if find_token(v_icom_vars.Civ_in[4:7]) == 1:
                        v_icom_vars.civ_command_length = 3
                        finish = v_command_answer.answer_2001[subcommand2](v_icom_vars.Civ_in)
                elif subcommand1 == 0x02:
                    if find_token(v_icom_vars.Civ_in[4:7]) == 1:
                        v_icom_vars.civ_command_length = 3
                        finish = v_command_answer.answer_2002[subcommand2](v_icom_vars.Civ_in)
                elif subcommand1 == 0x04:
                    if find_token(v_icom_vars.Civ_in[4:7]) == 1:
                        v_icom_vars.civ_command_length = 3
                        finish = v_command_answer.answer_2002[subcommand2](v_icom_vars.Civ_in)
            else:
                # 2003
                subcommand2 = int.from_bytes(v_icom_vars.Civ_in[6:7], byteorder='big', signed=False)
                if subcommand2 == 0:
                    # 200300
                    if find_token(v_icom_vars.Civ_in[4:7]) == 1:
                        v_icom_vars.civ_command_length = 3
                        finish = v_command_answer.answer_2003[subcommand2](v_icom_vars.Civ_in)
                else:
                    if subcommand2 == 0x01:
                        #200301xx
                        if find_token(v_icom_vars.Civ_in[4:8]) == 1:
                            v_icom_vars.civ_command_length = 5
                            subcommand3 = int.from_bytes(v_icom_vars.Civ_in[7:8], byteorder='big', signed=False)
                            v_icom_vars.civ_command_length = 4
                            finish = v_command_answer.answer_200301[subcommand3](v_icom_vars.Civ_in)
                    elif subcommand2 == 0x02:
                        #200302xx
                        if find_token(v_icom_vars.Civ_in[4:7]) == 1:
                            v_icom_vars.civ_command_length = 5
                            subcommand3 = int.from_bytes(v_icom_vars.Civ_in[7:8], byteorder='big', signed=False)
                            v_icom_vars.civ_command_length = 4
                            finish = v_command_answer.answer_200302[subcommand3](v_icom_vars.Civ_in)

        elif civ_command == 0x21:
            if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                v_icom_vars.civ_command_length = 2
                subcommand1 = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
                finish = v_command_answer.answer_21[subcommand1](v_icom_vars.Civ_in)
        elif civ_command == 0x22:
            subcommand1 = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
            if subcommand1 == 0x01:
                if find_token(v_icom_vars.Civ_in[4:7]) == 1:
                    v_icom_vars.civ_command_length = 3
                    subcommand2 = int.from_bytes(v_icom_vars.Civ_in[6:7], byteorder='big', signed=False)
                    print (subcommand2)
                    finish = v_command_answer.answer_2201[subcommand2](v_icom_vars.Civ_in)
            else:
                if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                    v_icom_vars.civ_command_length = 2
                    finish = v_command_answer.answer_22[subcommand1](v_icom_vars.Civ_in)
        elif civ_command == 0x23:
            if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                v_icom_vars.civ_command_length = 2
                subcommand1 = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
                finish = v_command_answer.answer_23[subcommand1](v_icom_vars.Civ_in)
        elif civ_command == 0x24:
            if find_token(v_icom_vars.Civ_in[4:7]) == 1:
                v_icom_vars.civ_command_length = 3
                subcommand1 = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
                finish = v_command_answer.answer_24[subcommand1](v_icom_vars.Civ_in)
        elif civ_command == 0x25:
            if find_token(v_icom_vars.Civ_in[4:5]) == 1:
                v_icom_vars.civ_command_length = 1
                finish = v_command_answer.answer_25[civ_command](v_icom_vars.Civ_in)
        elif civ_command == 0x26:
            if find_token(v_icom_vars.Civ_in[4:5]) == 1:
                v_icom_vars.civ_command_length = 1
                finish = v_command_answer.answer_26[civ_command](v_icom_vars.Civ_in)
        elif civ_command == 0x27:
            if find_token(v_icom_vars.Civ_in[4:6]) == 1:
                subcommand1 = int.from_bytes(v_icom_vars.Civ_in[5:6], byteorder='big', signed=False)
                v_icom_vars.civ_command_length = 2
                finish = v_command_answer.answer_27[subcommand1](v_icom_vars.Civ_in)
        else:
            if find_token(v_icom_vars.Civ_in[4:5]) == 1:
                v_icom_vars.civ_command_length = 1
                finish = v_command_answer.answer_rest[civ_command](v_icom_vars.Civ_in)
    if finish == 1:
        length = v_icom_vars.Civ_in.find(0xfd) + 1
        v_icom_vars.Civ_in = v_icom_vars.Civ_in[length:]
        v_icom_vars.input_locked = 0
    else:
        v_icom_vars.Civ_in = bytearray([])
        v_icom_vars.command_storage = []
        v_sk.info_to_all =[]
        v_icom_vars.ask_content = 0
        v_icom_vars.input_locked = 0
    if v_icom_vars.ask_content > 0:
        v_icom_vars.ask_content = 2
    return

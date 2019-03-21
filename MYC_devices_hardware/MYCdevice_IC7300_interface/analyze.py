"""
name : command_handling.py
last edited: 20190312
command handling subprograms for sk and civ
"""

from commands import *
from misc_functions import *

import time
import v_sk
import v_Ic7300_vars
import v_command_answer
import v_error_msg
from answers import *


# ------------------------------------------------
# start of commandhandling
# ------------------------------------------------


def poll_sk_input_buffer():
    input_device = 0
    # something received from SK ... ?
    while input_device < len(v_sk.inputline):
        line = v_sk.inputline[input_device]
        # if input data is correct and complete appropriate action is called
        if len(line) > 0:
            finish = 0
            # check for basic command
            if line[0] == 0:
                v_sk.info_to_all = bytearray([0x00, len(v_announcelist.full[0])])
                v_sk.info_to_all.extend([ord(el) for el in v_announcelist.full[0][1:]])
                # necessary to delete token:
                v_sk.len[input_device][0] = 1
                finish = 1
            else:
                # commandtoken ready?
                got_bytes = len(line)
                if got_bytes >= 2:
                    tokennumber = int.from_bytes(line[0:2], byteorder='big', signed=False)
                    v_sk.last_token = bytearray([line[0],line[1]])
                    try:
                        finish = v_command_answer.command[tokennumber](line, input_device, tokennumber )
                    except KeyError:
                        finish = 2
                        write_log(v_error_msg.wrong__command + str(tokennumber))
            if finish == 0:
                pass
            elif finish == 3:
                #will not delete command
                pass
            else:
                if finish == 2:
                    write_log(v_error_msg.parameter_error)
                    v_sk.inputline[input_device] = bytearray([])
                    v_Ic7300_vars.error_cmd_no = v_Ic7300_vars.command_no
                else:
                    # finish == 1, reset some values of v_sk after command finished
                    v_sk.inputline[input_device] = v_sk.inputline[input_device][v_sk.len[input_device][0]:]
                # stop watchdog
                v_Ic7300_vars.command_time = 0
                v_sk.len[input_device] = [0]
                v_Ic7300_vars.command_no += 1
                v_Ic7300_vars.command_no %= 255
                if v_Ic7300_vars.error_cmd_no == v_Ic7300_vars.command_no:
                    # no error
                    v_Ic7300_vars.error_cmd_no = 255
        input_device += 1
    return

def poll_civ_input_buffer():
    if v_Ic7300_vars.Civ_in.find(0xfd) == -1:
        return
    finish = 2
    # got answer:
    v_Ic7300_vars.civ_watchdog_time = 0
    if v_Ic7300_vars.Civ_in[0:6] == v_Ic7300_vars.nok_msg:
        if v_Ic7300_vars.init_content == 2:
            # initial memory check memory empty, copy content
            v_Ic7300_vars.init_content = 3
        else:
            temp = ""
            if len(v_sk.last_token) >= 2:
                temp = str((v_sk.last_token[0] * 256 + v_sk.last_token[1]))
            write_log(v_error_msg.civ_wrong_parameter + temp)
            finish = 1
    elif v_Ic7300_vars.Civ_in[0:6] == v_Ic7300_vars.ok_msg:
        if v_Ic7300_vars.init_content == 2 or v_Ic7300_vars.init_content == 4:
            # got valid memory data or correct initialization
            v_Ic7300_vars.init_content = 1
        elif v_Ic7300_vars.init_content >= 10:
            v_Ic7300_vars.init_content += 1
        elif v_Ic7300_vars.update_memory == 2:
            # "set VFO" sent -> ok -> send "set memory"
            v_Ic7300_vars.Civ_out = bytearray([0xFE, 0xFE, 0x94, 0xE0, 0x08, 0xfd])
            v_Ic7300_vars.update_memory = 0
            finish = 1
        elif v_Ic7300_vars.update_memory == 1:
            # memory changed -> got ok -> send "set VFO"
            v_Ic7300_vars.Civ_out = bytearray([0xfe, 0xfe, 0x94, 0xe0, 0x07, 0xfd])
            v_Ic7300_vars.update_memory = 2
            finish = 3
        else:
            print("CIV: ok")
            finish = 1
    elif len(v_Ic7300_vars.Civ_in) == 6:
        write_log(v_error_msg.civ_other_error + ba_to_str(v_Ic7300_vars.Civ_in))
    else:
        civ_command = int.from_bytes(v_Ic7300_vars.Civ_in[4:5], byteorder='big', signed=False)
        if civ_command < 20:
            try:
                finish = v_command_answer.answer[civ_command](v_Ic7300_vars.Civ_in)
            except KeyError:
                write_log(v_error_msg.civ_command_not_valid+ str(civ_command))
        elif civ_command == 20:
            if len(v_Ic7300_vars.Civ_in) > 6:
                subcommand = int.from_bytes(v_Ic7300_vars.Civ_in[5:6], byteorder='big', signed=False)
                try:
                    finish = v_command_answer.answer14[subcommand](v_Ic7300_vars.Civ_in)
                except KeyError:
                    write_log(v_error_msg.civ_sub_not_valid + str(subcommand))
        elif civ_command == 21:
            if len(v_Ic7300_vars.Civ_in) > 6:
                subcommand = int.from_bytes(v_Ic7300_vars.Civ_in[5:6], byteorder='big', signed=False)
                try:
                    finish = v_command_answer.answer15[subcommand](v_Ic7300_vars.Civ_in)
                except KeyError:
                    write_log(v_error_msg.civ_sub_not_valid + str(subcommand))
        elif civ_command == 22:
            if len(v_Ic7300_vars.Civ_in) > 6:
                subcommand = int.from_bytes(v_Ic7300_vars.Civ_in[5:6], byteorder='big', signed=False)
                try:
                    finish = v_command_answer.answer16[subcommand](v_Ic7300_vars.Civ_in)
                except KeyError:
                    write_log(v_error_msg.civ_sub_not_valid + str(subcommand))
        elif civ_command == 25:
            finish = answer_2_1_b(v_Ic7300_vars.Civ_in)
        elif civ_command == 0x1a:
            subcommand1 = int.from_bytes(v_Ic7300_vars.Civ_in[5:6], byteorder='big', signed=False)
            if subcommand1 < 5:
                try:
                    finish = v_command_answer.answer1a[subcommand1](v_Ic7300_vars.Civ_in)
                except KeyError:
                    write_log(v_error_msg.civ_sub_not_valid + str(subcommand1))
            elif subcommand1 == 5:
                subcommand2 = int.from_bytes(v_Ic7300_vars.Civ_in[6:7], byteorder='big', signed=False)
                if subcommand2 == 0:
                    subcommand3 = int.from_bytes(v_Ic7300_vars.Civ_in[7:8], byteorder='big', signed=False)
                    try:
                        finish = v_command_answer.answer1a0500[subcommand3](v_Ic7300_vars.Civ_in)
                    except KeyError:
                        write_log(v_error_msg.civ_sub_not_valid + str(subcommand2))
                if subcommand2 == 1:
                    subcommand3 = int.from_bytes(v_Ic7300_vars.Civ_in[7:8], byteorder='big', signed=False)
                    try:
                        finish = v_command_answer.answer1a0501[subcommand3](v_Ic7300_vars.Civ_in)
                    except KeyError:
                        write_log(v_error_msg.civ_sub_not_valid + str(subcommand2))
            else:
                try:
                    finish = v_command_answer.answer_1a67[subcommand1](v_Ic7300_vars.Civ_in)
                except KeyError:
                    write_log(v_error_msg.civ_sub_not_valid + str(subcommand1))
        elif civ_command == 0x1b:
            subcommand1 = int.from_bytes(v_Ic7300_vars.Civ_in[5:6], byteorder='big', signed=False)
            try:
                finish = v_command_answer.answer_1b[subcommand1](v_Ic7300_vars.Civ_in)
            except KeyError:
                write_log(v_error_msg.civ_sub_not_valid + str(subcommand1))
        elif civ_command == 0x1c:
            subcommand1 = int.from_bytes(v_Ic7300_vars.Civ_in[5:6], byteorder='big', signed=False)
            try:
                finish = v_command_answer.answer_1c[subcommand1](v_Ic7300_vars.Civ_in)
            except KeyError:
                write_log(v_error_msg.civ_sub_not_valid + str(subcommand1))
        elif civ_command == 0x1e:
            subcommand1 = int.from_bytes(v_Ic7300_vars.Civ_in[5:6], byteorder='big', signed=False)
            try:
                finish = v_command_answer.answer_1e[subcommand1](v_Ic7300_vars.Civ_in)
            except KeyError:
                write_log(v_error_msg.civ_sub_not_valid + str(subcommand1))
        elif civ_command == 0x21:
            subcommand1 = int.from_bytes(v_Ic7300_vars.Civ_in[5:6], byteorder='big', signed=False)
            try:
                finish= v_command_answer.answer_21[subcommand1](v_Ic7300_vars.Civ_in)
            except KeyError:
                write_log(v_error_msg.civ_sub_not_valid + str(subcommand1))
        elif civ_command == 0x1e:
            subcommand1 = int.from_bytes(v_Ic7300_vars.Civ_in[5:6], byteorder='big', signed=False)
            try:
                finish= v_command_answer.answer_1e[subcommand1](v_Ic7300_vars.Civ_in)
            except KeyError:
                write_log(v_error_msg.civ_sub_not_valid + str(subcommand1))
        elif civ_command == 0x27:
            subcommand1 = int.from_bytes(v_Ic7300_vars.Civ_in[5:6], byteorder='big', signed=False)
            try:
                finish = v_command_answer.answer_27[subcommand1](v_Ic7300_vars.Civ_in)
            except KeyError:
                write_log(v_error_msg.civ_sub_not_valid + str(subcommand1))
        else:
            try:
                finish = v_command_answer.answer_rest[civ_command](v_Ic7300_vars.Civ_in)
            except KeyError:
                write_log(v_error_msg.civ_sub_not_valid + str(civ_command))
    if finish == 1:
        length = v_Ic7300_vars.Civ_in.find(0xfd) + 1
        v_Ic7300_vars.Civ_in = v_Ic7300_vars.Civ_in[length:]
        v_Ic7300_vars.input_locked = 0
    else:
        v_Ic7300_vars.Civ_in = bytearray([])
    if v_Ic7300_vars.ask_content > 0:
        #
        v_Ic7300_vars.ask_content = 2
    return
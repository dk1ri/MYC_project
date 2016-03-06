"""
name : commandrouter_V01.1.py
Version 01.1, 20160220
purpose : Programm for a MYC commandrouter
Can be used with raspberry Pi Hardware
The Programm supports the MYC protocol
copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
The Programm is not ready, see description
The code is due to enhancements

missing:
rules device handling
logic device handling
get_announcements_of_one_lower_level_device
device interfaces
"""

# general
# import sys, os.path, time, socket, shutil, os, msvcr, threading
# from copy import deepcopy
# for i2c #sudo apt-get install python-smbu
# import smbus

# own subs
from commandrouter_command_handling import *
# from commandrouter_create_new_announce_list import *
from commandrouter_device_handling import *

# from commandrouter_length_of_commandtypes import *
# from commandrouter_misc_functions  import *
# from commandrouter_own_commands import *
# from commandrouter_terminal_handling import *
from commandrouter_init import *

# import variables for global use
# simple variables
import v_kbd_input
import v_sendstring
import v_command_number
import v_constants
import v_time_values

# simple lists
import v_token_of_basic_announcements
import v_all_command_token
import v_commandrouter_announcements
import v_device_names_and_indiv
import v_configparameter
# import v_input_buffer_list
import v_reserved_commands_for_commandtoken
import v_dev_devtoken_for_crtoken

# variables per device
import v_device_command
import v_device_announce
import v_device_buffer

# variables per input
import v_index_of_input_buffer
import v_input_buffer_actual_command_length

# variables per new commandtoken
import v_device_command_for_commandtoken

# other lists
import v_announcelist
import v_command_length
import v_commandrouter_params
import v_telnet

# list of full_indiv_line for lower level CR
lower_level_cr = []

# ------------------------------------------------
# initialization, programs are used at start only
# ------------------------------------------------


def dummy_sub():
    return


def init():
    # read config and initialize parameter array (for commands an devices)
    readconfig(sys.argv)
    read_commandrouter_annoucements()
    # poll networks for other devices, create my_devices and copy devicegroupfile
    read_networks()
    # at start ask for all, later react on info only
    get_announcements_of_lower_level_devices()
    read_my_devices()
    # also create announcelists
    check_activity_of_devices()
    return


def read_networks():
    # poll networks for other devices, create my_devices and copy devicegroupfile
    # missing
    return

# ------------------------------------------------
# time dependent task
# ------------------------------------------------


def time_dependent_tasks():
    # check existance of devices
    if int(time.time()) - v_time_values.last_activity > v_configparameter.time_for_activ_check:
        # not to to this twice..
        if v_configparameter.time_for_device_search - int(time.time()) > 2:
            check_activity_of_devices()
            v_configparameter.time_for_activ_check = time.time()
    # check for new device
    if int(time.time()) - v_time_values.last_device_search > v_configparameter.time_for_device_search:
        check_new_my_devices()
        v_configparameter.time_for_device_search = time.time()
    # check for timeout of HI, PQ..., write errormessage to inputbuffer
    i = 0
    while i < len(v_input_buffer.inputline):
        if v_input_buffer.inputline[i] != "":
            if (int(time.time()) - v_input_buffer.starttime[i]) > v_configparameter.time_for_command_timeout:
                v_input_buffer.last_error[i] = "timeout " + str(v_command_number.a)
                finish_command(i, len(v_input_buffer.inputline[i]))
        i += 1
    return


def check_activity_of_devices():
    # not final
    v_device_names_and_indiv.active = []
    for devices in v_device_names_and_indiv.active_and_last:
        # check missing
        dummy_sub()
        # for testphase only!!!!!!!!!!!!!!!!!!!!:
    v_device_names_and_indiv.active = list(v_device_names_and_indiv.active_and_last)

    notfound = 0
    # list may have different sequence
    for line in v_device_names_and_indiv.activ:
        if line in v_device_names_and_indiv.last:
            continue
        # one element not foun
        notfound = 1
    if notfound == 0:
        for line in v_device_names_and_indiv.last:
            if line in v_device_names_and_indiv.activ:
                continue
            notfound = 1
    if notfound == 1:
        create_new_announce_list()
        v_device_names_and_indiv.last = list(v_device_names_and_indiv.last)
    # send info for new list to all
    # missing
    print("new announcelists")
    return


def check_new_my_devices():
    # poll networks for other devices, create my_devices and copy devicegroupfile
    read_networks()
    read_my_devices()
    check_activity_of_devices()
    return


def poll_inputs():
    # input polling
    # inputs from HI, higher level CR...
    input_buffer_number = 0
    while input_buffer_number < len(v_input_buffer_list.name):
        if v_input_buffer_list.interface_type[input_buffer_number] == "Terminal":
            # input_buffer_number,device_buffer_number,input_device
            win_terminal(input_buffer_number, 0, 0)
        elif v_input_buffer_list.interface_type[input_buffer_number] == "TELNET":
            # telnet is a separate threat,writimg directlx to inputbuffer
            pass
        input_buffer_number += 1
    return


def send_input_answer_buffer():
    # answer
    # output to HI, higjer level CR...
    # checks v_input_buffer.answerline[x]
    input_buffer_number = 0
    while input_buffer_number < len(v_input_buffer_list.name):
        # actual answer available?
        if v_input_buffer.answer_ready[input_buffer_number] == 1:
            if v_input_buffer_list.interface_type[input_buffer_number] == "Terminal":
                terminal_out(v_input_buffer.answerline[input_buffer_number])
                v_input_buffer.answer_ready[input_buffer_number] = 0
                v_input_buffer.answerline[input_buffer_number] = []
            elif v_input_buffer_list.interface_type[input_buffer_number] == "TELNET":
                # telnet use a separate thread
                pass
        input_buffer_number += 1
    return

# device polling
# inputs from devices


def poll_devices():
    i = 0
    while i < len(v_device_buffer.interface):
        # 0: type
        if v_device_buffer.interface[i][0] == "Terminal":
            # input_buffer_number,device_buffer_number,input_device
            win_terminal(0, i, 1)
        if v_device_buffer.interface[i][0] == "Telnet":
            # telnet is a separate threat,writimg directlx to inputbuffer
            pass
        i += 1
    return

# output to normal devices


def send_buffer_to_device():
    i = 0
    while i < len(v_device_buffer.interface):
        if v_device_buffer.data_to_device != "":
            if v_device_buffer.interface[i][0] == "Terminal":
                terminal_out(v_device_buffer.data_to_device[i])
            if v_device_buffer.interface[i][0] == "Telnet":
                # telnet is a separate threat,writimg directlx to inputbuffer
                pass
        i += 1
    return

# ------------------------------------------------
# subprograms for tests
# ------------------------------------------------


def print_for_test():
    print_for_test1("all_command_token", v_all_command_token.a)
    print_for_test1("v_announcelist_basic", v_announcelist.basic)
    print_for_test1("v_announcelist_full", v_announcelist.full)
    print_for_test1("v_announcelist_rules", v_announcelist.rules)
    print_for_test3("v_command_length.reserved_token", v_command_length.reserved_token)
    print_for_test3("v_command_length.reserved_token_start", v_command_length.reserved_token_start)
    print_for_test3("v_command_length.reserved_token_adder", v_command_length.adder)
    print_for_test3("v_command_length.reserved_token_startnumber", v_command_length.startnumber)
    print_for_test3("v_command_number", v_command_number.a)
    print_for_test1("commandrouter_announcements", v_commandrouter_announcements.a)
    print_for_test3("v_commandrouter_params_name", v_commandrouter_params.name)
    print_for_test3("v_commandrouter_params_length_of_announcement_length", v_commandrouter_params.length_of_announcement_length)
    print_for_test3("v_configparameter", v_configparameter)
    print_for_test3("v_constants", v_constants)
    print_for_test3("v_dev_devtoken_for crtoken", v_dev_devtoken_for_crtoken.a)
    print_for_test3("v_device_announce", v_device_announce)
    print_for_test3("v_device_buffer_name", v_device_buffer.name)
    print_for_test3("v_device_buffer_interface", v_device_buffer.interface)
    print_for_test3("v_device_buffer_actual_CR_token_index", v_device_buffer.actual_CR_token_index)
    print_for_test3("v_device_buffer_actual_device_tokens", v_device_buffer.actual_device_token)
    print_for_test3("v_device_buffer_actual_device_tokens", v_device_buffer.actual_device_token)
    print_for_test3("v_device_buffer_all_answer_info_finished", v_device_buffer.answer_info_finished)
    print_for_test1("v_device_command", v_device_command.announceline)
    print_for_test1("v_device_command", v_device_command.token)
    print_for_test1("v_device_command_for_commandtoken_command", v_device_command_for_commandtoken.command)
    print_for_test1("v_device_command_for_commandtoken_announceline", v_device_command_for_commandtoken.announceline)
    print_for_test1("v_device_command_for_commandtoken_commandtype", v_device_command_for_commandtoken.commandtype)
    print_for_test1("v_device_command_for_commandtoken_device", v_device_command_for_commandtoken.device)
    print_for_test3("v_device_names_and_indiv", v_device_names_and_indiv)
    print_for_test1("v_device_names_and_indiv_active", v_device_names_and_indiv.activ)
    print_for_test1("v_device_names_and_indiv_all", v_device_names_and_indiv.active_and_last)
    print_for_test3("v_telnet_socket", v_telnet.socket)
    print_for_test3("v_telnet_surce", v_telnet.source)
    print_for_test3("v_telnet_socket_telnet_no", v_telnet.telnet_number)
    print_for_test3("v_index_of_input_buffer", v_index_of_input_buffer)
    print_for_test3("v_input_buffer_interface", v_input_buffer.interface)
    print_for_test3("v_input_buffer_actual_token", v_input_buffer.actual_token)
    print_for_test3("v_input_buffer_device_index", v_input_buffer.device_index)
    print_for_test3("v_input_buffer_", v_input_buffer.original_command_index)
    print_for_test3("v_input_buffer_actual_command_length_answer", v_input_buffer_actual_command_length.answer)
#    print_for_test3("v_input_buffer_list", v_input_buffer_list)
    print_for_test1("v_kbd_input", v_kbd_input.a)
    print_for_test3("v_line_length_command", v_linelength.command)
    print_for_test3("v_line_length_answer", v_linelength.answer)
    print_for_test3("v_line_length_info", v_linelength.info)
    print_for_test1("v_reserved_commands_for_commandtoken_basic", v_reserved_commands_for_commandtoken.basic)
    print_for_test1("v_reserved_commands_for_commandtoken_error", v_reserved_commands_for_commandtoken.error)
    print_for_test1("v_reserved_commands_for_commandtoken_indiv_read", v_reserved_commands_for_commandtoken.indiv_read)
    print_for_test1("v_reserved_commands_for_commandtoken_indiv_write", v_reserved_commands_for_commandtoken.indiv_write)
    print_for_test1("v_reserved_commands_for_commandtoken_infoc", v_reserved_commands_for_commandtoken.info)
    print_for_test1("v_reserved_commands_for_commandtoken_login", v_reserved_commands_for_commandtoken.login)
    print_for_test3("v_sendstring", v_sendstring.a)
    print_for_test1("v_token_of_basic_announcements", v_token_of_basic_announcements.a)

    return


def print_for_test1(file, data):
    handle = open("check_output/" + file, "w")
    i = 0
    for lines in data:
        handle.write(str(lines) + "\n")
        i += 1
    handle.close()
    return


def print_for_test3(file, data):
    # ------------------------for check
    handle = open("check_output/" + file, "w")
    handle.write(str(data))
    handle.close()
    return


# Main#
v_time_values.last_activity = int(time.time())
v_time_values.last_device_search = int(time.time())
init()
print_for_test()

# 5000 loops / s on coreI7
while 1:
    # input from HI...
    poll_inputs()
    # analyzes the input_buffer
    poll_input_buffer()
    send_input_answer_buffer()
    # get answers and info from normal device and lower level CR
    poll_devices()
    # analyzes the answers and info from devices
    poll_device_buffer()
    send_buffer_to_device()
    time_dependent_tasks()

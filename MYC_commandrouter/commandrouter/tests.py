#
#import time

import time

from misc_functions import *

import v_announcelist
import v_configparameter
import v_cr_params
import v_dev
import v_device_names_and_indiv
import v_kbd_input
import v_linelength
import v_sk
import v_sk_interface
import v_time_values
import v_token_params

# ------------------------------------------------
# subprograms for tests
# ------------------------------------------------


def print_for_test():
    print_for_test1("v_announcelist_basic", v_announcelist.basic)
    print_for_test1("v_announcelist_full", v_announcelist.full)
    print_for_test1("v_announcelist_rules", v_announcelist.rules)
    print_for_test3("v_command_length_adder", v_cr_params.adder)
    print_for_test3("v_command_length_commandtokenlength", v_cr_params.length_commandtoken)
    print_for_test3("v_command_length_reserved_token_start", v_cr_params.reserved_token_start)
    print_for_test3("v_command_length_startnumber", v_cr_params.startnumber)
    print_for_test3("v_command_index_of_cr-commands", v_token_params.index_of_cr_commands)
    print_for_test3("v_cr_params_cr_announcement", v_cr_params.cr_announcement)
    print_for_test3("v_cr_params_name", v_cr_params.full_device_name)
    print_for_test3("v_cr_params_length_of_announcement_length", v_cr_params.length_of_announcement_length)
    print_for_test3("v_cr_params_length_of_last_error_length", v_cr_params.length_last_error_length)
    print_for_test3("v_configparameter_devicegroup", v_configparameter.devicegroup)
    print_for_test3("v_configparameter_my_devices_file", v_configparameter.my_devices_file)
    print_for_test3("v_configparameter_time_for_activ_check", v_configparameter.time_for_activ_check)
    print_for_test3("v_configparameter_time_for_device_search", v_configparameter.time_for_device_search)
    print_for_test3("v_configparameter_time_for_command_timeout", v_configparameter.time_for_command_timeout)
    print_for_test3("v_dev_announceline", v_dev.announceline)
    print_for_test3("v_dev_name", v_dev.name)
    print_for_test3("v_dev_interface_adress", v_dev.interface_adress)
    print_for_test3("v_dev_interface_baudrate", v_dev.interface_baudrate)
    print_for_test3("v_dev_interface_comport", v_dev.interface_comport)
    print_for_test3("v_dev_interface_nofbits", v_dev.interface_number_of_bits)
    print_for_test3("v_dev_interface_port", v_dev.interface_port)
    print_for_test3("v_dev_interface_timeout", v_dev.interface_timeout)
    print_for_test3("v_dev_interface_type", v_dev.interface_type)
    print_for_test3("v_dev_commandtokenlength", v_dev.length_commandtoken)
    print_for_test3("v_dev_data_to_device", v_dev.data_to_device)
    print_for_test3("v_dev_data_to_CR", v_dev.data_to_CR)
    print_for_test1("v_token_params_dev_token", v_token_params.dev_token)
    print_for_test1("v_token_params_device", v_token_params.device)
    print_for_test1("v_token_params_index_of_cr_commands", v_token_params.index_of_cr_commands)
    print_for_test1("v_token_params_index_of_cr_commands_r", v_token_params.index_of_cr_commands_r)
    print_for_test3("v_device_names_and_indiv_nmae", v_device_names_and_indiv.name)
    print_for_test1("v_device_names_and_indiv_active", v_device_names_and_indiv.activ)
    print_for_test1("v_device_names_and_indiv_last", v_device_names_and_indiv.last)
    print_for_test3("v_input_buffer_baudrate", v_sk_interface.baudrate)
    print_for_test3("v_input_buffer_interface_adress", v_sk_interface.interface_adress)
    print_for_test3("v_input_buffer_interface_port", v_sk_interface.interface_port)
    print_for_test3("v_input_buffer_interface_timeout", v_sk_interface.interface_timeout)
    print_for_test3("v_input_buffer_interface_type", v_sk_interface.interface_type)
    print_for_test3("v_input_buffer_numberofbits", v_sk_interface.number_of_bits)
    print_for_test3("v_input_buffer_starttime", v_sk.starttime)
    print_for_test3("v_input_buffer_last_error", v_sk.last_error)
    print_for_test3("v_input_buffer_socket", v_sk_interface.socket)
    print_for_test3("v_input_buffer_source", v_sk_interface.source)
    print_for_test3("v_input_buffer_telnet_no", v_sk_interface.telnet_number)
    print_for_test1("v_kbd_input_data", v_kbd_input.data)
    print_for_test3("v_kbd_input_skdev", v_kbd_input.skdev)
    print_for_test3("v_line_length_answer", v_linelength.answer)
    print_for_test3("v_line_length_command", v_linelength.command)
    print_for_test3("v_line_length_info", v_linelength.info)
    print_for_test3("v_time_values_last_activity", v_time_values.last_activity)
    print_for_test3("v_time_values_last_device_search", v_time_values.last_device_search)

    return


def print_for_test1(file, data):
    handle = open("check_output/" + file, "w")
    for lines in data:
        handle.write(str(lines) + "\n")
    handle.close()
    return


def print_for_test3(file, data):
    # ------------------------for check
    handle = open("check_output/" + file, "w")
    handle.write(str(data))
    handle.close()
    return


def load_check():
    check_file = open(v_time_values.command_file)
    v_time_values.announcement = []
    v_time_values.from_sk = []
    v_time_values.to_dev = []
    v_time_values.errormsg =[]
    v_time_values.check_number = 0
    i = 0
    for lines in check_file:
        if lines[0] == "#":
            continue
        if i == 0:
            v_time_values.announcement.append(lines.rstrip())
        if i == 1:
            v_time_values.from_sk.append(to_ba(lines.rstrip()))
        if i == 2:
            v_time_values.to_dev.append(to_ba(lines.rstrip()))
        if i == 3:
            # errormsg for dev
            v_time_values.errormsg.append(lines.rstrip())
        i += 1
        if i == 4:
            i = 0
    check_file.close()
    return


def to_ba(string):
    # convert (integer) number to bytearray
    i = 0
    ob = bytearray([])
    tempi = ""
    while i < len(string):
        # read each character
        if string[i] == " ":
            # char found
            ob.extend(bytearray([(int(tempi))]))
            tempi = ""
        else:
            tempi += string[i]
        i += 1
    if tempi != "":
        ob.extend(bytearray([int(tempi)]))
    return ob


def to_ba2(string):
    # convert (integer) number  string mixture to bytearray
    # strings are enclosed by the string " \\str\\ "
    i = 0
    str_active = 0
    ob = bytearray([])
    tempi = ""
    last = ""
    cont = 0
    while i < len(string):
        # read each character
        if string[i] == " ":
            # separator for all
            if tempi == "xxstr":
                # stringmarker found
                if str_active == 0:
                    str_active = 1
                    last = ""
                else:
                    str_active = 0
                    ob.extend(str_to_bytearray(last))
                    cont = 0
                tempi = ""
            elif str_active == 1:
                # space in string
                if cont == 1:
                    last += " "
                last += tempi
                cont = 1
                tempi = ""
            else:
                # char found
                ob.extend(bytearray([(int(tempi))]))
                tempi = ""
        else:
            tempi += string[i]
        i += 1
    if tempi != "":
        if str_active == 0:
            ob.extend(bytearray([int(tempi)]))
        else:
            if tempi == "xxstr":
                ob.extend(str_to_bytearray(last))
    return ob

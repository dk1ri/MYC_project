"""
name: tests.py
last edited: 20250414
subprograms for tests
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""
import os.path
from misc_functions import *
import v_announcelist
import v_configparameter
import v_cr_params
import v_dev
import v_linelength
import v_sk
import v_io
import v_token_params

def print_for_test():
    if not os.path.isdir("check_output"):
        os.mkdir("check_output")
    print_for_test1("v_announcelist_all_token", v_announcelist.all_token)
    print_for_test1("v_announcelist_all_answer_token", v_dev.all_answer_toks)
    print_for_test1("v_announcelist_basic", v_announcelist.basic)
    print_for_test2("v_announcelist_full", v_announcelist.full)
    print_for_test1("v_announcelist_full_240", v_announcelist.full_240)
    print_for_test3("v_announcelist_length_of_full_elements", v_announcelist.length_of_full_elements)
    print_for_test1("v_announcelist_rules", v_announcelist.rules)
    print_for_test1("v_announcelist_administration", v_announcelist.administration)
    print_for_test3("v_command_length_startnumber", v_cr_params.startnumber)
    print_for_test3("v_cr_params_name", v_cr_params.full_device_name)
    print_for_test4("v_dev_announceline", v_dev.announcements)
    print_for_test4("v_dev_announceline_not_stripped", v_dev.announcments_not_stripped)
    print_for_test3("v_dev_a_to_o", v_dev.a_to_o)
    print_for_test3("v_dev_name", v_dev.name)
    print_for_test3("v_dev_interface_adress", v_dev.interface_adress)
    print_for_test3("v_dev_interface_baudrate", v_dev.interface_baudrate)
    print_for_test3("v_dev_interface_comport", v_dev.interface_comport)
    print_for_test3("v_dev_interface_nofbits", v_dev.interface_number_of_bits)
    print_for_test3("v_dev_interface_port", v_dev.interface_port)
    print_for_test3("v_dev_interface_timeout", v_dev.interface_timeout)
    print_for_test3("v_dev_interface_type", v_dev.interface_type)
    print_for_test3("v_dev_o_to_a", v_dev.o_to_a)
    print_for_test3("v_dev_commandtokenlength", v_dev.length_commandtoken)
    print_for_test5("v_line_length_answer", v_linelength.answer)
    print_for_test2("v_line_length_command", v_linelength.command)
    print_for_test1("v_kbd_input_data", v_io.data)
    print_for_test3("ld_all_condition_per_index", v_ld.all_condition_per_index)
    print_for_test3("ld_if_unless", v_ld.if_unless)
    print_for_test3("ld_index_by_tok", v_ld.index_by_tok)
    print_for_test3("ld_left_tok_by_index", v_ld.left_tok_by_index)
    print_for_test3("ld_updated", v_ld.updated)
    print_for_test3("ld_stringparameters", v_ld.stringparameters)
    print_for_test3("v_sk_buffer_baudrate", v_sk.baudrate)
    print_for_test3("v_sk_buffer_interface_port", v_sk.interface_com_port)
    print_for_test3("v_sk_buffer_interface_timeout", v_sk.interface_timeout)
    print_for_test3("v_sk_interface_type", v_sk.interface_type)
    print_for_test3("v_sk_buffer_numberofbits", v_sk.number_of_bits)
    print_for_test3("v_sk_buffer_starttime", v_sk.starttime)
    print_for_test3("v_sk_last_error", v_sk.last_error)
    print_for_test3("v_sk_buffer_socket", v_sk.socket)
    print_for_test3("v_sk_buffer_source", v_sk.source)
    print_for_test3("v_sk_buffer_telnet_no", v_sk.telnet_number)
    print_for_test1("v_token_params_cr_token", v_token_params.cr_token)
    print_for_test1("v_token_params_a_to_o", v_token_params.a_to_o)
    print_for_test1("v_token_params_dev_token", v_token_params.dev_token)
    print_for_test1("v_token_params_device", v_token_params.device)
    return


def print_for_test1(file, data):
    handle = open("check_output/" + file, "w")
    for lines in data:
        handle.write(str(lines) + "\n")
    handle.close()
    return

def print_for_test2(file, data):
    # tok as index
    handle = open("check_output/" + file, "w")
    for tok in v_announcelist.all_token:
        try:
            handle.write(str(tok) + ": " + str(data[tok]) + "\n")
        except:
            pass
    handle.close()#
    return

def print_for_test3(file, data):
    # ------------------------for check
    handle = open("check_output/" + file, "w")
    handle.write(str(data))
    handle.close()
    return

def print_for_test4(file, data):
    # device as index
    handle = open("check_output/" + file, "w")
    device = 1
    while device < len(data):
        for line in data[device]:
            handle.write(str(line[0]) + ": " + ";".join(line))
            handle.write("\n")
        device += 1
    handle.close()#
    return

def print_for_test5(file, data):
    # device as index
    handle = open("check_output/" + file, "w")
    device = 0
    for device in v_linelength.answer:
        data = v_linelength.answer[device]
        if len(data) > 0:
            for tok, line in data.items():
                i = 0
                dat = line
                da = "dev: " + str(device) + " tok: "+ str(tok ) + " : "
                while i < len(dat):
                    da += str(dat[i]) + " "
                    i+= 1
                handle.write(da)
                handle.write("\n")
        device += 1
    handle.close()
    return


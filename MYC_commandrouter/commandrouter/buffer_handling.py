"""
name : buffer_handling.py
last edited: 20260414
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""
from io_handling import *
import v_dev
import v_sk
import v_token_params
import v_ld
import v_announcelist
# poll LD inputbuffer see ld_command_handling

# poll device inputbuffer see device_handling

# poll inputs and command_handling operate by bytes
# the other subprograms use listelement: each element contain a complete command / answer / info

def poll_sk():
    # SK input polling
    # inputs from SK, higher level CR...
    # data are send to v_sk.inputline[input_buffer_number]
    input_buffer_number = 0
    while input_buffer_number < len(v_sk.interface_type):
        input_buffer_type = v_sk.interface_type[input_buffer_number]
        if v_sk.active[input_buffer_number] == 1:
            if input_buffer_type == "TERMINAL":
                sk_terminal_in(input_buffer_number)
            elif input_buffer_type == "TELNET":
                # telnet is a separate thread, writimg directly to inputbuffer
                pass
            elif input_buffer_type == "FILE":
                sk_file_in(input_buffer_number)
            elif input_buffer_type == "USB" or input_buffer_type == "RS232":
                sk_serial_in(v_sk.serial_interface[input_buffer_number], input_buffer_number)
            if (len(v_sk.interface_type[input_buffer_number]) > 0):
                analyze_sk_input(input_buffer_number)
        input_buffer_number += 1
    return

def send_to_sk():
    # send to all SK
    if len(v_sk.info_to_all) > 0:
        buffer_number = 0
        while buffer_number < len(v_sk.interface_type):
            if v_sk.active[buffer_number] == 1:
                sk_input_type = v_sk.interface_type[buffer_number]
                if sk_input_type == "TERMINAL":
                    sk_terminal_out()
                elif sk_input_type == "FILE":
                    sk_file_out(v_sk.file_out[buffer_number])
                elif sk_input_type == "RS232" or sk_input_type == "USB":
                    sk_serial_out(buffer_number)
                elif sk_input_type == "TELNET":
                    v_sk.info_to_telnet = v_sk.info_to_all
            buffer_number += 1
        v_sk.info_to_all = bytearray()
    return

def poll_devices():
    # poll for input of devices (answer or info)
    # CR (device == 0) answers of commands and infos are directly written to v_sk.info_to_all
    device = 1
    while device <= len(v_dev.interface_type):
        match  v_dev.interface_type[device]:
            case 0 | 1:
                dev_serial_in(device)
            case 2:
                dev_file_in(device)
        if v_dev.interface_type[device] == "TELNET":
            # telnet is a separate threat, writing directly to inputbuffer
            pass
        device += 1
    return

def send_to_device():
    # output to FU
    # poll v_ld.from_ld_to_dev (original input data with translated toks)
    if len(v_ld.from_ld_to_dev) > 0:
        cr_tok_len = v_announcelist.length_of_full_elements
        if type(v_ld.from_ld_to_dev) is list:
            i = 0
            cr_tok = 0
            while i < cr_tok_len:
                cr_tok = cr_tok * 256 + int(v_ld.from_ld_to_dev[i])
                i += 1
            data_to_send = v_ld.from_ld_to_dev
        else:
            cr_token = v_ld.from_ld_to_dev[:cr_tok_len]
            data_to_send = v_ld.from_ld_to_dev
            # may have more than one byte
            i = 0
            cr_tok = 0
            while i < len(cr_token):
                cr_tok = cr_tok * 256  + int(cr_token[i])
                i += 1
        # replace ct_tok -> dev_tok:
        device = v_dev.device_by_cr_tok[cr_tok]
        v_dev.data_to_device[device].append(v_token_params.dev_token[cr_tok])
        i = v_cr_params.length_commandtoken
        while i < len(data_to_send):
            v_dev.data_to_device[device].append(data_to_send[i])
            i += 1
        l = str(len(v_dev.data_to_device[device]))
        match v_dev.interface_type[device]:
            case 0 | 1:
                dev_serial_out(device)
            case 2:
                dev_file_out(device)
        # delete element
        write_log("to dev "+str(v_dev.name[device]) + " :" + l + " bytes")
        v_dev.data_to_device[device] = bytearray()
        v_ld.from_ld_to_dev = []
    return
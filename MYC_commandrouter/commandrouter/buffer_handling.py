"""
name : buffer_handling.py
last edited: 20260224
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""
from io_handling import *
import v_dev
import v_sk
import v_token_params
import v_ld
# poll LD inputbuffer see ld_command_handling

# poll device inputbuffer see device_handling

# poll inputs and command_handling operate by bytes
# the other subprograms use listelement: each element contain a complete command / answer / info

def poll_sk():
    # input polling
    # inputs from SK, higher level CR...
    # Terminal and Telnet only up to now
    # data are send to v_sk.inputline
    input_buffer_number = 0
    while input_buffer_number < len(v_sk.interface_type):
        if int(v_sk.active[input_buffer_number]) == 1:
            if v_sk.interface_type[input_buffer_number] == "TERMINAL":
                sk_terminal_in(input_buffer_number)
            elif v_sk.interface_type[input_buffer_number] == "FILE":
                sk_file_in()
            elif v_sk.interface_type[input_buffer_number] == "RS232":
               serial_in_from_sk()
            elif v_sk.interface_type[input_buffer_number] == "TELNET":
                # telnet is a separate thread, writimg directly to inputbuffer
                pass
        input_buffer_number += 1
    return

def send_to_sk():
    if v_sk.info_to_all != bytearray([]):
        # send to all SK
        input_buffer_number = 0
        while input_buffer_number < len(v_sk.interface_type):
            if v_sk.active[input_buffer_number] == 1:
                if len(v_sk.info_to_all) > 0:
                    if v_sk.interface_type[input_buffer_number] == "TERMINAL":
                        sk_terminal_out()
                    elif v_sk.interface_type[input_buffer_number] == "FILE":
                        sk_file_out()
                    elif v_sk.interface_type[input_buffer_number] == "RS232":
                        sk_serial_out()
                    elif v_sk.interface_type[input_buffer_number] == "TELNET":
                        v_sk.info_to_telnet = v_sk.info_to_all
            input_buffer_number += 1
    v_sk.info_to_all = bytearray([])
    return

def poll_devices():
    # poll for input from devices (answer or info)
    # output is v_dev.data_to_CR
    # CR (device == 0) answers of commands and infos are directly written to v_sk.info_to_all
    device = 1
    while device < len(v_dev.interface_type):
        match  v_dev.interface_type[device]:
            case "RS232"|"USB":
                serial_in_from_dev(device)
            case "FILE":
                dev_file_in(device)
        if v_dev.interface_type[device] == "TELNET":
            # telnet is a separate threat,writimg directlx to inputbuffer
            pass
        device += 1
    return

def send_to_device():
    # output to FU
    # poll v_ld.from_ld_to_dev (original input data with translated toks)
    if len(v_ld.from_ld_to_dev) > 0:
        cr_token = v_ld.from_ld_to_dev[:v_announcelist.length_of_full_elements]
        cr_tok_len = len(cr_token)
        # may have more than one byte
        i = 0
        cr_tok = 0
        while i < len(cr_token):
            cr_tok = cr_tok * (256 ** i)  + cr_token[i]
            i += 1
        device = v_dev.device_by_tok[cr_tok]
        v_dev.data_to_device[device] = [v_token_params.dev_token[int.from_bytes(cr_token)]]
        # replace ct_tok -> dev_tok:
        i = cr_tok_len
        while i < len(v_ld.from_ld_to_dev):
            v_dev.data_to_device[device].append(v_ld.from_ld_to_dev[i])
            i += 1
        match v_dev.interface_type[device]:
            case "RS232"|"USB":
                dev_serial_out(device)
            case "FILE":
                dev_file_out(device)
        # delete element
        print ("to dev ", v_dev.interface_type[device], v_dev.data_to_device[device])
        v_dev.data_to_device[device] = []
        v_ld.from_ld_to_dev = []
    return



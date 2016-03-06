# command handling subprograms

from commandrouter_analyze_linelength import *
from commandrouter_own_commands import *
from commandrouter_misc_functions import *

import v_device_buffer

# ------------------------------------------------
# start of commandhandling
# ------------------------------------------------


def poll_input_buffer():
    input_device = 0
    # something received from HI, PQ ... ?
    for line in v_input_buffer.inputline:
        # if input data is correct and complete appropriate action is called
        # nothing to do
        if line == "":
            continue
        # commandrouter basic announcement
        if ord(line[0]) == 0:
            com0(input_device)
            finish_command(input_device, 1)
            continue
        l = len(line)
        # wait for further bytes
        if l < v_input_buffer.wait[input_device]:
            continue
        # commandtoken ready?
        if l < v_command_length.commandtokenlength:
            continue
        # got token
        tokennumber = bytes_to_int(line[0:v_command_length.commandtokenlength])
        # commandtoken already set: actual commandtoken as int
        if v_input_buffer.actual_token[input_device] != 0:
            no_cr_command(input_device, tokennumber)
        else:
            # commandrouter own (reserved) commands
            if tokennumber >= v_command_length.reserved_token_start:
                # call the commandrouter own commands
                delete = v_constants.command[tokennumber](input_device)
                if delete > 0:
                    finish_command(input_device, delete)
                # else: more input needed
            # other command
            else:
                # valid command
                if tokennumber in v_all_command_token.a:
                    v_input_buffer.actual_token[input_device] = tokennumber
                    v_input_buffer.actual_token_string[input_device] = v_input_buffer.inputline[input_device][0:v_command_length.commandtokenlength]
                    tokenindex = v_all_command_token.a.index(tokennumber)
                    # original device for that command
                    v_input_buffer.device_index[input_device] = v_device_command_for_commandtoken.device[tokenindex]
                    # original command
                    v_input_buffer.original_command_index[input_device] = v_device_command_for_commandtoken.command[tokenindex]
                    no_cr_command(input_device, tokennumber)
                else:
                    v_input_buffer.last_error[input_device] = "no valid commandtoken "+str(v_command_number.a)
                    finish_command(input_device, v_command_length.commandtokenlength)
        input_device += 1
    return


def no_cr_command(input_device, tokennumber):
    # l include commandtoken
    # this is the index for v_linelength
    tok = tokennumber - v_command_length.adder
    finished = 0
    error = ""
    outstanding = 0
    i = 0
    # check complete line, one loop per character
    while i < len(v_linelength.command[tok][0]):
        # not yet set, first loop
        if v_input_buffer.wait == 0:
            # inputline without commandtoken
            error, outstanding, finished = analyze_length(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength], 0, tok, "c")
            v_input_buffer.wait = v_command_length.commandtokenlength + outstanding
        else:
            # inputline without commandtoken
            error, outstanding, finished = analyze_length(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength], 0, tok, "c")
            v_input_buffer.wait = v_command_length.commandtokenlength + outstanding
        i += 1
    if finished == 1:
        device = v_device_command_for_commandtoken.device[v_all_command_token.a.index(tokennumber)]
        data = retranslate(input_device, device, 0)
        data += v_input_buffer.inputline[v_command_length.commandtokenlength:v_command_length.commandtokenlength + outstanding]
        transfer_to_device_buffer(device, data, tok)
        finish_command(input_device, v_command_length.commandtokenlength + outstanding)
    # later copied to logfile
    print("error : ", error)
    return


def retranslate(input_device, device, start):
    # retranlate one token  from CR token to devicetoken
    # cr_token is the index to v_device_command_for commandtoken
    # return 0 if not valid
    # integer
    cr_token = bytes_to_int(v_input_buffer.inputline[input_device][start:start+v_command_length.commandtokenlength])
    # retranslated token must have this length
    l = v_device_buffer.commandtokenlength[device]
    try:
        ret = int_to_bytes(v_device_command_for_commandtoken.command[v_all_command_token.a.index(cr_token)], l)
    # if not v_device_command_for_commandtoken.command[v_all_command_token.a.index(cr_token) in
    # v_device_command.token[device]]:
    except ValueError:
        ret = 0
    return ret


def transfer_to_device_buffer(device, data, tok):
    # command send to devicebuffer
    # write actual CR command and corresponding device_command to device (for use during abswer)
    # data to send
    v_device_buffer.data_to_device[device] = data
    # index to CR token
    v_device_buffer.actual_CR_token_index = tok
    # corresponing device token
    v_device_buffer.actual_device_token = v_device_command_for_commandtoken.command[tok]
    return


def finish_command(input_device, delete):
    # call clear_v_input_buffer.a, is called, when the handlindling if a command is finished
    # and data transfered to devicebuffer
    # called, before answer erives
    print("command finished")
    v_command_number.a += 1
    clear_input_buffer(input_device, delete)
    return


def clear_input_buffer(input_device, delete):
    # reset some values of v_input_buffer after command finished
    # actual commandtoken as int; 0 array cleared
    v_input_buffer.actual_token[input_device] = 0
    # actual commandtoken as str
    v_input_buffer.actual_token_string[input_device] = ""
    # actual input buffer
    v_input_buffer.inputline[input_device] = v_input_buffer.inputline[input_device][delete:]
    # actual index to device involved
    v_input_buffer.device_index[input_device] = 0
    # actual index to command within device
    v_input_buffer.original_command_index[input_device] = 0
    # starttime
    v_input_buffer.starttime[input_device] = 0
    # wait for next action
    v_input_buffer.wait[input_device] = 0
    return

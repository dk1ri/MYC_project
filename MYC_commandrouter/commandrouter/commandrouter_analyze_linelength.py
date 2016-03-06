"""

input linelength is the string for a command from one of the three v_linelength arrays

return:    error:           message, usr by calling function for commands only, answers and infos should be errorfree
           position_next_action:   data must have data at that position, when this is call again. 0: no action at  start
           fiish:           no need to call this sub again,
"""


from commandrouter_misc_functions import *
import v_linelength
import v_device_buffer


# line do not include commandtoken; device is 0 for command
def analyze_length(line, device, tok, cai):
    error = ""
    position_next_action = 0
    finish = 1
    linelength = []
    if cai == "c":
        # local copy
        linelength = v_linelength.command[tok]
    elif cai == "a":
        linelength = v_linelength.answer[tok]
    elif cai == "i":
        linelength = v_linelength.info[tok]
    # called once
    if linelength[0] == "e":
        error = "not valid or other error"
    # command only
    elif linelength[0] == "b":
        error = "not valid or other error"
    # called once
    elif linelength[0] == "n":
        # wait for one numbers, than finish
        position_next_action = linelength[1]
    # called 2 times
    elif linelength[0] == "s":
        # 1st call
        if v_device_buffer.elementnumber[device] == 0:
            # wait for first parameter and linelength
            position_next_action = linelength[1]
            # so it will be calles  again
            finish = 0
        # 2nd call
        else:
            # number of bytes for string
            length_of_string = bytes_to_int(line[linelength[2]:linelength[2] + linelength[3]])
            k = 0
            st = ""
            while k < len(line):
                st += str(k) + ": " + str(bytes_to_int(line[k])) + " "
                k += 1

            if length_of_string == 0:
                error = "number of bytes = 0"
                position_next_action = linelength[3]
                v_device_buffer.stringlength[device] = 0
            # set complete length
            else:
                v_device_buffer.stringlength[device] = length_of_string
                position_next_action = linelength[1] + length_of_string
                finish = 1
    else:
        error = "no valid commandtype"
    return error, position_next_action, finish

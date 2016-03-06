"""

------------------------------------------------
commandhandling of commandrouter own commands
details see MYC commands specification
def comxxx()
------------------------------------------------
"""
import v_input_buffer
import v_command_number
import v_configparameter
from commandrouter_command_handling import *
from commandrouter_create_new_announce_list import *
from commandrouter_misc_functions import *


def com0(input_device):
    # actual answer buffer
    v_input_buffer.answerline[input_device].append(commandrouter_misc_functions.add_length(v_announcelist.basic[0], 0))
    # ready
    v_input_buffer.answer_ready[input_device] = 1
    return


def com240(input_device):
    l = len(v_input_buffer.inputline[input_device])
    # two parameter with length of commandtoken
    if l < 3 * v_command_length.commandtokenlength:
        return 0
    number_of_lines = bytes_to_int(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:v_command_length.commandtokenlength + v_command_length.commandtokenlength])
    start_line = bytes_to_int(v_input_buffer.inputline[input_device][2 * v_command_length.commandtokenlength:3 * v_command_length.commandtokenlength])
    if start_line >= len(v_announcelist.full) or number_of_lines >= len(v_announcelist.full):
        v_input_buffer.last_error[input_device] = "wrong parameter: " + str(v_command_number.a)
        return 3 * v_command_length.commandtokenlength

    i = start_line
    while i < len(v_announcelist.full):
        if number_of_lines == 0:
            break
        v_input_buffer.answerline[input_device].append(add_length(v_announcelist.full[i], v_commandrouter_params.length_of_announcement_length))
        i += 1
        number_of_lines -= 1
    i = 0
    while number_of_lines > 0:
        v_input_buffer.answerline[input_device].append(add_length(v_announcelist.full[i], v_commandrouter_params.length_of_announcement_length))
        number_of_lines -= 1
    v_input_buffer.answer_ready[input_device] = 1
    return 3 * v_command_length.commandtokenlength


def com252(input_device):
    l = 1
    for lines in v_commandrouter_announcements.a:
        if lines.split(";"[0]) == "252":
            # length of stringlrngth
            l = length_of_int(lines.split(";")[2].split(",")[0])
            break
    v_input_buffer.answerline[input_device].append(add_length(str(v_command_number.a) + ": "+v_input_buffer.last_error[input_device], l))
    v_input_buffer.answer_ready[input_device] = 1
    return v_command_length.commandtokenlength


def com253(input_device):
    v_input_buffer.answerline[input_device].append(chr(0x04))
    v_input_buffer.answer_ready[input_device] = 1
    return v_command_length.commandtokenlength


def com254(input_device):
    # write individualization
    # Interface type cannot be changend
    # got first parameter? (1 byte)
    if len(v_input_buffer.inputline[input_device]) < v_command_length.commandtokenlength + 1:
        return 0
    # first Parameter: position of property
    first_parameter = ord(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength])
    error = 1
    # name
    if first_parameter == v_commandrouter_params.name[1]:
        # got first parameter + stringlength *(2 byte)
        if len(v_input_buffer.inputline[input_device]) < v_command_length.commandtokenlength+2:
            return 0
        # one byte stringlength
        l = ord(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength + 1:v_command_length.commandtokenlength + 2])
        full_length = v_command_length.commandtokenlength + 2 + l
        # line complete?
        if len(v_input_buffer.inputline[input_device]) < full_length:
            return 0
        new_name = v_input_buffer.inputline[input_device][v_command_length.commandtokenlength + 2:full_length]
        modify("NAME", new_name, 0)
        create_new_announce_list()
        error = 0
    # number
    elif first_parameter == v_commandrouter_params.number[1]:
        # got first parameter + number *(2 byte)
        if len(v_input_buffer.inputline[input_device]) < v_command_length.commandtokenlength + 2:
            return 0
        new_number = str(ord(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength + 1:v_command_length.commandtokenlength+2]))
        modify("NUMBER", new_number, 0)
        create_new_announce_list()
        error = 0
    else:
        i = 0
        j = 0
        found = 0
        ifp = ""
        additional_byte = 0
        while i < len(v_input_buffer.interface):
            j = 0
            while j < len(v_input_buffer.interface[i]):
                if first_parameter == v_input_buffer.interface[i][j + 2]:
                    # interfaceparameter
                    ifp = v_input_buffer.interface[i][j] .split(",")[1]
                    # additional bytes to wait for
                    if ifp == "TIMEOUT" or ifp == "ADRESS" or ifp == "COMPORT" or ifp == "BAUDRATE":
                        additional_byte = 1
                        found = 1
                        break
                    elif ifp == "PORT":
                        additional_byte = 2
                        found = 1
                        break
                    elif ifp == "NUMBER_OF_BYTES":
                        additional_byte = 3
                        found = 1
                        break
                j += 3
            if found == 1:
                break
            i += 1
        # 1 parameter + l
        if len(v_input_buffer.inputline[input_device]) < v_command_length.commandtokenlength + 1:
            return 0
        new_value = v_input_buffer.inputline[input_device][2:2 + additional_byte]
        if len(v_input_buffer.interface[i][j].split(",")) > 2:
            # 3rd field is description of values
            ok = detect_range(new_value, v_input_buffer.interface[i][j])[2]
            if ok == 1:
                modify(ifp, new_value, first_parameter)
                create_new_announce_list()
        else:
            modify(ifp, new_value, first_parameter)
            create_new_announce_list()
    if error == 1:
        v_input_buffer.last_error[input_device] = "no valid parameter index for individualization write: " + str(v_command_number.a)
    return 1


def modify(parameter, new_parameter, index):
    # for 254 command modify announcemntfile of the commandrouter
    line_number = 0
    new_line = ""
    for lines in v_commandrouter_announcements.a:
        # modify this line
        if lines[0:3] == "254":
            item = lines.split(";")
            i = 2
            while i < len(item):
                item1 = item[i].split(",")
                if len(item1) > 2:
                    if item1[1] == parameter:
                        item1[2] = new_parameter
                        item[i] = ",".join(item1)
                        break
                i += 1
            new_line = ";".join(item)
            v_commandrouter_announcements.a[line_number] = new_line
            break
        line_number += 1
    config_file = open(v_configparameter.announcements)
    configtemp = []
    i = 0
    for lines in config_file:
        if lines[0:3] != "254":
            configtemp.append(lines.rstrip())
        else:
            configtemp.append(new_line)
        i += 1
    config_file.close()
    config_file = open(v_configparameter.announcements, "w")
    for lines in configtemp:
        config_file.write(lines + "\n")
    config_file.close()
    if parameter == "NAME":
        v_commandrouter_params.name[0] = new_parameter
    elif parameter == "NUMBER":
        v_commandrouter_params.number[0] = new_parameter
    else:
        # modify lists
        i = 0
        while i < len(v_input_buffer.interface):
            if v_input_buffer.interface[2] == index:
                v_input_buffer.interface[1] = new_parameter
                break
            i += 1
    return


# read individualization
def com255(input_device):
    # one additional byte (not more than 255 parameters)
    if len(v_input_buffer.inputline[input_device]) < v_command_length.commandtokenlength + 1:
        return 0
    # first Parameter: position of property
    first_parameter = ord(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength])
    error = 1
    if first_parameter == v_commandrouter_params.name[1]:                       #
        v_input_buffer.answerline[input_device].append(add_length(v_commandrouter_params.name[0], v_commandrouter_params.length_of_name_length))
        error = 0
    # number
    elif first_parameter == v_commandrouter_params.number[1]:
        v_input_buffer.answerline[input_device].append(chr(v_commandrouter_params.number[0]))
        error = 0
    # interface
    else:
        i = 0
        while i < len(v_input_buffer.interface):
            j = 0
            while j < len(v_input_buffer.interface[i]):
                if first_parameter == v_input_buffer.interface[i][j+2]:
                    try:
                        v_input_buffer.interface[i][j+1] += 0
                        v_input_buffer.answerline[input_device].append(int_to_bytes(v_input_buffer.interface[i][j + 1], 1))
                    except TypeError:
                        # no paramter need more than one byte for length
                        v_input_buffer.answerline[input_device].append(add_length(v_input_buffer.interface[i][j + 1], 1))
                    error = 0
                    break
                j += 3
            i += 1
    if error == 1:
        v_input_buffer.last_error[input_device] = "no valid parameter for individualization read: " + str(v_command_number.a)
    else:
        v_input_buffer.answer_ready[input_device] = 1
    return 1

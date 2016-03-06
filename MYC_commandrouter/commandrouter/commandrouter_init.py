"""
------------------------------------------------
initialization, programs are used at start only
------------------------------------------------
"""

import sys
import os

from commandrouter_ethernet_handling import *
from commandrouter_terminal_handling import *
import v_commandrouter_announcements
import v_device_names_and_indiv
import v_configparameter
import v_input_buffer_list

# variables per device
import v_device_command
import v_device_announce
import v_device_buffer
import v_lower_level_cr

# variables per input
import v_input_buffer_actual_command_length

import v_commandrouter_params


def readconfig(arg):
    # configfile can be given with full path
    # configfile is read read to v_configparameter[]
    # for details of parameters see manual -> files
    if len(arg) > 1:
        config_file = arg[1]
    else:
        config_file = "./config_commandrouter"
    if not os.path.isfile(config_file):
        sys.exit("Missing file:  " + config_file)
    config_file = open(config_file)
    i = 0
    # sequence within file is fixed!!!
    for lines in config_file:
        if lines[0] == "#":
            continue
        # filename of commandrouter announcements
        if i == 0:
            if lines.rstrip() == "home":
                v_configparameter.announcements = "announcements_commandrouter"
            else:
                v_configparameter.announcements = lines.rstrip()
                if not os.path.isfile(v_configparameter.announcements):
                    sys.exit("Missing file:  " + v_configparameter.announcements)
        # dir for my_devices
        if i == 1:
            if lines.rstrip() == "home":
                v_configparameter.my_devices_dir = "."
            else:
                v_configparameter.my_devices_dir = lines.rstrip()
            if not os.path.isdir(v_configparameter.my_devices_dir):
                sys.exit("Missing dir:  " + v_configparameter.my_devices_dir)
        # nameprefix fo my_devices
        if i == 2:
            if lines.rstrip() == "home":
                v_configparameter.my_devices_prefix = "my_device_"
            else:
                v_configparameter.my_devices_prefix = lines.rstrip()
        # location of local devicegroupfiles
        if i == 3:
            if lines.rstrip() == "home":
                v_configparameter.devicegroup = "./"
            else:
                v_configparameter.devicegroup = lines.rstrip()
            if not os.path.isdir(v_configparameter.devicegroup):
                sys.exit("Missing dir:  " + v_configparameter.devicegroup)
        if i == 4:
            # time in sec for checking weather a device is active
            v_configparameter.time_for_activ_check = int(lines.rstrip())
        if i == 5:
            # time in sec for searching for new devices
            v_configparameter.time_for_device_search = int(lines.rstrip())
        if i == 6:
            # time in sec for command timeout
            v_configparameter.time_for_command_timeout = int(lines.rstrip())
        i += 1
    config_file.close()
    if i != 7:
        sys.exit("wrong number of configparameters")
    return


def read_commandrouter_annoucements():

    # read at int only. Adding / deleting inputs for HI / PR require new start
    # read commandrouter announcements to commandrouter_announcements[]
    # extract data to v_commandrouter_params[] in inputbuffer
    # from individualzation  line (254) read the parameters for input devices and call their  initialization
    # commandtoken of commandrouter_announcements[] will be modified to word .. if necessary later

    commandrouter_announcement = open(v_configparameter.announcements)
    # file read
    for linesx in commandrouter_announcement:
        if linesx[0] != "#":
            lines = linesx.rstrip()
            v_commandrouter_announcements.a.append(lines)
            if lines[0:3] == "252":
                v_commandrouter_params.length_of_last_error_length = length_of_int(int(lines.split(";")[2].split(",")[0]))
            # initialize commandrouter inputs for user interface etc ...
            if lines[0:3] == "254":
                item = lines.split(";")
                i = 3
                # scan all i>1
                while i < len(item):
                    item1 = item[i].split(",")
                    if item1[1] == "TERMINAL":
                        m = init_inputbuffer(item1[1], item1[2])
                        v_input_buffer.interface[m].append("TERMINAL")
                        v_input_buffer.interface[m].append(item1[2])
                    elif item1[1] == "TELNET":
                        m = init_inputbuffer(item1[1], item1[2])
                        v_input_buffer.interface[m].append("TELNET")
                        v_input_buffer.interface[m].append(item1[2])
                        v_input_buffer.interface[m].append("")              # for port
                        v_input_buffer.interface[m].append(0)               # for timeout
                    elif item1[1] == "HTTP":
                        m = init_inputbuffer(item1[1], item1[2])
                        v_input_buffer.interface[m].append("HTTP")
                        v_input_buffer.interface[m].append(item1[2])
                        v_input_buffer.interface[m].append("")              # for port
                        v_input_buffer.interface[m].append(0)               # for timeout
                    elif item1[1] == "HTTPS":
                        m = init_inputbuffer(item1[1], item1[2])
                        v_input_buffer.interface[m].append("HTTPS")
                        v_input_buffer.interface[m].append(item1[2])
                        v_input_buffer.interface[m].append("")              # for port
                        v_input_buffer.interface[m].append(0)               # for timeout
                    elif item1[1] == "I2C":
                        m = init_inputbuffer(item1[1], item1[2])
                        v_input_buffer.interface[m].append("I2C")
                        v_input_buffer.interface[m].append(item1[2])
                        v_input_buffer.interface[m].append(0)               # for adress
                    elif item1[1] == "CAN":
                        m = init_inputbuffer(item1[1], item1[2])
                        v_input_buffer.interface[m].append("CAN")
                        v_input_buffer.interface[m].append(item1[2])
                        v_input_buffer.interface[m].append(0)               # for adress
                    elif item1[1] == "RC5":
                        m = init_inputbuffer(item1[1], item1[2])
                        v_input_buffer.interface[m].append("RC5")
                        v_input_buffer.interface[m].append(item1[2])
                        v_input_buffer.interface[m].append(0)               # for adress
                    elif item1[1] == "RC6":
                        m = init_inputbuffer(item1[1], item1[2])
                        v_input_buffer.interface[m].append("RC6")
                        v_input_buffer.interface[m].append(item1[2])
                        v_input_buffer.interface[m].append(0)               # for adress
                    elif item1[1] == "RS232":
                        m = init_inputbuffer(item1[1], item1[2])
                        v_input_buffer.interface[m].append("RS232")
                        v_input_buffer.interface[m].append(item1[2])
                        v_input_buffer.interface[m].append(0)               # Baudrate
                        v_input_buffer.interface[m].append("")              # like 8N1
                        v_input_buffer.interface[m].append(0)               # port
                    elif item1[1] == "USB":
                        m = init_inputbuffer(item1[1], item1[2])
                        v_input_buffer.interface[m].append("USB")
                        v_input_buffer.interface[m].append(item1[2])
                    elif item1[1] == "PORT":
                        m = len(v_input_buffer.interface) - 1
                        if v_input_buffer.interface[m][0] == "TELNET" or v_input_buffer.interface[m][0] == "HTTP":
                            v_input_buffer.interface[m][2] = int(item1[2])
                    elif item1[1] == "TIMEOUT":
                        m = len(v_input_buffer.interface) - 1
                        if v_input_buffer.interface[m][0] == "TELNET" or v_input_buffer.interface[m][0] == "HTTP":
                            v_input_buffer.interface[m][3] = int(item1[2])
                    elif item1[1] == "ADRESS":
                        m = len(v_input_buffer.interface) - 1
                        if v_input_buffer.interface[m][0] == "RC5" or v_input_buffer.interface[m][0] == "RC&":
                            v_input_buffer.interface[m][2] = int(item1[2])
                    elif item1[1] == "BAUDRATE":
                        m = len(v_input_buffer.interface) - 1
                        if v_input_buffer.interface[m][0] == "RS232":
                            v_input_buffer.interface[m][2] = int(item1[2])
                    elif item1[1] == "COMPORT":
                        m = len(v_input_buffer.interface) - 1
                        if v_input_buffer.interface[m][0] == "RS232":
                            v_input_buffer.interface[m][3] = int(item1[2])
                    elif item1[1] == "NUMBER_OF_BITS":
                        m = len(v_input_buffer.interface) - 1
                        if v_input_buffer.interface[m][0] == "RS232":
                            v_input_buffer.interface[m][4] = item1[2]
                    # second fild is the option
                    elif item1[1] == "NAME":
                        # name as string wihout length
                        v_commandrouter_params.name.append(item1[2])
                        # index of field in announceline
                        v_commandrouter_params.name.append(i)
                        v_commandrouter_params.length_of_name_length = length_of_int(int(item1[0]))
                    elif item1[1] == "NUMBER":
                        v_commandrouter_params.number.append(int(item1[2]))
                        # index of field in announceline
                        v_commandrouter_params.number.append(i)
                    i += 1
                i = 0
                while i < len(v_input_buffer.interface):
                    if v_input_buffer.interface[i][0] == "TELNET":
                        if v_input_buffer.interface[i][2] > 0:
                            start_ethernet_server(v_input_buffer.interface[i][2], len(v_input_buffer.interface) - 1)
                    i += 1
# other interfaces will follow...
#
    commandrouter_announcement.close()
    return


def init_inputbuffer(device_type, name):
    # update or initialize one v_input_buffer
    # name must be unique,
    m = len(v_input_buffer.name)
    v_input_buffer.name.append([])
    # name
    v_input_buffer.name[m] = device_type + name
    v_input_buffer.actual_token.append([])
    # actual commandtoken as int
    v_input_buffer.actual_token[m] = 0
    v_input_buffer.actual_token_string.append([])
    # actual commandtoken as int
    v_input_buffer.actual_token_string[m] = ""
    v_input_buffer.inputline.append([])
    # actual input buffer
    v_input_buffer.inputline[m] = ""
    v_input_buffer.answerline.append([])
    # actual answer buffer
    v_input_buffer.answerline[m] = []
    v_input_buffer.answer_ready.append([])
    # actual answer ready
    v_input_buffer.answer_ready[m] = 0
    v_input_buffer.device_index.append([])
    # actual index to device involved
    v_input_buffer.device_index[m] = 0
    v_input_buffer.original_command_index.append([])
    # actual index to command within device
    v_input_buffer.original_command_index[m] = 0
    v_input_buffer.starttime.append([])
    # starttime
    v_input_buffer.starttime[m] = 0
    v_input_buffer.last_error.append([])
    # last error message
    v_input_buffer.last_error[m] = "no error"
    v_input_buffer.wait.append([])
    # wait
    v_input_buffer.wait[m] = 0
    v_input_buffer.interface.append([])
    # interface paramter
    v_input_buffer.interface[m] = []
    v_input_buffer_list.interface_type.append([])
    v_input_buffer_list.interface_type[m] = type
    v_input_buffer_list.name.append([])
    v_input_buffer_list.name[m] = device_type + name
#
    v_input_buffer_actual_command_length.command.append([])
    v_input_buffer_actual_command_length.answer.append([])
    v_input_buffer_actual_command_length.info.append([])
    return m


def read_my_devices():
    # executed at start and every x minutes
    # add new devices but do not delete
    # different devices must have different basic announcements and / or different induvidualization ie:
    # file content must be unique !!!
    # this sub generates device_names_and_indiv.all and device_names_and_indiv.activ only
    # (and call read of lower level CR if necessary
    # program crashes, if filenames contain special characters
    prefix_len = len(v_configparameter.my_devices_prefix)
    files_dirs = os.listdir(v_configparameter.my_devices_dir)
    for name in files_dirs:
        if len(name) > prefix_len:
            if name[0:prefix_len] == v_configparameter.my_devices_prefix:
                my_dev_file = open(v_configparameter.my_devices_dir+name)
                switch = 0
                i = 0
                # additional devices?
                for lines in my_dev_file:
                    if lines == "" or lines[0] == "#":
                        continue
                    # first line, base
                    if switch == 0:
                        basic_line = lines.rstrip()
                        switch = 1
                    # second line: indiv
                    else:
                        indiv = lines.rstrip()
                        full_indiv_line = basic_line + ";" + indiv
                        item = basic_line.split(";")
                        # avoid dupes while reread
                        if full_indiv_line in v_device_names_and_indiv.active_and_last:
                            continue
                        else:
                            v_device_names_and_indiv.active_and_last.append(full_indiv_line)
                            v_device_names_and_indiv.activ.append(1)
                            item1 = item[1].split(",")
                            # lower level CR
                            if item1[0] == "c":
                                v_lower_level_cr.a.append(full_indiv_line)
                            device = initialize_device()
                            initialize_device_interface(indiv, device)
                            read_announcements_of_a_device(indiv, device)
                        switch = 0
                        i += 1
                my_dev_file.close()
    return
#
"""
------------------------------------------------
tasks, with new device
------------------------------------------------
"""


def initialize_device():
    # create new device_buffer
    # device point to the next empty element
    device = len(v_device_names_and_indiv.active_and_last) - 1
    v_device_buffer.name.append([])
    # name of that device (devicegroup and indiv)
    v_device_buffer.name[device] = v_device_names_and_indiv.active_and_last[device]
    # list: interfaceparameters of device
    v_device_buffer.interface.append([])
#    v_device_buffer.interface[device] = []
    v_device_buffer.commandtokenlength.append([])
    # commandlength of commands for device
    v_device_buffer.commandtokenlength[device] = 0
    v_device_buffer.actual_CR_token_index.append([])
    # actual index to commandtoken in work, 0, nothing actual, token of CR announcelist
    v_device_buffer.actual_CR_token_index[device] = 0
    v_device_buffer.actual_device_token.append([])
    # corresponding device_token
    v_device_buffer.actual_device_token[device] = 0
    v_device_buffer.data_to_device.append([])
    # data to send
    v_device_buffer.data_to_device[device] = ""
    v_device_buffer.wait_for_answer.append([])
    # actual need to wait for answer? as int
    v_device_buffer.wait_for_answer[device] = 0
    v_device_buffer.data_to_CR.append([])
    # actual received answer buffer from device
    v_device_buffer.data_to_CR[device] = ""
    v_device_buffer.bytenumber_for_next_action.append([])
    # byte position for next call of analyze_linelength
    v_device_buffer.bytenumber_for_next_action[device] = 0
    v_device_buffer.all_comandtoken.append([])
    # list of all commandtoken
    v_device_buffer.answer_info_finished.append([])
    # set if linelength data are complete
    v_device_buffer.answer_info_finished[device] = 0
    v_device_buffer.stringlength.append([])
    # for strings: actual length
    v_device_buffer.stringlength[device] = 0
    v_device_buffer.elementnumber.append([])
    # for strings: actual length
    v_device_buffer.elementnumber[device] = 0
    return device


def initialize_device_interface(indiv, device_number):
    # devices have one interface only
    # array alrady generated
    item = indiv.split(";")
    i = 3
    while i < len(item):
        item1 = item[i].split(",")
        if item1[1] == "TERMINAL":
            v_device_buffer.interface[device_number].append("TERMINAL")
            v_device_buffer.interface[device_number].append(item1[2])
            i += 1
            continue
        if item1[1] == "I2C":
            v_device_buffer.interface[device_number].append("I2C")
            v_device_buffer.interface[device_number].append(item1[2])
            # for adress
            v_device_buffer.interface[device_number].append(0)
            i += 1
            continue
        if item1[1] == "TELNET":
            v_device_buffer.interface[device_number].append("TELNET")
            v_device_buffer.interface[device_number].append(item1[2])
            # for adress
            v_device_buffer.interface[device_number].append(0)
            # for portnumber
            v_device_buffer.interface[device_number].append(0)
            # for timeout
            v_device_buffer.interface[device_number].append(0)
            i += 1
            continue
        # error in devicelist
        if not v_device_buffer.interface[device_number]:
            i += 1
            continue
        if v_device_buffer.interface[device_number][0] == "I2C" and item1[1] == "ADRESS":
            v_device_buffer.interface[device_number][1] = item1[2]
        if v_device_buffer.interface[device_number][0] == "TELNET" and item1[1] == "ADRESS":
            v_device_buffer.interface[device_number][1] = item1[2]
        if v_device_buffer.interface[device_number][0] == "TELNET" and item1[1] == "PORTNUMBER":
            v_device_buffer.interface[device_number][2] = int(item1[2])
        if v_device_buffer.interface[device_number][0] == "TELNET" and item1[1] == "TIMEOUT":
            v_device_buffer.interface[device_number][3] = int(item1[2])
        i += 1
    if v_device_buffer.interface[device_number][0] == "Telnet":
        # host and port must exist
        if v_device_buffer.interface[device_number][2] != "" and v_device_buffer.interface[device_number][3] > 0:
            start_ethernet_client(v_device_buffer.interface[device_number][2], v_device_buffer.interface[device_number][3], device_number)
    return


def read_announcements_of_a_device(indiv, device_number):
    # read announcements of one new device and resolve duplicate commandtoken / commandtype:
    # delete ANNOUNCEMENT line
    # find number of commands (excluding  rules and ANNOUNCEMENT line)
    # device point to the actual element
    device = len(v_device_names_and_indiv.active_and_last) - 1
    device_temp_command = []
    device_temp_announce = []
    # load announcements an resolve duplicate token ans "as" lines
    line = v_device_names_and_indiv.active_and_last[device]
    item1 = split_desc(line)
    item = item1.split(";")
    file = v_configparameter.devicegroup + item[2] + "_" + item[3] + "_" + item[4]
    device_group_file = open(file)
    # for check of duplicate token
    token_of_a_device = []
    # index for announcement
    k = 0
    # index for command
    i = 0
    # max of lokal commandtoken
    max_number_for_local_commands = 0
    # resolve duplicate token
    for linesx in device_group_file:
        if linesx[0] == "#":
            continue
        lines = linesx.rstrip()
        if lines[0] == "R":
            device_temp_announce.append(lines)
        else:
            item = lines.split(";")
            if int(item[0]) < max_number_for_local_commands:
                max_number_for_local_commands = int(item[0])
            # duplicate commandtoken / type, concatenate to one line
            if item[0]+";"+item[1] in token_of_a_device:
                # where is it? -> index
                index = token_of_a_device.index(item[0] + ";" + item[1])
                # the existing string
                ann_string = device_temp_command[index]
                j = 0
                # append to existing
                for item1 in item:
                    if j > 1:
                        ann_string += ";" + item1
                    j += 1
                device_temp_command[index] = ann_string
                device_temp_announce[index] = ann_string
            else:
                token_of_a_device.append(item[0] + ";" + item[1])
                device_temp_announce.append(lines)
                device_temp_command.append(lines)
                i += 1
            # resolve "as"lines
            if len(item) > 1:
                item1 = item[1].split(",")
                if len(item1) > 1:
                    # in commandlines here may be something as "as123"
                    if item1[1][0:2] == "as":
                        as_number = item1[1].split("as")[1]
                        m = 0
                        while m < len(device_temp_command):
                            # originalline found
                            if as_number == device_temp_command[m].split(";")[0]:
                                new_commandtype = item[1].split(",")[0]
                                k = 1
                                item2 = device_temp_command[m].split(";")[1].split(",")
                                while k < len(item2):
                                    new_commandtype += "," + item2[k]
                                    k += 1
                                new_command_line = device_temp_command[m].split(";")
                                # actual token
                                new_command_line[0] = item[0]
                                new_command_line[1] = new_commandtype
                                device_temp_announce[i-1] = ";".join(new_command_line)
                                device_temp_command[i-1] = ";".join(new_command_line)
                            m += 1
        k += 1
    device_group_file.close()
    local_command_length = 1
    if max_number_for_local_commands > 0xFFFF:
        local_command_length = 4
    elif max_number_for_local_commands > 0xFF:
        local_command_length = 2
    v_device_buffer.commandtokenlength[device_number] = local_command_length

    # all commandtoken for a device; no "R"
    for lines in device_temp_command:
        if lines != "":
            device_command_token = int(lines.split(";")[0])
            if device_command_token != "R":
                v_device_buffer.all_comandtoken[device].append(device_command_token)

# delete ANNOUNCEMENT line
# modify 2nd individualization line
    i = 0
    first_line = 1
    for lines in device_temp_command:
        if lines[0] != "R":
            item1 = lines.split(";")[1].split(",")
            if len(item1) > 1:
                # no announcements
                if item1[1] == "ANNOUNCEMENTS":
                    device_temp_command[i] = ""
                # modify decond INDIVIDUALIZATION line
                if item1[1] == "INDIVIDUALIZATION":
                    if first_line == 1:
                        device_temp_announce[i] = indiv
                        first_line = 0
        i += 1
    i = 0
    first_line = 1
    for lines in device_temp_announce:
        if lines[0] != "R":
            item1 = lines.split(";")[1].split(",")
            if len(item1) > 1:
                # no announcements
                if item1[1] == "ANNOUNCEMENTS":
                    device_temp_announce[i] = ""
                # modify first INDIVIDUALIZATION line
                if item1[1] == "INDIVIDUALIZATION":
                    if first_line == 1:
                        device_temp_announce[i] = indiv
                        first_line = 0
        i += 1

# write temp to final
    v_device_command.announceline.append([])
    v_device_command.token.append([])
    v_device_announce.announceline.append([])
    v_device_announce.token.append([])
    for lines in device_temp_command:
        if lines != "":
            v_device_command.announceline[device].append(lines)
            v_device_command.token[device].append(int(lines.split(";")[0]))
    for lines in device_temp_announce:
        if lines != "":
            v_device_announce.announceline[device].append(lines)
            if lines[0] != "R":
                v_device_announce.token[device].append(int(lines.split(";")[0]))

# action for the new device finished
    return


def get_announcements_of_lower_level_devices():
    # at start ask for all, later react on info only
    # ask via &HxxF0 command
    # not complete
    interface = ""
    prefix_len = len(v_configparameter.my_devices_prefix)
    # find my_devices files for lower level CR
    files_dirs = os.listdir(v_configparameter.my_devices_dir)
    for name in files_dirs:
        if len(name) > prefix_len:
            # mydevice file
            if name[0:prefix_len] == v_configparameter.my_devices_prefix:
                my_dev_file = open(v_configparameter.my_devices_dir+name)
                switch = 0
                # additional devices?
                for lines in my_dev_file:
                    if lines == "" or lines[0] == "#":
                        continue
                    basic_line = lines.rstrip()
                    # first line, base
                    if switch == 0:
                        # no CR#first line, base
                        if basic_line.split(";")[1].split(",")[0] != "c":
                            continue
                        switch = 1
                    # second line: indiv
                    else:
                        # exctract interface
                        # missing
                        get_announcements_of_one_lower_level_device(interface)
                        switch = 0
                my_dev_file.close()
    return


def get_announcements_of_one_lower_level_device(interface):
    # ask via &HxxF0 command
    # not complete
    # read announcementlist missing
    # instead read file:
    temp = []
    file = open("./original_lower_level_announce_file")
    i = 0
    no_of_ann = 0
    new_file = ""
    for line in file:
        line.rstrip()
        temp.append(line)
        item = line.split(";")
        if i == 0:
            pass
            # ???new_file = v_configparameter.[3]+item[2] + "_" + item[3] + "_" + item[4]
        else:
            if len(item) > 1:
                item1 = item[1].split(",")
                if len(item1) > 1:
                    if item1[1] == "ANNOUNCEMENTS":
                        no_of_ann = i
        i += 1
    file.close()
    file = open(new_file, 'w')
    file.write(temp[0])
    i = no_of_ann
    while i < len(temp):
        file.write(temp[i])
        i += 1
    i = 1
    while i <= no_of_ann-1:
        file.write(temp[i])
        i += 1
    file.close()
    return

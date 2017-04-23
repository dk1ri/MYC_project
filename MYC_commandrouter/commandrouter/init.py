"""
name : commandrouter_init.py
------------------------------------------------
readconfig used at start only
read_my_devices at start and from time to time
others are called by read_my_devices only
------------------------------------------------
"""

import os

from io_handling import *
from misc_functions import *

import v_device_names_and_indiv
import v_configparameter
import v_cr_params

# variables per device
import v_dev
import v_sk


def readconfig(arg):
    # configfile can be given with full path
    # configfile is read read to v_configparameter[]
    # for details of parameters see manual -> files
    if len(arg) > 1:
        config_file = arg[1]
    else:
        config_file = "commandrouter_config/config_commandrouter"
    if not os.path.isfile(config_file):
        sys.exit("Missing file:  " + config_file)
    config_file = open(config_file)
    i = 0
    # sequence within file is fixed!!!
    for lines in config_file:
        if lines[0] == "#":
            continue
        # dir for my_devices
        if i == 0:
            if lines.splitlines()[0] == "home":
                v_configparameter.my_devices_file = "commandrouter_config/my_devices"
            else:
                v_configparameter.my_devices_file = lines.rstrip()
            if not os.path.isfile(v_configparameter.my_devices_file):
                sys.exit("Missing file:  " + v_configparameter.my_devices_file)
        # location of local devicegroupfiles
        if i == 1:
            if lines.splitlines()[0] == "home":
                v_configparameter.devicegroup = "commandrouter_config/"
            else:
                v_configparameter.devicegroup = lines.rstrip()
            if not os.path.isdir(v_configparameter.devicegroup):
                sys.exit("Missing dir:  " + v_configparameter.devicegroup)
        if i == 2:
            # time in sec for checking weather a device is active
            v_configparameter.time_for_activ_check = int(lines.rstrip())
        if i == 3:
            # time in sec for searching for new devices
            v_configparameter.time_for_device_search = int(lines.rstrip())
        if i == 4:
            # time in sec for command timeout
            v_configparameter.time_for_command_timeout = int(lines.rstrip())
        if i == 5:
            if lines.splitlines()[0] == "home":
                v_configparameter.logfile = "commandrouter_config/logfile"
            else:
                v_configparameter.logfile = lines.rstrip()
        if i == 6:
            # time in sec for check of logfile
            v_configparameter.time_for_logfile_check = int(lines.rstrip())
        if i == 7:
            # time in sec for check of logfile
            v_configparameter.max_log_lines = int(lines.rstrip())
        if i == 8:
            # maximumum length of commands
            v_configparameter.max_command_length = int(lines.rstrip())
            v_configparameter.length_max_command_length = length_of_int(v_configparameter.max_command_length)
        if i == 9:
            # length of ringbuffer to device
            v_configparameter.device_ringbuffersize = int(lines.rstrip())
        if i == 10:
            # system timeout
            v_configparameter.system_timeout = int(lines.rstrip())
        if i == 11:
            # user timeout
            v_configparameter.user_timeout = int(lines.rstrip())
        i += 1
    config_file.close()
    if i != 12:
        sys.exit("wrong number of configparameters")
    return


def read_my_devices():
    # add new devices but do not delete
    # this sub generates device_names_and_indiv.all and device_names_and_indiv.activ only
    # (and call read of lower level CR if necessary)
    # program crashes, if filenames contain special characters
    my_dev_file = open(v_configparameter.my_devices_file)
    # own CR must be 1st device, own_cr is reset after the first device
    own_cr = 1
    devicegroupname = ""
    device = 0
    indiv = ""
    i = 0
    new_device_found = 0
    for linesx in my_dev_file:
        # read 3 lines for one device
        linesx = linesx.splitlines()[0]
        if linesx == "" or linesx[0] == "#":
            pass
        elif i == 0:
            indiv = linesx
            i += 1
        elif i == 1:
            line2 = linesx
            i += 1
        elif i == 2:
            line3 = linesx
            # got 3 lines for one device now
            # get lower level CR
            item1 = line2.split(";")[1].split(",")
            if item1[0] == "c" and own_cr == 0:
                v_cr_params.lower_level_cr.append(indiv)
                get_announcements_of_lower_level_device(devicegroupname)
            item = indiv.split(";")
            devicegroupname = item[0] + "_" + item[1] + "_" + item[2]
            if indiv in v_device_names_and_indiv.name:
                # dupe: skip next line
                pass
            else:
                v_device_names_and_indiv.name.append(indiv)
                # active by default
                v_device_names_and_indiv.activ.append(1)
                item = line2.split(";")[1].split(",")[0]
                if item == "m" or item == "c" or item == "s":
                    # not devcided, about RU and LD
                    device = create_device(indiv)
                if device == 0:
                    v_cr_params.full_device_name = indiv
                # third line: 255 announcement
                if own_cr == 1:
                    initialize_inputbuffer(line3)
                else:
                    # device = 0 is CR always no interface parameters needed
                    # extract interfaces from 255 line
                    initialize_device_interface(line3, device)
                read_announcements_of_a_device(indiv, devicegroupname, device, own_cr)
                new_device_found = 1
            own_cr = 0
            i = 0
    my_dev_file.close()
    return new_device_found
#
"""
------------------------------------------------
tasks, with new device
------------------------------------------------
"""


def create_device(indiv):
    v_dev.actual_device_token. append(0)
    # create new device_buffer
    v_dev.announceline.append([])
    # commandlength of commands for device
    v_dev.length_commandtoken.append(0)
    v_dev.cr_dev_tok.append({})
    # data to send to CR
    v_dev.data_to_CR.append([])
    #  received  from SK
    v_dev.data_to_device.append([])
    # list of tokennumber
    v_dev.dev_cr_tok.append({})
    # list of devicetoken
    v_dev.tok.append([])
    v_dev.info.append((0))
    v_dev.input_device.append(0)
    v_dev.interface_adress.append(0)
    v_dev.interface_baudrate.append(0)
    v_dev.interface_comport.append(0)
    v_dev.interface_number_of_bits.append(0)
    v_dev.interface_port.append(0)
    v_dev.interface_timeout.append(0)
    v_dev.interface_type.append("")
    # linelength parameters modified at real time: number of byte for next action
    v_dev.linelength_len.append(0)
    v_dev.linelength_other.append(0)
    v_dev.linelength_other1.append(0)
    v_dev.linelength_loop.append(0)
    v_dev.name.append(indiv)
    v_dev.start_time.append(0)
    v_dev.readpointer.append([])
    v_dev.writepointer.append([])
    v_dev.user.append([])
    # create ringbuffer
    i = 0
    device = len(v_dev.name) - 1
    while i < v_configparameter.device_ringbuffersize:
        v_dev.data_to_device[device].append(bytearray([]))
        v_dev.user[device].append(bytearray([]))
        v_dev.readpointer[device] = 0
        v_dev.writepointer[device] = 0
        i += 1
    return device


def initialize_device_interface(line, device_number):
    # first active interface used
    # devicebufferarray alrady generated
    item = line.split(";")
    i = 4
    active_interface_found = 0
    while i < len(item):
        if active_interface_found < 2:
            item1 = item[i].split(",")
            if item1[1] == "TERMINAL" or item1[1] == "I2C" or item1[1] == "RC5" or item1[1] == "RC6":
                if item1[2] == "1":
                    v_dev.interface_type[device_number] = (item1[1])
                    active_interface_found = 2
                else:
                    # skip to next interfacename
                    active_interface_found = 1
            if item1[1] == "TELNET" or item1[1] == "USB" or item1[1] == "SSH":
                if item1[2] == "1":
                    v_dev.interface_type[device_number] = (item1[1])
                    active_interface_found = 2
                else:
                    # skip to next interfacename
                    active_interface_found = 1
            if item1[1] == "CAN" or item1[1] == "HTTP" or item1[1] == "HTTPS":
                if item1[2] == "1":
                    v_dev.interface_type[device_number] = (item1[1])
                    active_interface_found = 2
                else:
                    # skip to next interfacename
                    active_interface_found = 1

        if active_interface_found == 2:
            if item1[1] == "ADRESS":
                v_dev.interface_adress[device_number] = item1[2]
            if item1[1] == "PORT":
                v_dev.interface_port[device_number] = int(item1[2])
            if item1[1] == "TIMEOUT":
                v_dev.interface_timeout[device_number] = int(item1[2])
            if item1[1] == "COMPORT":
                v_dev.interface_comport[device_number] = item1[2]
            if item1[1] == "NUMBER_OF_BITS":
                v_dev.interface_number_of_bits[device_number] = item1[2]
            if item1[1] == "BAUDRATE":
                v_dev.interface_baudrate[device_number] = item1[2]

        i += 1
    if v_dev.interface_type[device_number] == "TELNET":
        # adress and port must exist
        if v_dev.interface_port[device_number] != "" and v_dev.interface_adress[device_number] > 0:
            start_ethernet_client(v_dev.interface_adress[device_number], v_dev.interface_port[device_number], device_number)
    return


def create_inputbuffer(interface_type, name,):
    # create one v_sk
    # name must be unique,
    v_sk.baudrate.append(0)
    # actual input buffer
    v_sk.inputline.append(bytearray([]))
    # actual input bufferlock for ethernet
    v_sk.inputline_active.append(0)
    v_sk.interface_adress.append("")
    # des after interface_type in 255  line
    v_sk.interface_name.append(name)
    # des after interface_type in 255  line
    v_sk.interface_port.append(0)
    # des after interface_type in 255  line
    v_sk.interface_timeout.append(0)
    # des after interface_type in 255  line
    v_sk.interface_type.append(interface_type)
    # last error message
    v_sk.last_error.append("no error")
    # actual_call in analyze_length for next action:
    v_sk.linelength_len.append(0)
    # count the number of analyze calls
    v_sk.linelength_other.append(0)
    v_sk.linelength_other1.append(0)
    v_sk.linelength_loop.append(0)
    v_sk.name.append(interface_type + name)
    v_sk.number_of_bits.append("")
    v_sk.socket.append([])
    v_sk.source.append([])
    # starttime
    v_sk.starttime.append([])
    v_sk.user_number.append(0)
    v_sk.multiuser.append([2])
    v_sk.user_active.append([])
    v_sk.user_answer_token.append([])
    v_sk.user_timeout.append([])
    m = len(v_sk.user_active) - 1
    i = 0
    while i < 256:
        v_sk.user_timeout[m].append(0)
        v_sk.user_active[m].append(0)
        v_sk.user_answer_token[m].append(bytearray([42]))
        v_sk.starttime[m].append(0)
        i += 1
    v_sk.telnet_number.append([])
    # contain s list of started ports
    v_sk.ethernet_server_started.append([])
    return m


def initialize_inputbuffer(lines):
    # initialize commandrouter inputs for user interface etc ...
    item = lines.split(";")
    # individual name and number
    i = 4
    # scan all i > 3
    while i < len(item):
        item1 = item[i].split(",")
        if item1[1] == "TERMINAL" or item1[1] == "I2C" or item1[1] == "RC5" or item1[1] == "RC6":
            m = create_inputbuffer(item1[1], item1[2])
        if item1[1] == "TELNET" or item1[1] == "USB" or item1[1] == "SSH":
            m = create_inputbuffer(item1[1], item1[2])
        if item1[1] == "CAN" or item1[1] == "HTTP" or item1[1] == "HTTPS":
            m = create_inputbuffer(item1[1], item1[2])
        # the following parameters are added to the buffer m detected before
        if item1[1] == "PORT":
            v_sk.interface_port[m] = int(item1[2])
        if item1[1] == "TIMEOUT":
            v_sk.interface_timeout[m] = int(item1[2])
        if item1[1] == "ADRESS":
            v_sk.interface_adress[m] = int(item1[2])
        if item1[1] == "BAUDRATE":
            v_sk.baudrate[m] = int(item1[2])
        if item1[1] == "COMPORT":
            v_sk.interface_port[m] = int(item1[2])
        if item1[1] == "PORT":
            v_sk.socket[m] = int(item1[2])
        if item1[1] == "NUMBER_OF_BITS":
            v_sk.number_of_bits[m] = item1[2]
        i += 1
    if v_sk.interface_type[m] == "TELNET":
        start_ethernet_server(v_sk.socket[m], m)
    # other interfaces will follow...


def read_announcements_of_a_device(indiv, devicegroupname, device, own_cr):
    # read announcements of one new device from file with devicegroupname
    # resolve duplicate commandtoken / commandtype:
    # replace ANNOUNCEMENT line
    # find number of commands (excluding  rules and ANNOUNCEMENT line)
    # device point to the actual element
    # do some checks on announcement data: return in case of error
    # missing: ask device, if devicegroupfile not available
    device_temp_command = []
    device_temp_rules = []
    # load announcements and resolve duplicate token and "as" lines
    device_group_file = open(v_configparameter.devicegroup + devicegroupname)
    # for check of duplicate token:
    token_of_a_device = []
    # index for announcement:
    k = 0
    # index for command:
    i = 0
    commands_of_device = 0
    for linesx in device_group_file:
        lines = linesx.splitlines()[0]
        if lines[0] == "#" or lines == "":
            continue
        if lines[0] == "R":
            # rules will be appended to the end
            device_temp_rules.append(lines)
        elif lines[0] == "I":
            device_temp_command.append(lines)
        else:
            commands_of_device += 1
            item = lines.split(";")
            # number of bytes for commands:
            temp = item[1].split(",")[0]
            if temp == "m" or temp == "l" or temp == "r" or temp == "c" or temp == "h" or temp == "s":
                temp1 = int(item[7])
                if temp1 > 0 and temp1 < 9:
                    v_dev.length_commandtoken[device] = temp1
                else:
                    # device data wrong or old version
                    v_dev.length_commandtoken[device] = 1
            # find 0xxxfa line with INFO
            if len(item[1].split(",")) > 1:
                if item[1][1] == "FEATURE":
                    i = 0
                    while i < len(item):
                        temp = item[i].split(",")
                        if len(temp) > 1:
                            if temp[1] == "INFO":
                                v_dev.info[device] = 1
                        i += 1

            # resolve duplicate commandtoken / type, concatenate to one line
            if item[0] + ";" + item[1] in token_of_a_device:
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
            else:
                # check for valid values
                if len(item[0]) > 0 and len(item[1]) > 0:
                    token_of_a_device.append(item[0] + ";" + item[1])
                else:
                    print("resolve not valid")
                    return
                i += 1

            # resolve "as"lines
            if len(item) > 1:
                item1 = item[1].split(",")
                if len(item1) > 1:
                    # in commandlines here may be something as "as123"
                    if item1[1][0:2] == "as":
                        as_number = item1[1].split("as")[1]
                        m = 0
                        # search for "as" token
                        while m < len(device_temp_command):
                            if as_number == device_temp_command[m].split(";")[0]:
                                # "as" line found, original type + ext
                                new_commandtype = item[1].split(",")[0] + ",ext" + str(as_number)
                                # split "as line" commandtype field, add rest to original
                                item2 = device_temp_command[m].split(";")[1].split(",")
                                k = 1
                                while k < len(item2):
                                    new_commandtype += "," + item2[k]
                                    k += 1
                                # "as"line as master
                                new_command_line = device_temp_command[m].split(";")
                                # add original token and commandtype
                                new_command_line[0] = item[0]
                                new_command_line[1] = new_commandtype
                                lines = ";".join(new_command_line)
                            m += 1
            device_temp_command.append(lines)
        k += 1
    if device_length_of_commandtoken(commands_of_device) > v_dev.length_commandtoken[device]:
        write_log(("error in devicegroupfile", device))
    device_group_file.close()

    # all commandtoken for a device
    # device_temp_command may have I lines from lower level CR
    for lines in device_temp_command:
        if lines[0:1] != "I" and lines[0:1] != "R":
            v_dev.tok[device].append(int(lines.split(";")[0]))

# delete ANNOUNCEMENT line
# delete INDIVIDUALIZATION line
        # may be 1st or 2nd <des>
    i = 0
    for lines in device_temp_command:
        item1 = lines.split(";")[1].split(",")
        if own_cr == 1:
            if lines[0:3] == "252":
                # number of bytes for error messages
                v_cr_params.length_of_last_error_length = length_of_int(int(lines.split(";")[2].split(",")[0]))
        else:
            if len(item1) > 1:
                # des needed
                if item1[1] == "ANNOUNCEMENTS":
                    device_temp_command[i] = ""
                elif len(item1) > 2:
                    if item1[2] == "ANNOUNCEMENTS":
                        device_temp_command[i] = ""
        if len(item1) > 1:
            # des needed
            if item1[1] == "INDIVIDUALIZATION":
                device_temp_command[i] = ""
            elif len(item1) > 2:
                if item1[2] == "INDIVIDUALIZATION":
                    device_temp_command[i] = ""
        i += 1

    # write temp to final
    for lines in device_temp_command:
        if lines == "":
            continue
        v_dev.announceline[device].append(lines)
    for lines in device_temp_rules:
        v_dev.announceline[device].append(lines)
    # add I-line
    tr = indiv.split("_")
    v_dev.announceline[device].append("I;" + v_cr_params.full_device_name + ";" + ";".join(tr))
    return


def get_announcements_of_lower_level_device(devicegroupname):
    # missing:
    # interface is ready?
    # ask via 0x00 and 0xxxf0 command
    # and copy to commandrouter_config/devicegroupfiles
    # strip last "I" line
    return

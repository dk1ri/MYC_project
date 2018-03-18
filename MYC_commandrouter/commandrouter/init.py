"""
name : init.py
last edited: 201802
------------------------------------------------
readconfig used at start only
read_my_devices at start and from time to time
others are called by read_my_devices only
------------------------------------------------
"""

import os

from io_handling import *
from misc_functions import *
from create_new_announce_list import  *

import v_device_names_and_indiv
import v_configparameter
import v_cr_params
import v_sk_interface

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
            # system timeout
            v_configparameter.system_timeout = int(lines.rstrip())
        if i == 9:
            # channel timeout
            v_configparameter.channel_timeout = int(lines.rstrip())
        if i == 10:
            # test mode
            v_configparameter.test_mode = int(lines.rstrip())
        if i == 11:
            # sk buffer limit
            v_configparameter.sk_buffer_limit = int(lines.rstrip())
        if i == 12:
            # sk buffer limit for test_mode
            v_configparameter.sk_buffer_limit_testmode = int(lines.rstrip())
        if i == 13:
            # sk buffer limit hysteresys
            v_configparameter.sk_histeresys = int(lines.rstrip())
        i += 1
    config_file.close()
    if i != 14:
        sys.exit("wrong number of configparameters")
    if v_configparameter.test_mode == 0:
        v_cr_params.sk_buffer_limit = v_configparameter.sk_buffer_limit
        v_cr_params.sk_buffer_limit_low =  v_cr_params.sk_buffer_limit * v_configparameter.sk_hysteresys / 100
    else:
        v_cr_params.sk_buffer_limit = v_configparameter.sk_buffer_limit_testmode
        v_cr_params.sk_buffer_limit_low = v_cr_params.sk_buffer_limit * v_configparameter.sk_hysteresys / 100
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
                i = 0
                continue

            item = indiv.split(";")
            devicegroupname = item[0] + "_" + item[1] + "_" + item[2]
            if indiv in v_device_names_and_indiv.name:
                # dupe: skip next line (at re-initialization)
                pass
            else:
                # read devicegroupfile first. skip rest in case of severe error
                # otherwise create the device
                item = line2.split(";")[1].split(",")[0]
                if item == "m" or item == "c" or item == "s":
                # not decided about RU and LD
                    error = read_announcements_of_a_device(indiv, devicegroupname, own_cr)
                    if error == 1:
                        continue
                v_device_names_and_indiv.name.append(indiv)
                # active by default
                v_device_names_and_indiv.activ.append(1)

                # third line: 255 announcement
                if own_cr == 1:
                    initialize_inputbuffer(line3)
                else:
                    # device = 0 is CR always no interface parameters needed
                    # extract interfaces from 255 line
                    initialize_device_interface(line3, device)
                new_device_found = 1
            own_cr = 0
            device += 1
            i = 0
    my_dev_file.close()
    return new_device_found


"""
------------------------------------------------
tasks, with new device
------------------------------------------------
"""


def read_announcements_of_a_device(indiv, devicegroupname, own_cr):
    # read announcements of one new device from file with devicegroupname
    # resolve duplicate commandtoken / commandtype:
    # replace ANNOUNCEMENT line
    # drop "k" and "l" lines (for configuration only) and individualization lines
    # drop lines with errors, (as neccesary b< CR)
    # find number of commands (excluding rules and ANNOUNCEMENT line)
    # device point to the actual element
    # do some checks on announcement data: return in case of error
    # missing: ask device, if devicegroupfile not available

    # write device_group_file to temporary list
    file = []
    file_last = []
    device_temp_rules = []
    device_group_file = open(v_configparameter.devicegroup + devicegroupname)
    if own_cr == 1:
        i = 0
        for linesx in device_group_file:
            lines = linesx.splitlines()[0]
            if lines == "" or lines[0] == "#":
                continue
            # basic line only
            if i == 0:
                file_last.append(lines)
            else:
                # other lines appended later
                v_cr_params.cr_announcement.append(lines)
            i  +=  1
    else:
        file = []
        for linesx in device_group_file:
            lines = linesx.splitlines()[0]
            # drop comment and empty lines
            if lines == "" or lines[0] == "#":
                continue
            file.append(lines)
    device_group_file.close()

    # concatanate line with the same commandtoken
    # must have the same commandtype
    file1 =[]
    for lines in file:
        item = lines.split(";")
        if len(item) > 1:
            linenumber = 0
            found = 0
            for lines1 in file1:
                newline = lines1.split(";")
                if len(newline)> 1:
                    if item[0] == newline[0]:
                        if item[1].split(",")[0] == newline[1].split(",")[0]:
                            # found; concatanate lines

                            file1[linenumber] += ";".join(item[2:])
                        else:
                            # identical commandtoken, different commandtype: drop line
                            write_log("dentical commandtoken, different commandtype in device "+ str(devicegroupname))
                linenumber += 1
            if found == 0:
                file1.append(lines)
        else:
            file1.append(lines)

    # resolve "as"lines; modify lines, if found
    # lines with the same commandtoken must have the same commandtype
    file = []
    for linesx in file1:
        item = linesx.split(";")
        found = 0
        if len(item) > 1:
            item1 = item[1].split(",")
            if len(item1) > 1:
                # in commandlines here may be something as "as123"
                if item1[1][0:2] == "as":
                    # nothing will follow the "as" number (string)
                    as_number = item1[1].split("as")[1]
                    # search for "as" token
                    found = 1
                    for lines in file1:
                        lines1 = lines.splitlines()[0]
                        newline = lines1.split(";")
                        if as_number == newline[0] and found == 1:
                            # "as" line found, original type + ext
                            new_commandtype = newline[1].split(",")[0] + ",ext" + as_number
                            # "as"line as master
                            # add original token and commandtype
                            newline[0] = item[0]
                            newline[1] = new_commandtype
                            file.append(";".join(newline))
                            found = 2
        if found == 0:
            file.append(linesx)

    # drop "k" and "l" lines
    file1 = []
    for linesx in file:
        item = linesx.split(';')
        if len(item) > 1:
            item1 = item[1].split(",")
            if len(item1[0]) > 0:
                if item1[0][0] == "k" or item1[0][0] == "l":
                    continue

        #drop ANNOUNCEMENT and INDIVIDUALIZATION lines (not for CR)
        if len(item) > 1:
            item1 = item[1].split(",")
            if len(item1) > 1:
                # des needed
                if item1[1] == "ANNOUNCEMENTS":
                    continue
                if item1[1] == "INDIVIDUALIZATION":
                    continue
        file1.append(linesx)

    # for CR; overwritten by other device
    temp_length_commandtoken = 1

    if own_cr == 1:
        for lines in v_cr_params.cr_announcement:
            number, stripped = misc_functions.strip_dimension(lines)
            if lines[0] != "R" and lines[0] != "Q" and lines[0] != "I":
                error = check_parameters(stripped, lines)
                if error != "":
                    exit ("error in devicegroupfile of CR; terminate programm: " + lines + " " + error )

            temp_list1 = []
            temp_list2 = []
            item = lines.split(";")
            if item[0] != "R" and item[0] != "I" and item[0] != "Q" and len(item) > 1:
                item1 = item[1].split(",")
                temp_list3, temp_list4 = commandtypes[item1[0]](lines, temp_list1, temp_list2,1)

                if len(item1) > 1 and len(item) > 2:
                    if item1[1] == "LAST ERROR":
                        # number of bytes for length of error messages
                        value = 0
                        try:
                            value = int(item[2].split(",")[0])
                        except ValueError:
                            exit ("length of error not numeric in CR error announcement; terminate programm")
                        v_cr_params.length_last_error_length = length_of_int(value)

        v_cr_params.full_device_name = indiv

    else:

    # for normal devices only
        device_temp_rules = []
        commands_of_device = 0
        temp_length_commandtoken = 1

        for lines in file1:
            if lines[0] == "R":
                # rules will be appended to the end
                device_temp_rules.append(lines)
                continue

            item = lines.split(";")

            # check basic line
            temp = item[1].split(",")[0]
            if temp == "m" or temp == "l" or temp == "r" or temp == "c" or temp == "h" or temp == "s":
                if len(item) != 10:
                    # wrong basic announcement
                    # ignore that device
                    write_log("wrong number of parameters in basic announcement of device, device ignored: " + indiv)
                    return 1
                try:
                    temp_length_commandtoken = int(item[7])
                except ValueError:
                    # ignore that device
                    write_log("wrong commandlength in devicegroupfile device, device ignored: " + indiv)
                    return 1
        file = []
        for lines in file1:
            #line ready now; check for valid values
            number, stripped = misc_functions.strip_dimension(lines)
            if lines[0] != "R" and lines[0] != "Q" and lines[0] != "I":
                error = check_parameters(stripped, lines)
                if error == "":
                    commands_of_device += 1
                    file.append(lines)
                else:
                    write_log(str(lines) +  " " + error + " line ignored")
            else:
                file.append(lines)

        # length of commandtoken must match the value of the basic announcement
        # + 16 due to reserved token
        if device_length_of_commandtoken(commands_of_device + 16) > temp_length_commandtoken:
            write_log(("error in devicegroupfile device; " + indiv))
            return 1

        # check commandtype, the generated lists are ignored, valid list are generated with create_new_announce_list
        file_last = []
        for lines in file:
            #temp_list1 = []
            #temp_list2 = []
            #temp_list3 = []
            #temp_list4 = []
            #item =lines.split(";")
            #if item[0] != "R" and item[0] != "I" and item[0] != "Q" and len(item) > 1:
            #    item1= item[1].split(",")
            #    temp_list3, temp_list4, error = commandtypes[item1[0]](lines, temp_list1,temp_list2, temp_length_commandtoken)
            #    if error == 0:
            #        file_last.append(lines)
            #else:
            file_last.append(lines)


# device_temp_command1 ready now
# create new device
    device = create_device(indiv)

    v_dev.length_commandtoken[device] = temp_length_commandtoken

    # all commandtoken for a device
    # device_temp_command may have I lines from lower level CR
    tok = 0
    for lines in file_last:
        if lines[0:1] != "I" and lines[0:1] != "R" and lines[0:1] != "Q":
            v_dev.tok[device].append(int(lines.split(";")[0]))


    # write temp to final
    for lines in file_last:
        v_dev.announceline[device].append(lines)
    for lines in device_temp_rules:
        v_dev.announceline[device].append(lines)
    # add I-line
    tr = indiv.split("_")
    v_dev.announceline[device].append("I;" + v_cr_params.full_device_name + ";" + ";".join(tr))
    return 0

def create_device(indiv):
    # v_dev.actual_device_token. append(0)
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
    # v_dev.info.append(0)
    v_dev.input_device.append(0)
    v_dev.interface_adress.append(0)
    v_dev.interface_baudrate.append(0)
    v_dev.interface_comport.append(0)
    v_dev.interface_number_of_bits.append(0)
    v_dev.interface_port.append(0)
    v_dev.interface_timeout.append(0)
    v_dev.interface_type.append("")
    # linelength parameters modified at real time: number of byte for next action
    v_dev.len.append([0,0,0,0,0])
    v_dev.name.append(indiv)
    v_dev.start_time.append(0)
    # create ringbuffer
    i = 0
    device = len(v_dev.name) - 1
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


def  check_parameters(stripped, lines):
    # check announceline for syntax errors, do not check <des>
    # commandtoken)
    try:
        value = int(stripped[0])
    except ValueError:
        return "commandtoken not numeric"

    #commandtype
    commandtype = ["m","l","c","r","h","s","iz","ia","ib","if","im","in","io","ip","iq","ir","is","it","or","kr","rr","os"]
    commandtype += ["iu","ks","rs","ot","kt","rt","ou","ku","ru","ar","lr","sr","as","ls","ss","at","at","st","au","lu","su"]
    commandtype += ["op","kp","rp","oo","ko","ro","ap","lp","sp","om","km","rm","on","kn","rn","of","kf","rf"]
    commandtype += ["oa","ka","ra","ob","kb","rb","am","lm","sm","an","ln","sn","af","lf","sf","aa","sa","la","ab","lb","sb"]
    if not stripped[1].split(",")[0] in commandtype:
        return "unknown commandtype"

    # no check necessary
    types = ["iz","ia","ib","if","im","in","io","ip","ir","is","it","iu"]
    if stripped[1].split(",")[0] in types:
        return ""

    # check /drop DIMENSION and CHAPTER
    i = 2
    while i < len(stripped):
        found = 0
        item = lines.split(";")
        if len(item)> 1:
            item1 = item[i].split(",")
            if len(item1)  > 1:
                if item1[1] == "DIMENSION":
                    type, length, max = misc_functions.length_of_typ((item1[0]))
                    if type != "n":
                        return "wrong commandtype for DIMENSION"
                    else:
                        del(stripped[i])
                        found = 1
                if i < len(stripped):
                    # edl changes the index!!
                    if item1[1] == "CHAPTER":
                        type, length, max = misc_functions.length_of_typ((item1[0]))
                        if type != "s":
                            return "wrong commandtype for CHAPTER"
                        else:
                            del(stripped[i])
                        found = 1
        if found == 0:
            # del changes the index!!
            i += 1
    # basic lines
    types = ["m","l","c","r","h","s"]
    if stripped[1].split(",")[0] in types:
        # check done before
        return ""

    # all parameters should be numeric (switches), 4 positions as minimum
    types = ["or","kr","rr","ar","lr","sr"]
    if stripped[1] in types:
        if len(stripped) < 4:
            return "number of paramters not sufficient"
        i = 2
        while i < len(stripped):
            try:
                value = int(stripped[i])
            except ValueError:
                return "parameter not numeric"
            i += 1
        return ""

    # all parameters should be numeric (switches), 5 positions as minimum
    types = ["os","ks","rs","ot","kt","rt","ou","ku","ru","as","ls","ss","at","at","st","au","lu","su"]
    if stripped[1] in types:
        if len(stripped) < 5:
            return "number of paramters not sufficient"
        i = 2
        while i < len(stripped):
            type, length, max = misc_functions.length_of_typ(stripped[i])
            if type != "s":
                return "parameter not numeric"
            i += 1
        return ""

    # range control: 3rd, 4th and then every 3rd parameter numeric
    types =["op","kp","rp","ap","lp","sp"]
    if stripped[1] in types:
        type, length, max = misc_functions.length_of_typ(stripped[2])
        if type != "s":
            return "parameter not numeric"
        i = 3
        if len(stripped) < 6:
               return "number of parameters not sufficient"
        while i < len(stripped):
            type, length, max = misc_functions.length_of_typ(stripped[i])
            if type != "s":
                return "parameter not numeric"
            # 2 other parameters must follow
            if i + 2 > len(stripped):
                return "wrong number of parameters"
            i += 3
        return ""

    # range control: 3rd, 4th 5th 7th (9th...) parameter is checked as numeric
    types = ["oo", "ko", "ro"]
    if stripped[1] in types:
        type, length, max = misc_functions.length_of_typ(stripped[2])
        if type != "s":
            return "parameter not numeric"
        i = 3
        while i < len(stripped):
            if i + 5 > len(stripped):
                return "wrong number of parameters"
            type, length, max = misc_functions.length_of_typ(stripped[i])
            if type != "s":
                return "parameter not numeric"
            type, length, max = misc_functions.length_of_typ(stripped[i + 1])
            if type != "s":
                return "parameter not numeric"
            type, length, max = misc_functions.length_of_typ(stripped[i + 3])
            if type != "s":
                return "parameter not numeric"
            type, length, max = misc_functions.length_of_typ(stripped[i + 4])
            if type != "n":
                return "parameter no numeric type"
            i += 5
        return ""

    # memory 1st parameter. ty, others numeric
    types = ["om","km","rm","on","kn","rn","am","lm","sm","an","ln","sn","of","kf","rf","af","lf","sf"]
    if stripped[1] in types:
        if len(stripped) < 4:
            return "number of parameters not sufficient"

        #type
        type, length, max = misc_functions.length_of_typ(stripped[2])
        if type == "e":
            return "unknown parameter type"

        # other must be numeric
        i = 3
        while i < len(stripped):
            type, length, max = misc_functions.length_of_typ(stripped[i])
            if type != "s":
                return "parameter not numeric"
            i += 1

        if stripped[1] == "of" or stripped[2] == "af":
            if len(stripped) != 4:
                return "parameter number for of / af not 4"
        return ""

    # array. all parameter are ty
    types = ["oa","ka","ra","ob","kb","rb","aa","sa","la","ab","lb","sb"]
    if stripped[1] in types:
        if len(stripped) < 3:
            return "number of parameters not sufficient"

        i = 2
        while i < len(stripped):
            type, length, max = misc_functions.length_of_typ(stripped[i])
            if type == "e":
                return "parameter type not valid"
            i += 1
        return ""
    # other error
    return "other error"


def initialize_inputbuffer(lines):
    # initialize commandrouter inputs for SK interface etc ...
    item = lines.split(";")
    # individual name and number
    i = 4
    # scan all i > 3
    while i < len(item):
        item1 = item[i].split(",")
        if item1[1] == "TERMINAL" or item1[1] == "I2C" or item1[1] == "RC5" or item1[1] == "RC6":
            try:
                activ = int(item1[2])
            except ValueError:
                continue
            m = create_inputbuffer(item1[1], activ)
        if item1[1] == "TELNET" or item1[1] == "USB" or item1[1] == "SSH":
            try:
                activ = int(item1[2])
            except ValueError:
                continue
            m = create_inputbuffer(item1[1],activ)
        if item1[1] == "CAN" or item1[1] == "HTTP" or item1[1] == "HTTPS":
            try:
                activ = int(item1[2])
            except ValueError:
                continue
            m = create_inputbuffer(item1[1], activ)
        # the following parameters are added to the buffer m detected before
        if item1[1] == "PORT":
            v_sk_interface.interface_port[m] = int(item1[2])
        if item1[1] == "TIMEOUT":
            v_sk_interface.interface_timeout[m] = int(item1[2])
        if item1[1] == "ADRESS":
            v_sk_interface.interface_adress[m] = int(item1[2])
        if item1[1] == "BAUDRATE":
            v_sk_interface.baudrate[m] = int(item1[2])
        if item1[1] == "COMPORT":
            v_sk_interface.interface_port[m] = int(item1[2])
        if item1[1] == "PORT":
            v_sk_interface.socket[m] = int(item1[2])
        if item1[1] == "NUMBER_OF_BITS":
            v_sk_interface.number_of_bits[m] = item1[2]
        i += 1
    if v_sk_interface.interface_type[m] == "TELNET":
        start_ethernet_server(v_sk_interface.socket[m], m)
    # other interfaces will follow...


def create_inputbuffer(interface_type, activ,):
    # create one v_sk
    # name must be unique,
    v_sk_interface.baudrate.append(0)
    # actual input buffer
    v_sk_interface.inputline.append(bytearray([]))
    # actual input bufferlock for ethernet
    v_sk_interface.inputline_active.append(0)
    v_sk_interface.interface_adress.append("")
    v_sk_interface.activ.append(activ)
    v_sk_interface.interface_port.append(0)
    v_sk_interface.interface_timeout.append(0)
    v_sk_interface.interface_type.append(interface_type)
    v_sk_interface.number_of_bits.append("")
    v_sk_interface.socket.append([])
    v_sk_interface.source.append([])
    v_sk_interface.telnet_number.append([])
    # contain s list of started ports
    v_sk_interface.ethernet_server_started.append([])
    create_sk()
    return len(v_sk_interface.ethernet_server_started) - 1

def create_sk():
    v_sk.active.append(1)
    v_sk.inputline.append([])
    # actual_call in analyze_length for next action:
    v_sk.len.append([0, 0, 0, 0, 0])
    v_sk.last_error.append("no error")
    v_sk.starttime.append(0)
    # for command 0xxxf9
    v_sk.channel_answer_token.append([])
    # for multi channel
    v_sk.channel_number.append(0)
    v_sk.channel_timeout.append(0)
    v_sk.multi_channel.append(0)
    return
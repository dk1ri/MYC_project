"""
name : init.py
last edited: 20250309
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
other misc functions
------------------------------------------------
readconfig used at start only
read_my_devices at start and from time to time
others are called by read_my_devices only
------------------------------------------------
"""

from io_handling import *
from create_new_announce_list import  *

import v_configparameter
import v_cr_params

# variables per device#
from pathlib import Path
import v_dev
import v_sk
import sys
import v_time_values


def dummy_sub():
    return


def initialization():
    # read config data
    readconfig()
    v_configparameter.other_lines = ["I","L","Q","R","S","T"]
    #
    # create / read all FU data
    read_device_interface_list()
    # # temporary solution for announcements of up to 6 devices (in devices dir)
    v_dev.name[1] = "1"
    """
    v_dev.name[2] = "2"
    v_dev.name[3] = "3"
    v_dev.name[4] = "4"
    v_dev.name[5] = "5"
    v_dev.name[6] = "6"
    v_dev.name[7] = "7"
    v_dev.name[8] = "8"
    v_dev.name[9]= "9"
    v_dev.name[10] = "10"
    v_dev.name[11] = "11"
    v_dev.name[12] = "12"
    v_dev.name[13] = "13"
    v_dev.name[14] = "14"
    """
    i = 0
    while i < len(v_dev.announcements):
        # announcelist may be empty, if file not found
        read_announcements_of_a_device(i)
        i += 1
    create_new_announce_list()
    create_sk_buffer()
    # not ready:
    #  check_activity_of_devices()
    v_time_values.last_device_search = int(time.time())
    v_time_values.last_activity = time.time()
    v_time_values.time_for_activ_check = time.time()
    v_time_values.last_checktime = time.time()
    return


def readconfig():
    # configfile can be given with full path
    # configfile is read to v_configparameter[]
    # for details of parameters see manual -> files
    if len(sys.argv) > 1:
        config_file = sys.argv[1]
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
        lines = lines.splitlines()[0]
        # location of local devicegroupfiles
        if i == 0:
            if lines == "home":
                v_configparameter.connection_of_devices = "connection_of_devices"
            else:
                v_configparameter.connection_of_devices = lines.rstrip()
            if Unix_windows == 0:
                v_configparameter.connection_of_devices = "commandrouter_config/" + v_configparameter.connection_of_devices
            else:
                v_configparameter.connection_of_devices = "commandrouter_config//" + v_configparameter.connection_of_devices
            if not os.path.isfile(v_configparameter.connection_of_devices):
                sys.exit("Missing dir:  " + v_configparameter.connection_of_devices)
        if i == 1:
            if lines == "home":
               "devices"
            else:
                v_configparameter.announcements_dir = lines.rstrip()
            if Unix_windows == 0:
                v_configparameter.announcements_dir = "commandrouter_config/" + v_configparameter.announcements_dir
            else:
                v_configparameter.announcements_dir = "commandrouter_config//" + v_configparameter.announcements_dir
            if not os.path.isdir(v_configparameter.announcements_dir):
                sys.exit("Missing file:  " + v_configparameter.announcements_dir)
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
            if lines == "home":
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
        if i == 14:
            # dirname for LD files
            v_configparameter.dirname = lines.rstrip()
        if i == 15:
            v_configparameter.announceline_0_CR =  lines.rstrip()
        if i == 16:
            v_configparameter.announceline_240_CR = lines.rstrip()
        if i == 17:
            v_configparameter.announceline_241_CR = lines.rstrip()
        if i == 18:
            v_configparameter.announceline_242_CR = lines.rstrip()
        if i == 19:
            v_configparameter.announceline_254_CR =  lines.rstrip()
        if i == 20:
            v_configparameter.announceline_255_CR =  lines.rstrip()
        if i == 21:
            v_configparameter.com_port =  int(lines.rstrip())
        if i == 22:
            v_configparameter.ethernet_port =  int(lines.rstrip())
        i += 1
    config_file.close()
    if i != 23:
        sys.exit("wrong number of configparameters")
    if v_configparameter.test_mode == 0:
        v_cr_params.sk_buffer_limit = v_configparameter.sk_buffer_limit
        v_cr_params.sk_buffer_limit_low =  v_cr_params.sk_buffer_limit * v_configparameter.sk_hysteresys / 100
    else:
        v_cr_params.sk_buffer_limit = v_configparameter.sk_buffer_limit_testmode
        v_cr_params.sk_buffer_limit_low = v_cr_params.sk_buffer_limit * v_configparameter.sk_hysteresys / 100
    return


def read_device_interface_list():
    # all devices of connection_file

    connection_file = open(v_configparameter.connection_of_devices)
    # own CR must be 1st device, own_cr is reset after the first device
    # dvice for local CR
    create_device()
    i = 1
    for linesx in connection_file:
        # skip commants andempty lines
        if linesx[0] == "#" or linesx == "":
            continue
        create_device()
        linesx.rstrip()
        if linesx[0:4] == "RS232":
            v_dev.interface_comport[i] = linesx[5:]
            linesx= linesx[0:4]
        v_dev.interface_type[i] = linesx[0:4]
        # read announcments missing
        v_dev.avtive.append(1)
      #  v_device_names_and_indiv.name.append(i)
        # active by default
       # v_device_names_and_indiv.activ.append(i)
        i += 1
    connection_file.close()
    return


def create_device():
    v_dev.avtive.append(1)
    v_dev.announcements.append([])
    # commandlength of commands for device
    v_dev.length_commandtoken.append(1)
    # data to send to CR
    v_dev.data_to_CR.append([])
    #  received  from SK
    v_dev.data_to_device.append([])
    v_dev.rules.append([])
    # list of devicetoken
    v_dev.all_toks.append([])
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
    v_dev.len.append([0,0,0,0,0,0])
    v_dev.name.append("")
    v_dev.start_time.append(0)
    v_dev.a_to_o.append({})
    v_dev.o_to_a.append({})
    v_dev.all_toks.append([])
    return

"""
------------------------------------------------
tasks, with new device
------------------------------------------------
"""


def read_announcements_of_a_device(device_dir):
    # read announcements of one device from file in device_dir
    # resolve duplicate commandtoken / commandtype:
    # do some checks on announcement data: return in case of error
    # drop lines with errors, (as neccesary)
    # find number of commands (excluding rules and ANNOUNCEMENT line)
    # missing: ask device, if file not available

    # read announcement drop comment and empty lines
    if device_dir == 0:
        # CR
        # only basic announcment, other command awre added later to the end
        v_dev.announcements[device_dir].append(v_configparameter.announceline_0_CR)
        return
    file = []
    f = Path(v_configparameter.announcements_dir + "devices/" + v_dev.name[device_dir] + "/_announcements")
    if f.exists():
        announce_file = open(v_configparameter.announcements_dir + "devices/" + v_dev.name[device_dir] + "/_announcements")
        for linesx in announce_file:
            if linesx == "" or linesx[0] == "#":
                continue
            file.append(linesx.split("\n")[0])
        announce_file.close()
    else:
        return
    # concatenate line with the same commandtoken
    # must have the same commandtype
    file1 = []
    for lines in file:
        item = lines.split(";")
        if item[0] in v_configparameter.other_lines:
            file1.append(lines)
            continue
        linenumber = 0
        found = 0
        for lines1 in file1:
            # must be previous line -> file1
            newline = lines1.split(";")
            if item[0] == newline[0]:
                if item[1].split(",")[0] == newline[1].split(",")[0]:
                    # found; concatenate lines
                    file1[linenumber] += ";".join(item[2:])
                    found= 1
                else:
                    # identical commandtoken, different commandtype: drop line
                    write_log(str(item[0]) + item[1] + newline[1] + "identical commandtoken, different commandtype in device "+ str(device_dir))
            linenumber += 1
        if found == 0:
            file1.append(lines)

    # resolve "as" lines
    file = []
    for announce in file1:
        item = announce.split(";")
        item1 = item[1].split(",")
        tok = item[0]
        if len(item1) > 1:
            # in commandlines here may be something as "as123"
            if item1[1][0:2] == "as":
                # "as"line found
                # nothing will follow the "as" number (string)
                as_number = item1[1].split("as")[1]
                as_type = item1[0].split(",")[0][1]
                # search for "as" token
                found = 0
                for lines in file:
                    if found== 0:
                        newline = lines.split(";")
                        if as_number == newline[0]:
                            # "as" line found, original type + ext
                            new_commandtype = newline[1].split(",")[0][1]
                            if new_commandtype == as_type:
                                new_commandtype = "a" + new_commandtype + ",ext" + newline[0]
                                # add original token and commandtype
                                newline[0] = tok
                                newline[1] = new_commandtype
                                file.append(";".join(newline))
                                v_dev.a_to_o[device_dir][as_number] = tok
                                v_dev.o_to_a[device_dir][tok] = as_number
                                found = 1
            else:
                file.append(announce)
        else:
            file.append(announce)

    # check command lines
    # count commands and check if match
    commands_of_device = 0
    v_dev.announcements[device_dir] = []
    for lines in file:
        #line ready now; check for valid values
        if lines[0] in v_configparameter.other_lines:
            v_dev.announcements[device_dir].append(lines)
            continue
        stripped = misc_functions.strip_des_chapter(lines)
        error = check_parameters(stripped)
        if error != "":
            write_log(str([device_dir]) + " " + str(lines) + " " + error + " line ignored for device" + str(device_dir))
        else:
            commands_of_device += 1
            v_dev.announcements[device_dir].append(lines)

    # check basic line
    temp_length_commandtoken = 1
    for lines in v_dev.announcements[device_dir]:
        if lines[0] in v_configparameter.other_lines:
            continue
        item = lines.split(";")
        temp = item[1].split(",")[0]
        if temp == "m" or temp == "l" or temp == "r" or temp == "c" or temp == "h":
            if len(item) != 10:
                # wrong basic announcement
                # ignore that device
                write_log(
                    "wrong number of parameters in basic announcement of device, device ignored: " + str(device_dir))
                v_dev.announcements[device_dir] = []
                return
            try:
                temp_length_commandtoken = int(item[7])
            except ValueError:
                # ignore that device
                write_log("wrong commandlength in basic announcment, device ignored: " + device_dir)
                v_dev.announcements[device_dir] = []
                return

    # length of commandtoken must match the value of the basic announcement
    # + 16 due to reserved token
    if device_length_of_commandtoken(commands_of_device + 16) > temp_length_commandtoken:
        write_log("number of commands do not match in " + str(device_dir) + ", device ignored")
        v_dev.announcements[device_dir] = []
        return

    # create v_dev.tok
    i = 0
    for lines in v_dev.announcements[device_dir]:
        if lines[0] in v_configparameter.other_lines:
            i += 1
            continue
        v_dev.all_toks[device_dir].append(int(v_dev.announcements[device_dir][i].split(";")[0]))
        i += 1

    v_dev.length_commandtoken[device_dir] = temp_length_commandtoken
    return

def  check_parameters(stripped):
    # check announceline for syntax errors
    # stripped is list of announcements
    ct = stripped[1]

    # basic lines not checked
    types = ["m", "l", "c", "r", "h", "s"]
    if ct in types:
        return ""
    # no check necessary
    types = ["ia", "ib", "if", "im", "in", "io", "ip", "ir", "is", "it", "iu"]
    types += ["za", "zb", "zf", "zm", "zn", "zo", "zp", "zr", "zs", "zt", "zu"]
    if stripped[1] in types:
        return ""

    try:
        value = int(stripped[0])
    except ValueError:
        return "commandtoken not numeric"

    #commandtype
    commandtype = ["ja","jb","jf","jm","jn","jo","jp","jr","js","jt","ju"]
    commandtype += ["oa","ob","of","om","on","oo","op","or","os","ot","ou"]
    commandtype += ["ra","rb","rf","rm","rn","ro","rp","rr","rs","rt","ru"]
    commandtype += ["aa","ab","af","am","an","ao","ap","ar","as","at"]
    commandtype += ["sa","sb","sf","sm","sn","so","sp","sr","ss","st","su"]
    if not ct in commandtype:
        return "unknown commandtype " + ct

    # all parameters should be numeric (switches),5 positions as minimum
    types = ["or","rr","ar","sr","os","rs","ot","rt","ou","ru","as","ss","at","st","su"]
    if ct in types:
        if len(stripped) < 4:
            return "number of parameters not sufficient"
        i = 2
        while i < len(stripped):
            try:
                value = int(stripped[i])
            except ValueError:
                return " for: "+ stripped[i] + ": parameter not numeric"
            i += 1
        return ""

    # range control: 3rd, 4th and then every 3rd parameter numeric
    types =["op","rp","ap","sp"]
    if ct in types:
        try:
            # stack
            value = int(stripped[2])
        except ValueError:
            return " for: "+ stripped[2] + ": parameter not numeric"
        if len(stripped) < 6:
               return "number of parameters not sufficient"
        i = 3
        while i < len(stripped):
            try:
                value = int(stripped[i])
            except ValueError:
                return " for: "+ stripped[i] + ": parameter not numeric"
            # 2 other parameters (text) must follow
            if len(stripped) < i + 3:
                return "wrong number of parameters"
            i += 3
        return ""

    # range control: 3rd, 4th 5th 7th (9th...) parameter is checked as numeric
    types = ["oo", "ro"]
    if ct in types:
        # stack
        try:
            value = int(stripped[2])
        except ValueError:
            return "parameter not numeric"
        i = 0
        j = 7
        k = 3
        while k < len(stripped):
            if i < 3:
                try:
                    value = int(stripped[k])
                except ValueError:
                    return "parameter not numeric"
            if i == 3:
                if stripped[k].split(",")[0] != "b":
                    return "type for LOOP / LIMIT must be b"
            if i == 4:
                i = 0
                j += 5
            else:
                i += 1
                if i > j:
                    return "wrong nmber of parameters"
            k += 1
        return ""

    # memory 1st parameter. ty, others numeric
    types = ["om","rm","am", "sm", "of", "rf", "af", "sf"]
    if ct in types:
        if len(stripped)  != 4:
            return " number of parameters must be 2"

        #type
        x_type, length, x_max = misc_functions.length_of_typ(stripped[2])
        if x_type == "e":
            return "unknown parameter type"

        # other must be numeric
        try:
            value = int(stripped[3])
        except ValueError:
            return "parameter not numeric"
        return ""

    # memory 1st parameter. ty, others numeric
    types = ["on", "rn", "an", "sn"]
    if ct in types:
        if len(stripped) != 5:
            return " number of parameters must be 5"

        # type
        x_type, length, x_max = misc_functions.length_of_typ(stripped[2])
        if x_type == "e":
            return "unknown parameter type"

        # other must be numeric
        i = 3
        while i < len(stripped):
            try:
                value = int(stripped[i])
            except ValueError:
                return "parameter not numeric"
            i += 1
        return ""

    # array. all parameter are ty
    types = ["oa","ra","ob","rb","aa","sa","ab","sb"]
    if ct in types:
        if len(stripped) < 3:
            return " number of parameters not sufficient"

        i = 2
        while i < len(stripped):
            x_type, length, x_max = misc_functions.length_of_typ(stripped[i])
            if x_type == "e":
                return ";".join(stripped) + "parameter type not valid"
            i += 1
        return ""
    # other error
    return ";".join(stripped) + "other error"


def create_sk_buffer():
    # create 4 commandrouter inputs for SK interface
    create_one_sk_buffer ("RS232")
    create_one_sk_buffer("FILE")
    create_one_sk_buffer("TERMINAL")
    create_one_sk_buffer("TELNET")
    start_ethernet_server(v_sk.ethernet_port[3],4)
    # other interfaces will follow...

def create_one_sk_buffer(interface_type):
    v_sk.active.append(1)
    v_sk.inputline.append(bytearray())
    v_sk.interface_timeout.append(0)
    v_sk.interface_type.append(interface_type)
    v_sk.last_error.append("")
    v_sk.len.append([0, 0, 0, 0, 0, 0, 0])
    v_sk.starttime.append(0)
    v_sk.baudrate.append(0)
    v_sk.interface_com_port = v_configparameter.com_port
    v_sk.number_of_bits.append(0)
    v_sk.ethernet_port.append(v_configparameter.ethernet_port)
    v_sk.channel_answer_token.append(0)
    v_sk.channel_number.append(0)
    v_sk.channel_timeout.append(0)
    v_sk.info_to_telnet.append("")
    v_sk.multi_channel.append(0)
    v_sk.source.append(0)
    v_sk.socket.append(0)
    v_sk.telnet_number.append(0)
    v_sk.ethernet_server_started.append(0)
    return
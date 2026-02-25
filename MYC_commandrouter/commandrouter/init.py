"""
name : init.py
last edited: 20260224
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
other misc functions
------------------------------------------------
readconfig used at start only
read_my_devices at start and from time to time
others are called by read_my_devices only
------------------------------------------------
"""

import pathlib
from io_handling import *
from create_new_announce_list import  *
from ld_init import *
from pathlib import Path

import v_dev
import v_sk
import sys
import v_time_values

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
            v_configparameter.com_port =  lines.rstrip()
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
    # device[0] is for local CR
    device = 1
    for linesx in connection_file:
        # skip commants andempty lines
        if linesx[0] == "#" or linesx == "":
            continue
        create_device(device)
        linesx = linesx.rstrip()
        found = 0
        if linesx[:5] == "RS232":
            v_dev.interface_type[device] = linesx[:5]
            v_dev.interface_comport[device] = linesx[5:]
            found = 1
        if linesx[0:3] == "USB":
            v_dev.interface_type[device] = linesx[:3]
            v_dev.interface_comport[device] = linesx[3:]
            found = 1
        if linesx[:4] == "FILE":
            v_dev.interface_type[device] = linesx[:4]
            v_dev.filename_in[device] = v_io.filedir + "/from_" + linesx[4:]
            v_dev.filename_out[device] = v_io.filedir + "/to_" + linesx[4:]
            found = 1
        if found:
            device += 1
    connection_file.close()
    return

def read_interfaces_anouncefilenames():
    # the user must provide the device interface
    # the CR will check if it is available and read the basic command and the devidce name and number
    # if the device is not in the devices dir, it will load it.
    # dirname is something like Test1_V06_1_Device 1_1 (name, version, individual name, individual number)
    # for all aktive devices in the device dir it will create a device and load the announcelist
    if v_dev.init_sequence == 0:
        # fffd ?
        v_dev.data_to_device[v_dev.init_device] = [0xFD]
        init_send()
        v_dev.init_sequence = 1
        # default not active
        v_dev.active[v_dev.init_device] = 0
        return
    if v_ld.from_dev_to_ld != []:
        # data arrived
        match v_dev.init_sequence:
            case 1:
                #
                if v_ld.from_dev_to_ld == 0x4:
                    # device available
                    v_dev.data_to_device[v_dev.init_device] = [0x00]
                    v_dev.init_sequence = 2
                else:
                    v_dev.init_sequence = 5
            case 2:
                # got basic_command
                v_dev.data_to_device[v_dev.init_device] = [0xF0,00,0xff]
                # device stored?
                # missing
                v_dev.init_sequence = 3
            case 3:
                v_dev.data_to_device[v_dev.init_device] = [0xFE, 0x02]
                v_dev.init_sequence = 4
            case 4:
                v_dev.data_to_device[v_dev.init_device] = [0xFE, 0x03]
                v_dev.init_sequence = 5

    if v_dev.init_sequence == 5:
        # create v_dev.anouncefile_name[v_dev.init_device]
        # missing
        if v_dev.init_device < len(v_dev.interface_type):
            v_dev.init_device += 1
            v_dev.init_sequence = 0
            v_dev.active[v_dev.init_device] = 1
        else:
            v_dev.init_ready = 1
    return

def init_send():
    if v_dev.interface_type[v_dev.init_device] == "RS232":
        dev_serial_out(v_dev.init_device)
    if v_dev.interface_type[v_dev.init_device]  == "FILE":
        dev_file_out(v_io.to_dev)
    return

def create_device(device):
    v_dev.active[device] = 1
    v_dev.announcements[device] = []
    # commandlength of commands for device
    v_dev.length_commandtoken[device] = 1
    # data to send to CR
    v_dev.data_to_CR[device] = []
    #  received  from SK
    v_dev.data_to_device[device] = []
    v_dev.rules[device] = []
    # list of devicetoken
    v_dev.all_toks[device] = []
    # v_dev.info.append(0)
 #   v_dev.input_device[device] = 0
    v_dev.interface_adress[device] = 0
    v_dev.interface_baudrate[device] = 0
    v_dev.interface_comport[device] = 0
    v_dev.interface_number_of_bits[device] = 0
    v_dev.interface_port[device] = 0
    v_dev.interface_timeout[device] = 0
    v_dev.interface_type[device] = ""
    # linelength parameters modified at real time: number of byte for next action
    v_dev.len[device] = [0,0,0,0,0,0]
    v_dev.name[device] = ""
    v_dev.start_time[device] = 0
    v_dev.a_to_o[device] = {}
    v_dev.o_to_a[device] = {}
    return

def initialization():
    v_configparameter.other_lines = ["I","L","Q","R","S","T"]

    device = 0
    while device < len(v_dev.anouncefile_name):
        # announcelist may be empty, if file not found
        read_announcements_of_a_device(device)
        device += 1
    create_new_announce_list()
    create_sk_buffer()
    # not ready:
    #  check_activity_of_devices()
    v_time_values.last_device_search = int(time.time())
    v_time_values.last_activity = time.time()
    v_time_values.time_for_activ_check = time.time()
    v_time_values.last_checktime = time.time()
    # LD init
    create_len_of_string_length()
    read_read_rulelists()
    #   create_a_to_o()
    more_all_used_toks()
    find_string_parameters()
    default_data()
    create_ld_type_for_right_side_tok()
    return

def read_announcements_of_a_device(device):
    # read announcements of one device from file in device_dir
    # resolve duplicate commandtoken / commandtype:
    # do some checks on announcement data: return in case of error
    # drop lines with errors, (as neccesary)
    # find number of commands (excluding rules and ANNOUNCEMENT line)
    # missing: ask device, if file not available

    # read announcement drop comment and empty lines
    v_dev.announcements[device] = []
    if device == 0:
        # CR
        # only basic announcement, other command are added later to the end
        v_dev.announcements[device].append(v_configparameter.announceline_0_CR)
        return
    file = []
    f = Path("devices/" + v_dev.anouncefile_name[device])
    if f.exists():
        announce_file = open("devices/" + v_dev.anouncefile_name[device])
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
        if item[0] in v_announcelist.other_lines:
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
                    write_log(str(item[0]) + item[1] + newline[1] + "identical commandtoken, different commandtype in device "+ str(device))
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
                                v_dev.a_to_o[device][as_number] = tok
                                v_dev.o_to_a[device][tok] = as_number
                                found = 1
            else:
                file.append(announce)
        else:
            file.append(announce)

    # check command lines
    # count commands and check if match
    commands_of_device = 0
    for lines in file:
        #line ready now; check for valid values
        if lines[0] in v_configparameter.other_lines:
            v_dev.announcements[device].append(lines)
            continue
        stripped = misc_functions.strip_des_chapter(lines)
        error = check_parameters(stripped)
        if error != "":
            write_log(str([device]) + " " + str(lines) + " " + error + " line ignored for device" + str(device))
        else:
            commands_of_device += 1
            v_dev.announcements[device].append(lines)

    # check basic line
    temp_length_commandtoken = 1
    for lines in v_dev.announcements[device]:
        if lines[0] in v_configparameter.other_lines:
            continue
        item = lines.split(";")
        temp = item[1].split(",")[0]
        if temp == "m" or temp == "l" or temp == "r" or temp == "c" or temp == "h":
            if len(item) != 10:
                # wrong basic announcement
                # ignore that device
                write_log(
                    "wrong number of parameters in basic announcement of device, device ignored: " + str(device))
                v_dev.announcements[device] = []
                return
            try:
                temp_length_commandtoken = int(item[7])
            except ValueError:
                # ignore that device
                write_log("wrong commandlength in basic announcment, device ignored: " + device)
                v_dev.announcements[device] = []
                return

    # length of commandtoken must match the value of the basic announcement
    # + 16 due to reserved token
    if device_length_of_commandtoken(commands_of_device + 16) > temp_length_commandtoken:
        write_log("number of commands do not match in " + str(device) + ", device ignored")
        v_dev.announcements[device] = []
        return

    # create v_dev.tok
    i = 0
    for lines in v_dev.announcements[device]:
        if lines[0] in v_configparameter.other_lines:
            i += 1
            continue
        dev_tok = int(v_dev.announcements[device][i].split(";")[0])
        v_dev.all_toks[device].append(dev_tok)
        i += 1

    v_dev.length_commandtoken[device] = temp_length_commandtoken
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
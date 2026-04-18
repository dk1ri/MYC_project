"""
name : init.py
last edited: 20260414
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
------------------------------------------------
readconfig used at start only
read_my_devices at start and from time to time
others are called by read_my_devices only
------------------------------------------------
"""

from io_handling import *
from create_new_announce_list import  *
from ld_init import *
from pathlib import Path

import v_dev
import v_io
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
        if len(lines) == 0:
            continue
        match i:
            case 0:
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
            case 1:
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
            case 2:
                # dir name for dev file inteface
                v_configparameter.dev_file_interface = lines.rstrip()
            case 3:
                v_configparameter.local_interface_files = int(lines.rstrip())
            case 4:
                v_configparameter.sk_file_interface = lines.rstrip()
            case 5:
                if v_configparameter.local_interface_files  == 0:
                    v_configparameter.to_web = "c:/xampp/htdocs/Usb_interface/" + lines.rstrip()
                else:
                    v_configparameter.to_web = v_configparameter.sk_file_interface + "/" + lines.rstrip()
            case 6:
                if v_configparameter.local_interface_files  == 0:
                    v_configparameter.to_web = "c:/xampp/htdocs/Usb_interface/" + lines.rstrip()
                else:
                    v_configparameter.from_web = v_configparameter.sk_file_interface + "//" +lines.rstrip()
            case 7:
                # time in sec for checking weather a device is active
                v_configparameter.time_for_activ_check = int(lines.rstrip())
            case 8:
                # time in sec for searching for new devices
                v_configparameter.time_for_device_search = int(lines.rstrip())
            case 9:
                # time in sec for command timeout
                v_configparameter.time_for_command_timeout = int(lines.rstrip())
            case 10:
                if lines == "home":
                        v_configparameter.logfile = "commandrouter_config/logfile"
                else:
                    v_configparameter.logfile = lines.rstrip()
            case 11:
                # time in sec for check of logfile
                v_configparameter.time_for_logfile_check = int(lines.rstrip())
            case 12:
                # max lines of logfile
                v_configparameter.max_log_lines = int(lines.rstrip())
            case 13:
                # system timeout
                v_configparameter.system_timeout = int(lines.rstrip())
            case 14:
                # channel timeout
                v_configparameter.channel_timeout = int(lines.rstrip())
            case 15:
                # test mode
                v_configparameter.test_mode = int(lines.rstrip())
            case 16:
                # sk buffer limit
                v_configparameter.sk_buffer_limit = int(lines.rstrip())
            case 17:
                # sk buffer limit for test_mode
                v_configparameter.sk_buffer_limit_testmode = int(lines.rstrip())
            case 18:
                # sk buffer limit hysteresys
                v_configparameter.sk_histeresys = int(lines.rstrip())
            case 19:
                v_configparameter.com_port =  lines.rstrip()
            case 20:
                v_configparameter.ethernet_port =  int(lines.rstrip())
            case 21:
                v_cr_params.name =  lines.rstrip()
            case 22:
                v_cr_params.number = lines.rstrip()
            case 23:
                v_cr_params.usb_active = int(lines.rstrip())
            case 24:
                v_cr_params.telnet_active = int(lines.rstrip())
            case 25:
                v_cr_params.file_active = int(lines.rstrip())
            case 26:
                v_cr_params.terminal_active = int(lines.rstrip())
            case 27:
                v_cr_params.from_ru = v_configparameter.sk_file_interface + "//" + lines.rstrip()
            case 28:
                v_cr_params.to_ru = v_configparameter.sk_file_interface + "//" + lines.rstrip()
        i += 1
    config_file.close()
    if i != 29:
        sys.exit("wrong number of configparameters")
    if v_configparameter.test_mode == 0:
        v_cr_params.sk_buffer_limit = v_configparameter.sk_buffer_limit
        v_cr_params.sk_buffer_limit_low =  v_cr_params.sk_buffer_limit * v_configparameter.sk_hysteresys / 100
    else:
        v_cr_params.sk_buffer_limit = v_configparameter.sk_buffer_limit_testmode
        v_cr_params.sk_buffer_limit_low = v_cr_params.sk_buffer_limit * v_configparameter.sk_hysteresys / 100
    # read announcements for CR the location is fixed
    cr_file = "commandrouter_config/CR"
    if not os.path.isfile(cr_file):
        sys.exit("Missing file:  " + cr_file)
    cr_file_ = open(cr_file)
    i = 0
    for lines in cr_file_:
        if lines[0] == "#" or lines[0] == " ":
            continue
        lines = lines.splitlines()[0]
        if len(lines) == 0:
            continue
        v_configparameter.cr0_announcements[i] = lines
        i += 1
    cr_file_.close()
    return

def read_device_interface_list():
    # all devices of connection_file

    connection_file = open(v_configparameter.connection_of_devices)
    # device[0] is for local CR
    device = 1
    for linesx in connection_file:
        # skip comments and empty lines
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
        if found == 1:
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
        # device activ?
        v_dev.data_to_device[v_dev.init_device] = bytearray()
        v_dev.data_to_device[v_dev.init_device].append(0xFD)
        init_send()
        v_dev.init_sequence = 1
        # default not active
        v_dev.active[v_dev.init_device] = 0
        return
    if v_dev.data_to_CR != bytearray:
        # data arrived
        match v_dev.init_sequence:
            case 1:
                #
                if v_dev.data_to_CR == bytearray(0x4):
                    # device available
                    v_dev.data_to_device[v_dev.init_device] = bytearray()
                    v_dev.data_to_device[v_dev.init_device].append(0x00)
                    v_dev.init_sequence = 2
                else:
                    v_dev.init_sequence = 5
            case 2:
                # got basic_command
                v_dev.data_to_device[v_dev.init_device] = bytearray()
                v_dev.data_to_device[v_dev.init_device].extend(0xF0,00,0xff)
                # device stored?
                # missing
                v_dev.init_sequence = 3
            case 3:
                v_dev.data_to_device[v_dev.init_device] = bytearray()
                v_dev.data_to_device[v_dev.init_device].extend(0xFE, 0x02)
                v_dev.init_sequence = 4
            case 4:
                v_dev.data_to_device[v_dev.init_device] = bytearray()
                v_dev.data_to_device[v_dev.init_device].extend(0xFE, 0x03)
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
    dev_serial_out(v_dev.init_device)
    return

def create_device(device):
    v_dev.active[device] = 1
    # commandlength of commands for device
    v_dev.length_commandtoken[device] = 1
    # data to send to CR
    v_dev.data_to_CR[device] = bytearray()
    #  received  from SK
    v_dev.all_answer_toks[device] = []
    v_dev.data_to_device[device] = bytearray()
    v_dev.interface_adress[device] = 0
    v_dev.interface_baudrate[device] = 0
    v_dev.interface_comport[device] = 0
    v_dev.interface_number_of_bits[device] = 0
    v_dev.interface_port[device] = 0
    v_dev.interface_timeout[device] = 0
    v_dev.interface_type[device] = ""
    v_dev.len[device] = [0,0,0,0,0,0]
    v_dev.name[device] = ""
    v_dev.start_time[device] = 0
    v_dev.a_to_o[device] = {}
    v_dev.o_to_a[device] = {}
    v_dev.all_toks_of_dev[device] = []
    v_dev.all_conditions[device] = []
    v_dev.left_toks[device] = []
    v_dev.right_toks[device] = []
    return

def initialization():
    remove_at_start()
    # device 0 is CR
    # CR
    # only basic announcement, other command are added later to the end
    v_dev.announcements[0] = {}
    v_dev.announcements[0][0] = v_configparameter.cr0_announcements[0].split(";")
    v_dev.announcments_not_stripped[0] = {}
    v_dev.announcments_not_stripped[0][0] = bytearray([])
    v_dev.announcments_not_stripped[0][0].extend(misc_functions.tok_to_bytes(len(v_configparameter.cr0_announcements[0]), 1))
    v_dev.announcments_not_stripped[0][0].extend(bytes(map(ord, v_configparameter.cr0_announcements[0])))
    device = 1
    while device <= len(v_dev.anouncefile_name):
        # announcelist may be empty, if file not found
        read_announcements_of_a_device(device)
        device += 1
    create_new_announce_list()
    create_sk_buffer()
    v_time_values.last_device_search = int(time.time())
    v_time_values.last_activity = time.time()
    v_time_values.time_for_activ_check = time.time()
    v_time_values.last_checktime = time.time()
    # LD init
    create_len_of_string_length()
    #   create_a_to_o()
    find_string_parameters()
    default_data()
    create_ld_type_for_right_side_tok()
    return

def read_announcements_of_a_device(device):
    # result:   v_dev.announcements[device] (without other lines: R L etc
    #           v_dev.other_lines[device] R, L etc lines
    # read announcements of one device from file in device_dir
    # drop comment and empty lines and other "non announcement" lines
    # resolve duplicate commandtoken / commandtype:
    # resolve as lines
    # do some checks on announcement data: return in case of error
    # drop lines with errors, (as neccesary)
    # missing: ask device, if file not available
    v_dev.announcements[device] = {}
    v_dev.announcments_not_stripped[device] = {}
    file = []
    if v_configparameter.local_interface_files == 0:
        announce_file_ = "c:/xampp/devices/cr/announce_for_cr"
    else:
        announce_file_ = "devices/" + v_dev.anouncefile_name[device]
    f = Path(announce_file_)
    if f.exists():
        announce_file = open(announce_file_)
        for linesx in announce_file:
            if linesx == "" or linesx[0] == "#" or linesx[0] == "'":
                continue
            if linesx[0:9] == "Announce:":
                continue
            linesx = linesx.split("\n")[0]
            if linesx[0:4].upper() == "DATA":
                linesx = linesx[6:]
                linesx = linesx[:-1] + linesx[-1].replace("\"", "")
            if linesx == "":
                continue
            file.append(linesx.split("\n")[0])
        announce_file.close()
    else:
        return

    # other lines
    file1 = []
    v_dev.other_lines[device] = []
    v_dev.rules[device] = []
    for lines in file:
        if lines[0] == "R" or lines[0] == "Q":
            v_dev.rules[device].append(lines)
        elif lines[0] in v_configparameter.other_lines_id:
            v_dev.other_lines[device].append(lines)
        else:
            file1.append(lines)

    # drop 240 command
    # v_dev.length_of_announcements_count[device]
    file0 = []
    number_of_lines = len(file0)
    real_240 = misc_functions.real_tok(240, number_of_lines)
    for lines in file1:
        tok = int(lines.split(";")[0])
        if tok != real_240:
            v_dev.all_toks_of_dev[device].append(tok)
            file0.append(lines)
    # line ready now; check for valid values
    # concatenate line with the same commandtoken
    # must have the same commandtype; must be next line
    linenumber = 0
    file2 = []
    last_tok= "0"
    last_ct = ""
    for lines in file0:
        found = 0
        newline = lines.split(";")
        if linenumber > 0:
            # must be previous line -> file1
            if last_tok == newline[0].split(",")[0] and last_ct == newline[1].split(",")[0]:
                # found; concatenate lines
                file2.append(lines + ";".join(newline[2:]))
                found= 1
        if found == 0:
            file2.append(lines)
        last_tok = newline[0].split(",")[0]
        last_ct = newline[1].split(",")[0]
        linenumber += 1

    # resolve "as" lines
    file = []
    for announce in file2:
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
        stripped = misc_functions.strip_des_chapter(lines)
        error = check_parameters(stripped)
        if error != "":
            write_log(str([device]) + " " + str(lines) + " " + error + " line ignored for device" + str(device))
        else:
            commands_of_device += 1
            v_dev.announcements[device][stripped[0]] = stripped
            v_dev.announcments_not_stripped[device][stripped[0]] = bytearray([])
            v_dev.announcments_not_stripped[device][stripped[0]].extend(misc_functions.tok_to_bytes(len(stripped), misc_functions.length_of_int(len(stripped))))
            v_dev.announcments_not_stripped[device][stripped[0]].extend(bytes(map(ord, lines)))

    # create v_dev.all_answer_toks
    for cr_tok in  v_dev.announcements[device]:
        line =  v_dev.announcements[device][cr_tok]
        if line[1].split(",")[0][0] == "a":
            v_dev.all_answer_toks[device].append(int(line[0]))
    # check rules
    misc_functions.handle_rules(device)

    # check basic line
    temp_length_commandtoken = 1
    for tok in v_dev.announcements[device]:
        lines = v_dev.announcements[device][tok]
        temp = lines[1].split(",")[0]
        if temp == "m" or temp == "l" or temp == "r" or temp == "c" or temp == "h":
            if len(lines) != 10:
                # wrong basic announcement
                # ignore that device
                write_log(
                    "wrong number of parameters in basic announcement of device, device ignored: " + str(device))
                delete_dev(device)
                return
            try:
                temp_length_commandtoken = int(lines[7])
            except ValueError:
                # ignore that device
                write_log("wrong commandlength in basic announcment, device ignored: " + device)
                delete_dev(device)
                return

    # length of commandtoken must match the value of the basic announcement
    # + 16 due to reserved token
    if device_length_of_commandtoken(commands_of_device + 16) > temp_length_commandtoken:
        write_log("number of commands do not match in " + str(device) + ", device ignored")
        delete_dev(device)
        return

    # other checks
    for tok in v_dev.announcements[device]:
        lines = v_dev.announcements[device][tok]
        err = check_parameters(lines)
        if err != "":
            # ignore that device
            write_log(err)
            v_dev.announcements[device] = {}
            v_dev.announcments_not_stripped[device] = {}
            v_dev.other_lines[device] = []

    v_dev.length_commandtoken[device] = temp_length_commandtoken
    return

def delete_dev(device):
    v_dev.announcements[device] = {}
    v_dev.announcments_not_stripped[device] = {}
    v_dev.other_lines[device] = []
    v_dev.rules[device] = []
    return

def check_parameters(stripped):
    # check one announceline for syntax errors
    # stripped is list of announcements
    ct = stripped[1].split(",")[0]

    # basic lines not checked
    types = ["m", "l", "c", "r", "h", "s"]
    if not ct in types:
        return ""
    # no check necessary
    types = ["ia", "ib", "if", "im", "in", "io", "ip", "ir", "is", "it", "iu"]
    types += ["za", "zb", "zf", "zm", "zn", "zo", "zp", "zr", "zs", "zt", "zu"]
    if stripped[1] in types:
        return ""

    try:
        value = int(stripped[0].split(",")[0])
    except ValueError:
        return "commandtoken not numeric"

    #commandtype
    commandtype = ["m", "c", "r", "l", "h"]
    commandtype += ["ja","jb","jf","jm","jn","jo","jp","jr","js","jt","ju"]
    commandtype += ["oa","ob","of","om","on","oo","op","or","os","ot","ou"]
    commandtype += ["ra","rb","rf","rm","rn","ro","rp","rr","rs","rt","r"]
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
                value = int(stripped[i].split(",")[0])
            except ValueError:
                return " for: "+ stripped[i] + ": parameter not numeric"
            i += 1

    # range control: 3rd, 4th and then every 3rd parameter numeric
    types =["op","rp","ap","sp"]
    if ct in types:
        try:
            # stack
            value = int(stripped[2].split(",")[0])
        except ValueError:
            return " for: "+ stripped[2] + ": parameter not numeric"
        if len(stripped) < 6:
               return "number of parameters not sufficient"
        i = 3
        while i < len(stripped):
            try:
                value = int(stripped[i].split(",")[0])
            except ValueError:
                return " for: "+ stripped[i] + ": parameter not numeric"
            # 2 other parameters (text) must follow
            if len(stripped) < i + 3:
                return "wrong number of parameters"
            i += 3

    # range control: 3rd, 4th 5th parameter is checked as numeric 6th as a or b
    types = ["oo", "ro"]
    if ct in types:
        # stack
        try:
            value = int(stripped[2].split(",")[0])
        except ValueError:
            return "parameter not numeric"
        i = 0
        # minimum number of parameters
        j = 9
        k = 3
        while k < len(stripped):
            if i < 3:
                try:
                    value = int(stripped[k].split(",")[0])
                except ValueError:
                    return "parameter not numeric"
            if i == 3:
                if stripped[k] != "a" and stripped[k] != "b":
                    return "parameter not a or b"
            k += 1
            i += 1
            if i == 6:
                # last parameter of this dimension
                if len(stripped) > j:
                    j += 6
                    i = 0
        if k < j:
            return " parameters missing"

    # memory 1st parameter. ty, others numeric
    types = ["om","rm","am", "sm", "of", "rf", "af", "sf"]
    if ct in types:
        if len(stripped)  != 4:
            return " number of parameters must be 2"

        #type
        x_type, length, x_max = misc_functions.length_of_typ(stripped[2].split(",")[0])
        if x_type == "e":
            return "unknown parameter type"

        # other must be numeric
        try:
            value = int(stripped[3].split(",")[0])
        except ValueError:
            return "parameter not numeric"

        # type
        x_type, length, x_max = misc_functions.length_of_typ(stripped[2].split(",")[0])
        if x_type == "e":
            return " unknown parameter type"

        # other must be numeric
        i = 3
        while i < len(stripped):
            try:
                value = int(stripped[i].split(",")[0])
            except ValueError:
                return " parameter not numeric"
            i += 1

    # array. all parameter are ty
    types = ["oa","ra","ob","rb","aa","sa","ab","sb"]
    if ct in types:
        if len(stripped) < 3:
            return " number of parameters not sufficient"

        i = 2
        while i < len(stripped):
            x_type, length, x_max = misc_functions.length_of_typ(stripped[i].split(",")[0])
            if x_type == "e":
                return ";".join(stripped) + "parameter type not valid"
            i += 1
    # no error found
    return ""

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
    v_sk.last_error.append("no error")
    v_sk.data_len.append([0, 0, 0, 0, 0, 0, 0])
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
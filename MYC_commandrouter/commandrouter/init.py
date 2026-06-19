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
from time import sleep

import v_cr_params
from io_handling import *
from create_new_announce_list import  *
from ld_init import *
from pathlib import Path

import v_dev
import v_io
import v_sk
import sys
import v_time_values

def read_cr_line():
    # read CR 255 line and initialize SK interface (5th line)
    # read announcements for CR the location is fixed
    cr_file = "commandrouter_config/CR"
    if not os.path.isfile(cr_file):
        sys.exit("Missing file:  " + cr_file)
    cr_file_ = open(cr_file)

    # read CR own data
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
    c254_line = v_configparameter.cr0_announcements[5]
    c255_line = v_configparameter.cr0_announcements[6]
    v_cr_params.c254_line = c254_line
    v_cr_params.c255_line = c255_line
    try:
        v_cr_params.name = c255_line.split(";")[2].split(",")[2]
        v_cr_params.number = int(c255_line.split(";")[3].split(",")[2])
    except:
        sys.exit("error in CR 255 line with " + c255_line)
    # all interfaces get a number
    sk_interface_number = 0
    if len(c255_line.split("TERMINAL,")) > 1:
        active = c255_line.split("TERMINAL,")[1].split(",")[0].split(";")[0]
        if active == "1":
            create_one_sk_buffer(sk_interface_number,1,"TERMINAL", "", "","")
            print("possible SK interface: TERMINAL")
        else:
            create_one_sk_buffer(sk_interface_number, 1, "TERMINAL", "", "", "")
    sk_interface_number += 1

    if len(c255_line.split("TELNET,")) > 1:
        # one telnet allowed only (one port number)
        active = c255_line.split("TELNET,")[1].split(",")[0].split(";")[0]
        if active == "1":
            v_sk.ethernet_host = c255_line.split("ETH_ADRESS,")[1].split(",")[0].split(";")[0]
            v_sk.ethernet_port = c255_line.split("ETH_PORT,")[1].split(",")[0].split(";")[0]
            if len(v_sk.ethernet_host) > 0 and len(sk.ethernet_port) > 0:
                # create_one_sk_buffer(sk_interface_number, "TELNET", "", "")
                create_one_sk_buffer(sk_interface_number, active, "TELNET", "", "", "")
                start_ethernet_client(v_sk.ethernet_host, v_sk.ethernet_port[sk_interface_number],sk_interface_number)
                print("possible SK interface: TELNET port " + str(v_sk.ethernet_port[sk_interface_number]))
            else:
                create_one_sk_buffer(sk_interface_number, active, "TELNET", "", "", "")
        else:
            create_one_sk_buffer(sk_interface_number, active, "TELNET", "", "", "")
        sk_interface_number += 1

    sk_interface_number = find_multiple(c255_line, "a,USB,", "b,USB_COMPORT,", sk_interface_number)

    sk_interface_number = find_multiple(c255_line, "a,RS232,", "b,RS232_COMPORT,", sk_interface_number)

    sk_interface_number = find_multiple(c255_line, "a,FILE,", "40,FILENAME,", sk_interface_number)

    # other interfaces will follow...

def find_multiple(c255_line, type_, name, sk_interface_number):
    # find SK interface (may be more than one) for file and serial
    rest = c255_line.split(type_)
    i = 1
    while i < len(rest):
        line = rest[i]
        try:
            active = line.split(";")[0]
        except:
            sys.exit("error in CR 255 line with " + type_ + " stopped")
        try:
            found_name = line.split(name)[1].split(";")[0]
        except:
            sys.exit("error in CR 255 line with " + type_ + " stopped")
        if active == "1":
            # active
            if type_ == "a,USB," or type_ == "a,RS232,":
                error, serial_interface = serial_open("COM" + found_name, 0)
                if error == 0:
                    create_one_sk_buffer(sk_interface_number,1,type_[2:-1], found_name, serial_interface, "")
                    print("possible SK interface: " + type_[2:-1] + found_name)
                else:
                    create_one_sk_buffer(sk_interface_number,0, "", "", "", "")
                    v_cr_params.usb_com_port.append(int(found_name))
            elif type_ == "a,FILE,":
                remove_at_start(found_name)
                create_one_sk_buffer(sk_interface_number,1,type_[2:-1], "", "", found_name)
                print("possible SK interface: " + type_[2:-1] + " "+ found_name)
            sk_interface_number += 1
        else:
            # not active
            create_one_sk_buffer(sk_interface_number,0, "", "", "", "")
            sk_interface_number += 1
        i += 1
    return sk_interface_number

def create_one_sk_buffer(sk_interface_number,active,interface_type, comport, serial_interface, file):
    # read at initialization only, but may be updated and read by 254 255 command
    v_sk.active.append(active)
    v_sk.interface_type.append(interface_type)
    v_sk.inputline.append(bytearray())
    v_sk.interface_timeout.append(0)
    v_sk.data_len.append([0, 0, 0, 0, 0, 0, 0])
    v_sk.starttime.append(0)
    v_sk.serial_interface[sk_interface_number] = serial_interface
    v_sk.baudrate.append(0)
    v_sk.com_port = comport
    # fixed port
    v_sk.ethernet_port.append(23)
    v_sk.channel_answer_token.append(0)
    v_sk.channel_number.append(0)
    v_sk.channel_timeout.append(0)
    v_sk.info_to_telnet.append("")
    v_sk.multi_channel.append(0)
    v_sk.source.append(0)
    v_sk.socket.append(0)
    v_sk.telnet_number.append(0)
    v_sk.ethernet_server_started.append(0)
    if file != "":
        # split filename fro dirname
        spl = file.split("/")
        spl[-1] = "to_" + spl[-1]
        v_sk.file_in.append("/".join(spl))
        spl = file.split("/")
        spl[-1] = "from_" + spl[-1]
        v_sk.file_out.append("/".join(spl))
    else:
        v_sk.file_in.append("")
        v_sk.file_out.append("")

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
                   v_configparameter.announcements_dir = "devices"
                else:
                    v_configparameter.announcements_dir = lines.rstrip()
                    v_configparameter.announcements_dir = v_configparameter.announcements_dir
                if not os.path.isdir(v_configparameter.announcements_dir):
                    sys.exit("Missing directory:  " + v_configparameter.announcements_dir)
            case 2:
                # dir name for dev file inteface
                v_configparameter.dev_file_interface = lines.rstrip()
            case 3:
                # time in sec for checking weather a device is active
                v_configparameter.time_for_activ_check = int(lines.rstrip())
            case 4:
                # time in sec for searching for new devices
                v_configparameter.time_for_device_search = int(lines.rstrip())
            case 5:
                # time in sec for command timeout
                v_configparameter.time_for_command_timeout = int(lines.rstrip())
            case 6:
                if lines == "home":
                        v_configparameter.logfile = "commandrouter_config/logfile"
                else:
                    v_configparameter.logfile = lines.rstrip()
            case 7:
                # time in sec for check of logfile
                v_configparameter.time_for_logfile_check = int(lines.rstrip())
            case 8:
                # max lines of logfile
                v_configparameter.max_log_lines = int(lines.rstrip())
            case 9:
                # system timeout
                v_configparameter.system_timeout = int(lines.rstrip())
            case 10:
                # channel timeout
                v_configparameter.channel_timeout = int(lines.rstrip())
            case 11:
                # test mode
                v_configparameter.test_mode = int(lines.rstrip())
                if v_configparameter.test_mode == 1:
                    v_configparameter.time_for_command_timeout *= 100
            case 12:
                # sk buffer limit
                v_configparameter.sk_buffer_limit = int(lines.rstrip())
            case 13:
                # sk buffer limit for test_mode
                v_configparameter.sk_buffer_limit_testmode = int(lines.rstrip())
            case 14:
                # sk buffer limit hysteresys
                v_configparameter.sk_histeresys = int(lines.rstrip())
            case 15:
                v_cr_params.cr_search_announclist = int(lines.rstrip())
        i += 1
    config_file.close()
    if i != 16:
        sys.exit("wrong number of configparameters")
    if v_configparameter.test_mode == 0:
        v_cr_params.sk_buffer_limit = v_configparameter.sk_buffer_limit
        v_cr_params.sk_buffer_limit_low =  v_cr_params.sk_buffer_limit * v_configparameter.sk_hysteresys / 100
    else:
        v_cr_params.sk_buffer_limit = v_configparameter.sk_buffer_limit_testmode
        v_cr_params.sk_buffer_limit_low = v_cr_params.sk_buffer_limit * v_configparameter.sk_hysteresys / 100
    return

def create_devices():
    # read known devices
    data = os.listdir(v_configparameter.announcements_dir)
    i = 0
    v_cr_params.known_devices = []
    while i < len(data):
        line = data[i]
        j = 0
        v_cr_params.known_devices.append([])
        v_cr_params.known_devices[i] = ""
        while j < len(line):
            v_cr_params.known_devices[i] += line[j]
            j += 1
        i += 1
    return

def read_device_interface_list():
    # all devices of connection_file
    connection_file = open(v_configparameter.connection_of_devices)
    # device[0] is for local CR
    # check one device only
    for linesx in connection_file:
        # skip comments and empty lines
        if linesx[0] == "#" or linesx == "":
            continue
        else:
            linesx = linesx.rstrip()
            found = 0
            if linesx[:5] == "RS232":
                v_cr_params.interface_typ = 0
                v_cr_params.interface_name = linesx
                v_cr_params.interface_com_port = linesx[5:]
                v_cr_params.interface_baudrate = 0
                found = 1
            elif linesx[0:3] == "USB":
                v_cr_params.interface_typ = 1
                v_cr_params.interface_name = linesx
                v_cr_params.interface_com_port = linesx[3:]
                v_cr_params.interface_baudrate = 0
                found = 1
            elif linesx[0:4] == "FILE":
                v_cr_params.interface_typ= 2
                v_cr_params.interface_name = linesx
                v_cr_params.interface_file_in = v_io.filedir + "/from_" + linesx[4:]
                v_cr_params.interface_file_out = v_io.filedir + "/to_" + linesx[4:]
                found = 1
            elif linesx[0:4] == "PIPE":
                v_cr_params.interface_typ = 3
                v_cr_params.interface_name = linesx
                v_cr_params.interface_pipe = v_io.filedir + "/from_" + linesx[4:]
                found = 1
            elif linesx[0:3] == "ETH":
                v_cr_params.interface_typ = 4
                v_cr_params.interface_name = linesx
                v_cr_params.interface_ethernet_port = linesx[3:]
                found = 1
            if found == 1:
                check_device_interface()
    connection_file.close()
    return


def check_device_interface():
    # for one interface (device)
    # the user must provide the device interface
    # the CR will check if it is available and read the basic command and the device name and number
    # if the device is not in the devices dir, it will load it.
    # dirname is something like Test1_V06_1_Device 1_1 (name, version, individual name, individual number)
    # for all active devices in the device dir it will create a device and load the announcelist
    # sequencenumber 0: continue -1: stop  1 - 3: different steps
    sequence_number = 0
    # device_finished: 0: continue;     1: error;  2: final ok 3: final ok new
    device_finished = 0
    number_of_announcements = 0
    length_of_number_of_announcements = 1
    skip_bytes_of_announcelines = 0
    # xxF0 + length_of_number_of_announcements * 2 + 1 (length of str_len
    data = []
    new_announce_list = []
    v_time_values.time_wait_for_device = time.time()
    number_count = 0
    dev_id = ""
    temp_basic_command = ""
    # device_finished: 0: not ready, 1: error, 2: no error
    while device_finished == 0:
        if time.time() - v_time_values.time_wait_for_device > 3:
            misc_functions.write_log("device timeout, not found")
            sequence_number = -1
            device_finished = 1
        match sequence_number:
            case 3:
                # got number_of_announcelines and length
                error = 0
                if number_count < number_of_announcements and error == 0:
                    time.sleep(0.1)
                    data_to_send = bytearray()
                    data_to_send.append(0xF0)
                    data_to_send.extend(int_to_ba(number_count, length_of_number_of_announcements))
                    data_to_send.extend(int_to_ba(0x01, length_of_number_of_announcements))
                    v_time_values.time_wait_for_device = time.time()
                    error, data = init_send_read(data_to_send)
                    new_announce_list.append(data[skip_bytes_of_announcelines:])
                    if error == 0:
                        number_count += 1
                    match error:
                        case 1:
                            misc_functions.write_log("0xF0 write failed: " + str(number_count - 1))
                            device_finished = 1
                            sequence_number = -1
                        case 2:
                            misc_functions.write_log("0xF0 read returned empty line, try again; line: " + str(number_count - 1))
                            sequence_number = -1
                            device_finished = 1
                else:
                    if error == 0:
                        # ok
                        sequence_number = -1
                        device_finished = 2
            case 2:
                # got basic_command, drop "0" and len
                i = 2
                line = ""
                while i < len(data):
                    line += chr(data[i])
                    i += 1
                line_a = line.split(";")
                temp_basic_command = line
                v_cr_params.b_name = line_a[3]
                v_cr_params.length_commandtoken = int(line_a[7])
                dev_id = line_a[2] + "_" + line_a[3] + "_" + line_a[4]
                for dev in v_cr_params.known_devices:
                    de = dev.replace(".bas","").replace(".txt","")
                    if dev_id == de:
                        filesize = os.path.getsize("devices/" + dev)
                        if filesize > 0:
                            # announcefile already exists
                            sequence_number = -1
                            # finished, device active announcelist available
                            device_finished = 3
                if device_finished == 0:
                    while i < len(data):
                        line += chr(data[i])
                        i += 1
                    number_of_announcements = int(line_a[8])
                    length_of_number_of_announcements = length_of_int(number_of_announcements)
                    skip_bytes_of_announcelines = v_announcelist.length_of_full_elements + 2 * length_of_number_of_announcements + 2
                    misc_functions.write_log("reading announcelist " + v_cr_params.interface_name)
                    sequence_number = 3
            case 1:
                # device available
                v_time_values.time_wait_for_device = time.time()
                error, data = init_send_read(bytes([0x00]) )
                if error == 1:
                    misc_functions.write_log("basic command read error")
                    sequence_number = -1
                    device_finished = 1
                else:
                    if len(data) > 0:
                        if data[0] != "":
                            sequence_number = 2
            case 0:
                # device activ?
                v_time_values.time_wait_for_device = time.time()
                if v_cr_params.interface_typ == 0 or v_cr_params.interface_typ == 1:
                    # RS232 or USB
                    error, v_cr_params.serial_interface = serial_open(v_cr_params.interface_com_port, 1)
                    if error == 0:
                        # device is active
                        v_time_values.time_wait_for_device = time.time()
                        sequence_number = 1
                    else:
                        misc_functions.write_log(v_cr_params.interface_com_port + " activ read error")
                        sequence_number = -1
                        device_finished = 1
                elif v_cr_params.interface_typ == 2:
                    # file
                    data = init_send_read(bytes([0xFD]))
                    if len(data) > 0:
                        if data == bytes([0xfd, 0x04]):
                            sequence_number = 1
                        else:
                            misc_functions.write_log("04 wrong data")
                            sequence_number = -1
                            device_finished = 1
                    else:
                        misc_functions.write_log(v_cr_params.interface_file_in +" FILE activ read error")
                        sequence_number = -1
                        device_finished = 1
                elif v_cr_params.interface_typ == 3:
                    # Pipe
                    error, data = init_send_read(bytes([0xFD]))
                    if error == 0 and len(data) > 0:
                        if data == bytes([0xfd, 0x04]):
                            sequence_number = 1
                        else:
                            misc_functions.write_log("04 wrong data")
                            sequence_number = -1
                            device_finished = 1
                    if error > 0:
                        misc_functions.write_log("04 (activ) read error")
                        sequence_number = -1
                        device_finished = 1
                elif v_cr_params.interface_typ == 4:
                    # ethernet
                    error = start_ethernet_server(v_cr_params.interface_ethernet_port, v_cr_params.device)
                    if error == 0:
                        v_dev.data_to_device[v_cr_params.device] = bytes([0xFD])
                        sleep(.2)
                    if v_dev.data_to_CR[v_cr_params.device] != bytes([0xFD,0x04]):
                        misc_functions.write_log("04 wrong data")
                        sequence_number = -1
                        device_finished = 1
                    else:
                        sequence_number = 1
    if device_finished > 1:
        # read 255 line
        error, name = init_send_read(bytes([0xFf,0x00]))
        if error == 0:
            error, number = init_send_read(bytes([0xFf, 0x01]))
            if error == 0:
                # serial is open if device is serial
                v_dev.f255_name[v_cr_params.device] = name[v_cr_params.length_commandtoken + 2:].decode("utf-8")
                v_dev.f255_number[v_cr_params.device] = str(int.from_bytes(number[v_cr_params.length_commandtoken + 1:]))
                v_dev.anouncefile_name[v_cr_params.device] = v_configparameter.announcements_dir + "/" + dev_id
                v_dev.basic_commands[v_cr_params.device] = temp_basic_command
                create_device(v_cr_params.device)
                if device_finished == 2:
                    # write new announcements to file
                    dev_file = open(v_dev.anouncefile_name[v_cr_params.device], "w")
                    for lines in new_announce_list:
                        i = 0
                        s = ""
                        if len(lines) > 0:
                            while i < len(lines):
                                s += chr(lines[i])
                                i += 1
                            s += "\n"
                            dev_file.write(s)
                    dev_file.close()
                v_cr_params.device += 1
                print("device found " + dev_id)
    return

def init_send_read(data_to_send):
    error = 0
    data = bytes([])
    match v_cr_params.interface_typ:
        case 0 | 1:
            # RS232 USB
            error, data = serial_init(v_cr_params.serial_interface, data_to_send)
        case 2:
            # FILE
            error = file_out1(v_cr_params.interface_file_out, data_to_send)
            if error == 0:
                wait2 = 0
                while wait2 < 10:
                    if os.path.exists(v_cr_params.interface_file_in):
                        data = file_in_1(v_cr_params.interface_file_in)
                        if len(data) == 0:
                            ' wait for answer'
                            sleep(0.1)
                            wait = 0
                            while wait < 10:
                                data = file_in_1(v_cr_params.interface_file_in)
                                if len(data) > 0:
                                    wait = 10
                                else:
                                    sleep(.1)
                                    wait += 1
                        else:
                            wait2 = 10
                    else:
                        wait2 += 1
                        if wait2 == 10:
                            error = 1
                        sleep(0.1)

        case 3:
            # PIPE
            error = write_pipe(v_cr_params.interface_pipe, data_to_send)
            if error == 0:
                wait = 0
                while wait < 5:
                    data = file_in_1(v_cr_params.interface_file_in)
                    if error == 0:
                        wait = 5
                    else:
                        sleep(.1)
                        wait += 1
        case 4:
            # ethernet
            v_dev.data_to_device[v_cr_params.device] = bytes([0xFD])
            sleep(.2)
            data = v_dev.data_to_CR[v_cr_params.device]
            if len(data) == 0:
                error = 1
            else:
                error = 0
    return error, data

def create_device(device):
    v_dev.active[device] = 1
    # commandlength of commands for device
    v_dev.length_commandtoken[device] = v_cr_params.length_commandtoken
    # data to send to CR
    v_dev.data_to_CR[device] = bytearray()
    #  received  from SK
    v_dev.all_answer_toks[device] = []
    v_dev.data_to_device[device] = bytearray()
    v_dev.filename_out  [device] = ""
    v_dev.filename_in [device] = ""
    if v_cr_params.interface_typ == 2:
        v_dev.filename_out[device] = v_cr_params.interface_file_out
        v_dev.filename_in[device] = v_cr_params.interface_file_in
    v_dev.interface_comport[device] = 0
    if v_cr_params.interface_typ == 0 or v_cr_params.interface_typ == 1:
        v_dev.interface_comport [device] = v_cr_params.interface_com_port
    v_dev.serial_interface[device] = v_cr_params.serial_interface
    v_dev.interface_number_of_bits[device] = 0
    v_dev.interface_port[device] = 0
    v_dev.interface_timeout[device] = 0
    v_dev.interface_type[device] = v_cr_params.interface_typ
    v_dev.len[device] = [0,0,0,0,0,0]
    v_dev.name[device] = ""
    v_dev.start_time[device] = 0
    v_dev.a_to_o[device] = {}
    v_dev.o_to_a[device] = {}
    v_dev.all_toks_of_dev[device] = []
    v_dev.all_conditions[device] = []
    v_dev.left_toks[device] = []
    v_dev.right_toks[device] = []
    v_dev.interface_baudrate[device] = v_cr_params.interface_baudrate
    v_dev.name[device] = v_cr_params.b_name + "_" + v_dev.f255_name[device] + "_" + v_dev.f255_number[device] + " on "
    if v_dev.interface_comport != "":
        v_dev.name[device] += v_dev.interface_comport[device]
    elif v_dev.filename_out != "":
        v_dev.name[device] += v_dev.filename_out[device]
    return

def initialization():
    # device 0 is CR
    # CR
    # only basic announcement, other command are added later to the end
    v_dev.announcements[0] = {}
    v_dev.announcements[0][0] = v_configparameter.cr0_announcements[0].split(";")
    v_dev.announcments_not_stripped[0] = {}
    v_dev.announcments_not_stripped[0][0] = str(v_configparameter.cr0_announcements[0])
    v_dev.announcments_not_stripped[0][0] += v_configparameter.cr0_announcements[0]
    device = 1
    while device <= len(v_dev.anouncefile_name):
        # announcelist may be empty, if file not found
        read_announcements_of_a_device(device)
        device += 1
    create_new_announce_list()
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
    f = Path(v_dev.anouncefile_name[device])
    if f.exists():
        announce_file = open(v_dev.anouncefile_name[device])
        for linesx in announce_file:

            if linesx == "" or linesx[0] == "#" or linesx[0] == "'":
                continue
            if linesx[0:9] == "Announce:":
                continue
            linesx = linesx.split("\n")[0]
            if linesx[0:4].upper() == "DATA":
                # bascom lines
                linesx = linesx[4:]
                # skip leading spaces
                linex_len = len(linesx)
                found = 0
                i = 0
                while i < linex_len and not found:
                    if linesx[i] != " ":
                        found = 1
                    else:
                        i += 1
                linesx = linesx[i:]
                # skip "
                linesx = linesx[1:]
                # may have comments at the end
                linesx = linesx.split("'")[0]
                # drop  trailing spaces
                linex_len = len(linesx) - 1
                found = 0
                while linex_len > 0 and not found:
                    if linesx[linex_len] != " ":
                        found = 1
                    else:
                        linex_len -= 1
                linesx = linesx[0:linex_len]
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
    real_241 = misc_functions.real_tok(241, number_of_lines)
    for lines in file1:
        tok = int(lines.split(";")[0])
        if tok != real_240 and tok != real_241:
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
            v_dev.announcments_not_stripped[device][stripped[0]] = str(misc_functions.length_of_int(len(stripped)))
            v_dev.announcments_not_stripped[device][stripped[0]] += lines

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

    # other checks
    for tok in v_dev.announcements[device]:
        lines = v_dev.announcements[device][tok]
        err = check_parameters(lines)
        if err != "":
            # ignore that device
            write_log(err)
            delete_dev(device)

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


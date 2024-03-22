"""
name : init.py IC705
last edited: 20220103
"""

import os

from io_handling import *
from misc_functions import *

import v_sk
import v_icom_vars
import v_announcelist
import serial
import shutil


def initialization():
    # read config
    readconfig()
    create_announce_list()
    # read info for all devices and initialize them
    # and create announcelist
    # new_device_found = read_my_devices()
    if (os.path.isfile(v_icom_vars.control_data_out)):
        os.remove(v_icom_vars.control_data_out)
    return


def readconfig():
    if not os.path.isfile(v_icom_vars.config_file):
        shutil.copy('___config_default','___config')
    config_file = open(v_icom_vars.config_file)
    i = 0
    # sequence within file is fixed!!!
    for lines in config_file:
        if lines[0] == "#":
            continue
        lines = lines.rstrip()
        if i == 0:
            v_icom_vars.announce_list = lines
            if not os.path.isfile(v_icom_vars.announce_list):
                sys.exit("Missing:  " + v_icom_vars.announce_list)
        elif i == 1:
            # time in sec for command timeout
            v_icom_vars.command_timeout = int(lines)
        elif i == 2:
            v_icom_vars.log_file = lines.rstrip()
            # create if not exist
            open(v_icom_vars.log_file, "a").close()
        elif i == 3:
            # logfile size
            v_icom_vars.logfilesize = int(lines)
        elif i == 4:
            # test mode
            v_icom_vars.test_mode = int(lines)
        elif i == 5:
            v_icom_vars.name = lines.rstrip()
        elif i == 6:
            v_icom_vars.number = int(lines)
        elif i == 7:
            v_icom_vars.terminal_activ = int(lines)
        elif i == 8:
            v_icom_vars.telnet_active = int(lines)
        elif i == 9:
            v_icom_vars.telnet_port = int(lines)
        elif i == 10:
            v_icom_vars.comportnumber = int(lines)
            v_icom_vars.comport = "COM" + lines
        elif i == 11:
            v_icom_vars.civ_address = int(lines)
        elif i == 12:
            v_icom_vars.civ_watchdog_timeout = int(lines)
        elif i == 13:
            v_icom_vars.control_data_in = lines
        elif i == 14:
            v_icom_vars.control_data_out = lines
        elif i == 15:
            v_icom_vars.radio_version = lines
        i += 1
    config_file.close()
    return


def create_config_file(file, write_append):
    handle = open(file, write_append)
    handle.write("# sequence must not be changed !!!\n")
    handle.write("# line 0 filename for announcements\n")
    handle.write(str(v_icom_vars.announce_list) + "\n")
    handle.write("# line 1: time for command timeout (seconds)\n")
    handle.write(str(v_icom_vars.command_timeout) + "\n")
    handle.write("# line 2 filename for logfile\n")
    handle.write(str(v_icom_vars.log_file) + "\n")
    handle.write("# line 3: size of logfile; all lines are purged then\n")
    handle.write(str(v_icom_vars.logfilesize) + "\n")
    handle.write("# line 4: testmode\n")
    handle.write(str(v_icom_vars.test_mode) + "\n")
    handle.write("# line 5: Name\n")
    handle.write(v_icom_vars.device_name + "\n")
    handle.write("# line 6: Number\n")
    handle.write(str(v_icom_vars.device_number) + "\n")
    handle.write("# line 7: Terminal active\n")
    handle.write(str(v_icom_vars.terminal_activ) + "\n")
    handle.write("# line 8:Telnet active\n")
    handle.write(str(v_icom_vars.telnet_active) + "\n")
    handle.write("# line 9: Telnet Port\n")
    handle.write(str(v_icom_vars.telnet_port) + "\n")
    handle.write("# line10: Com Port number\n")
    handle.write(str(v_icom_vars.comportnumber) + "\n")
    handle.write("# line 11: CIV Adress (0x94 = 148)\n")
    handle.write(str(v_icom_vars.civ_address) + "\n")
    handle.write("# line12: CIV timeout (seconds)\n")
    handle.write(str(v_icom_vars.civ_watchdog_timeout) + "\n")
    handle.write("# line13: Data in  for control via filetransfer\n")
    handle.write(str(v_icom_vars.control_data_in) + "\n")
    handle.write("# line14: Data out  for control via filetransfer\n")
    handle.write(str(v_icom_vars.control_data_out) + "\n")
    handle.close()
    return


def initialize_inputbuffer(line):
    # initialize inputs for SK interface (Terminal and telnet
    m = create_inputbuffer(line, 1)
    if line == "TELNET":
        v_sk.socket[m] = 23
        start_ethernet_server(v_sk.socket[m], m)


def create_inputbuffer(interface_type, activ,):
    v_sk.interface_port.append(0)
    v_sk.interface_timeout.append(0)
    v_sk.interface_type.append(interface_type)
    v_sk.socket.append([])
    v_sk.ethernet_server_started.append([])
    create_sk()
    return len(v_sk.ethernet_server_started) - 1


def create_sk():
    v_sk.active.append(1)
    v_sk.inputline.append([])
    v_sk.last_command.append([])
    # v_sk.last_error.append("no error")
    v_sk.starttime.append(0)
    return


def create_announce_list():
    config_file = open(v_icom_vars.announce_list)
    i = 0
    v_announcelist.full = []
    for lines in config_file:
        if lines[0] != "D":
            continue
        lines = lines.rstrip()
        lines_ = lines.split("\"")
        lin = add_length_to_str(lines_[1], 1)
        v_announcelist.full.append(lin)
        i += 1
    v_announcelist.number_of_lines = i


def commands_at_start():
    if v_icom_vars.input_locked == 0:
        v_icom_vars.input_locked = 1
        if v_icom_vars.command_at_start == 1:
            # echo off
            v_icom_vars.Civ_out = v_icom_vars.start_echo_off
        elif v_icom_vars.command_at_start == 2:
            # transceive
            v_icom_vars.Civ_out = v_icom_vars.start_transceive
        elif v_icom_vars.command_at_start == 3:
            # LSB
            v_icom_vars.Civ_out = v_icom_vars.start_read_data_mode
        elif v_icom_vars.command_at_start == 4:
            # vfo A
            v_icom_vars.Civ_out = v_icom_vars.start_VFOA
        elif v_icom_vars.command_at_start == 5:
            # read frequency
            v_icom_vars.Civ_out = v_icom_vars.start_read_f
        elif v_icom_vars.command_at_start == 6:
            # read mode
            v_icom_vars.Civ_out = v_icom_vars.start_read_mode
        elif v_icom_vars.command_at_start == 7:
            # set memory number
            v_icom_vars.Civ_out = v_icom_vars.start_memory_no
        elif v_icom_vars.command_at_start == 8:
            # memory write
            v_icom_vars.Civ_out = v_icom_vars.start_memory_write
        elif v_icom_vars.command_at_start == 9:
            v_icom_vars.command_at_start = 0
            v_sk.info_to_telnet = bytearray([])
            v_sk.info_to_all = bytearray([])
            # start sk not earlier
            initialize_inputbuffer("TERMINAL")
            initialize_inputbuffer("TELNET")
            initialize_inputbuffer("FILE")
            if v_icom_vars.test_mode == 1:
                print("installation ready")
        if v_icom_vars.command_at_start != 0:
            v_icom_vars.command_at_start += 1
        else:
            v_icom_vars.input_locked = 0
    return

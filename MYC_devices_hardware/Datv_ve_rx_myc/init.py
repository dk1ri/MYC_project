"""
name : init.py Datv_ve_rx_myc
last edited: 20241226
"""
import v_fix_tables
from io_handling import *
from misc_functions import *

import v_sk
import v_dev_vars
import v_announcelist
import shutil
import platform


def initialization():
    # read config
    readconfig()
    v_fix_tables.add_fixed_drift()
    v_fix_tables.add_fixed_fastlock()
    v_fix_tables.add_fixed_fec()
    v_fix_tables.add_fixed_gain()
    v_fix_tables.add_fixed_gui()
    v_fix_tables.add_fixed_player()
    v_fix_tables.add_fixed_record_iq()
    v_fix_tables.add_fixed_record_t()
    v_fix_tables.add_fixed_standard()
    v_fix_tables.add_fixed_sampler()
    v_fix_tables.add_fixed_samplerate()
    v_fix_tables.add_fixed_symbolrate()
    v_fix_tables.add_fixed_viterbi()
    create_announce_list()

    if os.path.isfile(v_dev_vars.control_data_out):
        os.remove(v_dev_vars.control_data_out)

    # default chanal: QO100 beacon
    read_chanel(9)
    read_indiv_data()
    v_sk.info_to_telnet = bytearray([])
    v_sk.info_to_all = bytearray([])
    # start sk not earlier
    initialize_inputbuffer("TELNET")
    initialize_inputbuffer("FILE")
    if v_dev_vars.test_mode == 1:
        print("installation ready")
    return


def readconfig():
    platf =platform.platform()[0:7]
    if (platf == "Windows"):
        platf = "/xampp/htdocs/usb_interface/"
    else:
        platf = "/var/www/html/usb_interface/"
    if not os.path.isfile(v_dev_vars.config_file):
        shutil.copy('___config_default','___config')
    config_file = open(v_dev_vars.config_file)
    i = 0
    # sequence within file is fixed!!!
    for lines in config_file:
        if lines[0] == "#":
            continue
        lines = lines.rstrip()
        if i == 0:
            v_dev_vars.announce_list = lines
            if not os.path.isfile(v_dev_vars.announce_list):
                sys.exit("Missing:  " + v_dev_vars.announce_list)
        elif i == 1:
            # time in sec for command timeout
            v_dev_vars.command_timeout = int(lines)
        elif i == 2:
            v_dev_vars.log_file = lines.rstrip()
            # create if not exist
            open(v_dev_vars.log_file, "a").close()
        elif i == 3:
            # logfile size
            v_dev_vars.logfilesize = int(lines)
        elif i == 4:
            # test mode
            v_dev_vars.test_mode = int(lines)
        elif i == 5:
            v_dev_vars.file_active = int(lines)
        elif i == 6:
            v_dev_vars.telnet_active = int(lines)
        elif i == 7:
            v_dev_vars.telnet_port = int(lines)
        elif i == 8:
            v_dev_vars.control_data_in =  platf + lines
        elif i == 9:
            v_dev_vars.control_data_out = platf + lines
        elif i == 10:
            v_dev_vars.indiv_data_file = lines
        i += 1
    config_file.close()
    return


def initialize_inputbuffer(line):
    # initialize inputs for SK interface (file and telnet
    m = create_inputbuffer(line)
    if line == "TELNET":
        v_sk.socket[m] = 23
        start_ethernet_server(v_sk.socket[m], m)
    return

def create_inputbuffer(interface_type):
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
    announce_file = open(v_dev_vars.announce_list)
    i = 0
    v_announcelist.full = []
    for lines in announce_file:
        if lines[0] != "D":
            continue
        lines = lines.rstrip()
        lines_ = lines.split("\"")
        lin = chr(len(lines_[1])) + lines_[1]
      #  lin = add_length_to_str(lines_[1], 1)
        v_announcelist.full.append(lin)
        i += 1
    v_announcelist.number_of_lines = i


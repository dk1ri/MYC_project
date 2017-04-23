"""
name : commandrouter.py
Version 02.4, 20170423
Purpose : Programm for a MYC commandrouter
The Programm supports the MYC protocol
tested with win Python 2017.1
Should be used with raspberry Pi Hardware (not yet tested)
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
The programm is not ready, see description
The code is due to enhancements
"""

# general
# import sys, os.path, time, socket, shutil, os, msvcr, threading
# from copy import deepcopy
# for i2c
# sudo apt-get install python-smbu
# import smbus

# own subs
from create_new_announce_list import *
from init import *
from tests import *
from tests2 import *


# import variables for global use
# simple variables
import v_time_values

# simple lists
import v_device_names_and_indiv
import v_configparameter

# variables per device
import v_dev

# variables per input
import v_sk


def dummy_sub():
    return


def initialization():
    # read config and initialize parameter array (for commands an devices)
    readconfig(sys.argv)
    # read info for all devices and initialize them
    # and create announcelist
    new_device_found = read_my_devices()
    if new_device_found == 1:
        create_new_announce_list()
    v_device_names_and_indiv.last = v_device_names_and_indiv.activ
    # not ready:
    check_activity_of_devices()
    v_time_values.last_activity = time.time()
    v_time_values.time_for_activ_check = time.time()
    v_time_values.last_checktime = time.time()
    return


def time_dependent_tasks():
    # check existance of devices
    if time.time() - v_time_values.time_for_activ_check > v_configparameter.time_for_activ_check:
        check_activity_of_devices()
        v_time_values.time_for_activ_check = time.time()
    # check for new / deleted devices
    if time.time() - v_time_values.time_for_device_search > v_configparameter.time_for_device_search:
        read_my_devices()
        write_log("re_read  my devices")
        v_time_values.time_for_device_search = time.time()
    if time.time() - v_time_values.time_for_logfile_check > v_configparameter.time_for_logfile_check:
        check_logfile()
        write_log("check_log")
        v_time_values.time_for_logfile_check = time.time()
    # check for timeout of SK...,
    input_device = 0
    while input_device < len(v_sk.starttime):
        # user timeout
        j = 0
        while j < 256:
            # commandtimeout for each user
            if v_sk.starttime[input_device][j] > 0:
                if time.time() - v_sk.starttime[input_device][j] > v_configparameter.time_for_command_timeout:
                    write_log("SK timeout  " + str(input_device))
                    # error: purge complete line
                    finish_sk_error(input_device, 0)
            if v_sk.user_timeout[input_device][j] > 0:
                if time.time() - v_sk.user_timeout[input_device][j] > v_configparameter.user_timeout:
                    write_log("user timeout" + str(j))
                    v_sk.user_timeout[input_device][j] = 0
                    v_sk.user_answer_token[input_device][j] = bytearray([42])
                    v_sk.user_active[input_device][j] = 0
            j += 1

        input_device += 1
    device = 0
    while device < len(v_dev.start_time):
        if v_dev.start_time[device] != 0:
            if time.time() - v_dev.start_time[device] > v_configparameter.time_for_command_timeout:
                write_log("dev timeout: " + str(device))
                # purge complete line
                clear_dev(device, v_dev.linelength_len[device], 1, 0)
        device += 1
    # (re-)start sending input from file
    if v_time_values.auto == 1 and time.time() - v_time_values.last_checktime > v_configparameter.time_for_command_timeout + v_time_values.checktime:
        v_time_values.part = 1
    if v_time_values.auto == 10 and time.time() - v_time_values.random_time > 0.2:
        random_data()
    return


def check_activity_of_devices():
    v_device_names_and_indiv.active = []
    for devices in v_device_names_and_indiv.name:
        # check of devices missing
        dummy_sub()
        # for testphase only!!!!!!!!!!!!!!!!!!!!:
    v_device_names_and_indiv.active = v_device_names_and_indiv.last

    notfound = 0
    # list may have different sequence
    for line in v_device_names_and_indiv.activ:
        if line in v_device_names_and_indiv.last:
            continue
        # one element not foun
        notfound = 1
    if notfound == 0:
        for line in v_device_names_and_indiv.last:
            if line in v_device_names_and_indiv.activ:
                continue
            notfound = 1
    if notfound == 1:
        create_new_announce_list()
        v_device_names_and_indiv.last = list(v_device_names_and_indiv.activ)
        write_log("new announcelist")
        # send info for new list to all
        # missing
    return


def check_logfile():
    # limit logfile
    i = 0
    file = open(v_configparameter.logfile)
    for line in file:
        i += 1
    file.close()
    if i > v_configparameter.max_log_lines:
        os.remove(v_configparameter.logfile)
    return


# Main#i
v_time_values.last_activity = int(time.time())
v_time_values.last_device_search = int(time.time())
start_time = time.time()
initialization()
print_for_test()
# wait 2 seconds for system reset of other devices
print("wait")
while (time.time() - start_time) * 1000 < v_configparameter.system_timeout:
    pass
print("ready")
# 5000 loops / s on coreI7
while 1:
    time_dependent_tasks()
    if v_time_values.auto == 1:
        if v_time_values.part > 0:
            handle_check()
    else:
        poll_inputs()
        # analyzes the input_buffer :
        poll_input_buffer()
        # send commands to LD:
        send_to_ld()
        # analyzes data from LD
        poll_ld()
        # send commands to devices:
        send_buffer_to_device()
        # get answers and info from normal device and lower level CR:
        poll_devices()
        # analyzes the answers and info from devices:
        poll_device_buffer()
        # info to all SK
        # send to individual SK not yet implemented
        send_to_all()

"""
name : commandrouter.py
Version 03.02 , 20260414
Purpose : Program for a MYC commandrouter
The Programm supports the MYC protocol
developed using PyCharm
tested with win Python >= 312
Tested with Win11
Should be used with raspberry Pi Hardware (actual version not tested)
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""

from buffer_handling import *
from device_handling import *
from init import *
from ld_buffer_handling import *
from tests import *

import v_time_values
import v_dev

def time_dependent_tasks():
    # check existance of devices
    # if time.time() - v_time_values.time_for_activ_check > v_configparameter.time_for_activ_check:
    # check_activity_of_devices()
    # v_time_values.time_for_activ_check = time.time()
    # check for new / deleted devices
    # if time.time() - v_time_values.time_for_device_search > v_configparameter.time_for_device_search:
    # read_devices()
    # write_log("re_read  my devices")
    # v_time_values.time_for_device_search = time.time()

    # check for timeout of SK...,
    input_device = 0
    while input_device < len(v_sk.starttime):
        # channel timeout
        if v_sk.starttime[input_device] > 0:
            if time.time() - v_sk.starttime[input_device] > v_configparameter.time_for_command_timeout:
                write_log("SK timeout  " + str(input_device)+str(time.time() - v_sk.starttime[input_device])+ " "+str(v_configparameter.time_for_command_timeout) )
                # error: purge complete line
                clear_sk(input_device)
        if v_sk.channel_timeout[input_device] > 0:
            if time.time() - v_sk.channel_timeout[input_device] > v_configparameter.channel_timeout:
                write_log("channel timeout")
                v_sk.channel_timeout[input_device] = 0
                # delete interface: missing

        input_device += 1
    device = 1
    while device < len(v_dev.start_time):
        if v_dev.start_time[device] != 0:
            if time.time() - v_dev.start_time[device] > v_configparameter.time_for_command_timeout:
                write_log("dev timeout: " + str(device))
                # purge complete line
                clear_dev(device)
        device += 1
    return

# Main
init_start_time = time.time()
readconfig()
read_device_interface_list()
if v_configparameter.test_mode == 0:
    # search devices not tested
    v_dev.init_ready  = 0
    v_dev.init_sequence = 0
    v_dev.init_device = 0
    init_start = time.time()
    while v_dev.init_ready  == 0:
        if time.time() - init_start_time > 1:
            v_dev.init_sequence = 5
            start_time = time.time()
        read_interfaces_anouncefilenames()
        poll_devices()
        # analyzes the answers and info from devices:
        poll_device_buffer()
else:
    # device0 is CR!!
    v_dev.active[0] = 1
    v_dev.anouncefile_name[1] = "DK1RI_test1_V01.0_D1_1.bas"
    v_dev.active[1] = 1
    v_dev.anouncefile_name[2] = "DK1RI_test2_V01.0_D1_1.bas"
    v_dev.active[2]= 1
initialization()
print_for_test()
if v_configparameter.test_mode == 1:
    write_log("started")
"""
loops = 0
all_time = 0
last_time = time.time()
display_loops = 0
"""
while 1:
    """
    # measure loop time
    # 20260217: 65us idle
    if loops < 1000:
        act_time = time.time()
        all_time += act_time - last_time
        loops += 1
    else:
        act_time = time.time()
        act_loop_time = act_time - last_time
        last_time = act_time
        all_time = all_time - all_time / 1000 + act_loop_time
        display_loops += 1
        if display_loops >= 10000:
            print(all_time / 1000)
            print(act_loop_time)
            display_loops = 0
    """
    time_dependent_tasks()
    # collect data from (SK )inputs:
    poll_sk()
    # analyzes the sk input_buffer
    # send commands to LD if applicable per inputdevice
    # check for rules (ld_analyze)
    poll_input_buffer()
    # send commands to devices:
    send_to_device()
    # get answers and info from normal device and lower level CR:
    poll_devices()
    # analyzes the answers and info from devices:
    poll_device_buffer()
    # info to all SK
    # send to individual SK not yet implemented
    send_to_sk()
    # send direct commands to dev, if available
    send_direct_commands()

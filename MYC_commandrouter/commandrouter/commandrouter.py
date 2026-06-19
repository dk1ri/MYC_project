"""
name : commandrouter.py
Version V03.02 , 20260530
Purpose : Program for a MYC commandrouter
The Programm supports the MYC protocol
developed using PyCharm
tested with win Python >= 312
Tested with Win11
Should be used with raspberry Pi Hardware (actual version not tested)
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""
import v_cr_params
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
print ("Please wait...")
v_cr_params.init_ready = 0
init_start_time = time.time()
# reads config file
readconfig()
# read CR line and create SK interfaces
read_cr_line()
print ("search for devices")
# create device interfaces
create_devices()

# read list of given devices
read_device_interface_list()
if len(v_dev.anouncefile_name) == 0:
    sys.exit("no devices found")

initialization()
print_for_test()
if v_configparameter.test_mode == 1:
    write_log("started")
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
    # collect data from (SK )inputsnad aalyze data (analyze_sk_input)
    # send commands to LD if applicable per inputdevice
    # check for rules (ld_analyze)
    poll_sk()
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

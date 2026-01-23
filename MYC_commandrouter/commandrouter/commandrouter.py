"""
name : commandrouter.py
Version 03.01 , 20251215
Purpose : Program for a MYC commandrouter
The Programm supports the MYC protocol
developed using PyCharm
tested with win Python >= 312
Should be used with raspberry Pi Hardware
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
The programm is not ready, see documentation
"""
from init import *
from tests import *
from tests2 import *
import device_handling

import v_time_values

import v_dev

from ld_init import  *
from ld_buffer_handling import  *

def time_dependent_tasks():
    # check existance of devices
 #   if time.time() - v_time_values.time_for_activ_check > v_configparameter.time_for_activ_check:
  #      check_activity_of_devices()
   #     v_time_values.time_for_activ_check = time.time()
    # check for new / deleted devices
  #  if time.time() - v_time_values.time_for_device_search > v_configparameter.time_for_device_search:
   #     read_devices()
    #    write_log("re_read  my devices")
     #   v_time_values.time_for_device_search = time.time()


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
    device = 0
    while device < len(v_dev.start_time):
        if v_dev.start_time[device] != 0:
            if time.time() - v_dev.start_time[device] > v_configparameter.time_for_command_timeout:
                write_log("dev timeout: " + str(device))
                # purge complete line
                device_handling.clear_dev(device)
        device += 1
    # (re-)start sending input from file
    #  slow
  #  if v_time_values.auto == 10 and time.time() - v_time_values.random_time > 0.1:
    if v_time_values.auto == 10 :
        # no delay
        random_data()
    return


# Main#
start_time = time.time()
initialization()
ld_initialization()
print_for_test()
print("ready")
while 1:
    time_dependent_tasks()
    if v_time_values.auto == 1:
        handle_check()
    else:
        # collect data from (SK )inputs:
        poll_sk()

        # analyzes the sk input_buffer
        # send commands to LD
        # data in v_ld.data_to_ld
        poll_input_buffer()
        # LD checks for rules:
        ld_analyze()

        # analyzes data from LD:
        poll_ld()

        # send commands to devices:
        send_to_device()
        # get answers and info from normal device and lower level CR:
        poll_devices()
        # analyzes the answers and info from devices:
        device_handling.poll_device_buffer()
        # info to all SK
        # send to individual SK not yet implemented
        send_to_sk()

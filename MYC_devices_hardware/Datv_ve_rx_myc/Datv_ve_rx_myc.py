"""
name :Datv_ve_rx_myc.py
Version 01.1, 20250331
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)
Purpose : Program to control the  DATV Rx Datv_ve_rx (Raspberry with RTL SDR stick)
The program supports the MYC protocol
Details of the MYC protocol can be found in http://dk1ri.de/myc/Description.pdf
developed using PyCharm
tested with webbrowser under Win11

Some explanation:
Some configuration must be set in __config

testmode can be set in v_dev_vars.test_mode.
0: normal operation.
1: print control commands only
2: print control commands and execute them
For testmode 1 or 2 this program should be called by python Datv_ve_rx_myc.py
The program should be killed before (or commented in the start script /home/pi/ve-rx.sh)

"""

from io_handling import *
from analyze import poll_sk_input_buffer
from init import initialization
import v_dev_vars
import v_sk
import time
import os

# Main
initialization()
#string = "rtl_sdr -f 741e6 -g 0 -s 2.4e6 - | ./leandvb --gui -f 2.4e6 --sr 1.5e6 --cr 2/3 --standard DVB-S2 --sampler rrc --rrc-rej 30 --drift --fastlock --viterbi | ffplay -x 512 -y 300 -"
#os.popen(string)

while 1:
    # read SK
    poll_inputs()
    # analyzes the input_buffers:
    poll_sk_input_buffer()

    if v_sk.info_to_all != bytearray([]):
        # send result
        send_to_all()
    time.sleep(0.01)
    if v_dev_vars.command_started == 1:
        if time.time() - v_dev_vars.command_start_time > v_dev_vars.command_timeout:
            delete_buffers()
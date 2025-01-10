"""
name :Datv_ve_rx_myc.py
Version 01.0, 20250110
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)
Purpose : Program to control the  DTAV Rx Datc_ve_rx /RAspberry with RTL SDR stick)
The program supports the MYC protocol
Details of the MYC protocol can be found in http://dk1ri.de/myc/Description.pdf
developed using PyCharm
tested with webbrowser under Win11

Some explanation:
Some configuration must be set in __config

testmode can be set in v_dev_vars.test_mode. Should be set to 1 for manual command entry.

"""

from io_handling import *
from analyze import poll_sk_input_buffer
from init import initialization
import v_dev_vars
import v_sk

# Main
initialization()

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
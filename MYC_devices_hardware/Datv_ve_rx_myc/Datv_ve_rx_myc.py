"""
name : .py
name : v_dev_vars.py
Version 01.0, 20241226
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)
Purpose : Program to control the  DTAV Rx Datc_ve_rx /RAspberry with RTL SDR stick)
The program supports the MYC protocol
Details of the MYC protocol can be found in http://dk1ri.de/myc/Description.pdf
developed using PyCharm
tested with webbrowser under Win11

Some explanation:
Some configuration must be set in __config

Most commands work this way:
command is received by SK -> execute (send to civ buffer (overwrite)) ->, delete SK input, lock SK input
 -> civ buffer to civ, unlock SK input
in case of answers: civ answers are analyzed and sent to all (overwrite), civ data deleted
(some CIV commands result in more than one answer )
Some operate commands require the actual status of this or other functions (an answer command) first.
This is described with the v_dev_vars.ask_content variable.

Sending more than one command without delay is working

testmode can be set in v_dev_vars.test_mode. Should be set to 1 for manual command entry.

"""

from io_handling import *
from analyze import poll_sk_input_buffer
from init import initialization
import v_dev_vars

# Main
initialization()
v_dev_vars.command_at_start = 1
while 1:
    # read SK
    poll_inputs()
    # analyzes the input_buffers:
    poll_sk_input_buffer()

    if v_sk.info_to_all != bytearray([]):
        # send result
        send_to_all()
    time.sleep(0.01)
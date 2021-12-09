"""
name : Ic705_interface.py
Version 01.5, 20211209
Purpose : Program to control the IC-705 radio
The program supports the MYC protocol
Details of the MYC protocol can be found in http://dk1ri.de/myc/Description.pdf
developed using PyCharm
tested with win Python >= 3.9 under Win10
Manual A7560-8EX-1 Jul 2020 and A7577-10G-EN-1
tested with radio firmware 1.26
Should be used with raspberry Pi Hardware (later)
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)

Some explanation:
Some configuration must be set in __config as USB Port

At start the interface do not modify the radio except setting
civ echo = 0
transceive = 1
memory = 0
Vfo: vfoa
mode: USB
So it is up to the SK to read the start configuration of the radio
The radio do not send configuration changes except mode and frequency, if it is operated manually;
so manual modifying is not recommended during operating this program.

Most commands work this way:
command is received by SK -> execute (send to civ buffer (overwrite)) ->, delete SK input, lock SK input
 -> civ buffer to civ, unlock SK input
in case of answers: civ answers analyzed and sent to all (overwrite), civ data deleted
Some operate commands require an annswer command first. This is described with the v_icomvars.ask_content variable.

Some operate commands require the actual status of this or other functions to work.
For details see v_icom_vars.ask_content variable

Sending more than 0ne command without delay is working

testmode can be set in v_icom_vars.test_mode. Should be set to 1 for manual command entry.

Command 271e (fixed scope bandedge) is omitted, because function is identcal to 1a02xx

Missing, (things to do):

1a00 raw only
dstar and gps not 100% tested
command 20xx and 22xx not 100% tested
rules missing
"""
# general
import os, platform
if platform.system() == "Windows":
    import msvcrt
    Unix_windows = 1
else:
    import sys, tty, termios
import serial
# import usb.core
# import usb.util
# own subs
from io_handling import *
from analyze import poll_civ_input_buffer, poll_sk_input_buffer
from misc_functions import write_log
from init import initialization, commands_at_start
import v_icom_vars
# for i2c
# sudo apt-get install python-smbu
# if Unix_windows == 0:
#    import smbus


# Main
initialization()
try:
    v_icom_vars.icom_usb = serial.Serial(v_icom_vars.comport, 19200, timeout=1, parity=serial.PARITY_NONE,
                             bytesize=serial.EIGHTBITS, stopbits=serial.STOPBITS_ONE, rtscts=0)
except serial.serialutil.SerialException:
    write_log("com port " + v_icom_vars.comport + " not found")
    # USB is is locked untile fffe05 is called
    v_icom_vars.check_usb_again = 0


while 1:
    # watchdog:
    if (v_icom_vars.command_time != 0) and ((time.time() - v_icom_vars.command_time) > v_icom_vars.command_timeout):
        # command timeout
        v_sk.inputline[0] = bytearray([])
        v_sk.inputline[1] = bytearray([])
        v_sk.hex_count = 0
        write_log("input command timeout")
        v_icom_vars.command_time = 0
        v_icom_vars.input_locked = 0
    if v_icom_vars.civ_watchdog_time != 0 and time.time() - v_icom_vars.civ_watchdog_time > v_icom_vars.command_timeout:
        write_log("radio not responding")
        v_icom_vars.civ_watchdog_time = 0
        v_icom_vars.input_locked = 0

    if v_icom_vars.check_usb_again == 1:
        if v_icom_vars.command_at_start > 0:
            # command at_start
            commands_at_start()

    # read SK
    if v_icom_vars.input_locked == 0:
        # poll_inputs()
        win_terminal(0, 0)
        # analyzes the input_buffers:
        poll_sk_input_buffer()

    if v_icom_vars.check_usb_again == 1:
        # only, if USB is valid
        # send any civ, if not empty
        if v_icom_vars.Civ_out != bytearray([]) or v_icom_vars.Civ_out != bytearray(b''):
            if v_icom_vars.test_mode == 1:
                print("civout", v_icom_vars.Civ_out)
            v_icom_vars.civ_watchdog_time = time.time()
            try:
                v_icom_vars.icom_usb.write(v_icom_vars.Civ_out)
            except NameError:
                write_log("com port " + v_icom_vars.comport + " not found")
                v_icom_vars.check_usb_again = 0
            v_icom_vars.Civ_out = bytearray([])
            # lock input during civ handling
            v_icom_vars.input_locked = 1

        # read icom port
        try:
            b = v_icom_vars.icom_usb.in_waiting
            if b > 0:
                a = v_icom_vars.icom_usb.read(b)
                temp1 = 0
                while temp1 < len(a):
                    v_icom_vars.Civ_in.extend(bytearray([int(a[temp1])]))
                    temp1 += 1
                if v_icom_vars.test_mode == 1:
                    print("civin ", v_icom_vars.Civ_in)
        except NameError:
            write_log("com port " + v_icom_vars.comport + " not found")
            v_icom_vars.check_usb_again = 0

        # analyze CIV data
        poll_civ_input_buffer()

    # send result
    send_to_all()

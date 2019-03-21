"""
name : Ic7200_interface.py
Version 0.0.1 , 20190312
Purpose : Programm to control the IC7300 radio
The Programm supports the MYC protocol
developed using PyCharm
tested with win Python >= 3.6
Should be used with raspberry Pi Hardware
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)

Some explanation:
Most commands work this way:
command is received -> send to civ buffer (overwritten), input deleted -> civ buffer to civ
in case of answer commands: civ answers sent to all (overwrite), civ data deleted

Some operate commands require the actual status of this or other functions to work. These commands will set
ask_content != 0
command is received -> send ask command to civ buffer (overwritten), ask_content = 1, input not deleted  -> civ buffer to civ
-> civ answer analyzed, data stored,  ask_content = 2 -> original civ command updated with new data send to civ buffer (overwritten), input deleted
-> civ buffer to civ -> answer should be "ok"
"""

# general
import os, platform
if platform.system() == "Windows":
    import msvcrt
    getch = msvcrt.getch()
    Unix_windows = 1
else:
    import sys, tty, termios

# own subs
from init import initialization
from io_handling import *
from analyze import poll_civ_input_buffer, poll_sk_input_buffer
from commands import command_initial_data
from misc_functions import write_log
import v_Ic7300_vars
import serial

# for i2c
# sudo apt-get install python-smbu
#if Unix_windows == 0:
#    import smbus

def wait_for_answer():
    got_aswer = 0
    while got_aswer == 0:
        b = ser.in_waiting
        if b > 0:
            a = ser.read(b)
            got_aswer = 1
        # not more than 2 secocond
        if time.time() - starttime > 2:
            sys.exit("radio not respanding")
    return

# Main
initialization()
try:
    ser = serial.Serial(v_Ic7300_vars.comport, 19200, timeout=0,parity=serial.PARITY_NONE, bytesize=serial.EIGHTBITS, stopbits=serial.STOPBITS_ONE, rtscts=1)
except serial.serialutil.SerialException:
    sys.exit("No Com Port found")
starttime = time.time()
# set echo off
ser.write(bytearray([0xfe, 0xfe, v_Ic7300_vars.civ_address, 0xe0, 0x1a, 0x05, 0x00, 0x75, 0x00, 0xfd]))
wait_for_answer()
# set vfo mode
ser.write(bytearray([0xfe, 0xfe, v_Ic7300_vars.civ_address, 0xe0, 0x07, 0xfd]))
wait_for_answer()

print("ready")

while 1:
    # watchdog:
    if (v_Ic7300_vars.command_time != 0) and ((time.time() - v_Ic7300_vars.command_time) > v_Ic7300_vars.command_timeout):
        # command timeout
        v_sk.inputline[0] = bytearray([])
        v_sk.inputline[1] = bytearray([])
        v_sk.hex_count = 0
        write_log("input command timeout")
        v_Ic7300_vars.command_time = 0
        v_Ic7300_vars.input_locked = 0
    if v_Ic7300_vars.civ_watchdog_time != 0 and time.time() - v_Ic7300_vars.civ_watchdog_time > v_Ic7300_vars.command_timeout:
        write_log("radio not responding")
        v_Ic7300_vars.civ_watchdog_time = 0
        v_Ic7300_vars.input_locked = 0
    if v_Ic7300_vars.init_content > 0:
        # at start only: read and initialize some data of radio
        finish = command_initial_data()

    if v_Ic7300_vars.input_locked == 0:
        # poll_inputs()
        win_terminal(0, 0)
        # analyzes the input_buffers:
        poll_sk_input_buffer()

    # send any civ, if not empty
    if v_Ic7300_vars.Civ_out != bytearray([]) or v_Ic7300_vars.Civ_out != bytearray(b''):
        print("civout" ,v_Ic7300_vars.Civ_out)
        v_Ic7300_vars.civ_watchdog_time = time.time()
        ser.write(v_Ic7300_vars.Civ_out)
        v_Ic7300_vars.Civ_out = bytearray([])
        # lock inpit during civ handling
        v_Ic7300_vars.input_locked = 1

    b = ser.in_waiting
    if b > 0:
        a = ser.read(b)
        temp1 = 0
        while temp1 < len(a):
            v_Ic7300_vars.Civ_in.extend(bytearray([int(a[temp1])]))
            temp1 += 1
        print("civin ", v_Ic7300_vars.Civ_in)
    # analyze CIV data
    poll_civ_input_buffer()

    # send result
    send_to_all()
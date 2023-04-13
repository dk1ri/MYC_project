"""
name : serial.py
Author: DK1RI
Version 01.0, 20230406
call with: serial.py <comport>
Purpose :
interface between webserver and USB devices
"""
# general
import os
import sys
import time
import serial

def ser_read(ser):
    # Pause the program for 1 second to avoid overworking the serial port
    while 1:
        x = ser.read(100)
        return x


def ser_write(ser, da):
    ser.write(da)


if len(sys.argv) != 1:
    comport = sys.argv[1]
else:
    sys.exit("call with: serial.py <COMx>")
#
dir = "/xampp/htdocs/usb_interface"
if  not os.path.exists(dir):
    os.mkdir(dir)
#print (serial.version)
ser = serial.Serial(comport, 19200, timeout=0.5)
to_web = dir + "/to_web"
from_web = dir + "/from_web"
while 1:
    if os.path.exists(from_web):
        f = open(from_web)
        dat = f.readline()
        f.close()
        if len(dat) != 0:
            print ("received: " + dat)
            ser_write(ser, bytes.fromhex(dat))

            in_dat = ser_read(ser)
            if len(in_dat) != 0:
                if os.path.exists(to_web):
                    os.remove(to_web)
                f = open(to_web, "a")
                send = in_dat.hex()
                f.write(send)
                f.close()
                print ("sent: ")
                print(send)
        os.remove(from_web)
    time.sleep(1)
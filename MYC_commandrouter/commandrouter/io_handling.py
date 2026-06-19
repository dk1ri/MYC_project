"""
name : io_handlings.py
last edited: 20260414
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""
# all data should use binary data
# exception: terminal input and file (use 2 hex characters for each byte of bytearray)
# all sk input (ethernet, terminal, serial, FILE): result to v_sk.inputline[input_buffer_number] (add data)
# all sk output (ethernet, terminal, serial, FILE): data from v_sk.info_to_all; data are not deleted
# all dev input (ethernet, serial, FILE): result to v_dev.data_to_CR[device] (add data)
# all dev output (ethernet, serial, FILE): data from v_dev.data_to_device[device]; data are deleted

import socket
import threading
import platform
import time

import serial
import os
# from pywinpipe import Write2Pipe, ReadFromPipe
from misc_functions import *
import v_configparameter
import v_dev
import v_sk
import  v_io
import v_cr_params

if platform.system() == "Windows":
    import msvcrt
    getch = msvcrt.getch()
    Unix_windows = 1
else:
    Unix_windows = 0
    import sys, termios

    fd = sys.stdin.fileno()
    # get the current settings se we can modify them
    newattr = termios.tcgetattr(fd)
    newattr[3] = newattr[3] & ~termios.ICANON
    newattr[3] = newattr[3] & ~termios.ECHO
    termios.tcsetattr(fd, termios.TCSANOW, newattr)

    # set the terminal to uncanonical mode and turn off
    # input echo.
    newattr[3] &= ~termios.ICANON & ~termios.ECHO

    import select


def kbhitu():
    dr, dw, de = select.select([sys.stdin], [], [], 0)
    return dr != []

def getchu():
    return sys.stdin.read(1)

# Ethernet client Part, connecting to HI, PR...
def start_ethernet_client(host, port, input_buffer_number):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_thread = ClientThread(client_socket, host, port, input_buffer_number)
    client_thread.start()
    return

class ClientThread (threading.Thread):
    def __init__(self, client_socket, host, port, input_buffer_number):
        threading.Thread.__init__(self)
        self.client_socket = client_socket
        self.host = host
        self.port = port
        self.input_buffer_number = input_buffer_number

    def run(self):
        try:
            self.client_socket.connect((self.host, self.port))
        except socket.error:
            # to be replaced by entry to log
            self.client_socket.close()
            exit()
        client_read = ClientThreadRead(self.client_socket, self.input_buffer_number)
        client_read.start()
        client_write = ClientThreadWrite(self.client_socket, self.input_buffer_number)
        client_write.start()
        while 1:
            pass
        self.client_socket.close()

class ClientThreadRead (threading.Thread):
    # ethernet client part, connecting to devices
    def __init__(self, client_socket, input_buffer_number):
        threading.Thread.__init__(self)
        self.client_socket = client_socket
        self.input_buffer_number = input_buffer_number

    def run(self):
        while 1:
            data_in = self.client_socket.recv(1024)
            i = 0
            while i < len(data_in):
                v_sk.inputline[self.input_buffer_number].append(data_in[i])
                i += 1
        self.client_socket.close()


class ClientThreadWrite (threading.Thread):
    def __init__(self, client_socket, input_buffer_number):
        threading.Thread.__init__(self)
        self.client_socket = client_socket
        self.input_buffer_number = input_buffer_number

    def run(self):
        while True:
            if len((v_dev.data_to_device[self.input_buffer_number])) > 0:
                i = 0
                out = bytearray([])
                while i < (v_sk.info_to_all):
                    out += v_sk.info_to_all[i]
                self.client_socket.sendall(out)
        self.client_socket.close()
        return

# Ethernet server Part, connecting to devices
def start_ethernet_server(port, device):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    error = 0
    try:
        server_socket.bind(("", port))
    except socket.error:
        error = 1
        misc_functions.write_log("server socket failed")
    if error == 0:
        server_socket.listen(10)
        ethernet = ServerThread(server_socket, device)
        ethernet.start()
        misc_functions.write_log("Server started")
    return error

class ServerThread (threading.Thread):
    # ethernet server Part, connecting to HI, PR...
    def __init__(self, server_socket, device):
        threading.Thread.__init__(self)
        self.server_socket = server_socket
        self.device = device

    def run(self):
        while 1:
            connection, addr = self.server_socket.accept()
            misc_functions.write_log("connected to: " + str(addr))
            server_read = ServerThreadRead(connection, self.device)
            server_read.start()
            misc_functions.write_log("server read start")
            server_write = ServerThreadWrite(connection, self.device)
            server_write.start()
            misc_functions.write_log("server write start")

class ServerThreadRead (threading.Thread):
    def __init__(self, connection, device):
        threading.Thread.__init__(self)
        self.connection = connection
        self.device = device

    def run(self):
        while True:
            try:
                data_in = self.connection.recv(1024)
                if len(data_in) == 0:
                    continue
                v_sk.inputline_active[self.device] = 1
                # lock
#               i = 0
#                while i < len(data_in):
                v_dev.data_to_CR[self.device].extend(data_in)
#                    i += 1
                misc_functions.write_log("Input read: " + str(v_sk.inputline[self.device]) + "end")
            except (ConnectionAbortedError, OSError):
                misc_functions.write_log(" input read aborted")
                self.connection.close()
                exit()
        return


class ServerThreadWrite (threading.Thread):
    def __init__(self, connection, device):
        threading.Thread.__init__(self)
        self.connection = connection
        self.device = device

    def run(self):
        while True:
            if v_dev.data_to_device[self.device] != bytearray([]):
                i = 0
                stri = ""
                while i < len(v_dev.data_to_device[self.device]):
                    stri += chr(v_dev.data_to_device)[i]
                    i += 1
                try:
                    self.connection.sendall(stri)
                    v_dev.data_to_device[self.device] = bytearray([])
                except (ConnectionAbortedError, OSError):
                    misc_functions.write_log("telnet server send aborted")
                    self.connection.close()
                    exit()
        self.connection.close()

# Terminal (SK only):
def sk_terminal_in(input_buffer_number):
    t = None
    if Unix_windows == 0:
        if kbhitu():
            t = getchu()
    else:
        if msvcrt.kbhit():
            t = msvcrt.getwch()

    if t != None:
        try:
            #  must be HEX
            result = int(t, 16)
        except:
            return
        v_io.data += t
        if len(v_io.data) >= 2:
            r = int(v_io.data, 16)
            v_sk.inputline[input_buffer_number].append(r)
            v_io.data = ""
    return

def sk_terminal_out():
    print("info to all SK: " , v_sk.info_to_all)
    return

# serial:
def sk_serial_in(serial_in, input_buffer_number):
    data = ""
    if serial_in.in_waiting > 0:
        data = serial_in.read(10)
    if len(data) > 0:
        i = 0
        while i < len(data):
            v_sk.inputline[input_buffer_number].append(data[i])
            i += 1
    return

def dev_serial_in(device):
    data = ""
    if v_dev.serial_interface[device].in_waiting > 0:
        data = v_dev.serial_interface[device].read(10)
    if len(data) > 0:
        i = 0
        while i < len(data):
            v_dev.data_to_CR[device].append(data[i])
            i += 1
    return

def sk_serial_out(sk_number):
    v_sk.serial_interface[sk_number].write(v_sk.info_to_all)
    return

def dev_serial_out(device):
    v_dev.serial_interface[device].write(v_dev.data_to_device[device])
    v_dev.data_to_device[device] = bytearray()
    return

def serial_init(serial_, data):
    # used at init only
    try_number = 0
    error = 0
    line = bytearray([])
    while try_number < 4 and error == 0:
        n = serial_.write(data)
        time.sleep(0.1)
        if n == 0:
            error = 1
        else:
            line = serial_.read(255)
            if len(line) > 0:
                try_number = 4
            else:
                try_number += 1
    if len(line) == 0 and error == 0:
        error = 2
    return error, line

def serial_open(comport, check_active):
    # test availability and baudrate
    br = 19200
    error_ = 0
    serial_interface = ""
    if v_cr_params.interface_baudrate == 0:
        i = 0
        error_ = 1
        while i < 6 and error_ == 1:
            match i:
                case 0:
                    br = 115200
                    error_, serial_interface = serial_open_1(comport,br, check_active)
                case 1:
                    br = 57600
                    error_, serial_interface = serial_open_1(comport, br, check_active)
                case 3:
                    br = 38400
                    error_, serial_interface = serial_open_1(comport, br, check_active)
                case 4:
                    br = 28899
                    error_, serial_interface = serial_open_1(comport, br, check_active)
                case 5:
                    br = 19200
                    error_, serial_interface = serial_open_1(comport, br, check_active)
            i += 1
    if error_ == 0:
        v_cr_params.interface_baudrate = br
    return error_,serial_interface

def serial_open_1(comport, br, check_active):
    # used to check different baudrates -> time = 1 (device may hang otherwise)
    try:
        serial_interface = serial.Serial(comport, br, timeout=1)
        error = 0
    except:
        error = 1
    if error == 0:
        if check_active == 1:
            data = bytes([0xfd])
            n = serial_interface.write(data)
            if n > 0:
                line = serial_interface.read(5)
                if line != bytearray([0xfd, 0x04]):
                    error = 1
    else:
        serial_interface = ""
    return error, serial_interface

# FILE:
def remove_at_start(data):
    if os.path.exists("to" + data):
        os.remove("to" + data)
    if os.path.exists("from" + data):
        os.remove("from" + data)
    return

def sk_file_in(input_buffer_number):
    data = file_in_1(v_sk.file_in[input_buffer_number])
    if len(data) > 0:
        # data must be appended always; do not empty v_sk.inputline[input_buffer_number]
        # otherwise v_sk.data_len is not resetted!
        v_sk.inputline[input_buffer_number].extend(data)
    return

def dev_file_in(device):
    data = file_in_1(v_dev.filename_in[device])
    if len(data) > 0:
        v_dev.data_to_CR[device].append(data)
    return

def file_in_1(file):
    result = bytes()
    if os.path.exists(file):
        # read data once only
        f = open(file, "rb")
        data = f.read()
        f.close()
        try:
            if os.path.exists(file):
                os.remove(file)
        except:
            pass
        if len(data) > 0:
            result = two_byte_to_one_byte(data)
    return result

def sk_file_out(filename):
    file_out1(filename, v_sk.info_to_all)
    return

def dev_file_out(device):
    file_out1(v_dev.filename_out[device],v_dev.data_to_device[device])
    v_dev.data_to_device[device] = bytearray()
    return

def ru_file_out(device,change_mode, user_name, password):
    file_out1(v_dev.filename_out[device], change_mode + ";" + user_name + ";" + password)
    return

def file_out1(file, data):
    d = one_byte_to_two_bytes(data)
    f = open(file, "w")
    f.write(d)
    f.close()
    return

def read_pipe():
    error = 0
    with ReadFromPipe(pipename=r"\\.\pipe\example", ) as r_pipe:
        data = r_pipe.read_message()
        try:
            print (data)
        except Exception:
            error = 1
    return error, data

def write_pipe(pipe, data):
    with Write2Pipe(pipename=r"\\.\pipe" + pipe,
                    nMaxInstances=1,
                    nOutBufferSize=65536,
                    nInBufferSize=65536,
                    timeout=0.2, ) as w_pipe:
        w_pipe.write_message(data)
    return
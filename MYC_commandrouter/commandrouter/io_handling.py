"""
name : io_handlings.py
last edited: 20260414
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""
# all IO should use binary data with bytearrays ( not 100 % tested!!!!!!!!!!!!!)
# exception: terminal input (use 2 hex characters for each byte of bytearray)

import socket
import threading
import platform
import serial
from misc_functions import *
import v_configparameter
import v_dev
import v_sk
import  v_io

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

# Ethernet (sk only):
class ServerThread (threading.Thread):
    # ethernet server Part, connecting to HI, PR...
    def __init__(self, server_socket, input_buffer_number):
        threading.Thread.__init__(self)
        self.server_socket = server_socket
        self.input_buffer_number = input_buffer_number

    def run(self):
        while 1:
            connection, addr = self.server_socket.accept()
            misc_functions.write_log("connected to: " + str(addr))
            server_read = ServerThreadRead(connection, self.input_buffer_number)
            server_read.start()
            misc_functions.write_log("server read start")
            server_write = ServerThreadWrite(connection, self.input_buffer_number)
            server_write.start()
            misc_functions.write_log("server write start")


class ServerThreadRead (threading.Thread):
    # ethernet server Part, connecting to HI, PR...
    def __init__(self, connection, input_buffer_number):
        threading.Thread.__init__(self)
        self.connection = connection
        self.input_buffer_number = input_buffer_number

    def run(self):
        while True:
            try:
                data_in = self.connection.recv(1024)
                if len(data_in) == 0:
                    continue
                v_sk.inputline_active[self.input_buffer_number] = 1
                # lock
#               i = 0
#                while i < len(data_in):
                v_sk.inputline[self.input_buffer_number].extend(data_in)
#                    i += 1
                misc_functions.write_log("Input read: " + str(v_sk.inputline[self.input_buffer_number]) + "end")
            except (ConnectionAbortedError, OSError):
                misc_functions.write_log(" input read aborted")
                self.connection.close()
                exit()
        return


class ServerThreadWrite (threading.Thread):
    # ethernet server Part, connecting to SK
    def __init__(self, connection, input_buffer_number):
        threading.Thread.__init__(self)
        self.connection = connection
        self.input_buffer_number = input_buffer_number

    def run(self):
        while True:
            if v_sk.info_to_telnet != bytearray([]):
                i = 0
                stri = ""
                while i < len(v_sk.info_to_telnet[self.input_buffer_number]):
                    stri += chr(v_sk.info_to_telnet)[i]
                    i += 1
                try:
                    self.connection.sendall(stri)
                    v_sk.info_to_telnet = bytearray([])
                except (ConnectionAbortedError, OSError):
                    misc_functions.write_log("telnet server send aborted")
                    self.connection.close()
                    exit()
        self.connection.close()


def start_ethernet_server(port, input_buffer_number):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        server_socket.bind(("", port))
    except socket.error:
        # to be replaced by entry to log
        misc_functions.write_log("server socket failed")
    server_socket.listen(10)
    ethernet = ServerThread(server_socket, input_buffer_number)
    ethernet.start()
    misc_functions.write_log("Server started")
    return

# connecting to devices: not yet used!

class ClientThread (threading.Thread):
    # ethernet client part, connecting to devices
    def __init__(self, client_socket, host, port, device_buffer_number):
        threading.Thread.__init__(self)
        self.client_socket = client_socket
        self.host = host
        self.port = port
        self.device_buffer_number = device_buffer_number

    def run(self):
        try:
            self.client_socket.connect((self.host, self.port))
        except socket.error:
            # to be replaced by entry to log
            self.client_socket.close()
            exit()
        client_read = ClientThreadRead(self.client_socket, self.device_buffer_number)
        client_read.start()
        client_write = ClientThreadWrite(self.client_socket, self.device_buffer_number)
        client_write.start()
        while 1:
            pass
        self.client_socket.close()


class ClientThreadRead (threading.Thread):
    # ethernet client part, connecting to devices
    def __init__(self, client_socket, device_buffer_number):
        threading.Thread.__init__(self)
        self.client_socket = client_socket
        self.device_buffer_number = device_buffer_number

    def run(self):
        while 1:
            data_in = self.client_socket.recv(1024)
            i = 0
            while i < len(data_in):
                v_dev.data_to_CR[self.device_buffer_number] += data_in[i]
                i += 1
        self.client_socket.close()


class ClientThreadWrite (threading.Thread):
    # ethernet client part, connecting to devices
    def __init__(self, client_socket, device_buffer_number):
        threading.Thread.__init__(self)
        self.client_socket = client_socket
        self.device_buffer_number = device_buffer_number

def run(self):
    while True:
        if len((v_dev.data_to_device[self.device_buffer_number])) > 0:
            i = 0
            out = bytearray([])
            while i < (v_dev.data_to_device[self.device_buffer_number]):
                out += v_dev.data_to_device[self.device_buffer_number][i]
            self.client_socket.sendall(out)
    self.client_socket.close()
    return


def start_ethernet_client(host, port, device_buffer_number):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_thread = ClientThread(client_socket, host, port, device_buffer_number)
    client_thread.start()
    return


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
    if v_sk.info_to_all != bytearray():
        print("info to all SK: " , v_sk.info_to_all)
        v_sk.info_to_all = bytearray()
    return

# serial (uses bytes):
def serial_in_from_sk(input_buffer_number):
    try:
        ser = serial.Serial(v_configparameter.com_port, 19200, timeout=1.0)
    except:
        return
    while 1:
        v_sk.inputline[input_buffer_number] = ser.read(600)
    return

def serial_in_from_dev(device):
    try:
        # 2ms would b enaugh to read 40 bytes
        ser = serial.Serial(v_dev.interface_comport[device], 19200, timeout=.002)
    except:
        return
    while 1:
        # if more bytes, read with next loop
        v_dev.data_to_CR.append(ser.read(10))
    return

def sk_serial_out():
    try:
        ser = serial.Serial(v_configparameter.com_port, 19200, timeout=1.0)
    except:
        return
    ser.write(v_sk.info_to_all)
    v_sk.info_to_all = bytearray()
    return

def dev_serial_out(device):
    try:
        ser = serial.Serial(v_dev.interface_comport[device], 19200, timeout=1.0)
    except:
        return
    ser.write(v_dev.data_to_device[device])
    # there is one interface only -> can be deleted
    v_dev.data_to_device[device] = bytearray()
    return

# FILE:
def remove_at_start():
    if os.path.exists(v_io.from_sk):
        os.remove(v_io.from_sk)
    if os.path.exists(v_io.to_sk):
        os.remove(v_io.to_sk)
    return

def sk_file_in(input_buffer_number):
    file = v_io.from_sk
    if os.path.exists(file):
        if v_io.sk_file_removed == 1:
            # read data once only
            f = open(file, "rb")
            data = f.readline()
            if len(data) > 0:
                # data must be appended always; do not empty v_sk.inputline[input_buffer_number]
                # otherwise v_sk.data_len is not resetted!
                i = 0
                while i < len(data):
                    v_sk.inputline[input_buffer_number].append(data[i])
                    i += 1
                f.close()
        try:
            os.remove(v_io.from_sk)
            v_io.sk_file_removed = 1
        except:
            v_io.sk_file_removed = 0
    else:
        v_io.sk_file_removed = 1
    return

def sk_file_out():
    file = v_io.to_sk
    if not os.path.exists(file):
        f = open(v_io.to_sk, "ab")
        f.write(v_sk.info_to_all)
        f.close()
        v_sk.info_to_all = bytearray()
    return

def file_in_from_dev(device):
    # output should be bytearray
    file = v_dev.filename_in[device]
    if os.path.exists(file):
        f = open(file, "rb")
        line = f.read()
        v_dev.data_to_CR[device].extend(line)
        f.close()
        i = 0
        done = 0
        while i < 5 and done == 0:
            try:
                os.remove(v_dev.filename_in[device])
                done = 1
            except:
                i += 1
    return

def dev_file_out(device):
    file = v_dev.filename_out[device]
    if not os.path.exists(file):
        f = open(v_io.to_sk, "ab")
        f.write(v_dev.data_to_device[device])
        f.close()
        # there is one interface only -> can be deleted
        v_dev.data_to_device[device] = bytearray()
    return

def ru_file_in(input_buffer_number):
    file = v_configparameter.from_ru
    if os.path.exists(file):
        f = open(file, "rb")
        data = f.readline()
        if len(data) > 0:
            # data must be appended always; do not empty v_sk.inputline[input_buffer_number]
            # otherwise v_sk.data_len is not resetted!
            i = 0
            while i < len(data):
                v_sk.inputline[input_buffer_number].append(data[i])
                i += 1
            f.close()
        os.remove(v_io.from_sk)
    return

def ru_file_out(change_mode, user_name, password):
    file = v_configparameter.to_ru
    if not os.path.exists(file):
        f = open(v_io.to_sk, "ab")
        f.write(change_mode + ";" + user_name + ";" + password)
        f.close()
    return
"""
name : io_handlings.py
last edited: 202512
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""

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

    Unix_windows = 0

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
            write_log("connected to: " + str(addr))
            server_read = ServerThreadRead(connection, self.input_buffer_number)
            server_read.start()
            write_log("server read start")
            server_write = ServerThreadWrite(connection, self.input_buffer_number)
            server_write.start()
            write_log("server write start")


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
                write_log("Input read: " + str(v_sk.inputline[self.input_buffer_number]) + "end")
            except (ConnectionAbortedError, OSError):
                write_log(" input read aborted")
                self.connection.close()
                exit()


class ServerThreadWrite (threading.Thread):
    # ethernet server Part, connecting to HI, PR...
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
                    write_log("telnet server send aborted")
                    self.connection.close()
                    exit()
        self.connection.close()


def start_ethernet_server(port, input_buffer_number):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        server_socket.bind(("", port))
    except socket.error:
        # to be replaced by entry to log
        write_log("server socket failed")
    server_socket.listen(10)
    ethernet = ServerThread(server_socket, input_buffer_number)
    ethernet.start()
    write_log("Server started")


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


def start_ethernet_client(host, port, device_buffer_number):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_thread = ClientThread(client_socket, host, port, device_buffer_number)
    client_thread.start()


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
            result = int(t, 16)
        except:
            return
        v_io.data += t
        if len(v_io.data) >= 2:
            r = int(v_io.data, 16)
            v_sk.inputline[input_buffer_number].append(r)
            print (v_sk.inputline[input_buffer_number])
            v_io.data = ""
    return

def sk_terminal_out():
    print("info to all SK:", v_sk.info_to_all)
    return

# serial:
def serial_in(input_buffer_number, sk_dev):
    if sk_dev == 0:
        try:
            ser = serial.Serial(str(v_configparameter.com_port), 19200, timeout=1.0)
        except:
            return
    else:
        try:
            ser = serial.Serial(str(v_dev.interface_comport), 19200, timeout=1.0)
        except FileNotFoundError:
            return
    while 1:
        if sk_dev == 0:
            v_sk.inputline[input_buffer_number] = ser.read(600)
        else:
            v_dev.data_to_CR = ser.read(600)
        return

def sk_serial_out():
    try:
        ser = serial.Serial(str(v_configparameter.com_port), 19200, timeout=1.0)
    except:
        return
    i = 0
    s = ""
    while i < len(v_sk.info_to_all):
        s += v_sk.info_to_all[i]
        i += 1
    ser.write(s)

def dev_serial_out(device):
    try:
        ser = serial.Serial(str(v_dev.interface_comport), 19200, timeout=1.0)
    except FileNotFoundError:
        return
    ser.write(v_dev.data_to_device[device])

# FILE:
def sk_file_in(input_buffer_number):
    file = v_io.from_sk
    if os.path.exists(file):
        f = open(file)
        v_sk.inputline[input_buffer_number] = f.readline()
        f.close()
        os.remove(v_io.from_sk)

def dev_file_in(input_buffer_number):
    file = v_io.from_dev
    if os.path.exists(file):
        f = open(file)
        v_dev.data_to_CR = f.readline()
        f.close()
        os.remove(v_io.from_dev)

def file_out(file):
    if os.path.exists(file):
        os.remove(file)
    i = 0
    s = ""
    while i < len(v_sk.info_to_all):
        s += str(v_sk.info_to_all[i])
        i += 1
    f = open(v_io.to_sk, "a")
    f.write(s)
    f.close()

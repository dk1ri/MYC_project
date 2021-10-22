"""
name : io_handling.py IC9700
last edited: 20211008
"""

import sys
import socket
import threading
import os
import platform
import v_icom_vars


if platform.system() == "Windows":
    import msvcrt
    getch = msvcrt.getch()
    Unix_windows = 1
else:
    import sys, tty, termios

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

from misc_functions import *
import v_sk
import time


def poll_inputs():
    # input polling
    # data are send to v_sk.inputline
    input_buffer_number = 0
    while input_buffer_number < len(v_sk_interface.interface_type):
        if v_sk_interface.activ[input_buffer_number] == 1:
            if v_sk_interface.interface_type[input_buffer_number] == "TERMINAL":
                # input_buffer_number,device_buffer_number
                if v_sk.active[input_buffer_number] == 1:
                    win_terminal(input_buffer_number, 0)
            elif v_sk_interface.interface_type[input_buffer_number] == "TELNET":
                # telnet is a separate thread, writing directly to inputbuffer
                pass
        input_buffer_number += 1
    return


# Ethernet:
class ServerThread (threading.Thread):
    # telnet server
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
    # telnet server
    # CR commands are given as 2 digit hex numbers
    # other commands are:
    # x terminate programm
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
                v_sk.active[self.input_buffer_number] = 1
                # this works with cr and cr + lf
                if data_in[-1] == 0xa:
                    data_in = data_in[:-1]
                if data_in[-1] == 0x0d:
                    data_in = data_in[:-1]
                temp = 0
                while temp < len(data_in):
                    analyze_sk(chr(data_in[temp]), self.input_buffer_number)
                    temp += 1
            except (ConnectionAbortedError, OSError):
                write_log(" input read aborted")
                self.connection.close()
                exit()


class ServerThreadWrite (threading.Thread):
    # telnet server
    def __init__(self, connection, input_buffer_number):
        threading.Thread.__init__(self)
        self.connection = connection
        self.input_buffer_number = input_buffer_number

    def run(self):
        while True:
            if v_sk.info_to_telnet != bytearray([]):
                try:
                    self.connection.sendall(v_sk.info_to_telnet)
                    v_sk.info_to_telnet = bytearray([])
                except (ConnectionAbortedError, OSError):
                    write_log("telnet server send aborted")
                    self.connection.close()
                    exit()


def start_ethernet_server(port, input_buffer_number):
    i = 0
    while i < len(v_sk.ethernet_server_started):
        if port in v_sk.ethernet_server_started[i]:
            return
        i += 1
    v_sk.ethernet_server_started[input_buffer_number].append(port)
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        server_socket.bind(("", port))
    except socket.error:
        # to be replaced by entry to log
        write_log("server socket failed")
    server_socket.listen(10)
    ethernet = ServerThread(server_socket, input_buffer_number)
    ethernet.start()
    write_log("telnet server started")


# client:
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


def start_ethernet_client(host, port, device_buffer_number):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_thread = ClientThread(client_socket, host, port, device_buffer_number)
    client_thread.start()


# Terminal:
def win_terminal(input_buffer_number, device_buffer_number):
    # CR commands are given as 2 digit hex numbers
    # other commands are:
    # x terminate programm
    t = None
    if Unix_windows == 0:
        if kbhitu():
            t = getchu()
    else:
        if msvcrt.kbhit():
            t = msvcrt.getwch()
    if t is not None:
        # reset at any keystroke
        v_icom_vars.command_time = time.time()
        analyze_sk(t, input_buffer_number)
    return


def send_to_all():
    if v_sk.info_to_all != bytearray([]):
        temps = ""
        count = 0
        while count < len(v_sk.info_to_all):
            temp = v_sk.info_to_all[count]
            temps += hex(temp)
            count += 1
        if v_icom_vars.test_mode == 1:
            print("Hex: ", temps)
        else:
            print(temps)
        v_sk.info_to_telnet = v_sk.info_to_all
        v_sk.info_to_all = bytearray([])
    return

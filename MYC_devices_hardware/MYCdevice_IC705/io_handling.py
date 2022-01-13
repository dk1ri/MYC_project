"""
name : io_handling.py IC705
last edited: 20220109
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
    while input_buffer_number < len(v_sk.interface_type):
        if v_sk.active[input_buffer_number] == 1:
            if v_sk.interface_type[input_buffer_number] == "TERMINAL":
                # input_buffer_number,device_buffer_number
                if v_sk.active[input_buffer_number] == 1:
                    win_terminal(input_buffer_number, 0)
            elif v_sk.interface_type[input_buffer_number] == "TELNET":
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
        #    write_log("connected to: " + str(addr))
            server_read = ServerThreadRead(connection, self.input_buffer_number)
            server_write = ServerThreadWrite(connection,)
            server_read.start()
            server_write.start()


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
                    pass
                else:
                    v_sk.active[self.input_buffer_number] = 1
                    temp = 0
                    while temp < len(data_in):
                        analyze_sk(chr(data_in[temp]), self.input_buffer_number)
                        temp += 1
            except (ConnectionAbortedError, OSError):
                self.connection.close()
                exit()


class ServerThreadWrite (threading.Thread):
    # telnet server
    def __init__(self, connection):
        threading.Thread.__init__(self)
        self.connection = connection

    def run(self):
        while True:
            if v_sk.info_to_telnet != bytearray([]) and v_sk.info_to_telnet[-1] == 10:
                try:
                    #self.connection.settimeout(2)
                    self.connection.sendall(v_sk.info_to_telnet)
                    v_sk.info_to_telnet = bytearray([])
                except (ConnectionAbortedError, OSError, socket.timeout):
                    write_log("telnet write server send aborted")
                    v_sk.info_to_telnet = bytearray([])
                    v_sk.info_to_all = bytearray([])
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
        server_socket.bind(("127.0.0.1", port))
    except socket.error:
        # to be replaced by entry to log
        write_log("server socket failed")
    server_socket.listen(2)
    ethernet = ServerThread(server_socket, input_buffer_number)
    ethernet.start()
    write_log("telnet server started")


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
            temp = hex(v_sk.info_to_all[count]).lstrip("0x")
            if len(temp) == 1:
                temp = " 0" + temp
            temps += temp
            count += 1
        v_sk.info_to_telnet.extend([el for el in (v_sk.info_to_all)])
        v_sk.info_to_telnet.extend([10])
        if v_icom_vars.test_mode == 1:
            print("Hex: ", temps)
        else:
            print(temps)
        v_sk.info_to_all = bytearray([])
    return

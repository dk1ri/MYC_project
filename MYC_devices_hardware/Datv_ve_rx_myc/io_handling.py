"""
name : io_handling.py Datv_ve_rx_myc
last edited: 202401229
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)
subs for control input
"""

import socket
import threading
import os

from misc_functions import *
import v_sk
import time


def poll_inputs():
    # input polling
    # data are send to v_sk.inputline
    input_buffer_number = 0
    while input_buffer_number < len(v_sk.interface_type):
        if v_sk.active[input_buffer_number] == 1:
            # if v_dev_vars.telnet_active == 1:
            # telnet is a separate thread, writing directly to inputbuffer
            # pass
            if v_dev_vars.file_active == 1:
                file_data_input(input_buffer_number)
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

def send_to_all():
    # data to SK
    if v_dev_vars.test_mode == 1:
        print ("send to web:", v_sk.info_to_all)
    temps = ""
    temps_pure = ""
    count = 0
    while count < len(v_sk.info_to_all):
        ch = v_sk.info_to_all[count]
        if ch == 0:
            temp = "00"
            temp_pure = "00"
        else:
            temp = hex(ch)
            temp_pure = temp[2:]
            if len(temp) == 3:
                temp = " 0" + temp
                temp_pure = "0"+ temp_pure
        temps += temp
        temps_pure += temp_pure
        count += 1
    if v_dev_vars.telnet_active == 1:
        v_sk.info_to_telnet = bytearray()
        v_sk.info_to_telnet.extend([el for el in v_sk.info_to_all])
        v_sk.info_to_telnet.extend([10])
    if v_dev_vars.file_active == 1:
        # datatransfer via file
        f = open(v_dev_vars.control_data_out, "a")
        f.write(temps_pure)
        f.close()
    v_sk.info_to_all = bytearray([])
    return


def file_data_input(input_buffer_number):
    if os.path.isfile(v_dev_vars.control_data_in):
        file = open(v_dev_vars.control_data_in)
        i = 0
        from_web = ""
        for lines in file:
            # read one line only
            if i == 0:
                from_web = lines
            i += 1
        file.close()
        os.remove(v_dev_vars.control_data_in)
        if len(from_web) > 0:
            if v_dev_vars.test_mode == 1:
                print("from web ", from_web)
            i = 0
            j = 1
            while i < len(from_web):
                v_dev_vars.command_time = time.time()
                analyze_sk(from_web[i:j], input_buffer_number)
                i += 1
                j += 1
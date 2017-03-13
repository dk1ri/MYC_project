# name : commandrouter_ethernet_handling.py
# ethernet handling using threads


import sys
import socket
import threading
import time
import msvcrt

from misc_functions import *
from tests import load_check

import v_configparameter
import v_dev
import v_kbd_input
import v_sk
import v_time_values

# Ethernet:

class ServerThread (threading.Thread):
    # ethernet server Part, connecting to HI, PR...
    def __init__(self, server_socket, input_buffer_number):
        threading.Thread.__init__(self)
        self.server_socket = server_socket
        self.input_buffer_number = input_buffer_number

    def run(self):
        while 1:
            connection, addr = self.server_socket.accept()
            write_log("connected to: "+ str(addr))
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
#        global v_sk
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
                # start timeout
                if v_sk.starttime[self.input_buffer_number] == 0:
                    v_sk.starttime[self.input_buffer_number] = int(time.time())
                    v_sk.inputline_active[self.input_buffer_number] = 0
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
            if v_sk.answer_ready[self.input_buffer_number] == 1:
                try:
                    write_log("telnetServer send: " + str(len(v_sk.answerline[self.input_buffer_number])))
                    self.connection.sendall(v_sk.answerline[self.input_buffer_number])
                    v_sk.answer_ready[self.input_buffer_number] = 0
                    v_sk.answerline[self.input_buffer_number] = bytearray([])
                except (ConnectionAbortedError, OSError):
                    write_log("telnet server send aborted")
                    self.connection.close()
                    exit()
        self.connection.close()


def start_ethernet_server(port, input_buffer_number):
    i= 0
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


# Terminal:


def win_terminal(input_buffer_number, device_buffer_number):
    # can be used to input data to SK or device side
    v_kbd_input.num += 1
    if msvcrt.kbhit():
        t = msvcrt.getwch()
        if v_time_values.auto == 1:
            # ignore other characters in this mode except "a"
            if t == "a":
                v_time_values.auto = 0
                print("input from file stopped")
        else:
            if t == " ":
                # add to inputline
                if v_kbd_input.data != "":
                    if v_kbd_input.data[0 == "a"]:
                        i = int(v_kbd_input.data[1:])
                        v_time_values.command_file = "commandfiles\_commandfile_test"+ str(i)
                        v_time_values.auto = 1
                        v_time_values.check_number = 0
                        # there must be a timeout for invalid commands:
                        v_configparameter.time_for_command_timeout = v_configparameter.time_for_command_timeout / 10
                        v_time_values.checktime = v_configparameter.time_for_command_timeout - 0.5
                        v_time_values.number_of_nok = 0
                        load_check()
                        print("input from file _commandfile_test"+ str(i) +" started")
                    else:
                        i = (int(v_kbd_input.data))
                        if i < 256:
                            # 0: buffer for SK, 1: buffer for device
                            if v_kbd_input.skdev == 0:
                                v_sk.inputline[input_buffer_number].extend(bytearray([i]))
                                print("from SK to CR ", input_buffer_number, " : ", v_kbd_input.data)
                            else:
                                v_dev.data_to_CR[device_buffer_number].append(int_to_bytes(i, 1))
                                v_dev.wait_for_answer[device_buffer_number] = 1
                                print("from device to CR ", device_buffer_number, v_kbd_input.data)
                    v_kbd_input.data = ""
            elif str.isnumeric(t) == 1:
                v_kbd_input.data += t
            elif t == "d":
                v_kbd_input.skdev = 1
                print("next kbd input to device_in")
            elif t == "S":
                v_kbd_input.skdev = 0
                print("next kbd input to SK_in")
            elif t == "e":
                sys.exit(0)
            elif t == "a":
                v_kbd_input.data = t
        # ignore other characters
    return


def terminal_out(text, input_buffer):
    # for bytearrays
    if text == "":
        return
    tt = "from SK " + str(input_buffer) + " to CR: "
    t = ""
    i = 0
    while i < len(text):
        try:
            t += (chr(text[i]))
        except UnicodeEncodeError:
            t += "length unprintable "
        i += 1
    tt +=  t
    if v_time_values.auto == 0:
        print(tt)
    else:
        if t == v_time_values.to_sk[v_time_values.check_number - 1]:
            print (v_time_values.check_number - 1, "ok: ", tt)
        else:
            print(v_time_values.check_number - 1, "nok", tt, v_time_values.to_sk[v_time_values.check_number - 1])
    return

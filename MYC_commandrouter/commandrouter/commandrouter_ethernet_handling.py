# ethernet handling using threads

import socket
import threading
import v_input_buffer
import v_device_buffer
import time


class ServerThread (threading.Thread):
    # ethernet server Part, connecting to HI, PR...
    def __init__(self, server_socket, input_buffer_number):
        threading.Thread.__init__(self)
        self.server_socket = server_socket
        self.input_buffer_number = input_buffer_number

    def run(self):
        while 1:
            connection, addr = self.server_socket.accept()
            print("connected to: ", addr)
            server_read = ServerThreadRead(connection, self.input_buffer_number)
            server_read.start()
            print ("server read start")
            server_write = ServerThreadWrite(connection, self.input_buffer_number)
            server_write.start()
            print ("server write start")


class ServerThreadRead (threading.Thread):
    # ethernet server Part, connecting to HI, PR...
    def __init__(self, connection, input_buffer_number):
        threading.Thread.__init__(self)
        self.connection = connection
        self.input_buffer_number = input_buffer_number

    def run(self):
        while True:
            data_in = self.connection.recv(1024)
            i = 0
            while i < len(data_in):
                v_input_buffer.inputline[self.input_buffer_number] += chr(data_in[i])
                i += 1
            data_in = ([])
            print("Server read:", i, v_input_buffer.inputline[self.input_buffer_number],"end")
            # start timeout
            if v_input_buffer.starttime[self.input_buffer_number] == 0:
                v_input_buffer.starttime[self.input_buffer_number] = int(time.time())
            if not data_in:
                break
        self.connection.close()
        print("closed")

class ServerThreadWrite (threading.Thread):
    # ethernet server Part, connecting to HI, PR...
    def __init__(self, connection, input_buffer_number):
        threading.Thread.__init__(self)
        self.connection = connection
        self.input_buffer_number = input_buffer_number

    def run(self):
        while True:
            if v_input_buffer.answer_ready == 1:
                print("telnetServer send: ", len(v_input_buffer.answerline[self.input_buffer_number]))
                self.connection.sendall(v_input_buffer.answerline[self.input_buffer_number])
                v_input_buffer.answer_ready = 0
        self.connection.close()


def start_ethernet_server(port, input_buffer_number):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        server_socket.bind(("", port))
    except socket.error:
        # to be replaced by entry to log
        print("server socket failed")
    server_socket.listen(10)
    ethernet = ServerThread(server_socket, input_buffer_number)
    ethernet.start()
    print("Server started")


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
        while 1:
            client_read = ClientThreadRead(self.client_socket, self.device_buffer_number)
            client_read.start()
            client_write = ClientThreadWrite(self.client_socket, self.device_buffer_number)
            client_write.start()
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
                v_device_buffer.data_to_CR[self.device_buffer_number] += data_in[i]
                i += 1
            if not data_in:
                break
        self.client_socket.close()


class ClientThreadWrite (threading.Thread):
    # ethernet client part, connecting to devices
    def __init__(self, client_socket, device_buffer_number):
        threading.Thread.__init__(self)
        self.client_socket = client_socket
        self.device_buffer_number = device_buffer_number

    def run(self):
        while True:
            if len((v_device_buffer.data_to_device[self.device_buffer_number])) > 0:
                i = 0
                out = bytearray([])
                while i < (v_device_buffer.data_to_device[self.device_buffer_number]):
                    out += v_device_buffer.data_to_device[self.device_buffer_number][i]
                self.client_socket.sendall(out)
        self.client_socket.close()


def start_ethernet_client(host, port, device_buffer_number):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_thread = ClientThread(client_socket, host, port, device_buffer_number)
    client_thread.start()

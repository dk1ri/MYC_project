"""
name : send_get_data
Version 01.0, 20211214
Purpose : Program to send data to the commandrouter, wait for answer and print the result ("echo client")
"""
# general
import sys
import socket
import time


data_to_CR = bytearray([])
start_time = time.time()
i = 2
j = 0
while i < len(sys.argv):
    while j < len(sys.argv[i]):
        if str.isnumeric(sys.argv[i][j]):
            data_to_CR.append(int(sys.argv[i][j]) + 48)
        elif 96 < ord(sys.argv[i][j]) < 103:
            data_to_CR.append(ord(sys.argv[i][j]))
        j += 1
    i += 1
HOST = '192.168.2.100'
PORT = 23
data = ""
m = ord(sys.argv[1])
if m == 48 or m == 49:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        s.sendall(data_to_CR)
        if m == 49:
            data = s.recv(1024)
            print(data)

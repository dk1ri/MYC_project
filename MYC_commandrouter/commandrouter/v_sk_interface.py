""""
name: v_sk_interface.py
last edited: 201803
parameters for SK hardware interface
"""
baudrate = []                           # for RS232
inputline = []                          # actual input buffer, got from SK...
inputline_active = []                   # if 1: locked by ethernet
interface_adress =[]                    # adress for I2C, ... string
interface_port = []                     # port for USB, http...
interface_timeout = []                  # timeout
interface_type = []                     # interface type as Terminal, Ethernet I2C,...
number_of_bits = []                     # for RS232
activ =[]                               # copied from 255 announceline
#telnet
source = []                     	    # d: device -> client        h: HI -> server
socket = []                     	    # sockets
telnet_number = []              	    # index for this
ethernet_server_started =[]             # contain s list of started ports


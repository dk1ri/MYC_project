""""
name: v_sk.py Datv_ve_rx_myc
last edited: 20250109
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)
parameters for SK channel
"""
# one item for each SK channel
active = []                             # 0: not available, 1: active, 2: input buffer full
inputline = []                          # input buffer
last_command = []			            # last inputline
starttime = []                          # starttime of command
last_token = bytearray([0, 0])          # token of last command
parameter = bytearray([])               # parameter to be transferred from command to answer

info_to_all = bytearray([])             # output to all SK
info_to_telnet = bytearray({})          # temporary

interface_port = []                     # port for USB, http...
interface_timeout = []                  # timeout
interface_type = []                     # interface type as Terminal, Ethernet I2C,...
# telnet
socket = []                     	    # sockets
ethernet_server_started = []            # contains list of started ports
data = 0
hex_count = 0

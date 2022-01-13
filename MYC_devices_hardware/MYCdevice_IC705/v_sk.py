""""
name: v_sk.py IC705
last edited: 20220103
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
ethernet_server_started = []             # contains list of started ports

# keyboard
data = 0                                # ASCII from keyboard
hex_count = 0

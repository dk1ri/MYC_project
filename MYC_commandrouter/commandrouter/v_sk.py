""""
name: v_sk.py
last edited: 20260414
parameters for SK channel
channel may be (non permanent) virtual for multi-channel interfaces
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""

# one item for each SK input
active = []                             # 0: not available, 1: active, 2: input buffer full
channel_answer_token = []               # token of commands, for which the user want answers
info_to_all = bytearray()               # output to all SK
inputline = []                          # input buffer
interface_timeout = []                  # timeout
interface_type = []                     # interface type as Terminal, Ethernet
last_error = "no error"                 # last error message
data_len = []                           # store data for data_handling
starttime = []                          # starttime of command
source = []
timeout = []
type = []
serial_interface = {}                   # is handler
com_port = []
baudrate = []
ethernet_host = ""
ethernet_port = ""
#file
file_in = []
file_out = []
# telnet
ethernet_port = []
channel_number = []                     #
channel_timeout = []                    #
info_to_telnet = []                     # temporaray
multi_channel = []                      # 0: not active, 1: active
socket = []                     	    # sockets
telnet_number = []              	    # index for this
ethernet_server_started = []             # contain s list of started ports
multiuser = []
user_timeout = []

orig_to_ld = []                         # original input from CR to LD (to send to back to CR -> dev without additional handling
input_as_parameter_list = []            # input splitted to parameters (integer or string for LD
""""
name: v_sk.py
last edited: 201803
parameters for SK channel
channel may be (non permanent) virtual for multi-channel interfaces

"""
# one item for each SK channel
active = []                             # 0: not available, 1: active, 2: input buffer full
inputline = []                          # input buffer
len =[]                                 # contain a list: len, loop, other1, other2, other3
last_error = []                         # last error message
starttime = []                          # starttime of command
channel_answer_token = []               # token of commands, for which the user want answers
channel_number = []                     #
channel_timeout =[]                     #
multi_channel =[]                       # 0: not active, 1: active

info_to_all = bytearray([])             # output to all SK
info_to_telnet = bytearray({})          # temporaray

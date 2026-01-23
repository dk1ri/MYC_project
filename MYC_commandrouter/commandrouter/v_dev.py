"""
name: v_dev.py
last edited: 202512
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""
#
# items stored per device, stored at initialization:
announcements = []              # announcements of a device
avtive = []                     #active
interface_adress = []           #
interface_baudrate =[]          #
interface_comport = []          #
interface_number_of_bits =[]    # RS232
interface_port = []             # http, telnet ...
interface_timeout =[]           #
interface_type = []             # USB. TELNET...
len = []                        # store data for datahandling
length_commandtoken = []        # int: length of commandtoken for device commands
name = []                       # string: name of that device (devicegroup and indiv)
rules = []                      # rules of a device
all_toks = []                   # list of all commandtoken for a device (int)

# during operating
data_to_CR = []                 # string: actual received answer or info from device
data_to_device = []             # ringbuffer of bytearrays: data from CR, when command is ready, to be send to device
input_device = []               # input_device, which sent the command
start_time = []                 # time, when info starts
a_to_o =[]
o_to_a = []
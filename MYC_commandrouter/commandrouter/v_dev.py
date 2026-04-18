"""
name: v_dev.py
last edited: 20260414
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""
#
# items stored per device, stored at initialization:
init_device = 0                 # device to be read at int
init_sequence = 0               # sequence for reading devices info at init
init_ready = 0                  #
anouncefile_name = {}           # names of anouncefile per interface_number
announcements = {}              # dict of announcements lines of a device; tok as index, stripped, not other lines
                                # data as list of  parameters
announcments_not_stripped = {}  # as above
                                # and data is list of characters with leading length (for use with announcelist.full_240
rules = {}                      # per devices ( to resolve toks)
other_lines = {}                #
all_toks_of_dev = {}            # all toks of a device
all_answer_toks = {}            # toks of devices, per device
token_length = 1                # of device-token
active = {}                     #active
interface_adress = {}           #
interface_baudrate = {}         #
interface_comport = {}          #
filename_in = {}
filename_out = {}
interface_number_of_bits = {}   # RS232
interface_port = {}             # http, telnet ...
interface_timeout = {}          #
interface_type = {}             # USB. TELNET...
len = {}                        # store data for datahandling
length_commandtoken = {}        # int: length of commandtoken for device commands
name = {}                       # string: name of that device (devicegroup and indiv)
all_answers = {}                # answer commands only
device_by_cr_tok = {}              # device by translated toks
dev_tok_by_cr_tok = {}             # device token by translated tokn

# during operating
data_to_CR = {}                 # string: actual received answer or info from device
data_to_device = {}             # per device: data from CR, when command is ready, to be sent to device
#input_device = []              # input_device, which sent the command
start_time = {}                 # time, when info starts
a_to_o ={}
o_to_a = {}
if_unless = {}
ruleindex_typ = {}
direct_command_to_sent = {}
left_toks = {}
right_toks = {}
all_conditions = {}             # format see: v_ld.all_condition_per_index
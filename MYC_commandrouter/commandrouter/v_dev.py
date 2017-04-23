# items stored per device
#
# fixed, stored at initialization:
actual_device_token =[]
announceline = []               # announcements
cr_dev_tok = []                 # cr_token -> dev_token (directories)
info = []                       # device FEATURE : INFO
length_commandtoken = []        # int: length of commandtoken for device commands
data_to_CR = []                 # string: actual received answer or info from device
data_to_device = []             # ringbuffer of bytearrays: data from CR, when command is ready, to be send to device
writepointer = []               # for ringbuffer
readpointer = []                # for ringbuffer
dev_cr_tok = []                 # reverse: dev_token -> cr_token (directory)
tok = []                        # list of alle commandtoken for a device (int)
input_device = []               # input_device, which sent the command
interface_adress = []           #
interface_baudrate =[]          #
interface_comport = []          #
interface_number_of_bits =[]    # RS232
interface_port = []             # http, telnet ...
interface_timeout =[]           #
interface_type = []             # USB. TELNET...
linelength_len =[]              # linelength parameters modified at real time: number of byte for next action
linelength_other = []           # additional parameter for some commands
linelength_loop = []            # loopcounter
linelength_other1 = []
name = []                       # string: name of that device (devicegroup and indiv)
start_time = []                 # time, when info starts
user =[]                        # for multiuser, 0 : not defined or open channel

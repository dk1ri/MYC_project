# one buffer for each SK
baudrate = []                           # for RS232
inputline = []                          # actual input buffer, got from SK...
inputline_active = []                   # if 1: locked by ethernet
interface_adress =[]                    # adress for I2C, ... string
interface_name = []                     # des after interface_type in 255  line
interface_port = []                     # port for USB, http...
interface_timeout = []                  # timeout
interface_type = []                     # interface type as Terminal, Ethernet I2C,...
last_error = []                         # last error message
linelength_len =[]                      # linelength parameters modified at real time: number of byte for next action
linelength_other =[]                    # necessary for some commands
linelength_other1 =[]                    # necessary for some commands
linelength_actual_call =[]              # count the number of analyze calls
name = []                               # interface_type + interface_name
number_of_bits = []                     # for RS232
starttime = []                          # starttime
user_active =[]                         # array of 256 for 256 user
user_answer_token = []                  # #token of commands, for which the user want ansers
user_number = []
user_timeout =[]
multiuser =[]                           # 0: not active, 1: active 2 not set
#telnet
source = []                     	    # d: device -> client        h: HI -> server
socket = []                     	    # sockets
telnet_number = []              	    # index for this
ethernet_server_started =[]             # # contain s list of started ports
#
info_to_all = bytearray([])            # output to allSK
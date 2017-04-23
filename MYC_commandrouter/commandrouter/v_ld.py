# items stored for ld
#
data_to_ld = ""                         # data from CR (valid command) from SK
data_to_cr = bytearray([])              # data to CR, info or command, routing kernel handles bytearrays
ld_available = 0
linelength_len = 0                      # linelength parameters modified at real time: number of byte for next action
linelength_loop = 0                     # loopcounter
linelength_other = 0                   # additional parameter for some commands
linelength_other1 = 0
starttime = 0
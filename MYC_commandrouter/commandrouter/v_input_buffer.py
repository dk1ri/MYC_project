# one buffer for each HI / PR
name = []                               # interface type as Terminal, Ethernet I2C,...
actual_token = []                       # actual commandtoken as int (for non local commands), 0: array cleared
actual_token_string = []                # actual commandtoken as string
inputline = []                          # actual input buffer, got from HI...
input_ready = []                        # input complete, takes the number of charcters to be transfered. 0: not ready
answerline = []                         # actual answer buffer
answer_ready = []                       # actual aswer ready
device_index = []                       # actual index to device involved
original_command_index = []             # actual index to command within device
starttime = []                          # starttime
last_error = []                         # last error message
wait = []                               # real time value: wait until len(input_line) is higher
interface = []                          # list: interfaceparameters of device
# 0: USB|TC5|RC6|CAN 1: NAME 2:ADRESS
# 0: TERMINAL 1: NAME
# 0: TELNET|HTTP|HTTPS 1: NAME 2: PORTNUMBER 3: TIMEOUT

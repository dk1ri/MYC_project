# items stored per device

# fixed, stored atinitialization:
name = []                      # string: name of that device (devicegroup and indiv)
interface = []                 # list: interfaceparameters of device
# 0: USB|TC5|RC6|CAN 1: NAME 2:ADRESS
# 0: TERMINAL 1: NAME
# 0: TELNET|HTTP|HTTPS 1: NAME 2: PORTNUMBER 3: TIMEOUT 4: Adress for client
commandtokenlength = []        # int: length of commandtoken for devce commands
all_comandtoken = []           # list of alle commandtoken for a device
# temporary, during handling a command, answer or info:
actual_CR_token_index = []     # int:  actual index to commandtoken in work, 0, nothing actual, token of CR announcelist
# index 0 is the CR basic announcement, here only device commands are used

actual_device_token = []      # int: corresponding device_token
# command to device:
data_to_device = []            # string: data from CR, when command is ready, to be send to device
wait_for_answer = []           # bit: actual need to wait for answer?
# answer, info to CR:
data_to_CR = []                # string: actual received answer or info from device
bytenumber_for_next_action = []  # int: byte position for next call of analyze_linelength
answer_info_finished = []      # bit set if linelength data are complete
stringlength = []              # for strings: actual length
elementnumber = []             # number of actual element (number or string) in work

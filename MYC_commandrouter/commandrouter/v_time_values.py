""""
name: v_time_values.py
last edited: 201802
time parameters
"""
time_for_activ_check = 0
time_for_device_search = 0
time_for_logfile_check = 0
#is modified to command
# must be integer
checktime = 1
last_checktime = 0
check_number = 0
announcement = []
from_sk = []
to_dev = []
errormsg = []
#errormsg_sk =[]
auto = 0
# manual / automatic input to terminal
terminal = 255
out_device = 0
number_of_ok = 0
number_of_nok = 0
number_of_ok_nok = 0
all = 0
data = bytearray([])            #store intermediate data
command_file = 0
# for random test
random_i = 0
random_time = 0
random_k = 10
mess = 0                        # for performancemeasurement
mess_byte = 0                   # for performancemeasurement
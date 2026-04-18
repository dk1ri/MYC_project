""""
name: v_configparameter.py
last edited: 20260414
parameters for commandrouter configuration
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""
device_names = {}                   # names of devices to add to commands
local_interface_files = 0           # 0 fileinterace local 1: xampp/htdocs/...
actual_device_name_search = ""
announcements_dir = ""				# directory for announcements of devices
cr0_announcements = {}              # announcemnts for CR
channel_timeout = 0                 # for multi channel mode
com_port = ""                       # comport to SK
connection_of_devices = ""			# filename of connections at start
dev_file_interface = ""            # dir name for dev file inteface
ethernet_port = ""
from_web = ""
logfile =""                         # logfile
max_log_lines = 0                   # logfile is purged, when this number of is reached
system_timeout = 0
other_lines = []                    # fixed values: non command announcelines: 1st char
sk_buffer_limit = 0                 # buffer is purged, if limit is reached
sk_buffer_limit_testmode = 0        # buffer is purged, if limit is reached (testmode)
sk_file_interface = ""            # dir name for sk file inteface
sk_hysteresys = 10                  # percentage, when buffer is switched on again
test_mode = 1                       # 0: normal usage, 1: print logmessages
time_for_activ_check = 0			# time in sec for checking weather a device is active
time_for_device_search = 0			# time in sec for searching for new devices
time_for_command_timeout = 0		# time in sec for command timeout
to_web = ""                         # filename
to_ru = ""                          # filename
from_ru = ""                        # filename
other_lines_id = ["I", "L", "R", "Q", "S", "T"]
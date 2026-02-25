""""
name: v_configparameter.py
last edited: 20260224
parameters for commandrouter configuration
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""
device_names = {}                   # names of devices to add to commands
actual_device_name_search = ""
announceline_0_CR = ""              # line 0 of CR
announceline_240_CR = ""            # line 240 of CR
announceline_241_CR = ""            # line 241 of CR
announceline_242_CR = ""            # line 242 of CR
announceline_254_CR = ""            # line 254 of CR
announceline_255_CR = ""            # line 255 of CR
#announcements = ""					# location of announcements
announcements_dir = ""				# directory for announcements of devices
channel_timeout = 0                 # for multi channel mode
com_port = ""                       # comport to SK
connection_of_devices = ""			# filename of connections at start
ethernet_port = ""
logfile =""                         # logfile
max_log_lines = 0                   # logfile is purged, when this number of is reached
system_timeout = 0
other_lines = []                    # fixed values: non command announcelines: 1st char
sk_buffer_limit = 0                 # buffer is purged, if limit is reached
sk_buffer_limit_testmode = 0        # buffer is purged, if limit is reached (testmode)
sk_hysteresys = 10                  # percentage, when buffer is switched on again
test_mode = 1                       # 0: normal usage, 1: print logmessages
time_for_activ_check = 0			# time in sec for checking weather a device is active
time_for_device_search = 0			# time in sec for searching for new devices
time_for_command_timeout = 0		# time in sec for command timeout
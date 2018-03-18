""""
name: v_configparameter.py
last edited: 201803
parameters for commandrouter configuration
"""
#announcements = ""					# location of announcements
my_devices_file = ""				# file for my_devicex
devicegroup = ""					# directory of devicegroupfiles
time_for_activ_check = 0			# time in sec for checking weather a device is active
time_for_device_search = 0			# time in sec for searching for new devices
time_for_command_timeout = 0		# time in sec for command timeout
logfile =""                         # logfile
time_for_logfile_check = 0          # time i sec for checking logfile
max_log_lines = 0                   # logfile is purged, when this number of is reached
system_timeout = 0
channel_timeout = 0                 # for multi channel mode
test_mode = 1                       # 0: normal usage, 1: print logmessages
sk_buffer_limit = 0                 # buffer is purged, if limit is reached
sk_buffer_limit_testmode = 0        # buffer is purged, if limit is reached (testmode)
sk_hysteresys = 10                  # percentage, when buffer is switched on again
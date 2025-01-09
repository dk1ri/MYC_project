"""
name : v_Datv_ve_rx_myc_vars.py Datv_ve_rx_myc
last edited: 20241226
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)
Specific constants and variables
"""
# configurable variables (default) may be overwritten by ___config_default
telnet_active = 1
telnet_port = 23
control_data_in = ""
control_data_out = ""

# system configuration varialbles (default)
config_file_default = "___config_default"
config_file = "___config"
announce_list = "___announcements"
log_file = "___logfile"
logfilesize = 100               # lines
test_mode = 1
command_no = 0
device_name = "Device 1"
device_number = 1
file_active = 1
error_cmd_no = 255
last_error_msg = ""
command_timeout = 2
indiv_data_file = ""

# other
# set to 1, when read is done; to 0 after successful send (SK)
input_locked = 0
data_to_CR = bytearray([])

# will have all frequencies with base: 28mHz = 0 as well (due to frequency read)
frequency_dat = 0

# MYC data:
drift_dat = 0
fastlock_dat = 0
fec_dat = 0
gain_dat = 23
gui_dat = 0
player_dat = 0
record_iq_dat = 0
record_t_dat = 0
sampler_dat = 0
samplerate_dat = 0
standard_dat = 0
symbolrate_dat = 0
viterbi_dat = 0
selected_chanal = 0

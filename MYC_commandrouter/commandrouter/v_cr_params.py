""""
name: v_cr_params.py
last edited: 20260429
commandrouter parameters
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""
# temporary device data during init for dvices only:
device_type_name = ""                   # device_type_name of the CR !!!
device = 1                              # devices (used by init) checked (skip CR)
# used by all devices:
b_name = ""                              # device_type_name of the device (read from basic line)
anouncefile_name = ""
serial_interface = ""                   # handler
interface_file_in = ""
interface_file_out = ""
interface_pipe = ""
interface_typ = 0
interface_name = ""
interface_com_port = ""
interface_baudrate = 0
interface_ethernet_port = ""
length_commandtoken = 1

# parameter of CR announcement (data of interface to SK
c254_line = ""
c255_line = ""
name = ""
number = ""
# there nay be more than one SK interfaces of the same type (one terminal only)
rs232_com_port = []
usb_com_port = []
ethernet_port = []
file_active = ""
filename = []

c_251_name_length = 0                   #
c_251_password_length = 0               #
length_of_c_249_elements = 0            # length of this
sk_buffer_limit = 0                     # actual SK limit
sk_buffer_limit_low = 0                 # actual SK lower limit for enable again
lower_level_cr = []
wait_for_data = 0                       # from device
known_devices = []
length_of_par = {"z": 0,
                "a" : 1,
                "b": 1,
                "i": 2,
                "w": 2,
                "e": 4,
                "L": 4,
                "s": 4,
                "d": 8,
                }
max_of_par =    {"z": 0,
                "a": 0x01,
                "b": 0xff,
                "i": 0xffff,
                "w": 0xffff,
                "e": 0xffffffff,
                "L": 0xffffffff,
                "s": 0xffffffff,
                "t": 0xffffffffffffffff,
                "d": 0xffffffffffffffff,
                }

command_types = ["a", "b", "c", "i", "w", "e", "L", "s", "d"]


""""
name: v_cr_params.py
last edited: 201802
commandrouter parameters
"""
full_device_name = ""
length_commandtoken = 1         # length_of_commandtoken
start_of_reserved_token = 0xf0
number_of_commands = 0          # in full list; token are without gaps, including &HxxFx;
number_of_commands_noCR = 0     # as above, excluding &HxxFx
actual_cr_own_command = []      # depending on number of ccommands: list od CR own tokens
#ld_found = 0                   # set if LD avalable
lower_level_cr = []
adder = 0                       # adder for &HxxFx commands
                                # for full list announcements
startnumber = 0                 # start of token of other devices in full announcelist
startindex = 0                  # for index in full list: startnumber - 1
length_of_par = {"z": 0,
                "a" : 1,
                "b": 1,
                "i": 2,
                "w": 2,
                "e": 4,
                "L": 4,
                "s": 4,
                "t": 8,
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
cr_announcement = []            # CR announve lines except basic line
c_249_elements = 0              # max (number of ASIC commands * commandlength)
c_251_name_length = 0           #
c_251_password_length = 0       #
length_of_c_249_elements = 0    # length of this
sk_buffer_limit = 0             # actual SK limit
sk_buffer_limit_low = 0         # actual SK lower limit for enable again
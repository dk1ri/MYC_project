# commandrouter parameter
full_device_name = ""
length_announcement_length = 0
length_commandtoken = 1        # length_of_commandtoken
length_last_error_length = 0
number_of_commands = 0          # in full list; token are without gaps, including &HxxFx;
number_of_commands_noCR = 0     # as above, excluding &HxxFx
ld_found = 0                    # set if LD avalable
#announcements = []             # CR announcements added to full list (-> no &HxxFE and &HxxFF
lower_level_cr = []
adder = 0                       # adder for &HxxFx commands
                                # for CR announcements
reserved_token_start = 0        # &HxxF0
startnumber = 0                 # start of token of other devices in full announcelist
startindex = 0                  # for index in full list: startnumber + 1
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
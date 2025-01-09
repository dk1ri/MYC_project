"""
name : analyze.py Datv_ve_rx_myc
last edited: 20241226
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)
command handling, subprograms for sk and civ
"""

from misc_functions import *
import commands
import v_announcelist


# ------------------------------------------------
# start of commandhandling
# ------------------------------------------------


def poll_sk_input_buffer():
    input_device = 0
    # something received from SK ... ?
    while input_device < len(v_sk.inputline):
        line = v_sk.inputline[input_device]
        # if input data is correct and complete appropriate action is called
        if len(line) > 0:
            # check for basic command
            if line[0] == 0:
                v_sk.info_to_all = bytearray([0x00, len(v_announcelist.full[0])])
                v_sk.info_to_all.extend([ord(el) for el in v_announcelist.full[0][1:]])
                # no civ -> unlock input
                v_dev_vars.input_locked = 0
                # necessary to delete token:
                finish = 1
            else:
                 #   tokennumber = int.from_bytes(line[0], byteorder='big', signed=False)
                tokennumber = line[0]
                finish = commands.command_selector(tokennumber, line)
            if finish == 0:
                # continue reading input
                pass
            else:
                # finish == 1 or 2
                if finish == 2:
                    # error
                    v_dev_vars.error_cmd_no = v_dev_vars.command_no
                    temps = ""
                    count = 0
                    while count < len(v_sk.inputline[input_device]):
                        temp = v_sk.inputline[input_device][count]
                        temps += hex(temp)
                        count += 1
                    write_log(v_dev_vars.last_error_msg +" " + temps)
                    print ("finish 2 - " + v_dev_vars.last_error_msg + "  " + temps + " - delete")
                    v_sk.info_to_all = bytearray([])
                    v_dev_vars.input_locked = 0
                # stop watchdog
                v_dev_vars.command_time = 0
                v_sk.inputline[input_device] = bytearray([])
                v_dev_vars.command_no += 1
                v_dev_vars.command_no %= 255
                if v_dev_vars.error_cmd_no == v_dev_vars.command_no:
                    # no error
                    v_dev_vars.error_cmd_no = 255
        input_device += 1
    return

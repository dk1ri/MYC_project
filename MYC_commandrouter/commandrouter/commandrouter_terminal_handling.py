"""
 for test purposes!!
 this is the keyboard interface not according to MYC specification:
 a numeric input as ascii (decimal 0... 255) values is converted to one byte
 after each space the sub for checking the v_kbd_input.a is called
can be used for input of HI or device
"""

import time
import msvcrt
import v_kbd_input
import v_input_buffer
import v_device_buffer
from commandrouter_misc_functions import *


def win_terminal(input_buffer_number, device_buffer_number, input_device):
    if msvcrt.kbhit():
        # for test purposes!!
        # this is the keyboard interface not according to MYC specification:
        # a numeric input as ascii (decimal 0... 255) values is converted to one byte
        # after each space the sub for checking the v_kbd_input.a is called
        # str
        t = msvcrt.getwch()
        if ord(t) == 32:
            if v_kbd_input.a != "":
                i = (int(v_kbd_input.a))
                if i < 256:
                    # 0: buffer for input, 1: buffer for device
                    if input_device == 0:
                        # start timeout
                        if v_input_buffer.starttime[input_buffer_number] == 0:
                            v_input_buffer.starttime[input_buffer_number] = int(time.time())
                            # input buffer
                            v_input_buffer.inputline[input_buffer_number] += int_to_bytes(i, 1)
                            if input_device == 0:
                                print("HI_in", input_buffer_number, v_kbd_input.a)
                            else:
                                print("device_in", device_buffer_number, v_kbd_input.a)
                    else:
                        v_device_buffer.data_to_CR[device_buffer_number] += int_to_bytes(i, 1)
                    v_kbd_input.a = ""
        else:
            if str.isnumeric(t) == 1:
                v_kbd_input.a += t
    return


def terminal_out(text):
    if text == "":
        return
    try:
        print(text)
    except UnicodeEncodeError:
        print("length unprintable ", text[1:])
    print(text)
    return

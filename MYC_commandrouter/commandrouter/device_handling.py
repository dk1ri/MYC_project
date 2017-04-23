"""
name : device_handling.py
devicehandling subprograms
analyzes the answers and info and transfer to SK devices buffers
"""

from cr_own_commands import *
from misc_functions import *

import v_linelength
import v_dev


def poll_device_buffer():
    # analyze data from device for completeness to transfer to SK
    # the input may occur in a way, that more than one loop are necessary to finish
    # or a answer or info may be complete immediately. in this case, the handling should be completed
    # before switching to the next device
    # input is a bytearray for each device
    # device 0 (CR)content is created by CR, inputs to CR are handled in send_device
    device = 0
    for line in v_dev.data_to_CR:
        # wait for complete commandtoken
        if len(line) < v_dev.length_commandtoken[device]:
            # not enough bytes
            device += 1
            continue
        device_tokennumber = int.from_bytes(line[:v_dev.length_commandtoken[device]], byteorder='big', signed=False)
        # usually should be true:
        if device_tokennumber in v_dev.tok[device]:
            # cr_token
            try:
                tok = v_dev.dev_cr_tok[device][device_tokennumber]
            except KeyError:
                clear_dev(device, v_dev.length_commandtoken[device], 1, 0)
                device += 1
                write_log("dev, no vaid token")
                continue
            if v_linelength.answer[tok] == "0":
                # device cannot send command answer : due to some error before
                clear_dev(device, v_dev.length_commandtoken[device], 1, 0,)
                error = "dev cannot send this answer"
                write_log(error)
                device += 1
                continue
            # got valid token now
            # use rest of line
            line = line[v_dev.length_commandtoken[device]:]
            line_length_index_0 = v_linelength.answer[tok][0]
# start switches,range commands and numeric om, am
            if line_length_index_0 == "1":
                if v_dev.start_time[device] == 0:
                    # start timeout
                    v_dev.start_time[device] = time.time()
                if v_dev.linelength_loop[device] == 0:
                    v_dev.linelength_len[device] = v_linelength.answer[tok][1]
                while len(line) >= v_dev.linelength_len[device]:
                    if v_linelength.answer[tok][2] == 0:
                        # got all
                        clear_dev(device, v_dev.linelength_len[device], 0, tok)
                        # exit "while loop"
                        device += 1
                        break
                    # startindex of block (of v_linelength.answer[tok])
                    start = 4 + 3 * v_dev.linelength_loop[device]
                    if v_linelength.answer[tok][start + 2] == 2:
                        # check parameter
                        parameter = bytes_to_int_ba(line[v_dev.linelength_len[device] - v_linelength.answer[tok][start + 1]:v_dev.linelength_len[device]])
                        if parameter > v_linelength.answer[tok][start]:
                            clear_dev(device, v_dev.linelength_len[device], 1, 0)
                            error = "dev switch parameter value too high, loop:" + str(v_dev.linelength_loop[device]) + " " + str(parameter) + " " + str(v_linelength.answer[tok][start])
                            write_log(error)
                            # exit "while loop"
                            break
                    v_dev.linelength_loop[device] += 1
                    if v_dev.linelength_loop[device] == v_linelength.answer[tok][2]:
                        # all loops done
                        clear_dev(device, v_dev.linelength_len[device], 0, tok)
                        device += 1
                        break
                    else:
                        # add next linelength
                        v_dev.linelength_len[device] += v_linelength.answer[tok][start + 4]
                else:
                    # not enough bytes
                    device += 1
# end witches,range commands and numeric om, am. no real time length calculation
# start am string, identical to "1" except loop = 2
            elif line_length_index_0 == "2":
                if v_dev.start_time[device] == 0:
                    # start timeout
                    v_dev.start_time[device] = time.time()
                if v_dev.linelength_loop[device] == 0:
                    v_dev.linelength_len[device] = v_linelength.answer[tok][1]
                while len(line) >= v_dev.linelength_len[device]:
                    if v_dev.linelength_loop[device] == 0:
                        v_dev.linelength_len[device] = v_linelength.answer[tok][1]
                    # startindex of block (of v_linelength.answer[tok])
                    start = 4 + 3 * v_dev.linelength_loop[device]
                    if v_linelength.answer[tok][start + 2] == 2:
                        # check parameter
                        parameter = bytes_to_int_ba(line[v_dev.linelength_len[device] - v_linelength.answer[tok][start + 1]:v_dev.linelength_len[device]])
                        if parameter > v_linelength.answer[tok][start]:
                            clear_dev(device, v_dev.linelength_len[device], 1, 0)
                            error = "dev om / am parameter value too high, loop:" + str(v_dev.linelength_loop[device]) + " " + str(parameter) + " " + str(v_linelength.answer[tok][start])
                            write_log(error)
                            # exit "while loop"
                            break
                        v_dev.linelength_other1[device] = parameter
                    v_dev.linelength_loop[device] += 1
                    if v_dev.linelength_loop[device] == v_linelength.answer[tok][2]:
                        # all loops done
                        clear_dev(device, v_dev.linelength_len[device], 0, tok)
                        device += 1
                        break
                    else:
                        # add next linelength
                        if v_dev.linelength_loop[device] == 2:
                            v_dev.linelength_len[device] += v_dev.linelength_other1[device]
                        else:
                            v_dev.linelength_len[device] += v_linelength.answer[tok][start + 4]
                else:
                    # not enough bytes
                    device += 1
# end am string
# start an numeric
            elif line_length_index_0 == "3":
                if v_dev.start_time[device] == 0:
                    # start timeout
                    v_dev.start_time[device] = time.time()
                if v_dev.linelength_loop[device] == 0:
                    v_dev.linelength_len[device] = v_linelength.answer[tok][1]
                while len(line) >= v_dev.linelength_len[device]:
                    # startindex of block (of v_linelength.answer[tok])
                    start = 4 + 3 * v_dev.linelength_loop[device]
                    if v_linelength.answer[tok][start + 2] == 2:
                        # check parameter
                        parameter = bytes_to_int_ba(line[v_dev.linelength_len[device] - v_linelength.answer[tok][start + 1]:v_dev.linelength_len[device]])
                        if parameter > v_linelength.answer[tok][start]:
                            clear_dev(device, v_dev.linelength_len[device], 1, 0)
                            error = "on an value too high, loop:" + str(v_dev.linelength_loop[device]) + " " + str(parameter) + " " + str(v_linelength.answer[tok][start])
                            write_log(error)
                            # exit "while loop"
                            break
                        if v_dev.linelength_loop[device] == 1:
                            # remember next length (number of elements * length of element
                            v_dev.linelength_other[device] = parameter * v_linelength.answer[tok][start + 4]

                    v_dev.linelength_loop[device] += 1
                    if v_dev.linelength_loop[device] == v_linelength.answer[tok][2]:
                        # all loops done
                        clear_dev(device, v_dev.linelength_len[device], 0, tok)
                        device += 1
                        break
                    else:
                        # add next linelength
                        if v_dev.linelength_loop[device] == 2:
                            v_dev.linelength_len[device] += v_dev.linelength_other[device]
                        else:
                            # add next linelength (+3+2)
                            v_dev.linelength_len[device] += v_linelength.answer[tok][start + 4]
                else:
                    # not enough bytes
                    device += 1
# end an numeric
# start an string
            elif line_length_index_0 == "4":
                if v_dev.start_time[device] == 0:
                    # start timeout
                    v_dev.start_time[device] = time.time()
                if v_dev.linelength_loop[device] == 0:
                    v_dev.linelength_len[device] = v_linelength.answer[tok][1]
                while len(line) >= v_dev.linelength_len[device]:
                    # startindex of block (of v_linelength.answer[tok])
                    start = 4 + 3 * v_dev.linelength_loop[device]
                    if v_linelength.answer[tok][start + 2] == 2:
                        # check parameter
                        parameter = bytes_to_int_ba(line[v_dev.linelength_len[device] - v_linelength.answer[tok][
                            start + 1]:v_dev.linelength_len[device]])
                        if parameter > v_linelength.answer[tok][start]:
                            clear_dev(device, v_dev.linelength_len[device], 1, 0)
                            error = "on an value too high, loop:" + str(v_dev.linelength_loop[device]) + " " + str(
                                parameter) + " " + str(v_linelength.answer[tok][start])
                            write_log(error)
                            # exit "while loop"
                            break
                        if v_dev.linelength_loop[device] == 1:
                            # remember number of elements
                            v_dev.linelength_other[device] = parameter
                        if v_dev.linelength_loop[device] == 2 or v_dev.linelength_loop[device] == 4:
                            # remember length of string
                            v_dev.linelength_other1[device] = parameter

                    v_dev.linelength_loop[device] += 1
                    if v_dev.linelength_loop[device] == 6:
                        v_dev.linelength_loop[device] = 4
                    # add next linelength
                    if v_dev.linelength_loop[device] == 1:
                        v_dev.linelength_len[device] += v_linelength.answer[tok][8]
                    elif v_dev.linelength_loop[device] == 2 or v_dev.linelength_loop[device] == 4:
                        if v_dev.linelength_loop[device] > 1:
                            if v_dev.linelength_other[device] < 1:
                                # all elements done
                                clear_dev(device, v_dev.linelength_len[device], 0, tok)
                                device += 1
                                break
                            v_dev.linelength_other[device] -= 1
                        # add length of stringlength
                        v_dev.linelength_len[device] += v_linelength.answer[tok][11]
                    elif v_dev.linelength_loop[device] == 3 or v_dev.linelength_loop[device] == 5:
                        # add length of string
                        v_dev.linelength_len[device] += v_dev.linelength_other1[device]
                else:
                    # not enough bytes
                    device += 1
# end an string
# start af numeric
            elif line_length_index_0 == "5":
                if v_dev.start_time[device] == 0:
                    # start timeout
                    v_dev.start_time[device] = time.time()
                if v_dev.linelength_loop[device] == 0:
                    v_dev.linelength_len[device] = v_linelength.answer[tok][1]
                while len(line) >= v_dev.linelength_len[device]:
                    # one check in loop 0 only
                    if v_dev.linelength_loop[device] == 0:
                        # check parameter
                        parameter = bytes_to_int_ba(line[v_dev.linelength_len[device] - v_linelength.answer[tok][5]:v_dev.linelength_len[device]])
                        if parameter > v_linelength.answer[tok][4]:
                            clear_dev(device, v_dev.linelength_len[device], 1, 0)
                            error = "on an value too high, loop:" + str(v_dev.linelength_loop[device]) + " " + str(parameter) + " " + str(v_linelength.answer[tok][4])
                            write_log(error)
                            # exit "while loop"
                            break
                        if v_dev.linelength_loop[device] == 0:
                            # remember next length (number of elements * length of element
                            v_dev.linelength_other[device] = parameter * v_linelength.answer[tok][8]

                    v_dev.linelength_loop[device] += 1
                    if v_dev.linelength_loop[device] == 2:
                        # all loops done
                        clear_dev(device, v_dev.linelength_len[device], 0, tok)
                        device += 1
                        break
                    else:
                        # add next linelength
                        # v_dev.linelength_loop[device] == 1
                        v_dev.linelength_len[device] += v_dev.linelength_other[device]
                else:
                    # not enough bytes
                    device += 1
# end af numeric
# start af string
            elif line_length_index_0 == "6":
                if v_dev.start_time[device] == 0:
                    # start timeout
                    v_dev.start_time[device] = time.time()
                if v_dev.linelength_loop[device] == 0:
                    v_dev.linelength_len[device] = v_linelength.answer[tok][1]
                while len(line) >= v_dev.linelength_len[device]:
                    # startindex of block (of v_linelength.answer[tok])
                    start = 4 + 3 * v_dev.linelength_loop[device]
                    if v_linelength.answer[tok][start + 2] == 2:
                        # check parameter
                        parameter = bytes_to_int_ba(line[v_dev.linelength_len[device] - v_linelength.answer[tok][start + 1]:v_dev.linelength_len[device]])
                        if parameter > v_linelength.answer[tok][start]:
                            clear_dev(device, v_dev.linelength_len[device], 1, 0)
                            error = "on an value too high, loop:" + str(v_dev.linelength_loop[device]) + " " + str(parameter) + " " + str(v_linelength.answer[tok][start])
                            write_log(error)
                            # exit "while loop"
                            break
                        if v_dev.linelength_loop[device] == 0:
                            # remember number of elements
                            v_dev.linelength_other[device] = parameter
                        if v_dev.linelength_loop[device] == 1 or v_dev.linelength_loop[device] == 3:
                            # remember length of string
                            v_dev.linelength_other1[device] = parameter

                    v_dev.linelength_loop[device] += 1
                    if v_dev.linelength_loop[device] == 5:
                        v_dev.linelength_loop[device] = 3
                    # add next linelength
                    if v_dev.linelength_loop[device] == 1 or v_dev.linelength_loop[device] == 3:
                        if v_dev.linelength_loop[device] > 0:
                            if v_dev.linelength_other[device] < 1:
                                # all elements done
                                clear_dev(device, v_dev.linelength_len[device], 0, tok)
                                device += 1
                                break
                            v_dev.linelength_other[device] -= 1
                        # add length of stringlength
                        v_dev.linelength_len[device] += v_linelength.answer[tok][8]
                    else:
                        # add length of string
                        v_dev.linelength_len[device] += v_dev.linelength_other1[device]
                else:
                    # not enough bytes
                    device += 1
# end af string
# start aa
            elif line_length_index_0 == "7":
                if v_dev.start_time[device] == 0:
                    # start timeout
                    v_dev.start_time[device] = time.time()
                if v_dev.linelength_loop[device] == 0:
                    v_dev.linelength_len[device] = v_linelength.answer[tok][1]
                while len(line) >= v_dev.linelength_len[device]:
                    if v_linelength.answer[tok][2] == 0:
                        # 0: no position parameter
                        if v_linelength.answer[tok][6] == 1:
                            # numeric, no check, got all data
                            clear_dev(device, v_dev.linelength_len[device], 0, tok)
                            device += 1
                            break
                        else:
                            # string
                            if v_dev.linelength_loop[device] == 1:
                                # all elements done
                                clear_dev(device, v_dev.linelength_len[device], 0, tok)
                                device += 1
                                break
                            if v_linelength.answer[tok][6] == 3:
                                # check length of stringlength (loop 0)
                                parameter = bytes_to_int_ba(line[v_dev.linelength_len[device] - v_linelength.answer[tok][5]:v_dev.linelength_len[device]])
                                if parameter > v_linelength.answer[tok][4]:
                                    error = "dev aa parameter value too high, loop:" + str(v_dev.linelength_loop[device]) + " " + str(parameter) + " " + str(v_linelength.answer[tok][4])
                                    write_log(error)
                                    clear_dev(device, v_dev.linelength_len[device], 1, tok)
                                    device += 1
                                    # exit "while loop"
                                    break
                                v_dev.linelength_len[device] += parameter
                                v_dev.linelength_loop[device] += 1
                            else:
                                # all elements done
                                clear_dev(device, v_dev.linelength_len[device], 0, tok)
                                device += 1
                                break
                    else:
                        # 1: with position parameter
                        if v_dev.linelength_loop[device] == 0:
                            v_dev.linelength_len[device] = v_linelength.answer[tok][1]
                            parameter = bytes_to_int_ba(line[v_dev.linelength_len[device] - v_linelength.answer[tok][5]:v_dev.linelength_len[device]])
                            if parameter > v_linelength.answer[tok][4]:
                                error = "dev aa parameter value too high, loop:" + str(v_dev.linelength_loop[device]) + " " + str(v_dev.linelength_other[device]) + " " + str(v_linelength.answer[tok][4])
                                write_log(error)
                                clear_dev(device, v_dev.linelength_len[device], 1, tok)
                                device += 1
                                # exit "while loop"
                                break
                            # remember the element to transfer (position in v_linelength)
                            v_dev.linelength_other[device] = 7 + parameter * 3
                            # add length of numeric or length of stringlength
                            print(v_linelength.answer[tok],parameter,"360")
                            v_dev.linelength_len[device] += v_linelength.answer[tok][8 + parameter * 3]
                        else:
                            # loop == 1 or == 2
                            if v_linelength.answer[tok][v_dev.linelength_other[device] + 2] == 1:
                                # numeric, ready now
                                clear_dev(device, v_dev.linelength_len[device], 0, tok)
                                device += 1
                                break
                            else:
                                # string
                                if v_dev.linelength_loop[device] == 1:
                                    # check length of stringlength
                                    parameter = bytes_to_int_ba(line[v_dev.linelength_len[device] - v_linelength.answer[tok][5]:v_dev.linelength_len[device]])
                                    if v_dev.linelength_other1[device] > v_linelength.answer[tok][4]:
                                        error = "SK oa / aa parameter value too high, loop:" + str(v_dev.linelength_loop[device]) + " " + str(v_dev.linelength_other[device]) + " " + str(v_linelength.answer[tok][4])
                                        write_log(error)
                                        clear_dev(device, v_dev.linelength_len[device], 1, tok)
                                        device += 1
                                        # exit "while loop"
                                        break
                                    v_dev.linelength_len[device] += parameter
                                else:
                                    # all elements done
                                    clear_dev(device, v_dev.linelength_len[device], 0, tok)
                                    device += 1
                                    break
                        v_dev.linelength_loop[device] += 1
                else:
                    # not enough bytes
                    device += 1
# end aa
# start ab
            elif line_length_index_0 == "8":
                if v_dev.start_time[device] == 0:
                    # set time for timeout
                    v_dev.start_time[device] = time.time()
                if v_dev.linelength_loop[device] == 0:
                    v_dev.linelength_len[device] = v_linelength.answer[tok][1]
                while len(line) >= v_dev.linelength_len[device]:
                    # startindex of block (of v_linelength.command[tok])
                    if v_dev.linelength_loop[device] == 0:
                        # check parameter of startelement
                        parameter = bytes_to_int_ba(line[v_dev.linelength_len[device] - v_linelength.answer[tok][5]:v_dev.linelength_len[device]])
                        if parameter > v_linelength.answer[tok][4]:
                            error = "dev ob / ab startelement parameter value too high:" + str(parameter) + " " + str(v_linelength.answer[tok][4])
                            write_log(error)
                            clear_dev(device, v_dev.linelength_len[device], 1, tok)
                            device += 1
                            # exit "while loop"
                            break
                        # remember start elements
                        v_dev.linelength_other[device] = parameter
                        v_dev.linelength_loop[device] += 1
                        v_dev.linelength_len[device] += v_linelength.answer[tok][5]
                    if v_dev.linelength_loop[device] == 1:
                        # check parameter of number of elements
                        parameter = bytes_to_int_ba(
                            line[v_dev.linelength_len[device] - v_linelength.answer[tok][8]:v_dev.linelength_len[device]])
                        if parameter == 0 or parameter > v_linelength.answer[tok][7]:
                            error = "dev ob / ab number of elements parameter 0 or value too high:" + str(parameter) + " " + str(v_linelength.answer[tok][7])
                            write_log(error)
                            clear_dev(device, v_dev.linelength_len[device], 1, tok)
                            device += 1
                            # exit "while loop"
                            break
                        # remember number of elements
                        v_dev.linelength_other1[device] = parameter
                        v_dev.linelength_loop[device] += 1
                        # add length of 1st element or length of stringlength; linelength_other == 0 start with position 10
                        v_dev.linelength_len[device] += v_linelength.answer[tok][3 * v_dev.linelength_other[device] + 11]
                        if v_linelength.answer[tok][3 * v_dev.linelength_other[device] + 12] == 3:
                            # string
                            v_dev.linelength_loop[device] = 3
                    elif v_dev.linelength_loop[device] == 2:
                        v_dev.linelength_other1[device] -= 1
                        if v_dev.linelength_other1[device] <= 0:
                            # all elements done
                            clear_dev(device, v_dev.linelength_len[device], 0, tok)
                            device += 1
                            break
                        else:
                            # add numeric numeric or length of stringlength:
                            v_dev.linelength_other[device] += 1
                            if v_dev.linelength_other[device] == v_linelength.answer[tok][4]:
                                # overflow
                                v_dev.linelength_other[device] = 0
                            start = 3 * v_dev.linelength_other[device] + 11
                            v_dev.linelength_len[device] += v_linelength.answer[tok][start]
                            if v_linelength.answer[tok][start + 1] == 3:
                                # string
                                v_dev.linelength_loop[device] = 3
                    else:
                        # v_dev.linelength_loop = 3, got length of stringlength
                        # check parameter
                        start = 10 + 3 * v_dev.linelength_other[device]
                        parameter = bytes_to_int_ba(line[v_dev.linelength_len[device] - v_linelength.answer[tok][start + 1]:v_dev.linelength_len[device]])
                        if parameter > v_linelength.answer[tok][start]:
                            error = "dev ob / ab length of stringlenth parameter value too high:" + str(parameter) + " " + str(v_linelength.answer[tok][start])
                            write_log(error)
                            clear_dev(device, v_dev.linelength_len[device], 1, tok)
                            device += 1
                            # exit "while loop"
                            break
                        v_dev.linelength_len[device] += parameter
                        v_dev.linelength_loop[device] = 2
                else:
                    # not enough bytes
                    device += 1
# end ab
            else:
                # other ("0") v_linelength.answer[0]
                clear_dev(device, v_dev.length_commandtoken[device], 1, tok)
                device += 1
                break
        else:
            # major error, clear all
            write_log("dev, no vaid token")
            v_dev.data_to_CR[device] = bytearray([])
            device += 1
    return


def clear_dev(device, delete, error, tok):
    if error == 0:
        # tranfer to sk infobuffer
        # add tok
        v_sk.info_to_all.extend(int_to_ba(tok, v_cr_params.length_commandtoken))
        # add rest of line
        v_sk.info_to_all.extend(v_dev.data_to_CR[device][v_dev.length_commandtoken[device]:v_dev.length_commandtoken[device] + delete])
        # add length of device-commandtoken
        v_dev.data_to_CR[device] = v_dev.data_to_CR[device][delete + v_dev.length_commandtoken[device]:]
    else:
        # clear all data
        v_dev.data_to_CR[device] = bytearray([])
    v_dev.input_device[device] = 0
    v_dev.linelength_len[device] = 0
    v_dev.start_time[device] = 0
    v_dev.linelength_loop[device] = 0
    v_dev.linelength_other[device] = 0
    v_dev.linelength_other1[device] = 0
    return

"""
name : commandrouter_device_handling.py
devicehandling subprograms
# analyzes the answers and info and transfer to SK devices buffers
"""


import time

from cr_own_commands import *
from misc_functions import *

import v_announcelist
import v_dev
import v_linelength
import v_sk
import v_token_params


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
            tok = v_dev.dev_cr_tok[device][device_tokennumber]
            if v_linelength.answer[tok] == "0":
                # device cannot send command answer : due to some error before
                clear_dev(device, v_dev.length_commandtoken[device], 1, 0,)
                device += 1
                break
            # got valid token now
            if v_dev.start_time[device] == 0:
                # start timeout
                v_dev.start_time[device] = time.time()
            while len(line) >= v_dev.linelength_len[device]:
                # 1st call:
                if v_dev.linelength_actual_call[device] == 0:
                    # 1st call, valid for all commandtypes
                    # v_linelength_len is without length of command-token
                    v_dev.linelength_len[device] = v_linelength.answer[tok][1] + v_dev.length_commandtoken[device]
                    v_dev.linelength_actual_call[device] = 1

# start switches,range commands and numeric om, am. no real time length calculation
                elif v_linelength.answer[tok][0] == "1":
                    if v_linelength.answer[tok][2] == 0:
                        # got all
                        clear_dev(device, v_dev.linelength_len[device], 0, tok)
                        device += 1
                        break
                    else:
                        error = 0
                        # check parameter , number of parameter + 2 -> index to v_linelength.command[tok]
                        block = 0
                        temp = v_dev.linelength_len[device]
                        temp_new = temp
                        # index of 1 block (start)
                        par_index = 3
                        while block < v_linelength.answer[tok][2]:
                            # add length
                            length = v_linelength.answer[tok][par_index + 1]
                            temp_new += length
                            if v_linelength.answer[tok][par_index] > 0:
                                # skip check if 0
                                if bytes_to_int_ba(line[temp:temp_new]) > v_linelength.answer[tok][par_index]:
                                    v_dev.linelength_len[device] = temp_new
                                    clear_dev(device, v_dev.linelength_len[device], 1, tok)
                                    error = "device parameter value too high"
                                    write_log(error)
                                    error = 1
                                    break
                            block += 1
                            temp = temp_new
                            par_index += 2
                        if error == 0:
                            v_dev.linelength_len[device] = temp_new
                            clear_dev(device, v_dev.linelength_len[device], 0, tok)
                        device += 1
                        break
# end witches,range commands and numeric om, am. no real time length calculation
# start om / am string
                elif v_linelength.answer[tok][0] == "2":
                    # 2nd call:
                    if v_dev.linelength_actual_call[device] == 1:
                        # got position, length of stringlength, add  stringlength
                        temp = v_dev.linelength_len[device]
                        # start of stringlength
                        temp1 = temp - v_linelength.answer[tok][6]
                        # start of position
                        position = int.from_bytes(line[temp1 - v_linelength.answer[tok][4]:temp1], byteorder='big', signed=False)
                        if position > v_linelength.answer[tok][3]:
                            # position overflow, tok, info
                            clear_dev(device, v_dev.linelength_len[device], 1, tok)
                            # to log:
                            error = "position overflow"
                            write_log(error)
                            device += 1
                            break
                        else:
                            stringlength = int.from_bytes(line[temp - v_linelength.answer[tok][6]:temp], byteorder='big', signed=False)
                            # check stringlength
                            if stringlength > v_linelength.answer[tok][5]:
                                # string overflow, tok, info
                                clear_dev(device, v_dev.linelength_len[device], 1, tok)
                                # to log:
                                error = "stringlength overflow"
                                write_log(error)
                                device += 1
                                break
                        v_dev.linelength_len[device] += stringlength
                        v_dev.linelength_actual_call[device] = 3
                    else:
                        # v_dev.linelength_actual_call[device] = 3:
                        # got all data
                        clear_dev(device, v_dev.linelength_len[device], 0, tok)
                        device += 1
                        break
# end om / am string
# start on / an
                elif v_linelength.answer[tok][0] == "3":
                    if v_dev.linelength_actual_call[device] == 1:
                        #  got commandtoken + 2 * positionlength
                        # check startelement and number of elements
                        # commandtoken:
                        temp1 = v_cr_params.length_commandtoken
                        # add length of startposition
                        temp2 = temp1 + v_linelength.answer[tok][3]
                        startposition = int.from_bytes(line[temp1:temp2], byteorder='big', signed=False)
                        if startposition > v_linelength.answer[tok][2]:
                            clear_dev(device, v_dev.linelength_len[device], 1, 0)
                            error = "position overflow"
                            write_log(error)
                            device += 1
                            break
                        else:
                            if v_linelength.answer[tok][7] == 0:
                                # on / an
                                # add length of number of elements
                                temp1 = temp2 + v_linelength.answer[tok][3]
                                elements = int.from_bytes(line[temp2:temp1], byteorder='big', signed=False)
                                if elements > v_linelength.answer[tok][2]:
                                    clear_dev(device, v_dev.linelength_len[device], 1, 0)
                                    error = "too many elements"
                                    write_log(error)
                                    device += 1
                                    break
                            else:
                                # of / af: there is no startposition
                                elements = startposition
                        if v_linelength.answer[tok][6] == 0:
                            # numeric:
                            # add elements * length of element
                            v_dev.linelength_len[device] += elements * v_linelength.answer[tok][5]
                            v_dev.linelength_actual_call[device] = 2
                        else:
                            # string:
                            # remember the elements to follow
                            v_dev.linelength_other[device] = elements
                            # add length of stringlength
                            v_dev.linelength_len[device] += v_linelength.answer[tok][5]
                            v_dev.linelength_actual_call[device] = 3
                    elif v_dev.linelength_actual_call[device] == 2:
                        # got everything: numeric operate
                        clear_dev(device, v_dev.linelength_len[device], 0, tok)
                        device += 1
                        break

                    elif v_dev.linelength_actual_call[device] == 3:
                        # string: extract stringlength
                        temp2 = v_dev.linelength_len[device]
                        temp1 = temp2 - v_linelength.answer[tok][5]
                        stringlength = int.from_bytes(line[temp1:temp2], byteorder='big', signed=False)
                        if stringlength > v_linelength.answer[tok][4]:
                            clear_dev(device, v_dev.linelength_len[device], 1, 0)
                            error = "string overflow"
                            write_log(error)
                            device += 1
                            break
                        v_dev.linelength_len[device] += stringlength
                        v_dev.linelength_actual_call[device] = 4
                    elif v_dev.linelength_actual_call[device] == 4:
                        # actual element
                        v_dev.linelength_other[device] -= 1
                        if v_dev.linelength_other[device] == 0:
                            # finish
                            clear_dev(device, v_dev.linelength_len[device], 0, tok)
                            device += 1
                            break
                        else:
                            # add length of stringlength
                            v_dev.linelength_len[device] += v_linelength.answer[tok][3]
                            v_dev.linelength_actual_call[device] = 3
# end on / an
# start oa / aa
                elif v_linelength.answer[tok][0] == "4":
                    if v_dev.linelength_actual_call[device] == 1:
                        # got dev-commandtoken + memoryposition
                        # memoryposition
                        position = 0
                        if v_linelength.answer[tok][2] > 1:
                            # position transmitted
                            position = int.from_bytes(line[v_dev.linelength_len[device] - v_linelength.answer[tok][3]:v_dev.linelength_len[device]], byteorder='big', signed=False)
                            if position > v_linelength.answer[tok][2]:
                                clear_dev(device, v_dev.linelength_len[device], 1, 0)
                                error = "position overflow" + " " + str(position) + " " + str(v_linelength.answer[tok][2])
                                write_log(error)
                                device += 1
                                break
                        # data correct
                        # add length of <ty> or length of sringlength
                        v_dev.linelength_len[device] += v_linelength.answer[tok][3 * position + 5]
                        # remember position
                        v_dev.linelength_other[device] = position
                        if v_linelength.answer[tok][3 * position + 6] == 0:
                            # numeric
                            v_dev.linelength_actual_call[device] = 2
                        else:
                            # string
                            v_dev.linelength_actual_call[device] = 3
                    elif v_dev.linelength_actual_call[device] == 2:
                        # finish numeric
                        clear_dev(device, v_dev.linelength_len[device], 0, tok)
                        device += 1
                        break
                    elif v_dev.linelength_actual_call[device] == 3:
                        # got stringlength now
                        # stringlength:
                        # length of stringlength
                        l_string_length = v_linelength.answer[tok][3 * v_dev.linelength_other[device] + 5]
                        stringlength = int.from_bytes(line[v_dev.linelength_len[device] - l_string_length:v_dev.linelength_len[device]], byteorder='big', signed=False)
                        if stringlength > v_linelength.answer[tok][3 * v_dev.linelength_other[device] + 4]:
                            clear_dev(device, v_dev.linelength_len[device], 1, 0)
                            error = "string overflow"
                            write_log(error)
                            device += 1
                            break
                        # add number of bytes of string
                        v_dev.linelength_len[device] += stringlength
                        v_dev.linelength_actual_call[device] = 4
                    elif v_dev.linelength_actual_call[device] == 4:
                        clear_dev(device, v_dev.linelength_len[device], 0, tok)
                        device += 1
                        break
# end oa / aa
# start ob /ab
                elif v_linelength.answer[tok][0] == "5":
                    if v_dev.linelength_actual_call[device] == 1:
                        # got commandtoken (+ startpos + number of elements)
                        # startposition and elements available
                        temp1 = v_cr_params.length_commandtoken
                        # check elements and startpositiion
                        temp2 = temp1 + v_linelength.answer[tok][3]
                        startposition = int.from_bytes(line[temp1:temp2], byteorder='big', signed=False)
                        if startposition > v_linelength.answer[tok][2]:
                            clear_dev(device, v_dev.linelength_len[device], 1, 0)
                            error = "startposition value too high " + str(startposition) + " " + str(v_linelength.answer[tok][2])
                            write_log(error)
                            device += 1
                            break
                        else:
                            # add length of number of elements
                            temp1 = temp2 + v_linelength.answer[tok][3]
                            elements = int.from_bytes(line[temp2:temp1], byteorder='big', signed=False)
                            if elements > v_linelength.answer[tok][2]:
                                clear_dev(device, v_dev.linelength_len[device], 1, 0)
                                error = "element value too high " + str(elements) + " " + str(v_linelength.answer[tok][2])
                                write_log(error)
                                device += 1
                                break
                        # position data correct
                        if elements > 0:
                            #  add length of <ty> or length of sringlength of first element
                            # 2nd element (1) of n block 3 *n + 4 + 1 (n 0...x)
                            v_dev.linelength_len[device] += v_linelength.answer[tok][3 * startposition + 5]
                            # remember position
                            # v_linelength.answer block number for startnumenr and number of elements
                            v_dev.linelength_other[device] = startposition
                            v_dev.linelength_other1[device] = elements
                            # 3rd element (2) of n block 3 *n + 1 + 2
                            if v_linelength.answer[tok][3 * startposition + 6] == 0:
                                # numeric
                                v_dev.linelength_actual_call[device] = 2
                            else:
                                # string
                                v_dev.linelength_actual_call[device] = 3
                        else:
                            clear_dev(device, v_dev.linelength_len[device], 0, tok)
                            device += 1
                            break
                    elif v_dev.linelength_actual_call[device] == 2:
                        # got numeric element
                        # elements:
                        v_dev.linelength_other1[device] -= 1
                        if v_dev.linelength_other1[device] == 0:
                            # finish numeric
                            clear_dev(device, v_dev.linelength_len[device], 0, tok)
                            device += 1
                            break
                        else:
                            # next position
                            v_dev.linelength_other[device] += 1
                            # if index >= number of elements !!
                            if v_dev.linelength_other[device] >= v_linelength.answer[tok][2]:
                                # overflow
                                v_dev.linelength_other[device] = 0
                            # add length of <ty> or length of linelength
                            v_dev.linelength_len[device] += v_linelength.answer[tok][3 * v_dev.linelength_other[device] + 5]
                            if v_linelength.answer[tok][3 * v_dev.linelength_other[device] + 6] == 1:
                                # string
                                v_dev.linelength_actual_call[device] = 3
                                # else: v_dev.linelength_actual_call[device] = 2
                    elif v_dev.linelength_actual_call[device] == 3:
                        # add stringlength
                        # v_dev.linelength_len[device] += v_linelength.answer[tok][3 * v_dev.linelength_other[device] + 5]
                        v_dev.linelength_actual_call[device] = 4
                    elif v_dev.linelength_actual_call[device] == 4:
                        # got length of next string element
                        stringlength = int.from_bytes(line[v_dev.linelength_len[device] - v_linelength.answer[tok][3]:v_dev.linelength_len[device]], byteorder='big',signed=False)
                        if stringlength > v_linelength.answer[tok][3 * v_dev.linelength_other[device] + 4]:
                            # string overflow
                            clear_dev(device, v_dev.linelength_len[device], 1, 0)
                            error = "stringlength overflow "
                            write_log(error)
                            device += 1
                            break
                        # add number of bytes of string
                        v_dev.linelength_len[device] += stringlength
                        v_dev.linelength_actual_call[device] = 5
                    elif v_dev.linelength_actual_call[device] == 5:
                        # elements
                        v_dev.linelength_other1[device] -= 1
                        if v_dev.linelength_other1[device] == 0:
                            # elements done
                            clear_dev(device, v_dev.linelength_len[device], 0, tok)
                            device += 1
                            break
                        else:
                            # get length of next element
                            # increment position in v_linelength
                            v_dev.linelength_other[device] += 1
                            # if index >= number of elements !!
                            if v_dev.linelength_other[device] >= v_linelength.answer[tok][2]:
                                v_dev.linelength_other[device] = 0
                            # add next length of <ty> or length of stringlength
                            v_dev.linelength_len[device] += v_linelength.answer[tok][3 * v_dev.linelength_other[device] + 5]
                            if v_linelength.answer[tok][3 * v_dev.linelength_other[device] + 6] == 0:
                                # next element numeric
                                v_dev.linelength_actual_call[device] = 2
                            else:
                                v_dev.linelength_actual_call[device] = 3
# end ob / ab
                else:
                    # other ("0") v_linelength.answer[0]
                    clear_dev(device, v_dev.linelength_len[device], 1, tok)
                    device += 1
                    break
        else:
            # major error, clear all
            v_dev.data_to_CR[device] = bytearray([])
            device += 1
    return


def clear_dev(device, delete, error, tok):
    if error == 0:
        # tranfer to sk infobuffer
        # replace device_token by tok
        temp = bytearray([])
        temp.extend(int_to_ba(tok, v_cr_params.length_commandtoken))
        # add rest
        temp.extend(v_dev.data_to_CR[device][v_dev.length_commandtoken[device]:v_dev.linelength_len[device]])
        v_sk.info_to_all.extend(temp)
        v_dev.data_to_CR[device] = v_dev.data_to_CR[device][delete:]
    else:
        # clear all data
        v_dev.data_to_CR[device] = bytearray([])
    v_dev.input_device[device] = 0
    v_dev.linelength_len[device] = 0
    v_dev.linelength_actual_call[device] = 0
    v_dev.start_time[device] = 0
    return

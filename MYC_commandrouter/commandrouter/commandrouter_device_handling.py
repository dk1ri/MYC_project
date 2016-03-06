"""
devicehandling subprograms
# analyzes the answers and info and transfer to input devices (HI...)
"""


from commandrouter_analyze_linelength import *
from commandrouter_misc_functions import *
import v_dev_devtoken_for_crtoken
import v_device_buffer


def reset_device_buffer(device):
    # reset device_buffer[x]
    # actual commandtoken in work, 0, nothing actual
    v_device_buffer.actual_device_token[device] = 0
    # actual need to wait for answer?
    v_device_buffer.wait_for_answer[device] = 0
    # answer buffer
    v_device_buffer.data_to_CR[device] = ""
    return


def poll_device_buffer():
    # analyze data from device for completeness to transfer for HI,PR
    # the input may occur in a way, that more than one loop are necessary to finish a answer or info.
    # or a answer or info may be complete immediately. in this case, the handling should be completed
    # before switching to the next device
    device_index = 0
    # check all devices
    for line in v_device_buffer.data_to_CR:
        # nothing to do
        if line == "":
            continue
        # info
        if v_device_buffer.wait_for_answer[device_index] == 0:
            # wait for complete commandtoken
            if len(line) < v_device_buffer.commandtokenlength[device_index]:
                # not enough bytes, exit the loop, go to next device
                continue
            full_line = line
            # line without commandtoken
            line = line[v_device_buffer.commandtokenlength[device_index]:]
            # 0 only, before devicetoken is detected
            if v_device_buffer.bytenumber_for_next_action[device_index] == 0:
                device_tokennumber = bytes_to_int(full_line[:v_device_buffer.commandtokenlength[device_index]])
                # usually should be true
                if device_tokennumber in v_device_buffer.all_comandtoken[device_index]:
                    # got valid device token now
                    v_device_buffer.actual_device_token[device_index] = device_tokennumber
                    dev_command_string = str(device_index) + ";" + str(v_device_buffer.actual_device_token[device_index])
                    # find cr token for device and devicecommand
                    cr_token = v_dev_devtoken_for_crtoken.a[dev_command_string]
                    v_device_buffer.actual_CR_token_index[device_index] = cr_token
                    # linelength info is indexed by CR tokennumber
                    error, outstanding, v_device_buffer.answer_info_finished[device_index] = analyze_length(line, device_index, cr_token, "i")
                    v_device_buffer.elementnumber[device_index] += 1
                    v_device_buffer.bytenumber_for_next_action[device_index] = outstanding + v_device_buffer.commandtokenlength[device_index]
                # should not happen, if device works correct
                else:
                    clear_device_buffer(device_index, v_device_buffer.commandtokenlength[device_index], 0)
                    # next device
                    continue
            i = v_device_buffer.bytenumber_for_next_action[device_index]
            # everything finished
            if len(full_line) >= i and v_device_buffer.answer_info_finished[device_index] == 1:
                # transfer up to position i -1
                transfer_to_cr(device_index, full_line, i)
                # delete all up  to position i - 1
                clear_device_buffer(device_index, i, 0)
                # goto next device
                continue
            # bytes missing
            if len(full_line) < i:
                # goto next device
                continue
            # finished and got all data
            if v_device_buffer.answer_info_finished[device_index] == 1 and len(full_line) == v_device_buffer.bytenumber_for_next_action[device_index]:
                # transfer up to position i -1
                transfer_to_cr(device_index, full_line, i)
                # delete all up  to position i - 1
                clear_device_buffer(device_index, v_device_buffer.bytenumber_for_next_action[device_index] - 1, 0)
                # exit while loop: next device
                break
            else:
                if v_device_buffer.answer_info_finished[device_index] == 1:
                    # data missing
                    if i < v_device_buffer.bytenumber_for_next_action[device_index]:
                        i += 1
                        continue
                # not finished
                else:
                    cr_token = v_device_buffer.actual_CR_token_index[device_index]
                    error, outstanding, v_device_buffer.answer_info_finished[device_index] = analyze_length(line, device_index, cr_token, "i")
                    v_device_buffer.elementnumber[device_index] += 1
                    v_device_buffer.bytenumber_for_next_action[device_index] = outstanding + v_device_buffer.commandtokenlength[device_index]
                    i = v_device_buffer.bytenumber_for_next_action[device_index]
                    continue
        # answer
        else:
            # 0 only at atart
            if v_device_buffer.bytenumber_for_next_action[device_index] == 0:
                # is set by inputbuffer routine
                cr_token = v_device_buffer.actual_CR_token_index[device_index]
                # linelength info is indexed by CR tokennumber
                error, outstanding, v_device_buffer.answer_info_finished[device_index] = analyze_length(line, device_index, cr_token, "a")
                v_device_buffer.elementnumber[device_index] += 1
                v_device_buffer.bytenumber_for_next_action[device_index] = outstanding

            i = v_device_buffer.bytenumber_for_next_action[device_index]
            # everything finished
            if len(line) >= i and v_device_buffer.answer_info_finished[device_index] == 1:
                transfer_to_cr(device_index, line, i)
                # delete the commandtoken
                clear_device_buffer(device_index, i, 0)
                # goto next device
                continue
            # bytes missing
            if len(line) < i:
                # goto next device
                continue
            # finished and got all data
            if v_device_buffer.answer_info_finished[device_index] == 1 and len(line) == v_device_buffer.bytenumber_for_next_action[device_index - 1]:
                transfer_to_cr(device_index, line, i)
                # delete the commandtoken
                clear_device_buffer(device_index, v_device_buffer.bytenumber_for_next_action[device_index] - 1, 0)
                # next device
                break
            else:
                if v_device_buffer.answer_info_finished[device_index] == 1:
                    if i < v_device_buffer.bytenumber_for_next_action[device_index]:
                        i += 1
                        continue
                # not finished
                else:
                    # find cr token for device and devicecommand
                    cr_token = v_device_buffer.actual_CR_token_index[device_index]
                    error, outstanding, v_device_buffer.answer_info_finished[device_index] = analyze_length(line, device_index, cr_token, "a")
                    v_device_buffer.elementnumber[device_index] += 1
                    i = outstanding
                    v_device_buffer.bytenumber_for_next_action[device_index] = i
                    continue
        device_index += 1
    return


def clear_device_buffer(device_index, delete_to_cr, delete_to_dev):
    # reset some values of v_input_buffer after command finished
    v_device_buffer.actual_CR_token_index[device_index] = 0
    v_device_buffer.data_to_CR[device_index] = v_device_buffer.data_to_CR[device_index][delete_to_cr + 1:]
    v_device_buffer.actual_device_token[device_index] = 0
    v_device_buffer.data_to_device[device_index] = v_device_buffer.data_to_device[device_index][delete_to_dev + 1:]
    v_device_buffer.wait_for_answer[device_index] = 0
    v_device_buffer.bytenumber_for_next_action[device_index] = 0
    v_device_buffer.answer_info_finished[device_index] = 0
    v_device_buffer.stringlength[device_index] = 0
    v_device_buffer.elementnumber[device_index] = 0
    return


def transfer_to_cr(device_index, line, i):
    if i == 0:
        print("no transfer")
    else:
        k = 0
        st = ""
        while k < i:
            st += str(k) + ": " + str(bytes_to_int(line[k])) + " "
            k += 1
        print("to CR transfered bytes:", i, st)
    return

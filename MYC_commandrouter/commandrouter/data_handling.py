"""
name : data_handling.py
last edited: 1803
data handling subprograms for SK, LD and device
"""

from misc_functions import *

# some switches, no parameters
def data_0():
    finish_sk(input_device, user, to_cr)
    return

# switches, range commands. om, on, of numeric, all answer commands
def data_1(line, got_bytes, sk, linelength):
    # sk: len, loop, other1, other2, other3
    # while: reduce latency for block oriented input
    finish = 0
    #  endindex of block (of linelength)
    while got_bytes >= sk[0]:
        sk[1] += 1
        end = 3 + 5 * sk[1]
        parameter = bytes_to_int_ba(line[sk[0] - linelength[end - 3]:sk[0]])
        if linelength[end - 1] == 2 and parameter > linelength[end - 4]:
            write_log("transfertype 1 value too high, loop:" + str(sk[1]) + " " + str(parameter) + " should be " + str(linelength[end - 4]))
            finish = 2
            break
        if linelength[end - 2] == 0:
            # all loops done
            finish = 1
            break

        # next linelength
        if linelength[end] == 0:
            sk[0] = linelength[end - 2]
        elif linelength[end] == 1:
            # om string
            sk[0] += parameter
        else:
            # on numric
            # end + 2: length of parametertype
            sk[0] += parameter * linelength[end + 2]
    # else: not enough bytes
    return sk, finish

# on string
def data_2(line, got_bytes, sk, linelength):
    # sk: len, loop, other1, other2, other3
    finish = 0
    while got_bytes >= sk[0]:
        if sk[1] == 0:
            sk[1] += 1
            parameter = bytes_to_int_ba(line[sk[0] - linelength[5]:sk[0]])
            # test always
            if parameter > linelength[4]:
                write_log("on start value too high:" + str(parameter) + " should be " + str(linelength[5]))
                finish = 2
                break
            sk[0] = linelength[6]
            # remember start
            sk[2] = parameter
        elif sk[1] == 1:
            if linelength[3] == 0:
                # on string
                parameter = bytes_to_int_ba(line[sk[0] - linelength[10]:sk[0]])
                if parameter == 0:
                    # nothing else to transfer
                    finish = 1
                    break
                # test always
                if parameter > linelength[9]:
                    write_log("on length value too high:" + str(parameter) + " should be " + str(linelength[10]))
                    finish = 2
                    break
                # remember number of parameter:
                sk[3] = parameter
                # add stringlength
                sk[0] = linelength[11]
                sk[3] = 0
            sk[1] += 1
        else:
            # data transmission
            if sk[3] == 0:
                # got stringlenth
                parameter = bytes_to_int_ba(line[sk[0] - linelength[ 5  * sk[1]]:sk[0]])
                # test length of string always
                if parameter > linelength[5 * sk[1] - 1]:
                    write_log("on parameter value too high, loop:" + str(sk[1]) + " " + str(parameter) + " should be " + str(linelength[5 * sk[1]] - 1))
                    finish = 2
                    break
                # add length of string
                sk[0] += parameter
                sk[3] = 1
            else:
                # got string
                sk[2] -= 1
                if sk[2] == 0:
                    finish = 1
                    break
                sk[0] += linelength[5 *sk [1]]
                sk[3] = 0

    return sk, finish

# start oa
def data_3(line, got_bytes, sk, linelength):
    # sk: len, loop, other1, other2, other3
    # sk: len, loop, start, number_of_parameters, next num / string
    finish = 0
    while got_bytes >= sk[0]:
        if linelength[3] == 0 and sk[1] == 0:
            # one element only
            sk[1] = 1
            sk[2] = 1
            sk[4] = linelength[8]
        if sk[1] == 0:
            # got position
            sk[1] += 1
            parameter = bytes_to_int_ba(line[sk[0] - linelength[5]:sk[0]])
            # test always
            if parameter > linelength[4]:
                write_log("oa position value too high:" + str(parameter) + " should be " + str(linelength[4]))
                finish = 2
                break
            # remember start
            sk[2] = parameter + 2
            # wait for nueric (0) / stringlength (1)
            end = 3 + 5 * sk[2]
            sk[4] = linelength[end]
            # add stringlength or paramteerlength for next element
            sk[0] += linelength[end - 3]
        else:
            # data transmission
            # now alternate sk[4] = 0,1 or 2
            if sk[4] == 2:
                # string  received: finish
                finish = 1
                break

            end = 3 + 5 * sk[1]
            parameter = bytes_to_int_ba(line[sk[0] - linelength[end - 3]:sk[0]])
            # test always
            if parameter > linelength[end - 4]:
                write_log("oa stringlength or bit value too high:" + str(parameter) + " should be " + str(linelength[end - 4]))
                finish = 2
                break
            if sk[4] == 0:
                # got numeric parameter
                finish = 1
                break
            else:
                # sk[4] == 1:
                sk[0] += parameter
                sk[4] = 2
    return sk, finish

# ob
def data_4(line, got_bytes, sk, linelength):
    # sk: len, loop, start, number_of_parameters, next: num / string
    finish = 0
    while got_bytes >= sk[0]:
        if sk[1] == 0:
            sk[1] = 1
            parameter = bytes_to_int_ba(line[sk[0] - linelength[5]:sk[0]])
            # test always
            if parameter > linelength[4]:
                write_log("ob start value too high:" + str(parameter) + " should be " + str(linelength[4]))
                finish = 2
                break
            sk[0] = linelength[6]
            # remember start
            sk[2] = parameter + 3
        elif sk[1] == 1:
            # loop not used anymore
            sk[1] = 2
            parameter = bytes_to_int_ba(line[sk[0] - linelength[10]:sk[0]])
            # test always
            if parameter > linelength[9]:
                write_log("ob length value too high:" + str(parameter) + " should be " + str(linelength[9]))
                finish = 2
                break
            if parameter == 0:
                # nothing else to transfer
                finish = 1
                break
            # remember number of parameter:
            sk[3] = parameter

            # value of (next) start parameter
            # add length of start parameter
            # minimum of index end is 18
            end = 3 + 5 * sk[2]
            sk[0] += linelength[end - 3]
            # numeric or string
            sk[4] = linelength[end]
            # sk[2] += 1
            # overflow for parameterlist?
            #if sk[2] == linelength[3]:
             #   sk[2] = 3
        else:
            # data transmission
            # now alternate sk[4] = 0,1 or 2
            # end of the actual element
            end = 3 + 5 * sk[2]
            if sk[4] != 1:
                # sk[4] is 0 or 2
                # got numeric parameter or string
                # check if bit
                if linelength[end - 1] == 2:
                    parameter = bytes_to_int_ba(line[sk[0] - linelength[end - 3]:sk[0]])
                    if parameter > linelength[end - 4]:
                        write_log("ob bit value too high:" + str(parameter) + " should be " + str(linelength[end - 4]))
                        finish = 2
                        break
                sk[3] -= 1
                if sk[3] == 0:
                    finish = 1
                    break
                sk[2] += 1
                # oeverflow for parameterlist?
                if sk[2] == linelength[3]:
                    sk[2] = 3
                end = 3 + 5 * sk[2]
                # wait for nueric (0) / stringlength (1)
                sk[4] = linelength[end]
                sk[0] += linelength[end - 3]
            else:
                # sk[4] == 1:
                # got stringlength
                parameter = bytes_to_int_ba(line[sk[0] - linelength[end - 3]:sk[0]])
                # test always
                if parameter > linelength[end - 4]:
                    write_log("ob parameter value too high, loop:" + str(sk[2]) + " " + str(parameter) + " should be " + str(linelength[end - 4]))
                    finish = 2
                    break
                sk[0]  += parameter
                sk[4] = 0

    return sk, finish
"""
name : commandrouterlength_of_commandtypes.py
last edited: 201803
calculate the length of transmitted data for command, answer / info
called at initialization
ct_xx :xx is the commmandtyp, for detailed description see MYC documentation
for details see description of variable v_linelength
These list are used for incoming data to CR. The CR will forward accepted data only
annoncement is syntactically correct (checked before)

for all operate / answer commands the format of the operating commnad is identical to the answer of the answer command
except the length of the commandtoken
"""

import misc_functions
import v_cr_params
import v_linelength
import v_dev


def ct_m(announcement, command_list, answer_list ,device_command_length):
    # basic lines
    # are handled similar to aa commands with 1 string element
    command_list.append("0")
    command_list.append(v_cr_params.length_commandtoken)

    answer_list.append("1")
    answer_list.append(device_command_length)
    # no position parameter
    answer_list.append(1)
    answer_list.append(0)

    answer_list.append(255)
    answer_list.append(1)
    answer_list.append(0)
    answer_list.append(2)
    answer_list.append(0)

    return command_list, answer_list


def ct_nc(announcement, command_list, answer_list ,device_command_length):
    # <c>;yx do not send to device
    command_list.append("5")
    command_list.append(v_cr_params.length_commandtoken)
    answer_list.append("5")
    answer_list.append(device_command_length)
    return command_list, answer_list


def ct_or(announcement, command_list, answer_list ,device_command_length):
    # n on / off switches
    # <c>;or[,<des>]...[,<des>];number_of_stacks;pos0[,<des>]...[;posn,[<des>]][;<OPTION>[,<des>]...	]
    # <c><m><n>0|1
    command_list = c_or(announcement, v_cr_params.length_commandtoken)

    answer_list.append("5")
    answer_list.append(0)
    return command_list, answer_list

def c_or(announcement, tokenlength):
    command_list =[]
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    # number of bytes for stacks
    stacks, stack_length = misc_functions.stacklength(strippped)
    number_of_params = number_of_items - 3
    loops = 0
    command_list.append("1")
    # 1: wait bytes for start:
    command_list.append(tokenlength)
    # 2: loops
    command_list.append(0)
    # 3: not used
    command_list.append(0)
    last_index = 3
    if stack_length > 0:
        loops += 1
        # 4: max
        command_list.append(stacks)
        # 5: length
        command_list.append(stack_length)
        # 6: wait bytes
        command_list[1] += stack_length
        command_list.append(command_list[1])
        # 7: check
        command_list.append(2)
        # 8: addoption
        command_list.append(0)
        last_index += 5
    if number_of_params == 1:
        # no postional paramter; 0|1 only
        # maxpos:
        command_list.append(1)
        #length:
        command_list.append(1)
        # bytes to wait:
        if last_index == 3:
            command_list[1] += 1
        else:
            command_list[last_index - 2] += 1
        # no more loops:
        command_list.append(0)
        # check !
        command_list.append(2)
        # 8: addoption
        command_list.append(0)
        loops += 1
    else:
        # maxpos: example: number_of_params: 6, maxpos: 2, (positions 0, 1, 2 )
        maxpos = number_of_params - 1
        maxpos_length = misc_functions.length_of_int(maxpos)
        command_list.append(maxpos)
        # length of maxpos
        command_list.append(maxpos_length)
        # bytes to wait
        if last_index == 3:
            command_list[1] += maxpos_length
            command_list.append(command_list[1])
        else:
            command_list[last_index - 2] += maxpos_length
            command_list.append(command_list[last_index - 2])
        # check
        command_list.append(2)
        # 8: addoption
        command_list.append(0)
        last_index += 5
        #0|1
        command_list.append(1)
        command_list.append(1)
        command_list[last_index - 2] += 1
        command_list.append(0)
        command_list.append(2)
        # 8: addoption
        command_list.append(0)
        loops += 2
    command_list[2] = loops

    return command_list


def ct_ar(announcement, command_list, answer_list ,device_command_length):
    # <c>;ar[,<des>]...[,<des>];number_of_stacks;pos0[,<des>].[;posn,[<des>]][;<OPTION>[,<des>]...	]
    # <c>           command
    # <c><m><n>     command
    # <c><m><n>0|1  answer / info
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    # number of bytes for stacks
    stacks, stack_length = misc_functions.stacklength(strippped)
    number_of_params = number_of_items - 3
    # maxpos: example: number of positions: 3, maxpos: 2, (positions 0, 1, 2 )
    maxpos = number_of_params - 1
    maxpos_length = misc_functions.length_of_int(maxpos)
    if number_of_params == 1 and stack_length == 0:
        # no paramter to transmit
        command_list.append("0")
        command_list.append(v_cr_params.length_commandtoken)
    else:
        loops = 0
        command_list.append("1")
        # 1: wait bytes for start:
        command_list.append(v_cr_params.length_commandtoken)
        # 2: loops
        command_list.append(0)
        # 3: not used
        command_list.append(0)
        last_index = 3

        if stack_length > 0:
            # 4: max
            command_list.append(stacks)
            # 5: length
            command_list.append(stack_length)
            # 6: wait bytes
            command_list[1] += stack_length
            command_list.append(command_list[1])
            # 7: check
            command_list.append(2)
            # 8: addoption
            command_list.append(0)
            last_index += 5
            loops += 1

        if number_of_params == 1:
            # one loop only
            command_list[last_index - 2] = 0
        else:
            command_list.append(maxpos)
            # length
            command_list.append(maxpos_length)
            if last_index == 3:
                command_list[1] += maxpos_length
            else:
                command_list[last_index - 2] += maxpos_length
            # last loop
            command_list.append(0)
            # check !
            command_list.append(2)
            # 8: addoption
            command_list.append(0)
            loops += 1
        command_list[2]  = loops

    answer_list = c_or(announcement, device_command_length)

    return command_list, answer_list

def ct_os(announcement, command_list, answer_list ,device_command_length):
    # 1 of n switch
    # <c>;os[,<des>]...[,<des>];number_of_stacks;pos0[,<des>];...posn[.<des>][;<OPTION>[,<des>]...	]
    # <c><m><n>
    command_list = c_os(announcement, v_cr_params.length_commandtoken)

    answer_list.append("5")
    answer_list.append(0)
    return command_list, answer_list


def c_os(announcement, tokenlength):
    # for command and answer of answercommand
    command_list =[]
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    # number of bytes for stacks
    stacks, stack_length = misc_functions.stacklength(strippped)
    number_of_params = number_of_items - 3
    loops = 0
    command_list.append("1")
    # 1: wait bytes for start:
    command_list.append(tokenlength)
    # 2: loops
    command_list.append(0)
    # 3: not used
    command_list.append(0)
    last_index = 3
    if stack_length > 0:
        loops += 1
        # 4: maxpos
        command_list.append(stacks)
        # 5: length
        command_list.append(stack_length)
        # 6: wait bytes
        command_list[1] += stack_length
        command_list.append(command_list[1])
        # 7: check
        command_list.append(2)
        # 8: addoption
        command_list.append(0)
        last_index += 5

    # maxpos: example: number_of_params: 6, maxpos: 2, (positions 0, 1, 2 )
    maxpos = number_of_params - 1
    maxpos_length = misc_functions.length_of_int(maxpos)
    command_list.append(maxpos)
    # length of maxpos
    command_list.append(maxpos_length)
    # bytes to wait
    if last_index == 3:
        command_list[1] += maxpos_length
    else:
        command_list[last_index - 2] += maxpos_length
    # no more loop
    command_list.append(0)
    # check
    command_list.append(2)
    # 8: addoption
    command_list.append(0)
    loops += 1

    command_list[2] = loops
    return command_list


def ct_as(announcement, command_list, answer_list, device_command_length):
    # <c>;as[,<des>]...[,<des>];number_of_stacks;pos0[,<des>];...posn[.<des>][;<OPTION>[,<des>]...	]
    # <c><m>
    # cn><m><n>    answer / info
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    # number of bytes for stacks
    stacks, stack_length = misc_functions.stacklength(strippped)
    number_of_params = number_of_items - 3
    # maxpos: example: number of positions: 3, maxpos: 2, (positions 0, 1, 2 )
    maxpos = number_of_params - 1
    maxpos_length = misc_functions.length_of_int(maxpos)
    loops = 0
    command_list.append("1")
    # 1: wait bytes for start:
    command_list.append(v_cr_params.length_commandtoken)
    # 2: loops
    command_list.append(0)
    # 3: not used
    command_list.append(0)
    last_index = 3

    if stack_length > 0:
        # 4: max
        command_list.append(stacks)
        # 5: length
        command_list.append(stack_length)
        # 6: wait bytes
        command_list[1] += stack_length
        command_list.append(0)
        # 7: check
        command_list.append(2)
        # 8: addoption
        command_list.append(0)
        last_index += 5
        loops += 1
    else:
        command_list[0] = "0"
        command_list[1] = v_cr_params.length_commandtoken


    answer_list = c_os(announcement, device_command_length)
    return command_list, answer_list


def ct_ot(announcement, command_list,answer_list,device_command_length):
    # toggling switch
    # <c>;ot[,<des>]...[,<des>];number_of_stacks;[pos0[,<des>];...posn[,<des>][;<OPTION>[,<des>]...	]
    # <c>
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    # number of bytes for stacks
    stacks, stack_length = misc_functions.stacklength(strippped)
    if stack_length > 0:
        command_list.append("1")
        # 1: wait bytes for start:
        command_list.append(v_cr_params.length_commandtoken)
        # 2: loops
        command_list.append(1)
        # 3: not used
        command_list.append(0)
        # 4: maxpos
        command_list.append(stacks)
        # 5: length
        command_list.append(stack_length)
        # 6: wait bytes
        command_list[1] += stack_length
        command_list.append(0)
        # 7: check
        command_list.append(2)
        # 8: addoption
        command_list.append(0)
    else:
        command_list.append("0")
        command_list.append(v_cr_params.length_commandtoken)

    answer_list.append("5")
    answer_list.append(0)
    return command_list, answer_list

#for ct_at -> ct_as is used
#for ct_ou -> ct_os is used
#for ct_au -> ct_as is used

def ct_op(announcement, command_list, answer_list, device_command_length):
    # <c>;op[,<des>]...;number_of_stacks;number_of_valuesx,<des>;lin|log,<des>;unitx,<des>;number_of_valuesy,...
    # <c><n>
    # <c><n><n>
    command_list = c_op(announcement, v_cr_params.length_commandtoken)

    answer_list.append("5")
    answer_list.append(0)
    return command_list, answer_list

def c_op(announcement, tokenlength):
    # for command and answer of answercommand
    command_list = []
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    # number of bytes for stacks
    stacks, stack_length = misc_functions.stacklength(strippped)
    number_of_params = number_of_items - 3
    loops = 0
    command_list.append("1")
    # 1: wait bytes for start:
    command_list.append(tokenlength)
    # 2: loops
    command_list.append(0)
    # 3: not used
    command_list.append(0)
    last_index = 3
    if stack_length > 0:
        loops += 1
        # 4: max
        command_list.append(stacks)
        # 5: length
        command_list.append(stack_length)
        # 6: wait bytes
        command_list[1] += stack_length
        command_list.append(command_list[1])
        # 7: check
        command_list.append(2)
        # 8: addoption
        command_list.append(0)
        last_index += 5
    i = 3
    # 5 elements in linelength for each dimension
    while i < len(strippped):
        length = misc_functions.length_of_int(int(strippped[i]) - 1)
        # max value for this dimension ; -1: 0 based
        command_list.append(int(strippped[i]) - 1)
        # length
        command_list.append(length)
        #wait bytes
        if last_index == 3:
            command_list[1] += length
            command_list.append(command_list[1])
        else:
            command_list[last_index - 2] += length
            command_list.append(command_list[last_index - 2])
        # check!
        command_list.append(2)
        # 8: addoption
        command_list.append(0)
        i += 3
        loops += 1
        if i + 2 >= len(strippped):
            # last loop
            command_list[last_index + 3] = 0
        last_index += 5
    command_list[2] = loops
    return command_list


def ct_ap(announcement, command_list, answer_list, device_command_length):
    # <c>;ap[,<des>]...;number_of_stacks;number_of_valuesx,<des>;lin|log,<des>;unitx,<des>;number_of_valuesy,..
    # <c>
    # <c><m><n>    answer 1 dimension
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    # number of bytes for stacks
    stacks, stack_length = misc_functions.stacklength(strippped)

    if stack_length == 0:
        command_list.append("0")
        command_list.append(v_cr_params.length_commandtoken)
    else:
        command_list.append("1")
        # 1: wait bytes for start:
        command_list.append(v_cr_params.length_commandtoken)
        # 2: loops
        command_list.append(1)
        # 3: not used
        command_list.append(0)
        last_index = 3

        # 4: max
        command_list.append(stacks)
        # 5: length
        command_list.append(stack_length)
        # 6: wait bytes
        command_list[1] += stack_length
        # last loop
        command_list.append(0)
        # 7: check
        command_list.append(2)
        # 8: addoption
        command_list.append(0)
        last_index += 5

    answer_list = c_op(announcement, device_command_length)
    return command_list, answer_list


def ct_oo(announcement, command_list, answer_list,device_command_length):
    # <c>;oo,ext<c>,[<des>]...;number_of_steps[,<des>];steptime;unit;;stepsize[,<des>]<ty>...
    # <c><n><n><n><n>  1 dimension
    # <c><n><n><n><n><n><n><n><n><n>   2 dimension
    # length is calculated for the 1st loop only, so no check of values is done
    command_list = []
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    # number of bytes for stacks
    stacks, stack_length = misc_functions.stacklength(strippped)
    number_of_params = number_of_items - 3
    loops = 0
    command_list.append("1")
    # 1: wait bytes for start:
    command_list.append(v_cr_params.length_commandtoken)
    # 2: loops
    command_list.append(0)
    # 3: not used
    command_list.append(0)
    last_index = 3
    if stack_length > 0:
        loops += 1
        # 4: max
        command_list.append(stacks)
        # 5: length
        command_list.append(stack_length)
        # 6: wait bytes
        command_list[1] += stack_length
        command_list.append(command_list[1])
        # 7: check
        command_list.append(2)
        # 8: addoption
        command_list.append(0)
        last_index += 5
    i = 3
    while i < len(strippped):
        # any item will create a loop
        # number_of steps
        temp = int(strippped[i].split(",")[0]) - 1
        length = misc_functions.length_of_int(temp)
        command_list.append(temp)
        command_list.append(length)
        if last_index == 3:
            command_list[1] += length
            command_list.append(command_list[1])
        else:
            command_list[last_index - 2] += length
            command_list.append(command_list[last_index - 2])
        # check
        command_list.append(2)
        # 8: addoption
        command_list.append(0)
        loops += 1
        last_index += 5
        # steptime
        temp = int(strippped[i + 1].split(",")[0])
        # not transmitted, if 0
        if temp > 0:
            temp -= 1
            length = misc_functions.length_of_int(temp)
            command_list.append(temp)
            command_list.append(length)
            command_list[last_index - 2] += length
            command_list.append(command_list[last_index - 2])
            # check
            command_list.append(2)
            # 8: addoption
            command_list.append(0)
            loops += 1
            last_index += 5
        # stepsize
        temp = int(strippped[i + 3].split(",")[0])
        # not transmitted if 0
        if temp > 0:
            temp -= 1
            length = misc_functions.length_of_int(temp)
            command_list.append(temp)
            command_list.append(length)
            command_list[last_index - 2] += length
            command_list.append(command_list[last_index - 2])
            # check
            command_list.append(2)
            # 8: addoption
            command_list.append(0)
            loops += 1
            last_index += 5
        # <ty>
        temp = misc_functions.ba_to_str(strippped[i + 4].split(",")[0])
        length = v_cr_params.length_of_par[temp]
        if length > 0:
            command_list.append(v_cr_params.max_of_par[temp])
            command_list.append(length)
            command_list[last_index - 2] += length
            command_list.append(command_list[last_index - 2])
            # not check
            command_list.append(2)
            # 8: addoption
            command_list.append(0)
            loops += 1
            last_index += 5
        i += 5
        if i + 2 >= len(strippped):
            # last loop
            command_list[last_index - 2] = 0

    command_list[2] = loops

    answer_list.append("5")
    answer_list.append(0)
    return command_list, answer_list


def ct_om(announcement, command_list, answer_list,device_command_length):
    # <c>;om[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
    # <c><z><data>
    command_list = c_om(announcement, v_cr_params.length_commandtoken)

    answer_list.append("5")
    answer_list.append(0)
    return command_list, answer_list


def c_om(announcement, tokenlength):
    # for command and answer of answercommand
    command_list = []
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    p_type, length, maxpar = misc_functions.length_of_typ(strippped[2])
    positionlength, positions = calc_positionlength(strippped)

    command_list.append("1")
    command_list.append( v_cr_params.length_commandtoken + positionlength)
    # number of loops
    command_list.append(2)
    # not used
    command_list.append(0)
    command_list.append(positions)
    command_list.append(positionlength)
    command_list.append(command_list[1])
    # check!
    command_list.append(2)
    # 8: addoption
    command_list.append(0)

    if p_type == "n":
        # numeric
        command_list.append(maxpar)
        command_list.append(length)
        # last loop
        command_list[6] += length
        command_list.append(0)
        # no check
        if maxpar == 1:
            command_list.append(2)
        else:
            if strippped[2] == "a":
                command_list.append(2)
            else:
                command_list.append(1)
        # 8: addoption
        command_list.append(0)
    else:
        # string
        # max stringlength
        command_list.append(maxpar)
        # length of this
        command_list.append(length)
        command_list[6] += length
        command_list.append(command_list[6])
        # check!
        command_list.append(2)
        # 8: addoption
        command_list.append(1)

        #string itself
        # string itself, no check
        command_list.append(0)
        command_list.append(0)
        command_list.append(0)
        # no check
        command_list.append(1)
        # 8: addoption
        command_list.append(0)

    return command_list


def ct_am(announcement, command_list, answer_list,device_command_length):
    # c>;am[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
    # <c><n>        commandd
    # <c><n><data>  answer / info
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    positionlength, positions = calc_positionlength(strippped)
    command_list.append("1")
    command_list.append(v_cr_params.length_commandtoken + positionlength)
    # number of loops
    command_list.append(1)
    # not used
    command_list.append(0)

    command_list.append(positions)
    command_list.append(positionlength)
    command_list.append(0)
    # check!
    command_list.append(2)
    # 8: addoption
    command_list.append(0)

    answer_list = c_om(announcement, device_command_length)
    return command_list, answer_list

def ct_on(announcement, command_list, answer_list,device_command_length):
    # <c>;on[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
    # <c><n><m><data>
    command_list = c_on(announcement, v_cr_params.length_commandtoken)

    answer_list.append("5")
    answer_list.append(0)
    return command_list, answer_list


def c_on(announcement, tokenlength):
    command_list = []
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    p_type, length, maxpar = misc_functions.length_of_typ(strippped[2])
    item = announcement.split(";")
    positionlength, positions = calc_positionlength(strippped)
    command_list.append("1")
    command_list.append(v_cr_params.length_commandtoken + positionlength)
    # number of loops
    command_list.append(3)
    # not used
    command_list.append(0)

    # start
    command_list.append(positions)
    command_list.append(positionlength)
    command_list.append(command_list[1])
    # check!
    command_list.append(2)
    # 8: addoption
    command_list.append(0)
    
    # number of elements
    command_list.append(positions)
    command_list.append(positionlength)
    command_list[6] += positionlength
    command_list.append(command_list[6])
    # check!
    command_list.append(2)
    # on numeric:
    command_list.append(2)

    if p_type == "n":
        command_list.append(maxpar)
        command_list.append(length)
        # last loop
        command_list[11] += positionlength
        command_list.append(0)
        # no check!
        if strippped[2] == "a":
            command_list.append(2)
        else:
            command_list.append(1)
        command_list.append(2)
    else:
        # string
        command_list[0] = "2"
        # stringlength
        command_list.append(maxpar)
        command_list.append(length)
        # last loop
        command_list[11] += length
        command_list.append(0)
        # check!
        command_list.append(2)
        command_list.append(0)

    return command_list


def ct_an(announcement, command_list, answer_list,device_command_length):
    # c>;an[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
    # <c><n><m>
    # <c><n><m><data> abswere / info
    command_list = []
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    p_type, length, maxpar = misc_functions.length_of_typ(strippped[2])
    positionlength, positions = calc_positionlength(strippped)
    command_list.append("1")
    command_list.append(v_cr_params.length_commandtoken + positionlength)
    #  loops:
    command_list.append(2)
    # not used
    command_list.append(0)

    # startposition for transfer
    command_list.append(positions)
    command_list.append(positionlength)
    command_list.append(command_list[1] + positionlength)
    # check!
    command_list.append(2)
    command_list.append(0)

    # number of elements to transfer
    command_list.append(positions)
    command_list.append(positionlength)
    # last loop
    command_list.append(0)
    # check!
    command_list.append(2)
    command_list.append(0)

    answer_list = c_on(announcement, device_command_length)
    return command_list, answer_list


def ct_of(announcement, command_list, answer_list,device_command_length):
    # <c>;of[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]
    # <c><m><data>
    command_list = c_of(announcement, v_cr_params.length_commandtoken)

    answer_list.append("5")
    answer_list.append(0)
    return command_list, answer_list

def c_of(announcement, tokenlength):
    # for command and answer of answercommand
    command_list = []
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    p_type, length, max = misc_functions.length_of_typ(strippped[2])
    max_len = int(strippped[3])
    length_of_max_len = misc_functions.length_of_int(max_len)
    command_list.append("1")
    # length for 1st loop: length_of_commandtoken + length of startcell
    command_list.append(v_cr_params.length_commandtoken + length_of_max_len)
    command_list.append(2)
    # numric
    command_list.append(0)

    # max number of elements
    command_list.append(max_len)
    command_list.append(length_of_max_len)
    command_list.append(command_list[1])
    # check!
    command_list.append(2)
    # 8: addoption
    command_list.append(2)

    if p_type == "n":
        # max of type
        command_list.append(max)
        # length of type
        command_list.append(length)
        # last loop
        command_list.append(0)
        # check for bit only
        if strippped[2] == "a":
            command_list.append(2)
        else:
            command_list.append(1)
        command_list.append(2)
    else:
        # string
        command_list[0] = "2"
        # Marker for "of string"
        command_list[3] = 1
        # stringlength
        command_list.append(max)
        command_list.append(length)
        # last loop
        command_list[6] += length
        command_list.append(0)
        # check!
        command_list.append(2)
        command_list.append(0)
    return command_list


def ct_af(announcement, command_list, answer_list,device_command_length):
    # <c>;xf[,<des>]...[,<des>];<ty>[,<des>];<m>,<des>
    # <c><m>
    # <c><m><data>     answer / info
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    max = int(strippped[3])
    length_of_max = misc_functions.length_of_int(max)
    command_list.append("1")
    command_list.append(v_cr_params.length_commandtoken + length_of_max)

    command_list.append(1)
    # not used
    command_list.append(0)

    # max
    command_list.append(max)
    #
    command_list.append(length_of_max)
    # last loop
    command_list.append(0)
    # check
    command_list.append(2)
    command_list.append(0)

    answer_list = c_of(announcement, device_command_length)

    return command_list, answer_list


def ct_oa(announcement, command_list, answer_list,device_command_length):
    # <c>;oa[,<des>]...[,<des>];<ty>[,<des>]...[;<ty>[,<des>]]
    # <c><n><data>
    command_list = c_oa(announcement, v_cr_params.length_commandtoken)

    answer_list.append("5")
    answer_list.append(0)
    return command_list, answer_list

def c_oa(announcement, tokenlength):
    # for command and answer of answercommand
    command_list = []
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    command_list.append("3")
    if number_of_items == 3:
        command_list.append(v_cr_params.length_commandtoken)
        # number of loops
        command_list.append(0)
        # one parameter only
        command_list.append(0)

        if str.isnumeric(strippped[2]):
            # string
            command_list.append(int(strippped[2]))
            command_list.append(misc_functions.length_of_int(int(strippped[2])))
            command_list[1] += misc_functions.length_of_int(int(strippped[2]))
            command_list.append(command_list[1])
            # length of string
            command_list.append(0)
            # string
            command_list.append(1)
        else:
            # numeric
            p_type, length, maxpar = misc_functions.length_of_typ(strippped[2])
            command_list.append(maxpar)
            command_list.append(length)
            command_list[1] += v_cr_params.length_of_par[strippped[2]]
            command_list.append(command_list[1])
            # no check!
            command_list.append(1)
            # numeric
            command_list.append(0)
    else:
        # length for 1st loop: length_of_commandtoken + length of startcell
        command_list.append(v_cr_params.length_commandtoken)
        # number of loops (minimum)
        command_list.append(1)
        # more than one element
        command_list.append(1)

        # elementposition
        # -3 for max value: token, commandtype, 0 based
        positionlength = misc_functions.length_of_int(number_of_items - 3)
        command_list.append(number_of_items - 3)
        command_list.append(positionlength)
        command_list[1] += positionlength
        command_list.append(command_list[1])
        # check!
        command_list.append(2)
        command_list.append(0)

        i = 0
        while i < number_of_items - 2:
            # type is string / numeric ?
            if str.isnumeric(strippped[i + 2]):
                # string
                command_list.append(int(strippped[i + 2]))
                command_list.append(misc_functions.length_of_int(int(strippped[i + 2])))
                # length of string
                command_list.append(0)
                # check (stringlength)
                command_list.append(2)
                # string
                command_list.append(1)
            else:
                # numeric
                p_type, length, maxpar = misc_functions.length_of_typ(strippped[i + 2])
                command_list.append(maxpar)
                command_list.append(length)
                # not used
                command_list.append(0)
                # checck bit only
                if strippped[2] == "a":
                    command_list.append(2)
                else:
                    command_list.append(1)
                # numeric
                command_list.append(0)
            i += 1
    return command_list

def ct_aa(announcement, command_list, answer_list,device_command_length):
    # <c>,aa[,<des>]...[,<des>];<ty>[,<des>];<ty>[,<des>]...
    # <c><n>
    # <data>
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    positionlength = misc_functions.length_of_int(number_of_items - 3)
    if number_of_items == 3:
        command_list.append("0")
        command_list.append(v_cr_params.length_commandtoken)
    else:
        command_list.append("1")
        command_list.append(v_cr_params.length_commandtoken + positionlength)
        # number of loops
        command_list.append(1)
        command_list.append(0)

        command_list.append(number_of_items - 3)
        command_list.append(positionlength)
        # last loop
        command_list.append(0)
        # check !
        command_list.append(2)
        command_list.append(0)

    answer_list = c_oa(announcement, device_command_length)

    return command_list, answer_list


def ct_ob(announcement, command_list, answer_list,device_command_length):
    # <c>;ob[,<des>]...[,<des>];<ty>[,<des>]...[;<ty>[,<des>]]
    # <c><n><m><data>
    command_list = c_ob(announcement, v_cr_params.length_commandtoken)

    answer_list.append("5")
    answer_list.append(0)
    return command_list, answer_list


def c_ob(announcement, tokenlength):
    # for command and answer of answercommand
    command_list = []
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    positions = len(strippped) - 2

    command_list.append("4")
    command_list.append(v_cr_params.length_commandtoken)
    # number of loops
    command_list.append(3)
    # not used
    command_list.append(0)

    # start element
    command_list.append(number_of_items - 3)
    command_list.append(misc_functions.length_of_int(number_of_items - 3))
    command_list[1] += command_list[5]
    command_list.append(command_list[1])
    # check
    command_list.append(2)
    command_list.append(0)

    # number of elements
    command_list.append(number_of_items - 2)
    command_list.append(misc_functions.length_of_int(number_of_items - 2))
    command_list[6] += command_list[10]
    command_list.append(command_list[6])
    # check
    command_list.append(2)
    command_list.append(0)
    last_index = 13
    i = 0
    while i < positions:
        last_index += 5
        # type is string / numeric ?
        p_type, length, maxpar = misc_functions.length_of_typ(strippped[i + 2])
        if p_type == "s":
            # stringlength
            command_list.append(int(maxpar))
            # length of stringlength
            command_list.append(length)
            command_list.append(1)
            # not used for check
            command_list.append(1)
            # string (stringlength checked)
            command_list.append(1)
        else:
            # numeric
            command_list.append(maxpar)
            command_list.append(length)
            command_list.append(1)
            # check bit only
            if strippped[i + 2] == "a":
                command_list.append(2)
            else:
                command_list.append(1)
            # nuneric
            command_list.append(0)

        # last loop
        command_list[last_index - 2] = 0
        i += 1
    # loops
    command_list[2] = i + 2
    # number of blocks in linelength
    command_list[3] = i + 3
    return command_list


def ct_ab(announcement, command_list, answer_list,device_command_length):
    # <c>;ab[,<des>]...[,<des>];<ty>[,<des>]...[;<ty>[,<des>]
    command_list = []
    number_of_items, strippped = misc_functions.strip_dimension(announcement)
    command_list.append("1")
    command_list.append(v_cr_params.length_commandtoken)
    # number of loops
    command_list.append(2)
    # not used
    command_list.append(0)

    # start element (0 based position)
    command_list.append(number_of_items - 3)
    command_list.append(misc_functions.length_of_int(number_of_items - 3))
    command_list[1] += command_list[5]
    command_list.append(command_list[1])
    # check
    command_list.append(2)
    command_list.append(0)

    # number of elements
    command_list.append(number_of_items - 2)
    command_list.append(misc_functions.length_of_int(number_of_items - 2))
    command_list[6] += command_list[10]
    command_list.append(0)
    # check
    command_list.append(2)
    command_list.append(0)

    answer_list = c_ob(announcement, device_command_length)

    return command_list, answer_list

def calc_positionlength(item):
    # number of memory positions
    i = 3
    positions = 1
    while i < len(item):
        positions *= int(item[i])
        i += 1
    # positions "0" based:
    positions -= 1
    positionlength = misc_functions.length_of_int(positions)
    return positionlength, positions

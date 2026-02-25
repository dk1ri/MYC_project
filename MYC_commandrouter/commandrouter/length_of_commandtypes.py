"""
name : commandrouterlength_of_commandtypes.py
last edited: 20260224
calculate the length of transmitted data for command, answer / info
called at initialization
ct_xx :xx is the commmandtyp, for detailed description see MYC documentation
for details see description of variable v_linelength
These list are used for incoming data to CR. The CR will forward accepted data only
annoncement is syntactically correct (checked before)

for all operate / answer commands the format of the operating commnad is identical to the answer of the answer command
except the length of the commandtoken
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""

import misc_functions
import v_cr_params
import v_linelength
import v_token_params
import v_announcelist
from misc_functions import length_of_typ


def ct_m(stripped):
    # basic lines
    # are handled similar to aa commands with 1 string element
    command_list = ["0", v_announcelist.length_of_full_elements,]
    answer_list = [1, v_announcelist.length_of_full_elements, 1, 0, 255,1, 0, 2, 0]

    return command_list, answer_list


def ct_nc(stripped):
    # <c>;yx do not send to device
    command_list = [0, v_announcelist.length_of_full_elements]
    answer_list = [0, v_announcelist.length_of_full_elements]
    return command_list, answer_list

def add_stack(stripped, command_list):
    stacks, stack_length = misc_functions.stacklength(stripped)
    if stack_length > 0:
        command_list[1] += stack_length
        # 2: max
        command_list.append(stacks)
        # 3: length
        command_list.append(stack_length)
        # 4: string
        command_list.append(0)
    return command_list

def ct_or(stripped):
    # n on / off switches
    # <c>;or;number_of_stacks;pos0;...;posn
    # <c><m><n>0|1
    command_list = c_or(stripped)

    answer_list = [5, 0]
    return command_list, answer_list

def c_or(stripped):
    command_list = []
    number_of_items = len(stripped)
    # number of bytes for stacks
    number_of_params = number_of_items - 3
    command_list.append("1")
    command_list.append(v_announcelist.length_of_full_elements)

    command_list = add_stack(stripped, command_list)

    if number_of_params == 1:
        # no postional parameter; 0|1 only
        command_list[1] += 1
        # maxpos:
        command_list.append(1)
        # length:
        command_list.append(1)
        # string
        command_list.append(0)
    else:
        # maxpos: example: number_of_params: 6, maxpos: 2, (positions 0, 1, 2 )
        maxpos = number_of_params - 1
        maxpos_length = misc_functions.length_of_int(maxpos)
        command_list[1] += maxpos_length
        command_list.append(maxpos)
        # length of maxpos
        command_list.append(maxpos_length)
        # string
        command_list.append(0)
        #0|1
        command_list[1] += 1
        command_list.append(1)
        command_list.append(1)
        command_list.append(0)
    return command_list


def ct_ar(stripped):
    # <c>;number_of_stacks;pos0...;posn
    command_list = []
    number_of_items = len(stripped)
    # number of bytes for stacks
    stacks, stack_length = misc_functions.stacklength(stripped)
    number_of_params = number_of_items - 3
    # maxpos: example: number of positions: 3, maxpos: 2, (positions 0, 1, 2 )
    if number_of_params == 1 and stack_length == 0:
        # no parameter to transmit
        command_list.append("0")
        command_list.append(v_announcelist.length_of_full_elements)
    else:
        command_list.append("1")
        # 1: wait bytes for start:
        command_list.append(v_announcelist.length_of_full_elements)

        command_list = add_stack(stripped, command_list)

        if number_of_params > 1:
            maxpos = number_of_params - 1
            maxpos_length = misc_functions.length_of_int(maxpos)
            command_list[1] += maxpos_length
            command_list.append(maxpos)
            # length
            command_list.append(maxpos_length)
            # string
            command_list.append(0)
    answer_list = c_or(stripped)

    return command_list, answer_list

def ct_os(stripped):
    # 1 of n switch
    # <c>;os;number_of_stacks;pos0;...posn
    # <c><m><n>
    answer_list = []
    command_list = c_os(stripped)
    return command_list, answer_list

def c_os(stripped):
    # for command and answer of answercommand
    command_list = []
    number_of_items = len(stripped)
    number_of_params = number_of_items - 3
    # type
    command_list.append("1")
    # 1: wait bytes for start:
    command_list.append(v_announcelist.length_of_full_elements)

    command_list = add_stack(stripped, command_list)

    # 2/6: maxpos: example: number_of_params: 6, maxpos: 2, (positions 0, 1, 2 )
    maxpos = number_of_params - 1
    maxpos_length = misc_functions.length_of_int(maxpos)
    command_list[1] += maxpos_length
    command_list.append(maxpos)
    # 3/7length of maxpos
    command_list.append(maxpos_length)
    # 4/8; atring
    command_list.append(0)
    return command_list

def ct_as(stripped):
    # <c>;as;number_of_stacks;pos0;...posn
    tok = stripped[0]
    command_list = []
    if tok in v_token_params.a_to_o:
        command_list = v_linelength.command[v_token_params.a_to_o[tok]]
        answer_list = v_linelength.answer[v_token_params.a_to_o[tok]]
    else:
        command_list.append("1")
        # 1: wait bytes for start:
        command_list.append(v_announcelist.length_of_full_elements)

        command_list = add_stack(stripped, command_list)

        stacks, stack_length = misc_functions.stacklength(stripped)
        if stack_length == 0:
            command_list[0] = "0"
            command_list[1] = v_announcelist.length_of_full_elements
        answer_list = c_os(stripped)
    return command_list, answer_list


def ct_at(stripped):
    # toggling switch
    # <c>;at;number_of_stacks;pos0;...;posn
    command_list = []
    answer_list = []
    stacks, stack_length = misc_functions.stacklength(stripped)
    if stack_length > 0:
        answer_list.append("1")
        # 1: wait bytes for start:
        answer_list.append(v_announcelist.length_of_full_elements)
        answer_list = add_stack(stripped, answer_list)
        # new value
        answer_list.append(len(stripped) - 3)
        #length of this
        answer_list.append(misc_functions.length_of_int(len(stripped) - 3))
        # string
        answer_list.append(0)

        command_list.append("1")
        # 1: wait bytes for start:
        command_list.append(v_announcelist.length_of_full_elements)
        command_list = add_stack(stripped, command_list)
    else:
        answer_list.append("1")
        # wait
        answer_list.append(v_announcelist.length_of_full_elements)
        # new value
        answer_list.append(len(stripped) - 3)
        # length of this
        answer_list.append(misc_functions.length_of_int(len(stripped) - 3))
        # string
        answer_list.append(0)

        command_list.append("0")
        command_list.append(v_announcelist.length_of_full_elements)

    return command_list, answer_list

def ct_ou(stripped):
    answer_list = []
    command_list = c_os(stripped)
    # there ar no answers
    answer_list.append("0")
    answer_list.append(0)
    return command_list, answer_list

def ct_op(stripped):
    # <c>;op;number_of_stacks;number_of_valuesx;lin|log,;unitx;number_of_valuesy,...
    # <c><n>
    # <c><n><n>
    answer_list = []
    command_list = c_op(stripped)

    answer_list.append("0")
    answer_list.append(0)
    return command_list, answer_list

def c_op(stripped):
    # for command and answer of answercommand
    command_list = []
    command_list.append("1")
    # 1: wait bytes for start:
    command_list.append(v_announcelist.length_of_full_elements)

    command_list = add_stack(stripped, command_list)

    pos_of_stripped = 3
    # 3 elements in linelength for each dimension
    while pos_of_stripped < len(stripped):
        # number_of steps
        if int(stripped[pos_of_stripped]) != 0:
            temp = int(stripped[pos_of_stripped])
        else:
            temp = 0
        command_list.append(temp)
        # length of this
        length = misc_functions.length_of_int(temp)
        command_list.append(length)
        command_list[1] += length
        # string
        command_list.append(0)

        pos_of_stripped += 3
    return command_list


def ct_ap(stripped):
    # <c>;ap;number_of_stacks;number_of_valuesx,<des>;b;unitx;number_of_valuesy,..
    command_list = []

    # number of bytes for stacks
    stacks, stack_length = misc_functions.stacklength(stripped)

    if stack_length == 0:
        command_list.append("0")
        command_list.append(v_announcelist.length_of_full_elements)
    else:
        command_list.append("1")
        # 1: wait bytes for start:
        command_list.append(v_announcelist.length_of_full_elements)

        command_list = add_stack(stripped, command_list)

    answer_list = c_op(stripped)
    return command_list, answer_list


def ct_oo(stripped):
    # <c>;oo;number_of_steps;steptime;unit;stepsize;b;
    # <c><n><n><n><n>  1 dimension
    # <c><n><n><n><n><n><n><n><n><n>   2 dimension
    # length is calculated for the 1st loop only, so no check of values is done
    command_list = []
    answer_list = []
    # number of bytes for stacks
    command_list.append("1")
    # 1: wait bytes for start:
    command_list.append(v_announcelist.length_of_full_elements)

    command_list = add_stack(stripped, command_list)

    pos_of_stripped = 3
    while pos_of_stripped < len(stripped):
        # number_of steps
        if int(stripped[pos_of_stripped]) != 0:
            temp = int(stripped[pos_of_stripped])
        else:
            temp = 0
        command_list.append(temp)
        # length of this
        length = misc_functions.length_of_int(temp)
        command_list.append(length)
        command_list[1] += length
        # string
        command_list.append(0)

        # stepsize
        if int(stripped[pos_of_stripped + 1].split(",")[0]) != 0:
            temp = int(stripped[pos_of_stripped + 1])
        else:
            temp = 0
        command_list.append(temp)
        # length of this
        length = misc_functions.length_of_int(temp)
        command_list.append(length)
        command_list[1] += length
        # string
        command_list.append(0)

        # steptime
        if int(stripped[pos_of_stripped + 2]) != 0:
            temp = int(stripped[pos_of_stripped + 2])
        else:
            temp = 0
        command_list.append(temp)
        # length of this
        length = misc_functions.length_of_int(temp)
        command_list.append(length)
        command_list[1] += length
        # string
        command_list.append(0)

        pos_of_stripped += 5

    answer_list.append("0")
    answer_list.append(0)
    return command_list, answer_list


def ct_om(stripped):
    # <c>;om;<ty>;m
    answer_list = []
    command_list = c_om(stripped)

    answer_list.append("5")
    answer_list.append(0)
    return command_list, answer_list


def c_om(stripped):
    # for command and answer of answercommand
    command_list = []
    p_type, length, maxpar = misc_functions.length_of_typ(stripped[2])
    positions = int(stripped[3]) - 1
    positionlength = misc_functions.length_of_int(positions)
    if p_type == "n":
        # 0: type
        command_list.append("1")
        # 1: length
        command_list.append(v_announcelist.length_of_full_elements + positionlength)

        # 2: max
        command_list.append(positions)
        # 3: length
        command_list.append(positionlength)
        command_list[1] += length
        # 4: string
        command_list.append(0)

        # 5: max
        command_list.append(maxpar)
        # 6 length
        command_list.append(length)
        # 7: string
        command_list.append(0)
    else:
        # string
        # 0: type
        command_list.append("7")
        # 1: length
        command_list.append(v_announcelist.length_of_full_elements + positionlength)

        # 2: max
        command_list.append(positions)
        # 3: length
        command_list.append(positionlength)
        command_list[1] += length
        # 4: string
        command_list.append(0)

        # max stringlength
        command_list.append(maxpar)
        # length of this
        command_list.append(length)
        # string
        command_list.append (1)

    return command_list


def ct_am(stripped):
    # c>;am;<ty>;m
    command_list = []
    positions = int(stripped[3]) - 1
    positionlength = misc_functions.length_of_int(positions)
    command_list.append("1")
    command_list.append(v_announcelist.length_of_full_elements + positionlength)

    # max
    command_list.append(positions)
    command_list.append(positionlength)
    command_list.append(0)

    answer_list = c_om(stripped)
    return command_list, answer_list

def ct_on(stripped):
    # <c>;on;<ty>;m;n
    # <c><n><m><data>
    answer_list = []
    command_list = c_on(stripped)

    answer_list.append("5")
    answer_list.append(0)
    return command_list, answer_list

def c_on(stripped):
    command_list = []
    # 0: type
    command_list.append("2")
    # 1: length of first loop: added later
    command_list.append(1)

    positions = int(stripped[3])
    elements = int(stripped[4])
    positionlength = misc_functions.length_of_int(positions)
    elementlength = misc_functions.length_of_int(elements)
    # 3: max of start positions
    command_list.append(positions)
    # 4: length of this
    command_list.append(positionlength)
    command_list[1] += positionlength
    # 5: string
    command_list.append(0)

    # 6: max for elements
    command_list.append(elements)
    # 7: length of this
    command_list.append(elementlength)
    command_list[1] += elementlength
    # 8: string
    command_list.append(0)

    p_type, length, maxpar = misc_functions.length_of_typ(stripped[2])
    if p_type == "n":
        # 9: max of value
        command_list.append(maxpar)
        # 10: length
        command_list.append(length)
        # string
        command_list.append(0)
    else:
        # 9: max of length
        command_list.append(maxpar)
        # 10: length
        command_list.append(length)
        command_list.append(1)
    return command_list

def ct_an(stripped):
    # c>;an;<ty>;m;n
    command_list = []
    # 0: type:
    command_list.append("1")
    # 1: length of first loop: added later
    command_list.append(v_announcelist.length_of_full_elements)
    positions = int(stripped[3])
    elements = int(stripped[4])
    positionlength = misc_functions.length_of_int(positions)
    elementlength = misc_functions.length_of_int(elements)
    # 3: max of start positions
    command_list.append(positions)
    # 4: length of this
    command_list.append(positionlength)
    command_list[1] += positionlength
    # 5: string
    command_list.append(0)

    # 6: max for elements
    command_list.append(elements)
    # 7: length of this
    command_list.append(elementlength)
    command_list[1] += elementlength
    # 8: string
    command_list.append(0)
    answer_list = c_on(stripped)
    return command_list, answer_list

def ct_of(stripped):
    # <c>;of;<ty>;n
    answer_list = []
    command_list = c_of(stripped)

    answer_list.append("5")
    answer_list.append(0)
    return command_list, answer_list

def c_of(stripped):
    # for command and answer of answercommand
    command_list = []
    p_type, length, x_max = misc_functions.length_of_typ(stripped[2])
    max_len = int(stripped[3])
    length_of_max_len = misc_functions.length_of_int(max_len)
    # 0: typ
    command_list.append("4")
    # length for 1st loop: length_of_commandtoken + length of startcell
    # 1: wait
    command_list.append(v_announcelist.length_of_full_elements + length_of_max_len)

    # 2: max number of elements
    command_list.append(max_len)
    # 3: length of this
    command_list.append(length_of_max_len)
    # 4: string
    command_list.append(0)
    # 5: max of value /stringlength
    command_list.append(x_max)
    # 6: length of this
    command_list.append(length)
    # string
    if p_type == "n":
        command_list.append(0)
    else:
        command_list.append(1)
    return command_list

def ct_af(stripped):
    # <c>;af;<ty>;n
    command_list = []
    x_max = int(stripped[3])
    length_of_max = misc_functions.length_of_int(x_max)
    # 0: type
    command_list.append("1")
    # 1: wait
    command_list.append(v_announcelist.length_of_full_elements + length_of_max)

    # 2: max
    command_list.append(x_max)
    # 3: length of this
    command_list.append(length_of_max)
    # string
    command_list.append(0)

    answer_list = c_of(stripped)
    return command_list, answer_list

def ct_oa(stripped):
    # <c>;oa;<ty>...;<ty>
    answer_list = []
    command_list = c_oa(stripped)

    answer_list.append("0")
    answer_list.append(0)
    return command_list, answer_list

def c_oa(stripped):
    # for command and answer of answercommand
    command_list = []
    number_of_items = len(stripped)
    # 0: type
    command_list.append("3")
    # 1: length to wait
    command_list.append(v_announcelist.length_of_full_elements)

    if number_of_items == 3:
        # one element, no position necessary
        if str.isnumeric(stripped[2]):
            # string
            # 2: length of string "0" included
            command_list.append(int(stripped[2]))
            # 3: length of length
            command_list.append(misc_functions.length_of_int(command_list[2]))
            command_list[1] += command_list[3]
            # 4: string
            command_list.append(1)
        else:
            # numeric
            p_type, length, maxpar = misc_functions.length_of_typ(stripped[2].split(",")[0])
            command_list.append(maxpar)
            command_list.append(length)
            command_list[1] += v_cr_params.length_of_par[stripped[2]]
            # string
            command_list.append(0)
    else:
        # 2: max of position in announcement, 0 based -> len(stripped) - c - ct - 1
        command_list.append(number_of_items - 3)
        # 3: length
        command_list.append(misc_functions.length_of_int(number_of_items - 2))
        command_list[1] += command_list[3]
        # 4: string
        command_list.append(0)

        # one block for each parameter
        i = 0
        while i < number_of_items - 2:
            # type is string / numeric ?
            if str.isnumeric(stripped[i + 2]):
                # string
                value = int(stripped[i + 2])
                command_list.append(value)
                command_list.append(misc_functions.length_of_int(value))
                # string
                command_list.append(1)
            else:
                # numeric
                p_type, length, maxpar = misc_functions.length_of_typ(stripped[i + 2])
                command_list.append(maxpar)
                command_list.append(length)
                # string
                command_list.append(0)
            i += 1
    return command_list

def ct_aa(stripped):
    # <c>,aa;<ty>...;<ty>
    command_list = []
    number_of_items = len(stripped)
    if number_of_items == 3:
        # one element
        command_list.append("0")
        command_list.append(v_announcelist.length_of_full_elements)
    else:
        positionlength = misc_functions.length_of_int(number_of_items - 3)
        command_list.append("1")
        command_list.append(v_announcelist.length_of_full_elements + positionlength)

        # max of position in announcement, 0 based -> len(stripped) - c - ct - 1
        command_list.append(number_of_items - 3)
        command_list.append(positionlength)
        # string
        command_list.append(0)
    answer_list = c_oa(stripped)
    return command_list, answer_list


def ct_ob(stripped):
    answer_list = []
    # <c>;ob;<ty>...;<ty>
    command_list = c_ob(stripped)

    return command_list, answer_list


def c_ob(stripped):
    # for command and answer of answercommand
    command_list = []
    if len(stripped) == 3:
        # one element
        p_type, length, maxpar = misc_functions.length_of_typ(stripped[2])
        if p_type == "n":
            # 0: type
            command_list.append("1")
            # 1: wait
            command_list.append(v_announcelist.length_of_full_elements + length)
            # max of par
            command_list.append(maxpar)
            # length of this
            command_list.append(length)
            # string
            command_list.append(0)
        else:
            # 0: type
            command_list.append("6")
            # wait
            command_list.append(v_announcelist.length_of_full_elements + length)
            # max of stringlength
            command_list.append(maxpar)
            # length of this
            command_list.append(length)
            # string
            command_list.append(1)
    else:
        # more elements
        positions = len(stripped) - 2
        # 0: type
        command_list.append("5")
        # 1: wait
        command_list.append(v_announcelist.length_of_full_elements)

        # 2: start element
        command_list.append(positions - 1)
        #3: length of this
        command_list.append(misc_functions.length_of_int(positions))
        command_list[1] += misc_functions.length_of_int(positions)
        # 4: string
        command_list.append(0)

        # 5:number of elements
        command_list.append(positions)
        # 6: length of this
        command_list.append(misc_functions.length_of_int(positions))
        command_list[1] += misc_functions.length_of_int(positions)
        # 7: string
        command_list.append(0)
        i = 0
        while i < positions:
            # type is string / numeric ?
            p_type, length, maxpar = misc_functions.length_of_typ(stripped[i + 2])
            # max of parameter or max of stringlength
            command_list.append(int(maxpar))
            # length of this
            command_list.append(length)
            # string
            if p_type == "s":
                command_list.append(1)

            else:
                # numeric
                command_list.append(0)
            i += 1
    return command_list

def ct_ab(stripped):
    # <c>;ab;<ty>...;<ty>
    command_list = []
    positions = len(stripped) - 2
    if positions == 1:
        # 0: type
        command_list.append("0")
        # 1: wait
        command_list.append(v_announcelist.length_of_full_elements)
    else:
        # 0: type
        command_list.append("1")
        # 1: wait
        command_list.append(v_announcelist.length_of_full_elements)

        # 2: start element (0 based position)
        command_list.append(positions - 1)
        # 3: length of this
        command_list.append(misc_functions.length_of_int(positions - 2))
        command_list[1] += misc_functions.length_of_int(positions - 2)
        # 4: string
        command_list.append(0)

        # 5: number of elements
        command_list.append(positions)
        # 6: lengh of this
        command_list.append(misc_functions.length_of_int(positions))
        command_list[1] += misc_functions.length_of_int(positions)
        # 7: string
        command_list.append(0)

    answer_list = c_ob(stripped)
    return command_list, answer_list

def calc_positionlength1(item):
    # number of memory positions
    i = 3
    positions = 1
    while i < len(item):
        positions *= int(item[i].split(",")[0])
        i += 1
    # positions "0" based:
    positions -= 1
    positionlength = misc_functions.length_of_int(positions)
    return positionlength, positions

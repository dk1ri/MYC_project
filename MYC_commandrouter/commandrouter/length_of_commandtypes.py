"""
name : commandrouterlength_of_commandtypes.py
calculate the length of transmitted data for command, answer / info
called at initialization
ct_xx :xx is the commmandtyp, for detailed description see MYC documentation
for details see description of variable v_linelength
These list are used for incoming data to CR. The CR will forward accepted data only
"""

import misc_functions
import v_cr_params
import v_linelength
import v_dev


def ct_m(announcement, tok, device):
    # basic lines
    # are handled similar to aa commands with 1 string element
    v_linelength.command[tok].append("1")
    v_linelength.command[tok].append(1)
    v_linelength.command[tok].append(0)
    v_linelength.command[tok].append(0)
    v_linelength.answer[tok].append("7")
    v_linelength.answer[tok].append(0)
    # no position parameter
    v_linelength.answer[tok].append(0)
    v_linelength.answer[tok].append(0)
    v_linelength.answer[tok].append(255)
    v_linelength.answer[tok].append(1)
    v_linelength.answer[tok].append(1)
    return


def ct_nc(announcement, tok, device):
    # <c>;yx do not send to device
    v_linelength.command[tok].append("0")
    v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    v_linelength.answer[tok].append("0")
    v_linelength.answer[tok].append(0)
    return


def ct_or(announcement, tok, device):
    # n on / off switches
    # <c>;or[,<des>]...[,<des>];pos0[,<des>]...[;posn,[<des>]][;<OPTION>[,<des>]...	]
    # <c>0|1
    number_of_items = misc_functions.strip_dimension(announcement)
    # must be more than 2
    if number_of_items > 2:
        v_linelength.command[tok].append("1")
        if number_of_items == 3:
            v_linelength.command[tok].append(v_cr_params.length_commandtoken + 1)
            # number of following paramters (3 entries each)
            v_linelength.command[tok].append(1)
            v_linelength.command[tok].append(0)
            # 0|1
            v_linelength.command[tok].append(1)
            v_linelength.command[tok].append(1)
            # check !
            v_linelength.command[tok].append(2)
        if number_of_items > 3:
            v_linelength.command[tok].append(v_cr_params.length_commandtoken + misc_functions.length_of_int(number_of_items - 3))
            # number of loops (3 entries each)
            v_linelength.command[tok].append(2)
            v_linelength.command[tok].append(0)
            # maxpos: example number_of_items: 5, number of positions: 3, maxpos: 2, (positions 0, 1, 2 )
            v_linelength.command[tok].append(number_of_items - 3)
            # length of maxpos
            v_linelength.command[tok].append(misc_functions.length_of_int(number_of_items - 3))
            v_linelength.command[tok].append(2)
            #0|1
            v_linelength.command[tok].append(1)
            v_linelength.command[tok].append(1)
            v_linelength.command[tok].append(2)
    else:
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    v_linelength.answer[tok].append("0")
    v_linelength.answer[tok].append(0)
    return


def ct_ar(announcement, tok, device):
    # <c>;ar[,<des>]...[,<des>];pos0[,<des>].[;posn,[<des>]][;<OPTION>[,<des>]...	]
    # <c>       command
    # <c><n>    command
    # <c>0|1    answer / info
    # <c><n>0|1 answer / info
    number_of_items = misc_functions.strip_dimension(announcement)
    # must be more than 2
    if number_of_items > 2:
        v_linelength.command[tok].append("1")
        if number_of_items == 3:
            v_linelength.command[tok].append(v_cr_params.length_commandtoken)
            # number of loops
            v_linelength.command[tok].append(0)
        else:
            v_linelength.command[tok].append(v_cr_params.length_commandtoken + misc_functions.length_of_int(number_of_items - 3))
            # number of loops
            v_linelength.command[tok].append(1)
            v_linelength.command[tok].append(0)
            # maxpos: example number_of_items: 5, number of positions: 3, maxpos: 2, (positions 0, 1, 2 )
            v_linelength.command[tok].append(number_of_items - 3)
            # length of maxpos
            v_linelength.command[tok].append(misc_functions.length_of_int(number_of_items - 3))
            # check !
            v_linelength.command[tok].append(2)

        v_linelength.answer[tok].append("1")
        if number_of_items == 3:
            # number of loops
            v_linelength.answer[tok].append(1)
            v_linelength.answer[tok].append(0)
            # 0|1
            v_linelength.answer[tok].append(1)
            v_linelength.answer[tok].append(1)
            # check !
            v_linelength.answer[tok].append(2)
        if number_of_items > 3:
            v_linelength.answer[tok].append(misc_functions.length_of_int(number_of_items - 3))
            # number of loops
            v_linelength.answer[tok].append(2)
            v_linelength.answer[tok].append(0)
            # maxpos: example number_of_items: 5, number of positions: 3, maxpos: 2, (positions 0, 1, 2 )
            v_linelength.answer[tok].append(number_of_items - 3)
            # length of maxpos
            v_linelength.answer[tok].append(misc_functions.length_of_int(number_of_items - 3))
            v_linelength.answer[tok].append(2)
            # 0|1
            v_linelength.answer[tok].append(1)
            v_linelength.answer[tok].append(1)
            v_linelength.answer[tok].append(2)
    else:
        # incorrect announceline
        v_linelength.command[tok][0] = "0"
        v_linelength.command[tok].append(0)
        v_linelength.answer[tok][0] = "0"
        v_linelength.answer[tok].append(0)
    return


def ct_os(announcement, tok, device):
    # 1 of n switch
    # <c>;os[,<des>]...[,<des>];pos0[,<des>];...posn[.<des>][;<OPTION>[,<des>]...	]
    # <c><n>
    number_of_items = misc_functions.strip_dimension(announcement)
    # must be more than 2
    if number_of_items > 2:
        v_linelength.command[tok].append("1")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken + misc_functions.length_of_int(number_of_items - 3))
        # number of loops
        v_linelength.command[tok].append(1)
        v_linelength.command[tok].append(0)
        # maxpos: example number_of_items: 5, number of positions: 3, maxpos: 2, (positions 0, 1, 2 )
        v_linelength.command[tok].append(number_of_items - 3)
        # length of maxpos
        v_linelength.command[tok].append(misc_functions.length_of_int(number_of_items - 3))
        # check!
        v_linelength.command[tok].append(2)
    else:
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    v_linelength.answer[tok].append("0")
    v_linelength.answer[tok].append(0)
    return


def ct_as(announcement, tok, device):
    # <c>;as[,<des>]...[,<des>];pos0[,<des>];...posn[.<des>][;<OPTION>[,<des>]...	]
    # <c>
    # cn><n>    answer / info
    number_of_items = misc_functions.strip_dimension(announcement)
    if number_of_items > 2:
        v_linelength.command[tok].append("1")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
        # number of loops
        v_linelength.command[tok].append(0)
        v_linelength.command[tok].append(0)

        v_linelength.answer[tok].append("1")
        v_linelength.answer[tok].append(misc_functions.length_of_int(number_of_items - 3))
        # number of loops
        v_linelength.answer[tok].append(1)
        v_linelength.answer[tok].append(0)
        # maxpos: example number_of_items: 5, maxpos: 3, position 0, 1, 2  < 3
        v_linelength.answer[tok].append(number_of_items - 3)
        # length of nmaxpos
        v_linelength.answer[tok].append(misc_functions.length_of_int(number_of_items - 3))
        # check!
        v_linelength.answer[tok].append(2)
    else:
        # incorrect announceline
        v_linelength.command[tok][0] = "0"
        v_linelength.command[tok].append(0)
        v_linelength.answer[tok][0] = "0"
        v_linelength.answer[tok].append(0)
    return


def ct_ot(announcement, tok, device):
    # toggling switch
    # <c>;ot[,<des>]...[,<des>];[pos0[,<des>];...posn[,<des>][;<OPTION>[,<des>]...	]
    # <c>
    # no difference, if announceline has not enaugh elements
    v_linelength.command[tok].append("1")
    v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    # number of loops
    v_linelength.command[tok].append(0)
    v_linelength.command[tok].append(0)
    v_linelength.answer[tok].append("0")
    v_linelength.answer[tok].append(0)
    return


def ct_ou(announcement, tok, device):
    # momentary switch
    # <c>;ou[,<des>]...[<,des>];pos0[,<des>];...;posn[,<des>][;<OPTION>[,<des>]...	]
    # <c>
    # <c><n>
    number_of_items = misc_functions.strip_dimension(announcement)
    # pos 0 and pos1 needed
    if number_of_items > 3:
        if number_of_items == 4:
            v_linelength.command[tok].append("1")
            v_linelength.command[tok].append(v_cr_params.length_commandtoken)
            # number of loops
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(0)
        if number_of_items > 4:
            v_linelength.command[tok].append("1")
            v_linelength.command[tok].append(v_dev.length_commandtoken[device] + misc_functions.length_of_int(number_of_items - 3))
            # number of loops
            v_linelength.command[tok].append(1)
            v_linelength.command[tok].append(0)
            # maxpos: example number_of_items: 5, maxpos: 3, position 0, 1, 2  < 3
            v_linelength.command[tok].append(number_of_items - 3)
            # length of nmaxpos
            v_linelength.command[tok].append(misc_functions.length_of_int(number_of_items - 3))
            # check!
            v_linelength.command[tok].append(2)
    else:
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    v_linelength.answer[tok].append("0")
    v_linelength.answer[tok].append(0)
    return


def ct_op(announcement, tok, device):
    # <c>;op[,<des>]...;number_of_valuesx,<des>;lin|log,<des>;unitx,<des>;number_of_valuesy,...
    # <c><n>
    # <c><n><n>
    item1 = announcement.split(";")
    if len(item1) > 4:
        v_linelength.command[tok].append("1")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
        # number of loops: updated later
        v_linelength.command[tok].append(0)
        v_linelength.command[tok].append(0)
        length = 0
        i = 2
        j = 0
        # elements 2, 5, 8,... have to be calculated for each dimension
        while i < len(item1):
            item = item1[i].split(",")
            length = misc_functions.length_of_int(int(item[0]))
            if i == 2:
                v_linelength.command[tok][1] += length
            # value for this dimension
            v_linelength.command[tok].append(int(item[0]))
            # length of value
            v_linelength.command[tok].append(length)
            # check!
            v_linelength.command[tok].append(2)
            i += 3
            j += 1
        # number of following parameters
        v_linelength.command[tok][2] = j
    else:
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    v_linelength.answer[tok].append("0")
    v_linelength.answer[tok].append(0)
    return


def ct_ap(announcement, tok, device):
    # <c>;ap[,<des>]...;number_of_valuesx,<des>;lin|log,<des>;unitx,<des>;number_of_valuesy,..
    # <c>
    # <c><n>    answer / info 1 dimension
    item1 = announcement.split(";")
    if len(item1) > 4:
        v_linelength.command[tok].append("1")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
        # number of loops
        v_linelength.command[tok].append(0)
        v_linelength.command[tok].append(0)

        v_linelength.answer[tok].append("1")
        # updated later
        v_linelength.answer[tok].append(0)
        # number of loopsupdated later
        v_linelength.answer[tok].append(0)
        v_linelength.answer[tok].append(0)
        item1 = announcement.split(";")
        length = 0
        i = 2
        j = 0
        first = 1
        # elements 2, 5, 8,... have to be calculated for each dimension
        while i < len(item1):
            item = item1[i].split(",")
            temp = misc_functions.length_of_int(int(item[0]))
            if i == 2:
                v_linelength.answer[tok][1] += temp
            # value of dimension
            v_linelength.answer[tok].append(int(item[0]))
            # length of value
            v_linelength.answer[tok].append(temp)
            # check!
            v_linelength.answer[tok].append(2)
            length += temp
            i += 3
            j += 1
        # for 1st loop
        # number of following parameters
        v_linelength.answer[tok][2] = j
    else:
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
        v_linelength.answer[tok].append("0")
        v_linelength.answer[tok].append(0)
    return


def ct_oo(announcement, tok, device):
    # <c>;oo,ext<c>,[<des>]...;number_of_steps[,<des>];steptime[,<des>];steptime;unit;stepsize[,<des>];<ty>...
    # <c><n><n><n><n>  1 dimension
    # <c><n><n><n><n><n><n><n><n><n>   2 dimension
    # length is calculated for the 1st loop only, so no check of values is done
    v_linelength.command[tok].append("1")
    # for 1st loop, updated later
    v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    # number of loops: updated later
    v_linelength.command[tok].append(0)
    v_linelength.command[tok].append(0)
    item = announcement.split(";")
    error = 0
    length = 0
    length_all = 0
    i = 6
    j = 0
    first = 1
    # len(item) must be 6 + x * 5 , otherwise error
    while i < len(item):
        if len(item) <= i:
            error = 1
            break
        # number_of steps
        temp = int(item[i - 4].split(",")[0])
        length += misc_functions.length_of_int(temp)
        if i == 6:
            v_linelength.command[tok][1] += length
        length_all += length
        v_linelength.command[tok].append(temp)
        v_linelength.command[tok].append(length)
        v_linelength.command[tok].append(2)
        j += 1
        # steptime
        temp = int(item[i - 3].split(",")[0])
        # not transmitted, if 0
        if temp > 0:
            length = misc_functions.length_of_int(temp)
            length_all += length
            v_linelength.command[tok].append(temp)
            v_linelength.command[tok].append(length)
            v_linelength.command[tok].append(2)
            j += 1
        # stepsize
        temp = int(item[i - 1].split(",")[0])
        # not transmitted if 0
        if temp > 0:
            length = misc_functions.length_of_int(temp)
            length_all += length
            v_linelength.command[tok].append(temp)
            v_linelength.command[tok].append(length)
            v_linelength.command[tok].append(2)
            j += 1
        # <ty>
        temp = misc_functions.ba_to_str(item[i].split(",")[0])
        if str.isnumeric(temp):
            # string not allowed
            error = 1
        else:
            length = v_cr_params.length_of_par[temp]
            length_all += length
            if length > 0:
                # not checked
                v_linelength.command[tok].append(0)
                v_linelength.command[tok].append(length)
                v_linelength.command[tok].append(1)
                j += 1
        i += 5
    # for 1st loop
    if error == 0:
        # number of following parameter blocks (2 lines each)
        v_linelength.command[tok][2] = j
    else:
        v_linelength.command[tok][0] = "0"
        v_linelength.command.append(0)
    v_linelength.answer[tok].append("0")
    v_linelength.answer[tok].append(0)
    return


def ct_oq(announcement, tok, device):
    # <c>;oq[,<des>]...[<,des>];<defaultposition>[,des]...[,des]
    # <c>
    v_linelength.command[tok].append("1")
    v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    # number of loops
    v_linelength.command[tok].append(0)
    v_linelength.command[tok].append(0)
    v_linelength.answer[tok].append("0")
    v_linelength.answer[tok].append(0)
    return


def ct_om(announcement, tok, device):
    # <c>;om[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
    # <c><z><data>
    item = announcement.split(";")
    multi = misc_functions.length_of_typ(item[2].split(",")[0])
    if multi[0] != "0":
        positionlength, positions = calc_positionlength(item)
        if multi[0] == "n":
            # numeric
            v_linelength.command[tok].append("1")
            v_linelength.command[tok].append( v_cr_params.length_commandtoken + positionlength)
            # number of loops
            v_linelength.command[tok].append(2)
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(positions)
            v_linelength.command[tok].append(positionlength)
            # check!
            v_linelength.command[tok].append(2)
            #
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(multi[1])
            # no check
            v_linelength.command[tok].append(1)
        else:
            # string
            v_linelength.command[tok].append("2")
            v_linelength.command[tok].append(v_cr_params.length_commandtoken + positionlength)
            # number of loops
            v_linelength.command[tok].append(3)
            v_linelength.command[tok].append(0)
            # max of memorycells
            v_linelength.command[tok].append(positions)
            # length of this
            v_linelength.command[tok].append(positionlength)
            # check!
            v_linelength.command[tok].append(2)
            # max stringlength
            v_linelength.command[tok].append(int(item[2].split(",")[0]))
            # length of this
            v_linelength.command[tok].append(multi[1])
            # check!
            v_linelength.command[tok].append(2)
            # string itself, noch check
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(0)
            # check!
            v_linelength.command[tok].append(1)
    else:
        # error
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    v_linelength.answer[tok].append("0")
    v_linelength.answer[tok].append(0)
    return


def ct_am(announcement, tok, device):
    # c>;am[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
    # <c><n>        commandd
    # <c><n><data>  answer / info
    item = announcement.split(";")
    multi = misc_functions.length_of_typ(item[2].split(",")[0])
    if multi[0] != "0":
        positionlength, positions = calc_positionlength(item)
        v_linelength.command[tok].append("1")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken + positionlength)
        # number of loops
        v_linelength.command[tok].append(1)
        v_linelength.command[tok].append(0)
        v_linelength.command[tok].append(positions)
        v_linelength.command[tok].append(positionlength)
        # check !
        v_linelength.command[tok].append(2)

        if multi[0] == "n":
            # numeric
            v_linelength.answer[tok].append("1")
            v_linelength.answer[tok].append(positionlength)
            # number of loops
            v_linelength.answer[tok].append(2)
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(positions)
            v_linelength.answer[tok].append(positionlength)
            # check!
            v_linelength.answer[tok].append(2)
            #
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(multi[1])
            # no check
            v_linelength.answer[tok].append(1)
        else:
            # string
            v_linelength.answer[tok].append("2")
            # length for 1st loop: length of length of cellnumber
            v_linelength.answer[tok].append(positionlength)
            # number of loops
            v_linelength.answer[tok].append(3)
            v_linelength.answer[tok].append(0)
            # max of memorycells
            v_linelength.answer[tok].append(positions)
            # length of this
            v_linelength.answer[tok].append(positionlength)
            # check!
            v_linelength.answer[tok].append(2)
            # max stringlength
            v_linelength.answer[tok].append(int(item[2].split(",")[0]))
            # length of this
            v_linelength.answer[tok].append(multi[1])
            # check"
            v_linelength.answer[tok].append(2)
            # string itself
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(0)
            # check"
            v_linelength.answer[tok].append(1)
    else:
        # error
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(v_dev.length_commandtoken)
        v_linelength.answer[tok].append("0")
        v_linelength.answer[tok].append(0)
    return


def calc_positionlength(item):
    # number of memory positions
    i = 3
    positions = 1
    while i < len(item):
        item1 = item[i].split(",")
        positions *= int(item1[0])
        i += 1
    # positions "0" based:
    positions -= 1
    return misc_functions.length_of_int(positions), positions


def ct_on(announcement, tok, device):
    # <c>;on[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
    # <c><n><m><data>
    item = announcement.split(";")
    multi = misc_functions.length_of_typ(item[2].split(",")[0])
    if multi[0] != "0":
        positionlength, positions = calc_positionlength(item)
        v_linelength.command[tok].append("3")
        # length for 1st loop: length_of_commandtoken + length of startcell * length of length of cellnumber
        v_linelength.command[tok].append(v_cr_params.length_commandtoken + positionlength)

        # number of loops, updated later
        v_linelength.command[tok].append(0)
        v_linelength.command[tok].append(0)
        # startposition for transfer
        v_linelength.command[tok].append(positions)
        v_linelength.command[tok].append(positionlength)
        # check!
        v_linelength.command[tok].append(2)
        # number of elements to transfer
        v_linelength.command[tok].append(positions)
        v_linelength.command[tok].append(positionlength)
        # check!
        v_linelength.command[tok].append(2)

        if multi[0] == "n":
            v_linelength.command[tok][2] = 3
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(multi[1])
            # no check!
            v_linelength.command[tok].append(1)
        elif multi[0] == "s":
            # string
            v_linelength.command[tok][0] = "4"
            v_linelength.command[tok][2] = 4
            v_linelength.command[tok].append(int(item[2].split(",")[0]))
            v_linelength.command[tok].append(multi[1])
            # check!
            v_linelength.command[tok].append(2)
            # string itself
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(multi[1])
            # nop check!
            v_linelength.command[tok].append(1)
        else:
            v_linelength.command[tok].append("0")
            v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    else:
        # error
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    v_linelength.answer[tok].append("0")
    v_linelength.answer[tok].append(0)
    return


def ct_an(announcement, tok, device):
    # c>;an[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
    # <c><n><m>
    # <c><n><m><data> abswere / info
    item = announcement.split(";")
    multi = misc_functions.length_of_typ(item[2].split(",")[0])
    if multi[0] != "0":
        positionlength, positions = calc_positionlength(item)
        v_linelength.command[tok].append("1")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken + positionlength)

        v_linelength.command[tok].append(2)
        v_linelength.command[tok].append(0)
        # startposition for transfer
        v_linelength.command[tok].append(positions)
        v_linelength.command[tok].append(positionlength)
        # check!
        v_linelength.command[tok].append(2)
        # number of elements to transfer
        v_linelength.command[tok].append(positions)
        v_linelength.command[tok].append(positionlength)
        # check!
        v_linelength.command[tok].append(2)

        v_linelength.answer[tok].append("3")
        v_linelength.answer[tok].append(positionlength)
        # updated later
        v_linelength.answer[tok].append(0)
        v_linelength.answer[tok].append(0)
        # startposition for transfer
        v_linelength.answer[tok].append(positions)
        v_linelength.answer[tok].append(positionlength)
        # check!
        v_linelength.answer[tok].append(2)
        # number of elements to transfer
        v_linelength.answer[tok].append(positions)
        v_linelength.answer[tok].append(positionlength)
        # check!
        v_linelength.answer[tok].append(2)
        if multi[0] == "n":
            v_linelength.answer[tok][2] = 3
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(multi[1])
            # no check!
            v_linelength.answer[tok].append(1)
        elif multi[0] == "s":
            # string
            v_linelength.answer[tok][0] = "4"
            v_linelength.answer[tok][2] = 6
            v_linelength.answer[tok].append(int(item[2].split(",")[0]))
            v_linelength.answer[tok].append(multi[1])
            # check!
            v_linelength.answer[tok].append(2)
            # string itself
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(multi[1])
            # nop check!
            v_linelength.answer[tok].append(1)
            # 2 previous blocks must be repeated due to simpler analyze program
            v_linelength.answer[tok].append(int(item[2].split(",")[0]))
            v_linelength.answer[tok].append(multi[1])
            # check!
            v_linelength.answer[tok].append(2)
            # string itself
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(multi[1])
            # nop check!
            v_linelength.answer[tok].append(1)
        else:
            v_linelength.answer[tok].append("0")
            v_linelength.answer[tok].append(0)
    else:
        # error
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
        v_linelength.answer[tok].append("0")
        v_linelength.answer[tok].append(0)
    return


def ct_of(announcement, tok, device):
    # <c>;of[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]
    # <c><m><data>
    item = announcement.split(";")
    multi = misc_functions.length_of_typ(item[2].split(",")[0])
    if multi[0] != "0":
        positionlength, positions = calc_positionlength(item)
        v_linelength.command[tok].append("5")
        # length for 1st loop: length_of_commandtoken + length of startcell
        v_linelength.command[tok].append(v_cr_params.length_commandtoken + positionlength)

        # number of loops, updated later
        v_linelength.command[tok].append(0)
        v_linelength.command[tok].append(0)

        # number of elements to transfer
        v_linelength.command[tok].append(positions)
        v_linelength.command[tok].append(positionlength)
        # check!
        v_linelength.command[tok].append(2)

        if multi[0] == "n":
            v_linelength.command[tok][2] = 2
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(multi[1])
            # no check!
            v_linelength.command[tok].append(1)
        elif multi[0] == "s":
            # string
            v_linelength.command[tok][0] = "6"
            v_linelength.command[tok][2] = 5
            v_linelength.command[tok].append(int(item[2].split(",")[0]))
            v_linelength.command[tok].append(multi[1])
            # check!
            v_linelength.command[tok].append(2)
            # string itself
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(multi[1])
            # nop check!
            v_linelength.command[tok].append(1)
            # 2 previous blocks must be repeated due to simpler analyze program
            v_linelength.command[tok].append(int(item[2].split(",")[0]))
            v_linelength.command[tok].append(multi[1])
            # check!
            v_linelength.command[tok].append(2)
            # string itself
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(multi[1])
            # nop check!
            v_linelength.command[tok].append(1)
        else:
            v_linelength.command[tok].append("0")
            v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    else:
        # error
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    v_linelength.answer[tok].append("0")
    v_linelength.answer[tok].append(0)
    return


def ct_af(announcement, tok, device):
    # c>;an[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>]
    # <c><m>
    # <c><m><data>     answer / info
    item = announcement.split(";")
    multi = misc_functions.length_of_typ(item[2].split(",")[0])
    if multi[0] != "0":
        positionlength, positions = calc_positionlength(item)
        v_linelength.command[tok].append("1")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken + positionlength)

        v_linelength.command[tok].append(1)
        v_linelength.command[tok].append(0)
        # number of elements to transfer
        v_linelength.command[tok].append(positions)
        v_linelength.command[tok].append(positionlength)
        # check!
        v_linelength.command[tok].append(2)

        v_linelength.answer[tok].append("5")
        v_linelength.answer[tok].append(positionlength)
        # updated later
        v_linelength.answer[tok].append(0)
        v_linelength.answer[tok].append(0)

        # number of elements to transfer
        v_linelength.answer[tok].append(positions)
        v_linelength.answer[tok].append(positionlength)
        # check!
        v_linelength.answer[tok].append(2)
        if multi[0] == "n":
            v_linelength.answer[tok][2] = 2
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(multi[1])
            # no check!
            v_linelength.answer[tok].append(1)
        elif multi[0] == "s":
            # string
            v_linelength.answer[tok][0] = "6"
            v_linelength.answer[tok][2] = 5
            v_linelength.answer[tok].append(int(item[2].split(",")[0]))
            v_linelength.answer[tok].append(multi[1])
            # check!
            v_linelength.answer[tok].append(2)
            # string itself
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(multi[1])
            # nop check!
            v_linelength.answer[tok].append(1)
            # 2 previous blocks must be repeated due to simpler analyze program
            v_linelength.answer[tok].append(int(item[2].split(",")[0]))
            v_linelength.answer[tok].append(multi[1])
            # check!
            v_linelength.answer[tok].append(2)
            # string itself
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(multi[1])
            # nop check!
            v_linelength.answer[tok].append(1)
        else:
            v_linelength.answer[tok].append("0")
            v_linelength.answer[tok].append(0)
    else:
        # error
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
        v_linelength.answer[tok].append("0")
        v_linelength.answer[tok].append(0)
    return


def ct_oa(announcement, tok, device):
    # <c>;oa[,<des>]...[,<des>];<ty>[,<des>]...[;<ty>[,<des>]]
    # <c><n><data>
    item = announcement.split(";")
    positions = len(item)
    positionlength = misc_functions.length_of_int(positions)
    if positions < 3:
        # no data for memory, announcementerror
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    else:
        v_linelength.command[tok].append("7")
        if positions == 3:
            item1 = item[2].split(",")[0]
            # updated later
            v_linelength.command[tok].append(0)
            # number of loops
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(0)
            if str.isnumeric(item1):
                # string
                v_linelength.command[tok][1] = v_cr_params.length_commandtoken + misc_functions.length_of_int(int(item1))
                v_linelength.command[tok].append(int(item1))
                v_linelength.command[tok].append(misc_functions.length_of_int(int(item1)))
                # length of string
                v_linelength.command[tok].append(3)
            else:
                # numeric
                v_linelength.command[tok][1] = v_cr_params.length_commandtoken + v_cr_params.length_of_par[item1]
                v_linelength.command[tok].append(0)
                v_linelength.command[tok].append(v_cr_params.length_of_par[item1])
                # no check!
                v_linelength.command[tok].append(1)
        else:
            # number of positions, not index
            positions -= 2
            # length for 1st loop: length_of_commandtoken + length of startcell
            v_linelength.command[tok].append(v_cr_params.length_commandtoken + positionlength)
            # number of loops (minimum)
            v_linelength.command[tok].append(1)
            v_linelength.command[tok].append(0)

            # elementposition
            v_linelength.command[tok].append(positions)
            v_linelength.command[tok].append(positionlength)
            # check!
            v_linelength.command[tok].append(2)

            i = 0
            while i < positions:
                item1 = item[i + 2].split(",")[0]
                # type is string / numeric ?
                if str.isnumeric(item1):
                    # string
                    v_linelength.command[tok].append(int(item1))
                    v_linelength.command[tok].append(misc_functions.length_of_int(int(item1)))
                    # check!
                    v_linelength.command[tok].append(3)
                else:
                    # numeric
                    v_linelength.command[tok].append(0)
                    v_linelength.command[tok].append(v_cr_params.length_of_par[item1])
                    # no check!
                    v_linelength.command[tok].append(1)
                i += 1
    v_linelength.answer[tok].append("0")
    v_linelength.answer[tok].append(0)
    return


def ct_aa(announcement, tok, device):
    # <c>,aa[,<des>]...[,<des>];<ty>[,<des>];<ty>[,<des>]...
    # <c><n>
    # <data>
    item = announcement.split(";")
    positions = len(item)
    positionlength = misc_functions.length_of_int(positions)
    if positions < 3:
        # no data for memory, announcementerror
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(0)
        v_linelength.answer[tok].append("0")
        v_linelength.answer[tok].append(0)
    else:
        v_linelength.command[tok].append("1")
        if positions == 3:
            # 1st loop
            v_linelength.command[tok].append(v_cr_params.length_commandtoken)
            # number of loops
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(0)
        else:
            v_linelength.command[tok].append(v_cr_params.length_commandtoken + positionlength)
            # number of loops
            v_linelength.command[tok].append(1)
            v_linelength.command[tok].append(0)

            v_linelength.command[tok].append(positions - 3)
            v_linelength.command[tok].append(positionlength)
            # check !
            v_linelength.command[tok].append(2)

        v_linelength.answer[tok].append("7")
        if positions == 3:
            item1 = item[2].split(",")
            # updated later
            v_linelength.answer[tok].append(0)
            # number of loops
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(0)
            if str.isnumeric(item1[0]):
                # max length of string
                v_linelength.answer[tok][1] = misc_functions.length_of_int(int(item1[0]))
                v_linelength.answer[tok].append(int(item1[0]))
                v_linelength.answer[tok].append(misc_functions.length_of_int(int(item1[0])))
                # check!
                v_linelength.answer[tok].append(3)
            else:
                # numeric
                v_linelength.answer[tok][1] = v_cr_params.length_of_par[item1[0]]
                v_linelength.answer[tok].append(0)
                v_linelength.answer[tok].append(v_cr_params.length_of_par[item1[0]])
                # no check!
                v_linelength.answer[tok].append(1)
        else:
            # number of positions, not index
            positions -= 2
            # length for 1st loop: length_of_commandtoken + length of startcell
            v_linelength.answer[tok].append(positionlength)
            # number of loops
            v_linelength.answer[tok].append(1)
            v_linelength.answer[tok].append(0)

            # elementposition
            v_linelength.answer[tok].append(positions)
            v_linelength.answer[tok].append(positionlength)
            # check!
            v_linelength.answer[tok].append(2)

            i = 0
            while i < positions:
                item1 = item[i + 2].split(",")
                # type is string / numeric ?
                if str.isnumeric(item1[0]):
                    # length of string
                    v_linelength.answer[tok].append(int(item1[0]))
                    v_linelength.answer[tok].append(misc_functions.length_of_int(int(item1[0])))
                    # check!
                    v_linelength.answer[tok].append(3)
                else:
                    # numeric
                    v_linelength.answer[tok].append(0)
                    v_linelength.answer[tok].append(v_cr_params.length_of_par[item1[0]])
                    # no check!
                    v_linelength.answer[tok].append(1)
                i += 1
    return


def ct_ob(announcement, tok, device):
    # <c>;ob[,<des>]...[,<des>];<ty>[,<des>]...[;<ty>[,<des>]]
    # <c><n><m><data>
    item = announcement.split(";")
    positions = len(item)
    positionlength = misc_functions.length_of_int(positions)
    if positions < 3:
        # no data for memory, announcementerror
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken)
    else:
        v_linelength.command[tok].append("8")
        # number of positions, not index
        positions -= 2
        # length for 1st loop: length_of_commandtoken + length of startcell
        v_linelength.command[tok].append(v_cr_params.length_commandtoken + positionlength)
        # number of loops
        v_linelength.command[tok].append(2)
        v_linelength.command[tok].append(0)

        # start of elements
        v_linelength.command[tok].append(positions)
        v_linelength.command[tok].append(positionlength)
        # check!
        v_linelength.command[tok].append(2)
        # number of elements
        v_linelength.command[tok].append(positions)
        v_linelength.command[tok].append(positionlength)
        # check!
        v_linelength.command[tok].append(2)

        i = 0
        while i < positions:
            item1 = item[i + 2].split(",")
            # type is string / numeric ?
            if str.isnumeric(item1[0]):
                # string
                v_linelength.command[tok].append(int(item1[0]))
                v_linelength.command[tok].append(misc_functions.length_of_int(int(item1[0])))
                # check!
                v_linelength.command[tok].append(3)
            else:
                # numeric
                v_linelength.command[tok].append(0)
                v_linelength.command[tok].append(v_cr_params.length_of_par[item1[0]])
                # no check!
                v_linelength.command[tok].append(1)
            i += 1
    v_linelength.answer[tok].append("0")
    v_linelength.answer[tok].append(0)
    return


def ct_ab(announcement, tok, device):
    # <c>;ab[,<des>]...[,<des>];<ty>[,<des>]...[;<ty>[,<des>]
    item = announcement.split(";")
    positions = len(item)
    positionlength = misc_functions.length_of_int(positions)
    if positions < 3:
        # no data for memory, announcementerror
        v_linelength.command[tok].append("0")
        v_linelength.command[tok].append(0)
        v_linelength.answer[tok].append("0")
        v_linelength.answer[tok].append(0)
    else:
        v_linelength.command[tok].append("1")
        v_linelength.command[tok].append(v_cr_params.length_commandtoken + positionlength)
        # number of loops
        v_linelength.command[tok].append(2)
        v_linelength.command[tok].append(0)
        # start element
        v_linelength.command[tok].append(positions - 2)
        v_linelength.command[tok].append(positionlength)
        # check !
        v_linelength.command[tok].append(2)
        # number of elements
        v_linelength.command[tok].append(positions - 2)
        v_linelength.command[tok].append(positionlength)
        # check !
        v_linelength.command[tok].append(2)

        v_linelength.answer[tok].append("8")
        # number of positions, not index
        positions -= 2
        # length for 1st loop: length of startcell
        v_linelength.answer[tok].append(positionlength)
        # number of loops
        v_linelength.answer[tok].append(2)
        v_linelength.answer[tok].append(0)

        # start element
        v_linelength.answer[tok].append(positions)
        v_linelength.answer[tok].append(positionlength)
        # check!
        v_linelength.answer[tok].append(2)
        # number of elements
        v_linelength.answer[tok].append(positions)
        v_linelength.answer[tok].append(positionlength)
        # check!
        v_linelength.answer[tok].append(2)

        i = 0
        while i < positions:
            item1 = item[i + 2].split(",")
            # type is string / numeric ?
            if str.isnumeric(item1[0]):
                # string
                v_linelength.answer[tok].append(int(item1[0]))
                v_linelength.answer[tok].append(misc_functions.length_of_int(int(item1[0])))
                # check!
                v_linelength.answer[tok].append(3)
            else:
                # numeric
                v_linelength.answer[tok].append(0)
                v_linelength.answer[tok].append(v_cr_params.length_of_par[item1[0]])
                # no check!
                v_linelength.answer[tok].append(1)
            i += 1
    return

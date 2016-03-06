"""
calculate the length of of transmitted data for a actual command depending on commandtype
called at initialization
ct_xx :xx is the commmandtyp, for detailed description see MYC documentation
for details description of variable v_linelength
answer and info is identical except for memory commands
answer and info result in error for operating commandtoken.
length for commmands include command, answer and info do not
"""

import commandrouter_misc_functions
import v_linelength
import v_command_length
import v_constants


def ct_m(announcement, tok):
    # is not used
    # command only
    v_linelength.command[tok].append("b")
    v_linelength.command[tok].append(0)
    # string
    v_linelength.answer[tok].append("s")
    v_linelength.answer[tok].append(1)
    v_linelength.answer[tok].append(0)
    v_linelength.answer[tok].append(1)
    # string
    v_linelength.info[tok].append("s")
    v_linelength.info[tok].append(1)
    v_linelength.info[tok].append(0)
    v_linelength.info[tok].append(1)
    return


def ct_oc(announcement, tok):
    # announce:	<c>;oc[,<des>]...[,<des>];max_number_of_token
    # command:	<c>0|1<s

    item = announcement.split(";")
    item1 = item[2].split(",")
    # length of stringlength
    l = commandrouter_misc_functions.length_of_int(int(item1[0])*v_command_length.commandtokenlength)
    v_linelength.command[tok].append("c")
    # 1 for 0|1
    v_linelength.command[tok].append(v_command_length.commandtokenlength + 1 + l)
    # length of stringlength
    v_linelength.command[tok].append(l)
    # length string, added in real time
    v_linelength.command[tok].append(0)
    v_linelength.command[tok].append(1)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_od(announcement, tok):
    # nnounce:	<c>;od[,<des>]...[,<des>];<c><,des>;...<c><,des>
    # command:	<c>0|1
    # number of bytes for max length of string  * number of bytes for length of string of following commandtoken
    # 0|1 only
    v_linelength.command[tok].append("n")
    v_linelength.command[tok].append(v_command_length.commandtokenlength + 1)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_ac(announcement, tok):
    # announce:	<c>;ac[,<des>]...[,<des>];max_number_of_token
    # command:	<c><s>
    # answer:	<s>
    # info:		<c><s>
    item = announcement.split(";")
    item1 = item[2].split(",")
    # length of stringlength
    l = commandrouter_misc_functions.length_of_int(int(item1[0])*v_command_length.commandtokenlength)
    v_linelength.command[tok].append("c")
    v_linelength.command[tok].append(v_command_length.commandtokenlength + l)
    v_linelength.command[tok].append(l)
    v_linelength.command[tok].append(0)
    v_linelength.command[tok].append(0)
    v_linelength.answer[tok].append("s")
    v_linelength.answer[tok].append(0)
    v_linelength.answer[tok].append(1)
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("s")
    v_linelength.info[tok].append(0)
    v_linelength.info[tok].append(1)
    v_linelength.info[tok].append(0)
    return


def ct_ad(announcement, tok):
    # announce:	<c>;ad[,<des>]...[,<des>];<c><,des>;...<c><,des>
    # c ommand:	<c>
    # answer:	<0|1>
    # info:		<c><0|1>
    v_linelength.command[tok].append("b")
    v_linelength.command[tok].append(v_command_length.commandtokenlength)
    v_linelength.answer[tok].append("n")
    v_linelength.answer[tok].append(1)
    v_linelength.info[tok].append("n")
    v_linelength.info[tok].append(1)
    return


def ct_ic(announcement, tok):
    # info:		<c><s><s>
    v_linelength.command[tok].append("e")
    v_linelength.command[tok].append(0)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_id(announcement, tok):
    # info:		<c><s>
    v_linelength.command[tok].append("e")
    v_linelength.command[tok].append(0)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_nc(announcement, tok):
    # <c>;nc
    v_linelength.command[tok].append("e")
    v_linelength.command[tok].append(0)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_or(announcement, tok):
    # <c>;or[,<des>]...[,<des>];pos0[,<des>]...[;posn,[<des>]][;<OPTION>[,<des>]...	]
    # <c>0|1
    # <c>0|1<n>
    number_of_items = strip_dimension(announcement)
    # must be more than 2
    if number_of_items > 2:
        v_linelength.command[tok].append("n")
        if number_of_items == 3:
            # 0|1
            v_linelength.command[tok].append(v_command_length.commandtokenlength + 1)
        if number_of_items > 3:
            v_linelength.command[tok].append(v_command_length.commandtokenlength + commandrouter_misc_functions.length_of_int(number_of_items) + 1)
    else:
        v_linelength.command[tok].append("e")
        v_linelength.command[tok].append(0)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_os(announcement, tok):
    # <c>;os[,<des>]...[,<des>];pos0[,<des>];...posn[.<des>][;<OPTION>[,<des>]...	]
    # <c><n>
    number_of_items = strip_dimension(announcement)
    # must be more than 2
    if number_of_items > 2:
        v_linelength.command[tok].append("n")
        v_linelength.command[tok].append(v_command_length.commandtokenlength + commandrouter_misc_functions.length_of_int(number_of_items))
    else:
        v_linelength.command[tok].append("e")
        v_linelength.command[tok].append(0)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_ot(announcement, tok):
    # <c>;ot[,<des>]...[,<des>];[pos0[,<des>];...posn[,<des>][;<OPTION>[,<des>]...	]
    # <c>
    v_linelength.command[tok].append("b")
    v_linelength.command[tok].append(v_command_length.commandtokenlength)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_ou(announcement, tok):
    # <c>;ou[,<des>]...[<,des>];pos0[,<des>];...;posn[,<des>][;<OPTION>[,<des>]...	]
    # <c>
    # <c><n>
    number_of_items = strip_dimension(announcement)
    # must be more than 2
    if number_of_items > 2:
        if number_of_items == 3:
            v_linelength.command[tok].append("b")
            v_linelength.command[tok].append(v_command_length.commandtokenlength)
        if number_of_items > 3:
            v_linelength.command[tok].append("n")
            v_linelength.command[tok].append(v_command_length.commandtokenlength + commandrouter_misc_functions.length_of_int(number_of_items))
    else:
        v_linelength.command[tok].append("e")
        v_linelength.command[tok].append(0)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_ar(announcement, tok):
    # <c>;ar[,<des>]...[,<des>];pos0[,<des>].[;posn,[<des>]][;<OPTION>[,<des>]...	]
    # <c>
    # <c><n>
    # &H00|&H01  answer
    number_of_items = strip_dimension(announcement)
    # must be more than 2
    if number_of_items > 2:
        if number_of_items == 3:
            v_linelength.command[tok].append("b")
            v_linelength.command[tok].append(v_command_length.commandtokenlength)
        if number_of_items > 3:
            v_linelength.command[tok].append("n")
            v_linelength.command[tok].append(v_command_length.commandtokenlength + commandrouter_misc_functions.length_of_int(number_of_items))
    else:
        v_linelength.command[tok].append("n")
        v_linelength.command[tok].append(1)
    v_linelength.answer[tok].append("n")
    v_linelength.answer[tok].append(commandrouter_misc_functions.length_of_int(number_of_items))
    v_linelength.info[tok].append("n")
    v_linelength.info[tok].append(commandrouter_misc_functions.length_of_int(number_of_items))
    return


def ct_as(announcement, tok):
    # <c>;as[,<des>]...[,<des>];pos0[,<des>];...posn[.<des>][;<OPTION>[,<des>]...	]
    # <c>
    # <n>    answer
    # <c>;at[,<des>]...[,<des>];[pos0[,<des>];...posn[,<des>][;<OPTION>[,<des>]...	]
    # <c>
    # <n>        answer
    number_of_items = strip_dimension(announcement)
    v_linelength.command[tok].append("b")
    v_linelength.command[tok].append(v_command_length.commandtokenlength)
    v_linelength.answer[tok].append("n")
    v_linelength.answer[tok].append(commandrouter_misc_functions.length_of_int(number_of_items))
    v_linelength.info[tok].append("n")
    v_linelength.info[tok].append(commandrouter_misc_functions.length_of_int(number_of_items))
    return


def ct_au(announcement, tok):
    # announce:	<c>;au[,<des>]...[<,des>];pos0[,<des>];...;posn[,<des>][;<n>,<OPTION>[,<des>]...	]
    # not defined for answer, info only
    number_of_items = strip_dimension(announcement)
    v_linelength.command[tok].append("b")
    v_linelength.command[tok].append(v_command_length.commandtokenlength)
    v_linelength.answer[tok].append("n")
    v_linelength.answer[tok].append(commandrouter_misc_functions.length_of_int(number_of_items))
    v_linelength.info[tok].append("n")
    v_linelength.info[tok].append(commandrouter_misc_functions.length_of_int(number_of_items))
    return


def ct_op(announcement, tok):
    # <c>;op[,<des>]...[<,des>];<ranges>,<des>;unitx,<des>;<lin|log>,<des>;minx,<des>;maxx,<des>...
    # <c><n>
    # <c><n><n>
    v_linelength.command[tok].append("n")
    item1 = announcement.split(";")
    length = 0
    i = 2
    # elements 2, 5, 8,... have to be calculated
    while i < len(item1):
        item = item1[i].split(",")
        length += commandrouter_misc_functions.length_of_int(int(item[0]))
        i += 3
    v_linelength.command[tok].append(v_command_length.commandtokenlength+length)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_oo(announcement, tok):
    # <c>;oo[,<des>]...[<,des>];max_number_of_steps;steptimemin,<des>;steptimemax[,<des>];stepsizemin[,<des>];stepsizemax[,<des>];stepsizemiddle,<des>...
    # <c>0<n><n>
    # <c>&H02&H01&H08
    v_linelength.command[tok].append("n")
    item = announcement.split(";")
    length = 0
    i = 2
    # elements 2, 5, 8,... have to be calculated
    while i < len(item):
        # number_of steps
        length += commandrouter_misc_functions.length_of_int(int(item[i].split(",")[0]))
        # steptime
        length += commandrouter_misc_functions.length_of_int(int(item[i+2].split(",")[0])-int(item[i+1].split(",")[0]))
        # stepsize
        length += commandrouter_misc_functions.length_of_int(int(item[i+4].split(",")[0])-int(item[i+3].split(",")[0]))
        i += 6
    v_linelength.command[tok].append(v_command_length.commandtokenlength+length)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_oq(announcement, tok):
    # <c>;oq[,<des>]...[<,des>];<defaultposition>[,des]...[,des]
    # <c>
    v_linelength.command[tok].append("b")
    v_linelength.command[tok].append(v_command_length.commandtokenlength)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_ap(announcement, tok):
    # <c>;ap[,<des>]...[<,des>];<ranges>,<des>;unitx,<des>;<lin|log>,<des>;min,<des>;max,<des>....;<ranges>...
    # <c>
    # <n>    onswer 1 dinension
    v_linelength.command[tok].append("b")
    v_linelength.command[tok].append(v_command_length.commandtokenlength)
    v_linelength.answer[tok].append("n")
    v_linelength.info[tok].append("n")
    item1 = announcement.split(";")
    length = 0
    i = 2
    # elements 2, 5, 8,... have to be calculated
    while i < len(item1):
        item = item1[i].split(",")
        length += commandrouter_misc_functions.length_of_int(int(item[0]))
        i += 3
    v_linelength.answer[tok].append(length)
    v_linelength.info[tok].append(length)
    return


def ct_om(announcement, tok):
    # <c>;om[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
    # <c><z><data>
    item = announcement.split(";")
    multi = commandrouter_misc_functions.length_of_typ(item[2].split(",")[0])
    if multi[0] != "e":
        i = 3
        positions = 1
        while i < len(item):
            item1 = item[i].split(",")
            positions *= int(item1[0])
            i += 1
        positionlength = commandrouter_misc_functions.length_of_int(positions)
        if multi[0] == "n":
            v_linelength.command[tok].append("n")
            v_linelength.command[tok].append(v_command_length.commandtokenlength + positionlength + multi[1])
        if multi[0] == "s":
            v_linelength.command[tok].append("s")
            v_linelength.command[tok].append(v_command_length.commandtokenlength + positionlength + multi[1])
            v_linelength.command[tok].append(positionlength)
            v_linelength.command[tok].append(multi[1])
    else:
        v_linelength.command[tok].append("e")
        v_linelength.command[tok].append(0)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_on(announcement, tok):
    # <c>;on[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
    # <c><z><data>
    item = announcement.split(";")
    multi = commandrouter_misc_functions.length_of_typ(item[2].split(",")[0])
    if multi[0] != "e":
        i = 3
        positions = 1
        while i < len(item):
            item1 = item[i].split(",")
            positions *= int(item1[0])
            i += 1
        positionlength = commandrouter_misc_functions.length_of_int(positions)
        if multi[0] == "n":
            v_linelength.command[tok].append("m")
            # 2: start and length
            v_linelength.command[tok].append(v_command_length.commandtokenlength + 2 * positionlength)
            v_linelength.command[tok].append(2 * positionlength)
            v_linelength.command[tok].append(multi[1])
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(0)
        if multi[0] == "s":
            v_linelength.command[tok].append("t")
            v_linelength.command[tok].append(v_command_length.commandtokenlength + 2 * positionlength)
            v_linelength.command[tok].append(2 * positionlength)
            v_linelength.command[tok].append(multi[1])
            v_linelength.command[tok].append(0)
    else:
        v_linelength.command[tok].append("e")
        v_linelength.command[tok].append(0)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_of(announcement, tok):
    # <c>;of[,<des>]...[,<des>];<n>,<des>;<ty>[,<des>]
    # <c><n><data>
    item = announcement.split(";")
    number_of_elements = int(item[2].split(",")[0])
    multi = commandrouter_misc_functions.length_of_typ(item[3].split(",")[0])
    if multi[0] == "e":
        v_linelength.command[tok].append("e")
        v_linelength.command[tok].append(0)
    else:
        if multi[0] == "n":
            v_linelength.command[tok].append("m")
            v_linelength.command[tok].append(v_command_length.commandtokenlength + commandrouter_misc_functions.length_of_int(number_of_elements))
            v_linelength.command[tok].append(v_command_length.commandtokenlength + commandrouter_misc_functions.length_of_int(number_of_elements))
            v_linelength.command[tok].append(multi[1])
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(0)
        else:
            v_linelength.command[tok].append("t")
            v_linelength.command[tok].append(v_command_length.commandtokenlength + commandrouter_misc_functions.length_of_int(number_of_elements))
            v_linelength.command[tok].append(commandrouter_misc_functions.length_of_int(number_of_elements))
            v_linelength.command[tok].append(multi[1])
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(0)
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_oa(announcement, tok):
    # <c>;oa[,<des>]...[,<des>];<ty>[,<des>]...[;<ty>[,<des>]]
    # <c><n><data>
    item = announcement.split(";")
    number_of_position = len(item) - 2
    # one parameter
    if number_of_position == 1:
        item1 = item[2].split(",")
        # type is string
        if str.isnumeric(item1[0]):
            v_linelength.command[tok].append("s")
            # no position parameter
            v_linelength.command[tok].append(v_command_length.commandtokenlength + (commandrouter_misc_functions.length_of_int(int(item1[0]))))
            # no position parameter
            v_linelength.command[tok].append(0)
            # length of stringlength
            v_linelength.command[tok].append(commandrouter_misc_functions.length_of_int(int(item1[0])))
            v_linelength.command[tok].append(0)
        else:
            v_linelength.command[tok].append("n")
            v_linelength.command[tok].append(v_command_length.commandtokenlength + v_constants.length_of_par[item1[0]])
    # more than 1 parameter; commandtype must be found at realtime
    else:
        v_linelength.command[tok].append("t")
        # wait , until position is found
        v_linelength.command[tok].append(v_command_length.commandtokenlength + commandrouter_misc_functions.length_of_int(number_of_position))
        # start with 3rd element and use 3rd element of
        # v_input_buffer_actual_command_length.command[number_of_input_buffer
        i = 2
        while i < len(item):
            v_linelength.command[tok].append([])
            item1 = item[i].split(",")
            if str.isnumeric(item1[0]):
                # length for stringlength
                l = commandrouter_misc_functions.length_of_int(int(item1[0]))
                v_linelength.command[tok][i].append("s")
                v_linelength.command[tok][i].append(v_command_length.commandtokenlength + commandrouter_misc_functions.length_of_int(number_of_position) + l)
                # length of stringlength
                v_linelength.command[tok][i].append(l)
                # length string, added in real time
                v_linelength.command[tok][i].append(0)
            else:
                v_linelength.command[tok][i].append("n")
                v_linelength.command[tok][i].append(v_constants.length_of_par[item1[0]])
            i += 1
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_ob(announcement, tok):
    # <c>;ob[,<des>]...[,<des>];<ty>[,<des>]...[;<ty>[,<des>]]
    # <c><n><m><data>
    item = announcement.split(";")
    item1 = item[1].split(",")
    number_of_position = len(item) - 2
    # one parameter
    if number_of_position == 1:
        item1 = item[2].split(",")
        if str.isnumeric(item1[0]):
            v_linelength.command[tok].append("s")
            # no position parameter
            v_linelength.command[tok].append(v_command_length.commandtokenlength)
            # length of stringlength
            v_linelength.command[tok].append(commandrouter_misc_functions.length_of_int(int(item1[0])))
            # length string, added in real time
            v_linelength.command[tok].append(0)
        else:
            v_linelength.command[tok].append("n")
            v_linelength.command[tok].append(v_command_length.commandtokenlength+v_constants.length_of_par[item1[0]])
    # more than 1 parameter; commandtype must be found at realtime
    else:
        v_linelength.command[tok].append("t")
        # wait , until position is found
        # wait , until position is found
        v_linelength.command[tok].append(v_command_length.commandtokenlength + commandrouter_misc_functions.length_of_int(number_of_position))
        # start with 3rd element and use 3rd element of
        # v_input_buffer_actual_command_length.command[number_of_input_buffer
        i = 2
        while i < len(item):
            v_linelength.command[tok].append([])
            item1 = item[i].split(",")
            if str.isnumeric(item1[0]):
                # length for stringlength
                l = commandrouter_misc_functions.length_of_int(int(item1[0]))
                v_linelength.command[tok][i].append("s")
                v_linelength.command[tok][i].append(v_command_length.commandtokenlength + commandrouter_misc_functions.length_of_int(number_of_position) + l)
                # length of stringlength
                v_linelength.command[tok][i].append(l)
                # length string, added in real time
                v_linelength.command[tok][i].append(0)
            else:
                v_linelength.command[tok][i].append("n")
                v_linelength.command[tok][i].append(v_constants.length_of_par[item1[0]])
            i += 1
    v_linelength.answer[tok].append("e")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("e")
    v_linelength.info[tok].append(0)
    return


def ct_am(announcement, tok):
    # c>;am[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
    # <c><n>
    # <data>
    # <n><data>
    item = announcement.split(";")
    multi = commandrouter_misc_functions.length_of_typ(item[2].split(",")[0])
    # valid type found
    if multi[0] != "e":
        i = 3
        positions = 1
        while i < len(item):
            item1 = item[i].split(",")
            positions *= int(item1[0])
            i += 1
        # length for number of memory elements
        positionlength = commandrouter_misc_functions.length_of_int(positions)
        v_linelength.command[tok].append("n")
        v_linelength.command[tok].append(v_command_length.commandtokenlength + positionlength)
        if multi[0] == "n":
            v_linelength.answer[tok].append("n")
            v_linelength.answer[tok].append(multi[1])
            v_linelength.info[tok].append("n")
            v_linelength.info[tok].append(positionlength + multi[1])
        if multi[0] == "s":
            v_linelength.answer[tok].append("s")
            v_linelength.answer[tok].append(multi[1])
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(multi[1])
            v_linelength.info[tok].append("s")
            v_linelength.info[tok].append(positionlength + multi[1])
            v_linelength.answer[tok].append(positionlength)
            v_linelength.info[tok].append(multi[1])
    else:
        v_linelength.answer[tok].append("e")
        v_linelength.answer[tok].append(0)
        v_linelength.command[tok].append("e")
        v_linelength.command[tok].append(0)
        v_linelength.info[tok].append("e")
        v_linelength.info[tok].append(0)
    return


def ct_an(announcement, tok):
    # c>;an[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
    # <z>
    # <data>     answer
    item = announcement.split(";")
    multi = commandrouter_misc_functions.length_of_typ(item[2].split(",")[0])
    # valid type found
    if multi[0] != "e":
        i = 3
        positions = 1
        while i < len(item):
            item1 = item[i].split(",")
            positions *= int(item1[0])
            i += 1
        # length for number of of elements and start
        positionlength = commandrouter_misc_functions.length_of_int(positions)
        v_linelength.command[tok].append("n")
        v_linelength.command[tok].append(v_command_length.commandtokenlength + 2 * positionlength)
        if multi[0] == "n":
            v_linelength.answer[tok].append("m")
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(multi[1])
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(0)
            v_linelength.info[tok].append("m")
            v_linelength.info[tok].append(2 * positionlength)
            v_linelength.info[tok].append(positionlength)
            v_linelength.info[tok].append(multi[1])
            v_linelength.info[tok].append(0)
            v_linelength.info[tok].append(0)
            v_linelength.info[tok].append(0)
        if multi[0] == "s":
            v_linelength.answer[tok].append("t")
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(multi[1])
            v_linelength.answer[tok].append(0)
            v_linelength.answer[tok].append(0)
            v_linelength.info[tok].append("t")
            v_linelength.info[tok].append(2 * positionlength)
            v_linelength.info[tok].append(positionlength)
            v_linelength.info[tok].append(multi[1])
            v_linelength.info[tok].append(0)
            v_linelength.info[tok].append(0)
    else:
        v_linelength.answer[tok].append("e")
        v_linelength.answer[tok].append(0)
        v_linelength.command[tok].append("e")
        v_linelength.command[tok].append(0)
        v_linelength.info[tok].append("e")
        v_linelength.info[tok].append(0)
    return


def ct_af(announcement, tok):
    # <c>;af[,<des>]...[,<des>];<ty>[,<des>]
    # <c>
    # <data>     answer
    item = announcement.split(";")
    number_of_elements = int(item[2].split(",")[0])
    multi = commandrouter_misc_functions.length_of_typ(item[3].split(",")[0])
    v_linelength.command[tok].append("n")
    v_linelength.command[tok].append(v_command_length.commandtokenlength + commandrouter_misc_functions.length_of_int(number_of_elements))
    if multi[0] == "e":
        v_linelength.answer[tok].append("e")
        v_linelength.answer[tok].append(0)
        v_linelength.info[tok].append("e")
        v_linelength.info[tok].append(0)
    else:
        if multi[0] == "n":
            v_linelength.command[tok].append("m")
            v_linelength.command[tok].append(commandrouter_misc_functions.length_of_int(number_of_elements))
            v_linelength.command[tok].append(commandrouter_misc_functions.length_of_int(number_of_elements))
            v_linelength.command[tok].append(multi[1])
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(0)
        else:
            v_linelength.command[tok].append("t")
            v_linelength.command[tok].append(commandrouter_misc_functions.length_of_int(number_of_elements))
            v_linelength.command[tok].append(commandrouter_misc_functions.length_of_int(number_of_elements))
            v_linelength.command[tok].append(multi[1])
            v_linelength.command[tok].append(0)
            v_linelength.command[tok].append(0)
    return


def ct_aa(announcement, tok):
    # <c>,aa[,<des>]...[,<des>];<ty>[,<des>];<ty>[,<des>]...
    # <c><n>
    # <data>
    item = announcement.split(";")
    number_of_position = len(item) - 2
    # no parameter
    if number_of_position == 1:
        v_linelength.command[tok].append("b")
        v_linelength.command[tok].append(0)
    else:
        v_linelength.command[tok].append("n")
        v_linelength.command[tok].append(v_command_length.commandtokenlength + commandrouter_misc_functions.length_of_int(number_of_position))
    # variable
    v_linelength.answer[tok].append("t")
    # variable
    v_linelength.info[tok].append("t")
    i = 2
    while i < len(item):
        item1 = item[i].split(",")
        if str.isnumeric(item1[0]):
            v_linelength.answer[tok].append("s")
        else:
            v_linelength.answer[tok].append("n")
            v_linelength.info[tok].append("n")
            v_linelength.answer[tok].append(v_constants.length_of_par[item1[0]])
            v_linelength.info[tok].append(v_constants.length_of_par[item1[0]])
        i += 1


def ct_ab(announcement, tok):
    # <c>;ab[,<des>]...[,<des>];<ty>[,<des>]...[;<ty>[,<des>]
    item = announcement.split(";")
    length_of_position = commandrouter_misc_functions.length_of_int(len(item) - 2)
    v_linelength.command[tok].append("n")
    v_linelength.command[tok].append(v_command_length.commandtokenlength + length_of_position)
    v_linelength.answer[tok].append("t")
    v_linelength.answer[tok].append(0)
    v_linelength.info[tok].append("t")
    v_linelength.info[tok].append(0)


def strip_dimension(announcement):
    i = 0
    # ignore Option
    item1 = announcement.split(";")
    number_of_items = 0
    while i < len(item1):
        item = item1[i].split(",")
        if len(item) > 1:
            if item[1] != "DIMENSION":
                number_of_items += 1
        else:
            number_of_items += 1
        i += 1
    return number_of_items

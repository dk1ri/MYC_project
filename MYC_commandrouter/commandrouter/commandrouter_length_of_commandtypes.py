#calculate the length of of transmitted data for a actual command depending on commandtype :v_input_buffer_actual_command_length
#called, when a valid commandtoken is detected
# ct_xx :xx is the commmandtyp, for detailed description see MYC documentation
# for details of v_input_buffer_actual_command_length see description of variable
#------------------------------------------------
from commandrouter_misc_functions import *
import v_input_buffer_actual_command_length
import v_command_length
import v_constants
#
def ct_m(announcement,number_of_input_buffer):
#is not used
    l=v_command_length.commandtokenlength +1 + len(announcement)
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("b")                                                #command only
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("s")                                                 #string
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(1)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("s")                                                   #string
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(1)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_oc(announcement,number_of_input_buffer):
#announce:	<c>;oc[,<des>]...[,<des>];max_number_of_token
#command:	<c>0|1<s
#
    item=announcement.split(";")
    item1=item[2].split(",")
    l = length_of_int(int(item1[0])*v_command_length.commandtokenlength)                                                            #length of stringlength
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("c")
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+1+l)            #1 for 0|1
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(l)                                                  #length of stringlength
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)                                                  # length string, added in real time
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(1)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
    #
def ct_od(announcement,number_of_input_buffer):
#nnounce:	<c>;od[,<des>]...[,<des>];<c><,des>;...<c><,des>
#command:	<c>0|1
    item=announcement.split(";")
#number of bytes for max length of string  * number of bytes for length of string of following commandtoken
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")                                                #0|1 only
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+1)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_ac(announcement,number_of_input_buffer):
#announce:	<c>;ac[,<des>]...[,<des>];max_number_of_token
#command:	<c><s>
#answer:	<s>
#info:		<c><s>
    item=announcement.split(";")
    item1=item[2].split(",")
    l = length_of_int(int(item1[0])*v_command_length.commandtokenlength)                                                            #length of stringlength
    ll = length_of_int(int(item1[0])*v_command_length.commandtokenlength)                                                           #length of stringlength
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("c")
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+l)
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(l)
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("s")                                                 #string
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(1)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("s")                                                   #string
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(1)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_ad(announcement,number_of_input_buffer):
#announce:	<c>;ad[,<des>]...[,<des>];<c><,des>;...<c><,des>
#c ommand:	<c>
#answer:	<0|1>
#info:		<c><0|1>
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("b")                                                #error
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("n")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(v_command_length.commandtokenlength+1)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("n")
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(v_command_length.commandtokenlength+1)
    return
#
def ct_ic(announcement,number_of_input_buffer):
#info:		<c><s><s>
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("e")                                                #error
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("ss")
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("s")                                                   #string
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(1)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_id(announcement,number_of_input_buffer):
#info:		<c><s>
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("e")                                                #error
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("s")
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("s")                                                   #string
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(1)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
def ct_nc(announcement,number_of_input_buffer):
#<c>;nc
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("e")                                                #error
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_or(announcement,number_of_input_buffer):
#<c>;or[,<des>]...[,<des>];pos0[,<des>]...[;posn,[<des>]][;<OPTION>[,<des>]...	]
#<c>0|1
#<c>0|1<n>
    number_of_items=strip_dimension(announcement)
    if number_of_items > 2:                                                                                                         #must be more than 2
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")                                            #numeric
        if number_of_items == 3:
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+1)      #0|1
        if number_of_items > 3:
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int(number_of_items)+1)
    else:
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append("e")                                            #error
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_os(announcement,number_of_input_buffer):
#<c>;os[,<des>]...[,<des>];pos0[,<des>];...posn[.<des>][;<OPTION>[,<des>]...	]
#<c><n>
    number_of_items=strip_dimension(announcement)
    if number_of_items > 2:                                                                                                         #must be more than 2
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")                                            #numeric
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int(number_of_items))
    else:
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append("e")                                            #error
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_ot(announcement,number_of_input_buffer):
#<c>;ot[,<des>]...[,<des>];[pos0[,<des>];...posn[,<des>][;<OPTION>[,<des>]...	]
#<c>
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("b")                                                #error
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
#
def ct_ou(announcement,number_of_input_buffer):
#<c>;ou[,<des>]...[<,des>];pos0[,<des>];...;posn[,<des>][;<OPTION>[,<des>]...	]
#<c>
#<c><n>
    number_of_items=strip_dimension(announcement)
    if number_of_items > 2:                                                                                                         #must be more than 2
        if number_of_items == 3:
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("b")
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength)
        if number_of_items > 3:
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int(number_of_items))
    else:
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append("e")                                            #error
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_ar(announcement,number_of_input_buffer):
#<c>;ar[,<des>]...[,<des>];pos0[,<des>].[;posn,[<des>]][;<OPTION>[,<des>]...	]
#<c>
#<c><n>
#&H00|&H01  answer
    number_of_items=strip_dimension(announcement)
    if number_of_items > 2:                                                                                                         #must be more than 2
        if number_of_items == 3:
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("b")
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength)
        if number_of_items > 3:
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int(number_of_items))
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")
    else:
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append(1)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("n")
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(length_of_int(number_of_items))
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("n")
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int(number_of_items)+1)
    return
#
def ct_as(announcement,number_of_input_buffer):
#<c>;as[,<des>]...[,<des>];pos0[,<des>];...posn[.<des>][;<OPTION>[,<des>]...	]
#<c>
#<n>    answer
#<c>;at[,<des>]...[,<des>];[pos0[,<des>];...posm[,<des>][;<OPTION>[,<des>]...	]
#<c>
#<n>        answer
    number_of_items=strip_dimension(announcement)
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("b")                                                #numeric
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("n")
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(length_of_int(number_of_items))
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("n")
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int(number_of_items))
    return
#
def ct_au(announcement,number_of_input_buffer):
#announce:	<c>;au[,<des>]...[<,des>];pos0[,<des>];...;posn[,<des>][;<n>,<OPTION>[,<des>]...	]    item1=announcement.split("DIMENSION")
    number_of_items=strip_dimension(announcement)
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("b")
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("n")
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(length_of_int(number_of_items))
    if number_of_items > 2:                                                                                                         #must be more than 2
        v_input_buffer_actual_command_length.info[number_of_input_buffer].append("n")                                               #numeric
        if number_of_items == 3:
            v_input_buffer_actual_command_length.info[number_of_input_buffer].append(v_command_length.commandtokenlength)
        if number_of_items > 3:
            v_input_buffer_actual_command_length.info[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int(number_of_items))
    else:
        v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                               #error
        v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_op(announcement,number_of_input_buffer):
#<c>;op[,<des>]...[<,des>];<ranges>,<des>;unitx,<des>;<lin|log>,<des>;minx,<des>;maxx,<des>...
#<c><n>
#<c><n><n>
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")                                                #numeric
    item1=announcement.split(";")
    length=0
    i=2
    while i < len(item1):                                                                                                           #elements 2, 5, 8,... have to be calculated
        item=item1[i].split(",")
        length += length_of_int(int(item[0]))
        i+=3
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_oo(announcement,number_of_input_buffer):
#<c>;oo[,<des>]...[<,des>];max_number_of_steps;steptimemin,<des>;steptimemax[,<des>];stepsizemin[,<des>];stepsizemax[,<des>];stepsizemiddle,<des>...
#<c>0<n><n>
#<c>&H02&H01&H08
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")                                                #numeric
    item=announcement.split(";")
    length=0
    i=2
    while i < len(item):                                                                                                           #elements 2, 5, 8,... have to be calculated
        length += length_of_int(int(item[i].split(",")[0]))                            #number_of steps
        length += length_of_int(int(item[i+2].split(",")[0])-int(item[i+1].split(",")[0]))                                          #steptime
        length += length_of_int(int(item[i+4].split(",")[0])-int(item[i+3].split(",")[0]))                                          #stepsize
        i+=6
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_oq(announcement,number_of_input_buffer):
#<c>;oq[,<des>]...[<,des>];<defaultposition>[,des]...[,des]
#<c>
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("b")                                                #error
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_ap(announcement,number_of_input_buffer):
#<c>;ap[,<des>]...[<,des>];<ranges>,<des>;unitx,<des>;<lin|log>,<des>;min,<des>;max,<des>....;<ranges>...
#<c>
#<n>    onswer 1 dinension
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("b")                                                #error
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("n")                                                 #numeric
    item1=announcement.split(";")
    length=0
    i=2
    while i < len(item1):                                                                                                           #elements 2, 5, 8,... have to be calculated
        item=item1[i].split(",")
        length += length_of_int(int(item[0]))
        i+=3
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(length)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("n")                                                   #numeric
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(length)
#
def ct_om(announcement,number_of_input_buffer):
#<c>;om[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
#<c><z><data>
    item=announcement.split(";")
    multi=length_of_typ(item[2].split(",")[0])                                                                                      #commandtype
    if multi[0] != "e":
        i=3
        positions=1
        while i < len(item):
            item1=item[i].split(",")
            positions *= int(item1[0])
            i+=1
        positionlength=length_of_int(positions)
        if multi[0] == "n":
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")                                        #numeric
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+positionlength+multi[1])
        if multi[0] == "s":
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("s")                                        #string
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+positionlength+multi[1])
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(multi[1])
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_on(announcement,number_of_input_buffer):
#<c>;on[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
#<c><z><data>
    item=announcement.split(";")
    multi=length_of_typ(item[2].split(",")[0])                                                                                      #commandtype
    if multi[0] != "e":
        i=3
        positions=1
        while i < len(item):
            item1=item[i].split(",")
            positions *= int(item1[0])
            i+=1
        positionlength=length_of_int(positions)
        if multi[0] == "n":
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")                                        #numeric
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+2*positionlength)
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+positionlength)
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(multi[1])
            print(v_input_buffer_actual_command_length.command[number_of_input_buffer])
        if multi[0] == "s":
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("r")                                        #string
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+2*positionlength)
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+positionlength)
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(positionlength)
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(multi[1])
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_of(announcement,number_of_input_buffer):
#<c>;of[,<des>]...[,<des>];<n>,<des>;<ty>[,<des>]
#<c><n><data>
    item=announcement.split(";")
    number_of_elements=int(item[2].split(",")[0])
    multi=length_of_typ(item[3].split(",")[0])
    if multi[0] == "e":
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append("e")                                            #error
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    else:
        if multi[0] == "n":
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int((number_of_elements)))
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int((number_of_elements)))
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(multi[1])
        else:
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("r")                                        #string
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int(number_of_elements))
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int(number_of_elements))
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(length_of_int(number_of_elements))
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(multi[1])
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_oa(announcement,number_of_input_buffer):
#<c>;oa[,<des>]...[,<des>];<ty>[,<des>]...[;<ty>[,<des>]]
#<c><n><data>
    item=announcement.split(";")
    item=announcement.split(";")
    item1=item[1].split(",")
    number_of_position=len(item)-2
    if number_of_position == 1:                                                                                                     #one parameter
        item1=item[2].split(",")
        if str.isnumeric(item1[0]):                                                                                                 #nueric
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+v_constants.length_of_par[item1[0]])
        else:                                                                                                                       #string
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("s")
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength)        #no position parameter
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(length_of_int(item1[0]))                    #length of stringlength
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)                                          # length string, added in real time
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)                                          #no number
    else:                                                                                                                           #more than 1 parameter; commandtype must be found at realtime
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append("t")
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int(number_of_position)) #wait , until position is found
        i=2                                                                                                                         #start with 3rd element and use 3rd element of v_input_buffer_actual_command_length.command[number_of_input_buffer
        while i < len(item) :
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append([])
            item1=item[i].split(",")
            if str.isnumeric(item1[0]):
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append("n")
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append(v_constants.length_of_par[item1[0]])
            else:                                                                                                                   #string
                l=length_of_int(int(item1[0]))                                                                                      #length for stringlength
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append("s")
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append(v_command_length.commandtokenlength+length_of_int(number_of_position)+l)
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append(l)                                   #length of stringlength
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append(0)                                   # length string, added in real time
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append(0)                                   #no number (not used)
            i+=1
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
#
def ct_ob(announcement,number_of_input_buffer):
#<c>;ob[,<des>]...[,<des>];<ty>[,<des>]...[;<ty>[,<des>]]
#<c><n><m><data>
    item=announcement.split(";")
    item1=item[1].split(",")
    number_of_position=len(item)-2
    if number_of_position == 1:                                                                                                     #one parameter
        item1=item[2].split(",")
        if str.isnumeric(item1[0]):                                                                                                 #string
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("s")
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength)        #no position parameter
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(length_of_int(item1[0]))                    #length of stringlength
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)                                          # length string, added in real time
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)                                          #no number
        else:
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+v_constants.length_of_par[item1[0]])
    else:                                                                                                                           #more than 1 parameter; commandtype must be found at realtime
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append("t")
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int(number_of_position)) #wait , until position is found
        i=2                                                                                                                         #strat with 3rd element and use 3rd element of v_input_buffer_actual_command_length.command[number_of_input_buffer
        while i < len(item) :
            v_input_buffer_actual_command_length.command[number_of_input_buffer].append([])
            item1=item[i].split(",")
            if str.isnumeric(item1[0]):                                                                                             #string
                l=length_of_int(int(item1[0]))                                                                                      #length for stringlength
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append("s")
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append(v_command_length.commandtokenlength+length_of_int(number_of_position)+l)
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append(l)                                   #length of stringlength
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append(0)                                   # length string, added in real time
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append(0)                                   #no number (not used)
            else:
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append("n")
                v_input_buffer_actual_command_length.command[number_of_input_buffer][i].append(v_constants.length_of_par[item1[0]])
            i+=1
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
#
def ct_am(announcement,number_of_input_buffer):
#c>;am[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
#<c><n>
#<data>
    item=announcement.split(";")
    i=3
    positions=1
    while i < len(item):
        item1=item[i].split(",")
        positions = int(item1[0])
        i+=1
    positionlength=length_of_int(positions)
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+positionlength)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_an(announcement,number_of_input_buffer):
#c>;an[<,des>]...[,<des>]; <ty>[,<des>]... [,<des>];n_rows[,<des>]...[,<des>];[<n_cols[,<des>]...[,<des>]]...
#<z>
#<data>     answer
    item=announcement.split(";")
    i=3
    positions=1
    while i < len(item):
        item1=item[i].split(",")
        positions = int(item1[0])
        i+=1
    positionlength=length_of_int(positions)
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+(2*positionlength))
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
    return
#
def ct_af(announcement,number_of_input_buffer):
#<c>;af[,<des>]...[,<des>];<ty>[,<des>]
#<c>
#<data>     answer
    item=announcement.split(";")
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int(int(item[2].split(",")[0])))
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("e")                                                 #error
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("e")                                                   #error
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
#
def ct_aa(announcement,number_of_input_buffer):
#<c>,aa[,<des>]...[,<des>];<ty>[,<des>];<ty>[,<des>]...
#<c><n>
#<data>
    item=announcement.split(";")
    item1=item[1].split(",")
    number_of_position=len(item)-2
    if number_of_position == 1:                                                                                                     #no parameter
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append("x")
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append(0)
    else:
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")
        v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_int(number_of_position))
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("t")                                                 #variable
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("t")                                                   #variable
    i=2
    while i < len(item) :
        item1=item[i].split(",")
        if str.isnumeric(item1[0]):
            v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("s")
        else:
            v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("n")
            v_input_buffer_actual_command_length.info[number_of_input_buffer].append("n")
            v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(v_constants.length_of_par[item1[0]])
            v_input_buffer_actual_command_length.info[number_of_input_buffer].append(v_constants.length_of_par[item1[0]])
        i+=1
#
def ct_ab(announcement,number_of_input_buffer):
#<c>;ab[,<des>]...[,<des>];<ty>[,<des>]...[;<ty>[,<des>]
    item=announcement.split(";")
    length_of_position=length_of_int(len(item)-2)
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append("n")                                                #numeric command
    v_input_buffer_actual_command_length.command[number_of_input_buffer].append(v_command_length.commandtokenlength+length_of_position)
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append("t")                                                 #variable
    v_input_buffer_actual_command_length.answer[number_of_input_buffer].append(0)
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append("t")                                                   #variable
    v_input_buffer_actual_command_length.info[number_of_input_buffer].append(0)
#
def strip_dimension(announcement):
    i=0
    item1=announcement.split(";")                                                                                                   #ignore Option
    number_of_items=0
    while i< len(item1):
        item=item1[i].split(",")
        if len(item)> 1:
            if item[1]!="DIMENSION":
                number_of_items+=1
        else:
            number_of_items+=1
        i+=1
    return(number_of_items)
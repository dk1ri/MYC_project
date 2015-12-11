#------------------------------------------------
#misc functions
#------------------------------------------------
import v_command_length
import v_constants
#
def add_length(string,length):
#add the length of a string to the start
#the length of "length of command depend on parameter
    l=len(string)
    return(int_to_bytes(l,length)+string)
#
def length_of_int(i):
#return the number of bytes to be used depending on i
    if i == 0:
        return (1)
    else:
        j=(int.bit_length(i) - 1)//8 +1
        if j > 4:
            return(8)
        elif j > 2:
            return(4)
        elif j > 1:
            return(2)
    return(1)
#
def int_to_bytes(integ,length):
#convert a integer to a string of bytes (0-255) with a minimum length as per v_command_length.a
#length 0: use CR tokenlength
    if length == 0:
        if integ < 0x100:                                                                                               #1 byte
            if v_command_length.commandtokenlength == 2:
                return (chr(0)+chr(integ))
            elif v_command_length.commandtokenlength == 4:
                return (chr(0)+chr(0)+chr(0)+chr(integ))
            elif v_command_length.commandtokenlength == 8:
                return (chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(integ))
            else:
                return (chr(integ))
        elif integ < 0x10000:
            if v_command_length.commandtokenlength == 4:
                return (chr(0)+chr(0)+chr(integ//0x100))+chr(integ % 0x100)
            elif v_command_length.commandtokenlength == 8:
                return (chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(integ//0x100))+chr(integ % 0x100)
            else:
                return(chr(integ//0x100))+chr(integ % 0x100)
        elif integ < 0x100000000:
            if v_command_length.commandtokenlength == 8:
                return (chr(0)+chr(0)+chr(0)+chr(0)+chr(integ//0x1000000)+chr(integ//0x1000000)+chr(integ//0x10000)+chr(integ%0x0100))
            else:
                return(chr(integ//0x1000000)+chr(integ//0x1000000)+chr(integ//0x10000)+chr(integ%0x0100))
        else:
            return(chr(integ//0x10000000000000000)+chr(integ//0x100000000000000)+chr(integ//0x1000000000000)+chr(integ//0x10000000000)+chr(integ//0x100000000)+chr(integ//0x1000000)+chr(integ//0x10000)+chr(integ%0x0100))
    else:
        if integ < 0x100:                                                                                               #1 byte
            if length == 2:
                return (chr(0)+chr(integ))
            elif length == 4:
                return (chr(0)+chr(0)+chr(0)+chr(integ))
            elif length == 8:
                return (chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(integ))
            else:
                return (chr(integ))
        elif integ < 0x10000:
            if length == 4:
                return (chr(0)+chr(0)+chr(integ//0x100))+chr(integ % 0x100)
            elif length == 8:
                return (chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(0)+chr(integ//0x100))+chr(integ % 0x100)
            else:
                return(chr(integ//0x100))+chr(integ % 0x100)
        elif integ < 0x100000000:
            if length == 8:
                return (chr(0)+chr(0)+chr(0)+chr(0)+chr(integ//0x1000000)+chr(integ//0x1000000)+chr(integ//0x10000)+chr(integ%0x0100))
            else:
                return(chr(integ//0x1000000)+chr(integ//0x1000000)+chr(integ//0x10000)+chr(integ%0x0100))
        else:
            return(chr(integ//0x10000000000000000)+chr(integ//0x100000000000000)+chr(integ//0x1000000000000)+chr(integ//0x10000000000)+chr(integ//0x100000000)+chr(integ//0x1000000)+chr(integ//0x10000)+chr(integ%0x0100))

    return
#
def bytes_to_int(bytes):
#convert a 1, 2,4,8 byte string to int
#return nothing for 0 bytes
    if len(bytes) == 1:
        return (ord(bytes))
    elif len(bytes) == 2:
        return (0x100*ord(bytes[0])+ord(bytes[1]))
    elif len(bytes) == 4:
        return (0x1000000*ord(bytes[0])+0x10000*ord(bytes[1])+0x100*ord(bytes[2])+ord(bytes[3]))
    elif len(bytes) == 8:
        return (0x100000000000000*ord(bytes[0])+0x1000000000000*ord(bytes[1])+0x10000000000*ord(bytes[2])+0x100000000*ord(bytes[3])+0x1000000*ord(bytes[4])+0x10000*ord(bytes[5])+0x100*ord(bytes[6])+ord(bytes[7]))
    return
#
def split_desc(announcement):
#delete description from a announcement line
    items=[]
    no_desc=[]
    items=announcement.split(";")
    for item in items:
        tr=item.split(",")
        no_desc.append(item.split(",")[0])
    return(";".join(no_desc))
#
def calculate_length_of_commandtoken(number):
#calculate length of commandtoken
    v_command_length.adder=(0x00)                                                                                       #commandtokenadder for announcements of cammandrouter
    v_command_length.commandtokenlength=(1)                                    #length_of_commandtoken
    v_command_length.reserved_token=[0x0,0xf0,0xf9,0xfa, 0xfb,0xfc,0xfd,0xfe,0xff] #reserved commandtoken
    if (number > 0xef):                                         #last 16 reserved
        v_command_length.adder= 0xffff - 0xff
        v_command_length.commandtokenlength=2
        v_command_length.reserved_token=[0x0,0xfff0,0xfff9,0xfffa,0xfffb,0xfffc,0xfffd,0xfffe,0xffff]
    if (number > (0xffff - 0x10)):
        v_command_length.adder=0xffffffff - 0xff
        v_command_length.commandtokenlength=4
        v_command_length.reserved_token=[0x0,0xfffffff0,0xfffffff9,0xfffffffa,0xfffffffb,0xfffffffc,0xfffffffd,0xfffffffe,0xffffffff]
    if (number > (0xffffffff - 0x10)):
        v_command_length.adder=0xffffffffffffffff - 0xff
        v_command_length.commandtokenlength=8
        v_command_length.reserved_token=[0x0,0xffffffffffffff0,0xffffffffffffff9,0xffffffffffffffa,0xffffffffffffffb,0xffffffffffffffc,0xffffffffffffffd,0xffffffffffffffe,0xffffffffffffff]
    v_command_length.startnumber=calculate_length_of_stringlength(number,0x10)
    return()
#
def calculate_length_of_stringlength(number,subtractor):
    length=1
    if (number > (0xff - subtractor)):
        length=2
    if (number > (0xffff - subtractor)):
        length=4
    if (number > (0xffffffff - subtractor)):
        length=8
    return(length)

#
def length_of_typ(type):
    length=[]
    length.append("n")
    try:
        length.append(v_constants.length_of_par[type])
    except KeyError:
        if type == "c":
            length.append(v_command_length.commandtokenlength)
        else:                                                                                                           #string
            try:
                length.append(length_of_int(int(type)))
                length[0]="s"
            except KeyError:
                length[0]="e"
    return(length)
#
def detect_range(value,field):
#field is a description, string: {...}
# detect, weather a int number or string character matches
    if len(field)==0:
        return(1)                                                                                                       #no limit
    if field[0]!="{":
        return(0)
    field=field[1:-1]
    ok=0
    part=filed.split(",")
    i=0
    while i<len(part):
        subpart=part[i].split(" ")
        if len(subpart) == 1:                                                                                           #simple value
            if str.isnumeric(part[i])==1:
                if str.isnumeric(value) == 1:
                    if value == int(part):
                        ok=1
                        break
                else:                                                                                                   #must be a byte
                    if value == part[i]:
                        ok=1
                        break
        elif len(subpart)== 3:
            if str.isnumeric(subpart[0])==1 and str.isnumeric(subpart[0])== 1:
                if str.isnumeric(value) == 1:
                    if value > int(subpart[0]) and value < int(subpart[2]):
                        ok=1
                        break
            elif len(subpart[0]) == 1 and len(subpart[2])==1:
                if chr(value)<ord(subpart[0]) and chr(value)< ord(subpart[2]):
                    ok=1
                    break
        #otherwise ok=0
    return(ok)
#------------------------------------------------
#commandhandling of commandrouter own commands
#details see MYC commands specification
#def comxxx()
#------------------------------------------------
import v_input_buffer
import v_announcelist
import v_command_number
import v_commandrouter_announcements
import v_commandrouter_params
import v_command_length
import v_configparameter
from commandrouter_misc_functions import *
from commandrouter_command_handling import *
from commandrouter_create_new_announce_list import *
#
def com0(input_device):
    v_input_buffer.answerline[input_device].append(add_length(v_announcelist.basic[0],0)) # actual answer buffer
    v_input_buffer.answer_ready[input_device]=1                                                                         #ready
    v_input_buffer.delete[input_device]=v_command_length.commandtokenlength                                             #number of bytes to delete
    return
#
def com240(input_device):
    error =0
    finish =0
    l=len(v_input_buffer.inputline[input_device])
    if l < 2 * v_command_length.commandtokenlength:                                                                     #one parameter with length of commandtoken
        return
    first_parameter=bytes_to_int(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:v_command_length.commandtokenlength+v_command_length.commandtokenlength])
    if first_parameter == v_command_length.adder+253:                                                                   #&Hxxfd  rules
        for lines in v_announcelist.rules:
            v_input_buffer.answerline[input_device].append(add_length(lines,v_commandrouter_params.length_of_announcement_length))
    elif first_parameter == v_command_length.adder+254:                                                                 #send all
        for lines in v_announcelist.full:
            v_input_buffer.answerline[input_device].append(add_length(lines,v_commandrouter_params.length_of_announcement_length))
    elif first_parameter == v_command_length.adder+255:                                                                 #basic announcement
        v_input_buffer.answerline[input_device].append(add_length(v_announcelist.full[0],v_commandrouter_params.length_of_announcement_length))
    else:                                                                                                               #number is index ix full announcelist
        try:
            v_input_buffer.answerline[input_device].append(add_length(v_announcelist.full[first_parameter],v_commandrouter_params.length_of_announcement_length))
        except IndexError:
            v_input_buffer.last_error[input_device]="wrong parameter: "+ str(v_command_number.a)
            v_input_buffer.delete[input_device]=2 * v_command_length.commandtokenlength                                 #number of bytes to delete
            finish=1
    if error == 0:
        v_input_buffer.answer_ready[input_device]=1
        v_input_buffer.delete[input_device]=2 * v_command_length.commandtokenlength                                     #number of bytes to delete
        finish=1
    return(finish)
#
def com252(input_device):
    l=1
    for lines in v_commandrouter_announcements.a:
        if lines.split(";"[0]) == "240":
            l=length_of_int(lines.split(";")[3].split(","))                                                             #length of stringlrngth
            break
    v_input_buffer.answerline[input_device].append(add_length(str(v_command_number.a)+": "+v_input_buffer.last_error[input_device],l))
    v_input_buffer.answer_ready[input_device]=1
    v_input_buffer.delete[input_device]=v_command_length.commandtokenlength                                             #number of bytes to delete
    return(1)
#
def com253(input_device):
    v_input_buffer.answerline[input_device].append(chr(0x04))
    v_input_buffer.answer_ready[input_device]=1
    v_input_buffer.delete[input_device]=v_command_length.commandtokenlength                                             #number of bytes to delete
    return(1)
#
def com254(input_device):
#write individualization
#Interface type cannot be changend
    if len(v_input_buffer.inputline[input_device]) < v_command_length.commandtokenlength+1:                             #got first parameter? (1 byte)
        return 0
    first_parameter=ord(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength]) #first Parameter: position of property
    error=1
    if first_parameter == v_commandrouter_params.name[1]:                                                               #name
        if len(v_input_buffer.inputline[input_device]) < v_command_length.commandtokenlength+2:                         #got first parameter + stringlength *(2 byte)
            return 0
        l=ord(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength+1:v_command_length.commandtokenlength+2])  #one byte stringlength
        full_length=v_command_length.commandtokenlength+2 + l
        if len(v_input_buffer.inputline[input_device]) < full_length:                                                   #line complete?
            return (0)
        new_name=v_input_buffer.inputline[input_device][v_command_length.commandtokenlength+2:full_length]
        modify("NAME",new_name,0)
        create_new_announce_list()
        v_input_buffer.delete[input_device]=full_length                                                                 #number of bytes to delete
        error=0
    elif first_parameter == v_commandrouter_params.number[1]:                                                           #number
        if len(v_input_buffer.inputline[input_device]) < v_command_length.commandtokenlength+2:                         #got first parameter + number *(2 byte)
            return 0
        new_number=str(ord(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength+1:v_command_length.commandtokenlength+2]))
        modify("NUMBER",new_number,0)
        create_new_announce_list()
        v_input_buffer.delete[input_device]=v_command_length.commandtokenlength+3                                       #number of bytes to delete
        error=0
    else:
        i=0
        found=0
        while i < len(v_commandrouter_params.interface):
            j=0
            while j<len(v_commandrouter_params.interface[i]):
                if first_parameter == v_commandrouter_params.interface[i][j+2]:
                    ifp= v_commandrouter_params.interface[i][j] .split(",")[1]                                          #interfaceparameter
                    if ifp =="TIMEOUT" or ifp =="ADRESS" or ifp =="COMPORT" or ifp =="BAUDRATE":
                        additional_byte=1                                                                               #additional bytes to wait for
                        found=1
                        break
                    elif ifp =="PORT":
                        additional_byte=2
                        found=1
                        break
                    elif ifp =="NUMBER_OF_BYTES":
                        additional_byte=3
                        found =1
                        break
                j+=3
            if found==1:
                break
            i+=1
        if len(v_input_buffer.inputline[input_device]) < v_command_length.commandtokenlength+1+l:                       #1 parameter + l
            return(0)
        new_value=v_input_buffer.inputline[input_device][2:2+additional_byte]
        if len(v_commandrouter_params.interface[i][j].split(","))> 2:
            ok=detect_range(new_value,v_commandrouter_params.interface[i][j])[2]                                        #3rd field is description of values
            if ok == 1:
                modify(ifp,new_value,first_parameter)
                create_new_announce_list()
        else:
            modify(ifp,new_value,first_parameter)
            create_new_announce_list()
    if error==1:
        v_input_buffer.last_error[input_device]="no valid parameter index for individualization write: "+ str(v_command_number.a)
    return(1)
#
def modify(parameter,new_parameter,index):
#for 254 command modify announcemntfile of the commandrouter
    line_number=0
    for lines in v_commandrouter_announcements.a:
        if lines[0:3]=="254":                                                                                           #modify this line
            item=lines.split(";")
            i=2
            while i < len(item):
                item1=item[i].split(",")
                if len(item1) >2:
                    if item1[1]== parameter:
                        item1[2]= new_parameter
                        break
                i+=1
            item[i]=",".join(item1)
            new_line=";".join(item)
            v_commandrouter_announcements.a[line_number]=new_line
            break
        line_number+=1
    config_file=open(v_configparameter.announcements)
    configtemp=[]
    i=0
    for lines in config_file:
        if lines[0:3] != "254":
            configtemp.append(lines.rstrip())
        else:
            configtemp.append(new_line)
        i+=1
    config_file.close()
    config_file=open(v_configparameter.announcements,"w")
    for lines in configtemp:
        config_file.write(lines+"\n")
    config_file.close()
    if parameter == "NAME":
        v_commandrouter_params.name[0]=new_parameter
    elif parameter == "NUMBER":
        v_commandrouter_params.number[0]=new_parameter
    else:
        i=0                                                                                                             #modify lists
        while i< len(v_commandrouter_params.interface):
            if v_commandrouter_params.interface[2]== index:
                v_commandrouter_params.interface[1]=new_parameter
                break
            i+=1
    return
#
def com255(input_device):                                                                                               #read individualization
    if len(v_input_buffer.inputline[input_device]) < v_command_length.commandtokenlength+1:                             #one additional byte (not more than 255 parameters)
        return(0)
    first_parameter=ord(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength])                    #first Parameter: position of property
    error=1
    if first_parameter == v_commandrouter_params.name[1]:                       #
        v_input_buffer.answerline[input_device].append(add_length(v_commandrouter_params.name[0],v_commandrouter_params.length_of_name_length))
        error=0
    elif first_parameter == v_commandrouter_params.number[1]:                                                           #number
        v_input_buffer.answerline[input_device].append(chr(v_commandrouter_params.number[0]))
        error=0
    else:                                                                                                               #interface
        i=0
        while i < len(v_commandrouter_params.interface):
            j=0
            while j<len(v_commandrouter_params.interface[i]):
                if first_parameter == v_commandrouter_params.interface[i][j+2]:
                    try:
                        v_commandrouter_params.interface[i][j+1] += 0
                        v_input_buffer.answerline[input_device].append(int_to_bytes(v_commandrouter_params.interface[i][j+1],1))
                    except TypeError:
                        v_input_buffer.answerline[input_device].append(add_length(v_commandrouter_params.interface[i][j+1],1))  #no paramter need more than one byte for length
                    error=0
                    break
                j+=3
            i+=1
    if error==1:
        v_input_buffer.last_error[input_device]="no valid parameter for individualization read: "+ str(v_command_number.a)
    else:
        v_input_buffer.answer_ready[input_device]=1
    v_input_buffer.delete[input_device]=v_command_length.commandtokenlength+1                                           #number of bytes to delete
    return(1)
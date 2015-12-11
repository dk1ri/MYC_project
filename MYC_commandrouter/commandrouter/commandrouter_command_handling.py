# command handling subprograms
#
import v_all_command_token
import  v_command_length
import v_command_number
import v_constants
import v_device_command
import v_device_buffer
import v_device_command_for_commandtoken
import v_input_buffer
import v_input_buffer_actual_command_length
import v_sendstring
import v_token_of_basic_announcements
from commandrouter_own_commands import *
from commandrouter_device_handling import *
#
#------------------------------------------------
#start of commandhandling
#------------------------------------------------
def poll_input_buffer():
    i=0
    for item in v_input_buffer.inputline:                                                                                           #something received from HI
        check_input_buffer(i)
        i += 1
    return
#
def check_input_buffer(input_device):
#is called by polling. received data are checked weather they are complete
#if correct and complete approriate action is called
    error=0
    if v_input_buffer.inputline[input_device] == "":                                                                                #nothing to do
        return
    if (ord(v_input_buffer.inputline[input_device][0]) == 0):                                                                       #commandrouter basic announcement
        com0(input_device)
        finish_command(input_device)
        return
    l=len(v_input_buffer.inputline[input_device])
    if l < v_command_length.commandtokenlength:                                                                                     #commandtoken ready?
        return
    tokennumber=bytes_to_int(v_input_buffer.inputline[input_device][0:v_command_length.commandtokenlength])                         #got token
    if v_input_buffer.actual_token[input_device] != 0:                                                                              #commandtoken already set 2: actual commandtoken as int
        no_CR_command(input_device,l,tokennumber)
    else:
        if tokennumber in v_command_length.reserved_token:                                                                          #commandrouter own (reserved) commands
            finish =v_constants.command[tokennumber](input_device)                                                                  #call the commandrouter own commands
            if finish == 1:
                finish_command(input_device)
        else:                       #other command
            if tokennumber in v_all_command_token.a:                                                                                #valid command
                if tokennumber in v_token_of_basic_announcements.a:                                                                 #basic announcement command
                    v_input_buffer.answerline[input_device].append(add_length(v_announcelist.basic[v_token_of_basic_announcements.a.index(tokennumber)],0))
                    v_input_buffer.answer_ready[input_device]=1
                    finish_command(input_device)
                else:
                    no_CR_command(input_device,l,tokennumber)                                                                       #other command
            else:
                v_input_buffer.last_error[input_device]="no valid commandtoken "+str(v_command_number.a)
                finish_command(input_device)
    return
#
def no_CR_command(input_device,l,tokennumber):
    #find and store parameters for that command in input_buffer
    if v_input_buffer.actual_token[input_device] == 0:
        v_input_buffer.actual_token[input_device]=tokennumber
        v_input_buffer.actual_token_string[input_device]=v_input_buffer.inputline[input_device][0:v_command_length.commandtokenlength]
        tokenindex=v_all_command_token.a.index(tokennumber)
        v_input_buffer.device_index[input_device]=v_device_command_for_commandtoken.device[tokenindex]                              #original device for that command
        v_input_buffer.original_command_index[input_device]=v_device_command_for_commandtoken.command[tokenindex]                   #original command
        v_constants.commandtypes[v_device_command_for_commandtoken.commandtype[tokenindex]](v_device_command_for_commandtoken.announceline[tokenindex],input_device)
#l include commandtoken
    if l <  v_input_buffer_actual_command_length.command[input_device][1]:                                                          #commandtoken + actual bytes to wait for
        return
    d= (v_input_buffer_actual_command_length.command[input_device][0])                                                              #type
    error=0
    device=v_device_command_for_commandtoken.device[v_all_command_token.a.index(tokennumber)]
    if d == "e":
        v_input_buffer.last_error[input_device]="no valid command or other error"
        finish_command(input_device)
    elif d == "b":                                                                                                                  #command only
        data=retranslate(input_device,device,0)
        transfer_to_device_buffer(input_device,device,data)
        finish_command(input_device)
    elif d == "n":
        if len(v_input_buffer_actual_command_length.command[input_device])== 2:                                                     #one parameneter
            data=retranslate(input_device,device,0)
            data += v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:v_command_length.commandtokenlength+v_input_buffer_actual_command_length.command[input_device][1]]                                             #commandtoken
            transfer_to_device_buffer(input_device,device,data)
            finish_command(input_device)
        else:                                                                                                                       #sequential access
#wait for number of elements
            n=bytes_to_int(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:v_input_buffer_actual_command_length.command[input_device][2]])   #number of parameters
            m= n*v_input_buffer_actual_command_length.command[input_device][3]                                                      #number of_bytes for paramters
            if l<v_input_buffer_actual_command_length.command[input_device][1]+n:                                                   #wait more m bytes
                return
            data=retranslate(input_device,device,0)
            data += v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:v_input_buffer_actual_command_length.command[input_device][1]+m]                                       #commandtoken
            transfer_to_device_buffer(input_device,device,data)
            finish_command(input_device)
    elif d == "s":
        if v_input_buffer_actual_command_length.command[input_device][3] == 0:                                                  #complete length not yet set
            number_of_bytes=bytes_to_int(v_input_buffer.inputline[input_device][v_input_buffer_actual_command_length.command[input_device][1]-v_input_buffer_actual_command_length.command[input_device][2]:v_input_buffer_actual_command_length.command[input_device][1]] )       #complete length of string
            if number_of_bytes ==0:
                finish_command(input_device)
                return
            else:                                                                                                               #set complete length
                v_input_buffer_actual_command_length.command[input_device][3]=number_of_bytes
        if l < v_input_buffer_actual_command_length.command[input_device][1] + v_input_buffer_actual_command_length.command[input_device][3]:       #now complete length needed
            return
        else:
            data=retranslate(input_device,device,0)
            end= v_input_buffer_actual_command_length.command[input_device][1]+v_input_buffer_actual_command_length.command[input_device][3]
            print(v_command_length.commandtokenlength,end)
            data+= v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:end]
            transfer_to_device_buffer(input_device,device,data)
            finish_command(input_device)
    elif d == "r":
#for sequential strings of on command
        if v_input_buffer_actual_command_length.command[input_device][5] == 0:                                                  #number of parameters not yet set
            number_of_pars=bytes_to_int(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:v_input_buffer_actual_command_length.command[input_device][2]])
            if number_of_pars ==0:
                finish_command(input_device)
                return
#start with pos of actual + stringlength
            v_input_buffer_actual_command_length.command[input_device][5]=v_input_buffer_actual_command_length.command[input_device][1]+v_input_buffer_actual_command_length.command[input_device][4]# actual + stringlength
            v_input_buffer_actual_command_length.command[input_device][6]=number_of_pars
        if l< v_input_buffer_actual_command_length.command[input_device][5]:
            return
        if v_input_buffer_actual_command_length.command[input_device][7]==0:                                                        #now set length for next string
            start=v_input_buffer_actual_command_length.command[input_device][5]-v_input_buffer_actual_command_length.command[input_device][4]
            end = v_input_buffer_actual_command_length.command[input_device][5]
            v_input_buffer_actual_command_length.command[input_device][7]=bytes_to_int(v_input_buffer.inputline[input_device][start:end])
            v_input_buffer_actual_command_length.command[input_device][5]+=v_input_buffer_actual_command_length.command[input_device][7]
        if l < v_input_buffer_actual_command_length.command[input_device][5]:                                                       #wait after length set
            return
        v_input_buffer_actual_command_length.command[input_device][6]-=1
        v_input_buffer_actual_command_length.command[input_device][7]=0                                                             #so new stringlength can be set
        v_input_buffer_actual_command_length.command[input_device][5]+= v_input_buffer_actual_command_length.command[input_device][4] #wait for next stringlenth (if not finished)
        if v_input_buffer_actual_command_length.command[input_device][6]==0:                                                        #no more parameters -> command finished
            data=retranslate(input_device,device,0)
            end= v_input_buffer_actual_command_length.command[input_device][5]
            data+= v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:end]
            transfer_to_device_buffer(input_device,device,data)
            finish_command(input_device)
        return
    elif d == "v":
#for commands
            if l < v_input_buffer_actual_command_length.command[input_device][1]:                                                   #now number of elements needed
                return
            if v_input_buffer_actual_command_length.command[input_device][2]=="n":
                number_of_el= bytes_to_int(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:v_input_buffer_actual_command_length.command[input_device][1]])
                s_end=v_input_buffer_actual_command_length.command[input_device][1]+number_of_el*v_input_buffer_actual_command_length.command[input_device][3]
                if l < s_end:
                    return
                data=retranslate(input_device,device,0)
                data += v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:s_end]
                transfer_to_device_buffer(input_device,device,data)
                finish_command(input_device)
            else:                                                                                                                   #string
                if v_input_buffer_actual_command_length.command[input_device][4]==0:                                                #number of pos not yet set no set yet
#number of positions:
                    v_input_buffer_actual_command_length.command[input_device][4]=bytes_to_int(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:v_input_buffer_actual_command_length.command[input_device][1]]) #number of elements
                    v_input_buffer_actual_command_length.command[input_device][5]=v_input_buffer_actual_command_length.command[input_device][1]     #start of string
                if l < v_input_buffer_actual_command_length.command[input_device][5]+v_input_buffer_actual_command_length.command[input_device][3]: #start + stringlength
                    return
                #now have stringlength
                if v_input_buffer_actual_command_length.command[input_device][6]==0:  #end not set
                    length_of_actual_string=bytes_to_int(v_input_buffer.inputline[input_device][v_input_buffer_actual_command_length.command[input_device][5]:v_input_buffer_actual_command_length.command[input_device][5]+v_input_buffer_actual_command_length.command[input_device][3]])
#end = start + length of stringlength + stringlength
                    v_input_buffer_actual_command_length.command[input_device][6]= v_input_buffer_actual_command_length.command[input_device][5]+v_input_buffer_actual_command_length.command[input_device][3]+length_of_actual_string #start + string
                if l < v_input_buffer_actual_command_length.command[input_device][6]:                                               #wait for end of actual string
                    return
                v_input_buffer_actual_command_length.command[input_device][4] -=1                                                   #decreament number of striings left
                if v_input_buffer_actual_command_length.command[input_device][4] != 0:
                    v_input_buffer_actual_command_length.command[input_device][5]= v_input_buffer_actual_command_length.command[input_device][6]
                    v_input_buffer_actual_command_length.command[input_device][6]=0                                                 #for wait for next stringlength
                else:
                    data=retranslate(input_device,device,0)
                    data += v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:v_input_buffer_actual_command_length.command[input_device][6]]
                    transfer_to_device_buffer(input_device,device,data)
                    finish_command(input_device)
    elif d == "c":
        if v_input_buffer_actual_command_length.command[input_device][3] == 0:                                                      #complete length not yet set
            number_of_bytes=bytes_to_int(v_input_buffer.inputline[input_device][v_input_buffer_actual_command_length.command[input_device][1]-v_input_buffer_actual_command_length.command[input_device][2]:v_input_buffer_actual_command_length.command[input_device][1]] )       #complete length of string
            if number_of_bytes ==0:
                finish_command(input_device)
            else:                                                                                                                   #set complete length
                v_input_buffer_actual_command_length.command[input_device][3]=number_of_bytes
            return
        else:
            if l < v_input_buffer_actual_command_length.command[input_device][1] + v_input_buffer_actual_command_length.command[input_device][3]:       #now complete length needed
                return
            else:
#resolve_inline_commandtoken()
                data=retranslate(input_device,device,0)
                data +=v_input_buffer.inputline[input_device][ v_command_length.commandtokenlength:v_command_length.commandtokenlength+v_input_buffer_actual_command_length.command[input_device][4]]                                            #commandtoken
                i=v_input_buffer_actual_command_length.command[input_device][1]                                                     #commandtoken +1 + length of stringlength
                temp=""
                while i+v_command_length.commandtokenlength <= len(v_input_buffer.inputline[input_device]):                         #change inline commandtoken
                    temp1= retranslate(input_device,device,i)
                    if temp1 == "error":
                        error=1
                    else:
                        temp += temp1
                    i += v_command_length.commandtokenlength
                if error ==1:
                    v_input_buffer.last_error[input_device]="wrong commandtoken in commandlist"
                else:
                    transfer_to_device_buffer(input_device,device,data+add_length(temp,v_device_buffer.commandtokenlength[device]))
                finish_command(input_device)
    elif d == "t":
#for oa command
        if l < v_input_buffer_actual_command_length.command[input_device][1]:                                                       #wait for parameter position
            return
        position= bytes_to_int(v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:v_input_buffer_actual_command_length.command[input_device][1]]) #arraypostion
        if v_input_buffer_actual_command_length.command[input_device][position+2][0]=="s":
            if l < v_input_buffer_actual_command_length.command[input_device][position+2][1]:                                       #wait until got string length
                return
            if v_input_buffer_actual_command_length.command[input_device][position+2][3] == 0:                                      #stringlength not yet set
                start=v_input_buffer_actual_command_length.command[input_device][position+2][1]-v_input_buffer_actual_command_length.command[input_device][position+2][2]   #actual pos - length of stringlength
                end=v_input_buffer_actual_command_length.command[input_device][position+2][1]                                       #actual pos
                number_of_bytes=bytes_to_int(v_input_buffer.inputline[input_device][start:end])
                if number_of_bytes ==0:
                    finish_command(input_device)
                v_input_buffer_actual_command_length.command[input_device][position+2][3]=number_of_bytes
            if l < v_input_buffer_actual_command_length.command[input_device][position+2][1]+v_input_buffer_actual_command_length.command[input_device][position+2][3]:
                return
            data=retranslate(input_device,device,0)
            data+= v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:]
            transfer_to_device_buffer(input_device,device,data)
            finish_command(input_device)
        else:                                                                                                                       #numeric
            if l < v_input_buffer_actual_command_length.command[input_device][1]+ v_input_buffer_actual_command_length.command[input_device][position+2][1]:  #commandlength + positionlength + parameterlength     #now complete length needed
                return
            data=retranslate(input_device,device,0)
            data+= v_input_buffer.inputline[input_device][v_command_length.commandtokenlength:]
            transfer_to_device_buffer(input_device,device,data)
            finish_command(input_device)
    else:
        v_input_buffer.last_error[input_device]="no valid commandtype"
        finish_command(input_device)
    return
#
def retranslate(input_device,device,start):
#retranlate one token  from CR token to devicetoken
#cr_token is the index to v_devvic_commans_for commandtoken
#return 0 if not valid
    ret=0
    cr_token=bytes_to_int(v_input_buffer.inputline[input_device][start:start+v_command_length.commandtokenlength]) #integer
    l=v_device_buffer.commandtokenlength[device]                                                                                    #retranslated token must have this length
    try:
        ret=int_to_bytes(v_device_command_for_commandtoken.command[v_all_command_token.a.index(cr_token)],l)
#    if not v_device_command_for_commandtoken.command[v_all_command_token.a.index(cr_token) in v_device_command.token[device]]:
    except ValueError:
        ret="error"
    if not cr_token in v_all_command_token.a:                                                                                       #necessary for inline token retransmit
        ret="error"
    return(ret)
#
def transfer_to_device_buffer(input_device,device,data):
#command send to devicebuffer
    v_device_buffer.actual_token[device]=v_input_buffer.actual_token_string[input_device]                                           #actual commandtoken
    v_device_buffer.input[device]=data                      #data to send
    return
#
def finish_command(input_device):
#call clear_v_input_buffer.a, is called, when the handlindling if a command is finished and data transfered to devicebuffer
#called, before answer erives
    print ("command finished")
    v_command_number.a +=1
    clear_input_buffer(input_device)
    return
#
def clear_input_buffer(input_device):
# reset some values of v_input_buffer after command finished
    v_input_buffer.actual_token[input_device]=0                                                                                     #actual commandtoken as int; 0 array cleared
    v_input_buffer.actual_token_string[input_device]=""                                                                             #actual commandtoken as str
    v_input_buffer.inputline[input_device]=""                                                                                       #actual input buffer
    v_input_buffer.device_index[input_device]=0                                                                                     #actual index to device involved
    v_input_buffer.original_command_index[input_device]=0                                                                           #actual index to command within device
    v_input_buffer.starttime[input_device]=0                                                                                        #starttime
    v_input_buffer.delete[input_device]=0                                                                                           #delete these number of bytes with finnish_command
#
    v_input_buffer_actual_command_length.command[input_device]=[]
    v_input_buffer_actual_command_length.answer[input_device]=[]
    v_input_buffer_actual_command_length.info[input_device]=[]
    return
#
def send_input_answer_buffer():
#checks v_input_buffer.answerline[x] (answer buffer for data to send to inputdivice)
    i=0
    while i < len(v_input_buffer.answerline):                                                                                       # all input buffers
        if v_input_buffer.answer_ready[i] == 1:                                                                                     #7: actual aswer ready
            v_sendstring.a=[]
            for lines in v_input_buffer.answerline[i]:
                v_sendstring.a.append(lines)
            send_string()
            v_input_buffer.answer_ready[i]=0
            v_input_buffer.answerline[i]=[]
        i+=1
    return
#
def send_string():
#now do not reply to input device, print to console only
#i will be the input_buffer
    for lines in v_sendstring.a:
        try:
            print(lines)
        except UnicodeEncodeError:
            print ("length unprintable ",lines[1:])
    return
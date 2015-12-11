#name : commandrouter_V01.1.py
#Version 01.0, 20151208
#purpose : Programm for a MYC commandrouter
#Can be used with raspberry Pi Hardware
#The Programm supports the MYC protocol
#copyright : DK1RI
#If no other rights are affected, this programm can be used under GPL (Gnu public licence)
#The Programm is not ready, see description
#The code is due to enhancements
#
#missing:
#answer, info handling
#rules devuce and logic get_announcements_of_one_lower_level_device
#device interfaces
#...
#
#general
import sys, os.path, time, socket, shutil, os
from copy import deepcopy
import msvcrt
#import smbus                                                                                                           #for i2c #sudo apt-get install python-smbu
#
#own subs
from commandrouter_command_handling import *
from commandrouter_length_of_commandtypes import *
from commandrouter_misc_functions  import *
from commandrouter_create_new_announce_list import *
from commandrouter_own_commands import *
#
#import variables for global use
#simple variables
import v_kbd_input
import v_sendstring
import v_command_number
import v_constants
#
#simple listss
import v_token_of_basic_announcements
import v_all_command_token
import v_commandrouter_announcements
import v_device_names_and_indiv
import v_configparameter
import v_input_buffer_list
#
#variables per device
import v_device_command
import v_device_announce
import v_device_buffer
#
#variables per input
import v_index_of_input_buffer
import v_input_buffer_actual_command_length
#
#variables per new commandtoken
import v_device_command_for_commandtoken
#
#other lists
import v_announcelist
import v_command_length
import v_commandrouter_params
#
lower_level_cr=[]                                                                                                       #list of full_indiv_line for lower level CR
#
#other arrays
time_values=[]
time_values.append(int(time.time()))                                                                                    #last check of active devices
time_values.append(int(time.time()))                                                                                    #last check of my_devices
#
#------------------------------------------------
#initialization, programs are used at start only
#------------------------------------------------
def dummy_sub():
    return
#
def init():
# read config and initialize parameter array (for commands an devices)
    readconfig()
    read_commandrouter_annoucements()
    read_networks()                                                                                                     #poll networks for other devices, create my_devices and copy devicegroupfile
    get_announcements_of_lower_level_devices()                                                                          #at start ask for all, later react on info only
    read_my_devices()                                                                                                   #initialize new known devices
    check_activity_of_devices()                                                                                         #also create announcelists
    return
#
def readconfig():
# configfile can be given with full path
# configfile is read read to v_configparameter[]
# for details of parameters see manual -> files
    config_file=""
    file=""
    if len(sys.argv) > 1:
        config_file(sys.argv[1])
    else:
        config_file="./config_commandrouter"
    if os.path.isfile(config_file) == False:
        sys.exit("Missing file:  "+ config_file)
    config_file=open (config_file)
    i=0
    for lines in config_file:                                                                                           #sequence within file is fixed!!!
        if lines[0] == "#":
            continue
        if i == 0:                                                                                                      #filename of commandrouter announcements
            if lines.rstrip() == "home":
                v_configparameter.announcements="announcements_commandrouter"
            else:
                v_configparameter.announcements=lines.rstrip()
                if os.path.isfile(configparameter.announcements) == False:
                    sys.exit("Missing file:  "+ configparameter.announcements)
        if i == 1:                                                                                                      #dir for my_devices
            if lines.rstrip() == "home":
                v_configparameter.my_devices_dir="."
            else:
                v_configparameter.my_devices_dir=lines.rstrip()
            if os.path.isdir(v_configparameter.my_devices_dir) == False:
                sys.exit("Missing dir:  "+ configparameter.my_devices_dir)
        if i == 2:                                                                                                      #nameprefix fo my_devices
            if lines.rstrip() == "home":
                v_configparameter.my_devices_prefix="my_device_"
            else:
                v_configparameter.my_devices_prefix=lines.rstrip()
        if i == 3:                                                                                                      #location of local devicegroupfiles
            if lines.rstrip() == "home":
               v_configparameter.devicegroup="./"
            else:
               v_configparameter.devicegroup=lines.rstrip()
            if os.path.isdir(v_configparameter.devicegroup) == False:
                sys.exit("Missing dir:  "+ configparameter.devicegroup)
        if i == 4:
            v_configparameter.time_for_activ_check=int(lines.rstrip())                                                  #time in sec for checking weather a device is active
        if i == 5:
            v_configparameter.time_for_device_search=int(lines.rstrip())                                                #ime in sec for searching for new devices
        if i == 6:
            v_configparameter.time_for_command_timeout=int(lines.rstrip())                                              #time in sec for command timeout
        i += 1
    config_file.close()
    if i != 7:
        sys.exit("wrong number of configparameters")
    return
#
def read_commandrouter_annoucements():
#read at int only. adding /deleting inputs for HI / PR require new start
#read commandrouter announcements to commandrouter_announcements[]
#extract data to v_command_params[]
#from individualzation  line (254) read the parameters for input devices and call their  initialization
#commandtoken of commandrouter_announcements[] will be modified to word .. if necessary later
    commandrouter_announcement=open(v_configparameter.announcements)
    for linesx in  commandrouter_announcement:                                                                          #file read
        if linesx[0] != "#":
            lines=linesx.rstrip()
            v_commandrouter_announcements.a.append(lines)
            if lines[0:3] == "252":
                v_commandrouter_params.length_of_last_error_length=length_of_int(int(lines.split(";")[2].split(",")[0]))
            if lines[0:3] == "254":                             #initialize commandrouter inputs for user interface etc ...
                item=lines.split(";")
                i = 0
                started = ""
                interface_number=0
                beginn_interface=0
                while i+2 < len(item):                                                                                  #scan all i>1
                    if len(item)<4:                                                                                     #must have these parameters
                        continue
                    item1=item[i+2].split(",")
                    if item1[1] == "NAME":                                                                              #second fild is the option
                        v_commandrouter_params.name.append(item1[2])                                                    #name as string wihout length
                        v_commandrouter_params.name.append(i)                                                           #index of field in announceline
                        v_commandrouter_params.length_of_name_length=length_of_int(int(item1[0]))
                        beginn_interface=0
                    elif item1[1] == "NUMBER":
                        v_commandrouter_params.number.append(int(item1[2]))                                             #number
                        v_commandrouter_params.number.append(i)                                                         #index of field in announceline
                        beginn_interface=0
                    elif item1[1] == "Terminal":
                        init_inputbuffer(item1[1],item1[2])
                        started=""
                        v_commandrouter_params.interface.append([])
                        v_commandrouter_params.interface[interface_number].append(item1)
                        v_commandrouter_params.interface[interface_number].append(item1[2])                             #name
                        v_commandrouter_params.interface[interface_number].append(i)                                    #index of field in announceline
                        interface_number+=1
                        beginn_interface=0
                    elif item1[1]  == "TELNET":
                        started = item[i+2]
                        s_value=item1[2]
                        index1=i
                        beginn_interface=1
                    elif item1[1]  == "HTTP":
                        started = item[i+2]
                        s_value=item1[2]
                        index1=i
                        beginn_interface=1
                    elif item1[1]  == "I2C":
                        started = item[i+2]
                        s_value=item1[2]
                        index1=i
                        beginn_interface=1
                    elif item1[1]  == "CAN":
                        started = item[i+2]
                        s_value=item1[2]
                        index1=i
                        beginn_interface=1
                    elif item1[1]  == "RC5":
                        started = item[i+2]
                        index1=i
                        s_value=item1[2]
                        beginn_interface=1
                    elif item1[1]  == "RC6":
                        started = item[i+2]
                        index1=i
                        s_value=item1[2]
                        beginn_interface=1
                    elif item1[1]  == "RS232":
                        started = item[i+2]
                        index1=i
                        s_value=item1[2]
                        beginn_interface=1
                    elif item1[1]  == "USB":
                        init_inputbuffer(item1[1],item1[2])
                        started=""
                        v_commandrouter_params.interface.append([])
                        v_commandrouter_params.interface[interface_number].append(item[i+2])
                        v_commandrouter_params.interface[interface_number].append(item1[2])                             #name
                        v_commandrouter_params.interface[interface_number].append(i)                                    #index of field in announceline
                        interface_number+=1
                        beginn_interface=0
                    elif item1[1] == "PORT" or item1[1] == "TIMEOUT":
                        if started.split(",")[1] == "TELNET" or started == "HTTP":                                      #one parameter only
                            fill_v_commandrouter_params(started,s_value,index1,item1[1],int(item1[2]),i,interface_number,beginn_interface)
                            if interface_number == 1:
                                interface_number+=1
                                beginn_interface=0
                    elif item1[1] == "ADRESS":
                        if started.split(",")[1] == "I2C" or started== "CAN" or started== "RC5" or started== "RC6":
                            fill_v_commandrouter_params(started,s_value,index1,item1[1],int(item1[2]),i,interface_number,beginn_interface)
                            if interface_number == 1:
                                interface_number+=1
                                beginn_interface=0
                    elif item1[1] == "BAUDRATE" or item1[1] == "COMPORT":
                        if started.split(",")[1] == "RS232":
                            fill_v_commandrouter_params(started,s_value,index1,item1[1],int(item1[2]),i,interface_number,beginn_interface)
                            if interface_number == 1:
                                interface_number+=1
                                beginn_interface=0
                    elif item1[1] == "NUMBER_OF_BITS":
                        if started.split(",")[1] == "RS232":
                            fill_v_commandrouter_params(started,s_value,index1,item1[1],item1[2],i,interface_number,beginn_interface)
                            if interface_number == 1:
                                interface_number+=1
                                beginn_interface=0
                    else:
                        started =""
                        beginn_interface=0
                    i += 1
    commandrouter_announcement.close()
    return
#
def fill_v_commandrouter_params(first,first_value,first_index,second,second_value,second_index,interface_number,beginn_interface):
    if beginn_interface == 1:
        v_commandrouter_params.interface.append([])
        v_commandrouter_params.interface[interface_number].append(first)
        v_commandrouter_params.interface[interface_number].append(first_value)
        v_commandrouter_params.interface[interface_number].append(first_index)
        init_inputbuffer(first.split(",")[1],first_value)
    v_commandrouter_params.interface[interface_number].append(second)
    v_commandrouter_params.interface[interface_number].append(second_value)
    v_commandrouter_params.interface[interface_number].append(second_index)                                             #index of field in announceline
    return
#
def init_inputbuffer(type,name):
# update or initialize one v_input_buffer
#name must be unique,
    m=len(v_input_buffer.name)
    v_input_buffer.name.append([])
    v_input_buffer.name[m]=type+name                                                                                    #name
    v_input_buffer.actual_token.append([])
    v_input_buffer.actual_token[m]=0                                                                                    #actual commandtoken as int
    v_input_buffer.actual_token_string.append([])
    v_input_buffer.actual_token_string[m]=""                                                                            #actual commandtoken as str
    v_input_buffer.inputline.append([])
    v_input_buffer.inputline[m]=""                                                                                      #actual input buffer
    v_input_buffer.answerline.append([])
    v_input_buffer.answerline[m]=[]                                                                                     #actual answer buffer
    v_input_buffer.answer_ready.append([])
    v_input_buffer.answer_ready[m]=0                                                                                    #actual answer ready
    v_input_buffer.device_index.append([])
    v_input_buffer.device_index[m]=0                                                                                    #actual index to device involved
    v_input_buffer.original_command_index.append([])
    v_input_buffer.original_command_index[m]=0                                                                          #9actual index to command within device
    v_input_buffer.starttime.append([])
    v_input_buffer.starttime[m]=0                                                                                       #1starttime
    v_input_buffer.delete.append([])
    v_input_buffer.delete[m]=0                                                                                          #number of bytes of command and sent to devicebuffer , delete these bytes if cmd finnished
    v_input_buffer.last_error.append([])
    v_input_buffer.last_error[m]="no error"                                                                             #last error message
    v_input_buffer.wait.append([])
    v_input_buffer.wait[m]=0                                                                                            #wait
#
    v_input_buffer_list.type.append([])
    v_input_buffer_list.type[m]=type
    v_input_buffer_list.name.append([])
    v_input_buffer_list.name[m]=type+name
#
    v_input_buffer_actual_command_length.command.append([])
    v_input_buffer_actual_command_length.answer.append([])
    v_input_buffer_actual_command_length.info.append([])
    return
#
def read_my_devices():
#executed at start and every x minutes
#add new devices but do not delete
#different devices must have different basic announcements and / or different induvidualization ie: file content must be unique !!!
#this sub generates device_names_and_indiv.all and device_names_and_indiv.activ only (and call read of lower level CR if necessary
#program crashes, if filenames contain special characters
    global lower_level_cr
    prefix_len=len(v_configparameter.my_devices_prefix)
    files_dirs = os.listdir(v_configparameter.my_devices_dir)
    for name in files_dirs:
        if len(name)>prefix_len:
            if name[0:prefix_len] == v_configparameter.my_devices_prefix:                                               #mydevice file
                my_dev_file= open(v_configparameter.my_devices_dir+name)
                switch=0
                i=0
                for lines in my_dev_file:                                                                               #additional devices?
                    if lines == "" or lines[0] == "#":
                        continue
                    if switch == 0:                                                                                     #first line, base
                        basic_line=lines.rstrip()
                        item=basic_line.split(";")
                        switch=1
                    else:                                                                                               #second line: indiv
                        indiv=lines.rstrip()
                        full_indiv_line= basic_line+";"+indiv
                        item=basic_line.split(";")
                        if full_indiv_line in v_device_names_and_indiv.all:                                             #avoid dupes while reread
                            continue
                        else:
                            v_device_names_and_indiv.all.append(full_indiv_line)
                            v_device_names_and_indiv.activ.append(1)
                            item1=item[1].split(",")
                            if item1[0] == "c":                                                                         #lower level CR
                                lower_level_cr.append(full_indiv_line)
                            device_number=initialize_device()
                            read_announcements_of_a_device(indiv,device_number)
                        switch=0
                        i += 1
                my_dev_file.close()
    return
#
#------------------------------------------------
#tasks, with new device
#------------------------------------------------
def initialize_device():
#create new device_buffer
    device=len(v_device_names_and_indiv.all) -1                                                                         #device point to the next empty element
#
    v_device_buffer.name.append([])
    v_device_buffer.name[device]=v_device_names_and_indiv.all[device]                                                   #name of that device (devicegroup and indiv)
    v_device_buffer.interface.append([])
    v_device_buffer.interface[device]=""                                                                                #interfaceparamters of device
    v_device_buffer.commandtokenlength.append([])
    v_device_buffer.commandtokenlength[device]=0                                                                        #commandlength of commands for device
    v_device_buffer.actual_token.append([])
    v_device_buffer.actual_token[device]=0                                                                              #actual commandtoken in work, 0, nothing actual
    v_device_buffer.input.append([])
    v_device_buffer.input[device]=""                                                                                    #input from inputbuffer
    v_device_buffer.wait_for_answer.append([])
    v_device_buffer.wait_for_answer[device]=0                                                                           #actual need to wait for answer?
    v_device_buffer.answer.append([])
    v_device_buffer.answer[device]=""                                                                                   #actual received answer buffer from device
    return(device)
#
def read_announcements_of_a_device(indiv,device_number):
# read announcements of one new device and resolve duplicate commandtoken / commandtype:
#delete ANNOUNCEMENT line
#find number of commands (excluding  rules and ANNOUNCEMENT line)
    device=len(v_device_names_and_indiv.all)-1                                                                          #device point to the actual element
    device_temp_command=[]
    device_temp_announce=[]
#load announcements an resolve duplicate token ans "as" lines
    line=v_device_names_and_indiv.all[device]
    item1=split_desc(line)
    item=item1.split(";")
    file=v_configparameter.devicegroup+item[2]+"_"+item[3]+"_"+item[4]
    device_group_file=open(file)
    token_of_a_device=[]                                                                                                #for check of duplicate token
    ann_string=""
    k=0                                                                                                                 #index for announcement
    i=0                                                                                                                 #index for command
    max_number_for_local_commands=0                                                                                     #max of lokal commandtoken
    for linesx in device_group_file:                                                                                    #resolve duplicate token
        if linesx[0] == "#":
            continue
        lines=linesx.rstrip()
        if lines[0]  == "R":
            device_temp_announce.append(lines)
        else:
            item=lines.split(";")
            if int(item[0]) < max_number_for_local_commands:
                max_number_for_local_commands = int(iten[0])
            if item[0]+";"+item[1] in token_of_a_device:                                                                #duplicate commandtoken / type, concatenate to one line
                index=token_of_a_device.index(item[0]+";"+item[1])                                                      #where is it? -> index
                ann_string=device_temp_command[index]                                                                   #the existing string
                j=0
                for item1 in item:                                                                                      #append to existing
                    if j>1:
                        ann_string += ";"+item1
                    j += 1
                device_temp_command[index]=ann_string
                device_temp_announce[index]=ann_string
            else:
                token_of_a_device.append(item[0]+";"+item[1])
                device_temp_announce.append(lines)
                device_temp_command.append(lines)
                i+=1
            if len(item) > 1:                                                                                           #resolve "as"lines
                item1=item[1].split(",")
                if (len(item1) > 1):
                   if (item1[1][0:2] == "as") :                                                                         #in commandlines here may be something as "as123"
                        as_number=item1[1].split("as")[1]
                        m=0
                        while m < len(device_temp_command):
                            if as_number == device_temp_command[m].split(";")[0]:                                       #originalline found
                                new_commandtype=item[1].split(",")[0]
                                k=1
                                item2=device_temp_command[m].split(";")[1].split(",")
                                while k < len(item2):
                                    new_commandtype+=","+item2[k]
                                    k +=1
                                new_command_line=device_temp_command[m].split(";")
                                new_command_line[0]=item[0]                                                             #actual token
                                new_command_line[1]=new_commandtype
                                device_temp_announce[i-1]=";".join(new_command_line)
                                device_temp_command[i-1]=";".join(new_command_line)
                            m+=1
        k+=1
    device_group_file.close()
    local_command_length =1
    if max_number_for_local_commands > 0xFFFF:
        local_command_length=4
    elif max_number_for_local_commands > 0xFF:
        local_command_length=2
    v_device_buffer.commandtokenlength[device_number]=local_command_length
#
#delete ANNOUNCEMENT line
#modify 2nd individualization line
    i=0
    first_line=1
    for lines in device_temp_command:
        if lines[0] != "R":
            item1=lines.split(";")[1].split(",")
            if len(item1)>1:
                if item1[1] == "ANNOUNCEMENTS" :                                                                        #no announcements
                    device_temp_command[i]=""
                if item1[1] == "INDIVIDUALIZATION" :                                                                    #modify decond INDIVIDUALIZATION line
                    if  first_line == 1:
                        device_temp_announce[i]=indiv
                        first_line=0
        i += 1
    i=0
    first_line=1
    for lines in device_temp_announce:
        if lines[0] != "R":
            item1=lines.split(";")[1].split(",")
            if len(item1)>1:
                if item1[1] == "ANNOUNCEMENTS" :                                                                        #no announcements
                    device_temp_announce[i]=""
                if item1[1] == "INDIVIDUALIZATION" :                                                                    #modify first INDIVIDUALIZATION line
                    if  first_line == 1:
                        device_temp_announce[i]=indiv
                        first_line=0
        i += 1
#
#write temp to final
    v_device_command.announceline.append([])
    v_device_command.token.append([])
    v_device_announce.announceline.append([])
    v_device_announce.token.append([])
    for lines in device_temp_command:
        if lines != "":
            v_device_command.announceline[device].append(lines)
            v_device_command.token[device].append(int(lines.split(";")[0]))
    for lines in device_temp_announce:
        if lines != "":
            v_device_announce.announceline[device].append(lines)
            v_device_announce.token[device].append(int(lines.split(";")[0]))
#
#action for the new device finished
    return
#
def read_networks():
#poll networks for other devices, create my_devices and copy devicegroupfile
#missing
    return
#
def get_announcements_of_lower_level_devices():
#at start ask for all, later react on info only
#ask via &HxxF0 command
#not complete
    global configparameter
    interface=""
    prefix_len=len(v_configparameter.my_devices_prefix)
    files_dirs = os.listdir(v_configparameter.my_devices_dir)                                                           #find my_devices files for lower level CR
    for name in files_dirs:
        if len(name)>prefix_len:
            if name[0:prefix_len] == v_configparameter.my_devices_prefix:                                               #mydevice file
                my_dev_file= open(v_configparameter.my_devices_dir+name)
                switch=0
                i=0
                for lines in my_dev_file:                                                                               #additional devices?
                    if lines == "" or lines[0] == "#":
                        continue
                    if switch == 0:                                                                                     #first line, base
                        basic_line=lines.rstrip()
                        if basic_line.split(";")[1].split(",")[0]!="c": #no CR
                            continue
                        switch=1
                    else:                                                                                               #second line: indiv
                        indiv=lines.rstrip()
                        full_indiv_line= basic_line+";"+indiv
                        item=full_indiv_line.split(";")
#exctract interface
#missing
                        get_announcements_of_one_lower_level_device(interface)
                        switch=0
                my_dev_file.close()
    return
#
def get_announcements_of_one_lower_level_device(interface):
    global configparameter
#ask via &HxxF0 command
#not complete
#read announcementlist
#missing
#instead read file:
    temp=[]
    file=open("./original_lower_level_announce_file")
    i=0
    for line in file:
        line.rstrip()
        temp.append(line)
        item=line.split(";")
        if i==0:
            new_file=configparameter[3]+item[2]+"_"+item[3]+"_"+item[4]
        else:
            if len(item)>1:
                item1=item[1].split(",")
                if len(item1)>1:
                    if item1[1]=="ANNOUNCEMENTS":
                        no_of_ann=i
        i+=1
    file.close()                                                                                                        #reorder lines
    file=open(new_file,'w')
    file.write(temp[0])
    i=no_of_ann
    while i < len(temp):
        file.write(temp[i])
        i+=1
    i=1
    while i <= no_of_ann-1:
        file.write(temp[i])
        i+=1
    file.close()
    return
#
#------------------------------------------------
#time dependent task
#------------------------------------------------
def time_dependent_tasks():
#check for timeout of inputs, write errormessage to inputbuffer
    global time_values
    if int(time.time()) - time_values[0] > v_configparameter.time_for_activ_check:
        if  v_configparameter.time_for_device_search - int(time.time())> 2:                                             #not to to this twice...
            check_activity_of_devices()
            v_configparameter.time_for_activ_check=time.time()
    if int(time.time()) - time_values[1] > v_configparameter.time_for_device_search:
        check_new_my_devices()
        v_configparameter.time_for_device_search=time.time()
    i=0
    for item in v_input_buffer.inputline:                                                                               #timeout for input buffer, for command and answer
        if v_input_buffer.inputline[i] != "":
            if (int(time.time())- v_input_buffer.starttime[i]) > v_configparameter.time_for_command_timeout:
                v_input_buffer.last_error[i]="timeout "+str(v_command_number.a)
                finish_command(i)
        i += 1
    return
#
def check_activity_of_devices():
#not final
    v_device_names_and_indiv.active=[]
    for devices in v_device_names_and_indiv.all:
# check missing
        dummy_sub()
#for testphase only!!!!!!!!!!!!!!!!!!!!:
    v_device_names_and_indiv.active=list(v_device_names_and_indiv.all)
#
    notfound=0                                                                                                          #list may have different sequence
    for line in v_device_names_and_indiv.active:
        if line in v_device_names_and_indiv.last:
            continue
        notfound=1                                                                                                      #one element not found
    if notfound == 0:
        for line in v_device_names_and_indiv.last:
            if line in v_device_names_and_indiv.active:
                continue
            notfound=1
    if notfound == 1:
        create_new_announce_list()
        v_device_names_and_indiv.last=list(v_device_names_and_indiv.last)
#send info for new list to all
#missing
    print("new announcelists")
    return
#
def check_new_my_devices():
    read_networks()                                                                                                     ##poll networks for other devices, create my_devices and copy devicegroupfile
    read_my_devices()                                                                                                   #initialize new known devices
    check_activity_of_devices()                                                                                         #also create announcelists
    return
#
#------------------------------------------------
#input handling
#------------------------------------------------
def poll_inputs():
    input_buffer_number=0
    while input_buffer_number<len(v_input_buffer_list.name):
        if v_input_buffer_list.type[input_buffer_number]=="Terminal":
            if msvcrt.kbhit():
# for test purposes!!
# this is the keyboard interface not according to MYC specification:
# a numeric input as ascii (decimal 0... 255) values is converted to one byte
# after each space the sub for checking the v_kbd_input.a is called
                t=msvcrt.getwch()                                                                                       #str
                if ord(t) == 32:
                    if v_kbd_input.a != "":
                        i=(int(v_kbd_input.a))
                        if i<256:
                            if v_input_buffer.starttime[input_buffer_number] == 0:                                      #start timeout
                                v_input_buffer.starttime[input_buffer_number]=int(time.time())
                            v_input_buffer.inputline[input_buffer_number] += int_to_bytes(i,1)                          #rxbuffer
                            print("kbd_in",v_kbd_input.a)
                        v_kbd_input.a=""
                else:
                    if str.isnumeric(t)== 1:
                        v_kbd_input.a += t
        elif v_input_buffer_list.type[input_buffer_number]=="TELNET":
            connected=0
            try:
                conn, addr = s.accept()
                connected=1
                print ("connected")
            except BlockingIOError:
                dummy=0
            if connected:
                try:
                    telnetbyte=conn.recv(255)
                    print(telnetbyte)
                    if v_input_buffer.starttime[input_device] == 0:                                                     #start timeout
                        v_input_buffer.name[input_device]=int(time.time())
                    i = 0
                    while (i < len(telnetbyte)) :
                        if telnetbyte[i] == 32:
                            telnetstring=telnetstring+(chr(int(tempin)))
                            tempin = ""
                        else:
                            if (ord(telnetbyte[i])> 47 and ord(telnetbyte[i])< 58):
                                tempin = tempin + telnetbyte[i]
                        i+=1
                    v_input_buffer.inputline[index_of_input_buffer.index("0")]= telnetstring                            #one ethernet access only
                    tempin = ""
                except BlockingIOError:
                    dummy=0
        input_buffer_number+=1
    return
#
def open_telnet():
    global s
    i = 0
    for temp in v_input_buffer_list.type:
        if temp== "TELNET":
            HOST = ''   # Symbolic name meaning all available interfaces
            PORT = 23 # Arbitrary non-privileged port
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.setblocking(0)
            try:
                s.bind((HOST, PORT))
            except socket.error:
                sys.exit("Bind failed")
            s.listen(10)
            print("telnet connect possible")
        i+=1
    return
#
def transmit_device_buffer_to_device():
#checks device_buffer.input (actual received commands buffer after command is ready, to be sent to device)
#call send_string (now send to terminal only with some additional information)
#clear device_buffer
    text=""
    i=0
    for item in v_device_buffer.input:                                                                                  #check all buffer
        if item != "":                                                                                                  #output data
            v_sendstring.a=[]
            text="Device "+str(i)+": == "+item+" === "
            j=0
            while j<len(v_device_buffer.input[i]):
                text += str(ord(v_device_buffer.input[i][j]))+" "
                j+=1
            text += "=="
            v_sendstring.a.append(text)
            send_string()
            v_sendstring.a=[]
            reset_device_buffer(i)
        i += 1
    return
#
def read_device_answer_buffer():
#read the answer
    return
#
#------------------------------------------------
#subprograms for tests
#------------------------------------------------
def print_for_test():
    print_for_test1("all_command_token",v_all_command_token.a)
    print_for_test1("v_device_names_and_indiv.active",v_device_names_and_indiv.active)
    print_for_test1("v_device_names_and_indiv.all",v_device_names_and_indiv.all)
    print_for_test1("v_token_of_basic_announcements",v_token_of_basic_announcements.a)
    print_for_test1("commandrouter_announcements",v_commandrouter_announcements.a)
    print_for_test1("v_announcelist_basic",v_announcelist.basic)
    print_for_test1("v_announcelist_full",v_announcelist.full)
    print_for_test1("v_announcelist_rules",v_announcelist.rules)
    return
#
def print_for_test1(file,data):
#------------------------for check
    handle=open("check_output/"+file,"w")
    i=0
    for lines in data:
        handle.write(str(lines)+"\n")
        i+=1
    handle.close()
    return
#
def print_for_test2(file,data):
#------------------------for check
    handle=open("check_output/"+file,"w")
    i=0
    for device in data:
        for lines in device:
            handle.write(str(i)+" : "+lines+"\n")
        i+=1
    handle.close()
    return
#
# Main
#
init()
print_for_test()
open_telnet()
#
while 1:
    poll_inputs()
    poll_input_buffer()
    transmit_device_buffer_to_device()
    send_input_answer_buffer()                                                                                          #answers for HI ...
    read_device_answer_buffer()                                                                                         #transfer device answer to input buffer answer
    time_dependent_tasks()
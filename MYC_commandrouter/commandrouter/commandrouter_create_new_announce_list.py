#new announcelists are created and some assotiated lists and parameters
import v_device_announce
import v_commandrouter_announcements
import v_announcelist
import v_all_command_token
import v_commandrouter_params
import v_device_command_for_commandtoken
import v_reserved_commands_for_commandtoken
import v_token_of_basic_announcements
from commandrouter_misc_functions import *
def create_new_announce_list():
#now new announcelists are created and some values may change:
#
#number of all announcements and their maximum length:
    number_of_all_announcements=0
    number_of_commands=0
    max_length_of_all_announcments=0
    number_of_devices=0
    i=0
    for dev in v_device_announce.announceline:
        j=0
        for announce in v_device_announce.announceline[i]:
            number_of_all_announcements += 1
            if len(announce) > max_length_of_all_announcments:                                                          #includes rules
                max_length_of_all_announcments=len(announce)
            if announce[0] != "R":
                number_of_commands+=1
                dev_typ=announce.split(";")[1].split(",")[0]
                if dev_typ == "m" or dev_typ=="c" or dev_typ =="r" or dev_typ == "l" or dev_typ == "h" or dev_typ =="v" or dev_typ == "p":
                    number_of_devices+=1
            j+=1
        i+=1
    for announce in v_commandrouter_announcements.a:
        number_of_all_announcements+=1
        if len(announce) > max_length_of_all_announcments:
            max_length_of_all_announcments=len(announce)
    v_commandrouter_params.length_of_announcement_length=max_length_of_all_announcments
#
    calculate_length_of_commandtoken(number_of_commands+ 16)                                                            #16 reserved commands
#
#create final annoucelists with new commandtoken
#inline translation of matacommands and rules
#strip individualization lines
    v_announcelist.full=[]
    v_announcelist.basic=[]
    v_announcelist.full.append("")                                                                                      #for basic CR line
    v_announcelist.basic.append("")                                                                                     #for basic CR line
    v_token_of_basic_announcements.a.append(int(0))                                                                     #new commantoken
    device=0
    new_command_number=v_command_length.startnumber
    number_of_CR=0
    v_all_command_token.a=[]
    for dev in v_device_announce.announceline:                                                                          #lines for other devices
        announcement_number=0                                                                                           #announcement_number within that device
        command_number_in_device=0                                                                                      #commandnumber within device
        for announce in v_device_announce.announceline[device]:
            if announce[0] != "R":
                error=0
                items=announce.split(";")
                item=items[1].split(",")
                original_command_token=int(items[0])
                items[0]=str(new_command_number)                                                                        #new command token
                v_all_command_token.a.append(new_command_number)                                                        #all final commandtoken
                v_device_command_for_commandtoken.device.append(device)                                                 #device for that token
                v_device_command_for_commandtoken.command.append(original_command_token)                                #original command for that token
                v_device_command_for_commandtoken.commandtype.append(item[0])                                           #commandtype for that token
                v_device_command_for_commandtoken.announceline.append(announce)                                         #announceline for that token
                read=0
                announce_missing =1
                if len(item)>1:
                    if item[1]=="INDIVIDUALIZATION":                                                                    #keep NAME and NUMBER from INDIVIDUALIZATION only
                        i=2
                        while i<(len(items)):
                            item2=items[i].split(",")
                            if len(item2)>1:
                                if item2[1]!="NAME":
                                    if item2[1]!="NUMBER":
                                        items[i]=""
                            i+=1
                        i=0
                        while i < len(items):                                                                           #join has some ; at the end :(
                            if i==0:
                                announce=items[i]
                            else:
                                if items[i]!="":
                                    announce+=";"+items[i]
                            i+=1
                        announce_missing=0
                if announce_missing ==1:
                    announce=";".join(items)
                if item[0] =="c":
                    number_of_CR += 1
                if item[0] == "m":                                                                                      #basic annonouncement
                    v_announcelist.basic.append(";".join(items))
                    v_token_of_basic_announcements.a.append(int(items[0]))                                              #new commantoken
#change inline token for meta commands
                if item[0]=="wk" or item[0]=="wi" or item[0]=="wf":
                    error=0
                    ij=0
                    error=1
                    for item in items:
                        if ij <2:
                            continue
                        tr=items[ij].split(",")
                        token=int(tr[0])                                                                                #token to replace
                        n=0
                        while n < len(v_device_params.a[device]):
                            if v_device_params.a[device][n][1] == token:
                                tr[0] = str(v_device_params.a[device][n][0])
                                error=0
                                items[ij]=",".join(tr)
                                break
                            n += 1
                        ij += 1
                    if error == 0:
                        announce=";".join(items)
                    else:
                        announce="metacommand error"
                new_command_number+=1
                command_number_in_device+=1
                v_announcelist.full.append(announce)
            else:
#resolve inline token for rules:
                items=announce[1:].split("$")
                ij=0
                error=0
                for item in items:                                                                                      #one $xx command:
                    number=""
                    if ij > 0:                                                                                          #before 1st $ is nothing
                        new_item=item
                        finished=0                                                                                      #search for complete number not finished
                        ik=0
                        while ik < len(item):
                            if (item[ik].isdigit() == 1) & (finished == 0):                                             #number follows $
                                number=number+item[ik]
                            else:                                                                                       #no more number, search new token
                                if finished == 0:                                                                       #number found, find index for line in announce
                                    int_number=int(number)
                                    n=0
                                    found=0
                                    while n < len(v_device_params.a[device]):
                                        if v_device_params.a[device][n][1] == int_number:
                                            new_item = str(v_device_params.a[device][n][0])
                                            found= 1
                                            break
                                        n += 1
                                    finished = 1                                                                        #new commandtoken found or error
                                    if found == 0:
                                        error=1
                                new_item=new_item+item[ik]                                                              #modified field
                            ik += 1
                        items[ij]=new_item
                    ij += 1
                if error == 0:
                    announce="R"+"$".join(items)
                else:
                    announce="R error"
                v_announcelist.full.append(announce)
                v_announcelist.rules.append(announce)
            announcement_number+=1
        device+=1
#add lines for CR
    tr=v_commandrouter_announcements.a[0].split(";")                                                                    #modify number of announcelines and length for CR basic line
    tr[5]= str(number_of_devices)
    tr[6]= str(max_length_of_all_announcments)
    tr[7]= str(number_of_commands+1)                                                                                    #+1 basic CR announcement
    tr[8]=str(number_of_all_announcements)
    v_announcelist.full[0]=";".join(tr)                                                                                 #basic CR line
    v_announcelist.basic[0]=";".join(tr)
    for lines in  v_commandrouter_announcements.a:
        tr=lines.split(";")
        if lines[0]!="0":                                                                                               #not basic line
            tr[0]=str(int(tr[0]) + v_command_length.adder)
            if (len(tr[1].split(",")[1])) > 0:
                if tr[1].split(",")[1] == "ANNOUNCEMENTS":
                    tr[2]= str(max_length_of_all_announcments)
                    tr[3]= str(number_of_all_announcements)
            v_announcelist.full.append(";".join(tr))                                                                    #list write
    return
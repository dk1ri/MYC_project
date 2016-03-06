# new announcelists are created and some assotiated lists and parameters
import v_all_command_token
import v_announcelist
import v_command_length
import v_constants
import v_commandrouter_params
import v_commandrouter_announcements
import v_device_announce
import v_device_command_for_commandtoken
import v_linelength
import v_token_of_basic_announcements
import v_dev_devtoken_for_crtoken
import commandrouter_misc_functions


def create_new_announce_list():
    # now new announcelists are created and some values may change:

    # claculate number of all announcements and their maximum length:
    number_of_all_announcements = 0
    number_of_commands = 0
    max_length_of_all_announcments = 0
    number_of_devices = 0
    i = 0
    while i < len(v_device_announce.announceline):
        j = 0
        for announce in v_device_announce.announceline[i]:
            number_of_all_announcements += 1
            # includes rules for announcements
            if len(announce) > max_length_of_all_announcments:
                max_length_of_all_announcments = len(announce)
            if announce[0] != "R":
                number_of_commands += 1
                dev_typ = announce.split(";")[1].split(",")[0]
                if dev_typ == "m" or dev_typ == "c" or dev_typ == "r" or dev_typ == "l" or dev_typ == "h" or dev_typ == "v" or dev_typ == "p":
                    number_of_devices += 1
            j += 1
        i += 1
    for announce in v_commandrouter_announcements.a:
        number_of_all_announcements += 1
        if len(announce) > max_length_of_all_announcments:
            max_length_of_all_announcments = len(announce)
    v_commandrouter_params.length_of_announcement_length = max_length_of_all_announcments
    # 16 reserved commands
    commandrouter_misc_functions.calculate_length_of_commandtoken(number_of_commands + 16)

    # create final annoucelists with new commandtoken
    # inline translation of matacommands and rules
    # strip individualization lines
    v_announcelist.full = []
    v_announcelist.basic = []
    # for basic CR line
    v_announcelist.full.append("")
    # for basic CR line
    v_announcelist.basic.append("")
    # new commantoken
    v_token_of_basic_announcements.a.append(int(0))
    v_linelength.command = []
    v_linelength.answer = []
    v_linelength.info = []
    # for CR basic announceline
    v_linelength.command.append([])
    v_linelength.answer.append([])
    v_linelength.info.append([])
    # also for CR basic announceline
    v_dev_devtoken_for_crtoken.a["CR"] = 0
    device = 0
    new_command_number = v_command_length.startnumber
    # as index for v_linelength start with 0
    basic_token_number = 1
    number_of_cr = 0
    v_all_command_token.a = []
    # prerun: find per device: original token -> newtoken
    while device < len(v_device_announce.announceline):
        new_token_list = []
        original_token_list = []
        temp_new_token = new_command_number
        for announce in v_device_announce.announceline[device]:
            if announce[0] != "R":
                new_token_list.append(temp_new_token)
                original_token_list.append(int(announce.split(";")[0]))
            temp_new_token += 1
        # announcement_number within that device
        announcement_number = 0
        # commandnumber within device
        command_number_in_device = 0
        for announce in v_device_announce.announceline[device]:
            if announce[0] != "R":
                items = announce.split(";")
                item = items[1].split(",")
                v_linelength.command.append([])
                v_linelength.answer.append([])
                v_linelength.info.append([])
                # create list of length of command, answer and info for this cr command
                v_constants.commandtypes[item[0]](announce, basic_token_number)
                original_command_token = int(items[0])
                # new command token
                items[0] = str(new_command_number)
                # all final commandtoken
                v_all_command_token.a.append(new_command_number)
                # device for that token
                v_device_command_for_commandtoken.device.append(device)
                # original command for that token
                v_device_command_for_commandtoken.command.append(original_command_token)
                # commandtype for that token
                v_device_command_for_commandtoken.commandtype.append(item[0])
                # announceline for that token
                v_device_command_for_commandtoken.announceline.append(announce)
                # hash: device, commandtoken  -> cr commandtoken
                v_dev_devtoken_for_crtoken.a[str(device) + ";" + str(original_command_token)] = basic_token_number
                announce_missing = 1
                if len(item) > 1:
                    # keep NAME and NUMBER from INDIVIDUALIZATION only
                    if item[1] == "INDIVIDUALIZATION":
                        i = 2
                        while i < (len(items)):
                            item2 = items[i].split(",")
                            if len(item2) > 1:
                                if item2[1] != "NAME":
                                    if item2[1] != "NUMBER":
                                        items[i] = ""
                            i += 1
                        i = 0
                        # join has some ; at the end :(
                        while i < len(items):
                            if i == 0:
                                announce = items[i]
                            else:
                                if items[i] != "":
                                    announce += ";" + items[i]
                            i += 1
                        announce_missing = 0
                if announce_missing == 1:
                    announce = ";".join(items)
                if item[0] == "c":
                    number_of_cr += 1
                # basic annonouncement
                if item[0] == "m":
                    v_announcelist.basic.append(";".join(items))
                    # new commantoken
                    v_token_of_basic_announcements.a.append(int(items[0]))
                # change inline token for meta commands
                if item[0] == "wk" or item[0] == "wi" or item[0] == "wf":
                    ij = 0
                    error = 1
                    il = 0
                    while il < len(items):
                        if ij < 2:
                            continue
                        tr = items[ij].split(",")
                        # token to replace
                        token = int(tr[0])
                        n = 0
                        while n < len(original_token_list):
                            if original_token_list[n] == token:
                                tr[0] = str(new_token_list[n])
                                error = 0
                                items[ij] = ",".join(tr)
                                break
                            n += 1
                        tr[0] = str(new_token_list[token])
                        ij += 1
                        il += 1
                    if error == 0:
                        announce = ";".join(items)
                    else:
                        announce = "metacommand error"
                new_command_number += 1
                basic_token_number += 1
                command_number_in_device += 1
                v_announcelist.full.append(announce)
            # rules
            else:
                # resolve inline token for rules:
                items = announce[1:].split("$")
                ij = 0
                error = 0
                # one $xx command:
                for item in items:
                    number = ""
                    # before 1st $ is nothing
                    if ij > 0:
                        new_item = item
                        # search for complete number not finished
                        finished = 0
                        ik = 0
                        while ik < len(item):
                            # number follows $
                            if (item[ik].isdigit() == 1) & (finished == 0):
                                number = number + item[ik]
                            # no more number, search new token
                            else:
                                # number found, find index for line in announce
                                if finished == 0:
                                    int_number = int(number)
                                    n = 0
                                    found = 0
                                    while n < len(original_token_list):
                                        if original_token_list[n] == int_number:
                                            new_item = str(new_token_list[n])
                                            found = 1
                                            break
                                        n += 1
                                        # new commandtoken found or erro
                                    finished = 1
                                    if found == 0:
                                        error = 1
                                # modified field
                                new_item = new_item+item[ik]
                            ik += 1
                        items[ij] = new_item
                    ij += 1
                if error == 0:
                    announce = "R" + "$".join(items)
                else:
                    announce = "R error"
                v_announcelist.full.append(announce)
                v_announcelist.rules.append(announce)
        announcement_number += 1
        device += 1
    # add lines for CR
    # modify number of announcelines and length for CR basic line
    tr = v_commandrouter_announcements.a[0].split(";")
    tr[5] = str(number_of_devices)
    tr[6] = str(max_length_of_all_announcments)
    # +1 basic CR announcement
    tr[7] = str(number_of_commands+1)
    tr[8] = str(number_of_all_announcements)
    # basic CR line
    v_announcelist.full[0] = ";".join(tr)
    v_announcelist.basic[0] = ";".join(tr)
    for lines in v_commandrouter_announcements.a:
        tr = lines.split(";")
        # not basic line
        if lines[0] != "0":
            tr[0] = str(int(tr[0]) + v_command_length.adder)
            if (len(tr[1].split(",")[1])) > 0:
                if tr[1].split(",")[1] == "ANNOUNCEMENTS":
                    tr[2] = str(max_length_of_all_announcments)
                    tr[3] = str(number_of_all_announcements)
                    # list write
            v_announcelist.full.append(";".join(tr))
    return

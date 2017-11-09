# name : commandrouter_create_new_announce_list.py
# new announcelist is created or modified and some associated lists and parameters

from length_of_commandtypes import *
import misc_functions
import v_announcelist
import v_cr_params
import v_dev
import v_token_params
import v_linelength


def create_new_announce_list():
    # count number of all announcements and some other values for full list
    number_of_all_announcements = 0
    max_length_of_all_announcments = 0
    v_cr_params.number_of_commands = 0
    v_cr_params.number_of_commands_noCR = 0
    number_of_devices = 0
    device = 0
    # all devices, CR inclusive
    # v_dev.announceline[i] have announcement and individualization lines dropped except CR
    while device < len(v_dev.announceline):
        j = 0
        for announce in v_dev.announceline[device]:
            # all lines of a device
            v_dev.announceline[device][j] = resolve_bin_hex(announce)
            j += 1
        number_of_device_commands = 0
        # set set later:
        v_token_params.announcements[0] = 0
        for announce in v_dev.announceline[device]:
            # all lines
            number_of_all_announcements += 1
            if len(announce) > max_length_of_all_announcments:
                max_length_of_all_announcments = len(announce)
            if announce[0] != "R" and announce[0] != "I" and announce[0] != "Q":
                number_of_device_commands += 1
                # used to calculate length_commandtoken -> omit device 0
                v_cr_params.number_of_commands += 1
                if device != 0:
                    v_cr_params.number_of_commands_noCR += 1
                # tok -> announcelist index, +1 due to "0"
                dev_typ = announce.split(";")[1].split(",")[0]
                # is used in CR basic line: normal devices and lower level CR
                if dev_typ == "m" or dev_typ == "c":
                    number_of_devices += 1
        device += 1
    # add CR:
    v_cr_params.number_of_commands_noCR += 1

    v_cr_params.length_of_announcement_length = max_length_of_all_announcments
    # commandtoken are without gaps: this is the highest number of a token (+ &HxxFx commands)
    # leave gaps for 16 reserved commands of SK
    misc_functions.calculate_length_of_commandtoken(v_cr_params.number_of_commands_noCR)

    # modify commandtoken for CR (device 0)
    # skip basic line
    i = 1
    while i < len(v_dev.announceline[0]):
        line = v_dev.announceline[0][i]
        # not basic line (is 1st line):
        if line[0] == "I" or line[0] == "R" or line[0] == "Q":
            pass
        else:
            # add adder for commandtoken
            tr = line.split(";")
            tr[0] = str(int(tr[0]) + v_cr_params.adder)
            v_dev.announceline[0][i] = ";".join(tr)
        i += 1

    # create final annoucelists with new commandtoken
    v_announcelist.full = []
    device = 0
    new_command_number = v_cr_params.startnumber
    number_of_cr = 0
    # per device:
    while device < len(v_dev.announceline):
        # within a device; necessary for resolve inline token of rules:
        #  original token -> newtoken:
        original_token_list = []
        new_token_list = []
        # start with the number of the full list:
        temp_new_token = new_command_number
        # all announcelines:
        for announce in v_dev.announceline[device]:
            if announce[0] != "R" and announce[0] != "I" and announce[0] != "Q":
                new_token_list.append(temp_new_token)
                original_token_list.append(int(announce.split(";")[0]))
                # dictionary dev_token -> cr_token
                v_dev.dev_cr_tok[device][int(announce.split(";")[0])] = temp_new_token
                # cr_token -> dev_token
                v_dev.cr_dev_tok[device][temp_new_token] = int(announce.split(";")[0])
            temp_new_token += 1

        # commandnumber within device
        # all announcelines
        for announce in v_dev.announceline[device]:
            # but not for device 0 except basic line
            if device == 0 and announce[0] != "0":
                pass
            else:
                if device == 0 and announce[0] == "0":
                        # modify number of announcelines and length for CR basic line
                        tr = announce.split(";")
                        tr[5] = str(number_of_devices)
                        tr[6] = str(max_length_of_all_announcments)
                        tr[8] = str(number_of_all_announcements)
                        v_announcelist.full.append(";".join(tr))
                if announce[0] == "I":
                    v_announcelist.full.append(announce)
                elif announce[0] == "R":
                    # rules lines
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
                                            # new commandtoken found or error
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
                else:
                    # other announcelines: not R-lines, not I-lines
                    # original command for that token
                    items = announce.split(";")
                    item = items[1].split(",")
                    # originaltoken per cr token
                    original_command_token = int(items[0])
                    v_token_params.dev_token.append(original_command_token)
                    # device, that token should be send to
                    # basic commands are handled by CR (device 0)
                    if original_command_token == 0:
                        v_token_params.device.append(0)
                    else:
                        v_token_params.device.append(device)
                    # modify token for new announdelist: for device == 0 stored earlier
                    if device != 0:
                        # new command token
                        items[0] = str(new_command_number)
                        v_announcelist.full.append(";".join(items))
                        # startnumber stated with 1 (not basic line of CR)
                        new_command_number += 1
                        if item[0] == "c":
                            number_of_cr += 1
        device += 1
    # announcelist complete for command 0 and all devices except CR
    #
    # add cr_announcements create index_of_cr_commands directory
    cr_index = v_cr_params.number_of_commands_noCR
    for lines in v_dev.announceline[0]:
        # not basic line (is 1st line already):
        if lines[0] != "0":
            if lines[0] == "I" or lines[0] == "R" or lines[0] == "Q":
                pass
            else:
                tr = lines.split(";")
                v_token_params.device.append(0)
                v_token_params.dev_token.append(int(tr[0]))
                # directory token of full announcement list -> index in full list and reverse
                v_token_params.index_of_cr_commands[int(tr[0])]  = cr_index
                v_token_params.index_of_cr_commands_r[cr_index] = int(tr[0])
                cr_index += 1
            v_announcelist.full.append(lines)

    # update basic line
    item = v_announcelist.full[0].split(";")
    # number of commandbytes
    item[7] = str(v_cr_params.length_commandtoken)
    v_announcelist.full[0] = ";".join(item)

    # update ANNOUNCEMENT and BASIC ANNOUNCEMENT line
    i = 0
    for announce in v_announcelist.full:
        tr = announce.split(";")
        if len(tr) > 2:
            if len(tr[1].split(","))> 1:
                if tr[1].split(",")[1] == "ANNOUNCEMENTS":
                    tr[2] = str(max_length_of_all_announcments)
                    tr[3] = str(number_of_all_announcements)
                    v_announcelist.full[i] = ";".join(tr)
                if tr[1].split(",")[1] == "BASIC ANNOUNCEMENTS":
                    tr[2] = str(max_length_of_all_announcments)
                    tr[3] = str(number_of_devices)
                    v_announcelist.full[i] = ";".join(tr)
        i += 1

    # full announcelist ready now
    #
    # calculate v_linelength from full list
    v_linelength.command = []
    v_linelength.answer = []
    v_linelength.info = []
    # the index of the resulting linelength is the same as the index of the token of the full list
    tokennumber = 0
    for announce in v_announcelist.full:
        if announce[0] != "R" and announce[0] != "I" and announce[0] != "Q":
            items = announce.split(";")
            item = items[1].split(",")
            v_linelength.command.append([])
            v_linelength.answer.append([])
            v_linelength.info.append([])
            # create list of length of command, answer and info for this cr command
            commandtypes[item[0]](announce, tokennumber, v_token_params.device[tokennumber])
            tokennumber += 1

    tok = 0
    announcelines = 0
    for announce in v_announcelist.full:
        # for basic announcement command
        if announce[0] != "R" and announce[0] != "I" and announce[0] != "Q":
            v_token_params.announcements[tok] = announcelines
            tok += 1
        announcelines += 1

    # create list of basic announcements from full list
    v_announcelist.basic = []
    for announce in v_announcelist.full:
        item = announce.split(";")
        if len(item) > 1 and announce[0] != "I" and announce[0] != "R" and announce[0] != "Q":
            if item[1] == "m" or item[1] == "l" or item[1] == "r" or item[1] == "c" or item[1] == "h":
                v_announcelist.basic.append(announce)

    # create list of rules from full list
    v_announcelist.rules = []
    for announce in v_announcelist.full:
        if announce[0] == "R":
            v_announcelist.rules.append(announce)
    return


def resolve_bin_hex(announce):
    # not allowd in R ind I lines
    if announce[0] != "R" and announce[0] != "I" and announce[0] != "Q":
        item = announce.split(";")
        i = 0
        while i < len(item):
            temp = 0
            if len(item[i]) > 2:
                if item[i][2] == "h" or item[i][2] == "H":
                    try:
                        temp = int(item[i], 16)
                    except ValueError:
                        pass
                elif item[i][2] == "b" or item[i][2] == "B":
                    try:
                        temp = int(item[i], 2)
                    except ValueError:
                        pass
            if temp != 0:
                item[i] = str(temp)
            i += 1
        new_announce = ";".join(item)
    else:
        new_announce = announce
    return new_announce


# for ct_x see length_of_commandtypes.py
commandtypes = {"m": ct_m,
                "l": ct_m,
                "c": ct_m,
                "r": ct_m,
                "h": ct_m,
                "iy": ct_nc,
                "ia": ct_nc,
                "ib": ct_nc,
                "if": ct_nc,
                "im": ct_nc,
                "in": ct_nc,
                "io": ct_nc,
                "ip": ct_nc,
                "iq": ct_nc,
                "ir": ct_nc,
                "is": ct_nc,
                "it": ct_nc,
                "or": ct_or,
                "kr": ct_or,
                "rr": ct_or,
                "os": ct_os,
                "ks": ct_os,
                "rs": ct_os,
                "ot": ct_ot,
                "kt": ct_ot,
                "rt": ct_ot,
                "ou": ct_ou,
                "ku": ct_ou,
                "ru": ct_ou,
                "ar": ct_ar,
                "lr": ct_ar,
                "sr": ct_ar,
                "as": ct_as,
                "ls": ct_as,
                "ss": ct_as,
                "at": ct_as,
                "lt": ct_as,
                "st": ct_as,
                "au": ct_as,
                "lu": ct_as,
                "su": ct_as,
                "op": ct_op,
                "kp": ct_op,
                "rp": ct_op,
                "oo": ct_oo,
                "ko": ct_oo,
                "ro": ct_oo,
                "oq": ct_oq,
                "lq": ct_oq,
                "rq": ct_oq,
                "ap": ct_ap,
                "lp": ct_ap,
                "sp": ct_ap,
                "om": ct_om,
                "km": ct_om,
                "rm": ct_om,
                "on": ct_on,
                "kn": ct_on,
                "rn": ct_on,
                "of": ct_of,
                "kf": ct_of,
                "rf": ct_of,
                "oa": ct_oa,
                "ka": ct_oa,
                "ra": ct_oa,
                "ob": ct_ob,
                "kb": ct_ob,
                "rb": ct_ob,
                "am": ct_am,
                "lm": ct_am,
                "sm": ct_am,
                "an": ct_an,
                "ln": ct_an,
                "sn": ct_an,
                "af": ct_af,
                "lf": ct_af,
                "sf": ct_af,
                "aa": ct_aa,
                "sa": ct_aa,
                "la": ct_aa,
                "ab": ct_ab,
                "lb": ct_ab,
                "sb": ct_ab
                }

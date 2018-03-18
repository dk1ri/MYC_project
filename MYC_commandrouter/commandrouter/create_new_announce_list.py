""""
name : create_new_announce_list.py
last edited: 201802
new announcelist is created or modified and some associated lists and parameters
"""

from length_of_commandtypes import *
from cr_own_commands import  *
import misc_functions
import v_announcelist
import v_cr_params
import v_dev
import v_token_params
import v_linelength


def create_new_announce_list():
    # count number of all announcements and some other values for full list
    v_cr_params.length_of_announcement_length = 0
    v_cr_params.number_of_commands = 0
    v_cr_params.number_of_commands_noCR = 0
    number_of_devices = 0
    # all devices, CR inclusive
    # v_dev.announceline[i] have xxF0 xxFE, xxFF, k and l lines dropped except for CR

    # collect some figures (per device)
    while number_of_devices < len(v_dev.announceline):
        # for each device
        for announce in v_dev.announceline[number_of_devices]:
            # all lines of the device
            if len(announce) > v_cr_params.length_of_announcement_length:
                v_cr_params.length_of_announcement_length = len(announce)
            if announce[0] != "R" and announce[0] != "I" and announce[0] != "Q":
                # used to calculate length_commandtoken -> omit device 0 (CR)
                v_cr_params.number_of_commands += 1
        number_of_devices += 1

    # only basic line of CR
    v_cr_params.number_of_commands_noCR = v_cr_params.number_of_commands - 1

    # commandtokens are without gaps: this is the highest number of a token
    # leave gaps for 16 reserved commands of SK at the end
    # calculates length and start_number
    misc_functions.calculate_length_of_commandtoken(v_cr_params.number_of_commands)

    # create final annoucelists with new commandtoken
    fulllist = []
    v_announcelist.full = []
    device = 0
    new_command_number = v_cr_params.startnumber
    number_of_cr = 0

    # per device:
    while device < len(v_dev.announceline):
        if device == 0:
            fulllist.append(v_dev.announceline[0][0])
            device += 1
            number_of_cr = 1
            v_token_params.device.append(0)
            v_token_params.dev_token.append(0)
            v_token_params.token_number.append(0)
            continue

        #  original token -> newtoken:
        original_token_list = []
        new_token_list = []
        # start with the number of the full list:
        temp_new_token = new_command_number

        # all announcelines, some tables (not CR)
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
        # all announcelines (CR already done)
        for announce in v_dev.announceline[device]:
            if announce[0] == "I":
                fulllist.append(announce)
            elif announce[0] == "R":
                # modify commandtoken for rules lines
                # rules are at the end; so token should be known
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
                fulllist.append(announce)
            else:
                # other announcelines: not R-lines, not I-lines
                items = announce.split(";")
                item = items[1].split(",")

                # originaltoken per cr command
                original_command_token = int(items[0])
                v_token_params.dev_token.append(original_command_token)

                # original device per CR command
                if announce[0] == "0":
                    # basic announcement will be answered by CR
                    v_token_params.device.append(0)
                else:
                    v_token_params.device.append(device)

                # tokennumber per CR command
                v_token_params.token_number.append(int(items[0]))

                # modify token for new announdelist
                items[0] = str(new_command_number)
                fulllist.append(";".join(items))
                # startnumber stated with 1 (not basic line of CR)
                new_command_number += 1
                if item[0] == "c":
                    number_of_cr += 1
        device += 1
    # announcelist complete for devices except CR
    #
    #calculate adder (for CR commands, length_commandtoken and start_of_reserved_token
    number_of_commands = 0
    for lines in fulllist:
        if lines[0] == "I" or lines[0] == "R" or lines[0] == "Q":
            pass
        else:
            number_of_commands += 1
    i = 256
    v_cr_params.adder = 0
    v_cr_params.length_commandtoken = 1
    v_cr_params.start_of_reserved_token = v_cr_params.length_commandtoken * 256 - 16
    while number_of_commands >= i - 16:
        i *= 256
        v_cr_params.adder = i - 256
        v_cr_params.length_commandtoken += 1
        v_cr_params.start_of_reserved_token = i - 16

    # add cr_announcements create index_of_cr_commands directory
    # create list: actual_cr_own_commands (token)
    cr_index = v_cr_params.number_of_commands_noCR + 1
    for lines in v_cr_params.cr_announcement:
        if lines[0] == "I" or lines[0] == "R" or lines[0] == "Q":
            pass
        else:
            tr = lines.split(";")
            v_token_params.device.append(0)
            v_token_params.dev_token.append(int(tr[0]))
            v_token_params.token_number.append(int(tr[0]))
            # directory token of full announcement list -> index in full list and reverse
            v_token_params.index_of_cr_commands[int(tr[0])]  = cr_index
            v_token_params.index_of_cr_commands_r[cr_index] = int(tr[0])
            # for multi-byte commandtoken
            tr[0] = str(int(tr[0]) + v_cr_params.adder)
            cr_index += 1
            # create v_cr_params.actual_cr_own_command
            try:
                v_cr_params.actual_cr_own_command.append(cr_own_command[int(tr[0])])
            except KeyError:
                pass
            # 251 parameters
            if tr[0] == "251":
                v_cr_params.c_251_name_length = int(tr[3].split(",")[0])
                v_cr_params.c_251_password_length = int((tr[4].split(",")[0]))

        fulllist.append(lines)

    # update CR basic line
    item = fulllist[0].split(";")
    item[5] = str(number_of_devices)
    item[6] = str(v_cr_params.length_of_announcement_length)
    item[8] = str(len(fulllist))
    # number of commandbytes
    item[7] = str(v_cr_params.length_commandtoken)
    fulllist[0] = ";".join(item)

    # update CR ANNOUNCEMENT line
    i = 0
    for announce in fulllist:
        tr = announce.split(";")
        if len(tr) > 2:
            if len(tr[1].split(","))> 1:
                if tr[1].split(",")[1] == "ANNOUNCEMENTS":
                    tr[2] = str(v_cr_params.length_of_announcement_length)
                    tr[3] = str(len(fulllist))
                    fulllist[i] = ";".join(tr)
                if tr[1].split(",")[1] == "BASIC ANNOUNCEMENTS":
                    tr[2] = str(v_cr_params.length_of_announcement_length)
                    tr[3] = str(number_of_devices)
                    fulllist[i] = ";".join(tr)
        i += 1

    # full announcelist ready now
    #
    # calculate v_linelength from fulllist and copy valid lines to v_announcelist.full
    v_linelength.command = []
    v_linelength.answer = []
    v_linelength.info = []
    # the index of the resulting linelength is the same as the index of the token of the full list
    line_number = 0
    tok = 0
    for announce in fulllist:
        if announce[0] != "R" and announce[0] != "I" and announce[0] != "Q":
            items = announce.split(";")
            item = items[1].split(",")

            # fill 2 lists of length of command, answer / info for this command
            # there is no error (erraneous lines ignored earlier)
            temp_c = []
            temp_a = []
            device = v_token_params.device[tok]
            temp_command, temp_answer = commandtypes[item[0]](announce, temp_c, temp_a ,v_dev.length_commandtoken[device])
            v_linelength.command.append(temp_command)
            v_linelength.answer.append(temp_answer)
            tok += 1
        v_announcelist.full.append(fulllist[line_number])
        line_number += 1

    tok = 0
    v_announcelist.full_elements = 0
    v_cr_params.c_249_elements = 0
    for announce in v_announcelist.full:
        # for basic announcement command
        if announce[0] != "R" and announce[0] != "I" and announce[0] != "Q":
            v_token_params.announcements[tok] = v_announcelist.full_elements
            tok += 1
            if announce[1].split(";")[0] == "m" or announce[1].split(";")[0] == "c":
                v_cr_params.c_249_elements += 1
        v_announcelist.full_elements += 1
    v_announcelist.length_of_ful_elements = length_of_int(v_announcelist.full_elements)
    v_announcelist.length_of_basic = 0
    # for 249 command
    v_cr_params.c_249_elements *= v_cr_params.length_commandtoken
    v_cr_params.length_of_c_249_elements = length_of_int(v_cr_params.c_249_elements)

    # create list of basic announcements from full list
    v_announcelist.basic = []
    v_announcelist.basic_elements = 0
    for announce in v_announcelist.full:
        item = announce.split(";")
        if len(item) > 1 and announce[0] != "I" and announce[0] != "R" and announce[0] != "Q":
            item1 = item[1].split(",")[0]
            if item1 == "m" or item1 == "l" or item1 == "r" or item1 == "c" or item1 == "h":
                v_announcelist.basic.append(announce)
                v_announcelist.basic_elements += 1
    v_announcelist.length_of_basic_elements = length_of_int(v_announcelist.basic_elements)

    # modify 249 command
    index = 0
    for announce in v_announcelist.full:
        tr = announce.split(";")
        if len(tr) > 1:
            item = tr[1].split(",")
            if len(item) > 1 and item[1] == "SK-FEATURE":
                while i < len(tr):
                    item = tr[i].split(",")
                    if len(item) > 1:
                        if item[1] == "ANSWER":
                            tr[i] = str(v_cr_params.c_249_elements) + ",ANSWER"
                v_announcelist.full[index] = ";".join(tr)
        index += 1



    # create list of rules from full list
    v_announcelist.rules = []
    v_announcelist.rules_elements = 0
    for announce in v_announcelist.full:
        if announce[0] == "R":
            v_announcelist.rules.append(announce)
            v_announcelist.rules_elements += 1
    v_announcelist.length_of_rules_elements= length_of_int(v_announcelist.rules_elements)
    return


# for ct_x see length_of_commandtypes.py
commandtypes = {"m": ct_m,
                "l": ct_m,
                "c": ct_m,
                "r": ct_m,
                "h": ct_m,
                "s": ct_m,
                "iz": ct_nc,
                "ir": ct_nc,
                "or": ct_or,
                "kr": ct_or,
                "rr": ct_or,
                "ar": ct_ar,
                "lr": ct_ar,
                "sr": ct_ar,
                "is": ct_nc,
                "os": ct_os,
                "ks": ct_os,
                "rs": ct_os,
                "as": ct_as,
                "ls": ct_as,
                "ss": ct_as,
                "it": ct_nc,
                "ot": ct_ot,
                "kt": ct_ot,
                "rt": ct_ot,
                "at": ct_as,
                "lt": ct_as,
                "st": ct_as,
                "iu": ct_nc,
                "ou": ct_os,
                "ku": ct_os,
                "ru": ct_os,
                "au": ct_as,
                "lu": ct_as,
                "su": ct_as,
                "ip": ct_nc,
                "op": ct_op,
                "kp": ct_op,
                "rp": ct_op,
                "ap": ct_ap,
                "lp": ct_ap,
                "sp": ct_ap,
                "io": ct_nc,
                "oo": ct_oo,
                "ko": ct_oo,
                "ro": ct_oo,
                "im": ct_nc,
                "om": ct_om,
                "km": ct_om,
                "rm": ct_om,
                "am": ct_am,
                "lm": ct_am,
                "sm": ct_am,
                "in": ct_nc,
                "on": ct_on,
                "kn": ct_on,
                "rn": ct_on,
                "an": ct_an,
                "ln": ct_an,
                "sn": ct_an,
                "if": ct_nc,
                "of": ct_of,
                "kf": ct_of,
                "rf": ct_of,
                "af": ct_af,
                "lf": ct_af,
                "sf": ct_af,
                "ia": ct_nc,
                "oa": ct_oa,
                "ka": ct_oa,
                "ra": ct_oa,
                "aa": ct_aa,
                "sa": ct_aa,
                "la": ct_aa,
                "ib": ct_nc,
                "ob": ct_ob,
                "kb": ct_ob,
                "rb": ct_ob,
                "ab": ct_ab,
                "sb": ct_ab,
                "lb": ct_ab,
                }

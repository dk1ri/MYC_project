""""
name : create_new_announce_list.py
last edited: 202512
new announcelist is created or modified and some associated lists and parameters
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""
import misc_functions
from length_of_commandtypes import *
from cr_own_commands import  *
import v_announcelist
import v_cr_params
import v_dev
import v_token_params
import v_linelength
import v_logicdevice


def create_new_announce_list():
    # count number of all announcements
    v_cr_params.length_of_announcement_length = 0
    device_number = 0
    v_announcelist.full_elements = 0
    v_announcelist.full_elements_240 = 0
    v_announcelist.basic_elements = 0
    v_announcelist.rules_elements = 0
    v_announcelist.admin_elements = 0
    number_of_devices =  len(v_dev.announcements)
    while device_number < number_of_devices:
        # for each device
        for announce in v_dev.announcements[device_number]:
            # all lines of the device
            if announce.find("ADMINISTRATION") >= 0:
                # admin: to admin list
                v_announcelist.admin_elements += 1
            if announce[0] in v_configparameter.other_lines:
                # rules: to rules list
                v_announcelist.rules_elements += 1
            if len(announce.split(";")) > 1:
                ct = announce.split(";")[1].split(",")
                if ct[0] == "m" or ct[0] == "c":
                    # basic: to basic, full and full:240 list
                    v_announcelist.basic_elements += 1
            if announce.find("ADMINISTRATION") == -1:
                # other commands, all with tok + rules, not administration
                v_announcelist.full_elements_240 += 1
            if announce[0] in v_configparameter.other_lines:
                continue
            else:
                # other commands, all with tok
                v_announcelist.full_elements += 1
                # used to calculate length_cr_token
        device_number += 1
    # 5 additional elemnts follow at the end (they do not vhange the length)
    v_announcelist.full_elements += 5
    v_announcelist.full_elements_240 += 5
    # 3 byte of commands maximum (16711665)
    if v_announcelist.full_elements <= 0xF0:
        v_announcelist.length_of_full_elements = 1
        v_announcelist.start_of_reserved_token = 0xf0
        v_announcelist.start_of_cr_token = 0x01
    elif v_announcelist.full_elements <= 0xFFF0:
        v_announcelist.length_of_full_elements = 2
        v_announcelist.start_of_reserved_token = 0xfff0
        v_announcelist.start_of_cr_token = 0x0100
    else:
        #3 byte
        v_announcelist.length_of_full_elements = 3
        v_announcelist.start_of_reserved_token = 0xfffff0
        v_announcelist.start_of_cr_token = 0x010000

    # device 0 is local CR
    v_token_params.dev_token[0] = 0
    v_token_params.cr_token.append({})
    v_token_params.cr_token[0] = {0}
    v_token_params.device[0] = 0

    # announce 0 (CR)
    cr_announce = v_configparameter.announceline_0_CR
    item = cr_announce.split(";")
    item[5] = str(number_of_devices)
    # number of commandbytes
    item[7] = str(v_announcelist.length_of_full_elements)
    # number of all announcements
    item[8] = str(v_announcelist.full_elements_240)
    v_announcelist.basic.append(";".join(item))
    v_announcelist.full[0]= ";".join(item)
    v_announcelist.full_240.append(";".join(item))
    v_announcelist.all_token.append(0)

    # create translate lists: v_token_params.dev_token v_token_params.cr_token and v_token_params.device
    device_number = 1
    new_command_number = v_announcelist.start_of_cr_token
    while device_number < number_of_devices:
        v_token_params.cr_token.append([])
        v_token_params.cr_token[device_number] = {}
        for announce in v_dev.announcements[device_number]:
            tok = announce[0]
            if announce[0] in v_configparameter.other_lines:
                continue
            tok = int(announce.split(";")[0])
            v_token_params.dev_token[new_command_number] = tok
            v_token_params.cr_token[device_number][tok] = new_command_number
            v_token_params.device[new_command_number] = device_number
            new_command_number += 1
        device_number += 1
    # create admin announcelist with new commandtoken
    v_announcelist.administration = []
    device_number = 1
    while device_number < number_of_devices:
        for announce in v_dev.announcements[device_number]:
            if announce.find("ADMINISTRATION") != -1:
                items = announce.split(";")
                items[0] = str(v_token_params.cr_token[device_number][int(items[0])])
                v_announcelist.administration.append(";".join(items))
                v_announcelist.admin_elements += 1
        device_number += 1

    # create rules announcelist with new commandtoken
    v_announcelist.rules = []
    device_number = 1
    while device_number < number_of_devices:
        for announce in v_dev.announcements[device_number]:
            if announce[0] == "R" or announce[0] == "Q" or announce[0] == "S":
                #
                # commandnumbers follow "$" only
                items = announce.split("$")
                ij = 0
                # one $xx command:
                for item in items:
                    if ij == 0:
                        # chars before 1st "$"
                        ij += 1
                        continue
                    number = ""
                    # search for complete number not finished
                    finished = 0
                    ik = 0
                    while ik < len(item):
                        if finished  == 0:
                            # number follows $
                            if item[ik] != "~":
                                if item[ik] == " " or item[ik] in v_logicdevice.all_operators:

                                    # number finished, search new token
                                    if number != "~":
                                        new_item = str(v_token_params.cr_token[device_number][int(number)])
                                        # modified field
                                        new_item = new_item + item[ik:]
                                        items[ij] = new_item
                                    finished = 1
                                else:
                                    number = number + item[ik]
                            else:
                                finished = 1
                        ik += 1
                    ij += 1
                announce = "$".join(items)
                v_announcelist.rules.extend([announce])
                v_announcelist.rules_elements += 1
        device_number += 1

    # create basic announcelist with new commandtoken
    device_number = 1
    while device_number < number_of_devices:
        for announce in v_dev.announcements[device_number]:
            if announce[0] in v_configparameter.other_lines:
                continue
            items = announce.split(";")
            if items[1].split(",")[0] == "m" or items[1].split(";")[0] == "c":
                items[0] = str(v_token_params.cr_token[device_number][int(items[0])])
                v_announcelist.basic.append(";".join(items))
                v_announcelist.basic_elements += 1
        device_number += 1

    # create full announcelist with new commandtoken (all with tok)
    device_number = 1
    while device_number < number_of_devices:
        for announce in v_dev.announcements[device_number]:
            if announce[0] in v_configparameter.other_lines:
                continue
            items = announce.split(";")
            items[0] = str(v_token_params.cr_token[device_number][int(items[0])])
            line = misc_functions.strip_des_chapter(";".join(items))
            v_announcelist.full_elements += 1
            v_announcelist.full[int(items[0])] = line
            v_announcelist.full_elements += 1
            v_announcelist.all_token.append(int(items[0]))
        device_number += 1

    # create full_240 announcelist with new commandtoken (all with tok, no ADMINISTRATION
    # + rules at the end added later
    device_number = 1
    while device_number < number_of_devices:
        for announce in v_dev.announcements[device_number]:
            if announce[0] in v_configparameter.other_lines:
                continue
            if announce.find("ADMINISTRATION") > -1:
                continue
            items = announce.split(";")
            items[0] = str(v_token_params.cr_token[device_number][int(items[0])])
            v_announcelist.full_240.append(";".join(items))
            v_announcelist.full_elements_240 += 1
        device_number += 1

    # add 240
    items = v_configparameter.announceline_240_CR.split(";")
    items[0] = str(v_announcelist.start_of_reserved_token)
    items[3] = str(v_announcelist.full_elements)
    items[4] = str(v_announcelist.full_elements)
    line = misc_functions.strip_des_chapter(";".join(items))
    v_announcelist.full[240] = line
    v_announcelist.full_240.append(";".join(items))
    v_announcelist.all_token.append(240)

    # add 254
    items = v_configparameter.announceline_254_CR.split(";")
    items[0] = str(v_announcelist.start_of_reserved_token + 14)
    line = misc_functions.strip_des_chapter(";".join(items))
    v_announcelist.full[254] = line
    v_announcelist.all_token.append(254)

    # add 255
    items = v_configparameter.announceline_255_CR.split(";")
    items[0] = str(v_announcelist.start_of_reserved_token + 15)
    line = misc_functions.strip_des_chapter(";".join(items))
    v_announcelist.full[255] = line
    v_announcelist.full_240.append(";".join(items))
    v_announcelist.all_token.append(255)

    # rules at the end of full_240
    for announce in v_announcelist.rules:
            v_announcelist.full_240.append(announce)

    # full announcelist complete now

    # fill 2 lists of length of command, answer / info for this command
    # there is no error (erraneous lines ignored earlier)
    for tok in v_announcelist.all_token:
        if tok == 0:
            continue
        ct = v_announcelist.full[tok][1]
        v_linelength.command[tok], v_linelength.answer[tok] = commandtypes[ct](v_announcelist.full[tok])

    # CR tooks for a_to_o and o_to_a
    device_number = 1
    while device_number < number_of_devices:
        if (v_dev.o_to_a[device_number])!= {}:
            toks = v_dev.o_to_a[device_number]
            for tok in toks:
                try:
                    a_token = v_token_params.cr_token[device_number][int(v_dev.o_to_a[device_number][tok])]
                    o_token = v_token_params.cr_token[device_number][int(tok)]
                    v_announcelist.o_to_a[o_token] = a_token
                    v_announcelist.a_to_o[a_token] = o_token
                except:
                    pass
        device_number += 1
    while device_number < number_of_devices:
        for tok in v_dev.all_toks:
            try:
                v_announcelist.a_to_o[v_token_params.cr_token[device_number][tok]] = v_dev.a_to_o[tok]
            except:
                pass
        device_number += 1
    return

# for ct_x see length_of_commandtypes.py
commandtypes = {"m": ct_m,
                "l": ct_m,
                "c": ct_m,
                "r": ct_m,
                "h": ct_m,
                "s": ct_m,
                "ir": ct_nc,
                "jr": ct_nc,
                "zr": ct_nc,
                "or": ct_or,
                "rr": ct_or,
                "ar": ct_ar,
                "sr": ct_ar,
                "is": ct_nc,
                "js": ct_nc,
                "zs": ct_nc,
                "os": ct_os,
                "rs": ct_os,
                "as": ct_as,
                "ss": ct_as,
                "it": ct_nc,
                "jt": ct_nc,
                "zt": ct_nc,
                # "ot": ct_ot, answer only
                # "rt": ct_ot, answer only
                "at": ct_at,
                "st": ct_at,
                "iu": ct_nc,
                "ju": ct_nc,
                "zu": ct_nc,
                "ou": ct_ou,
                "ru": ct_ou,
                # "su": ct_as, operate only
                "ip": ct_nc,
                "jp": ct_nc,
                "zp": ct_nc,
                "op": ct_op,
                "rp": ct_op,
                "ap": ct_ap,
                "sp": ct_ap,
                "io": ct_nc,
                "jo": ct_nc,
                "zo": ct_nc,
                "oo": ct_oo,
                "ro": ct_oo,
                "im": ct_nc,
                "jm": ct_nc,
                "zm": ct_nc,
                "om": ct_om,
                "rm": ct_om,
                "am": ct_am,
                "sm": ct_am,
                "in": ct_nc,
                "ij": ct_nc,
                "zn": ct_nc,
                "on": ct_on,
                "rn": ct_on,
                "an": ct_an,
                "sn": ct_an,
                "if": ct_nc,
                "jf": ct_nc,
                "zf": ct_nc,
                "of": ct_of,
                "rf": ct_of,
                "af": ct_af,
                "sf": ct_af,
                "ia": ct_nc,
                "ja": ct_nc,
                "za": ct_nc,
                "oa": ct_oa,
                "ra": ct_oa,
                "aa": ct_aa,
                "sa": ct_aa,
                "ib": ct_nc,
                "jb": ct_nc,
                "zb": ct_nc,
                "ob": ct_ob,
                "rb": ct_ob,
                "ab": ct_ab,
                "sb": ct_ab,
                }

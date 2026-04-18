""""
name : create_new_announce_list.py
last edited: 20260414
new announcelist is created or modified and some associated lists and parameters
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""
from length_of_commandtypes import *
from misc_functions import *
import v_announcelist
import v_cr_params
import v_dev
import v_token_params
import v_linelength
import v_configparameter

def create_new_announce_list():
    # count number of all announcements
    v_cr_params.length_of_announcement_length = 0
    device_number = 1
    v_announcelist.full_elements = 0
    v_announcelist.full_elements_240 = 0
    v_announcelist.basic_elements = 0
    v_announcelist.rules_elements = 0
    v_announcelist.admin_elements = 0
    number_of_devices =  len(v_dev.announcements)

    while device_number < number_of_devices:
        # for each device
        v_announcelist.rules_elements += len(v_dev.rules[device_number])
        v_announcelist.full_elements += len(v_dev.announcements[device_number])
        v_announcelist.other_lines_elements += len(v_dev.other_lines[device_number])
        for announce in v_dev.announcements[device_number]:
            i = 0
            while i < len(announce):
                if announce[i].find("ADMINISTRATION") >= 0:
                    # admin: to admin list
                    # other commands, all with tok
                    v_announcelist.admin_elements += 1
                else:
                    v_announcelist.full_elements_240 += 1
                i += 1
        device_number += 1

    # add number of other_lines to full (this defines the length of tok
    v_announcelist.full_elements += v_announcelist.rules_elements
    v_announcelist.full_elements += v_announcelist.other_lines_elements

    # 3 byte of commands maximum (16711665)
    if v_announcelist.full_elements <= 0xF0:
        v_announcelist.length_of_full_elements = 1
        v_announcelist.start_of_reserved_token = 0xf0
        v_announcelist.start_of_cr_token  = 0x01
    elif v_announcelist.full_elements <= 0xFFF0:
        v_announcelist.length_of_full_elements = 2
        v_announcelist.start_of_reserved_token = 0xfff0
        v_announcelist.start_of_cr_token = 0x0100
    else:
        #3 byte
        v_announcelist.length_of_full_elements = 3
        v_announcelist.start_of_reserved_token = 0xfffff0
        v_announcelist.start_of_cr_token = 0x010000

    # 5 additional elements follow at the end (they do not change the length)
    v_announcelist.full_elements += 5
    v_announcelist.full_elements_240 += 5

    # device 0 is local CR
    v_token_params.dev_token[0] = 0
    v_token_params.cr_token.append({})
    v_token_params.cr_token[0] = {}
    v_token_params.cr_token[0][0] = 0
    v_token_params.device[0] = 0

    # announce 0 (CR)
    cr_announce = v_configparameter.cr0_announcements[0]
    item = cr_announce.split(";")
    item[5] = str(number_of_devices)
    # number of commandbytes
    item[7] = str(v_announcelist.length_of_full_elements)
    # number of all announcements
    item[8] = str(v_announcelist.full_elements_240)
    v_announcelist.full[0] = item
    line = ";".join(item)
    # full line
    v_announcelist.basic[0] = bytearray([])
    v_announcelist.basic[0].extend(tok_to_bytes(len(line), 1))
    v_announcelist.basic[0].extend(bytes(map(ord, line)))
    v_announcelist.full_240.append(bytearray())
    v_announcelist.full_240[0].extend(tok_to_bytes(len(line), 1))
    v_announcelist.full_240[0].extend(bytes(map(ord, line)))
    v_announcelist.all_token.append(0)
    # create translate lists: v_token_params.dev_token v_token_params.cr_token and v_token_params.device
    device_number = 1
    new_command_number = v_announcelist.start_of_cr_token
    while device_number < number_of_devices:
        v_token_params.cr_token.append([])
        v_token_params.cr_token[device_number] = {}
        for tok in v_dev.announcements[device_number]:
            v_token_params.dev_token[new_command_number] = int(tok)
            v_token_params.cr_token[device_number][int(tok)] = new_command_number
            v_token_params.device[new_command_number] = device_number
            new_command_number += 1
        device_number += 1
    # create admin announcelist with new commandtoken
    v_announcelist.administration = []
    device_number = 1
    while device_number < number_of_devices:
        for announce in v_dev.announcements[device_number]:
            i = 0
            while i < len(announce):
                if announce[i].find("ADMINISTRATION") != -1:
                    announce[0] = str(v_token_params.cr_token[device_number][int(announce[0])])
                    v_announcelist.administration[v_announcelist.admin_elements] = ";".join(announce)
                    v_announcelist.admin_elements += 1
                i += 1
        device_number += 1

    # create rules announcelist with new commandtoken, add !!$~ if necessary
    # v_announcelist.rules is used by 240 command and by LD
    # other changes made with ld_init
    device_number = 1
    i = 0
    while device_number < number_of_devices:
        found_tilde = 0
        for announce in v_dev.rules[device_number]:
            left, right, typ = split_rule(announce)
            # left side (array !)
            m = 0
            multi = 0
            while m < len(left):
                if "!~" in left[m]:
                    found_tilde = 1
                elif "!!~" in left[m]:
                    found_tilde = 0
                elif "!" in left[m]:
                    # normal commands start with "!$"
                    number = left[m][1:]
                    left[m] = "!" + str(v_token_params.cr_token[device_number][int(number)])
                else:
                    # direct commands or direct blocking command
                    left[m] = left[m]
                if multi == 0:
                    # right side, calculate once only
                    right_space = right.split(" ")
                    condition = 0
                    new_right = []
                    # right_space: <tok><campare><value>
                    # modify tok
                    while condition < len(right_space):
                        if right_space[condition] in v_ld.condition_operators:
                            new_right.append(right_space[condition])
                        else:
                            org_tok = ""
                            if right_space[condition] != "":
                                # first character must be numeric (tok as first characters)
                                if right_space[condition][0].isnumeric():
                                    j = 0
                                    fin = 0
                                    while j < len(right_space[condition]) and fin == 0:
                                        if right_space[condition][j].isnumeric():
                                            org_tok += right_space[condition][j]
                                        else:
                                            new_tok = str(v_token_params.cr_token[device_number][int(org_tok)])
                                            new_right.append(new_tok + right_space[condition][j:])
                                            fin = 1
                                        j += 1
                        condition += 1
                    right = " ".join(new_right)
                    multi += 1
                v_announcelist.rules.append(left[m] +" " + typ + " " + right)
                v_announcelist.rules_elements += 1
                m += 1
        if found_tilde == 1:
            # stop all block with
            v_announcelist.rules.append("!!~ IF ~")
            v_announcelist.rules_elements += 1
            i += 1
        device_number += 1
    # create basic announcelist with new commandtoken
    device_number = 1
    while device_number < number_of_devices:
        v_announcelist.basic_elements = 1
        for tok in v_dev.announcements[device_number]:
            announce = v_dev.announcements[device_number][tok]
            ann_0 = announce[1]
            if ann_0 == "m" or ann_0 == "c" or ann_0 == "r" or ann_0 == "l" or ann_0 == "h":
                cr_tok = v_token_params.cr_token[device_number][int(announce[0])]
                line = str(cr_tok) + ";"
                line += ";".join(announce[1:])
                v_announcelist.basic[cr_tok] = bytearray()
                v_announcelist.basic[cr_tok].extend(tok_to_bytes(len(line),1))
                v_announcelist.basic[cr_tok].extend(bytes(map(ord, line)))
                v_announcelist.basic_elements += 1
                v_announcelist.basic_token.append(announce[0])
                v_announcelist.cr_token.append(cr_tok)
        device_number += 1

    # create oo_ext list, max_oo list and LOOP_LIMIT list
    device_number = 1
    while device_number < number_of_devices:
        for tok in v_dev.announcements[device_number]:
            announce = v_dev.announcements[device_number][tok]
            ct = announce[1].split(",")
            if ct[0] != "oo":
                continue
            oo_tok = announce[0]
            oo_tok = v_token_params.cr_token[device_number][int(oo_tok)]
            if len(ct) > 1:
                if ct[1][:3] == "ext":
                    op_tok_org = ct[1][3:]
                    if int(op_tok_org) in v_token_params.cr_token[device_number]:
                        # oo_tok -> op_tok
                        v_announcelist.oo_ext[oo_tok] = v_token_params.cr_token[device_number][int(op_tok_org)]

                        # max allowed  from op tok list
                        op_line_org = v_dev.announcements[device_number][int(op_tok_org)]
                        if oo_tok not in v_announcelist.max_oo:
                            v_announcelist.max_oo[oo_tok] = {}
                        if oo_tok not in v_announcelist.loop_limit:
                            v_announcelist.loop_limit[oo_tok] = {}
                        j = 3
                        i = 0
                        while j < len(op_line_org):
                            v_announcelist.max_oo[oo_tok][i] = int(op_line_org[j].split(",")[0])
                            i += 1
                            j += 3
                        j = 7
                        i = 0
                        # LOOP or LIMIT from oo announcement
                        while j < len(announce):
                            if announce[j] == "4,LOOP":
                                v_announcelist.loop_limit[oo_tok][i] = 0
                            else:
                                v_announcelist.loop_limit[oo_tok][i] = 1
                            i += 1
                            j += 6
        device_number += 1

    # device for cr_tok
    # dev_tok for cr_tok
    # ignore CR device
    device_number = 1
    while device_number < number_of_devices:
        for tok in v_dev.announcements[device_number]:
            lines = v_dev.announcements[device_number][tok]
            dev_tok = int(lines[0])
            cr_tok = v_token_params.cr_token[device_number][dev_tok]
            v_dev.device_by_cr_tok[cr_tok] = device_number
            v_dev.dev_tok_by_cr_tok[cr_tok] = dev_tok

        device_number += 1

    # v_linelength.answer: length of answer / info for this command
    # CR
    v_linelength.answer = {}
    v_linelength.answer[0] = {}
    v_linelength.answer[0][0] = [0,1]
    devices = 1
    while devices < len(v_dev.announcements):
        v_linelength.answer[devices] = {}
        for tok in v_dev.announcements[devices]:
            line = v_dev.announcements[devices][tok]
            ct = line[1].split(",")[0]
            v_linelength.answer[devices][int(line[0])] = commandtypes[ct](line, 1, devices)
        devices += 1

    # create full announcelist with new commandtoken (all with tok)
    # create full_240 announcelist with new commandtoken (all with tok, no ADMINISTRATION
    # + rules + otherlines at the end added later
    device_number = 1
    index = 1
    while device_number < number_of_devices:
        for tok in v_dev.announcements[device_number]:
            announce = v_dev.announcements[device_number][tok]
            cr_tok = str(v_token_params.cr_token[device_number][int(announce[0])])
            announce[0] = cr_tok
            line = announce
            v_announcelist.full[int(announce[0])] = line
            v_announcelist.all_token.append(int(cr_tok))
            i = 0
            found = 0
            while i < len(announce) and found == 0:
                if announce[i].find("ADMINISTRATION") > -1:
                    found = 1
                i += 1
            if found == 0:
                # tok
                v_announcelist.full_240.append(bytearray())
                v_announcelist.full_240[index].extend(v_dev.announcments_not_stripped[device_number][tok])
                v_announcelist.full_elements_240 += 1
                index += 1
        device_number += 1
    # add 240
    act_tok = v_announcelist.start_of_reserved_token
    items = v_configparameter.cr0_announcements[1].split(";")
    items[0] = str(act_tok)
    items[3] = str(v_announcelist.full_elements)
    items[4] = str(v_announcelist.full_elements)
    v_announcelist.full[act_tok] = items
    line = (";".join(items))
    v_announcelist.full_240.append([hex(len(line)), bytes(map(ord, line))])
    v_announcelist.all_token.append(act_tok)
    v_announcelist.cr_token.append(act_tok)

    # add 241
    act_tok = v_announcelist.start_of_reserved_token + 1
    items = v_configparameter.cr0_announcements[2].split(";")
    items[0] = str(act_tok)
    items[3] = str(v_announcelist.basic_elements)
    items[4] = str(v_announcelist.basic_elements)
    v_announcelist.full[act_tok] = items
    line = (";".join(items))
    v_announcelist.full_240.append([hex(len(line)), bytes(map(ord, line))])
    v_announcelist.all_token.append(act_tok)
    v_announcelist.cr_token.append(act_tok)

    # add 252
    act_tok = v_announcelist.start_of_reserved_token + 12
    items = v_configparameter.cr0_announcements[3].split(";")
    items[0] = str(act_tok)
    v_announcelist.full[act_tok] = items
    line = (";".join(items))
    v_announcelist.full_240.append([hex(len(line)), bytes(map(ord, line))])
    v_announcelist.all_token.append(act_tok)
    v_announcelist.cr_token.append(act_tok)

    # add 253
    act_tok = v_announcelist.start_of_reserved_token + 13
    items = v_configparameter.cr0_announcements[4].split(";")
    items[0] = str(act_tok)
    v_announcelist.full[act_tok] = items
    line = (";".join(items))
    v_announcelist.full_240.append([hex(len(line)), bytes(map(ord, line))])
    v_announcelist.all_token.append(act_tok)
    v_announcelist.cr_token.append(act_tok)

    # add 255
    act_tok = v_announcelist.start_of_reserved_token + 15
    items = v_configparameter.cr0_announcements[5].split(";")
    items[0] = str(act_tok)
    v_announcelist.full[act_tok] = items
    line = (";".join(items))
    v_announcelist.full_240.append([hex(len(line)), bytes(map(ord, line))])
    v_announcelist.all_token.append(act_tok)
    v_announcelist.cr_token.append(act_tok)

    # add rules
    for announce in v_announcelist.rules:
        v_announcelist.full_240.append("R;" + announce)

    # add otherlines
    for device in v_dev.other_lines:
        # otherlines the end of full_240
        for announce in v_dev.other_lines[device]:
            v_announcelist.full_240.append(announce)
    # full announcelist complete now

    # v_linelength.command:
    for cr_tok in v_announcelist.full:
        ct = v_announcelist.full[cr_tok][1].split(",")[0]
        v_linelength.command[int(cr_tok)] = commandtypes[ct](v_announcelist.full[cr_tok], 0, 0)

        # some ld lists
        rules_index = 0
        device_number = 1
        while device_number < number_of_devices:
            for lines in v_dev.rules[device_number]:
                v_ld.if_unless[rules_index] = v_dev.if_unless[device_number][rules_index]
                v_ld.ruleindex_typ[rules_index] = v_dev.ruleindex_typ[device_number][rules_index]
                v_ld.direct_command_to_sent[rules_index] = v_dev.direct_command_to_sent[device_number][rules_index]
                v_ld.all_condition_per_index[rules_index] = v_dev.all_conditions[device_number][rules_index]
                v_ld.left_tok_by_index[rules_index] = v_token_params.cr_token[
                    v_dev.left_toks[device_number][rules_index]]
                v_announcelist.all_answer_token.append(
                    v_token_params.cr_token[v_dev.all_answer_toks[device_number][rules_index]])
            device_number += 1

    inital_block_status()
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


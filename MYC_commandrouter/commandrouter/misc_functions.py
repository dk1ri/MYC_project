"""
name : misc_functions.py
last edited: 20260407
misc functions
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""
import os

import v_dev
from buffer_handling import *
from command_handling import *

import v_announcelist
import v_cr_params
import v_configparameter
import v_ld
import v_sk
import v_token_params
import v_time_values

def str_to_bytearray(string):
    # for string s: length with length l
    c = bytearray()
    i = 0
    while i < len(string):
        c.append(ord(string[i]))
        i += 1
    return c

def ba_to_str(ba):
    # bytearray to string
    string = ""
    i = 0
    while i < len(ba):
        string += str(ba[i])
        i += 1
    return string

def length_of_int(i):
    # return the number of bytes to be used ( 1, 2, 3, 4) depending on i
    # for positions etc
    if i > 0xFFFFFFFF:
        return 5
    if i > 0xFFFFFF:
        return 4
    elif i > 0xFFFF:
        return 3
    elif i > 0xFF:
        return 2
    else:
        return 1

def int_to_ba(integ, length):
    # convert a integer to a bytearray of of int (0-255) with a length  ( 1, 2, 4, 8 )
    # length 0: use CR tokenlength
    if length == 0:
        length = v_announcelist.length_of_full_elements
    ba = bytearray()
    i = 0
    while i < length:
        ba.append(0)
        i += 1
    i = 0
    while i < length:
        ba[length - i - 1] = integ & 0xFF
        integ >>= 8
        i += 1
    return ba

def bytes_to_int_ba(ba):
    i = len(ba) - 1
    z = 1
    temp = 0
    while i >= 0:
        temp += ba[i] * z
        z *= 256
        i -= 1
    return temp

def tok_to_bytes(tok, length):
    # return tok or other number (as int) with length given by v_announcelist.length_of_full_elements
    # length == 0: use tok length
    if length == 0:
        length = v_announcelist.length_of_full_elements
    if length == 1:
        return bytearray([tok])
    elif length == 2:
        if tok < 0x100:
            return bytearray([0, tok])
        else:
            return bytearray([tok / 256, tok % 256 ])
    elif length == 3:
        if tok < 0x100:
            return bytearray([0, 0, tok])
        elif tok < 0x10000:
            return bytearray([0, tok / 256, tok % 256 ])
        else:
            n0 = tok / 256
            n1 = tok % 256
            n2 = n1 / 26
            n3 = n1 % 256
            return bytearray([n0, n2, n3 ])
    # should not happen
    return bytearray([tok])

def device_length_of_commandtoken(number):
    # for devices only
    # number is highest tokennumber of a devices
    multi = 256
    # length_of_commandtoken:
    length_commandtoken = 1
    while number + 16 >= multi:
        multi = multi * 256
        length_commandtoken += 1
    return length_commandtoken


def length_of_typ(c_type):
    # c_type is parameter - type: a, b, L d, .... or number for string
    # return 1st element: n|s   2nd element: length of parameter or length of stringlength, 3rd element: max value
    # without <des>
    if c_type in v_cr_params.length_of_par:
        # as lin,...
        return "n", v_cr_params.length_of_par[c_type], v_cr_params.max_of_par[c_type]
    if c_type == "c":
        # commands
        return "n", v_announcelist.length_of_full_elements,
    else:
        # string
        return "s", length_of_int(int(c_type)), int(c_type)

def write_log(line):
    with open(v_configparameter.logfile) as file:
        i = len(file.readlines())
    if i > v_configparameter.max_log_lines:
        os.remove(v_configparameter.logfile)
    if v_configparameter.test_mode == 1:
        print(line)
    v_sk.last_error = line
    handle = open(v_configparameter.logfile, "a")
    handle.write(str(time.time()) + " " + line + "\n")
    handle.close()
    return

def strip_des_chapter(announcement):
    # strip <des> and CHAPTER and other OPTIONS
    # returns list
    i = 0
    a = announcement.split(";")
    stripped = []
    while i < len(a):
        drop = 0
        item = a[i].split(",")
        if len(item) > 1:
            if item[1] == "CHAPTER" or item[1] == "METER":
                drop = 1
        if drop == 0:
            stripped.append(item[0])
        i += 1
    return stripped


def stacklength(stripped):
    # return the number of bytes required for stacks if stack is > 1
    stacks = int(stripped[2])
    # value 0 is not allowed -> 1; transmitted value i "0" based:
    if stacks == 0:
        stacks = 1
    stacks -= 1
    if stacks == 0:
        # nothing transmitted
        stack_length = 0
    else:
        stack_length = length_of_int(stacks)
    return  stacks, stack_length

def split_rule(line):
    typ = "IF"
    if " UNLESS " in line:
        typ = "UNLESS"
    li_ = line.split(typ)
    left = li_[0].replace("$", "").replace("R;", "").split(" ")
    if len(li_) > 1:
        right = li_[1].replace("$", "").replace("&", "")
    else:
        right = ""
    return left, right, typ

def default_data():
    # for LD status
    for tok in v_ld.right_tok:
        ct = v_announcelist.full[tok][1]
        # without tok
        # nothing done for "ou", "oo", "xm", "xn" and "xf"
        if not tok in v_ld.actual_status:
            v_ld.actual_status[tok] = {}
        announce = v_announcelist.full[tok][v_announcelist.length_of_full_elements + 1:]
        match ct:
            case "os" | "as" | "rs" | "ss":
                # less than 256 positions only
                if int(announce[0]) == 1:
                    # no stack
                    v_ld.actual_status[tok] = []
                    v_ld.actual_status[tok].append(-1)
                else:
                    # with stack
                    i = 0
                    v_ld.actual_status[tok] = []
                    while i < int(announce[0]):
                        v_ld.actual_status[tok].append(-1)
                        i += 1
            case "or" | "ar" | "rr"| "sr":
                if int(announce[0]) == 1:
                    # no stack
                    v_ld.actual_status[tok] = []
                    i = 0
                    while i < len(announce) - 1:
                        v_ld.actual_status[tok].append(-1)
                        i += 1
                else:
                    # with stack
                    v_ld.actual_status[tok] = []
                    stack = 0
                    while stack < int(announce[0]):
                        v_ld.actual_status[tok].append([])
                        v_ld.actual_status[tok][stack] = []
                        pos = 0
                        while pos < len(announce) -1:
                            v_ld.actual_status[tok][stack].append(-1)
                            pos += 1
                        stack += 1
            case "op" |"ap"  | "rp"| "sp":
                dimensions = int((len(announce) - 1) / 3)
                if int(announce[0]) == 1:
                    # no stack
                    v_ld.actual_status[tok] = []
                    k = 0
                    while k < dimensions:
                        # all values
                        v_ld.actual_status[tok].append(-1)
                        k += 1
                else:
                    # with stack
                    v_ld.actual_status[tok] = []
                    stack = 0
                    while stack < int(announce[0]):
                        v_ld.actual_status[tok].append([])
                        k = 0
                        while k < dimensions:
                            v_ld.actual_status[tok][stack].append(-1)
                            k += 1
                        stack += 1
            case "oa" | "aa"  | "ra"| "sa":
                v_ld.actual_status[tok] = []
                pos = 0
                while pos < len(announce):
                    c_type, length, c = length_of_typ(announce[pos])
                    if c_type == "s":
                        v = ""
                    else:
                        v = -1
                    v_ld.actual_status[tok].append(v)
                    pos += 1
        if tok in v_token_params.o_to_a:
            v_ld.actual_status[v_token_params.o_to_a[tok]] = v_ld.actual_status[tok]
        if tok in v_token_params.a_to_o:
            v_ld.actual_status[v_token_params.a_to_o[tok]] = v_ld.actual_status[tok]
    return

def create_len_of_string_length():
    # for xa und xb commands only
    for tok in v_announcelist.full:
        line = v_announcelist.full[tok]
        ct =  line[1].split(",")[0]
        if ct == "oa" or ct == "aa" or ct == "ob" or ct == "ab":
            i = 2
            if not tok in v_announcelist.string_length_ab:
                v_announcelist.string_length_ab[tok] = []
            while i < len(line):
                val = line[i].split(",")[0]
                if val.isdigit():
                    val = int(val)
                    v_announcelist.string_length_ab[tok].append(val)
                else:
                    v_announcelist.string_length_ab[tok].append(-1)
                i  += 1
    return

def real_tok(tok, max_number):
    # calculate the tok with length depending on maxnumber
    # used for "general" 240 ++ commands
    tok_ = tok
    if max_number < 0x100:
        tok_ = tok
    elif max_number < 0x10000:
        tok_ = 0xff + tok
    elif max_number < 0x1000000:
        tok_ = 0xffff + tok
    elif max_number < 0x100000000:
        tok_ = 0xffffff + tok
    #  not more than 0xffffffff commands expected
    return tok_

def handle_rules(device):
    # for one device
    # split multiple tok on left side
    rules_for_this_device = []
    v_dev.all_conditions[device] = []
    rules0 = []
    for lines in v_dev.rules[device]:
        ok = 0
        typ = "IF"
        if  " UNLESS " in lines:
            typ = "UNLESS"
            ok = 1
        else:
            if " IF " in lines:
                typ = "IF"
                ok = 1
        if ok == 0:
            write_log("device "+ str(device) + "error in rule: " + lines)
            continue
        li_ = lines.split(typ)
        left = li_[0].replace("$", "").replace("R;", "").split(" ")
        if len(li_) > 1:
            right = li_[1].replace("$", "").replace("&", "")
        else:
            write_log("device "+ str(device) + "error in rule: " + lines)
            continue
        if len(right.replace(" ","")) == 0:
                write_log("device "+ str(device) + "empty right side in rule" + lines)
        else:
            i = 0
            while i < len(left):
                # split multiple left toks
                if left[i] != "":
                    if left[i] != "!~" and left[i] != "!!~":
                        if "!" in left:
                            tok = left[i].replace("!", "").replace(" ", "")
                            # command
                            if not tok.isnumeric():
                                write_log("device "+ str(device) + "error in rule: commandtoken not numeric " + lines)
                            else:
                                rules0.append([left[i], typ, right])
                        else:
                            rules0.append([left[i], typ, right])
                    else:
                        rules0.append([left[i], typ, right])
                i += 1

    # device 0: CR: empty
    v_dev.if_unless[0] = 0
    v_dev.ruleindex_typ[0] = 0
    # - 1: not used
    v_dev.direct_command_to_sent[0] = [-1]
    v_dev.rules[0] = ""
    v_dev.all_conditions[0] = []
    v_dev.left_toks[0] = []
    v_dev.right_toks[0] = []

    # actual device
    v_dev.if_unless[device] = []
    v_dev.ruleindex_typ[device] = []
    # - 1: not used
    v_dev.direct_command_to_sent[device] = []
    v_dev.rules[device] = []
    v_dev.all_conditions[device] = []
    v_dev.left_toks[device] = []
    v_dev.right_toks[device] = []

    rule_index = 0
    for lines in rules0:
        # all must have a value
        ok = 1
        if lines[1] == "IF":
            v_dev.if_unless[device].append(0)
        else:
            # UNLESS
            v_dev.if_unless[device].append(1)

        left = lines[0]
        right = lines[2]
        if left == "!~":
            v_dev.ruleindex_typ[device].append(0)
        elif left == "!!~":
            v_dev.ruleindex_typ[device].append(1)
        elif left[0] == "!":
            # normal command
            left0 = int(left.replace("!", ""))
            # check left0 tok in all_toks_of_dev and operating command
            if left0 in v_dev.all_toks_of_dev[device] and left0 not in v_dev.all_answer_toks[device]:
                v_dev.left_toks[device].append(left0)
            else:
                misc_functions.write_log("device "+ str(device) + " left token not valid: " + " ".join(lines))
                ok = 0
            v_dev.ruleindex_typ[device].append(2)
        elif left[0] == "?":
            # full command to block
            v_dev.ruleindex_typ[device].append(3)
        else:
            # direct command to excute not allowed for devices
            misc_functions.write_log("device "+ str(device) + " left data not valid: " + " ".join(lines))

        if ok == 1:
            ok = create_condition_per_index(device, rule_index, right)
        if ok == 1:
            # find toks in right
            r = right.split(" ")
            i = 0
            while i < len(r) and ok == 1:
                # drop first space
                if len(r[i]) > 0:
                    if r[i] in v_ld.condition_operators:
                        pass
                    else:
                        j = 0
                        num = ""
                        fin = 0
                        while j < len(r[i]) and not fin:
                            if r[i][j].isnumeric():
                                num += r[i][j]
                            else:
                                fin = 1
                            j += 1
                        if num != "":
                            # tok of the right side
                            tok_int = int(num)
                            # tok must be in v_announcelist.all_answer_token
                            if tok_int not in v_dev.all_answer_toks[device]:
                                misc_functions.write_log("device "+ str(device) + "no answer token: " + str(tok_int))
                                ok = 0
                            v_dev.right_toks[device].append(tok_int)
                        else:
                            misc_functions.write_log("device "+ str(device) + " rule right side error: " + right)
                            ok = 0
                i += 1
        if ok == 1:
            rules_for_this_device.append("")
            rules_for_this_device[rule_index] = left + " " + typ + right
            rule_index += 1
            next_rule = 1
    v_dev.rules[device] = rules_for_this_device

def create_condition_per_index(device, rule_index, right):
    # for one device, one ruleindex
    # for right side
    v_dev.all_conditions[device].append([])
    if right[0] == " ":
        right = right[1:]
    if right[0] == "~":
        v_dev.all_conditions[device][rule_index] = [right[0]]
        return 1
    linex = right.split(" ")
    rule_element = 0
    ok = 1
    while rule_element < len(linex) and ok == 1:
        v_dev.all_conditions[device][rule_index].append([])
        ok = 1
        # all conditions or separators
        # each condition (or separator)
        condition = linex[rule_element]
        if condition in v_ld.condition_operators:
            v_dev.all_conditions[device][rule_index][rule_element] = condition
        else:
        # start with tok
            tok_string = ""
            i = 0
            while i < len(condition) and not (condition[i] in v_ld.relational_operators):
                if condition[i] != " ":
                    tok_string += condition[i]
                i += 1
            try:
                tok = int(tok_string)
                condition = condition[i:]
            except:
                # ignore rule
                write_log("wrong tok in right side of rule" + condition)
                return 0
            v_dev.all_conditions[device][rule_index][rule_element] = [tok]
            character = 0
            # start with relational operator
            next_is_rel = 1
            while character < len(condition):
                # relational operator follow
                if next_is_rel == 1:
                    # parameter must start with separator ["<", ">", "=", "!"]
                    if condition[character] in v_ld.relational_operators:
                        # separator ["<", ">", "=", "!"]
                        v_dev.all_conditions[device][rule_index][rule_element].append(condition[character])
                        next_is_rel = 0
                    else:
                        write_log("wrong right side (relational operator) " + condition)
                        return 0
                    character += 1
                else:
                    # value follow
                    start_index = character
                    # find next rel
                    while character < len(condition) and not (condition[character] in v_ld.relational_operators):
                        character += 1
                    value_to_check = condition[start_index:character]
                    if "TO" in value_to_check:
                        to_ = value_to_check.split("TO")[1]
                        from_ = value_to_check.split("TO")[0]
                        rel_found = 0
                        i = 0
                        for rel in v_ld.relational_operators:
                            if rel in to_:
                                rel_found = 1
                                # skip all this tof next relational operator
                                character += 1
                            else:
                                i += 1
                        if rel_found == 1:
                            # drop next part
                            to_ = to_[1][:i - 2]
                        string_not_num = 0
                        try:
                            value = int(from_)
                        except ValueError:
                            string_not_num = 1
                        try:
                            value = int(to_)
                        except ValueError:
                            string_not_num = 1
                        if string_not_num == 0:
                            v_dev.all_conditions[device][rule_index][rule_element].append("n")
                            v_dev.all_conditions[device][rule_index][rule_element].append(value_to_check)
                        else:
                            # string that contains TO
                            v_dev.all_conditions[device][rule_index][rule_element].append("s")
                            v_dev.all_conditions[device][rule_index][rule_element].append(value_to_check)
                    else:
                        # numeric or string or tilde
                        if value_to_check == "~":
                            v_dev.all_conditions[device][rule_index][rule_element].append("n")
                            v_dev.all_conditions[device][rule_index][rule_element].append(value_to_check)
                        else:
                            try:
                                va = int(value_to_check)
                                v_dev.all_conditions[device][rule_index][rule_element].append("n")
                                v_dev.all_conditions[device][rule_index][rule_element].append(va)
                            except ValueError:
                                v_dev.all_conditions[device][rule_index][rule_element].append("n")
                                v_dev.all_conditions[device][rule_index][rule_element].append(len(value_to_check))
                                v_dev.all_conditions[device][rule_index][rule_element].append("=")
                                v_dev.all_conditions[device][rule_index][rule_element].append("s")
                                v_dev.all_conditions[device][rule_index][rule_element].append(value_to_check)
                    next_is_rel = 1
        rule_element += 1
    return ok

def inital_block_status():
    #  at start all toks, which appear in the right side are not blocked
    rule_index = 0
    # all ruleindices have a v_ld.ruleindex_typ
    while rule_index < len(v_ld.ruleindex_typ):
        if v_ld.ruleindex_typ[rule_index] == 1:
            # !!tilde true always at start
            v_ld.blocked_rule_index[rule_index] = 1
        else:
            # others blocked (or false)
            v_ld.blocked_rule_index[rule_index] = 0
        rule_index += 1
    return
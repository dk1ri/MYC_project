"""
name : ld_init.py
last edited: 20260224
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
------------------------------------------------
read_my_devices at start and from time to time
------------------------------------------------
"""
import v_linelength
from misc_functions import *
import v_announcelist
import v_token_params
import v_ld


def read_read_rulelists():
    # announcelist.rules is ok (from CR)
    # split multiple tok on left side
    rule_index = 0
    initial_rules = {}
    for lines in v_announcelist.rules:
        ok = 1
        left, right, typ = split_rule(lines)
        typ = typ.replace(" ","")
        if not typ in v_ld.compare_operator:
            write_log("error in rule: no compare limiter"   + lines)
            ok = 0
        tok_list = left.split(" ")
        i = 0
        while i < len(tok_list):
            # split multiple left toks
            if tok_list[i] != "":
                if tok_list[i] != "!$~" and tok_list[i] != "!!$~":
                    if "!$" in left:
                        tok = left.replace("!$", "").replace(" ", "")
                        # command
                        if not tok.isnumeric():
                            write_log("error in rule: commandtoken not numeric " + lines)
                            ok = 0
                if ok == 1:
                    initial_rules[rule_index] = tok_list[i] + " " + typ + " " + right
                rule_index += 1
            i += 1

    rule_index = 0
    while rule_index < len(initial_rules):
        lines = initial_rules[rule_index]
        v_ld.left_tok_by_index[rule_index] = 0
        v_ld.command_sent_by_index[rule_index] = 0
        if "IF" in lines:
            v_ld.if_unless[rule_index] = 0
            typ = "IF"
        elif " UNLESS " in lines:
            v_ld.if_unless[rule_index] = 1
            typ = " UNLESS "
        else:
            # should not happen
            v_ld.if_unless[rule_index] = 4
            typ = "IF"
        left = lines.split(typ)[0].replace(" ", "")
        right = lines.split(typ)[1].replace("$", "").replace("&", "")[1:]
        if left[0].isnumeric():
            # direct command
            v_ld.direct_command_by_index[rule_index] = left
        elif left == "!$~":
            v_ld.index_of_tilde.append(rule_index)
            v_ld.left_tok_by_index[rule_index] = left
        elif left == "!!$~":
            v_ld.index_of_not_tilde.appen(rule_index)
            v_ld.left_tok_by_index[rule_index] = left
        else:
            if left[0:2] == "!$":
                # drop "$"
                left = left.replace("!$","")
                tok_int = int(left)
                if not (tok_int in v_ld.all_used_toks):
                    v_ld.all_used_toks[tok_int] = tok_int
                if not (tok_int in v_ld.left_tok):
                    v_ld.left_tok[tok_int] = tok_int
                v_ld.left_tok_by_index[rule_index] = tok_int
        create_condition_per_index(rule_index, right)

        # find toks in right
        r = right.split(" ")
        i = 0
        while i < len(r):
            # drop first space
            if r[i] != []:
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
                    tok_int = int(num)
                    if not tok_int in v_ld.all_used_toks:
                        v_ld.all_used_toks[tok_int] = tok_int
                    if not tok_int in v_ld.right_tok:
                        v_ld.right_tok.append(tok_int)
            i += 1
        rule_index += 1
    return


def create_condition_per_index(rule_index,right):
    # for right side
    v_ld.all_condition_per_index[rule_index] = {}
    line = right
    if len(line) == 0:
        #should not happen
        return
    if line[0] == " ":
        line = line[1:]
    linex = line.split(" ")
    # split conditions (rule_element)
    rule_element = 0
    while rule_element < len(linex):
        ok = 1
        # all conditions or separators
        v_ld.all_condition_per_index[rule_index][rule_element] = []
        # each condition
        condition = linex[rule_element]
        # for a / b commands the 1.values of the 1st element must be stored
        # more than one element (position exist)
        store_for_string = 0
        if rule_element == 0 and len(linex) > 3:
            store_for_string = condition[3]
        # one condition
        tok = ""
        i = 0
        while i < len(condition) and not (condition[i] in v_ld.relational_operators):
            if condition[i] != " ":
                tok += condition[i]
            i += 1
        try:
            tok = int(tok)
            condition = condition[i:]
        except:
            ok = 0
        if ok:
            v_ld.all_condition_per_index[rule_index][rule_element].append(tok)
            character = 0
            param = 1
            parameter_started = 0
            next_par = 1
            val = ""
            to_found = 0
            while character < len(condition):
                # relational operator follow
                if parameter_started == 0:
                    # add [] for parameter
                    v_ld.all_condition_per_index[rule_index][rule_element].append([])
                    parameter_started = 1
                if next_par == 1:
                    # parameter must start with separator ["<", ">", "=", "!"]
                    if condition[character] in v_ld.relational_operators:
                        # separator ["<", ">", "=", "!"]
                        v_ld.all_condition_per_index[rule_index][rule_element][param].append(condition[character])
                        next_par = 0
                    else:
                        write_log("wrong right side (relational operator) " + condition)
                        break
                else:
                    if to_found == 0:
                    # value or valueTOvalue follow
                        if condition[character] == "T":
                            try:
                                # value before TO must be numeric
                                va = int(val)
                                v_ld.all_condition_per_index[rule_index][rule_element][param].append("n")
                                v_ld.all_condition_per_index[rule_index][rule_element][param].append(va)
                                to_found = 1
                                val = ""
                                # skip "TO"
                          #      character += 2
                            except ValueError:
                                write_log("wrong right side with TO" + condition)
                                break
                        else:
                      #      if condition[character] in v_ld.relational_operators:
                       #         # separator ["<", ">", "=", "!"]
                        #        v_ld.all_condition_per_index[rule_index][rule_element][param].append(condition[character])
                         #       val = ""
                          #  else:
                                # value after relational_operators
                                val += condition[character]
                                # last character of value
                                # last character or next is relational_operator
                                if character + 1 == len(condition) or character + 1 < len(condition) and condition[character + 1] in v_ld.relational_operators:
                                    try:
                                        va = int(val)
                                        v_ld.all_condition_per_index[rule_index][rule_element][param].append("n")
                                        v_ld.all_condition_per_index[rule_index][rule_element][param].append(va)
                                    except ValueError:
                                        # val is complete string. add length
                                        # store_for_string is pos of parameter, length nis in _announcelist.string_length_ab[tok]
                                        length_of_string = length_of_int(v_announcelist.string_length_ab[tok][store_for_string])
                                        v_ld.all_condition_per_index[rule_index][rule_element][param].append("s")
                                        length = len(val)
                                        v_ld.all_condition_per_index[rule_index][rule_element][param].append(int_to_bytes(length, length_of_string) + val)
                                    next_par = 1
                                    val = ""
                    else:
                        # 2 value of "TO"
                        val += condition[character]
                        # last character?
                        if character == len(condition):
                            try:
                                val = int(condition)
                                v_ld.all_condition_per_index[rule_index][rule_element][param].append("n")
                                v_ld.all_condition_per_index[rule_index][rule_element][param].append(val)
                                to_found = 0
                                next_par = 1
                            except ValueError:
                                write_log("wrong right side with TO" + condition)
                                break
                character += 1
        rule_element += 1
    return

def more_all_used_toks():
    # find answer commands for all_used_toks. if missing
    add = {}
    for tok in v_ld.all_used_toks:
        if tok in v_token_params.o_to_a:
            if not v_token_params.o_to_a[tok] in v_ld.all_used_toks:
                add[v_token_params.o_to_a[tok]] = v_token_params.o_to_a[tok]
        if tok in v_token_params.a_to_o:
            if not v_token_params.a_to_o[tok] in v_ld.all_used_toks:
                add[v_token_params.a_to_o[tok]] = v_token_params.a_to_o[tok]
    for tok in add:
        v_ld.all_used_toks[tok] = tok
    return

def find_string_parameters():
    # find tok and position if string parameters
    for  tok in v_announcelist.all_token:
        line = v_announcelist.full[tok]
        if line[1] == "oa" or line[1] == "aa":
            position = ""
            tok = int(line[0])
            i = 2
            while i < len(line):
                l_type = line[i].split(",")[0]
                if not l_type in v_cr_params.command_types:
                    if position == "":
                        v_ld.stringparameters[tok] = {}
                        position = 0
                    v_ld.stringparameters[tok][position] = position
                    position += 1
                i += 1
    return

def create_ld_type_for_right_side_tok():
    for rtok in v_ld.right_tok:
        ct = v_announcelist.full[rtok][1].split(",")[0]
        match ct:
            case "os" | "as"  "rs" | "ss":
                if v_announcelist.full[rtok][2] == 1:
                    # os no stack
                    v_ld.ld_type_by_rtok[rtok] = 1
                else:
                    # with stack
                    v_ld.ld_type_by_rtok[rtok] = 2
            case "or" | "ar" | "rr" | "sr":
                if v_announcelist.full[rtok][2] == 1:
                    # or no stack
                    v_ld.ld_type_by_rtok[rtok] = 2
                else:
                    # with stack
                    v_ld.ld_type_by_rtok[rtok] = 3
            case "op" | "ap" | "rr" | "sp":
                if v_announcelist.full[rtok][2] == 1:
                    # or no stack
                    v_ld.ld_type_by_rtok[rtok] = 4
                else:
                    # with stack
                    v_ld.ld_type_by_rtok[rtok] = 5
            case "oo" | "ro":
                if v_announcelist.full[rtok][2] == 1:
                    # oo no stack not used
                    v_ld.ld_type_by_rtok[rtok] = 6
                else:
                    # with stack not used
                    v_ld.ld_type_by_rtok[rtok] = 7
            case "oa" | "aa":
                if len(v_announcelist.full[rtok]) == 3:
                    # one element
                    v_ld.ld_type_by_rtok[rtok] = 10
                else:
                    v_ld.ld_type_by_rtok[rtok] = 11
    return
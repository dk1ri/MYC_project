"""
name : ld_init.py
last edited: 202512
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
------------------------------------------------
read_my_devices at start and from time to time
------------------------------------------------
"""
from ld_misc import *
from misc_functions import *
import v_announcelist
import v_token_params
import v_ld

def ld_initialization():
    read_read_announcelists()
 #   create_a_to_o()
    more_all_used_toks()
    find_string_parameters()
    init_ct_value_by_ct()
    return


def read_read_announcelists():
    # announcelist ok (from CR)
    # split multiple tok on left side and create basic and rules
    rule_index = 0
    initial_rules = {}
    for lines in v_announcelist.rules:
        typ = "IF"
        li = lines.split(";")[1]
        if " IF " in li:
            typ = " IF "
        elif " UNLESS " in li:
            typ = " UNLESS "
        elif " AFTER" in li:
            typ = " AFTER"
        elif " IN" in li:
            typ = " IN"
        li_ = li.split(typ)
        left = li_[0]
        if len(li_) > 1:
            right = li_[1]
        else:
            right = ""
        tok_list = left.split(" ")
        i = 0
        while i < len(tok_list):
            # split multiple left toks
            if tok_list[i] != "":
                initial_rules[rule_index] = tok_list[i] + typ + right
                rule_index += 1
            i += 1

    rule_index = 0
    while rule_index < len(initial_rules):
        lines = initial_rules[rule_index].replace("\n", "")
        # drop first "!" for toks
        if lines[0] == "!":
            lines = lines[1:]
        ok = check_rules(lines)
        if not ok:
            # skip wrong rules
            rule_index += 1
            return
        v_logicdevice.left_tok_by_index[rule_index] = 0
        v_logicdevice.command_sent_by_index[rule_index] = 0
        if "IF" in lines:
            v_logicdevice.if_unless[rule_index] = 0
            typ = "IF"
        elif " UNLESS " in lines:
            v_logicdevice.if_unless[rule_index] = 1
            typ = " UNLESS "
        elif " AFTER" in lines:
            v_logicdevice.if_unless[rule_index] = 2
            typ = " AFTER"
            v_logicdevice.after_by_index[rule_index] = rule_index
        else:
            # should not happen
            v_logicdevice.if_unless[rule_index] = 4
            typ = "IF"
        left = lines.split(typ)[0]
        if len(left) > 1:
            right = lines.split(typ)[1]
        else:
            right = ""
        left = left.replace(" ", "")
        if left[0].isnumeric():
            # one command or AFTER
            v_logicdevice.direct_command_by_index[rule_index] = left
        elif left == "$~":
            v_logicdevice.all_by_index[rule_index] = rule_index
            v_logicdevice.left_tok_by_index[rule_index] = left
        elif left == "!$~":
            v_logicdevice.not_all_by_index[rule_index] = rule_index
            v_logicdevice.left_tok_by_index[rule_index] = left
        else:
            if left[0] == "$":
                # drop "$"
                left = left[1:].replace(" ","")
                tok_int = int(left)
                if not (tok_int in v_ld.all_used_toks):
                    v_ld.all_used_toks[tok_int] = tok_int
                if not (tok_int in v_logicdevice.left_tok):
                    v_logicdevice.left_tok[tok_int] = tok_int
                v_logicdevice.left_tok_by_index[rule_index] = tok_int
        create_condition_per_index(rule_index, right)
        # find toks in right
        while right != "":
            if right[0] == "$":
                right = right[1:]
                tok_int, right = find_tok(right)
                if not tok_int in v_ld.all_used_toks:
                    v_ld.all_used_toks[tok_int] = tok_int
            else:
                right = right[1:]
        rule_index += 1
    return


def create_condition_per_index(rule_index,right):
    # for t1 rule
    v_logicdevice.all_condition_per_index[rule_index] = {}
    line = right
    if len(line) == 0:
        #should not happen
        return
    if line[0] == " ":
        line = line[1:]
    linex = line.split(" ")
    rule_element = 0
    while rule_element < len(linex):
        # all conditions
        v_logicdevice.all_condition_per_index[rule_index][rule_element] = {}
        # each condition
        condition = linex[rule_element]
        if condition in v_logicdevice.condition_operators:
            v_logicdevice.all_condition_per_index[rule_index][rule_element][0] = condition
        else:
            c_index = 0
            while len(condition) > 0:
                if condition[0] == "$":
                    condition = condition[1:]
                    tok, condition = find_tok(condition)
                    if condition == "":
                        v_logicdevice.all_condition_per_index[rule_index][rule_element][0] = tok
                        v_logicdevice.all_condition_per_index[rule_index][rule_element][1] = "="
                        v_logicdevice.all_condition_per_index[rule_index][rule_element][2] = "~"
                        break
                    # differentiate tok - value for calculation
                    v_logicdevice.all_condition_per_index[rule_index][rule_element][c_index] = tok
                    c_index += 1
                    if condition[0] in v_logicdevice.relational_operators:
                        # one parameter only
                        v_logicdevice.all_condition_per_index[rule_index][rule_element][c_index] = condition[0]
                        c_index += 1
                        condition = condition[1:]
                        value_calculate_element(rule_index, rule_element ,c_index, condition)
                        c_index += 1
                elif condition[0] == "&":
                    condition = condition[1:]
                    # operator following
                    if condition[0] in v_logicdevice.relational_operators:
                        v_logicdevice.all_condition_per_index[rule_index][rule_element][c_index] = condition[0]
                        condition = condition[1:]
                    else:
                        # TO notation
                        from_, condition = find_tok(condition)
                        v_logicdevice.all_condition_per_index[rule_index][rule_element][c_index] = int(from_)
                        # skip TO
                        condition = condition[2:]
                    # data following
                    c_index += 1
                    condition = value_calculate_element(rule_index, rule_element, c_index, condition)
                    c_index += 1
                else:
                    # should not happen
                    condition = condition[1:]
                    c_index += 1
        rule_element += 1
    return

def value_calculate_element(rule_index, rule_element, c_index, condition):
    # condition for value element
    #  calculation is missing
    value, condition = find_tok(condition)
    v_logicdevice.all_condition_per_index[rule_index][rule_element][c_index] = {}
    v_logicdevice.all_condition_per_index[rule_index][rule_element][c_index][0] = value
    return condition

def init_ct_value_by_ct():
    for tok in v_announcelist.all_token:
        linex = v_announcelist.full[tok]
        ct = linex[1]
        tok = linex[0]
        v_logicdevice.ct[tok] = ct
        if linex[0] in v_ld.all_used_toks:
            linex = linex[2:]
            # nothing done for "ou", "oo", "xm", "xn" and "xf"
            match ct:
                case "os" | "as":
                    # less than 256 positions only
                    if int(linex[0]) == 1:
                        # no stack
                        create_update(tok)
                        create_value0(tok)
                        v_logicdevice.value[tok] = 0
                    else:
                        # with stack
                        create_update(tok)
                        create_value0(tok)
                        # for all stacks
                        i = 0
                        while i < int(linex[0]):
                            create_value1(tok, i)
                            v_logicdevice.value[tok][i] = 0
                            i += 1
                case "or" | "ar":
                    if int(linex[0]) == 1:
                        # no stack
                        create_update(tok)
                        create_value0(tok)
                        # for all positions
                        i = 0
                        while i < len(linex) - 1:
                            create_value1(tok, i)
                            v_logicdevice.value[tok][i] = 0
                            i += 1
                    else:
                        create_update(tok)
                        create_value0(tok)
                        # for all stacks
                        i = 0
                        while i < int(linex[0]):
                            create_value1(tok, i)
                            v_logicdevice.value[tok][i] = {}
                            j = 0
                            while j < len(linex) - 1:
                             #   v_logicdevice.value[tok][i][j] = {}
                                if not j in v_logicdevice.value[tok][i]:
                                #    v_logicdevice.value[v_logicdevice.o_to_a[tok]][i][j] = {}
                                    v_logicdevice.value[tok][i][j] = 0
                                j += 1
                            i += 1
                case "op" |"ap":
                    if int(linex[0]) == 1:
                        # no stack
                        create_update(tok)
                        create_value0(tok)
                        i = 2
                        k = 0
                        while i < len(linex):
                            if not k in v_logicdevice.value[tok]:
                                v_logicdevice.value[tok][k] = 0
                                k += 1
                            i += 3
                    else:
                        # with stack
                        create_update(tok)
                        create_value0(tok)
                        i = 0
                        while i < int(linex[0]):
                            # all stacks
                            if not i in v_logicdevice.value[tok]:
                                v_logicdevice.value[tok][i] = {}
                                j = 2
                                k = 0
                                while j < len(linex):
                                    if not k in v_logicdevice.value[tok][i]:
                                        v_logicdevice.value[tok][i][k] = 0
                                        k += 1
                                    j += 3
                            i += 1
                case "oa" | "aa":
                    create_value0(tok)
                    if len(linex) == 1:
                        # one element
                        if tok in v_logicdevice.stringparameters:
                            v_logicdevice.value[tok][0] = ""
                        else:
                            v_logicdevice.value[tok][0] = 0
                    else:
                        v_logicdevice.value[tok][0] = 0
                        i = 0
                        j = 0
                        while i < len(linex):
                            if tok in v_logicdevice.stringparameters:
                                if j in v_logicdevice.stringparameters[tok]:
                                    v_logicdevice.value[tok][j] = ""
                            else:
                                v_logicdevice.value[tok][j] = 0
                            i += 1
                            j += 1
    return

def check_rules(lines):
    ok = 1
    command = 0
    tok = 0
    error = ""
    linesx = lines.split(" ")
    left = linesx[0]
    right = linesx[2:]
    # left side
    if left != "$~" and left != "!$~":
        if "!" in left:
            tok = left.replace("!", "", 2)
            try:
                tok = int(tok[1:])
            except:
                error = " no numeric tok "
                ok = 0
        else:
            # command
            try:
                tok = int(left[1:], 16)
                command = 1
            except:
                error = "command not correct "
                ok = 0

        found = 0
        for i in v_logicdevice.compare_operator:
            if i in lines:
                found = 1
        if not found:
            error = " no compare limite r"
            ok = 0
        if not command and ok:
            line = v_announcelist.full[tok].replace("\n", "")
            linex = line.split(";")
            ct = linex[1].split(",")[0]
            if not ct in v_logicdevice.s_r:
                error = " commandtoken is memory "
                ok = 0
    # right side
        i = 0
        while i < len(right):
            if not right[i] in v_logicdevice.condition_operators:
                if right[i][0] != "$":
                    error = " condition do not start with $ "
                    ok = 0
                else:
                    tok, right[i] = find_tok(right[i][1:])
                    ct = v_announcelist.full[str(tok)].split(";")[1].split(",")[0]
                    if right[i] == "" and not (ct == "oo" or ct == "ou"):
                        # tok only allowed dor oo or ou commands
                        error = " only tok, other data missing "
                        ok = 0
            i += 1
    if not ok:
        write_log("error in rule: " + error + lines)
    return ok

"""
def create_a_to_o():
    # create lists of "as" answer commands
    # one "as" command per op command only, directly following
    last_tok = ""
    i = 0
    for tok in v_announcelist.full:
        lines_x = v_announcelist.full[int(tok)].split(";")
        org_line = ";".join(lines_x[2:])
        last_line = ""
        if last_tok != "":
            last_line = ";".join(v_announcelist.full[last_tok].split(";")[2:])
        if org_line == last_line:
            v_logicdevice.a_to_o[tok] = last_tok
            v_logicdevice.o_to_a[last_tok] = tok
        last_tok = tok
        i += 1
    return last_tok

"""

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
                if not l_type in v_logicdevice.command_types:
                    if position == "":
                        v_logicdevice.stringparameters[tok] = {}
                        position = 0
                    v_logicdevice.stringparameters[tok][position] = position
                    position += 1
                i += 1
    return
"""
name : ld_buffer_handling.py
last edited: 20260224
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""

import v_ld
import v_announcelist
import misc_functions
import v_token_params
import v_linelength
import v_sk


def store_by_ld():
    # data from dev are stored and send back to CR
    if v_ld.from_dev_to_ld != []:
        if v_ld.from_dev_to_ld[0] in v_ld.s_r_p_a_dev:
            store_data(v_ld.from_dev_to_ld[0], v_ld.from_dev_to_ld)
        v_ld.from_dev_to_sk = v_ld.from_dev_to_ld
    return

def ld_analyze():
    # the values of the transmitted data are checked by CR to be in the allowed range.
    # so check is not done
    # input_as_parameter_list is list of parameters (int or string)
    if v_sk.input_as_parameter_list == []:
        v_ld.from_ld_to_dev = v_sk.orig_to_ld
        v_sk.orig_to_ld = []
        return
    tok = int.from_bytes(v_sk.orig_to_ld[:v_announcelist.length_of_full_elements])
    ct = v_announcelist.full[tok][1]
    if not ct in v_ld.s_r_p_a_sk:
        v_ld.from_ld_to_dev = v_ld.orig_to_ld
        v_ld.input_as_parameter_list = []
        v_sk.orig_to_ld = []
        return
    print ("for LD", v_sk.orig_to_ld)
    if  tok in v_ld.right_tok:
        # store if tok in right side
        store_data(tok, v_sk.input_as_parameter_list)
    if tok in v_ld.blockd_toks:
        misc_functions.write_log("blocked: " + str(tok))
    else:
        # not blocked
        # update for oo command
        if v_announcelist.full[tok][1] == "oo":
            update_op_with_oo()
        v_ld.from_ld_to_dev = v_sk.orig_to_ld
    v_sk.orig_to_ld = []
    v_sk.input_as_parameter_list = []
    return

def find_blocked_toks():
    # find all left toks to be blocked by right side
    v_ld.blockd_toks = []
    all_blocked = 0
    rule_index = 0
    right_side_blocked = 0
    while rule_index < len(v_ld.left_tok_by_index):
        not_done = 1
        left_tok = v_ld.left_tok_by_index[rule_index]
        # there must be a actual status to be blocked
        # first check, if rules should be blocked
        if all_blocked == 1:
            # all blocked, search valid !!$~
            if rule_index in v_ld.index_of_not_tilde:
                right_side_blocked = parse_condition(v_ld.all_condition_per_index[rule_index])
                if right_side_blocked == 1:
                    all_blocked = 0
            # next rule
            not_done = 0
        if not_done and rule_index in v_ld.index_of_tilde:
            right_side_blocked = parse_condition(v_ld.all_condition_per_index[rule_index])
            if right_side_blocked == 1:
                all_blocked = 1
                not_done = 0
        if not_done and all_blocked == 1:
            not_done = 0
        if not_done and rule_index in v_ld.direct_command_by_index:
            right_side_blocked = parse_condition(v_ld.all_condition_per_index[rule_index])
            if right_side_blocked == 0:
                # true!!
                if rule_index in v_ld.command_sent_by_index[rule_index]:
                    if v_ld.command_sent_by_index[rule_index] == 0:
                        # not yet sent
                        v_ld.direct_commands.append(v_ld.direct_command_by_index[rule_index])
                        v_ld.command_sent_by_index[rule_index] = 1
                else:
                    # allow again
                    v_ld.command_sent_by_index[rule_index] = 0
            not_done = 0
        # normal commands on left side
        if not_done:
            if v_ld.all_condition_per_index[rule_index] == "~":
                # block always
                right_side_blocked = 1
            else:
                right_side_blocked = parse_condition(v_ld.all_condition_per_index[rule_index])
            if v_ld.if_unless[rule_index] == 1:
                # "UNLESS"
                if right_side_blocked:
                    right_side_blocked = 0
                else:
                    right_side_blocked = 1
        if right_side_blocked or all_blocked:
            v_ld.blockd_toks.append(left_tok)
        rule_index += 1
    print(v_ld.blockd_toks)
    return

def parse_condition(full_condition):
    # check match of a rule
    operator_stack = []
    actual = 0
    element_index = 0
    while element_index < len(full_condition):
        # all conditions of a rule
        condition = full_condition[element_index]
        if condition[0] in v_ld.condition_operators:
            match condition[0]:
                case "(":
                    operator_stack.append("(")
                case ")":
                    pop_result = operator_stack.pop()
                    if pop_result != "(":
                        misc_functions.write_log("wrong operator stack")
                    else:
                        actual , operator_stack = handle_operator_stack(condition, operator_stack, actual)
                    operator_stack.append(")")
                case "AND":
                    operator_stack.append("A")
                case "OR":
                    operator_stack.append("O")
                case "!":
                    operator_stack.append("!")
        else:
            actual, operator_stack = handle_operator_stack(condition, operator_stack, actual)
        element_index += 1
    return actual

def handle_operator_stack(condition, operator_stack, actual ):
    result = comapare(condition)
    if len(operator_stack) == 0:
        # first element
        actual = result
    else:
        stop = 0
        while len(operator_stack) > 0 and not stop:
            last_stack = operator_stack.pop()
            if last_stack== "(" or last_stack == ")":
                operator_stack.append(last_stack)
                stop = 1
            else:
                match last_stack:
                    case "!":
                        if result == 0:
                            result = 1
                        else:
                            result = 0
                    case "O":
                        actual = actual or result
                        stop = 1
                    case "A":
                        actual = actual and result
                        stop = 1
    return actual, operator_stack

def comapare (condition):
    # tok for this condition
    ctok = condition[0]
    match_ = 1
    stat = v_ld.actual_status[ctok]
    match v_ld.ld_type_by_rtok[ctok]:
        case 1:
            # os no stack: 1 transmitted parameter
            match_ = m(0, condition[1], stat)
        case 2:
            # os with stack, or no stack ; 2 transmitted parameters
            max_ = v_announcelist.full[ctok][2]
            match_ = condition2(condition[1], stat, int(max_))
        case 3:
            # or with stack
            max_stack = v_announcelist.full[ctok][2]
            max_pos = len(v_announcelist.full[ctok]) - 2
            match_ = condition_3(condition[1], stat, int(max_stack), max_pos)
        case 4:
            # op no stack
            match_ = condition_4(condition)
        case 5:
            # op with stack
            match_ = condition_5(condition)
        case 10:
            # "oa" one parameter
            match_ = condition_10(condition)
        case 11:
            # "oa" more parameters
            match_ = condition_11(condition)
    return match_

def m(i, condition, stat):
    match_ = 0
    if condition[i+ 2] == "~":
        if condition[i] == "=":
            match_ = 1
        else:
            match_ = 0
    elif condition[i] == "=":
        if condition[i + 2] == stat:
            match_ = 1
    elif condition[i] == "<":
        if stat < condition[i + 2]:
            match_ = 1
    elif condition[i] == ">":
        if stat > condition[i + 2]:
            match_ = 1
    elif condition[i] == "!":
        if condition[i + 2] != stat:
            match_ = 1
    return match_

def condition2(all_params, status_for_tok, max_):
    match_ = 0
    match all_params[0]:
        case "=":
           match_ = m(3, all_params, status_for_tok[int(all_params[2])])
        case "<":
            i = 0
            while i < int(all_params[2]) and match_ == 0:
                match_ = m(3, all_params, status_for_tok[i])
                i += 1
        case ">":
            i = int(all_params[2] + 1)
            while i < max_ and match_ == 0:
                match_ = m(3, all_params, status_for_tok[i])
                i += 1
        case "!":
            i = 0
            while i < max_ and match_ == 0:
                if i != all_params[2]:
                    match_ = m(3, all_params, status_for_tok[i])
                i += 1
    return match_

def condition_3(all_params, status_for_tok, max_stack, max_pos):
    # or with stack
    match_ = 0
    match all_params[0]:
        case "=":
           match_ =condition99(all_params, status_for_tok, max_pos)
        case "<":
            i = 0
            while i < int(all_params[2]) and match_ == 0:
                match_ = condition99(all_params, status_for_tok, max_pos)
                i += 1
        case ">":
            i = int(all_params[2] + 1)
            while i < max_stack and match_ == 0:
                match_ = condition99(all_params, status_for_tok, max_pos)
                i += 1
        case "!":
            i = 0
            while i < max_stack and match_ == 0:
                if i != all_params[2]:
                    match_ = condition99(all_params, status_for_tok, max_pos)
                i += 1
    return match_

def condition99(all_params, status_for_tok, max_pos):
    match_ = 0
    match all_params[3]:
        case "=":
           match_ = m(6, all_params, status_for_tok[int(all_params[2])][int(all_params[5])])
        case "<":
            i = 0
            while i < int(all_params[5]) and match_ == 0:
                match_ = m(6, all_params, status_for_tok[i])
                i += 1
        case ">":
            i = int(all_params[5] + 1)
            while i < max_pos and match_ == 0:
                match_ = m(6, all_params, status_for_tok[i])
                i += 1
        case "!":
            i = 0
            while i < max_pos and match_ == 0:
                if i != all_params[5]:
                    match_ = m(6, all_params, status_for_tok[i])
                i += 1
    return match_

def condition_4(condition):
    # op cammand no stack
    match_ = 0
    # tok for this condition
    ctok = condition[0]
    stat = v_ld.actual_status[ctok]
    i = 0
    j = 0
    while i < len(stat) and match_ == 0:
        match_ = m(j, condition[1], stat[i])
        i += 1
        j += 3
    return match_

def condition_5(condition):
    # op cammand with stack
    match_ = 0
    # tok for this condition
    ctok = condition[0]
    max_stack = int(v_announcelist.full[ctok][2])
    dimensions = (len(v_announcelist.full[ctok]) - 2) / 3
    stack = 0
    while stack < max_stack and match_ == 0:
        match_ = m(0, condition[1], v_ld.actual_status[ctok][stack][0])
        if match_ == 1:
            i = 0
            while i <  dimensions and match_ == 0:
                match_ = m(i, condition[1], v_ld.actual_status[ctok][stack][i])
                i += 1
        stack += 1
    return match_

def condition_10(condition):
    # oa one parameter
    i = 0
    tok = condition[0]
    match_ = m(i, condition[1], v_ld.actual_status[tok][0])
    return match_

def condition_11(condition):
    match_ = 0
    tok = condition[0]
    i = 0
    j = 0
    while i < len(condition[1]) and match_ == 0:
        match_ = m(i, condition[1], v_ld.actual_status[tok][j])
        i += 3
        j += 1
    return match_

def store_data(tok, inputline):
    # inputline without tok
    if not tok in v_ld.actual_status:
        return
    ct = v_announcelist.full[tok][1]
    announce_line_tok = v_announcelist.full[tok]
    # nothing done for "ou", "oo", "xm", "xn" and "xf"
    match ct:
        case "os" | "as":
            # less than 256 positions only
            if int(announce_line_tok[2]) == 1:
                # no stack
                value = inputline[1]
                v_ld.actual_status[tok] = value
                if tok in v_token_params.o_to_a:
                    v_ld.actual_status[v_token_params.o_to_a[tok]] = value
                if tok in v_token_params.a_to_o:
                    v_ld.actual_status[v_token_params.a_to_o[tok]] = value
            else:
                # with stack
                stack = inputline[1]
                value = inputline[2]
                v_ld.actual_status[tok][stack] = value
                if tok in v_token_params.o_to_a:
                    v_ld.actual_status[v_token_params.o_to_a[tok]][stack] = value
                if tok in v_token_params.a_to_o:
                    v_ld.actual_status[v_token_params.a_to_o[tok]][stack] = value
        case "or" | "ar":
            if int(announce_line_tok[2]) == 1:
                # no stack
                pos = inputline[1]
                value = inputline[2]
                v_ld.actual_status[tok][pos] = value
                if tok in v_token_params.o_to_a:
                    v_ld.actual_status[v_token_params.o_to_a[tok]][pos] = value
                if tok in v_token_params.a_to_o:
                    v_ld.actual_status[v_token_params.a_to_o[tok]][pos] = value
            else:
                # with stack
                stack = inputline[1]
                pos = inputline[2]
                value = inputline[3]
                v_ld.actual_status[tok][stack][pos] = value
                if tok in v_token_params.o_to_a:
                    v_ld.actual_status[v_token_params.o_to_a[tok]][stack][pos] = value
                if tok in v_token_params.a_to_o:
                    v_ld.actual_status[v_token_params.a_to_o[tok]][stack][pos] = value

        case "op" |"ap":
            if int(announce_line_tok[2]) == 1:
                # no stack
                k = 1
                while k < len(inputline):
                    # all values
                    v_ld.actual_status[tok][k - 1] = inputline[k]
                    if tok in v_token_params.o_to_a:
                        v_ld.actual_status[v_token_params.o_to_a[tok]][k] = int.from_bytes(inputline[k])
                    if tok in v_token_params.a_to_o:
                        v_ld.actual_status[v_token_params.a_to_o[tok]][k] = int.from_bytes(inputline[k])
                    k += 1
            else:
                # with stack
                k = 2
                while k < len(inputline):
                    v_ld.actual_status[tok][int(inputline[1])][k -2] = inputline[k]
                    if tok in v_token_params.o_to_a:
                        v_ld.actual_status[v_token_params.o_to_a[tok]][int.from_bytes(inputline[0])][k] = int.from_bytes(inputline[k + 1])
                    if tok in v_token_params.a_to_o:
                        v_ld.actual_status[v_token_params.a_to_o[tok]][int.from_bytes(inputline[0])][k] = int.from_bytes(inputline[k + 1])
                    k += 1

        case "oa" | "aa":
            if len(announce_line_tok) == 3:
                if announce_line_tok[2].isdigit():
                    # string
                    data = ""
                    i = 0
                    while i < len(inputline):
                        data += chr(inputline[i])
                        i += 1
                else:
                    data = inputline
                # one element only
                v_ld.actual_status[tok][0] = data
                if tok in v_token_params.o_to_a:
                    v_ld.actual_status[v_token_params.o_to_a[tok]][0] = data
                if tok in v_token_params.a_to_o:
                    v_ld.actual_status[v_token_params.a_to_o[tok]][0] = data
            else:
                pos = inputline[0]
                if announce_line_tok[2 + pos].isdigit():
                    # string
                    data = ""
                    i = 0
                    while i < len(inputline[1]):
                        data += chr(inputline[1][i])
                        i += 1
                else:
                    data = inputline[1]
                v_ld.actual_status[tok][pos] = data
                if tok in v_token_params.o_to_a:
                    v_ld.actual_status[v_token_params.o_to_a[tok]][pos] = data
                if tok in v_token_params.a_to_o:
                    v_ld.actual_status[v_token_params.a_to_o[tok]][pos] = data

    print ("store",v_ld.actual_status)
    find_blocked_toks()
    return

def update_op_with_oo():
    oo_tok = v_ld.from_sk_to_ld[0]
    op_tok = v_announcelist.oo_ext[oo_tok]
    if op_tok in v_ld.actual_status:
        if v_announcelist.full[op_tok][2] == 1:
            # no stack
            i = 0
            j = 2
            while i < len(v_ld.from_sk_to_ld):
                v_ld.actual_status[op_tok][0][i] += v_ld.from_sk_to_ld[j]
                i += 1
                j += 3
        else:
            i = 0
            j = 2
            stack = v_ld.from_sk_to_ld[1]
            dimensions = (len(v_ld.from_sk_to_ld) - 2) / 3
            while i < dimensions:
                if v_ld.actual_status[op_tok][stack][i] == -1:
                    v_ld.actual_status[op_tok][stack][i] = 0
                adder = v_ld.from_sk_to_ld[j] * v_ld.from_sk_to_ld[j+ 1]
                if adder + v_ld.actual_status[op_tok][stack][i] < v_announcelist.max_oo[oo_tok][i]:
                    v_ld.actual_status[op_tok][stack][i] += adder
                else:
                    # loop or limt
                    if v_announcelist.loop_limit[oo_tok][i] == 0:
                        # LOOP
                        v = v_ld.actual_status[op_tok][stack][i] + v_ld.from_sk_to_ld[j] - v_announcelist.max_oo[oo_tok][i]
                        v_ld.actual_status[op_tok][stack][i] = v
                    else:
                        # LIMIT
                        v_ld.actual_status[op_tok][stack][i] = v_announcelist.max_oo[oo_tok][i]
                i += 1
                j += 3
    return

def send_direct_commands():
    if v_ld.direct_commands != []:
        # is HEX string: split to tok and data (CR do not check parameter)
        tok = v_ld.direct_commands[0][:v_announcelist.length_of_full_elements]
        data = v_ld.actual_status[tok][0][v_announcelist.length_of_full_elements:]
        v_ld.from_ld_to_dev = []
        v_ld.from_ld_to_dev.append(tok)
        v_ld.from_ld_to_dev.append(data)
        v_ld.direct_commands = v_ld.direct_commands[1:]
    return

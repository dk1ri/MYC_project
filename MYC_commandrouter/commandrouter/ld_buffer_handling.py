"""
name : ld_buffer_handling.py
last edited: 202512
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""

from time import sleep
from ld_misc import *
from misc_functions import *
import v_logicdevice
import v_ld

def ld_analyze():
    # the values of the transmitted data are checked by CR to be in the allowed range.
    # so check is not done
    # from_sk_to_dev:
    # if a command is blocked -> v_logicdevice.inputline = []
    # block: 0: no store, not in rules; 1: in rules, not blocked; true == 1: blocked
    if v_ld.from_sk_to_ld == [] and v_ld.from_dev_to_ld == []:
        return
    if v_ld.from_sk_to_ld != []:
        print ("from sk to ld")
        print (v_ld.from_sk_to_ld)
        v_ld.from_ld_to_dev = v_ld.from_sk_to_ld
        v_ld.from_sk_to_ld = []
        # analyze and update
    if v_ld.from_dev_to_ld == []:
        v_ld.from_ld_to_sk = v_ld.from_dev_to_ld
        v_ld.from_dev_to_ld = []
    return
        # analyze and update
    print (v_ld.from_dev_to_ld)
    print("from CR:" , v_logicdevice.inputline)
    s_or_d = v_logicdevice.inputline[0]
    if s_or_d != "s" and s_or_d != "u":
        v_logicdevice.inputline = []
        write_log("wrong s or d")
        return
    inputline = v_logicdevice.inputline[1:]
    if inputline[0] == "":
        v_logicdevice.inputline = []
        write_log("no tok")
        return
    update = 0
    blocked = 0
    tok_in_rules = 0
    tok = int(inputline[0], 16)
    inputline = inputline[1:]
    direct_commands = {}
    direct_command_index = 0
    # answer commands from Skin are forwarded, (no store no check)
    if tok in v_logicdevice.all_used_toks or v_logicdevice.all_by_index != {}:
        tok_in_rules = 1
        ct = v_logicdevice.ct[tok]
        if ct in v_logicdevice.s_r:
            # switches, range and "xa" only
            if ct[0] == "a" and s_or_d == "s":
                # answer commands from SK require no update
                if tok in v_logicdevice.left_tok_by_index:
                    i = 0
                    while i < len(v_logicdevice.left_tok_by_index):
                        if tok == v_logicdevice.left_tok_by_index[i]:
                            if parse_condition(i):
                                blocked = 1
                        i += 1
            else:
                # answers from device and operate commands from SK (data update)
                update = 1
            if s_or_d == "s":
                if tok in v_logicdevice.left_tok or v_logicdevice.all_by_index != {}:
                    # block SK commands only (answer and operate)
                    write_log("rulecheck for left tok")
                    rule_index = 0
                    enable = 1
                    true_ = 0
                    while rule_index < len(v_logicdevice.left_tok_by_index):
                        # all rules are used
                        if v_logicdevice.left_tok_by_index[rule_index] == "$~":
                            if parse_condition(rule_index):
                                enable = 0
                        elif v_logicdevice.left_tok_by_index[rule_index] == "!$~":
                            # not as last rule
                            if rule_index < len(v_logicdevice.left_tok_by_index) - 1:
                                if parse_condition(rule_index):
                                    enable = 1
                        else:
                            if enable:
                                # check all rules for actual tok
                                true = parse_condition(rule_index)
                                if v_logicdevice.if_unless[rule_index] == 1:
                                    # "UNLESS"
                                    # due to "OR" only with true == 0
                                    if  not true:
                                        true_ = 1
                                else:
                                    if true == 1:
                                        true_= 1
                                if not true_:
                                    j = rule_index + 1
                                    found = 1
                                    while j < len(v_logicdevice.left_tok_by_index) and found == 1:
                                        if rule_index in v_logicdevice.after_by_index:
                                            if parse_condition(rule_index):
                                                direct_commands[direct_command_index] = v_logicdevice.left_tok[j]
                                                direct_command_index += 1
                                            j += 1
                                            rule_index+= 1
                                        else:
                                            found = 0
                        rule_index += 1
                    if not enable or true_:
                        # not unblocked
                        blocked = 1
                        # blocked are not updated
                        update = 0
    # send direct commands once always (if condition is true)
    rule_index = 0
    while  rule_index < len(v_logicdevice.left_tok_by_index):
        if rule_index in v_logicdevice.direct_command_by_index:
            # direct commands are send if not blocked
            if parse_condition(rule_index):
                if v_logicdevice.command_sent_by_index[rule_index] == 0:
                    # not yet sent
                    if check_direct_command():
                        direct_commands[direct_command_index] = v_logicdevice.direct_command_by_index[rule_index]
                        direct_command_index += 1
                    v_logicdevice.command_sent_by_index[rule_index] = 1
            else:
                if v_logicdevice.command_sent_by_index[rule_index] == 1:
                    # renable
                    v_logicdevice.command_sent_by_index[rule_index] = 1
        rule_index += 1

    if tok_in_rules == 0:
        write_log ("tok not in rules")
  #      data_to_cr = v_logicdevice.inputline
    else:
        if direct_commands:
            i = 0
            while i < len(direct_commands):
                v_ld.data_to_cr = direct_commands[i]
                sleep(0.001)
                i += 1
        if blocked:
            # block
            write_log (str(tok) + " blocked")
        # else:
   #         data_to_cr = concat_send(v_logicdevice.inputline)
    if update == 1:
        # store new value
        store_data(tok, inputline)
        check_change_of_direct_command_condition(tok)
    v_logicdevice.inputline = []
    return


def parse_condition(rule_index):
    # check match of a rule
    condition_result = []
    condition_result.append(1)
    operator_stack = []
    actual = 0
    result = 0
    block_compare_by_ct = 0
    all_condition_per_index = v_logicdevice.all_condition_per_index[rule_index]
    for element_index in all_condition_per_index:
        # all conditions
        condition = all_condition_per_index[element_index]
        if condition[0] in v_logicdevice.condition_operators:
            match condition[0]:
                case "(":
                    condition_result.append(actual)
                    operator_stack.append("(")
                case ")":
                    pop_result = operator_stack.pop()
                    if pop_result != "(":
                        write_log("wrong operator stack")
                    else:
                        # the "old"data will be compared wil the actual
                        result = actual or condition_result.pop()
                        block_compare_by_ct = 1
                        actual , operator_stack = handle_operator_stack(all_condition_per_index, block_compare_by_ct, element_index, operator_stack, result, actual)
                    operator_stack.append(")")
                case "AND":
                    operator_stack.append("A")
                case "OR":
                    operator_stack.append("O")
                case "!":
                    operator_stack.append("!")
        else:
            actual, operator_stack = handle_operator_stack(all_condition_per_index, block_compare_by_ct, element_index, operator_stack, result, actual)
    true_ = actual
    return true_

def handle_operator_stack(all_condition_per_index, block_compare_by_ct, element_index,operator_stack, result, actual ):
    if block_compare_by_ct == 0:
        result = comapare_by_ct(all_condition_per_index[element_index])
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

def concat_send(data):
    # array to string
    i = 0
    string = ""
    while i < len(data):
        string += data[i]
        i += 1
    return string

def  check_change_of_direct_command_condition(tok):
    ct = v_logicdevice.ct[tok]
    match ct:
        case "os" | "as":
            # check change of condition for directcommand:
            i = 0
            while i < len(v_logicdevice.command_sent_by_index):
                if v_logicdevice.command_sent_by_index[i] == 1:
                    # these were sent and are blocke for resend
                    true = parse_condition(i)
                    if not true:
                        v_logicdevice.command_sent_by_index[i] = 0
                i += 1
    return

def comapare_by_ct(data_array):
    tok = data_array[0]
    line = v_logicdevice.announcelist_basic[tok].replace("\n", "")
    linex = line.split(";")
    ct = v_logicdevice.ct[tok]
    linex = linex[2:]
    true_ = 0
    # nothing done for "ou", "oo", "xm", "xn" and "xf"
    match ct:
        case "os" | "as":
            if int(linex[0]) == 1:
                # no stack
                is_value = v_logicdevice.value[tok]
                compare_value = calulate_compare_value(data_array[2])
                relation = data_array[1]
                true_ = compare(is_value, compare_value, relation)
            else:
                # for stack
                relation_location = data_array[1]
                compare_value_location = calulate_compare_value(data_array[2])
                relation = data_array[3]
                compare_value = calulate_compare_value(data_array[4])
                stack_no = 0
                stack = data_array[0]
                while not true_ and stack_no <= stack:
                    true, stack_no = comparelocation(stack_no, relation_location, compare_value_location)
                    if not true:
                        is_value = v_logicdevice.value[tok][stack_no]
                        true_ = compare(is_value, compare_value, relation)
                    stack_no += 1
        case "or" | "ar":
            if int(linex[0]) == 1:
                # no stack
                relation_location = data_array[1]
                compare_value_location = calulate_compare_value(data_array[2])
                relation = data_array[3]
                compare_value = calulate_compare_value(data_array[4])
                position_no = 0
                while not true_ and position_no <= len(linex) - 2:
                    continue_, position_no = comparelocation(position_no, relation_location, compare_value_location)
                    if not continue_:
                        is_value = v_logicdevice.value[tok][position_no]
                        true_ = compare(is_value, compare_value, relation)
                    position_no += 1
            else:
                # with stack
                relation_location = data_array[1]
                compare_value_location = calulate_compare_value(data_array[2])
                relation_location1 = data_array[3]
                compare_value_location1 = calulate_compare_value(data_array[4])
                relation = data_array[5]
                compare_value = calulate_compare_value(data_array[6])
                stack_no = 0
                continue_ = 1
                while not true_ and continue_ and stack_no <= len(linex) - 2:
                    continue_, stack_no = comparelocation(stack_no, relation_location, compare_value_location)
                    if not continue_:
                        position_no = 0
                        while not true_ and  position_no <= len(linex):
                            continue__, stack_no = comparelocation(position_no, relation_location1, compare_value_location1)
                            if not continue__:
                                is_value = v_logicdevice.value[tok][stack_no][position_no]
                                true_ = compare(is_value, compare_value, relation)
                            position_no += 1
                    stack_no += 1
        case "op" | "ap":
            if int(linex[0]) == 1:
                # no stack
                if len(linex) > 4:
                    # more dimensions
                    positionadder = calulate_compare_value(data_array[2])
                    compare_value = calulate_compare_value(data_array[4])
                    is_value = v_logicdevice.value[tok][positionadder]
                    relation = data_array[3]
                else:
                    compare_value = calulate_compare_value(data_array[2])
                    is_value = v_logicdevice.value[tok][0]
                    relation = data_array[1]
                true_ = compare(is_value, compare_value, relation)
            else:
                # for stack
                relation_location = data_array[1]
                compare_value_location = calulate_compare_value(data_array[2])
                stack_no = 0
                stack = data_array[0]
                while not true_ and stack_no <= stack:
                    continue_, stack_no = comparelocation(stack_no, relation_location, compare_value_location)
                    if not continue_:
                        # stack found
                        if len(linex) > 4:
                            # more dimensions
                            positionadder = calulate_compare_value(data_array[4])
                            compare_value = calulate_compare_value(data_array[6])
                            is_value = v_logicdevice.value[tok][stack_no][positionadder]
                            relation = data_array[5]
                        else:
                            compare_value = calulate_compare_value(data_array[4])
                            is_value = v_logicdevice.value[tok][stack_no][0]
                            relation = data_array[3]
                        true_ = compare(is_value, compare_value, relation)
                    stack_no += 1
        case "oa" | "aa":
            if len(linex) == 1:
                # one element
                relation = data_array[1]
                compare_value = calulate_compare_value(data_array[2])
                if tok in v_logicdevice.stringparameters:
                    data = v_logicdevice.value[tok][0]
                else:
                    data = v_logicdevice.value[tok][0]
                true_ = compare(data, compare_value, relation)
            else:
                position = calulate_compare_value(data_array[2])
                relation = data_array[3]
                compare_value = calulate_compare_value(data_array[4])
                data = v_logicdevice.value[tok][position]
                if type(data) == type(compare_value):
                    true_ = compare(data, compare_value, relation)
        case "oo" | "ou":
            # executed always
            true_ = 1
    return true_

def store_data(tok, inputline):
    line = v_logicdevice.announcelist_basic[tok].replace("\n", "")
    linex = line.split(";")
    ct = v_logicdevice.ct[tok]
    linex = linex[2:]
    # nothing done for "ou", "oo", "xm", "xn" and "xf"
    match ct:
        case "os" | "as":
            # less than 256 positions only
            if int(linex[0]) == 1:
                # no stack
                v_logicdevice.value[tok] = int(inputline[0],16)
                if tok in v_logicdevice.o_to_a:
                    v_logicdevice.value[v_logicdevice.o_to_a[tok]] = int(inputline[0],16)
                if tok in v_logicdevice.a_to_o:
                    v_logicdevice.value[v_logicdevice.a_to_o[tok]] = int(inputline[0],16)
            else:
                # with stack
                v_logicdevice.value[tok][int(inputline[0],16)] = int(inputline[1],16)
                if tok in v_logicdevice.o_to_a:
                    v_logicdevice.value[v_logicdevice.o_to_a[tok]][int(inputline[0],16)] = int(inputline[1],16)
                if tok in v_logicdevice.a_to_o:
                    v_logicdevice.value[v_logicdevice.a_to_o[tok]][int(inputline[0],16)] = int(inputline[1],16)
        case "or" | "ar":
            if int(linex[0]) == 1:
                # no stack
                v_logicdevice.value[tok][int(inputline[0],16)] = int(inputline[1],16)
                if tok in v_logicdevice.o_to_a:
                    v_logicdevice.value[v_logicdevice.o_to_a[tok]][int(inputline[0],16)] = int(inputline[1],16)
                if tok in v_logicdevice.a_to_o:
                    v_logicdevice.value[v_logicdevice.a_to_o[tok]][int(inputline[0],16)] = int(inputline[1],16)
            else:
                # with stack
                v_logicdevice.value[tok][int(inputline[0],16)][int(inputline[1],16)] = int(inputline[2],16)
                if tok in v_logicdevice.o_to_a:
                    v_logicdevice.value[v_logicdevice.o_to_a[tok]][int(inputline[0],16)][int(inputline[1],16)] = int(inputline[2],16)
                if tok in v_logicdevice.a_to_o:
                    v_logicdevice.value[v_logicdevice.a_to_o[tok]][int(inputline[0],16)][int(inputline[1],16)] = int(inputline[2],16)

        case "op" |"ap":
            if int(linex[0]) == 1:
                # no stack
                k = 0
                while k < len(inputline):
                    # all values
                    v_logicdevice.value[tok][k] = int(inputline[k], 16)
                    if tok in v_logicdevice.o_to_a:
                        v_logicdevice.value[v_logicdevice.o_to_a[tok]][k] = int(inputline[k], 16)
                    if tok in v_logicdevice.a_to_o:
                        v_logicdevice.value[v_logicdevice.a_to_o[tok]][k] = int(inputline[k], 16)
                    k += 1
            else:
                # with stack
                k = 0
                while k < len(inputline) - 1:
                    v_logicdevice.value[tok][int(inputline[0])][k] = int(inputline[k + 1], 16)
                    if tok in v_logicdevice.o_to_a:
                        v_logicdevice.value[v_logicdevice.o_to_a[tok]][int(inputline[0])][k] = int(inputline[k + 1], 16)
                    if tok in v_logicdevice.a_to_o:
                        v_logicdevice.value[v_logicdevice.a_to_o[tok]][int(inputline[0], 16)][k] = int(inputline[k + 1], 16)
                    k += 1

        case "oa" | "aa":
            if len(linex) == 1:
                # one element only
                if tok in v_logicdevice.stringparameters:
                    data = concat(inputline)
                    v_logicdevice.inputline = "s" + data
                else:
                    data = int(inputline[0], 16)
                v_logicdevice.value[tok][0] = data
                if tok in v_logicdevice.o_to_a:
                    v_logicdevice.value[v_logicdevice.o_to_a[tok]][0] = data
                if tok in v_logicdevice.a_to_o:
                    v_logicdevice.value[v_logicdevice.a_to_o[tok]][0] = data
            else:
                pos = int(inputline[0], 16)
                if tok in v_logicdevice.stringparameters:
                    data = concat(inputline[1:])
                    v_logicdevice.inputline = "s" + data
                else:
                    data = int(inputline[1], 16)
                v_logicdevice.value[tok][pos] = data
                if tok in v_logicdevice.o_to_a:
                    v_logicdevice.value[v_logicdevice.o_to_a[tok]][pos] = data
                if tok in v_logicdevice.a_to_o:
                    v_logicdevice.value[v_logicdevice.a_to_o[tok]][pos] = data

  #  print (v_logicdevice.value)
    return


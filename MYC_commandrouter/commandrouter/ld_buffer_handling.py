"""
name : ld_buffer_handling.py
last edited: 20260414
Copyright : DK1RI
If no other rights are affected, this programmcan be used under GPL (Gnu public licence)
"""
import buffer_handling
import v_configparameter
import v_ld
import v_announcelist
import misc_functions
import v_token_params
import v_sk

def ld_analyze():
    # the values of the transmitted data are checked by CR to be in the allowed range.
    # so check is not done
    # b,m, n, f commands will have no data in v_sk.orig_to_ld
    # input_as_parameter_list is list of parameters (int or string)
    # function:
    # find rules to block
    # find corresponding tok
    # block tok or not
    # if not: store and find new blocked toks
    if v_sk.orig_to_ld == []:
       # v_ld.from_ld_to_dev = v_sk.orig_to_ld
      #  v_sk.orig_to_ld = []
        return
    tok = int.from_bytes(v_sk.orig_to_ld[:v_announcelist.length_of_full_elements])
    # check all rules
    if v_configparameter.test_mode == 1:
        print("for LD", v_sk.orig_to_ld)
    skip_rule = 0
    # more than one rules may be blocking, collect all
    block3_rule_index = []
    blocking_rules = []
    for rule_index in v_ld.all_condition_per_index:
        match v_ld.ruleindex_typ[rule_index]:
            case 0:
                # tilde
                if v_ld.blocked_rule_index[rule_index] == 1:
                    skip_rule = 1
            case 1:
                # not tilde
                if v_ld.blocked_rule_index[rule_index] == 1:
                    skip_rule = 0
            case 2:
                # normal command
                if skip_rule == 0 and v_ld.blocked_rule_index[rule_index] == 1:
                    blocking_rules.append(rule_index)
            case 3:
                # command to block
                if skip_rule == 0 and v_ld.blocked_rule_index[rule_index] == 1:
                        block3_rule_index.append(rule_index)
    blocked = 0
    for rule_index in blocking_rules:
        if v_ld.left_tok_by_index[rule_index] == str(tok):
            blocked = 1
    for rule_index in block3_rule_index:
        if v_ld.left_tok_by_index[rule_index] == v_sk.orig_to_ld:
            blocked = 1

    i = 0
    while i < len(block3_rule_index) and not blocked:
        if v_sk.orig_to_ld == v_ld.left_tok_by_index[block3_rule_index[i]]:
            blocked = 1
        i +=1
    if blocked == 0:
        if v_configparameter.test_mode == 1:
            print(" not blocked", tok)
        # update for oo command
        if v_announcelist.full[tok][1] == "oo":
            update_op_with_oo()
        v_ld.from_ld_to_dev = v_sk.orig_to_ld
        # store if tok in right side and update blocked ruleindices
        store_data(tok, v_sk.input_as_parameter_list)
    else:
        if v_configparameter.test_mode == 1:
            print("blocked", tok)
    v_sk.orig_to_ld = []
    v_sk.input_as_parameter_list = []

    # commands_to execute?
    for rule_index in v_ld.all_condition_per_index:
        match v_ld.ruleindex_typ[rule_index]:
            case 0:
                # tilde
                if v_ld.blocked_rule_index[rule_index] == 1:
                    skip_rule = 1
            case 1:
                # not tilde
                if v_ld.blocked_rule_index[rule_index] == 1:
                    skip_rule = 0
            case 4:
                # command to execute
                if skip_rule == 0:
                    if v_ld.blocked_rule_index[rule_index] == 1:
                        if v_ld.direct_command_to_sent[rule_index] == 0:
                            v_ld.direct_commands.append(rule_index)
                            v_ld.direct_command_to_sent[rule_index] = 1
                    else:
                        v_ld.direct_command_to_sent[rule_index] = 0

    return

def store_data(tok, inputline):
    if not tok in v_ld.right_tok:
        return
    # only, if tok in right side
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
                # no stack, onr parameter only
                v_ld.actual_status[tok] = [inputline[0]]
            else:
                # with stack
                stack = inputline[0]
                value = inputline[1]
                v_ld.actual_status[tok][stack] = value
        case "or" | "ar":
            if int(announce_line_tok[2]) == 1:
                # no stack
                pos = inputline[0]
                value = inputline[1]
                v_ld.actual_status[tok][pos] = value
            else:
                # with stack
                stack = inputline[0]
                pos = inputline[1]
                value = inputline[2]
                v_ld.actual_status[tok][stack][pos] = value

        case "op" |"ap":
            if int(announce_line_tok[2]) == 1:
                # no stack
                k = 0
                while k < len(inputline):
                    # all values
                    v_ld.actual_status[tok][k] = inputline[k]
                    k += 1
            else:
                # with stack
                k = 1
                while k < len(inputline):
                    v_ld.actual_status[tok][int(inputline[0])][k - 1] = inputline[k]
                    k += 1

        case "oa" | "aa":
            if len(announce_line_tok) == 3:
                # one parameter
                c_type, length, c = misc_functions.length_of_typ(v_announcelist.full[tok][2])
                v_ld.actual_status[tok][0] = store_oa_aa_(c_type, inputline[0])
            else:
                # more parameters
                pos = int(inputline[0])
                c_type, length, c = misc_functions.length_of_typ(v_announcelist.full[tok][2 + pos])
                # limitation: 255 elements
                v_ld.actual_status[tok][pos] = store_oa_aa_(c_type, inputline[1])

    if tok in v_token_params.o_to_a:
        v_ld.actual_status[v_token_params.o_to_a[tok]] = v_ld.actual_status[tok]
    if tok in v_token_params.a_to_o:
        v_ld.actual_status[v_token_params.a_to_o[tok]] = v_ld.actual_status[tok]
    if v_configparameter.test_mode == 1:
        print("st_out",v_ld.actual_status)
    find_blocking_rules(tok)
    return

def find_blocking_rules(tok):
    # find all blocking rules by comparing status with right side containing actual tok
    # other rules are not modified
    for rule_index in v_ld.ruleindices_by_rtok[tok]:
        blocked = parse_conditions(v_ld.all_condition_per_index[rule_index])
        if v_ld.if_unless[rule_index] == 1:
            # "UNLESS"
            if blocked:
                blocked = 0
            else:
                blocked = 1
        v_ld.blocked_rule_index[rule_index] = blocked
    if v_configparameter.test_mode == 1:
        print("blocking rules: ",v_ld.blocked_rule_index)
    return

def parse_conditions(full_condition):
    # check match of a rule
    operator_stack = []
    actual = 0
    element_index = 0
    while element_index < len(full_condition):
        # all conditions of a rule
        condition = full_condition[element_index]
        if condition in v_ld.condition_operators:
            match condition:
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
            match_ = check_match_data(condition[1], condition[3], stat[0])
        case 2:
            # os with stack, or no stack ; 2 transmitted parameters
            max_ = v_announcelist.full[ctok][2]
            match_ = condition2(condition, stat, int(max_))
        case 3:
            # or with stack
            max_stack = int(v_announcelist.full[ctok][2])
            # - tok, -ct, - stack
            max_pos = len(v_announcelist.full[ctok]) - 3
            match_ = condition_3(condition, stat, max_stack, max_pos)
        case 4:
            # op no stack
            match_ = condition_4(condition)
        case 5:
            # op with stack
            max_stack = int(v_announcelist.full[ctok][2])
            match_ = condition_5(condition, stat, max_stack)
        case 10:
            # "oa" one parameter
            match_ = condition_6(condition, 0)
        case 11:
            # "oa" more parameters
            match_ = condition_6(condition, 1)
    return match_

def check_match_data(operator, compare_value, status):
    # position matched. now check last value (data)
    # for one (fixed) status
    match_ = 0
    _invalue = 0
    if compare_value == "~":
        match_ = 1
        _invalue = 1
    elif type(compare_value) is str:
        # string
        if "TO" in compare_value:
            compare_val = compare_value.split("TO")
            # disregard operator
            from_ = int(compare_val[0])
            to_ = int(compare_val[1])
            # _ may be part of string
            if from_.is_integer() and to_.is_integer():
                if from_ <= status <= to_:
                    if operator == "=":
                        match_  = 1
                        _invalue = 1
                    elif operator == "!" :
                        match_ = 0
                        _invalue = 1
                    else:
                        pass
            else:
                # string
                if compare_value == status:
                    match_ = 1
                    _invalue = 1
        else:
            # normal string
            if compare_value == status:
                match_ = 1
    else:
       pass

    if _invalue == 0:
        # numeric
        if operator == "=":
            if compare_value == status:
                match_ = 1
        elif operator == "<":
            if 0 <= status < compare_value:
                match_ = 1
        elif operator == ">":
            if status > compare_value:
                match_ = 1
        elif operator == "!":
            if compare_value != status:
                match_ = 1
    return match_

def condition2(condition, status_for_tok, max_):
    # os with stack, or no stack ; 2 transmitted parameters
    match_ = 1
    i = 0
    # all stacks must match
    if condition[3] == "~":
        while i < max_ and match_ == 1:
            match_ = check_match_data(condition[4], condition[6], status_for_tok[i])
            i += 1
    elif type(condition[3]) is str:
        # must contain "TO" (no string with stacks)
        # ignore condition{1] (compare operator)
        from_ = condition[3].split("TO")[0]
        if len(condition[3].split("TO")) > 1:
            to_ = int(condition[3].split("TO")[1])
            i = int(from_)
            while i <= to_ and match_ == 1:
                match_ = check_match_data(condition[4], condition[6], status_for_tok[i])
                i += 1
    else:
        # numeric
        match condition[1]:
            # operator for stack
            case "=":
                # all_params[3]is pos of actual_data to match
                match_ = check_match_data(condition[4], condition[6], status_for_tok[condition[3]])
            case "<":
                i = 0
                while i < int(condition[3]) and match_ == 1:
                    match_ = check_match_data(condition[4], condition[6], status_for_tok[i])
                    i += 1
            case ">":
                i = int(condition[3] + 1)
                while i < max_ and match_ == 1:
                    match_ = check_match_data(condition[4], condition[6], status_for_tok[i])
                    i += 1
            case "!":
                i = 0
                while i < max_ and match_ == 1:
                    if i != condition[3]:
                        match_ = check_match_data(condition[4], condition[6], status_for_tok[i])
                    i += 1
    return match_

def condition_3(condition, status_for_tok, max_stack, max_pos):
    # or with stack
    match_ = 1
    i = 0
    stack = condition[3]
    if stack == "~":
        while i < max_stack  and match_ == 1:
            match_ = check_match_data(condition[4], condition[6], status_for_tok[i])
            i += 1
    elif type(stack) is str:
        # must contain "TO" (no string with stacks)
        # ignore condition{1] (compare operator)
        from_ = condition[3].split("TO")[0]
        if len(stack.split("TO")) > 1:
            to_ = int(stack.split("TO")[1])
            i = int(from_)
            while i <= to_ and match_ == 1:
                match_ = condition3_pos(i, condition, status_for_tok, max_pos)
                i += 1
    else:
        # numeric
        # relation for stack
        stack = int(stack)
        match condition[1]:
            case "=":
                #       condition3_pos stack pos all_params...
               match_ = condition3_pos(stack, condition, status_for_tok, max_pos)
            case "<":
                i = 0
                while i < stack and match_ == 1:
                    match_ = condition3_pos(i, condition, status_for_tok, max_pos)
                    i += 1
            case ">":
                i = stack + 1
                while i < max_stack and match_ == 1:
                    match_ = condition3_pos(i, condition, status_for_tok, max_pos)
                    i += 1
            case "!":
                i = 0
                while i < max_stack and match_ == 1:
                    if i != stack:
                        match_ = condition3_pos(i, condition, status_for_tok, max_pos)
                    i += 1
    return match_

def condition3_pos(stack, condition, status_for_tok, max_pos):
    # for or with stack
    match_ = 1
    i = 0
    position = condition[6]
    if position == "~":
        while i < max_pos and match_ == 1:
            match_ = check_match_data(condition[7], condition[9], status_for_tok[i])
            i += 1
    elif type(position) is str:
        # must contain "TO" (no string with stacks)
        # ignore condition{1] (compare operator)
        from_ = position.split("TO")[0]
        if len(position.split("TO")) > 1:
            to_ = int(position.split("TO")[1])
            i = int(from_)
            while i <= to_ and match_ == 1:
                match_ = check_match_data(condition[7], condition[9], status_for_tok[stack][i])
                i += 1
    else:
        # numeric
        # relation for position
        match condition[4]:
            case "=":
                match_ = check_match_data(condition[7], condition[9], status_for_tok[stack][condition[6]])
            case "<":
                i = 0
                while i < int(condition[6]) and match_ == 1:
                    match_ = check_match_data(condition[7], condition[9], status_for_tok[stack][i])
                    i += 1
            case ">":
                i = int(condition[6] + 1)
                while i < max_pos and match_ == 1:
                    match_ = check_match_data(condition[7], condition[9], status_for_tok[stack][i])
                    i += 1
            case "!":
                i = 0
                while i < max_pos and match_ == 1:
                    if i != condition[5]:
                        match_ = check_match_data(6, condition[9], status_for_tok[stack][i])
                    i += 1
    return match_

def condition_4(condition):
    # op cammand no stack
    # tok for this condition
    ctok = condition[0]
    status = v_ld.actual_status[ctok]
    match_ = all_dimensions(condition, status, 0)
    return match_

def all_dimensions(condition, status, stack_adder):
    i = 0
    match_ = 1
    while i < len(status) and match_ == 1:
        # used for op commands one dimension
        operator = condition[1 + stack_adder + 3 * i]
        compare_value =  condition[3 + stack_adder + 3 * i]
        match_ = 0
        _invalue = 0
        if compare_value == "~":
            match_ = 1
        elif type(compare_value) is str:
            # has TO always
            compare_val = compare_value.split("TO")
            # disregard operator
            from_ = int(compare_val[0])
            to_ = int(compare_val[1])
            # may be wrong
            if from_.is_integer() and to_.is_integer():
                if from_ <= status[i] <= to_:
                    match_ = 1
                else:
                    match_ = 0
            else:
                match_ = 0
        else:
            # numeric
            if operator == "=":
                if compare_value == status[i]:
                    match_ = 1
            elif operator == "<":
                if 0 <= status[i]< compare_value:
                    match_ = 1
            elif operator == ">":
                if status[i] > compare_value:
                    match_ = 1
            elif operator == "!":
                if compare_value != status[i]:
                    match_ = 1
        i += 1
    return match_

def condition_5(condition, status, max_stack):
    # op cammand with stack
    match_ = 1
    if condition[3] == "~":
        i = 0
        while i < max_stack and match_ == 1:
            match_ = all_dimensions(condition, status, 3)
            i += 1
    elif type(condition[3]) is str:
        # stack contain "TO"
        # ignore rlation operator -> "=" always
        all_params_spltted = condition[3].split("TO")
        stack = int(all_params_spltted[0])
        while stack <= int(all_params_spltted[1]) and match_ == 1:
            match_ = all_dimensions(condition, status[stack], 3)
            stack += 1
    else:
        # comparator of stack
        match condition[1]:
            case "=":
            #    match_ = condition_55(condition[4], condition[6], stat[condition[3][condition[6]], dimensions
                match_ = all_dimensions(condition, status[int(condition[3])], 3)
            case "<":
                stack = 0
                while stack < int(condition[3]) and match_ == 1:
                    match_ = all_dimensions(condition, status[stack], 3)
                    stack += 1
            case ">":
                stack = int(condition[3]) + 1
                while stack < max_stack and match_ == 1:
                    match_ = all_dimensions(condition, status[stack], 3)
                    stack += 1
            case "!":
                stack = 0
                while stack < max_stack and match_ == 1:
                    if stack != int(condition[3]):
                        match_ = all_dimensions(condition, status[stack], 3)
                    stack += 1
    return match_

def condition_6(condition, more_than_one):
    # oa
    tok = condition[0]
    if more_than_one == 0:
        match_ = 0
        # one parameter
        if len(condition) > 4:
            # string with length
            if len(v_ld.actual_status[tok][0]) == condition[3]:
                #number of character matches
                match_ = check_match_data(condition[1], condition[6], v_ld.actual_status[tok][0])
        else:
            # one numeric
            match_ = check_match_data(condition[1], condition[3], v_ld.actual_status[tok][0])
    else:
        # more parameters
        match_ = 1
        # position
        if type(condition[3]) is str:
            # must be mTOn
            from_ = int(condition[3].split("TO")[0])
            to_ = int(condition[3].split("TO")[1])
            i = from_
            while i <= to_ and match_ == 1:
                match_ =condition_6x(condition, v_ld.actual_status[tok][i])
                i += 1
        else:
            match condition[1]:
                case "=":
                    match_ = condition_6x(condition, v_ld.actual_status[tok][condition[3]])
                case "<":
                    i = 0
                    while i <= condition[3] and match_ == 1:
                        match_ = condition_6x(condition, v_ld.actual_status[tok][i])
                        i += 1
                case "<":
                    i = condition[3]
                    while i < len(v_ld.actual_status) and match_ == 1:
                        match_ = condition_6x(condition, v_ld.actual_status[tok][i])
                        i += 1
                case "!":
                    i = 0
                    while i < len(v_ld.actual_status) and match_ == 1:
                        match_ = condition_6x(condition, v_ld.actual_status[tok][i])
                        i += 1
    return match_

def condition_6x(condition, status):
    match_ = 0
    if len(condition) > 7:
        # string
        if len(status) == condition[6]:
            # len matches
            match_ = check_match_data(condition[7], condition[9], status)
    else:
        # numeric
        match_ = check_match_data(condition[4], condition[6], status)
    return match_

def store_oa_aa_(c_type, inputline,):
    if c_type == "s":
        # string
        data = ""
        i = 0
        while i < len(inputline):
            data += chr(inputline[i])
            i += 1
    else:
        # numeric
        # inputline is int ?
    #    i = 0
     #   data = 0
      #  while i < len(inputline):
       #     data = data * 256
        #    data += inputline[i]
         #   i += 1
        data = inputline
    return data

def update_op_with_oo():
    oo_tok = v_sk.orig_to_ld[0]
    op_tok = v_announcelist.oo_ext[oo_tok]
    if op_tok in v_ld.actual_status:
        if int(v_announcelist.full[op_tok][2]) == 1:
            # no stack
            i = 0
            j = 0
            while j < len(v_sk.orig_to_ld) - 1:
                v_ld.actual_status[op_tok][i] = update_op_with_oo2(j, v_ld.actual_status[op_tok][i],v_announcelist.max_oo[oo_tok][i],v_announcelist.loop_limit[oo_tok][i])
                i += 1
                j += 4
        else:
            # with stack
            i = 0
            j = 1
            stack = v_sk.orig_to_ld[1]
            while j < len(v_sk.orig_to_ld) - 2:
                v_ld.actual_status[op_tok][stack][i]= update_op_with_oo2(j, v_ld.actual_status[op_tok][stack][i], v_announcelist.max_oo[oo_tok][i], v_announcelist.loop_limit[oo_tok][i])
                i += 1
                j += 4
    return

def update_op_with_oo2(j, actual, max_, limit):
    if actual == -1:
        actual = 0
    adder = v_sk.orig_to_ld[j + 1] * v_sk.orig_to_ld[j + 2]
    if v_sk.orig_to_ld[j + 4] == 1:
        adder = -adder
    temp_actual = adder + actual
    if 0 <= temp_actual <= max_:
        actual = temp_actual
    else:
        if temp_actual < 0:
            actual = max_ + adder
        else:
            # loop or limit
            if limit == 0:
                # LOOP
                actual = temp_actual - max_
            else:
                # LIMIT
                actual = max
    return actual

def send_direct_commands():
    if v_ld.direct_commands != []:
        # complete string as transmit data
        if v_ld.from_ld_to_dev == []:
            i = 0
            while i < len(v_ld.direct_commands):
                j = 0
                while j < len(v_ld.left_tok_by_index[v_ld.direct_commands[0]]):
                    v_ld.from_ld_to_dev.append(v_ld.left_tok_by_index[v_ld.direct_commands[0]][j])
                    j += 1
                buffer_handling.send_to_device()
                i += 1
            v_ld.direct_commands = []
    return

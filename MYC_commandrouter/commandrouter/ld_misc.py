"""
name : ld_misc.py
last edited: 20250309
other misc functions
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""

import v_logicdevice

def create_update(tok):
    v_logicdevice.updated[tok] = 0
    if tok in v_logicdevice.o_to_a:
        v_logicdevice.updated[v_logicdevice.o_to_a[tok]] = 0
    if tok in v_logicdevice.a_to_o:
        v_logicdevice.updated[v_logicdevice.a_to_o[tok]] = 0
    return

def create_value0(tok):
    if not tok in v_logicdevice.value:
        v_logicdevice.value[tok] = {}
    return

def create_value1(tok,i):
    if not i in v_logicdevice.value[tok]:
        v_logicdevice.value[tok][i] = {}
    return

def find_tok(condition):
    tok = ""
    i = 0
    while i < len(condition) and not (condition[i] in v_logicdevice.all_operators):
        if condition[i] != " ":
            tok += condition[i]
        i += 1
    try:
        return int(tok), condition[i:]
    except:
        return tok, condition[i:]

def calulate_compare_value(data_array):
    # calculation missing
    value = data_array[0]
    return value


def compare (is_value, compare_value, relation):
    true_ = 0
    try:
        # relation is the low value of range
        if is_value <= is_value <= compare_value:
            true_ = 1
    except:
        if relation == "<" and is_value < compare_value:
            true_ = 1
        if relation == ">" and is_value > compare_value:
            true_ = 1
        if relation == "=" and is_value == compare_value:
            true_ = 1
    return true_


def comparelocation(i, relation_location, compare_value_location):
    # default: continue
    continu = 1
    if relation_location in v_logicdevice.relational_operators:
        if compare_value_location == "~":
            # continue
            continu = 0
        elif  relation_location == "=":
            if i == compare_value_location:
                # stop with compare_value_location
                continu = 0
        elif  relation_location == ">":
            if i < compare_value_location:
                # continue with this value
                i = compare_value_location
                continu = 1
        elif  relation_location == "<":
            if i > compare_value_location:
                # stop with this value
                i = compare_value_location
                continu= 0
    else:
        if i < relation_location:
            i = relation_location
            continu = 0
        elif i > relation_location:
            continu = 0
    return continu, i

def check_direct_command():
    true = 1
    ##################################################################
    return true


def concat(data):
    # array to string
    i = 0
    string = ""
    while i < len(data):
        string += chr(int(data[i], 16))
        i += 1
    return string
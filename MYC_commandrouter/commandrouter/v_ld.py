""""
name: v_ld.py
last edited: 20260414
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
parameters for LD
"""

from_ld_to_dev = []                 # data from LD to device vis CR
from_ld_to_sk = []                  # data from LD to SK vis CR

blocked_rule_index = {}             # ruleindices refer to tok, direct command to execute or direct command to
                                    # blocked either true or false
                                    # at start nothing is blocked

left_tok_by_index = {}              # left tok by index
right_tok = []                      # all tok usd on right side
if_unless = {}                      # 0: IF, 1:UNLESS
ruleindex_typ = {}                  # left side of rule is 0: tilde 1: not_tilde, 2 normal command
                                    # 3: command to block 4: command to execute
updated = {}                        # [command_token.d] valid_actual_values
actual_status = {}                          # actual values, updated with each input
                                    # array with 4 levels (subarrays)
                                    # 1. level: tok
                                    # 2. level: position
                                    # content: data
all_condition_per_index = {}        # per ruleindex: list of rule_elements (as for 2=1 AND ...)
                                    # rule_element: list: right_tok position relation value or tok operator tok....
command_sent_by_index = {}          # for rules sending commands: 0: idle: 1: command sent, wait for change
stringparameters = {}               # tok and position for "xa" commands with string
index_by_tok = {}                   # all ruleindices for a left side tok
#tok_by_ruleindex = {}               # inverse
direct_commands = []                # direct commands are send not together with others
direct_command_to_sent = {}         # senf only once
ld_type_by_rtok = {}                # speed up calculation of condition_elements (depend on tok)
ruleindices_by_rtok = {}            #list of affected ruleindices for all tok of the right side

s_r_p_a_dev = ["os", "as", "or", "ar", "op", "ap", "oa", "aa", "at","rs", "ss", "rr", "sr", "rp", "sp", "ra", "sa","st"]
s_r_p_a_sk = ["os", "or", "op", "oa", "oo","rs", "rr", "rp", "ra", " ro"]
s_r = ["os", "as", "or", "ar", "ou","rs", "ss", "rr", "sr", "ru"]
relational_operators = ["<", ">", "=", "!"]
condition_operators = ["!", "OR", "AND","(", ")"]
all_operators = ["<", ">", "=", "*", "~", "+", "-", " ", "$", "&","<", ">", "=", "(", ")", "T"]
logical_operarors = ["AND", "NOT"]
arithmetic_operators = ["+", "-", "*", "/"]
compare_operator = ["IF", "UNLESS"]


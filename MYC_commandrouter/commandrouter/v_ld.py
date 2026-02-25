""""
name: v_ld.py
last edited: 20260224
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
parameters for LD
"""

from_dev_to_ld = []                 # data from device via CR
from_ld_to_dev = []                 # data from LD to device vis CR
from_sk_to_ld = []                  # data from SK via CR
from_ld_to_sk = []                  # data from LD to SK vis CR
data_to_cr = []                     # data to CR, info or command

blockd_toks = []                    # toks blocked by rules, updated after each update of status
all_used_toks = {}                  # tok used by LD only

left_tok_by_index = {}              # left tok by index
left_tok = {}
right_tok = []                      # all tok usd on right side
if_unless = {}                      # 0: IF, 1:UNLESS
direct_command_by_index = {}        # send command und condition
updated = {}                        # [command_token.d] valid_actual_values
actual_status = {}                          # actual values, updated with each input
                                    # array with 4 levels (subarrays)
                                    # 1. level: tok
                                    # 2. level: position
                                    # content: data
all_condition_per_index = {}        # per index: array of conditions: array: right_tok position relation value or tok operator tok....
index_of_tilde = []                 # !$~
index_of_not_tilde = []             # !!$~
command_sent_by_index = {}          # for rules sending commands: 0: idle: 1: command sent, wait for change
stringparameters = {}               # tok and position for "xa" commands with string
index_by_tok = {}                   # all ruleindices for a left side tok
tok_by_ruleindex = {}               # inverse
direct_commands = []                # dirct commands are send not together with others
ld_type_by_rtok = {}                # speed up calculation of condition_elements ( depend on tok)

s_r_p_a_dev = ["os", "as", "or", "ar", "op", "ap", "oa", "aa", "at","rs", "ss", "rr", "sr", "rp", "sp", "ra", "sa","st"]
s_r_p_a_sk = ["os", "or", "op", "oa", "oo","rs", "rr", "rp", "ra", " ro"]
s_r = ["os", "as", "or", "ar", "ou","rs", "ss", "rr", "sr", "ru"]
relational_operators = ["<", ">", "=", "!"]
condition_operators = ["!", "OR", "AND","(", ")"]
all_operators = ["<", ">", "=", "*", "~", "+", "-", " ", "$", "&","<", ">", "=", "(", ")", "T"]
logical_operarors = ["AND", "NOT"]
arithmetic_operators = ["+", "-", "*", "/"]
compare_operator = ["IF", "UNLESS"]


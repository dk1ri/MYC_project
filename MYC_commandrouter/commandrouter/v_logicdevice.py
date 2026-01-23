""""
name: v_ld.py
last edited: 202512
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
parameters for LD
"""

inputline = []                      # input buffer
# length_commandtoken = 1             # length_of_commandtoken
left_tok_by_index = {}              # left tok by index
left_tok = {}
#a_to_o = {}                         # reference of answer to corresponding operating command
# o_to_a = {}                         #reverse
#all_used_toks = {}                  # all toks used in rules
if_unless = {}                      # 0: IF, 1:UNLESS, 2 AFTER
direct_command_by_index = {}                 # send command und condition
updated = {}                        # [command_token.d] valid_actual_values
value = {}                          # actual values, updated with each input
                                    # array with 4 levels (subarrays)
                                    # 1. level: tok
                                    # 2. level: position
                                    # content: data
ct = {}                             # commandtype of tok
all_condition_per_index = {}        # per index: array of conditions: array: right_tok position relation value or tok operator tok....
after_by_index = {}                 #
all_by_index = {}                   # !$~
not_all_by_index = {}               # !!$~
command_sent_by_index = {}          # for rules sending commands: 0: idle: 1: command sent, wait for change
stringparameters = {}               # tok and position for "xa" commands with string

#kbd_data = ""                                   # a: string from keyboard
#kbd_started  = ""
#kbd_line = []

s_r = ["os", "as", "or", "ar", "op", "ap", "oa", "aa", "oo", "ou"]
relational_operators = ["<", ">", "="]
condition_operators = ["!", "OR", "AND","(", ")"]
all_operators = ["<", ">", "=", "*", "~", "+", "-", " ", "$", "&","<", ">", "=", "(", ")", "T"]
logical_operarors = ["AND", "NOT"]
arithmetic_operators = ["+", "-", "*", "/"]
compare_operator = ["IF", "UNLESS", "AFTER", "IN"]
command_types = ["a", "b", "c", "i", "w", "k", "l", "L", "e", "t", "u", "d"]


""""
name: v_announcelist.py
last edited: 201803
the 3 announcement lists
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""
a_to_o = {}
o_to_a = {}
all_token = []
full = {}						    # full announcelist, all elements called by int(tok)
                                    # stripped announceline (no <des> or CHAPTER )
full_240 = []						# full announcelist, elements called by index only
basic = []                          # basic announcelist, elements called by index only
rules = []							# rules announcelist, elements called by index only
administration = []                 # admin lines, called by index inly
full_elements = 0                   # number of full announcelist
length_of_full_elements = 0         # length of this (is CR token length)
full_elements_240 = 0               # number of full announcelist
length_of_full_elements_240 = 0     # length of this
basic_elements = 0                  # number of basic announcelist
length_of_basic_elements = 0        # length of this
rules_elements = 0                  # number of rules announcelist
length_of_rules_elements = 0        # length of this
admin_elements = 0
length_of_admin_elements = 0
start_of_reserved_token = 0xf0
start_of_cr_token = 1               # &H01, &H01000, &H010000,
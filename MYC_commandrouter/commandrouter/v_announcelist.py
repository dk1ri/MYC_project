""""
name: v_announcelist.py
last edited: 20260414
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
"""
all_token = []
all_answer_token = []               # answrs commands
full = {}						    # full announcelist, all elements called by int(tok)
                                    # stripped announceline (no <des> or CHAPTER )
full_240 = []						# full announcelist, complete line, called by index for distribution
basic = {}                          # basic announcelist, complete line, called by int(tok) for distribution
rules = []							# list of rules
administration = []                 # list of admin lines
cr_token = [0]                      # toks of toks handled by CR
basic_token = []                    # toks of basic announcements
full_elements = 0                   # number of lines of full announcelist, used for distribution to SK (-> complete with other_lines: R; L; etc)
                                    # + CR lines
length_of_full_elements = 0         # length of this (is CR token length)
full_elements_240 = 0               # number of lines of full announcelist
basic_elements = 0                  # number of lines of basic announcelist
other_lines_elements = 0            # number of lines of otherlines
rules_elements = 0                  # number lines of rules list
admin_elements = 0                  # number lines of admin list
start_of_reserved_token = 0xf0
start_of_cr_token = 1               # &H01, &H01000, &H010000,
oo_ext = {}                         # used by LD to find oo command
loop_limit = {}                     # 0: LOOP 1 : LIMIT of oo commands
max_oo = {}                         # max of value of corresponding op command
string_length_ab = {}               # length of stringlength for xa xb commands
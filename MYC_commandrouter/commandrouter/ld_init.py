"""
name : ld_init.py
last edited: 20260414
Copyright : DK1RI
If no other rights are affected, this program can be used under GPL (Gnu public licence)
------------------------------------------------
read_my_devices at start and from time to time
------------------------------------------------
"""
from misc_functions import *
import v_announcelist
import v_ld

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
                if not l_type in v_cr_params.command_types:
                    if position == "":
                        v_ld.stringparameters[tok] = {}
                        position = 0
                    v_ld.stringparameters[tok][position] = position
                    position += 1
                i += 1
    return

def create_ld_type_for_right_side_tok():
    for rtok in v_ld.right_tok:
        ct = v_announcelist.full[rtok][1].split(",")[0]
        match ct:
            case "os" | "as"  "rs" | "ss":
                if v_announcelist.full[rtok][2] == "1":
                    # os no stack
                    v_ld.ld_type_by_rtok[rtok] = 1
                else:
                    # with stack
                    v_ld.ld_type_by_rtok[rtok] = 2
            case "or" | "ar" | "rr" | "sr":
                if v_announcelist.full[rtok][2] == "1":
                    # or no stack
                    v_ld.ld_type_by_rtok[rtok] = 2
                else:
                    # with stack
                    v_ld.ld_type_by_rtok[rtok] = 3
            case "op" | "ap" | "rr" | "sp":
                if v_announcelist.full[rtok][2] == "1":
                    # or no stack
                    v_ld.ld_type_by_rtok[rtok] = 4
                else:
                    # with stack
                    v_ld.ld_type_by_rtok[rtok] = 5
            case "oo" | "ro":
                if v_announcelist.full[rtok][2] == "1":
                    # oo no stack not used
                    v_ld.ld_type_by_rtok[rtok] = 6
                else:
                    # with stack not used
                    v_ld.ld_type_by_rtok[rtok] = 7
            case "oa" | "aa":
                if len(v_announcelist.full[rtok]) == 3:
                    # one element
                    v_ld.ld_type_by_rtok[rtok] = 10
                else:
                    v_ld.ld_type_by_rtok[rtok] = 11
    return

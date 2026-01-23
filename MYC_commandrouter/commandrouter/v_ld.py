""""
name: v_sld.py
last edited: 202512
parameters for LD interface
Copyright : DK1RI
If no other rights are affected, this programm can be used under GPL (Gnu public licence)
"""
from_dev_to_ld = []             # data from device via CR
from_ld_to_dev = []             # data from LD to device vis CR
from_sk_to_ld = []              # data from SK via CR
from_ld_to_sk = []              # data from LD to SK vis CR
data_to_cr = []                 # data to CR, info or command
ld_available = 0
ld_len = [0,0,0,0,0,0,0]        # linelength parameters modified at real time: number of byte for next action
all_used_toks = {}              # used by LD only

"""
name : v_fix_tables.py Datv_ve_rx_myc
last edited: 20250331
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)
"""

drift = {}
fastlock = {}
fec = {}
gain = {}
gui = {}
player = {}
record_t = {}
record_iq = {}
sampler = {}
samplerate = {}
standard = {}
symbolrate = {}
viterbi = {}

# MYC values are stored for fixed frequencies
#  frequencies to send to sdr
frequency = {0: "29.25e6",
            1: "51.7e6",
            2: "71e6",
            3: "146.5e6",
            4: "437e6",
            5: "1.255e9",
            6: "1.275e9",
            7: "1.291e9",
            8: "2.395e9",

# QO100: start with 10491500
# f = forg - 9750000
             9: "741.5e6",
            10: "743.25e6",
            11: "744.75e6",
            12: "746.25e6",
            13: "742.75e6",
            14: "743.25e6",
            15: "743.75e6",
            16: "744.25e6",
            17: "744.75e6",
            18: "745.25e6",
            19: "745.75e6",
            20: "746.25e6",
            21: "746.75e6",
            22: "747.25e6",
            23: "747.75e6",
            24: "748.25e6",
            25: "748.75e6",
            26: "749.25e6",

            27: "74275e6",
            28: "743e6",
            29: "743.25e6",
            30: "743.5e6",
            31: "743.75e6",
            32: "744e6",
            33: "744.25e6",
            34: "744.5e6",
            35: "744.75e6",
            36: "745e6",
            37: "745.25e6",
            38: "745.5e6",
            39: "745.75e6",
            40: "746e6",
            41: "746.25e6",
            42: "746.5e6",
            43: "746.75e6",
            44: "747e6",
            45: "747.25e6",
            46: "747.5e6",
            47: "747.75e6",
            48: "748e6",
            49: "748.25e6",
            50: "748.5e6",
            51: "748.756",
            52: "749e6",
            53: "74925e6",
             # individual frequencies
             54: "437e6",
             55: "1.255e9",
             56: "1.275e9",
             57: "1.291e9",
             58: "2.395e9",
             }


def add_fixed_drift():
    i = 0
    while i < 59:
        drift[i] = 0
        i+=1
    return


def add_fixed_fastlock():
    i = 0
    while i <= 59:
        fastlock[i] = 1
        i += 1
    return


def add_fixed_fec():
    i = 0
    while i < 59:
        fec[i] = 1
        i+=1
    return


def add_fixed_gain():
    i = 0
    while i < 59:
        gain[i] = 0
        i+=1
    return



def add_fixed_gui():
    i = 0
    while i < 59:
        gui[i] = 1
        i+=1
    return


def add_fixed_player():
    i = 0
    while i < 59:
        player[i] = 0
        i+=1
    return


def add_fixed_record_iq():
    i = 0
    while i < 59:
        record_iq[i] = 0
        i+=1
    return


def add_fixed_record_t():
    i = 0
    while i < 59:
        record_t[i] = 0
        i+=1
    return


def add_fixed_sampler():
    i = 0
    while i < 59:
        sampler[i] = 0
        i+=1
    return


def add_fixed_samplerate():
    i = 0
    while i < 59:
        if i == 0:
            samplerate[i] = 0
        elif i == 1:
            samplerate[i] = 1
        elif i == 2:
            samplerate[i] = 1
        else:
            samplerate[i] = 4
        i+= 1
    return


def add_fixed_standard():
    i = 0
    while i < 59:
        standard[i] = 0
        i+=1
    return

def add_fixed_symbolrate():
    i = 0
    while i < 59:
        if i == 0:
            symbolrate[i] = 0
        elif i == 1:
            symbolrate[i] = 2
        elif i == 2:
            symbolrate[i] = 2
        elif i == 3:
            symbolrate[i] = 2
        elif i < 9:
            # direct <-> 333kS
            symbolrate[i] = 4
        elif i == 9:
            symbolrate[i] = 7
        elif i < 13:
            symbolrate[i] = 6
        elif i < 27:
            symbolrate[i] = 4
        else:
            symbolrate[i] = 2
        i+=1
    return

def add_fixed_viterbi():
    i = 0
    while i < 59:
        viterbi[i] = 1
        i+=1
    return

fec_values = { 0:["1/2"],
               1: ["2/3"],
               2: ["3/4"],
               3: ["5/6"],
               4: ["7/8"],
               }

gui_values = {0: " - | ./leandvb -f ",
              1: " - | ./leandvb --gui -f ",
              }


player_values = {0: "ffplay -x 512 -y 300 -",
                1: "mplayer -cache 32 -"
                }


samplerate_values = {0: "6e4",
                     1: "8e5",
                     2: "1.0e6",
                     3: "1.8e6",
                     4: "2.4e6",
                     }


standard_values = {0: ["DVB-S2"],
                   1: ["DVB-S"],
                   }


symbolrate_values = {   0: "33e3",
                        1: "66e3",
                        2: "125e3",
                        3: "250e3",
                        4: "333e3",
                        5: "500e3",
                        6: "1.0e6",
                        7: "1.5e6"
                       }
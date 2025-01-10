"""
name : v_fix_tables.py Datv_ve_rx_myc
last edited: 20250109
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)
fixed valus
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
#  frequencies to send to sdr in kHz
frequency = {0: 29250,
            1: 51700,
            2: 71000,
            3: 146500,
            4: 437000,
            5: 1255000,
            6: 1275000,
            7: 1291000,
            8: 2395000,

# QO100: start with 10491500
# f = forg - 9750000
            9: 10491500,
            10: 10493250,
            11: 10494750,
            12: 10496250,
            13: 10492750,
            14: 10493250,
            15: 10493750,
            16: 10494250,
            17: 10494750,
            18: 10495250,
            19: 10495750,
            20: 10496250,
            21: 10496750,
            22: 10497250,
            23: 10497750,
            24: 10498250,
            25: 10498750,
            26: 10499250,

            27: 10492750,
            28: 10493000,
            29: 10493250,
            30: 10493500,
            31: 10493750,
            32: 10494000,
            33: 10494250,
            34: 10494500,
            35: 10494750,
            36: 10495000,
            37: 10495250,
            38: 10495500,
            39: 10495750,
            40: 10496000,
            41: 10496250,
            42: 10496500,
            43: 10496750,
            44: 10497000,
            45: 10497250,
            46: 10497500,
            47: 10497750,
            48: 10498000,
            49: 10498250,
            50: 10498500,
            51: 10498750,
            52: 10499000,
            53: 10499250,
             # individual frequencies
             54: 437000,
             55: 1255000,
             56: 1275000,
             57: 1291000,
             58: 2395000,
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
        gain[i] = 23
        i+=1
    return



def add_fixed_gui():
    i = 0
    while i < 59:
        gui[i] = 0
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
            samplerate[i] = 2
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
            symbolrate[i] = 4
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


samplerate_values = {0: "60000",
                     1: "800000",
                     2: "1000000",
                     3: "1800000",
                     4: "2400000",
                     }


standard_values = {0: ["DVB-S2"],
                   1: ["DVB-S"],
                   }


symbolrate_values = {   0: "33000",
                        1: "66000",
                        2: "125000",
                        3: "250000",
                        4: "333000",
                        5: "500000",
                        6: "1000000",
                        7: "1500000"
                       }
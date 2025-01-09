"""
name : misc_functions.py Datv_ve_rx_myc
last edited: 20250107
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)
misc functions
"""

import time
import sys
import platform

import v_dev_vars
import v_sk
import v_fix_tables
import os


def str_to_bytearray(string):
    # for string s:
    c = bytearray([])
    i = 0
    while i < len(string):
        c.extend(bytearray([ord(string[i])]))
        i += 1
    return c


def ba_to_str(ba):
    # bytearray to string
    string = ""
    i = 0
    while i < len(ba):
        string += chr(ba[i])
        i += 1
    return string


def int_to_list(integ):
    # convert an integer (frequency) to list with 3 bytes ( 0- 10471250)
    s = [0,0,0]
    t0 = integ
    t = t0
    i = 2
    while t > 256:
        t = t0 // 256
        b = t0 - t * 256
        t0 = t
        s[i] = b
        i -= 1
    s[i] = t
    return s


def write_log(line):
    # check number of lines
    v_dev_vars.error_cmd_no = v_dev_vars.command_no
    handle = open(v_dev_vars.log_file)
    i = 0
    log = []
    for lines in handle:
        log.append(lines)
        i += 1
    handle.close()
    if i > v_dev_vars.logfilesize:
        # delete 23 %
        handle = open(v_dev_vars.log_file, "w")
        pos = i // 1.3
        pos = int(pos)
        while pos < i:
            handle.write(log[pos])
            pos += 1
        handle.close()
    temp = time.asctime(time.localtime(time.time())) + " commandnumber: " + str(v_dev_vars.error_cmd_no) + " : " + line
    if v_dev_vars.test_mode == 1:
        handle = open(v_dev_vars.log_file, "a")
        handle.write(temp + "\n")
        handle.close()
    return

def read_indiv_data():
    # at start only
    if not os.path.isfile(v_dev_vars.indiv_data_file):
        store_indiv_data(5)
    handle = open(v_dev_vars.indiv_data_file)
    i = 54
    for lines in handle:
        if len(lines) > 2:
            line = lines.split(";")
            v_fix_tables.drift[i] = int(line[0])
            v_fix_tables.fastlock[i] = int(line[0])
            v_fix_tables.fec[i] = int(line[1])
            v_fix_tables.frequency[i] = int(line[11])
            v_fix_tables.gain[i] = int(line[2])
            v_fix_tables.gui[i] = int(line[3])
            v_fix_tables.player[i] = int(line[4])
            v_fix_tables.record_t[i] = int(line[5])
            v_fix_tables.record_iq[i] = int(line[6])
            v_fix_tables.sampler[i] = int(line[7])
            v_fix_tables.samplerate[i] = int(line[8])
            v_fix_tables.standard[i] = int(line[8])
            v_fix_tables.symbolrate[i] = int(line[9])
            v_fix_tables.viterbi[i] = int(line[10])
        i += 1
    handle.close()
    return


def store_indiv_data(i):
    i+=53
    v_fix_tables.drift[i] = v_dev_vars.drift_dat
    v_fix_tables.fastlock[i] = v_dev_vars.fastlock_dat
    v_fix_tables.fec[i] = v_dev_vars.fec_dat
    v_fix_tables.frequency[i] = v_dev_vars.frequency_dat
    v_fix_tables.gain[i] = v_dev_vars.gain_dat
    v_fix_tables.gui[i] = v_dev_vars.gui_dat
    v_fix_tables.player[i] = v_dev_vars.player_dat
    v_fix_tables.record_t[i] = v_dev_vars.record_t_dat
    v_fix_tables.record_iq[i] = v_dev_vars.record_iq_dat
    v_fix_tables.sampler[i] = v_dev_vars.sampler_dat
    v_fix_tables.samplerate[i] = v_dev_vars.samplerate_dat
    v_fix_tables.standard[i] = v_dev_vars.standard_dat
    v_fix_tables.symbolrate[i] = v_dev_vars.symbolrate_dat
    v_fix_tables.viterbi[i] = v_dev_vars.viterbi_dat
    v_fix_tables.frequency[i] = v_dev_vars.frequency_dat
    handle = open(v_dev_vars.indiv_data_file, "w")
    i = 54
    while i < 59:
        line = str(v_fix_tables.fastlock[i]) + ";" + str(v_fix_tables.fec[i]) + ";" + str(v_fix_tables.gain[i]) + ";"
        line += str(v_fix_tables.gui[i]) + ";" + str(v_fix_tables.player[i]) + ";" + str(v_fix_tables.record_t[i]) + ";"
        line += str(v_fix_tables.record_iq[i]) + ";" + str(v_fix_tables.sampler[i]) + ";" + str(v_fix_tables.samplerate[i]) + ";"
        line += str(v_fix_tables.symbolrate[i]) + ";" + str(v_fix_tables.viterbi[i]) + ";" +str(v_fix_tables.frequency[i]) + "\n"
        handle.write(line)
        i += 1
    handle.close()
    return


def analyze_sk(t, input_buffer_number):
    # if v_sk.hex_count == 0:
    #    v_sk.data = 0
    if str.isnumeric(t) == 1:
        # 0 - 9
        if v_sk.hex_count == 0:
            v_sk.data = ord(t) - 48
        else:
            v_sk.data *= 16
            v_sk.data += ord(t) - 48
        v_sk.hex_count += 1
    elif 96 < ord(t) < 103:
        # a - f
        if v_sk.hex_count == 0:
            v_sk.data = ord(t) - 87
        else:
            v_sk.data *= 16
            v_sk.data += (ord(t) - 87)
        v_sk.hex_count += 1
    elif t == "x":
        sys.exit(0)
    # ignore other characters
    if v_sk.hex_count == 2:
        # add to inputline
        v_sk.inputline[input_buffer_number].extend(bytearray([v_sk.data]))
        v_sk.data = ""
        v_sk.hex_count = 0
    return


def send_to_sdr():
    error = check_valid_values()
    if error == 1:
        return

    if v_dev_vars.frequency_dat >= 10491500:
        # - lnb offset
        f = str((v_dev_vars.frequency_dat - 9750000) * 1000)
    else:
        f = str(v_dev_vars.frequency_dat * 1000)
    string = "rtl_sdr -f " + f
    string += " -g " + str(v_dev_vars.gain_dat)
    string += " -s "  + str(v_fix_tables.samplerate_values[v_dev_vars.samplerate_dat])
    if v_dev_vars.record_iq_dat == 1:
        string +=  " - | tee /home/pi/Desktop/Videos/record$(date +%y.%m.%d-%H:%M:%S).iq "
    string += " " + ''.join(v_fix_tables.gui_values[v_dev_vars.gui_dat])
    string += " " + str(v_fix_tables.samplerate_values[v_dev_vars.samplerate_dat])
    string += " --sr " + ''.join(v_fix_tables.symbolrate_values[v_dev_vars.symbolrate_dat])
    string += " --cr  " + ''.join(v_fix_tables.fec_values[v_dev_vars.fec_dat])
    string += " --standard " + ''.join(v_fix_tables.standard_values[v_dev_vars.standard_dat])
    if v_dev_vars.sampler_dat == 0:
        string += " --sampler  rrc --rrc-rej 30 "
    if v_dev_vars.drift_dat == 0:
        string += " --drift "
    if v_dev_vars.fastlock_dat == 0:
        string += " --fastlock "
    if v_dev_vars.viterbi_dat == 0:
        string += " --viterbi "
    if v_dev_vars.record_t_dat:
        string += " | tee /home/pi/Desktop/Videos/record$(date +%y.%m.%d-%H:%M:%S).ts "
    string += " | " + ''.join(v_fix_tables.player_values[v_dev_vars.player_dat])
    if v_dev_vars.test_mode == 1:
        print (string)
    else:
        os.popen(string)
    return

def check_valid_values():
    # may be that not all rules are known
    if v_dev_vars.standard_dat == 1:
        if v_dev_vars.fec_dat > 2:
            return 1
    return 0


def store_chanel(indiv_chanal_no):
    # for individual chanels only
    indiv_chanal_no = indiv_chanal_no + 53
    v_fix_tables.drift[indiv_chanal_no] = v_dev_vars.drift_dat
    v_fix_tables.fastlock[indiv_chanal_no] = v_dev_vars.fastlock_dat
    v_fix_tables.fec[indiv_chanal_no] = v_dev_vars.fec_dat
    v_fix_tables.frequency[indiv_chanal_no] = v_dev_vars.frequency_dat
    v_fix_tables.gain[indiv_chanal_no] = v_dev_vars.gain_dat
    v_fix_tables.gui[indiv_chanal_no] = v_dev_vars.gui_dat
    v_fix_tables.player[indiv_chanal_no] = v_dev_vars.player_dat
    v_fix_tables.record_iq[indiv_chanal_no] = v_dev_vars.record_iq_dat
    v_fix_tables.record_t[indiv_chanal_no] = v_dev_vars.record_t_dat
    v_fix_tables.sampler[indiv_chanal_no] = v_dev_vars.sampler_dat
    v_fix_tables.samplerate[indiv_chanal_no] = v_dev_vars.samplerate_dat
    v_fix_tables.standard[indiv_chanal_no] = v_dev_vars.standard_dat
    v_fix_tables.symbolrate[indiv_chanal_no] = v_dev_vars.symbolrate_dat
    v_fix_tables.viterbi[indiv_chanal_no] = v_dev_vars.viterbi_dat
    return


def read_chanel(indiv_chanal_no):
    # copies data for ficed or individual data
    v_dev_vars.drift_dat = v_fix_tables.drift[indiv_chanal_no]
    v_dev_vars.fastlock_dat = v_fix_tables.fastlock[indiv_chanal_no]
    v_dev_vars.fec_dat = v_fix_tables.fec[indiv_chanal_no]
    v_dev_vars.frequency_dat = v_fix_tables.frequency[indiv_chanal_no]
    v_dev_vars.gain_dat = v_fix_tables.gain[indiv_chanal_no]
    v_dev_vars.gui_dat = v_fix_tables.gui[indiv_chanal_no]
    v_dev_vars.player_dat = v_fix_tables.player[indiv_chanal_no]
    v_dev_vars.record_iq_dat = v_fix_tables.record_iq[indiv_chanal_no]
    v_dev_vars.record_t_dat = v_fix_tables.record_t[indiv_chanal_no]
    v_dev_vars.sampler_dat = v_fix_tables.sampler[indiv_chanal_no]
    v_dev_vars.samplerate_dat = v_fix_tables.samplerate[indiv_chanal_no]
    v_dev_vars.standard_dat = v_fix_tables.standard[indiv_chanal_no]
    v_dev_vars.symbolrate_dat = v_fix_tables.symbolrate[indiv_chanal_no]
    v_dev_vars.viterbi_dat = v_fix_tables.viterbi[indiv_chanal_no]
    return

def stoprx():
    platf = platform.platform()[0:7]
    if (platf != "Windows"):
        os.popen("killall rtl_sdr")
        os.popen("killall leandvb")
        os.popen("killall mplayer")
        os.popen("killall vlc")
        os.popen("killall ffplay")
    return

def exit_():
    stoprx()
    exit()

"""
name: commands.py Datv_ve_rx_myc
last edited: 20250109
Copyright : DK1RI
If no other earlier rights are affected, this program can be used under GPL (Gnu public licence)
handling of sk input commands
"""

from misc_functions import *
import v_announcelist
import v_sk
import v_dev_vars


def command_selector(command, line):
    if command == 1:
        ret = com01(line)
    elif command == 2:
        ret = com02(command)
    elif command == 3:
        ret = com03(line)
    elif command == 4:
        ret = com04(line)
    elif command == 5:
        ret = com05(command)
    elif command == 6:
        ret = com06(line)
    elif command == 7:
        ret = com07(command)
    elif command == 8:
        ret = com08(line)
    elif command == 9:
        ret = com09(command)
    elif command == 10:
        ret = com10(line)
    elif command == 11:
        ret = com11(command)
    elif command == 12:
        ret = com12(line)
    elif command == 13:
        ret = com13(command)
    elif command == 14:
        ret = com14(line)
    elif command == 15:
        ret = com15(command)
    elif command == 16:
        ret = com16(line)
    elif command == 17:
        ret = com17(command)
    elif command == 18:
        ret = com18(line)
    elif command == 19:
        ret = com19(command)
    elif command == 20:
        ret = com20(line)
    elif command == 21:
        ret = com21(command)
    elif command == 22:
        ret = com22(line)
    elif command == 23:
        ret = com23(command)
    elif command == 24:
        ret = com24(line)
    elif command == 25:
        ret = com25(command)
    elif command == 26:
        ret = com26(line)
    elif command == 27:
        ret = com27(command)
    elif command == 28:
        ret = com28(line)
    elif command == 29:
        ret = com29(command)
    elif command == 30:
        ret = com30(line)
    elif command == 31:
        ret = com31(command)
    elif command == 32:
        ret = com32(line)
    elif command == 33:
        ret = com33(line)
    elif command == 34:
        ret = com34(line)
    elif command == 240:
        ret = com240(line)
    elif command == 252:
        ret = com252()
    elif command == 253:
        ret = com253()
    elif command == 254:
        ret = com254(line)
    elif command == 255:
        ret = com255(line)
    else:
        v_dev_vars.last_error_msg = "command not found"
        ret = 2
    return ret


def com01(line):
    #   fixeed frequency
    if len(line) < 2:
        return 0
    if line[1] > 54:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    read_chanel(line[1])
    send_to_sdr()
    v_dev_vars.selected_chanal = line[1]
    return 1


def com02(command):
    v_sk.info_to_all.extend([command, v_dev_vars.selected_chanal])
    return 1


def com03(line):
    # frequency
    if len(line) < 4:
        return 0
    f = 65536 * line[1] + 256 * line[2] + line[3]
    if f > 236900:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.frequency_dat = f + 2800
    v_dev_vars.frequency_dat *= 10
    send_to_sdr()
    return 1


def com04(line):
    # frequency
    if len(line) < 3:
        return 0
    f = 256 * line[1] + line[2]
    if f > 776:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    #
    v_dev_vars.frequency_dat = f + 1049150
    v_dev_vars.frequency_dat *= 10
    send_to_sdr()
    return 1


def com05(command):
    v_sk.info_to_all.extend([command])
    a = int_to_list(v_dev_vars.frequency_dat)
    v_sk.info_to_all.extend([a[0]])
    v_sk.info_to_all.extend([a[1]])
    v_sk.info_to_all.extend([a[2]])
    return 1

def com06(line):
    # sample rate
    if len(line) < 2:
        return 0
    if line[1] > 4:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.samplerate_dat = line[1]
    send_to_sdr()
    return 1


def com07(command):
    v_sk.info_to_all.extend([command, v_dev_vars.samplerate_dat])
  # v_sk.info_to_all.extend([v_dev_vars.samplerate_dat])
    return 1


def com08(line):
    # gain
    if len(line) < 2:
        return 0
    if line[1] > 49:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.gain_dat = line[1]
    send_to_sdr()
    return 1


def com09(command):
    v_sk.info_to_all.extend([command, v_dev_vars.gain_dat])
    return 1


def com10(line):
    # symbolrate
    if len(line) < 2:
        return 0
    if line[1] > 7:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.symbolrate_dat = line[1]
    send_to_sdr()
    return 1

def com11(command):
    v_sk.info_to_all.extend([command, v_dev_vars.symbolrate_dat])
    return 1


def com12(line):
    # fec
    if len(line) < 2:
        return 0
    if line[1] > 4:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.fec_dat = line[1]
    send_to_sdr()
    return 1


def com13(command):
    v_sk.info_to_all.extend([command, v_dev_vars.fec_dat])
    return 1


def com14(line):
    # standard
    if len(line) < 2:
        return 0
    if line[1] > 1:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.standard_dat = line[1]
    send_to_sdr()
    return 1


def com15(command):
    v_sk.info_to_all.extend([command, v_dev_vars.standard_dat])
    return 1


def com16(line):
    # additional (GUI)
    if len(line) < 2:
        return 0
    if line[1] > 1:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.gui_dat = line[1]
    send_to_sdr()
    return 1


def com17(command):
    v_sk.info_to_all.extend([command, v_dev_vars.gui_dat])
    return 1


def com18(line):
    # player
    if len(line) < 2:
        return 0
    if line[1] > 1:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.player_dat = line[1]
    send_to_sdr()
    return 1


def com19(command):
    v_sk.info_to_all.extend([command, v_dev_vars.player_dat])
    return 1


def com20(line):
    # drift
    if len(line) < 2:
        return 0
    if line[1] > 1:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.drift_dat = line[1]
    send_to_sdr()
    return 1


def com21(command):
    v_sk.info_to_all.extend([command, v_dev_vars.drift_dat])
    return 1


def com22(line):
    # fastlock
    if len(line) < 2:
        return 0
    if line[1] > 1:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.fastlock_dat = line[1]
    send_to_sdr()
    return 1


def com23(command):
    v_sk.info_to_all.extend([command, v_dev_vars.fastlock_dat])
    return 1


def com24(line):
    # viterbi
    if len(line) < 2:
        return 0
    if line[1] > 1:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.viterbi_dat = line[1]
    send_to_sdr()
    return 1


def com25(command):
    v_sk.info_to_all.extend([command, v_dev_vars.viterbi_dat])
    return 1


def com26(line):
    # sampler
    if len(line) < 2:
        return 0
    if line[1] > 1:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.sampler_dat = line[1]
    send_to_sdr()
    return 1

def com27(command):
    v_sk.info_to_all.extend([command, v_dev_vars.sampler_dat])
    return 1


def com28(line):
    # record transport
    if len(line) < 2:
        return 0
    if line[1] > 1:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.record_t_dat = line[1]
    send_to_sdr()
    return 1


def com29(command):
    v_sk.info_to_all.extend([command, v_dev_vars.record_t_dat])
    return 1


def com30(line):
    # record iq
    if len(line) < 2:
        return 0
    if line[1] > 1:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_dev_vars.record_iq_dat= line[1]
    send_to_sdr()
    return 1


def com31(command):
    v_sk.info_to_all.extend([command, v_dev_vars.record_iq_dat])
    return 1


def com32(line):
    # store individual chanel
    if len(line) < 2:
        return 0
    if line[1] > 5:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    if line[1] == 0:
        return 1
    store_chanel(line[1])
    store_indiv_data(line[1])
    return 1

def com33(line):
    # read individual chanel
    if len(line) < 2:
        return 0
    if line[1] > 5:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    if line[1] == 0:
        return 1
    read_chanel(line[1] + 53)
    return 1

def com34(line):
    # stop
    if len(line) < 2:
        return 0
    if line[1] > 3:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    if line[1] == 1:
        send_to_sdr()
    elif line[1] == 2:
        stoprx()
    elif line[1] == 3:
        exit_()
    return 1


def com240(line):
    # ANNOUCEMENTS
    if len(line) < 3:
        return 0
    start_line = line[1]
    if start_line >= v_announcelist.number_of_lines:
        v_dev_vars.last_error_msg = "startline for announcecommand too high: " + str(start_line)
        return 2
    number_of_lines = line[2]
    if number_of_lines > v_announcelist.number_of_lines:
        v_dev_vars.last_error_msg = "number of lines for announcecommand too high: " + str(start_line)
        return 2
    else:
        output = bytearray([0xf0])
        output.extend(line[1:3])
        if  number_of_lines > 0:
            i = 0
            while i < number_of_lines:
                output.extend(str_to_bytearray(v_announcelist.full[start_line]))
                i += 1
                start_line += 1
                if start_line >= v_announcelist.number_of_lines:
                    start_line = 0
        v_sk.info_to_all.extend(output)
    return 1


def com252():
    # ERROR
    v_sk.info_to_all = bytearray([ 0xfc])
    if v_dev_vars.error_cmd_no == 255:
        temp = "no error"
    else:
        temp = "command: " + str(v_dev_vars.command_no) + " last error at command: " + str(v_dev_vars.error_cmd_no)
        temp += " : " + v_dev_vars.last_error_msg
    v_sk.info_to_all.extend(bytearray([len(temp)]))
    v_sk.info_to_all.extend(str_to_bytearray(temp))
    return 1


def com253():
    # BUSY
    v_sk.info_to_all = bytearray([0xfd, 0x04])
    return 1


def com254(line):
    # INDIVIDUALIZATION
    if len(line) < 3:
        return 0
    if line[1] > 4:
        v_dev_vars.last_error_msg = "fparameter error"
        return 2

    if line[1] == 0:
        length = line[2]
        if length > 20 or length == 0:
            v_dev_vars.last_error_msg = "parameter error"
            return 2
        if len(line) < length + 2:
            return 0
        if len(line) > length + 3:
            v_dev_vars.last_error_msg = "parameter error"
            return 2
        v_dev_vars.device_name = ba_to_str(line[3:])
    elif line[1] == 1:
        v_dev_vars.device_number = line[2]
    elif line[1] == 2:
        if line[2] > 1:
            v_dev_vars.last_error_msg = "parameter error"
            return 2
        v_dev_vars.telnet_active = line[2]
    elif line[1] == 3:
        if len(line) < 4:
            return 0
        v_dev_vars.telnet_port = line[2] * 256 + line[3]
    elif line[1] == 4:
        if line[2] > 1:
            v_dev_vars.last_error_msg = "parameter error"
            return 2
        v_dev_vars.file_active = line[2]
    return 1


def com255(line):
    if len(line) < 2:
        return 0
    if line[1] > 4:
        v_dev_vars.last_error_msg = "parameter error"
        return 2
    v_sk.info_to_all = bytearray([0xff, line[1]])
    if line[1] == 0:
        v_sk.info_to_all.extend(bytearray([len(v_dev_vars.device_name)]))
        v_sk.info_to_all.extend(bytearray(v_dev_vars.device_name, encoding='utf8'))
    elif line[1] == 1:
        v_sk.info_to_all.extend(bytearray([v_dev_vars.device_number]))
    elif line[1] == 2:
        v_sk.info_to_all.extend(bytearray([v_dev_vars.telnet_active]))
    elif line[1] == 3:
        v_sk.info_to_all.extend(bytes(v_dev_vars.telnet_port.to_bytes(2,"big")))
    elif line[1] == 4:
        v_sk.info_to_all.extend(bytearray([v_dev_vars.file_active]))
    return 1

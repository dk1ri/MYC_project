"""
name : misc_functions.py IC9700
last edited: 20211020
misc functions
"""

import time
import sys
import v_icom_vars
import v_sk


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
        string += str(ba[i])
        i += 1
    return string


def ba_to_int(ba):
    # bytearray to int
    num = 0
    i = len(ba) - 1
    mul = 1
    while i >= 0:
        num += ba[i] * mul
        i -= 1
        mul *= 256
    return num


def add_length_to_str(string, length):
    # add the length of a string to the start
    # the length of "length" depend on calling parameter length
    return int_to_bytes(len(string), length) + string


def int_to_bytes(integ, length):
    # convert a integer to a string of bytes (0-255)
    # length 0: use CR tokenlength
    if length == 0:
        length = 2
    s = ""
    i = 0
    while i < length:
        s += chr(integ & 0xFF)
        integ >>= 8
        i += 1
    # reverse
    s2 = ""
    i = 0
    while i < length:
        s2 += s[length - i - 1]
        i += 1
    return s2


def int_to_list(integ, le):
    # convert a integer to a list of of int (0-255) with a length 1 or 2
    # length 0: use CR tokenlength
    if le == 0:
        le = 2
    list_ = []
    if le == 1:
        list_. append(integ)
    elif le == 2:
        t = integ // 256
        list_.append(t)
        t = integ % 256
        list_.append(t)
    return list


def int_to_2_ele(integ):
    # convert a integer to 2 parameter
    t = integ // 256
    u = integ % 256
    return t, u


def bytes_to_int_ba(ba):
    i = len(ba) - 1
    z = 1
    temp = 0
    while i >= 0:
        temp += ba[i] * z
        z *= 256
        i -= 1
    return temp


def calculate_length_of_commandtoken(number):
    # for CR only
    # number is highest tokennumber of other devices in full CR announcelist
    multi = 256
    # length_of_commandtoken:
    v_cr_params.length_commandtoken = 1
    # avoid 0 as first byte:
    v_cr_params.startnumber = 1
    while number + 32 >= multi:
        multi = multi * 256
        v_cr_params.startnumber = v_cr_params.startnumber * 256
        v_cr_params.length_commandtoken += 1
    # adder for 0hxxFx commands: n + f0 = 0hxxf0
    v_cr_params.adder = multi - 0x100
    # reserved commandtoken last 16 reserved
    v_cr_params.reserved_token_start = multi - 0x10

    v_cr_params.startindex = v_cr_params.startnumber - 1
    return


def write_log(line):
    # check number of lines
    v_icom_vars.error_cmd_no = v_icom_vars.command_no
    handle = open(v_icom_vars.log_file)
    i = 0
    log = []
    for lines in handle:
        log.append(lines)
        i += 1
    handle.close()
    if i > v_icom_vars.logfilesize:
        # delete 23 %
        handle = open(v_icom_vars.log_file, "w")
        pos = i // 1.3
        pos = int(pos)
        while pos < i:
            handle.write(log[pos])
            pos += 1
        handle.close()
    temp = time.asctime(time.localtime(time.time())) + " commandnumber: " + str(v_icom_vars.error_cmd_no) + " : " + line
    if v_icom_vars.test_mode == 1:
        print(temp)
    handle = open(v_icom_vars.log_file, "a")
    handle.write(temp + "\n")
    handle.close()
    return


def bcd_to_int(a):
    # 0 - 99 bcd
    temp1 = (a >> 4) * 10 + (a & 0x0F)
    return temp1


def bcd2_to_int(a):
    # 0 - 255 bcd (2 byte ba) to 1 byte int
    temp1 = a[0]
    temp1 = ((temp1 >> 4) * 10 + (temp1 & 0x0F)) * 100
    temp2 = a[1]
    temp1 += (temp2 >> 4) * 10 + (temp2 & 0x0F)
    return temp1


def bcdx_to_int(a, no_of_bytes):
    # up to 4 byte ba to int
    if no_of_bytes == 1:
        return (a[0] >> 4) * 10 + (a[0] & 0x0F)
    elif no_of_bytes == 2:
        temp1 = a[0]
        temp1 = ((temp1 >> 4) * 10 + (temp1 & 0x0F)) * 100
        temp2 = a[1]
        temp1 += (temp2 >> 4) * 10 + (temp2 & 0x0F)
        return temp1
    elif no_of_bytes == 3:
        temp1 = a[0]
        temp1 = ((temp1 >> 4) * 10 + (temp1 & 0x0F)) * 10000
        temp2 = a[1]
        temp1 += ((temp2 >> 4) * 10 + (temp2 & 0x0F)) * 100
        temp2 = a[2]
        temp1 += ((temp2 >> 4) * 10 + (temp2 & 0x0F))
        return temp1
    else:
        return 0


def bcd_to_int2(a):
    # 0 - 9999 bcd (2 byte ba) to int
    temp1 = a[0]
    temp1 = (temp1 >> 4) * 10 + (temp1 & 0x0F)
    temp2 = temp1 * 100
    temp1 = a[1]
    temp1 = (temp1 >> 4) * 10 + (temp1 & 0x0F)
    return temp1 + temp2


def bcd_to_int_3(a):
    # 0 - 9999 bcd (2 byte ba) to int
    temp1 = a[0]
    temp1 = ((temp1 >> 4) * 10 + (temp1 & 0x0F)) * 100
    temp2 = a[1]
    temp1 += (temp2 >> 4) * 10 + (temp2 & 0x0F)
    temp1 *= 100
    temp3 = a[2]
    temp1 += (temp3 >> 4) * 10 + (temp3 & 0x0F)
    return temp1


def bcd_to_ba_2(a, adder):
    # 0 - 9999 bcd (2 byte bcd to 2 byte ba)
    temp1 = a[0]
    temp1 = ((temp1 >> 4) * 10 + (temp1 & 0x0F)) * 100
    temp2 = a[1]
    temp1 += (temp2 >> 4) * 10 + (temp2 & 0x0F) + adder
    return bytearray([temp1 // 256, temp1 % 256])


def bcd_to_ba_3(a, divisor, subtract):
    # 0 - 64365 bcd (3 byte bcd to 2 byte ba); than divide, than subtract
    temp1 = a[0]
    temp1 = ((temp1 >> 4) * 10 + (temp1 & 0x0F)) * 100
    temp2 = a[1]
    temp1 += (temp2 >> 4) * 10 + (temp2 & 0x0F)
    temp1 *= 100
    temp3 = a[2]
    temp1 += (temp3 >> 4) * 10 + (temp3 & 0x0F)
    temp1 //= divisor
    temp1 -= subtract
    return [(temp1 // 256) % 256, temp1 % 256]


def int_to_bcd(a, figures):
    # return ba up to 999999 ( 3 bcd bytes)
    bcd = bytearray([])
    if figures == 3:
        if a > 999999:
            return bytearray([0, 0, 0])
        b = a // 10000
        bcd.extend(bytearray([(b // 10 * 16) + b % 10]))
        c = a % 10000
        b = c // 100
        bcd.extend(bytearray([(b // 10 * 16) + b % 10]))
        d = c % 100
        bcd.extend(bytearray([(d // 10 * 16) + d % 10]))
    elif figures > 1:
        if a > 9999:
            return bytearray([0, 0])
        b = a // 100
        bcd.extend(bytearray([(b//10 * 16) + b % 10]))
        b = a % 100
        bcd.extend(bytearray([(b // 10 * 16) + b % 10]))
    else:
        if a > 99:
            return bytearray([0])
        bcd.extend(bytearray([(a // 10 * 16) + a % 10]))
    return bcd


def int_to_bcd_int(a):
    # return 1 byte (< 256) int
    bcd = (a // 10 * 16) + a % 10
    return bcd


def int_to_3bcd(a):
    # return ba
    instr = str(a)
    length = len(instr)
    temp1 = 1
    s = ""
    zeros = 7 - length
    while temp1 < 7:
        if temp1 < zeros:
            s += "0"
        else:
            s += instr[temp1 - zeros]
        temp1 += 1
    bcd = bytearray([0x00, 0x00, 0x00])
    temp = int(s[4:6])
    bcd[0] = (temp // 10 * 16) + temp % 10
    temp = int(s[2:4])
    bcd[1] = (temp // 10 * 16) + temp % 10
    temp = int(s[0:2])
    bcd[2] = (temp // 10 * 16) + temp % 10
    return bcd


def int_to_4bcd_reverse(a):
    # return ba (for 4 byte frequency)
    instr = str(a)
    length = len(instr)
    temp1 = 1
    s = ""
    zeros = 9 - length
    while temp1 < 9:
        if temp1 < zeros:
            s += "0"
        else:
            s += instr[temp1 - zeros]
        temp1 += 1
    bcd = bytearray([0x00, 0x00, 0x00, 0x00])
    temp = int(s[6:8])
    bcd[0] = (temp // 10 * 16) + temp % 10
    temp = int(s[4:6])
    bcd[1] = (temp // 10 * 16) + temp % 10
    temp = int(s[2:4])
    bcd[2] = (temp // 10 * 16) + temp % 10
    temp = int(s[0:2])
    bcd[3] = (temp // 10 * 16) + temp % 10
    return bcd

def int_to_bcd_plusminus(line, max_, bcdbytes, multiplier):
    # max is maximum for abs value -> max_int = 2 * max (0 base)
    # for 2 byte int values
    # for bcdbytes bcd digits, bcd reverse: low byte first
    int_value = line[2] * 256 + line[3]
    if int_value > 2 * max_:
        return 2, 0
    if int_value > max_:
        # positive
        int_value -= max_
        negative = 0
    else:
        # 0 is negative
        int_value = max_ - int_value
        negative = 1
    int_value *= multiplier
    decimal_string = str(int_value)
    digits = [int(c) for c in decimal_string]
    civ_byte = 0
    source = len(digits)
    temp = bytearray([])
    while civ_byte < bcdbytes:
        # high nibble
        if source > 1:
            temp1 = int(digits[source - 2]) * 16
        else:
            temp1 = 0
        # add low nibble
        if source > 0:
            temp1 += int(digits[source - 1])
            temp.extend(bytearray([temp1]))
            source -= 2
        else:
            temp.extend(bytearray([0x00]))
        civ_byte += 1
    temp.extend(bytearray([negative]))
    return 1, temp


def bcd_plusminus_to_int(line, start, max_, bcdbytes, commandbytes, divisor):
    # bcdbytes bcd values (lsb first) + polarity
    # convert to commandbytes bytes ba
    temp1 = start
    intvalue = 0
    multiplier = 1
    while temp1 < (start + bcdbytes):
        temp2 = bcd_to_int(line[temp1])
        intvalue = intvalue + multiplier * temp2
        multiplier *= 100
        temp1 += 1
    intvalue //= divisor
    if line[start + bcdbytes] == 0:
        intvalue += max_
    else:
        intvalue = max_ - intvalue
    temp1 = intvalue.to_bytes(commandbytes, byteorder="big")
    return temp1


def check_and_convert_alphabet(a, type_):
    # used for answers, a= 255 should not happen
    aa = 255
    if 0x2f < a < 0x3a:
        # 0 to 9 always ok
        return a
    if type_ == 0:
        # TX Message (DV), network radio name, Memory Name, VOICE TX RECORD,dd your call singn name,repeaterlist name subname, GPS TX mode, preset name
        if 0x1f < a < 0x7f:
            aa = a
    elif type_ == 1:
        # symbol 1st char DEF_ALPHA1
        if a == 0x2f or a == 0x5c:
            aa = a
        elif 57 < a < 58:
            # numeric
            aa = a
        elif 64 < a < 91:
            #A-Z
            aa = a
    elif type_ == 2:
        # CW memory keyer DEF_ALPHA2
        # A-Z
        if (a > 64) and (a < 91):
            aa = a
        elif (a > 45) and (a < 58):
            aa = a
        elif a in [0x20, 0x2a, 0x2c, 0x3f, 0x5e, 0x40]:
            aa = a
    elif type_ == 3:
        # CW DEF_ALPHA3
        # A-Z
        if (a > 64) and (a < 91):
            aa = a
        # a-z
        elif (a > 96) and (a < 123):
            aa = a
        # 2b - 3a
        elif (a > 42) and (a < 59):
            aa = a
        elif a in [0x20, 0x22, 0x27, 0x28, 0x29, 0x3d, 0x3f, 0x40]:
            aa = a
    elif type_ == 4:
        # My Call Sign (DV)/(DD), UR, R1, R2,dd your call singn call sign, repeaterlist CALL SIGN, GW CALL SIGN,DR TO SELECT Direct input (UR)/(RPT)
        if (a > 64) and (a < 91):
            aa = a
        elif (a > 46) and (a < 58):
            aa = a
        elif a == 0x20:
            aa = a
        elif a == 0x2f:
            aa = a
    elif type_ == 5:
        # Network Name
        # A-Z
        if (a > 64) and (a < 91):
            aa = a
        # a-z
        elif (a > 96) and (a < 123):
            aa = a
        elif (a > 32) and (a < 42):
            aa = a
        elif (a > 42) and (a < 47):
            aa = a
        elif a in [0x3b, 0x3d, 0x40, 0x5b, 0x5d, 0x5e, 0x5f, 0x60,0x7b, 0x7d, 0x7f]:
            aa = a
    elif type_ == 6:
        # Network User ,Password
        if 0x20 < a <0x7f:
            aa = a
    elif type_ == 7:
        # NTP Server Address
        # A-Z
        if (a > 64) and (a < 91):
            aa = a
        # a-z
        elif (a > 96) and (a < 123):
            aa = a
        # num
        elif (a > 47) and (a < 58):
            aa = a
        elif a in [0x2d, 0x2e]:
            # - .
            aa = a
    elif type_ == 8:
        # SD card
        # > ... A-Z
        if (a > 59) and (a < 91):
            aa = a
        # a-z
        elif (a > 96) and (a < 123):
            aa = a
        # num
        elif (a > 47) and (a < 58):
            aa = a
        elif (a > 0x31) and (a < 0x47):
            aa = a
        elif a in [x5b, 0x5d, 0x5e, 0x5f, 0x60,0x7b, 0x7d, 0x7f]:
            # ! " # $ % & ' ( ) +  , - . < = > ? @ [ ] ^ _ ` { } ~
            aa = a
    elif type_ == 9:
        # RTTY memory
        # > ... A-Z
        if (a > 59) and (a < 91):
            aa = a
        # num
        elif (a > 47) and (a < 58):
            aa = a
        elif a in [0x20, 0x21, 0x22, 0x24, 0x26,0x2c,0x2d,0x2e, 0x2f, 0x3a, 0x3b,0x28, 0x29]:
            # ! $ & ? " ' - / . , : ; ( )
            aa = a
    elif type_ == 10:
        # DTMF
        # num
        if (a > 47) and (a < 58):
            aa = a
        elif a in [0x41, 0x42, 0x43, 0x44,0x4c,0x4d,0x2a, 0x23]:
            # A B C D * #
            aa = a
    elif type_ == 11:
        aa = a
    return aa


def check_length(line, no_of_strings, start, max1, max2, max3, max4, max5):
    # check command up to 4 strings are availablbe with correct length
    len2 = 0
    len3 = 0
    len4 = 0
    len5 = 0
    if len(line) < start + 1:
        return 0, 0, 0, 0, 0, 0
    len1 = line[start]
    # 1st string
    if len1 > max1:
        return 2, 0, 0, 0, 0, 0
    start += len1 + 1
    if len(line) < start + 1:
        return 0, 0, 0, 0, 0, 0
    # 2nd string
    if no_of_strings > 1:
        len2 = line[start]
        if len2 > max2:
            return 2, 0, 0, 0, 0, 0
        start += len2 + 1
        if len(line) < start + 1:
            return 0, 0, 0, 0, 0, 0
    # 3rd string
    if no_of_strings > 2:
        len3 = line[start]
        if len3 > max3:
            return 2, 0, 0, 0, 0, 0
        start += len3 + 1
        if len(line) < start + 1:
            return 0, 0, 0, 0, 0, 0
    # 4th string
    if no_of_strings > 3:
        len4 = line[start]
        if len4 > max4:
            return 2, 0, 0, 0, 0, 0
        start += len4 + 1
        if len(line) < start + 1:
            return 0, 0, 0, 0, 0, 0
    # 5th string
    if no_of_strings > 4:
        len5 = line[start]
        if len5 > max5:
            return 2, 0, 0, 0, 0, 0
        start += len5 + 1
        if len(line) < start:
            return 0, 0, 0, 0, 0, 0
    return 1, len1, len2, len3, len4, len5


def copy_and_fill(line, start, le, max_, alpha):
    # append le le charrs from line to v_icom_vars.Civ_out anf fill with blanks up to max chars
    charcount = 0
    temp = 0
    while temp < le:
        if check_and_convert_alphabet(line[start], alpha) != 255:
            v_icom_vars.Civ_out.extend([line[start]])
            charcount += 1
        start += 1
        temp += 1
    while charcount < max_:
        # fill with blanks
        v_icom_vars.Civ_out.extend([0x20])
        charcount += 1
    return 1


def analyze_sk(t, input_buffer_number):
    if v_sk.hex_count == 0:
        v_sk.data = 0
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
        if v_sk.data < 256:
            v_sk.inputline[input_buffer_number].extend(bytearray([v_sk.data]))
            if v_icom_vars.test_mode == 1:
                print("in: ", hex(v_sk.data))
        v_sk.data = ""
        v_sk.hex_count = 0
    return

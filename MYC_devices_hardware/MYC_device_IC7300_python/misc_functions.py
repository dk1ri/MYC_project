"""
name : misc_functions.py IC7300
last edited: 20210306
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
    list = []
    if le == 1:
        list. append(integ)
    elif le == 2:
        t = integ // 256
        list.append(t)
        t = integ % 256
        list.append(t)
    return list


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
    # up to 3 byte ba to int
    if no_of_bytes == 1:
        return (a >> 4) * 10 + (a & 0x0F)
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


def int_to_bcd_plusminus(line, max, bcdbytes, multiplier):
    # max is maximum for abs value -> max_int = 2 * max (0 base)
    # for 2 byte int values
    # for bcdbytes bcd digits, bcd reverse: low byte first
    int_value = line[2] * 256 + line[3]
    if int_value > 2 * max:
        return 2, 0
    if int_value > max:
        # positive
        int_value -= max
        negative = 0
    else:
        # 0 is negative
        int_value = max - int_value
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


def bcd_plusminus_to_int(line, start, max, bcdbytes, commandbytes, divisor):
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
        intvalue += max
    else:
        intvalue = max - intvalue
    temp1 = intvalue.to_bytes(commandbytes, byteorder="big")
    return temp1


def check_and_convert_alphabet(a, type):
    # used for answers, a= 255 should not happen
    aa = 255
    if type == 0:
        # nearly all , only check ALPHA 0
        if 0x1f < a < 0x7f:
            aa = a
        else:
            aa = 255
    elif type == 1:
        # symbol 1st char ALPHA 1
        if a == 0x2f or a == 0x5c:
            aa = a
        elif 57 < a < 58:
            # numeric
            aa = a
        elif 64 < a < 91:
            aa = a
    elif type == 3:
        # CW check only ALPHA 3
        if (a > 64) and (a < 91):
            aa = a + 32
        elif (a > 96) and (a < 123):
            aa = a
        elif (a > 42) and (a < 59):
            aa = a
        elif a in [0x20, 0x22, 0x27, 0x28, 0x29, 0x3d, 0x3f, 0x40]:
            aa = a
        else:
            aa = 255
    elif type == 4:
        # call sign ALPHA 4
        if (a > 64) and (a < 91):
            aa = a
        elif (a > 46) and (a < 58):
            aa = a
        elif a == 0x20:
            aa = a
        elif a == 0x2f:
            aa = a
        else:
            aa = 255
    elif type == 5:
        # call sign ALPHA 5 (1a02)
        if (a > 63) and (a < 91):
            aa = a
        elif (a > 45) and (a < 58):
            aa = a
        elif a == 0x20:
            aa = a
        elif a == 0x2a:
            aa = a
        elif a == 0x2c:
            aa = a
        elif a == 0x5e:
            aa = a
        elif a == 0x3f:
            aa = a
        else:
            aa = 255
    return aa


def find_token(civ_command):
    code = 0
    if len(civ_command) == 1:
        try:
            stri = str(hex(civ_command[0]))
            code = v_icom_vars.civ_code_to_token[stri]
        except KeyError:
            code = 0
    elif len(civ_command) == 2:
        try:
            stri = str(hex(civ_command[0])) + str(hex(civ_command[1]))
            code = v_icom_vars.civ_code_to_token[stri]
        except KeyError:
            code = 0
    elif len(civ_command) == 3:
        try:
            stri = str(hex(civ_command[0])) + str(hex(civ_command[1])) + str(hex(civ_command[2]))
            code = v_icom_vars.civ_code_to_token[stri]
        except KeyError:
            code = 0
    elif len(civ_command) == 4:
        try:
            stri = str(hex(civ_command[0])) + str(hex(civ_command[1])) + str(hex(civ_command[2])) + str(hex(civ_command[3]))
            code = v_icom_vars.civ_code_to_token[stri]
        except KeyError:
            code = 0
    if code > 0:
        v_sk.answer_token = int_to_list(code, 2)
        return 1
    return 2


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


def copy_and_fill(line, start, le, max, alpha):
    # append le le charrs from line to v_icom_vars.Civ_out anf fill with blanks up to max chars
    charcount = 0
    temp = 0
    while temp < le:
        if check_and_convert_alphabet(line[start], alpha) != 255:
            v_icom_vars.Civ_out.extend([line[start]])
            charcount += 1
        start += 1
        temp += 1
    while charcount < max:
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

"""
name : helper_get_trx.py
Version 01.0, 20220308
call with: helper_get_trx.py <device> number_of_tokenbytes 1 or 2>
Purpose : Program to read all initial data (answercommands) at start from the transceiver
The loopback address is used to connect the python interface program.
That works better than an address 192... ,
The complete read may take  minutes!!!

input: file: ___announcements (original)
intermediate: data: annoncements as delivered by CR
intermediate: data all_answer_tokens: token (data and data for stack|memorylocation)
output: file _all_answer_data: <token (commandtoken for correspnding answertoken) decimal> <values in hex with selectors stripped>
"""
# general
import os
import sys
import socket
import threading

device = "commandrouter"
if len(sys.argv) > 2:
    device = sys.argv[1]
    path = "./" + device
    if os.path.exists(path):
        pass
    else:
        print("device ", device, " does not exists")
    number_of_tokenbytes = int(sys.argv[2])
    if number_of_tokenbytes > 2:
        number_of_tokenbytes = 2
else:
    sys.exit("call with: helper_get_device_data.py <device>")

announcements = ""
# not necessary with use of commandrouter
# strip data content for operate and answer commands
# ignore others
announce_file = open(device + "/___announcements")
an = []
for lines in announce_file:
    if lines[0] != "D":
        continue
    # Data lines only
    lines = lines.rstrip(chr(10))
    lines_ = lines.split("\"")
    # now data only
    if lines_[1][0] == "R":
        continue
    an.append(lines_[1])


# concatenate lines with same token
i = 0
last_line = ""
last_token = ""
ann = []
while i < len(an):
    field = an[i].split(";")
    if last_token == field[0]:
        # append to last_line (empty at beginning only)
        j = 2
        while j < len(field):
            if j == len(field) - 1:
                last_line += field[j]
            else:
                last_line += field[j] + ";"
            j += 1
    else:
        # store last line
        if last_line != "":
            ann.append(last_line)
        # actual line for next line
        last_line = an[i]
        last_token = field[0]
    i += 1
if last_line != "":
    ann.append(last_line)
an = []


# resolve "as" lines
last_line = ""
last_token = 0
i = 0
while i < len(ann):
    n_tok = int(ann[i].split(";")[0])
    if len(ann[i].split(";")[1].split(",")) > 1:
        asfield = ann[i].split(";")[1].split(",")[1]
        if last_token + 1 == n_tok and asfield[0:2] == "as":
            # resolve "as"
            lin = last_line
            lin[0] = str(n_tok)
            new_command_type = "a" + lin[1].split(",")[0][1] + ",ext" + str(n_tok - 1)
            if len(lin[1].split(",")) > 1:
                new_command_type += "," + lin[1].split(",")[1]
            lin[1] = new_command_type
            an.append(";".join(lin))
        else:
            an.append(ann[i])
    last_line = ann[i].split(";")
    last_token = int(last_line[0])
    i += 1

# an as by CR now

# delete OPTION fields at the end, not needed here
ann = []
for line in an:
    line = line[:-1]
    fields = line.split(";")
    i = 0
    li = []
    while i < len(fields):
        if fields[i].find("CHAPTER") != -1 or fields[i].find("METER") != -1:
            break
        i += 1
    fiel = fields[:i]
    jo = ";".join(fiel)
    ann.append(jo)
    #
"""
all_answer_tokens:
find answercommand lines (also for corresponding operate commands ("ext"))
ignore commands without corresponding answertoken
those with stack > 1 will ask for 1st stack only ("00" or "0000" added),
for memories: first location only
will be used to ask for the actual content of a device
"""
lasttoken = 0
i = 0
all_answer_tokens = []
for line in ann:
    field = line.split(";")
    if field[1].split(",")[0:4] == "ext":
        type = "o"
    else:
        type = "a"
    ot = field[1][0]
    if ot == "a" or ot == "s" or ot == "l":
        # memory commands have no stack but memory location
        token = field[0]
        # function:
        of = field[1][1]
        if of == "r" or of == "s" or of == "t" or of == "u" or of == "p" or of == "o":
            # with stacks
            selectors = int(field[2].split(",")[0])
            if selectors > 1:
                if selectors > 65535:
                    token = token + " 6" + " 000000"
                if selectors > 255:
                    token = token + " 4" + " 0000"
                else:
                    token = token + " 2" + " 00"
            else:
                token = token + "0"
            # answer command: 1 additional parameter if more than one
            if of == "r":
                if len(field) > 3:
                    if selectors < 2:
                        token += " "
                    if len(field) > 259:
                        token = token + "0000"
                    else:
                        token = token + "00"
        # other memory: am: one paramter, an: 2 paramters, af: one paramter
        if of == "m" or of == "f":
            # one parameter
            i = 3
            mem_num = 1
            while i < len(field):
                s = field[i].split(",")
                if s[0][0] == "a":
                    mem_num += int(s[0][1:])
                else:
                    mem_num *= int(s[0])
                i += 1
            if mem_num > 255:
                token = token + " 4" + " 0000"
            else:
                token = token + " 2" + " 00"
        elif of == "n":
            # two parameter
            if int(field[3]) > 256:
                token = token + " 8" + " 00000001"
            else:
                token = token + " 4" + " 0001"
        elif of == "a":
            if len(field) > 3:
                if len(field) > 258:
                    token = token + " 42" + " 0000"
                else:
                    token = token + " 2" + " 00"
        elif of == "b":
            # two parameter
            if len(field) > 258:
                token = token + " 8" + " 00000001"
            else:
                token = token + " 4" + " 0001"
        # others (d) ignored
        if i > 0:
            all_answer_tokens.append(chr(10))
        all_answer_tokens.append(type + " " + token)
        i += 1
    else:
        last_token = field[0]

# read ata from device
# output token_(decimal) data_hex (including selector data)
TRX_VALUE_FILENAME = device + "\_all_answer_data"
# create new token for selectors if stack > 1
# read actual configaration of device
# HOST = '192.168.2.100'
host = '127.0.0.1'
port = 23
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect((host, port))
client_socket.settimeout(3)
with open(TRX_VALUE_FILENAME, "w") as output:
    for token in all_answer_tokens:
        lines = token.split()
        if lines[0] == "a":
            tok = lines[1]
        else:
            tok = f"{(int(lines[1]) + 1):4x}"
        text = f"{int(lines[1]):04x}"
        if len(lines) > 1:
            text += lines[2]
        client_socket.sendall(text.encode())
        try:
            data = client_socket.recv(4096)
        except socket.timeout:
            out = tok + " "
            if len(lines) > 1:
                out += lines[2]
            out += "00"
            print("timeout", out)
        else:
            out_ = "".join(f"{char:02x}" for char in data)
            out = out_[:-2]
            if out == "":
                out = lines[0]
                out += " "
                # add selectors
                if len(lines) > 1:
                    out += lines[1]
                out += "00"
            else:
                if number_of_tokenbytes == 1:
                    out = str(int(out_[0:2], 8)) + " " + out_[2:-2]
                else:
                    out = str(int(out_[0:4], 16)) + " " + out_[4:-2]
            print("client received ", out)
        output.write(out + "\n")

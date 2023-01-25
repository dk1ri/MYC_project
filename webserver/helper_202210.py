"""
name : helper_2022.py
Author: DK1RI
Version 01.0, 20230108
call with: helper_202210.py <device>
Purpose :
make some modifications on announcement file
create displayable objects (tokens) for webserver
"""
# general
import os
import sys
import shutil


def basic_tok(token):
    if token.find("c") != -1:
        return token.split("c")[0]
    # for "ADD"
    elif token.find("b") != -1:
        # for stack and memory selector
        return token.split("b")[0]
    elif token.find("k") != -1:
        # oa aa ob ab
        return token.split("k")[0]
    elif token.find("l") != -1:
        # os as or ar o at
        return token.split("l")[0]
    elif token.find("m") != -1:
        # om an
        return token.split("m")[0]
    elif token.find("n") != -1:
        # on an
        return token.split("n")[0]
    elif token.find("p") != -1:
        # op ap
        return token.split("p")[0]
    if token.find("q") != -1:
        # oo
        return token.split("q")[0]
    if token.find("w") != -1:
        # memory selector
        return token.split("w")[0]
    if token.find("x") != -1:
        # memory data
        return token.split("x")[0]
    else:
        return token

def replace_cr():
    # select operate and sole answer commands
    # ignore others ( i, z)
    # write dependent answer commands to answer_commands
    announce_file = ""
    for afile in os.listdir(device):
        if afile == "_announcements":
            announce_file = open(device + "/_announcements")
            break
        elif afile == "__announcements":
            announce_file = open(device + "/__announcements")
            break
        elif afile == "___announcements":
            announce_file = open(device + "/___announcements")
            break
        elif afile == "_announcements.bas":
            announce_file = open(device + "/_announcements.bas")
            break
        elif afile == "__announcements.bas":
            announce_file = open(device + "/__announcements.bas")
            break
        elif afile == "___announcements.bas":
            announce_file = open(device + "/___announcements.bas")
            break
    if announce_file == "":
        sys.exit("no annoncefile")
        
    an = []
    for alines in announce_file:
        if alines[0] != "D":
            continue
        # Data lines only
        alines = alines.rstrip(chr(10))
        lines_ = alines.split("\"")
        # now data only
        if lines_[1][0] == "R":
            continue
        an.append(lines_[1])
    # concatenate lines with same token
    ia = 0
    last_line = ""
    last_token = ""
    ann = []
    while ia < len(an):
        fielda = an[ia].split(";")
        if last_token == fielda[0]:
            # append to last_line (empty at beginning only)
            ja = 2
            while ja < len(fielda):
                if ja == len(fielda) - 1:
                    last_line += fielda[ja]
                else:
                    last_line += fielda[ja] + ";"
                ja += 1
        else:
            # store last line
            if last_line != "":
                ann.append(last_line)
            # actual line for next line
            last_line = an[ia]
            last_token = fielda[0]
        ia += 1
    if last_line != "":
        ann.append(last_line)
    an = []
    #
    # delete answer "as" lines and "ext" lines
    answer_commands = []
    i = 0
    last_tok = ""
    while i < len(ann):
        # a and o and basiccommand only
        if ann[i].split(";")[0] != "0":
            ot = ann[i].split(";")[1].split(",")[0][0]
            if ot != "o" and ot != "a":
                i += 1
                continue
        # delete METER
        field = ann[i].split(";")
        if ann[i].find("METER") != -1:
            j = 0
            while j < len(field):
                if field[j].find("METER") != -1:
                    break
                j += 1
            field = field[:j]
            ann[i] = ";".join(field)
        act_tok = ann[i].split(";")[0]
        if ann[i].split(";")[1].split(",")[0][0] != "a":
            an.append(ann[i])
            last_tok = ann[i].split(";")[0]
        else:
            # a commands
            if len(ann[i].split(";")[1].split(",")) > 1:
                asfield = ann[i].split(";")[1].split(",")[1]
                if asfield[0:2] == "as" or asfield[0:3] == "ext":
                    answer_commands.append(act_tok + " " + last_tok)
                else:
                    an.append(ann[i])
            else:
                an.append(ann[i])
        i += 1
    return an


device = "commandrouter"
if len(sys.argv) != 1:
    device = sys.argv[1]
    path = "./" + device
    if os.path.exists(path):
        pass
    else:
        print("device ", device, " does not exists")
else:
    sys.exit("call with: helper2022.py <device>")
#
cr_ann = replace_cr()
#
filename = "./" + device + "/" + "announcements"
if os.path.exists(filename):
    os.remove(filename)
file = open(filename, "a")
i = 0
for lines in cr_ann:
    if i > 0:
        file.write(chr(10))
    file.write(lines)
    i += 1

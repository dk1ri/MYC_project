"""
name : helper_2022.py
Author: DK1RI
Version 01.0, 20231130
call with: helper_202210.py <device>
Purpose :
make some modifications on announcement file
create displayable objects (tokens) for webserver
"""
# general
import os
import sys
import shutil


def replace_cr():
    # select operate and sole answer commands
    # ignore others ( i, z)
    # write dependent answer commands to answer_commands
    announce_file = ""
    for afile in os.listdir("devices/" + device):
        if afile == "_announcements":
            announce_file = open("devices/" + device + "/_announcements")
            break
        elif afile == "__announcements":
            announce_file = open("devices/" + device + "/__announcements")
            break
        elif afile == "___announcements":
            announce_file = open("devices/" + device + "/___announcements")
            break
        elif afile == "_announcements.bas":
            announce_file = open("devices/" + device + "/_announcements.bas")
            break
        elif afile == "__announcements.bas":
            announce_file = open("devices/" + device + "/__announcements.bas")
            break
        elif afile == "___announcements.bas":
            announce_file = open("devices/" + device + "/___announcements.bas")
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
    # concatenate lines with same token:
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
    answer_commands = []
    i = 0
    last_tok = ""
    last_ann = ""
    ank = []
    while i < len(ann):
        # expand as commands
        if (len(ann[i].split(";")[1].split(",")) > 1):
            if ann[i].split(";")[1].split(",")[1][0:2] != "as":
                last_tok = ann[i].split(";")[0]
                last_ann = ann[i]
                ank.append(ann[i])
            else:
                # a commands follow directly
                if last_ann != "":
                    act_tok = ann[i].split(";")[0]
                    act_ct = ann[i].split(";")[1]
                    ann[i] = last_ann
                    a = ann[i].split(";")
                    a[0] = act_tok
                    a[1] = act_ct
                    ank.append(";".join(a))
                    last_ann = ""
        else:
            last_tok = ann[i].split(";")[0]
            last_ann = ann[i]
            ank.append(ann[i])
        i += 1
    i = 0
    while i < len(ank):
        an.append(ank[i])
        i += 1
    return an


device = "commandrouter"
if len(sys.argv) != 1:
    device = sys.argv[1]
    path = "./devices/" + device
    if os.path.exists(path):
        pass
    else:
        print("device ", device, " does not exists")
else:
    sys.exit("call with: helper2022.py <device>")
#
cr_ann = replace_cr()
#
filename = "./devices/" + device + "/" + "announcements"
if os.path.exists(filename):
    os.remove(filename)
file = open(filename, "a")
i = 0
for lines in cr_ann:
    if i > 0:
        file.write(chr(10))
    file.write(lines)
    i += 1

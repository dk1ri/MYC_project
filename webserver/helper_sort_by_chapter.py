"""
name : helper_sort_by_chapter.py
Author: DK1RI
Version 01.0, 202203225
call with: helper_sort_by_chapter.py <device> <token_length>
Purpose :
sort _announcedata by chapter and make some modifications

The result for further usage is announce_lines_<chapter>:
"as" lines deleted
announcelines with added selectors
splitted op / ap lines (per dimension)
sorted by chapter
"""
# general
import os
import sys


def basic_tok(token):
    if token.find("_") != -1:
        return token[token.find("_"):]
    elif token.find("a") != -1:
        return token[token.find("a"):]
    elif token.find("p") != -1:
        return token[token.find("p"):]
    return


def create_mul(token_, mul_):
    # create additional selector lines for each "mul" dimension
    # mul_ contain description inside "{"... "}"
    # MUL inside MUL is nor supported
    mul = mul_.split("MUL,")
    jj = 0
    kk = 0
    while jj < len(mul):
        # one ADD can be in the last MUL element only (after MUL)
        if mul[jj].find("ADD") != -1:
            add = mul[jj].split("ADD,")
            work_on_mul(token_, add[0], "_", kk)
            kk += 1
            work_on_mul(token_, add[1], "a", kk)
        else:
            work_on_mul(token_, mul[jj], "_", kk)
        jj += 1
        kk += 1
    return


def work_on_mul(token_, selector_decription, add, selector):
    selector_decription_ = selector_decription
    if selector_decription[-1] == ",":
        selector_decription_ = selector_decription[:-1]
    sel = selector_decription_.split(",")
    selections = sel[0]
    del sel[0]
    if sel[0].find("{") == -1:
        name__ = sel[0]
        if len(sel) > 1:
            # name, range
            range_ = sel[1:]
        else:
            # name, no range
            range_ = ""
    else:
        # no name, range
        name__ = ""
        range_ = sel
    create_one_selector(token_, selections, name__, range_, add, selector)
    return


def create_one_selector(token_, selections, selector_name_, range_, add, selector_number):
    global all_announcelines
    global announce
    global chapter_name
    global chapter_names
    if selector_name_ == "":
        selector_name_ = "selector"
    lin = token_ + add + str(selector_number) + ";os," + selector_name_ + ";1;"
    k = 0
    while k < int(selections):
        if k < int(selections) - 1:
            if range_ == "":
                lin += str(k) + "," + str(k) + ";"
            else:
                lin += str(k) + "," + range_[k] + ";"
        else:
            if range_ == "":
                lin += str(k) + "," + str(k)
            else:
                lin += str(k) + "," + range_[k]
        k += 1
    lin = lin.replace("}", "")
    lin = lin.replace("{", "")
    all_announcelines.append(lin)
    announce[chapter_names.index(chapter_name)].append(lin)
    return


def create_memory_selector(token_, selections, selector_name_, range_, sequence):
    if selector_name_ == "":
        selector_name_ = "selector"
    lin = token_ + "_" + str(sequence) + ";os," + selector_name_ + ";1;"
    k = 0
    indiv_selector = range_.split(",")
    while k < int(selections):
        if range_ == "":
            lin += str(k) + "," + str(k) + ";"
        else:
            # range is used for "a" selectors with individual seletions
            if k < len(indiv_selector):
                lin += str(k) + "," + indiv_selector[k] + ";"
            else:
                lin += str(k) + "," + str(k) + ";"
        k += 1
    announce[chapter_names.index(chapter_name)].append(lin)
    return


def writefile(device_, filename_, data):
    filename = device_ + "/" + filename_
    if os.path.exists(filename):
        os.remove(filename)
    file = open(filename, "a")
    i = 0
    for lines in data:
        if i > 0:
            file.write(chr(10))
        file.write(lines)
        i += 1
    file.close()
    return


def extline(token, anno):
    i  = 0
    while i < len(anno):
        if anno[i].split(";")[0] == token:
            return anno[i]
        i += 1
    return ""


def replace_cr():
    # strip data content for operate and answer commands
    # ignore others
    announce_file = ""
    for file in os.listdir(device):
        if file == "_announcements":
            announce_file = open(device + "/_announcements")
            break
        elif file == "__announcements":
            announce_file = open(device + "/__announcements")
            break
        elif file == "___announcements":
            announce_file = open(device + "/___announcements")
            break
    if announce_file == "":
        sys.exit("no annoncefile")
        
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
    #
    # delete "as" lines and answer lines with "ext"
    i = 0
    while i < len(ann):
        if (ann[i].split(";")[1].split(",")[0] == "oo"):
            an.append(ann[i])
        else:
            if len(ann[i].split(";")[1].split(",")) > 1:
                asfield = ann[i].split(";")[1].split(",")[1]
                if asfield[0:2] == "as":
                    pass
                elif asfield[0:3] == "ext":
                    pass
                else:
                    an.append(ann[i])
        i += 1
    return an


def sort_announcelines_by_chapter(an):
    # sort announcelines by chapter to announce_lines_chapter
    # for stacks > 1 and memories additional lines are added as a selector (os type):
    # selector_token;os;1;0,0;....."
    # contain all answer and operate lines except answer commands with preceeding corresponding operate-command (ext)
    # all token to be used by the website
    # delete ext lines (but not oo commands)
    global all_announcelines
    global announce
    global chapter_name
    global chapter_names
    chapter_name = "no_chapter"
    chapter_names = []
    all_announcelines = []
    announce = []
    done = 0
    for line in an:
        line = line.rstrip("\n")
        field = line.split(";")
        if field[1].find("ext") != -1:
            # ;ct,extxxx,..;
            ext_token = field[1].split(",")[1].split("ext")[1]
            ext_line = extline(ext_token, an)
        # handle chapternames
        if line.find("CHAPTER") != -1:
            # CHAPTER marking found
            j = 0
            while j < len(field):
                if field[j].find("CHAPTER") != -1:
                    chapter_name = field[j + 1]
                    break
                j += 1
            field = field[:j]
            line = ";".join(field)
            if not (chapter_name in chapter_names):
                # create new chapter
                chapter_names.append(chapter_name)
                announce.append([])
                announce[chapter_names.index(chapter_name)] = []
        else:
            chapter_name = "no_chapter"
        #
        # delete METER
        if line.find("METER") != -1:
            j = 0
            while j < len(field):
                if field[j].find("METER") != -1:
                    break
                j += 1
            field = field[:j]
            line = ";".join(field)
        # create announcelines
        # create selectors for stack for switches and range commands; operate and answercommands
        select_tokens = []
        token = field[0]
        if field[1][1] == "r" or field[1][1] == "s" or field[1][1] == "t" or field[1][1] == "u" or field[1][1] == "p" or field[1][1] == "o":
            stack = field[2].split(",")
            all_selections = int(stack[0])
            if all_selections > 1:
                # selectors necessary
                if len(stack) == 1:
                    # stacks
                    # no name, no range, no add, selector_number=0
                    create_one_selector(field[0], all_selections, "", "", "_", 0)
                else:
                    if stack[1].find("{") == -1:
                        # stacks,name
                        # (stacks,{...   would have len > 2; no range, no add, selector_number=0
                        create_one_selector(field[0], all_selections, stack[1], "", "_", 0)
                    else:
                        # stacks with description,{.....}
                        sta = stack
                        del sta[0]
                        sta = ",".join(sta)
                        sta = sta[1:-1]
                        # now: description only: number_of_selecttions,<name><{..}>
                        des = sta.split(",")
                        if len(des) == 2:
                            if des[1].find("{") == -1:
                                # not used usually
                                # (stacks,{...   would have len > 2; n range, no add, selector_number=0
                                create_one_selector(field[0], all_selections, des[1], "", "_", 0)
                            else:
                                # with range
                                create_one_selector(field[0], all_selections, "", des, "_", 0)
                        else:
                            #  with {>mul<}>
                            create_mul(field[0], ",".join(des))
        if field[1][1] == "m" or field[1][1] == "n":
            # create selectors for each row, column ... for memories
            # first row at pos 3
            row_col = 3
            total = 1
            while row_col < len(field):
                sel_name = "mem_dimension"
                if len(field[row_col].split(",")) > 1:
                    if field[row_col].split(",")[1][0]!= "{":
                        sel_name = field[row_col].split(",")[1]
                # range is used for "a" selectors with individual seletions
                range = ""
                add_selections = field[row_col].split(",")[0]
                if add_selections[0] == "a":
                    add_selections = add_selections[1:]
                    sel_name = "additional: "
                    if len(field[row_col].split(",")) > 1:
                        range = field[row_col].split(",")[1]
                    total += int(add_selections)
                else:
                    total *= int(add_selections)
                create_memory_selector(field[0], int(add_selections), sel_name, range, row_col - 3)
                row_col += 1
            if field[1][1] == "n":
                sel_name = ""
                range = ""
                if len(field[1].split(",")) > 2:
                    sel_name = field[1].split(",")[1]
                create_memory_selector(field[0], int(total) - 1, "number " + sel_name, range, row_col - 3)
        if field[1][1] == "a" or field[1][1] == "b":
            # one selector
            ct = field[1].split(",")
            if len(ct) > 1:
                selector_name = ct[1]
            else:
                selector_name = "x"
            li = token + "_" + "0;os," + selector_name + "_start ;1"
            i = 3
            while i < len(field):
                a_field = field[i].split(",")
                if len(a_field) > 1:
                    li += ";" + str(i - 3) + "," + a_field[1]
                else:
                    li += ";" + str(i - 3) + "," + "x"
                i += 1
            announcelines.append(li)
            select_tokens.append(token + "_" + "0")
            if field[1][1] == "b":
                li = token + "_" + "1;os," + selector_name + "_number ;1;"
                i = 3
                while i < len(field) - 1:
                    li += ";" + str(i - 3) + "," + str(i - 2)
                select_tokens.append(token + "_" + "1")
        if field[1][1] == "p":
            # split dimensions
            dim = 3
            i = 0
            while dim < len(field):
                tok = field[0]
                if len(field) == 6:
                    pass
                else:
                    if dim + 4 < (len(field)):
                        tok = tok + "p" + str(i)
                line = tok + ";" + ";".join(field[1:3]) + ";" + ";".join(field[dim:dim + 3])
                announce[chapter_names.index(chapter_name)].append(line)
                all_announcelines.append(line)
                dim += 3
                i += 1
            done = 1
        if field[1][1] == "o":
            # split dimensions
            dim = 3
            i = 0
            while dim < len(field):
                tok = field[0]
                if len(field) == 9:
                    pass
                else:
                    if dim + 7 < (len(field)):
                        tok = tok + "o" + str(i)
                line = tok + ";" + ";".join(field[1:3]) + ";" + ";".join(field[dim:dim + 6])
                announce[chapter_names.index(chapter_name)].append(line)
                all_announcelines.append(line)
                dim += 6
                i += 1
            done = 1
        if done == 0:
            announce[chapter_names.index(chapter_name)].append(line)
            all_announcelines.append(line)

    return


device = "commandrouter"
if len(sys.argv) != 1:
    device = sys.argv[1]
    path = "./" + device
    if os.path.exists(path):
        pass
    else:
        print("device ", device, " does not exists")
else:
    sys.exit("call with: helper_replace.py <device>")

chapter_names = []
all_announcelines = []
announce = []
chapter_name = ""
#
cr_ann = replace_cr()
#
sort_announcelines_by_chapter(cr_ann)
#
# copy announce by chapter to file
for name in chapter_names:
    if announce[chapter_names.index(name)]:
        writefile(device, "announce_lines_" + name, announce[chapter_names.index(name)])
<?php
# split_to_display_objects.php
# DK1RI 20230608
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function split_to_display_objects(){
    $device = $_SESSION["device"];
    $_SESSION["chapter_names"][$device]["all_basic"] = "all_basic";
    $_SESSION["activ_chapters"][$device]["all_basic"] = "all_basic";
    $_SESSION["chapter_names"][$device]["ADMINISTRATION"] = "ADMINISTRATION";
    $_SESSION["activ_chapters"][$device]["ADMINISTRATION"] = "ADMINISTRATION";
    $_SESSION["chapter_index"][$device] = [];
    $_SESSION["chapter_token"][$device] = [];
    $_SESSION["chapter_token"][$device]["all_basic"] = [];
    $_SESSION["chapter_token"][$device]["ADMINISTRATION"] = [];

    # token for all display elements:
    # announce_all has no "asxx" token!!
    # they are defined in "cor_token!!
    # toka:     answer token -> ct
    # tokmx:    stack -> ct
    # toknx:    ADD -> ct
    # tokdx:    data -> ct for memory data -> ct memtype
    $_SESSION["announce_all"][$device] = [];
    # contain ranges for all token of announce_all:
    $_SESSION["des"][$device] = [];
    # contain name for all token of announce_all:
    $_SESSION["des_name"][$device] = [];
    # token for _POST to check / correct
    # contain des_range
    $_SESSION["to_correct"][$device] = [];
    # to delete:
    $_SESSION["des_range"][$device] = [];
    # to delete:
    $_SESSION["des_type"][$device] = [];
    # used?
  #  $_SESSION["des_type_with_restricions"][$device] = [];
    # for all op commands:
    $_SESSION["unit"][$device] = [];
    # max value for display element
    $_SESSION["max_for_send"][$device] = [];
    $_SESSION["oo_tok"][$device] = [];
  #  $_SESSION["defaults"][$device] = [];
    # create $_SESSION["original_announce"][$device] from announcefile
    # and $_SESSION["chapter_token"][$device]
    if (file_exists("./devices/".$device."/announcements")) {
        $file = fopen("./devices/".$device . "/announcements", "r");
        while (!(feof($file))) {
            $pure = fgets($file);
            $pure = str_replace("\n", '', $pure);
            $line = str_replace("\r", '', $pure);
            $field = explode(";", $line);
            $token = $field[0];
            $lda =[];
            # delete CHAPTER
            $i= 2;
            $temp = $field[1];
            $last_was_chap = 0;
            while ($i < count($field)) {
                if(!strstr($field[$i],",CHAPTER,")) {
                    if ($last_was_chap == 0) {
                        $lda[] = $temp;
                    }
                    $temp = $field[$i];
                    $last_was_chap = 0;
                }
                else {
                    $last_was_chap = 1;
                    $lda[] = $temp;
                }
                $i += 1;
            }
            if ($temp != "" and !$last_was_chap){
                $lda[] = $temp;
            }
            $new_tok = $token;
            if ($lda[0] == "op") {
                $last_is_op = 1;
                $last_op_tok = basic_tok($token);
            }
            elseif ($lda[0] == "oo"){
                if ($last_is_op == 1) {
                    $_SESSION["oo_tok"][$device][$token] = $last_op_tok;
                }
            }
            if (!array_key_exists($token, $_SESSION["a_to_o"][$device])) {
                $_SESSION["original_announce"][$device][$token] = $lda;
                if (!strpos($line, "14,CHAPTER,ADMINISTRATION")) {
                    $_SESSION["chapter_token"][$device]["all_basic"][$token] = 1;
                }
                if (strpos($line, "CHAPTER,")) {
                    $ar = explode("CHAPTER", "$line");
                    $chap = explode(",", $ar[1])[1];
                    $_SESSION["chapter_token"][$device][$chap][$token] = 1;
                    $_SESSION["chapter_names"][$device][$chap] = $chap;
                    $_SESSION["activ_chapters"][$device][$chap] = $chap;
                }
            }
        }
        fclose($file);
    }
    # create display-objects
    foreach ($_SESSION["original_announce"][$device] as $basic_tok => $announce_o) {
        $ct = explode(",", $announce_o[0])[0];
        $ctm = substr($ct,1);
        if ($announce_o[0] == "m") {
            expand_m($basic_tok, $announce_o);
        }
        if ($ctm == "r" or $ctm == "s" or $ctm == "t" or $ctm == "u" or $ctm == "p" or $ctm == "o") {
            des_memory($basic_tok, $announce_o, $ct);
        }
        if ($ctm == "r" or $ctm == "s" or $ctm == "t" or $ctm == "u") {
            expand_s($basic_tok, $announce_o, $ct, $ctm);
        }
        if ($ctm == "p") {
            expand_p($basic_tok, $announce_o);
        }
        if ($ctm == "o"){
            expand_o($basic_tok, $announce_o);
        }
        if ($ctm == "m" or $ctm == "n") {
            expand_m_n($basic_tok, $announce_o);
        }
        if ($ctm == "a" or $ctm == "m") {
            expand_a_b($basic_tok, $announce_o);
        }
    }
}

function des_range($basic_tok, $data, $max_r, $s_number){
    $device = $_SESSION["device"];
    $data = str_replace("{", "", $data);
    $data = str_replace("}", "", $data);
    $result = $max_r;
    if ($max_r == 0){
        $_SESSION["des"][$device][$basic_tok . $s_number] = "0,0,0";
        $_SESSION["max_for_send"][$device][$basic_tok.$s_number] = $max_r;
        return;
    }
    if ($max_r > $_SESSION["conf"]["selector_limit"]){
        # too big
        $result = $max_r . "," . $data;
        # for all "big" selectors
        $_SESSION["to_correct"][$device][$basic_tok . $s_number] = $data;
    }
    else{
        # result: string: something like: max_r,0,0,1,1,2,2...
        $data = explode(",", $data);
        $i = 0;
        # $position: value to transmit:
        $position = 0;
        while ($i < count($data)){
            if (strstr($data[$i],"_")){
                # range
                $rang = explode("_", $data[$i]);
                $separator = $rang[0];
                $fr_to = explode("to", $rang[1]);
                $value = $fr_to[0];
                while ($value <= $fr_to[1]){
                    $result .= ",". $position.",". $value;
                    $value += $separator;
                    $position += 1;
                }
            }
            else {
                # fixed value
                $result .= "," . $position. "," . $data[$i];
                $position += 1;
            }
            $i += 1;
        }
    }
    $_SESSION["des"][$device][$basic_tok . $s_number] = $result;
    $_SESSION["max_for_send"][$device][$basic_tok.$s_number] = $max_r;
}

function des_one_mul($basic_tok, $des, $ct, $s_number, $defaultname){
    # des: string: max[,label][{,...}] ; not empty
    $device = $_SESSION["device"];
    $_SESSION["announce_all"][$device][$basic_tok . $s_number][0] = $ct;
    $max_r = explode(",",$des)[0];
    # delete max_r
    $range = explode(",", $des);
    array_splice($range,0, 1);
    if (count($range) == 0){
        # max only
        $_SESSION["des_name"][$device][$basic_tok . $s_number] = $defaultname;
        des_range($basic_tok, "1_0to". $max_r, $max_r, $s_number);
        # done
        return;
    }
    elseif (!strstr($range[0],"{")) {
        # label available
        $_SESSION["des_name"][$device][$basic_tok . $s_number] = delete_bracket($range[0]);
        # remove label:
        array_splice($range, 0, 1);
    }
    else {
        $_SESSION["des_name"][$device][$basic_tok . $s_number] = $defaultname;
    }
    if (count($range) == 0){
        $i = 0;
        $result = $max_r;
        while ($i < $max_r){
            $result .= "," . $i. ",". $i;
            $i += 1;
        }
        $_SESSION["des"][$device][$basic_tok . $s_number] = $result;
        $_SESSION["max_for_send"][$device][$basic_tok.$s_number] = $max_r;
    }
    else {
        # remaining: {...} -> des_range
        $data= implode(",", $range);
        des_range($basic_tok, $data, $max_r, $s_number);
    }
}

function des_memory($basic_tok, $announce_o, $ct){
    # this is for stacks only:  additional lines are added for selectors
    # toksx are used if number_of_stacks > 1
    # toks0 for stacks without MUL; with MUL contain max of all elements only
    # toksx (x>0) for each MUL ADD element (des_range)
    # it is assumed, that "high" numbers og stacks use the {... } notation always
    # so 0,1,2,... is not for "high" numbers!
    $stack = explode(",",$announce_o[1]);
    # always:
    $number_of_stacks = (int)$stack[0];
    $device = $_SESSION["device"];
    if ($number_of_stacks > 1){
        if (!strstr($announce_o[1], "MUL")) {
            # no MUL -> one MUL element only
            des_one_mul($basic_tok, $announce_o[1], $ct, "m0", "stack");
            return;
        }
        # with MUL with non-manual or manual selectors
        # remove $number_of_stack:
        array_splice($stack,0, 1);
        # [label],{...MUL...}
        # more than on element always!
        if (!strstr($stack[0],"{")) {
            # label available
            $_SESSION["des_name"][$device][$basic_tok . "m"] = delete_bracket($stack[0]);
            # remove label:
            array_splice($stack, 0, 1);
        }
        else {
            $_SESSION["des_name"][$device][$basic_tok . "m"] = "stack";
        }
        $stack = implode(",", $stack);
        # remaining: string: {...MUL...}
        $stack = substr($stack,1);
        $des_add = explode("ADD", $stack);
        $des_mul = explode("MUL", $des_add[0]);
        $i = 0;
        while ($i < count($des_mul)){
            # for MUL
            str_replace("{", "", $des_mul[$i]);
            des_one_mul($basic_tok, $des_mul[$i], $ct, "m".$i, "stack");
            $i += 1;
        }
        if (count($des_add) > 1){
            # for ADD
            des_one_mul($basic_tok, $des_add[1], $ct, "n1", "stack");
        }
    }
}

function expand_m($token, $announce){
    $device = $_SESSION["device"];
    $_SESSION["announce_all"][$device][$token."a"][0] = $announce[0][0];
    $_SESSION["des_name"][$device][$token] = "basic_ command";

}

function expand_s($basic_tok, $announce, $ct, $ctm){
    # announce_all: basic_tok   -> ct ( for operating)
    # announce_all: basic_toka  -> ct (for answer)
    # announce_all: basic_tokdx -> ct  (for data)
    # des: basic_tok.d0         -> switchpositions for s t u
    # des: basic<_tok.dx        -> switchpositions for r
    $device = $_SESSION["device"];
    switch ($ctm){
        case "r":
            $name_d = "switch";
        case "s":
            $name_d = "1/n switch";
        case "t";
            $name_d = "toggle switch";
        case "u":
            $name_d = "momentary switch";
    }
    count(explode(",",$announce[0])) > 1 ? $name = delete_bracket(explode(",",$announce[0])[1]): $name = $name_d;
    $_SESSION["des_name"][$device][$basic_tok] = $name;
    $result = [];
    if ($ctm == "r"){
        # one tok per position
        $i = 2;
        $j = 0;
        while ($i < count($announce)) {
            $_SESSION["announce_all"][$device][$basic_tok . "d" . $j][0] = $ct;
            $_SESSION["des"][$device][$basic_tok . "d" . $j] = $announce[$i];
            $i += 1;
            $j += 1;
        }
    }
    else {
        # string of positions (one tok)
        $i = 2;
        $result = "";
        while ($i < count($announce)) {
            if ($i != 2){$result .= ",";}
            $result .= $announce[$i];
            $i += 1;
        }
        $_SESSION["des"][$device][$basic_tok . "d0"] = $result;
        $_SESSION["announce_all"][$device][$basic_tok . "d0"][0] = $ct;
    }
    if($ct == "as" or $ct == "at") {
        $_SESSION["announce_all"][$device][$basic_tok . "a"][0] = $ct;
    }
}

function expand_p($basic_tok, $announce){
    $device = $_SESSION["device"];
    # split dimension
    $_SESSION["des"][$device][$basic_tok . "d0"] = "";
    count(explode(",", $announce[0])) > 1 ? $name = delete_bracket(explode(",", $announce[0])[1]) : $name = "range";
    $_SESSION["des_name"][$device][basic_tok($basic_tok)] = $name;
    # dimensions:
    $dim = 2;
    $d_number = 0;
    $ct = explode(",",$announce[0])[0];
    while ($dim < count($announce)) {
        $_SESSION["announce_all"][$device][$basic_tok . "d" . $d_number][0] = $ct;
        $max = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim])[0];
        $_SESSION["des"][$device][$basic_tok . "d" . $d_number] = $max. ",";
        $_SESSION["unit"][$device][$basic_tok . "d" . $d_number] = $_SESSION["original_announce"][$device][$basic_tok][$dim + 2];
        des_one_mul($basic_tok, $_SESSION["original_announce"][$device][$basic_tok][$dim], $ct, "d".$d_number, "count");
        $dim += 3;
        $d_number += 1;
    }
    if($ct[0] == "ap"){
        $_SESSION["announce_all"][$device][$basic_tok . "a"][0] = $ct;
    }
}

function expand_o($basic_tok, $announce){
    $device = $_SESSION["device"];
    $ct = explode(",",$announce[0])[0];
    # split dimensions
    $no_use = 0;
    $i = 0;
    while ($i < count($announce)){
        if (strstr($announce[$i], "4,LOOP")) {
            # optional byte available
            $no_use += 1;
        }
        if (strstr($announce[$i], "6,LIMIT")) {
            # optional byte available
            $no_use += 1;
        }
        if (strstr($announce[$i], "a,0") or strstr($announce[$i], "a,1")) {
            # optional LOOP LIMIT available
            $no_use += 1;
        }
        $i += 1;
    }
    # basic command: for name only
    count(explode(",", $announce[0])) > 1 ? $name = delete_bracket(explode(",", $announce[0])[1]) : $name = "change";
    $_SESSION["des_name"][$device][basic_tok($basic_tok)] = $name;
    # dimensions:
    $dim = 2;
    $d_number = 0;
    while ($dim < (count($announce) - $no_use)){
        $_SESSION["announce_all"][$device][$basic_tok . "d" . $d_number . "r"][0] = $ct;
        $max = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim])[0];
        if ($max < $_SESSION["conf"]["selector_limit"]) {
            des_one_mul($basic_tok,  $_SESSION["original_announce"][$device][$basic_tok][$dim], $ct, "d".$d_number. "r", "step");
        }
        else{
            $_SESSION["des"][$device][$basic_tok . "d" . $d_number . "r"] = $announce[$dim];
        }
        #
        $_SESSION["announce_all"][$device][$basic_tok . "d" . $d_number . "s"][0] = $ct;
        $max = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim + 1])[0];
        if ($max < $_SESSION["conf"]["selector_limit"]) {
            des_one_mul($basic_tok,  $_SESSION["original_announce"][$device][$basic_tok][$dim + 1], $ct, "d".$d_number. "s", "steptime");
        }
        else{
            $_SESSION["des"][$device][$basic_tok . "d" . $d_number . "s"] = $announce[$dim + 1];
        }
        $_SESSION["announce_all"][$device][$basic_tok . "d" . $d_number .  "t"][0] = $ct;
        $max = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim + 2])[0];
        if ($max < $_SESSION["conf"]["selector_limit"]) {
            des_one_mul($basic_tok,  $_SESSION["original_announce"][$device][$basic_tok][$dim + 2], $ct, "d".$d_number. "t", "count");
        }
        else{
            $_SESSION["des"][$device][$basic_tok . "d" . $d_number . "t"] = $announce[$dim + 2];
        }
        $_SESSION["unit"][$device][$basic_tok . "d" . $d_number . "t"] = $_SESSION["original_announce"][$device][$basic_tok][$dim + 3];
        $dim += 4;
        $d_number += 1;
    }
}


function expand_m_n($basic_tok, $announce){
    # create display-object for each row, column and data
    # first row (or count) at pos 3 of announcement
    $device = $_SESSION["device"];
    if (strstr($_SESSION["original_announce"][$device][$basic_tok],"{")){
        # corrections of _POST are made, if restistions are available
        $_SESSION["des_type_with_restricions"][$device][$basic_tok] = 1;
    }
    $ct = explode(",",$announce[0]);
    count($ct) > 1 ? $name = $ct[1] : $name = "memory";
    # for selectors one display-object (tok) per dimension
    # tok;ct;dimension_data
    $row_col = 2;
    while ($row_col < count($announce)){
        $tok = $basic_tok . "m" . strval($row_col - 2);
        # announce_all
        $_SESSION["announce_all"][$device][$tok][0] = $ct[0];
        # des_range
        if (($ct[0] == "on" or $ct[0] == "an") and $row_col == 2) {
            $desc_part = des_range($data, $max);
        }
        else{
            $desc_part = des_range($data, $max);
        }
        $_SESSION["des_range"][$device][$tok] = $desc_part;
        $row_col += 1;
    }
    # data
    $_SESSION["des_name"][$device][basic_tok($basic_tok) . "d0"] = $name;
    $_SESSION["announce_all"][$device][$basic_tok . "d0"][0] = $ct[0];
    $_SESSION["announce_all"][$device][$basic_tok . "d1"][0] = $ct[0];
    # des-type
    $typ_a = explode(",", $announce[1]);
    $_SESSION["des_type"][$device][$basic_tok . "d1"] = add_type($basic_tok . "d1", $typ_a);
    if($ct[0] == "am" or $ct[0] == "an"){
        $_SESSION["announce_all"][$device][$basic_tok . "a0"][0] = $ct[0];
    }
}

function expand_a_b($basic_tok, $announce){
    # [ b0 and b1] one tok per <ty> element
    $device = $_SESSION["device"];
    $name = "array element";
    $ct = explode(",", $announce[0])[0];
    if (count($ct) > 1) {
        $name = $ct[1];
    }
    $_SESSION["des_name"][$device][basic_tok($basic_tok) . "d0"] = $name;
    # sequence determines the display - sequence -> do this first:
    if (count($announce) > 2) {
        # additional selector for <ty>
        $_SESSION["announce_all"][$device][$basic_tok . "b1"][0] = $ct;
        $_SESSION["des_name"][$device][$basic_tok . "b1"] = $name;
        if ($ct[0] == "ob" or $ct[0] == "ab") {
            # used for number_of_elements
            $_SESSION["announce_all"][$device][$basic_tok . "b0"][0] = $ct;
            $_SESSION["des_name"][$device][$basic_tok . "b0"] = $name;
        }
        # x0 used for basic name
        $_SESSION["announce_all"][$device][$basic_tok . "d0"][0] = $ct;
        $_SESSION["des_name"][$device][$basic_tok . "d0"] = $name;
        # ob /ab as number of elements to transmit
        # des_type stat with "d1"
    }
    # then calculate the type
    $i = 1;
    $j = 1;
    while ($i < count($announce)) {
        $typ_a = explode(",", $announce[$i]);
        $_SESSION["announce_all"][$device][$basic_tok . "d" . $j][0] = $ct;
        $_SESSION["des_name"][$device][basic_tok($basic_tok) . "d" . $j] = $name;
        $_SESSION["des_type"][$device][$basic_tok . "d" . $j] = add_type($basic_tok . "d" . $j, $typ_a);
        $i += 1;
        $j += 1;
    }
    if (count($announce) > 2) {
        # add selector for more than 2 elements
        $li = "";
        $li_n = "0,0,";
        $i = 1;
        $j = 1;
        $found = 1;
        while ($found) {
            $tok = $basic_tok . "d" . $i;
            if (!array_key_exists($tok, $_SESSION["des_type"][$device])) {
                $found = 0;
            } else {
                if ($_SESSION["des_type"][$device][$tok][0] != "f") {
                    # ignore exponent
                    if ($j != 1) {
                        $li .= ",";
                        $li_n .= ",";
                    }
                    $value = explode(";", $_SESSION["des_type"][$device][$tok])[2];
                    $li .= strval($j - 1) . "," . $j . "_" . $value;
                    $li_n .= $j . "," . $j;
                    $j += 1;
                }
            }
            $i += 1;
        }
        $_SESSION["des_range"][$device][$basic_tok . "b0"] = $li_n;
        # additional selector for <ty> (number for b and) position
        $_SESSION["des_range"][$device][$basic_tok . "b1"] = $li;
    }
    if($ct[0] == "ab" or $ct[0] == "aa"){
        $_SESSION["announce_all"][$device][$basic_tok . "a0"][0] = $ct;
    }
}

function add_type($tok, $desc){
    # create des_type
    # $desc: array: type [CODING] [name] [{...}]
    # return:type;CODING;name;range;startvalue;endvalue (some may be empty)
    # startvalue;endvalue are limits for the real numeric values given by type
    #
    $typ = $desc[0];
    # find "CODING"
    if (count($desc) > 1) {
        if ($desc[1] == "CODING") {
            if (count($desc) > 3) {
                $label = $desc[3];
            } else {
                $label = $desc[2];
            }
            switch ($desc[2]) {
                case "UNIXTIME8":
                    return $typ . ";UNIXTIME8;" . $label . ";0;0to1000000000000;0;1000000000000;end";
                case "UNIXTIME4":
                    return $typ . ";UNIXTIME4;" . $label . ";0;0to4294967295;0;4294967295;end";
                case "TIME":
                    return $typ . ";TIME;" . $label . ";0;0to86400;0;86400;end";
                case "DAYSEC":
                    return $typ . ";DAYSEC;" . $label . ";0;0to60;0;60;end";
                case "DAYMIN":
                    return $typ . ";DAYMIN;" . $label . ";0;0to60;0;60;end";
                case "DAYHOUR":
                    return $typ . ";DAYHOUR;" . $label . ";0;0to60;0;60;end";
                case "DAY":
                    return $typ . ";DAY;" . $label . ";0;0to31;0;31;end";
                case "YEARDAY":
                    return $typ . ";YEARDAY;" . $label . ";0;0to365;0;365;end";
                case "YEARDAY0":
                    return $typ . ";YEARDAY;" . $label . ";0;0to4294967295;0;4294967295;end";
                case "MON":
                    return $typ . ";MON;" . $label . ";0;0to12;0;12;end";
                case "YEAR0":
                    return $typ . ";YEAR0;" . $label . ";0;0to65535;0;65535;end";
                case "YEARNA":
                    return $typ . ";YEAR0;" . $label . ";0;-2147483648to2147483647;-2147483648;2147483647;end";
            }
        }
    }
    # no CODING:
    if ($typ == "s" or $typ == "d") {
        # add exponent
        return "f;;exponent;-128to127;0;;end";
    }
    # else
    $type = $typ . ";;;;;;end";
    $type_a = explode(";", $type);
    if (is_numeric($desc[0])) {
        # ranges of characters not yet supported
        $type_a[2] = "alpha";
        if (array_key_exists(1, $desc)) {
            if (!strstr($desc[1], "{")) {
                $type_a[2] = $desc[1];
            }
        }
        $type_a[3] = "ALPHA";
        $type_a[4] = "a";
        $type_a[5] = "z";
    } else {
        list($type_a[4], $type_a[5]) = find_allowed($desc[0]);
        # default, may be overwritten
    }
    # eliminate type:
    array_splice($desc, 0, 1);
    if (count($desc) > 0) {
        if (!strstr($desc[0], "{")) {
            # label
            $type_a[2] = $desc[0];
            array_splice($desc, 0, 1);
        }
    }
    if (count($desc) > 0) {
        # one label only, now:
        # {...,.},xxx
        $desc = implode(",", $desc);
        $desc = explode("}", $desc);
        $desc = str_replace("{", "", $desc[0]);
        $type_a[3] = $desc;
        # find displaystart
        $desc_a = explode(",", $desc);
        if (!strstr($desc_a[0], "_") and !strstr($desc_a[0], "to")) {
            $type_a[4] = $desc_a[0];
        } else {
            $type_a[4] = explode("_", explode("to", $desc_a[0])[0])[1];
            # may be overwritten
            $type_a[5] = explode("to", $desc_a[0])[1];
        }
        array_splice($desc_a, 0, 1);
        $desc_len = count($desc_a);
        while ($desc_len > 0) {
            if (strstr($desc_a[0], "_") and strstr($desc_a[0], "to")) {
                $type_a[5] = explode("to", $desc_a[0])[1];
            } else {
                $type_a[5] = $desc_a[0];
            }
            array_splice($desc_a, 0, 1);
            $desc_len = count($desc_a);
        }
    }
    return implode(";", $type_a);
}

function expand_range($value){
    # in: a,b,c,ntom,....
    # return: sequence of values
    $i = 0;
    $result = "";
    $value_a = explode(",",$value);
    $k = 0;
    while ($i < count($value_a)){
        if(strstr($value_a[$i], "to") and strstr($value_a[$i], "_")){
            $split_to = explode("to",$value_a[$i]);
            $split__ = explode("_", $split_to[0]);
            $j = $split__[1];
            $to = $split_to[1];
            $spacing = $split__[0];
            while ($j <= $to){
                if ($k != 0){
                    $result .= ",";
                }
                $result .= $k . ",". $j;
                $j += $spacing;
                $k += 1;
            }
        }
        else{
            if ($k != 0){
                $result .= ",";
            }
            $result .= $k. "," . $value_a[$i];
            $k += 1;
        }
        $i += 1;
    }
    return $result;
}
?>

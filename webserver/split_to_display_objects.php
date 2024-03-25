<?php
# split_to_display_objects.php
# DK1RI 20240124
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function create_original_announce(){
    # create $_SESSION["original_announce"][$device] from announcements
    # and $_SESSION["chapter_token"][$device]
    # $SESSION[meter][$device]
    global $username, $language, $is_lang, $new_sequncelist, $device, $actual_data;
    $last_is_op = 0;
    $last_op_tok = "";
    if (file_exists("devices/".$device."/_announcements")) {$filename = "devices/".$device."/_announcements";}
    elseif (file_exists("devices/".$device."/__announcements")) {$filename ="devices/".$device."/__announcements";}
    elseif (file_exists("devices/".$device."/___announcements")) {$filename = "devices/".$device."/___announcements";}
    elseif (file_exists("devices/".$device."/_announcements.bas")) {$filename = "devices/".$device."/_announcements.bas";}
    elseif (file_exists("devices/".$device."/__announcements.bas")) {$filename = "devices/".$device."/__announcements.bas";}
    elseif (file_exists("devices/".$device."/___announcements.bas")) {$filename = "devices/".$device."/___announcements.bas";}
    else{echo "no anouncement file found";return;}
    $file = fopen($filename, "r");
    $an = [];
    while (!(feof($file))) {
        $pure = fgets($file);
        if ($pure[0] != "D"){continue;}
        $pure = str_replace("\n", '', $pure);
        $line = str_replace("\r", '', $pure);
        $line = explode("\"", $line);
        if ($line[1][0] == "R"){
            $_SESSION["rules"][$device][] = $line[1];
            continue;}
        $an[] = $line[1];
    }
    fclose($file);
    # concatenate lines with same token:
    $last_line = "";
    $last_token = "";
    $ann = [];
    $i = 0;
    while ($i < count($an)){
        $fielda = explode(";",$an[$i]);
        if ($last_token == $fielda[0]){
            # append to last_line (empty at beginning only)
            $j = 2;
            while( $j < count($fielda)){
                if ($j == count($fielda) - 1 ){
                    $last_line .= $fielda[$j];
                }
                else {
                    $last_line .= $fielda[$j] . ";";
                }
                $j += 1;
            }
        }
        else {
            # store last line
            if ($last_line != "") {
                $ann[] = $last_line;
            }
            # actual line for next line
            $last_line = $an[$i];
            $last_token = $fielda[0];
        }
        $i += 1;
    }
    if ($last_line != "") {
        $ann[] = $last_line;
    }
    $an = [];
    # expand as lines
    $last_line = "";
    $i = 0;
    $add = 0;
    while ($i < count($ann)){
        $fielda = explode(";",$ann[$i]);
        $ct = explode(",",$fielda[1]);
        if(count($ct)> 1){
            if (substr($ct[1],0,2) == "as"){$add = 1;}
        }
        if ($add){
            # append to last_line (empty at beginning only)
            $an[] = $fielda[0].";". $fielda[1].";".$last_line;
            $add = 0;
        }
        else {
            $an[] = $ann[$i];
            $o_a = array_splice($fielda,2);
            $last_line = implode(";",$o_a);
        }
        $i += 1;
    }
    $ann = [];
   # add ;9,CHAPTER,all_basic"
    $i = 0;
    while ($i < count($an)){
        if (!strstr($an[$i], ",CHAPTER,")) {
            $ann[] = $an[$i].";9,CHAPTER,all_basic";
        }
        else{
            $ann[] = $an[$i];
            }
        $i += 1;
    }
    #
    foreach ($ann as $line) {
        $field = explode(";", $line);
        $basic_tok = $field[0];
        $i = 2;
        $skip_field = 0;
        while ($i < count($field)) {
            if (strstr($field[$i], "0,ALL")) {
                $_SESSION["ALL"][$device][$basic_tok] = 1;
                $skip_field++;
            }
            if (strstr($field[$i], ",METER,")) {
                # default
                $meter_time = 1000;
                if (count(explode(",", $field[$i])) > 2) {
                    $meter_time = explode(",", $field[$i])[2];
                }
                $_SESSION["meter"][$device][$basic_tok] = $meter_time;
                $_SESSION["meter_announce_line"][$device][$basic_tok] = $line;
                if ($_SESSION["meter_min_time"][$device] == 0) {
                    $_SESSION["meter_min_time"][$device] = $meter_time;
                } elseif ($_SESSION["meter_min_time"][$device] < $meter_time) {
                    $_SESSION["meter_min_time"][$device] = $meter_time;
                }
                $skip_field++;
            }
            elseif (strstr($field[$i], ",CHAPTER,")) {
                $ar = explode("CHAPTER", "$line");
                $chap = explode(",", $ar[1])[1];
                $chap_no_space = str_replace(" ", "_x_", $chap);
                $_SESSION["chapter_token"][$device][$chap_no_space][$basic_tok] = 1;
                $_SESSION["chapter_names"][$device][$chap_no_space] = $chap_no_space;
                $_SESSION["chapter_names_with_space"][$device][$chap_no_space] = $chap;
                $_SESSION["activ_chapters"][$device][$chap_no_space] = $chap_no_space;
                $skip_field++;
            }
            $i += 1;
        }
        $ct = explode(",", $field[1])[0];
        if ($ct == "op") {
            $last_is_op = 1;
            $last_op_tok = $basic_tok;
        } elseif ($ct == "oo") {
            if ($last_is_op == 1) {
                $_SESSION["oo_tok"][$device][$basic_tok] = $last_op_tok;
            }
        } else {
            $last_is_op = 0;
        }
        $o_a = array_splice($field, 1);
        $length = count($o_a);
        $o_a = array_splice($o_a,0, $length - $skip_field );
        $_SESSION["original_announce"][$device][$basic_tok] = $o_a;
    }
}

function split_to_display_objects(){
    global $device;
    # create display-objects
    foreach ($_SESSION["original_announce"][$device] as $basic_tok => $announce) {
        $ct = explode(",", $announce[0])[0];
        $ctm = substr($ct,1);
        if ($announce[0] == "m") {
            $_SESSION["announce_all"][$device][$basic_tok."a"] = $announce[0][0];
            $_SESSION["des_name"][$device][$basic_tok] = "basic_ command";

        }
        if ($ctm == "r" or $ctm == "s" or $ctm == "t" or $ctm == "u" or $ctm == "p" or $ctm == "o") {
            des_stack_memory($basic_tok, $announce, $ct);
        }
        if ($ctm == "r" or $ctm == "s" or $ctm == "t" or $ctm == "u") {
            expand_s($basic_tok, $announce, $ct, $ctm);
        }
        if ($ctm == "p") {
            expand_p($basic_tok, $announce, $ct);
        }
        if ($ctm == "o"){
            expand_o($basic_tok, $announce, $ct);
        }
        if ($ctm == "m" or $ctm == "n") {
            expand_m_n($basic_tok, $announce, $ct, $ctm);
        }
        if ($ctm == "a" or $ctm == "b") {
            expand_a_b($basic_tok, $announce, $ct, $ctm);
        }
        if ($ctm == "f" ) {
            expand_f($basic_tok, $announce, $ct);
        }
    }
}

function expand_s($basic_tok, $announce, $ct, $ctm){
    # announce_all: basic_tok   -> ct ( for operating)
    # announce_all: basic_toka  -> ct (for answer)
    # announce_all: basic_tokdx -> ct  (for data)
    # des: basic_tok.d0         -> switchpositions for s t u
    # des: basic<_tok.dx        -> switchpositions for r
    global $device;
    $name_d = "some_switch";
    switch ($ctm){
        case "r":
            $name_d = "switch";
            break;
        case "s":
            $name_d = "1/n switch";
            break;
        case "t";
            $name_d = "toggle switch";
            break;
        case "u":
            $name_d = "momentary switch";
            break;
    }
    count(explode(",",$announce[0])) > 1 ? $name = delete_bracket(explode(",",$announce[0])[1]): $name = $name_d;
    $_SESSION["des_name"][$device][$basic_tok] = $name;
    if ($ctm == "r"){
        # one tok per position
        $i = 2;
        $j = 0;
        while ($i < count($announce)) {
            $_SESSION["announce_all"][$device][$basic_tok . "d" . $j] = $ct;
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
        $_SESSION["announce_all"][$device][$basic_tok . "d0"] = $ct;
    }
    if($ct == "as" or $ct == "at" or $ct == "ar") {
        $_SESSION["announce_all"][$device][$basic_tok . "a"] = $ct;
    }
    if ($ctm == "s" or $ctm == "t"){$_SESSION["includes"][$device]["s"] = "s";}
    elseif ($ctm == "r"){$_SESSION["includes"][$device]["r"] = "r";}
    elseif ($ctm == "u"){$_SESSION["includes"][$device]["u"] = "u";}
}

function expand_p($basic_tok, $announce, $ct){
    global $device;
    # split dimension
    $_SESSION["des"][$device][$basic_tok . "d0"] = "";
    count(explode(",", $announce[0])) > 1 ? $name = delete_bracket(explode(",", $announce[0])[1]) : $name = "range";
    $_SESSION["des_name"][$device][basic_tok($basic_tok)] = $name;
    # dimensions:
    $dim = 2;
    $d_number = 0;
    while ($dim < count($announce)) {
        $tok = $basic_tok . "d" . $d_number;
        $_SESSION["announce_all"][$device][$tok] = $ct;
        $dim_content = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim]);
        $max = $dim_content[0];
        if (count($dim_content) > 1){
            if (!strstr($dim_content[1],"{")){
                $_SESSION["des_name"][$device][$tok] = $dim_content[1];
            }
        }
        $_SESSION["des"][$device][$tok] = $max. ",";
        $_SESSION["unit"][$device][$tok] = $_SESSION["original_announce"][$device][$basic_tok][$dim + 2];
        if ($max < $_SESSION["conf"]["selector_limit"]) {
            one_range_simple ($basic_tok, $announce[$dim], $ct, "d".$d_number, "count");
        }
        else {
            des_range_for_big_number_op_oo($tok, $announce[$dim]);
        }
        $dim += 3;
        $d_number += 1;
    }
    #
    if($ct == "ap"){
        $_SESSION["announce_all"][$device][$basic_tok . "a"] = $ct;
    }
    $_SESSION["includes"][$device]["p"] = "p";
}

function expand_o($basic_tok, $announce, $ct){
    global $device;
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
        $_SESSION["announce_all"][$device][$basic_tok . "d" . $d_number . "r"] = $ct;
        $max = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim])[0];
        if ($max < $_SESSION["conf"]["selector_limit"]) {
            one_range_simple ($basic_tok,  $_SESSION["original_announce"][$device][$basic_tok][$dim], $ct, "d".$d_number. "r", "step");
        }
        else{
            des_range_for_big_number_op_oo($basic_tok . "d" . $d_number."r", $announce[$dim]);
        }
        #
        $_SESSION["announce_all"][$device][$basic_tok . "d" . $d_number . "s"] = $ct;
        $max = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim + 1])[0];
        if ($max < $_SESSION["conf"]["selector_limit"]) {
            one_range_simple ($basic_tok,  $_SESSION["original_announce"][$device][$basic_tok][$dim + 1], $ct, "d".$d_number. "s", "steptime");
        }
        else{
            des_range_for_big_number_op_oo($basic_tok . "d" . $d_number."s", $announce[$dim + 1]);
        }
        $_SESSION["announce_all"][$device][$basic_tok . "d" . $d_number .  "t"] = $ct;
        $max = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim + 2])[0];
        if ($max < $_SESSION["conf"]["selector_limit"]) {
            one_range_simple ($basic_tok,  $_SESSION["original_announce"][$device][$basic_tok][$dim + 2], $ct, "d".$d_number. "t", "count");
        }
        else{
            des_range_for_big_number_op_oo($basic_tok . "d" . $d_number."t", $announce[$dim + 2]);
        }
        $_SESSION["unit"][$device][$basic_tok . "d" . $d_number . "t"] = $_SESSION["original_announce"][$device][$basic_tok][$dim + 3];
        $dim += 4;
        $d_number += 1;
    }
    $_SESSION["includes"][$device]["p"] = "p";
}

function expand_m_n($basic_tok, $announce, $ct, $ctm){
    # create display-object for each row, column and data
    global $device;
    count(explode(",",$announce[0])) > 1 ? $name = explode(",",$announce[0])[1] : $name = "memory";
    $_SESSION["des_name"][$device][$basic_tok] = $name;
    # data
    $tok = $basic_tok. "d0";
    $ann = explode(",",$announce[1]);
    $_SESSION["type_for_memories"][$device][$tok] = $ann[0];
    array_splice($ann, 0, 1);
    des_type($tok, $announce[1]);
    # memorypositions, for m and n commands:
    des_stack_memory($basic_tok, $announce, $ct);
    if($ct == "on" or $ct == "an") {
        $elements = explode(",",$announce[3]);
        # number of elements
        number_range_simple($basic_tok, "1_0to" . ($elements[0]), $elements[0], "o0");
        count($elements)> 1 ? $_SESSION["des_name"][$device][$basic_tok."o0"] = $elements[1] : $_SESSION["des_name"][$device][$basic_tok."o0"] = "elements";
        $_SESSION["announce_all"][$device][$basic_tok . "o0"] = $ct;
    }
    $_SESSION["announce_all"][$device][$basic_tok . "d0"] = $ct;
    # answer command:
    if($ct == "am" or $ct == "an"){
        $_SESSION["announce_all"][$device][$basic_tok . "a"] = $ct;
    }
    if ($ctm == "m"){$_SESSION["includes"][$device]["m"] = "m";}
    elseif ($ctm == "n"){$_SESSION["includes"][$device]["n"] = "n";}
}

function expand_a_b($basic_tok, $announce, $ct, $ctm){
    # one tok (basictok."d".$xx) per type element; xx start with 0
    # exception: basictok."dx" same element is generated with each call of this function
    # used for data input element
    global $device;
    $_SESSION["announce_all"][$device][$basic_tok."dx"] = $ct;
    $_SESSION["type_for_memories"][$device][$basic_tok."dx"] = $ct;
    #
    count(explode(",",$announce[0])) > 1 ? $name = explode(",",$announce[0])[1] : $name = "array elements";
    $_SESSION["des_name"][$device][$basic_tok] = $name;
    $_SESSION["announce_all"][$device][$basic_tok . "m0"] = $ct;
    if ($ctm == "a") {
        $_SESSION["des_name"][$device][$basic_tok . "m0"] = "position";
    }
    else{
        # b
        $_SESSION["des_name"][$device][$basic_tok . "m0"] = "start at";
    }
    $no_of_elements = 0;
    $j = 1;
    $end = 0;
    While($j < count($_SESSION["original_announce"][$device][$basic_tok]) and $end == 0){
        # count all up to CHAPTER
        if (strpos($_SESSION["original_announce"][$device][$basic_tok][$j],"CHAPTER")){
            $end = 1;
        }
        else {
            $no_of_elements++;
        }
        $j++;
    }
    if ($ct == "ob" or $ct == "ab") {
        # used for position of the array to select, no des, selector is created in createcommands directly
        $_SESSION["announce_all"][$device][$basic_tok . "o0"] = $ct;
        number_range_simple($basic_tok,"{1_0to".($no_of_elements)."}", $no_of_elements , "o0");
        $_SESSION["des_name"][$device][$basic_tok . "o0"] = "number of elements";
    }
    # ob / ab as number of elements to transmit or start number (for "b"
    if ($no_of_elements > 1) {
        # additional selector for dataelements
        selector_for_aa($basic_tok, $no_of_elements);
    }
    # then calculate the type
    range_a_b_type($basic_tok,$announce, $ct);
    if($ct == "ab" or $ct == "aa"){
        $_SESSION["announce_all"][$device][$basic_tok . "a"] = $ct;
    }
    if ($ct == "oa" or $ct == "aa"){$_SESSION["includes"][$device]["a"] = "a";}
    if ($ct == "ob" or $ct == "ab"){$_SESSION["includes"][$device]["b"] = "b";}
}

function expand_f($basic_tok, $announce, $ct){
    global $device;
    $ann = explode(",",$announce[1]);
    count(explode(",",$announce[0])) > 1 ? $name = explode(",",$announce[0])[1] : $name = "FIFO";
    $_SESSION["des_name"][$device][$basic_tok] = $name;
    $elements = explode(",", $announce[2]);
    $_SESSION["announce_all"][$device][$basic_tok . "m0"] = $ct;
    $max_r = explode(",",$announce[2])[0];
    number_range_simple($basic_tok, "1_0to".$max_r, $max_r, "m0");
    if (count($elements) > 1) {
        $_SESSION["des_name"][$device][$basic_tok . "m0"] = $elements[1];
    }
    # ?? necessary ??
    # one_range_simple ($basic_tok, $announce[2],$ct, "m0", "elements");
    $_SESSION["announce_all"][$device][$basic_tok . "d0"] = $ct;
    $_SESSION["type_for_memories"][$device][$basic_tok. "d0"] = $ann[0];
    des_type($basic_tok."d0", $announce[1]);
    if($ct == "af" ){
        $_SESSION["announce_all"][$device][$basic_tok . "a"] = $ct;
    }
    $_SESSION["includes"][$device]["f"] = "f";
}

function des_type($tok,$announce){
    # used for memory commands
    # announce is type only ($_SESSION["original_announce"][$device)$tok][1])
    # announce: <ty>[,label][,default_value][,{<des>}]
    global $device;
    $ann = explode(",", $announce);
    $type = $ann[0];
    $name = "";
    # delete type:
    array_splice($ann, 0, 1);
    if (is_numeric($type)) {
        # type is length of string
        if (count($ann) > 0){
            if (!strstr($ann[0],"{")){
                $name = $ann[0];
                $ann = array_splice($ann,1);
            }
            else{ $name = "alpha";}
        }
        if (count($ann) > 0){
            if (!strstr($ann[0],"{")){
                $_SESSION["default_value"][$device][$tok] = $ann[0];
                $ann = array_splice($ann,1);
            }
        }
        count($ann) > 0 ?$ra= implode(",",$ann) : $ra ="";
        $ra = delete_bracket($ra);
        $_SESSION["des"][$device][$tok] = create_des_for_strings($type, $ra);
    }
    else {
        list($min, $max) = find_allowed($type);
        # without restrictions:
        if (count($ann) > 0) {
            if (!strstr($ann[0], "{")) {
                # label available -> remove
                $name = $ann[0];
                array_splice($ann, 0, 1);
            }
        }
        if (count($ann) > 0) {
            if (!strstr($ann[0], "{")) {
                $_SESSION["default_value"][$device][$tok] = $ann[0];
                $ann = array_splice($ann, 1);
            }
        }
        if (count($ann) > 0) {
            # {des}
            $ann = delete_bracket(implode(",", $ann));
            $_SESSION["des"][$device][$tok] = $type . "," . $ann;
        } else {
            $_SESSION["des"][$device][$tok] = $type;
        }
    }
    $_SESSION["des_name"][$device][$tok] = $name;
}

function range_a_b_type($basic_tok, $announce, $ct){
    # create "announce_all and "type_for_memory" for $basictok."dx" for each data element
    #
    global $device;
    $tok = $basic_tok. "m0";
    $_SESSION["announce_all"][$device][$tok] = $ct;
    $j = 0;
    $i = 1;
    $type_for_memories = "";
    $subtoken = 0;
    while ($i < count($announce)){
        $d_tok = $basic_tok. "d" . $subtoken;
        if ($i != 1) {
            $type_for_memories .= ",";
        }
        $type_for_memories .= $j . ",";
        $ann = explode(",", $announce[$i]);
        $type = $ann[0];
        des_type($d_tok,$announce[$i]);
        $type_for_memories .= $type;
        $_SESSION["announce_all"][$device][$d_tok] = $ct;
        $_SESSION["type_for_memories"][$device][$d_tok] = $type;
        $j += 1;
        $i += 1;
        $subtoken += 1;
    }
    $_SESSION["type_for_memories"][$device][$tok] = $type_for_memories;
  # $_SESSION["des"][$device][$tok] = $des;
}

function number_range_simple($basic_tok, $data, $max_r, $s_number){
    # for "small" numbers
    # data: {n_mtox,a,b,d,...}
    global $device;
    $data = delete_bracket($data);
    $result = $max_r;
    # result: string: something like: max_r,1,2,4,5,a,s...
    $data = explode(",", $data);
    $i = 0;
    while ($i < count($data)){
        if (strstr($data[$i],"_") and strstr($data[$i], "to")){
            list($separator, $from, $to) = split_range($data[$i]);
            while ($from <= $to) {
                $result .= "," . $from;
                $from += $separator;
            }
        }
        else {
            # fixed value
            $result .= "," . $data[$i];
        }
        $i += 1;
    }
    $_SESSION["des"][$device][$basic_tok . $s_number] = $result;
}

function des_range_for_big_number_op_oo($tok, $announce){
    global $device;
    $ann = explode(",", $announce);
    $type = $ann[0];
    $name = "";
    # type is length of string (for big values of p/o command -> max value
    $ann = array_splice($ann,1);
    if (count($ann) > 0){
        if (!strstr($ann[0],"{")){
            $name = $ann[0];
            $ann = array_splice($ann,1);
        }
        else{ $name = "alpha";}
    }
    $_SESSION["des_name"][$device][$tok] = $name;
    $i = 0;
    $_SESSION["des"][$device][$tok] = $type;
    while ($i< count($ann)){
        $_SESSION["des"][$device][$tok] .=  ",". delete_bracket($ann[$i]);
        $i++;
    }
}

function selector_for_aa($basic_tok,$number_of_elements){
    global $device;
    $ann = $_SESSION["original_announce"][$device][$basic_tok];
    $ann = array_splice($ann, 1);
    $result = $number_of_elements;
    if (count($ann) > 0) {
        $i = 0;
        while ($i < count($ann)) {
            $ann_ = explode(",", $ann[$i]);
            if (count($ann_) > 1 and !strstr($ann_[1], "{")) {
                $result .= ",".$ann_[1];
            } else {
                $result .= ",".find_name_of_type($ann_[0]);
            }
            $i++;
        }
    }
    $_SESSION["des"][$device][$basic_tok."m0"] = $result;
}

function des_stack_memory($basic_tok, $announce_o, $ct){
    global $device;
    # $announce_o is complete string
    # this is for stacks and memorypositions only:  additional lines are added for selectors
    # toksx are used if number_of_stacks > 1
    # toks0 for stacks without MUL; with MUL contain max of all elements only
    # toksx (x>0) for each MUL ADD element (des)
    # it is assumed, that "high" numbers of stacks use the {... } notation always
    # so 0,1,2,... is not for "high" numbers!
    if ($ct[1] == "m" or $ct[1] == "n"){
        $def_name = "memoryposition";
        $despos = 2;
        }
    else{
        if ($announce_o[1] == 1){
            # one stack only
            return;
        }
        else {
            $def_name = "stack";
            $despos = 1;
        }
    }
    $stack = explode(",",$announce_o[$despos]);
    # now stack ore memory pos only
    # always start with number of all elements
    if (!strstr($announce_o[$despos], "MUL")) {
        # no MUL -> one element only
       one_range_simple($basic_tok, $announce_o[$despos], $ct, "m". "0", "selector");
        $_SESSION["des_name"][$device][$basic_tok."mx"] = "";
        return;
    }
    # with MUL
    # remove $number_of_stack:
    array_splice($stack,0, 1);
    # first element may be label now
    if (!strstr($stack[0],"{")){
        # mx is used for name only
        $_SESSION["des_name"][$device][$basic_tok."mx"] = $stack[0];
        array_splice($stack,0, 1);
    }
    else{$_SESSION["des_name"][$device][$basic_tok."mx"] = $def_name;}
    # remove leading { end ending } (the may be othe "{")
    $stack = implode(",",$stack);
    if ($stack[0] == "{"){ $stack = substr($stack,1);}
    $end = strlen($stack);
    if ($stack[$end -1] == "}"){ $stack = substr($stack,0, $end - 1);}
    # n,label,...MUL...
    # more than on element always!
    $one_mul = explode("MUL",$stack);
    $i = 0;
    while ($i < count($one_mul)){
        if (!strstr($one_mul[$i],"ADD")) {
           one_range_simple($basic_tok, $one_mul[$i], $ct, "m" . $i, "selector");
        }
        else{
            $one_mul = explode("ADD",$one_mul[$i]);
            one_range_simple ($basic_tok, $one_mul[0], $ct, "m" . $i, "selector");
            one_range_simple ($basic_tok, $one_mul[1], $ct, "n0", "selector");
        }
        $i++;
    }
}

function one_range_simple ($basic_tok, $des, $ct, $s_number, $defaultname){
    # des: string: max[,label][,default][{,...}] ; not empty
    global $device;
    $_SESSION["announce_all"][$device][$basic_tok . $s_number] = $ct;
    $range = explode(",", $des);
    $max_r = $range[0];
    # delete max_r
    $range = array_splice($range,1);
    if (count($range) == 0){
        # max only
        $_SESSION["des_name"][$device][$basic_tok . $s_number] = $defaultname;
        if ($max_r <= $_SESSION["conf"]["selector_limit"]) {
            number_range_simple($basic_tok, "1_0to" . ($max_r - 1), $max_r, $s_number);
        }
        else{
            $_SESSION["des"][$device][$basic_tok . $s_number] = $max_r;
        }
        # done
        return;
    }
    elseif (!strstr($range[0],"{")) {
        #  label available
        $_SESSION["des_name"][$device][$basic_tok . $s_number] = delete_bracket($range[0]);
        # remove label
        $range = array_splice($range, 1);
    }
    else {
        $_SESSION["des_name"][$device][$basic_tok . $s_number] = " ";
    }
    if (count($range) > 0) {
        if (!strstr($range[0], "{")) {
            # default_value available
            $_SESSION["default_value"][$device][$basic_tok . $s_number] = delete_bracket($range[0]);
            $range = array_splice($range, 1);
        }
    }
    if (count($range) == 0){
        $result = $max_r;
        if ($max_r <= $_SESSION["conf"]["selector_limit"]) {
            $i = 0;
            while ($i < $max_r) {
                $result .= "," . $i;
                $i += 1;
            }
        }
        $_SESSION["des"][$device][$basic_tok . $s_number] = $result;
    }
    else {
        # remaining: {...} -> des_range
        $result = $max_r;
        if ($max_r <= $_SESSION["conf"]["selector_limit"]) {
            $data = implode(",", $range);
            number_range_simple($basic_tok, $data, $max_r, $s_number);
        }
        else{
            $_SESSION["des"][$device][$basic_tok . $s_number] = $max_r;
	}
    }
}

function create_des_for_strings($type, $data){
    global $device;
    # to distiguish from numeric des, the first colon separated element is empty
    $result = ",".$type;
    $add_result = "";
    if($data != "") {
        $range = explode(",", $data);
        $i = 0;
        while ($i < count($range)) {
            if (array_key_exists($range[$i], $_SESSION["alpha"][$device])) {
                $add_result .= $_SESSION["alpha"][$device][$range[$i]];
            }
            elseif(strstr($range[$i],"_") and strstr($range[$i], "to")){
                $ra = explode("_",$range[$i]);
                $sep = $ra[0];
                $min = explode("to",$ra[1])[0];
                $max = explode("to",$ra[1])[1];
                $j = ord($min);
                while ($j <= ord($max)){
                    if(!strstr($add_result,chr($j))){$add_result .= chr($j);}
                    $j += $sep;
                }
            }
            else{
                if(!strstr($add_result,$range[$i])){$add_result .= $range[$i];}
            }
            $i++;
        }
        if ($add_result != ""){$result .= ",".$add_result;}
    }
    return $result;
}

?>

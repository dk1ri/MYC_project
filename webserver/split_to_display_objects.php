<?php
# split_to_display_objects.php
# DK1RI 20230615
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
    $_SESSION["real_range_for_type"][$device] = [];

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
    # for all op commands:
    $_SESSION["unit"][$device] = [];
    # max value for display element
    $_SESSION["max_for_send"][$device] = [];
    $_SESSION["oo_tok"][$device] = [];
  #  $_SESSION["defaults"][$device] = [];
    # create $_SESSION["original_announce"][$device] from announcefile
    # and $_SESSION["chapter_token"][$device]
    $last_is_op = 0;
    $last_op_tok = "";
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
            $ct = explode(",",$lda[0])[0];
            if ($ct == "op") {
                $last_is_op = 1;
                $last_op_tok = basic_tok($token);
            }
            elseif ($ct == "oo"){
                if ($last_is_op == 1) {
                    $_SESSION["oo_tok"][$device][$token] = $last_op_tok;
                }
            }
            else {
                if (!$ct == "ap") {
                    $last_is_op = 0;
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
            des_stack_memory($basic_tok, $announce_o, $ct, 0);
        }
        if ($ctm == "r" or $ctm == "s" or $ctm == "t" or $ctm == "u") {
            expand_s($basic_tok, $announce_o, $ct, $ctm);
        }
        if ($ctm == "p") {
            expand_p($basic_tok, $announce_o, $ct);
        }
        if ($ctm == "o"){
            expand_o($basic_tok, $announce_o, $ct);
        }
        if ($ctm == "m" or $ctm == "n") {
            expand_m_n($basic_tok, $announce_o, $ct);
        }
        if ($ctm == "a" or $ctm == "b") {
            expand_a_b($basic_tok, $announce_o, $ct);
        }
        if ($ctm == "f" ) {
            expand_f($basic_tok, $announce_o, $ct);
        }
    }
}

function des_range($basic_tok, $data, $max_r, $s_number){
    # input: {n_mtox,a,b,d,...}
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
        des_range($basic_tok, "1_0to" . ($max_r - 1), $max_r, $s_number);
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
        $result = $max_r;
        if ($max_r <= $_SESSION["conf"]["selector_limit"]) {
            $i = 0;
            while ($i < $max_r) {
                $result .= "," . $i . "," . $i;
                $i += 1;
            }
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

function des_stack_memory($basic_tok, $announce_o, $ct, $stack_memory){
    # this is for stacks and memorypositions only:  additional lines are added for selectors
    # toksx are used if number_of_stacks > 1
    # toks0 for stacks without MUL; with MUL contain max of all elements only
    # toksx (x>0) for each MUL ADD element (des_range)
    # it is assumed, that "high" numbers og stacks use the {... } notation always
    # so 0,1,2,... is not for "high" numbers!
    # $stack_memory == 0:
    $despos = 1;
    $def_name = "stack";
    $snumber = "m";
    if($stack_memory == 1){
        $def_name = "memoryposition";
        $despos = 2;
    }
    elseif($stack_memory == 2){
        $def_name = "elements";
        $despos = 3;
        $snumber ="o";
    }
    $stack = explode(",",$announce_o[$despos]);
    # always:
    $number_of_stacks = (int)$stack[0];
    $device = $_SESSION["device"];
    if ($number_of_stacks > 1){
        if (!strstr(implode(",",$announce_o), "MUL")) {
            # no MUL -> one MUL element only
            des_one_mul($basic_tok, $announce_o[$despos], $ct, $snumber. "0", "$def_name");
            return;
        }
        # with MUL with non-manual or manual selectors
        # remove $number_of_stack:
        array_splice($stack,0, 1);
        # [label],{...MUL...}
        # more than on element always!
        if (!strstr($stack[0],"{")) {
            # label available
            $_SESSION["des_name"][$device][$basic_tok . $snumber. "0"] = delete_bracket($stack[0]);
            # remove label:
            array_splice($stack, 0, 1);
        }
        else {
            $_SESSION["des_name"][$device][$basic_tok . $snumber. "0"] = $def_name;
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
            des_one_mul($basic_tok, $des_mul[$i], $ct, $snumber . $i, $def_name);
            $i += 1;
        }
        if (count($des_add) > 1){
            # for ADD
            des_one_mul($basic_tok, $des_add[1], $ct, $snumber. "0", $def_name);
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

function expand_p($basic_tok, $announce, $ct){
    $device = $_SESSION["device"];
    # split dimension
    $_SESSION["des"][$device][$basic_tok . "d0"] = "";
    count(explode(",", $announce[0])) > 1 ? $name = delete_bracket(explode(",", $announce[0])[1]) : $name = "range";
    $_SESSION["des_name"][$device][basic_tok($basic_tok)] = $name;
    # dimensions:
    $dim = 2;
    $d_number = 0;
    while ($dim < count($announce)) {
        $_SESSION["announce_all"][$device][$basic_tok . "d" . $d_number][0] = $ct;
        $max = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim])[0];
        $_SESSION["des"][$device][$basic_tok . "d" . $d_number] = $max. ",";
        $_SESSION["unit"][$device][$basic_tok . "d" . $d_number] = $_SESSION["original_announce"][$device][$basic_tok][$dim + 2];
        des_one_mul($basic_tok, $_SESSION["original_announce"][$device][$basic_tok][$dim], $ct, "d".$d_number, "count");
        $dim += 3;
        $d_number += 1;
    }
    if($ct == "ap"){
        $_SESSION["announce_all"][$device][$basic_tok . "a"][0] = $ct;
    }
}

function expand_o($basic_tok, $announce, $ct){
    $device = $_SESSION["device"];
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


function expand_m_n($basic_tok, $announce, $ct){
    # create display-object for each row, column and data
    $device = $_SESSION["device"];
    #  if (strstr($_SESSION["original_announce"][$device][$basic_tok],"{")){
    #     # corrections of _POST are made, if restistions are available
    #    $_SESSION["des_type_with_restricions"][$device][$basic_tok] = 1;
    #}
    count(explode(",",$announce[0])) > 1 ? $name = explode(",",$announce[0])[1] : $name = "memory";
    $_SESSION["des_name"][$device][$basic_tok] = $name;
    # data
    $tok = $basic_tok. "d0";
    $ann = explode(",",$announce[1]);
    $_SESSION["real_range_for_type"][$device][$tok] = $ann[0];
    array_splice($ann, 0, 1);
    $_SESSION["announce_all"][$device][$basic_tok . "d0"][0] = $ct;
    des_type($basic_tok, $announce[1],0, $ct);
    # memorypositions, for n commands: number of elements also:
    des_stack_memory($basic_tok, $announce, $ct, 1);
    if($ct == "on" or $ct == "an") {
        des_stack_memory($basic_tok, $announce, $ct, 2);
    }
    # answer command:
    if($ct == "am" or $ct == "an"){
        $_SESSION["announce_all"][$device][$basic_tok . "a"][0] = $ct;
    }
}

function expand_a_b($basic_tok, $announce, $ct){
    # one tok basictokdx per type element
    $device = $_SESSION["device"];
    count(explode(",",$announce[0])) > 1 ? $name = explode(",",$announce[0])[1] : $name = "array elements";
    $_SESSION["des_name"][$device][$basic_tok] = $name;
    # sequence determines the display - sequence -> do this first:
    if (count($announce) > 2) {
        # additional selector for <ty>
        $_SESSION["announce_all"][$device][$basic_tok . "m0"][0] = $ct;
        $_SESSION["des_name"][$device][$basic_tok . "m0"] = $name;
        if ($ct[0] == "ob" or $ct[0] == "ab") {
            # used for number_of_elements, no des, selector is created in createcommands directly
            $_SESSION["announce_all"][$device][$basic_tok . "o0"][0] = $ct;
            $_SESSION["des_name"][$device][$basic_tok . "o0"] = $name;
        }
        # ob /ab as number of elements to transmit
    }
    # then calculate the type
    $i = 1;
    while ($i < count($announce)){
        des_type($basic_tok, $announce[$i],$i - 1, $ct);
        $i += 1;
    }
    if($ct == "ab" or $ct == "aa"){
        $_SESSION["announce_all"][$device][$basic_tok . "a"][0] = $ct;
        # This will hold the position of the array to select
        $_SESSION["announce_all"][$device][$basic_tok . "m0"][0] = $ct;
    }
}

function expand_f($basic_tok, $announce, $ct){
    $device = $_SESSION["device"];
    count(explode(",",$announce[0])) > 1 ? $name = explode(",",$announce[0])[1] : $name = "memory";
    $_SESSION["des_name"][$device][$basic_tok] = $name;
    $elements = explode(",", $announce[2]);
    $_SESSION["announce_all"][$device][$basic_tok . "m0"][0] = $ct;
    $max_r = explode(",",$announce[2])[0];
    des_range($basic_tok, "1_0to".$max_r, $max_r, "m0");
    count($elements) > 1 ? $name = $elements[1] : $name = "number of elements";
    $_SESSION["des_name"][$device][$basic_tok."m0"] = $name;
    $_SESSION["announce_all"][$device][$basic_tok . "d0"][0] = $ct[0];
    if($ct == "af" ){
        $_SESSION["announce_all"][$device][$basic_tok . "a"][0] = $ct;
    }
}

function des_type($basic_tok,$announce, $subtoken, $ct){
    # announce is type part only for string or numeric with <des>
    $device = $_SESSION["device"];
    $ann = explode(",",$announce);
    if (!is_numeric($ann[0])){
        # the "a","b",... must be rplaced by the max number for transmission
        # if <  $_SESSION["conf"]["selector_limit"] real number is necessary other the mx is given
        list($name, $max_for_transmit) = check_max_for_memory_data($announce);
        $modified_announce = $max_for_transmit;
        if (count($ann)> 0) {
            $modified_announce .=  "," . implode(",", $ann);
        }
        des_one_mul($basic_tok,$modified_announce,$ct,"d" . $subtoken, $name);
    }
    else {
        $_SESSION["des"][$device][$basic_tok."d". $subtoken] = "alpha";
        $name = "alpha";
        if (count($ann) > 0 and !strstr($ann[0],"{")){
            $name = $ann[0];
        }
        $_SESSION["des_name"][$device][$basic_tok."d". $subtoken] = $name;
        # alpha restriction not supported now
    }
}

function check_max_for_memory_data($announce){
    # this function is similar to des_one_mul + des_range
    # return: [byte|bit|..., $max_for_transmit]
    $range = explode(",", $announce);
    $type = $range[0];
    list($name, $min, $max) = type_data($type);
    $max_for_transmit = $max - $min + 1;
    $result = [$name,$max_for_transmit];
    # delete type:
    array_splice($range,0, 1);
    if (count($range) > 0) {
        if (!strstr($range[0], "{")) {
            # label available -> remove
            array_splice($range, 0, 1);
        }
    }
    if (count($range) > 0){
        # remaining: {...} -> des_range
        $data= implode(",", $range);
        # $data: {n_mtox,a,b,d,...}
        $data = str_replace("{", "", $data);
        $data = str_replace("}", "", $data);
        $data = explode(",", $data);
        $i = 0;
        $position = 0;
        while ($i < count($data)){
            if (strstr($data[$i],"_")){
                # range
                $rang = explode("_", $data[$i]);
                $separator = $rang[0];
                $fr_to = explode("to", $rang[1]);
                $value = $fr_to[0];
                while ($value <= $fr_to[1]){
                    $value += $separator;
                    $position += 1;
                }
            }
            else {
                # fixed value
                $position += 1;
            }
            $i += 1;
        }
        if ($position <= $_SESSION["conf"]["selector_limit"]) {
            $result = [$name, $position];
        }
    }
    return $result;
}

?>

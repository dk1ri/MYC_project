<?php
# split_to_display_objects.php
# DK1RI 20230724
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function split_to_display_objects(){
    # create $_SESSION["original_announce"][$device] from announcefile
    # and $_SESSION["chapter_token"][$device]
    $device = $_SESSION["device"];
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
            $_SESSION["original_announce"][$device][$token] = $lda;
            if (!strpos($line, "CHAPTER")) {
                # only those without CHAPTER
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
        fclose($file);
    }
    # create display-objects
    foreach ($_SESSION["original_announce"][$device] as $basic_tok => $announce) {
        $ct = explode(",", $announce[0])[0];
        $ctm = substr($ct,1);
        if ($announce[0] == "m") {
            expand_m($basic_tok, $announce);
        }
        if ($ctm == "r" or $ctm == "s" or $ctm == "t" or $ctm == "u" or $ctm == "p" or $ctm == "o") {
            des_stack_memory($basic_tok, $announce, $ct, 0);
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
    if($ct == "as" or $ct == "at" or $ct == "ar") {
        $_SESSION["announce_all"][$device][$basic_tok . "a"][0] = $ct;
    }
    if ($ctm == "s"){$_SESSION["includes"][$device]["s"] = "s";}
    elseif ($ctm == "r"){$_SESSION["includes"][$device]["r"] = "r";}
    elseif ($ctm == "u"){$_SESSION["includes"][$device]["u"] = "u";}
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
    $_SESSION["includes"][$device]["p"] = "p";
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
    $_SESSION["includes"][$device]["p"] = "p";
}

function expand_m_n($basic_tok, $announce, $ct, $ctm){
    # create display-object for each row, column and data
    $device = $_SESSION["device"];
    count(explode(",",$announce[0])) > 1 ? $name = explode(",",$announce[0])[1] : $name = "memory";
    $_SESSION["des_name"][$device][$basic_tok] = $name;
    # data
    $tok = $basic_tok. "d0";
    $ann = explode(",",$announce[1]);
    $_SESSION["type_for_memories"][$device][$tok] = $ann[0];
    array_splice($ann, 0, 1);
    des_type($basic_tok, $announce[1],0, $ct);
    # memorypositions, for n commands: number of elements also:
    des_stack_memory($basic_tok, $announce, $ct, 1);
    if($ct == "on" or $ct == "an") {
        des_stack_memory($basic_tok, $announce, $ct, 2);
    }
    $_SESSION["announce_all"][$device][$basic_tok . "d0"][0] = $ct;
    # answer command:
    if($ct == "am" or $ct == "an"){
        $_SESSION["announce_all"][$device][$basic_tok . "a"][0] = $ct;
    }
    if ($ctm == "m"){$_SESSION["includes"][$device]["m"] = "m";}
    elseif ($ctm == "n"){$_SESSION["includes"][$device]["n"] = "n";}
}

function expand_a_b($basic_tok, $announce, $ct){
    # one tok basictokdx per type element
    $device = $_SESSION["device"];
    $ann = explode(",",$announce[1]);
    count(explode(",",$announce[0])) > 1 ? $name = explode(",",$announce[0])[1] : $name = "array elements";
    $_SESSION["des_name"][$device][$basic_tok] = $name;
    $_SESSION["announce_all"][$device][$basic_tok . "m0"][0] = $ct;
    if ($ct[0] == "a") {
        $_SESSION["des_name"][$device][$basic_tok . "m0"] = "position";
    }
    else{
        $_SESSION["des_name"][$device][$basic_tok . "m0"] = "start at";
    }
    $no_of_elements = count($_SESSION["original_announce"][$device][$basic_tok]) - 1;
    if ($ct == "ob" or $ct == "ab") {
        # used for position of the array to select, no des, selector is created in createcommands directly
        $_SESSION["announce_all"][$device][$basic_tok . "o0"][0] = $ct;
        des_range($basic_tok,"1_0to".($no_of_elements -1), $no_of_elements, "o0");
        $_SESSION["des_name"][$device][$basic_tok . "o0"] = "number of elements";
    }
    # ob /ab as number of elements to transmit
    des_range($basic_tok,"1_0to".($no_of_elements - 1), $no_of_elements, "m0");
    if ($no_of_elements > 2) {
        # additional selector for dataelements
        des_range($basic_tok, "1_0to" . ($no_of_elements - 1), $no_of_elements, "m0");
    }
    else{
        des_range($basic_tok,"1_0to1", $no_of_elements, "m0");
    }
    # then calculate the type
    range_a_b_type($basic_tok,$announce, $ct);
    if($ct == "ab" or $ct == "aa"){
        $_SESSION["announce_all"][$device][$basic_tok . "a"][0] = $ct;
    }
    if ($ct == "oa" or $ct == "aa"){$_SESSION["includes"][$device]["a"] = "a";}
    if ($ct == "ob" or $ct == "ab"){$_SESSION["includes"][$device]["b"] = "b";}
}

function expand_f($basic_tok, $announce, $ct){
    $device = $_SESSION["device"];
    $ann = explode(",",$announce[1]);
    count(explode(",",$announce[0])) > 1 ? $name = explode(",",$announce[0])[1] : $name = "memory";
    $_SESSION["des_name"][$device][$basic_tok] = $name;
    $elements = explode(",", $announce[2]);
    $_SESSION["announce_all"][$device][$basic_tok . "m0"][0] = $ct;
    $max_r = explode(",",$announce[2])[0];
    des_range($basic_tok, "1_0to".$max_r, $max_r, "m0");
    count($elements) > 1 ? $name = $elements[1] : $name = "number of elements";
    $_SESSION["des_name"][$device][$basic_tok."m0"] = $name;
    des_one_mul($basic_tok, $announce[2],$ct, "m0", "elements");
    $_SESSION["announce_all"][$device][$basic_tok . "d0"][0] = $ct;
    $_SESSION["type_for_memories"][$device][$basic_tok. "d0"] = $ann[0];
    des_type($basic_tok, $announce[1],0, $ct);
    if($ct == "af" ){
        $_SESSION["announce_all"][$device][$basic_tok . "a"][0] = $ct;
    }
    $_SESSION["includes"][$device]["f"] = "f";
}

function des_type($basic_tok,$announce, $subtoken, $ct){
    # announce is type part only for string or numeric with <des>
    #announce: <ty>[,label][,<des_range>]
    $device = $_SESSION["device"];
    $ann = explode(",", $announce);
    $type = $ann[0];
    if (is_numeric($type)) {
        $_SESSION["des"][$device][$basic_tok . "d" . $subtoken] = "alpha";
        $name = "alpha";
        # alpha restriction not supported now
    }
    else {
        list($type, $min, $max) = type_data($type);
        # without restrictions:
        $max_for_transmit = (int)$max - (int)$min + 1;
        # delete type:
        array_splice($ann,0, 1);
        $name = "";
        if (count($ann) > 0) {
            if (!strstr($ann[0], "{")) {
                # label available -> remove
                $name = $ann[0];
                array_splice($ann, 0, 1);
            }
        }
        if (count($ann) > 0) {
            # the "a","b",... must be replaced by the max number for transmission
            $max_for_transmit = check_max_for_memory_data($ann[0]);
        }
        if ($ann == []){$ann[0] = "1_0to". ($max_for_transmit - 1);}
        des_range($basic_tok, implode(",", $ann), $max_for_transmit -1 , "d" . $subtoken);
    }
    $_SESSION["des_name"][$device][$basic_tok . "d" . $subtoken] = $name;
}

function check_max_for_memory_data($announce){
    # this function is similar to des_one_mul + des_range
    # return: [byte|bit|..., $max_for_transmit]
    # remaining: {...} -> des_range
    # $data: {n_mtox,a,b,d,...}
    $data = delete_bracket($announce);
    $data = explode(",", $data);
    $i = 0;
    $position = 0;
    while ($i < count($data)){
        if (strstr($data[$i],"_")){
            # range
            list($separator, $from, $to) = split_range($data[$i]);
            $position += ($to - $from) / $separator;
        }
        else {
            # fixed value
            $position += 1;
        }
        $i += 1;
    }
    return $position;
}

function range_a_b_type($basic_tok, $announce, $ct){
    # for special selector for a / b type: display the type or label
    # also create "announce_all and "type_for_memory" for $basictok."dx" for each data element
    #
    $device = $_SESSION["device"];
    $tok = $basic_tok. "m0";
    $_SESSION["announce_all"][$device][$tok][0] = $ct;
    $j = 0;
    $i = 1;
    $des = (count($announce) - 1) . ",";
    $type_for_memories = "";
    $max_for_send = "";
    $subtoken = 0;
    while ($i < count($announce)){
        $des_ = "";
        if ($i != 1) {
            $des .= ",";
            $type_for_memories .= ",";
            $max_for_send .= ",";
        }
        $des .= $j . ",";
        $type_for_memories .= $j . ",";
        $max_for_send .= $j . ",";
        $ann = explode(",", $announce[$i]);
        $type = $ann[0];
        array_splice($ann, 0, 1);
        $name = find_name_of_type($type);

        if (count($ann) > 0){
            if (!strstr($ann[0], "{")){
                $name = $ann[0];
                array_splice($ann, 0, 1);
            }
        }
        if (count($ann) > 0){
            # rest is <des>
            $des_ = str_replace(["{","}"],"", $ann[0]);
        }
        $des .= $name;
        $type_for_memories .= $type;
        list( $min, $max) = find_allowed($type);
        $_SESSION["announce_all"][$device][$basic_tok. "d" . $subtoken][0] = $ct;
        $_SESSION["des"][$device][$basic_tok. "d" . $subtoken] = $type;
        $_SESSION["type_for_memories"][$device][$basic_tok. "d" . $subtoken] = $type;
        $_SESSION["des_name"][$device][$basic_tok. "d" . $subtoken] = $name . ".".$des_;
        $j += 1;
        $i += 1;
        $subtoken += 1;
    }
    $_SESSION["type_for_memories"][$device][$tok] = $type_for_memories;
    $_SESSION["des"][$device][$tok] = $des;
}

function des_range($basic_tok, $data, $max_r, $s_number){
    # data: {n_mtox,a,b,d,...}
    $device = $_SESSION["device"];
    $data = delete_bracket($data);
    $result = $max_r;
    if ($max_r > $_SESSION["conf"]["selector_limit"]){
        # too big
        $result .= ",".$data;
        # for all "big" selectors
        $_SESSION["des"][$device][$basic_tok . $s_number] = $data;
        $_SESSION["to_correct"][$device][$basic_tok . $s_number] = 1;
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
                list($separator, $from, $to) = split_range($data[$i]);
                while ($from <= $to){
                    $result .= ",". $position.",". $from;
                    $from += $separator;
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
    # $stack_memory == 0 (stacks):
    $despos = 1;
    $def_name = "stack";
    $snumber = "m";
    if($stack_memory == 1){
        # memoryposition
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
            $data = delete_bracket($des_mul[$i]);
            des_one_mul($basic_tok, $data, $ct, $snumber . $i, $def_name);
            $i += 1;
        }
        if (count($des_add) > 1){
            # for ADD
            des_one_mul($basic_tok, $des_add[1], $ct, "n0", $def_name);
        }
    }
}

function expand_m($token, $announce){
    $device = $_SESSION["device"];
    $_SESSION["announce_all"][$device][$token."a"][0] = $announce[0][0];
    $_SESSION["des_name"][$device][$token] = "basic_ command";

}
?>

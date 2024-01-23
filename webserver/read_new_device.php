<?php
# read_new_device.php
# DK1RI 20240124
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function read_new_device($device){
    $_SESSION["includes"][$device] = [];
    $_SESSION["chapter_index"][$device] = [];
    $_SESSION["chapter_token"][$device] = [];
    $_SESSION["original_announce"][$device] = [];
    $_SESSION["announce_all"][$device] = [];
    $_SESSION["a_to_o"][$device] = [];
    $_SESSION["o_to_a"][$device] = [];
    $_SESSION["special_token"][$device] = [];
    $_SESSION["property_len"][$device] = [];
    $_SESSION["property_len_byte"][$device] = [];
    $_SESSION["cor_token"][$device] = [];
    $_SESSION["actual_data"][$device] = [];
    $_SESSION["chapter_array"][$device] = [];
    $_SESSION["tok_list"][$device] = [];
    $_SESSION["ct_of_as"][$device] = [];
    $_SESSION["as_token"][$device] = [];
    $_SESSION["as_token_as_to_basic"][$device] = [];
    $_SESSION["type_for_memories"][$device] = [];
    $_SESSION["oo_tok"][$device] = [];
    $_SESSION["des"][$device] = [];
    $_SESSION["des_name"][$device] = [];
    $_SESSION["des_range"][$device] = [];
    $_SESSION["max_for_send"][$device] = [];
    $_SESSION["max_for_ADD"][$device] = [];
    $_SESSION["string_commands"][$device] =[];
    $_SESSION["unit"][$device] = [];
    $_SESSION["meter"][$device] = [];
    $_SESSION["meter_announce_line"][$device] = [];
    $_SESSION["meter_min_time"][$device] = 0;
    $_SESSION["chapter_names"][$device] = [];
    $_SESSION["chapter_names"][$device]["all_basic"] = "all_basic";
    $_SESSION["activ_chapters"][$device]["all_basic"] = "all_basic";
    $_SESSION["chapter_names"][$device]["ADMINISTRATION"] = "ADMINISTRATION";
    $_SESSION["activ_chapters"][$device]["ADMINISTRATION"] = "ADMINISTRATION";
    $_SESSION["chapter_token"][$device]["all_basic"] = [];
    $_SESSION["chapter_token"][$device]["ADMINISTRATION"] = [];
    $_SESSION["chapter"] = "all";
    $_SESSION["update"] = 0;
    $_SESSION["send_ok"] = 0;
    $_SESSION["tok_to_send"] = [];
    $_SESSION["send_string_by_tok"] = [];
    #
    split_to_display_objects();
    # as answer token <-> operate token:
    read_a_o($device);
    # like interface ... : after split_to_display_objects (some updates there)
    read_special_token();
    # ct for "as" commands (ct of corresponding "o" command)
    ct_of_as();
    # length of properties
    calculate_property_len();
    # list of all token with identical basic token + answertoken + oo token:
    calculate_cor_token($device);
    # for active chapters:
    create_tok_list($device);
    # max values for each display element
    max_for_send();
    # calculate max values for ADD
    max_for_ADD();
    # commands with type "string) (m, n, f possible)
    string_command();
    # actual data for all displaed elements
    init_data($device);
    # start time events
    # create $_SESSION["to_cerrect"]
    create_to_correct($device);
    start_time_events($device);
}

function read_a_o($device){
    # original_announce contain expanded as commands
    $last_tok = 0;
    foreach ($_SESSION["original_announce"][$device] as $tok => $line) {
        $ct = explode(",", $line[0]);
        if (count($ct) > 1) {
            if (substr($ct[1], 0, 2) == "as") {
                $a_e_tok = str_replace("as", "", $ct[1]);
                if ($a_e_tok == $last_tok) {
                    $_SESSION["a_to_o"][$device][$tok] = $last_tok;
                    $_SESSION["o_to_a"][$device][$last_tok] = $tok;
                }
            }
            elseif (substr($ct[1], 0, 3) == "ext") {
                $a_e_tok = str_replace("ext", "", $ct[1]);
                if ($a_e_tok == $last_tok) {
                    $_SESSION["a_to_o"][$device][$tok] = $last_tok;
                    $_SESSION["o_to_a"][$device][$last_tok] = $tok;
                }
            }
            else{
                $last_tok = $tok;
            }
        }
        else{
            $last_tok = $tok;
        }
    }
}

function read_special_token(){
    $device = $_SESSION["device"];
    $_SESSION["special_token"][$device]["interface"] = 1;
    $_SESSION["special_token"][$device]["user_name"] = 1;
    $_SESSION["special_token"][$device]["user"] = 1;
    $_SESSION["special_token"][$device]["languages"] = 1;
    $_SESSION["special_token"][$device]["device"] = 1;
    foreach ($_SESSION["chapter_names"][$device] as $value){
        $_SESSION["special_token"][$device]["chapter_".$value] = 1;
    }
}

function ct_of_as(){
    # token for as commands are set to "a". <command_type_of_o_command>
    $device =$_SESSION["device"];
    foreach ($_SESSION["o_to_a"][$device] as $key => $value) {
        # there is a "d0" token always
        $new_ct = "a" . explode(",",$_SESSION["announce_all"][$device][$key . "d0"][0])[0][1];
        $_SESSION["ct_of_as"][$device][$value] = $new_ct;
    }
}

function calculate_property_len(){
    # for all basic-toks !!
    # stacks added with stacktoken
    # length of all properties for data transmission for basic_tok
    # this will replace tok_len, sel_len,
    $device = $_SESSION["device"];
    end($_SESSION["original_announce"][$device]);
    $tok_len = length_of_number(basic_tok(key($_SESSION["original_announce"][$device])));
    $_SESSION["command_len"][$device] = $tok_len;
    $_SESSION["property_len_byte"][$device] = [];
    foreach ($_SESSION["original_announce"][$device] as $key => $value) {
        $_SESSION["property_len"][$device][$key][] = $tok_len;
        $_SESSION["property_len_byte"][$device][$key][] = $tok_len / 2;
        $cta = explode(";",$value[0])[0];
        $ct = explode(",",$cta)[0];
        switch ($ct) {
            case "os":
            case "ou":
            case "or":
            case "as":
            case "ar":
            case "at":
                # token + stacks + no_of switches
                # for update_memory_position pos 1: stacks and memorytype for memories
                stack_len($key, $value[1]);
                if (count($value) > 4) {
                    $_SESSION["property_len"][$device][$key][] = length_of_number(count($value) - 2);
                    $_SESSION["property_len_byte"][$device][$key][] = (length_of_number(count($value) - 2)) / 2;
                }
                else{
                    $_SESSION["property_len"][$device][$key][] = 0;
                    $_SESSION["property_len_byte"][$device][$key][] = 0;
                }
                break;
            case "op":
            case "ap":
                # token + stacks + no_of_range
                stack_len($key, $value[1]);
                $i = 2;
                while ($i < count($value)) {
                    $_SESSION["property_len"][$device][$key][] = length_of_number(explode(",", $value[$i])[0]);
                    $_SESSION["property_len_byte"][$device][$key][] = (length_of_number(explode(",", $value[$i])[0])) / 2;
                    $i += 3;
                }
                break;
            case "oo":
                $i = 2;
                while ($i < count($value)) {
                    if (count($value) - $i > 2) {
                        $_SESSION["property_len"][$device][$key][] = length_of_number(explode(",", $value[$i])[0]);
                        $_SESSION["property_len_byte"][$device][$key][] = (length_of_number(explode(",", $value[$i])[0])) / 2;
                        $_SESSION["property_len"][$device][$key][] = length_of_number(explode(",", $value[$i + 1])[0]);
                        $_SESSION["property_len_byte"][$device][$key][] = (length_of_number(explode(",", $value[$i + 1])[0])) / 2;
                        $_SESSION["property_len"][$device][$key][] = length_of_number(explode(",", $value[$i + 2])[0]);
                        $_SESSION["property_len_byte"][$device][$key][] = (length_of_number(explode(",", $value[$i + 2])[0])) / 2;
                    }
                    $i += 4;
                }
                break;
            case "om":
            case "am":
                # token + type + pos
                # type:
                $_SESSION["property_len"][$device][$key][] = length_of_type(explode(",",$value[1])[0]);
                $_SESSION["property_len_byte"][$device][$key][] = (length_of_type(explode(",",$value[1])[0])) / 2;
                # pos:
                $i = 2;
                $result = 1;
                while ($i < count($value)){
                    if (!strstr($value[$i],"CHAPTER")) {
                        $result *= (int)explode(",", $value[$i])[0];
                    }
                    $i += 1;
                }
                $_SESSION["property_len"][$device][$key][] = length_of_number($result);
                $_SESSION["property_len_byte"][$device][$key][] = (length_of_number($result)) / 2;
                break;
            case "on":
            case "an":
                # token + type + no_of_element, start
                # type:
                $_SESSION["property_len"][$device][$key][] = length_of_type(explode(",",$value[1])[0]);
                $_SESSION["property_len_byte"][$device][$key][] = (length_of_type(explode(",",$value[1])[0])) / 2;
                # number_of_elements
                $_SESSION["property_len"][$device][$key][] = length_of_number(explode(",",$value[2])[0]);
                $_SESSION["property_len_byte"][$device][$key][] = (length_of_number(explode(",",$value[2])[0])) / 2;
                # pos
                $i = 3;
                $result = 1;
                while ($i < count($value)){
                    if (!strstr($value[$i],"CHAPTER")) {
                        $result *= (int)explode(",",$value[$i])[0];
                    }
                    $i += 1;
                }
                $_SESSION["property_len"][$device][$key][] = length_of_number($result);
                $_SESSION["property_len_byte"][$device][$key][] = (length_of_number($result)) / 2;
                break;
            case "of":
            case "af":
                $_SESSION["property_len"][$device][$key][] = length_of_type(explode(",",$value[1])[0]);
                $_SESSION["property_len_byte"][$device][$key][] = (length_of_type(explode(",",$value[1])[0])) / 2;
                $_SESSION["property_len"][$device][$key][] = length_of_number(explode(",",$value[2])[0]);
                $_SESSION["property_len_byte"][$device][$key][] = (length_of_number(explode(",",$value[2])[0])) / 2;
                break;
            case "oa":
            case "aa":
            case "ob":
            case "ab":
                $number_of_elements = count($value);
                # data: token + type + type
                $i = 1;
                while ($i < count($value)) {
                    if (!strstr($value[$i], ",CHAPTER,")) {
                        # value[$i} : n,label,{xx,xx...} ...
                        $result = explode(",", $value[$i])[0];
                        $_SESSION["property_len"][$device][$key][] = length_of_type($result);
                        $_SESSION["property_len_byte"][$device][$key][] = (length_of_type($result)) / 2;
                    }
                    $i += 1;
                }
                if ($number_of_elements > 3){
                    $_SESSION["property_len"][$device][$key][] = length_of_number($number_of_elements);
                    $_SESSION["property_len_byte"][$device][$key][] = (length_of_number($number_of_elements)) / 2;
                }
                else{
                    $_SESSION["property_len"][$device][$key][] = 2;
                    $_SESSION["property_len_byte"][$device][$key][] = 1;
                }
                break;
        }

    }
}

function calculate_des_range($basic_tok, $data, $ct, $s_number){
    # extract ranges for some commands
    # simple ranges with no MUL or ADD one "{" and one "}"
    $device = $_SESSION["device"];
    if (is_numeric($data)){
        $_SESSION["des_range"][$device][$basic_tok.$s_number] = "1_0to".$data;
    }
    else{
        $range = explode(",", $data);
        if (count($range) > 1) {
            array_splice($range, 0, 1);
            if (!strstr($range[0], "{")) {
                # delete label
                array_splice($range, 0, 1);
            }
        }
        if (count($range) == 0) {
            $_SESSION["des_range"][$device][$basic_tok . $s_number] = "1_0to" . explode(",", $data)[0];
        }
        else{
            $range = str_replace("{","",$range);
            $range = str_replace("}","",$range);
            $_SESSION["des_range"][$device][$basic_tok . $s_number] = implode(",",$range);
        }
    }
}

function stack_len($key, $value){
    $device = $_SESSION["device"];
    $stacks = explode(",",$value)[0];
    if ($stacks == 1) {
        $_SESSION["property_len"][$device][$key][] = 0;
        $_SESSION["property_len_byte"][$device][$key][] = 0;
    }
    else {
        $_SESSION["property_len"][$device][$key][] = length_of_number($stacks);
        $_SESSION["property_len_byte"][$device][$key][] = (length_of_number($stacks))/ 2;
    }
}

function calculate_cor_token($device){
    # all except oo and as:
    foreach ($_SESSION["announce_all"][$device] as $key => $value){
        $_SESSION["cor_token"][$device][basic_tok($key)][] = $key;
    }
    # add oo comands
    foreach ($_SESSION["announce_all"][$device] as $key => $value) {
        if ($value[0] == "oo"){
            if (strstr($key, "r") or strstr($key, "s") or strstr($key, "t")) {
                $o_tok = $_SESSION["oo_tok"][$device][basic_tok($key)];
                $_SESSION["cor_token"][$device][basic_tok($o_tok)][] = $key;
            }
        }
     }
    # add as commands
    # as command get the tok of the corresponding op tok!
    foreach ($_SESSION["o_to_a"][$device] as $key => $value) {
        $_SESSION["cor_token"][$device][basic_tok($key)][] = $value. "a";
    }
}

function max_for_send(){
    $device = $_SESSION["device"];
    # _SESSION["des]  always: max,....
    foreach ($_SESSION["des"][$device] as $token => $value){
        $_SESSION["max_for_send"][$device][$token] = explode(",", $_SESSION["des"][$device][$token])[0];
    }
}

function max_for_ADD(){
    $device = $_SESSION["device"];
    foreach ($_SESSION["original_announce"][$device] as $basic_tok => $value){
        if (strstr(implode(";", $value), "ADD")){
            $max = 1;
            $i = 0;
            $found = 0;
            while (!$found){
                $tok = $basic_tok."m".$i;
                if(array_key_exists($tok, $_SESSION["des"][$device])) {
                    $max *= (int)explode(",", $_SESSION["des"][$device][$tok])[0];
                }
                else{$found = 1;}
                $i++;
            }
            $_SESSION["max_for_ADD"][$device][$basic_tok . "n0"] = $max;
        }
    }

}

function string_command(){
    # m, n, f commands with one string as data -> <c>d0 only
    $device = $_SESSION["device"];
    foreach ($_SESSION["original_announce"][$device] as $basic_tok => $value) {
        if (strlen($value[0]) > 1) {
            $ct = $value[0][1];
            if ($ct == "m" or $ct == "n" or $ct == "f") {
                # string ?:
                if (is_numeric(explode(",", $_SESSION["original_announce"][$device][$basic_tok][2])[0])) {
                    $_SESSION["string_commands"][$device][$basic_tok] = 1;
                }
            }
        }
    }
}

function init_data($device){
    # create $_SESSION[actual_data][$device]
    # actual_data contain real data!
    # set data  for all numeric token to "0", strings to "input test"
    # except "big" values for positions stacks (not supported now
    # ranges for memory data not supported
    foreach ($_SESSION["announce_all"][$device] as $key => $value) {
        if ($key == "0a") {
            # basic command
            $field = $_SESSION["original_announce"][$device][basic_tok($key)];
            $_SESSION["actual_data"][$device][$key] = $field[2] . "," . $field[3] . "," . $field[1];
        }
       else{
           if (strstr($key,"d")){
               # only "d" toks can have types
               $ct = $value[0][1];
                  if ($ct == "m" or $ct == "n" or $ct == "a" or $ct == "b" or $ct == "f") {
                   $type =  $_SESSION["type_for_memories"][$device][$key][0];
                   if (is_numeric($type)) {
                       # for string data
                       $_SESSION["actual_data"][$device][$key] = "";
                   } else {
                       $_SESSION["actual_data"][$device][$key] = "0";
                   }
               } else {
                   # switches and range commands
                   $_SESSION["actual_data"][$device][$key] = "0";
               }
           }
           else {
               # others
               $_SESSION["actual_data"][$device][$key] = "0";
           }
        }
    }
}

function create_to_correct($device){
    # all token with manual inputs
    # stack and memoryposition with big nuimber of entries should be avoided
    foreach ($_SESSION["announce_all"][$device] as $key => $value){
        if ($value[0] == "m"){continue;}
        $of = $value[0][1];
        if ($of == "m" or $of == "n" or $of == "a" or $of == "b" or $of == "f"){
            if (strstr($key, "d")){
                # all data for all memories
                $_SESSION["to_correct"][$device][$key] = 1;
            }
        }
    }
}

function start_time_events($device){
    if ($_SESSION["meter_min_time"][$device] > 0){
        #for later use
  #     <script>
   #         let conter = 0
    #        setInterval(update_window, 1000);
     #   </script>
    }
}
?>
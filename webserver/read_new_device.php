<?php
# read_new_device.php
# DK1RI 20240124
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function read_new_device(){
    global $device, $chapter_token;
    # These variables are used for all users and reead at first usage (per device)
    $_SESSION["includes"][$device] = [];
  #  $_SESSION["chapter_index"][$device] = [];
    $chapter_token = [];
    $_SESSION["original_announce"][$device] = [];
    $_SESSION["announce_all"][$device] = [];
    $_SESSION["a_to_o"][$device] = [];
    $_SESSION["o_to_a"][$device] = [];
    $_SESSION["special_token"][$device] = [];
    $_SESSION["property_len"][$device] = [];
    $_SESSION["property_len_byte"][$device] = [];
    $_SESSION["cor_token"][$device] = [];
    $_SESSION["chapter_array"][$device] = [];
    $_SESSION["as_token"][$device] = [];
    $_SESSION["as_token_as_to_basic"][$device] = [];
    $_SESSION["type_for_memories"][$device] = [];
    $_SESSION["oo_tok"][$device] = [];
    $_SESSION["des"][$device] = [];
    $_SESSION["des_name"][$device] = [];
    $_SESSION["max_for_send"][$device] = [];
    $_SESSION["max_for_ADD"][$device] = [];
    $_SESSION["string_commands"][$device] =[];
    $_SESSION["unit"][$device] = [];
    $_SESSION["meter"][$device] = [];
    $_SESSION["meter_announce_line"][$device] = [];
    $_SESSION["meter_min_time"][$device] = 0;
    $_SESSION["chapter_names"][$device] = [];
    $_SESSION["chapter_names_with_space"][$device] = [];
    $_SESSION["chapter_names"][$device]["all_basic"] = "all_basic";
    $_SESSION["chapter_names_with_space"][$device]["all_basic"] = "all_basic";
    $_SESSION["chapter_names"][$device]["ADMINISTRATION"] = "ADMINISTRATION";
    $_SESSION["chapter_names_with_space"][$device]["ADMINISTRATION"] = "ADMINISTRATION";
    $_SESSION["chapter_token_pure"][$device]["all_basic"] = [];
    $_SESSION["chapter_token_pure"][$device]["ADMINISTRATION"] = [];
    $_SESSION["rules"][$device] = [];
    $_SESSION["alpha"][$device] = [];
    $_SESSION["ALL"][$device] = [];
    $_SESSION["default_value"][$device] = [];
    $_SESSION["to_correct"][$device] = [];
    $_SESSION["DEF"][$device] = [];
    #
    if (!is_dir($_SESSION["conf"]["usb_interface_dir"])){mkdir($_SESSION["conf"]["usb_interface_dir"]);}
    if (!is_dir($_SESSION["conf"]["device_dir"])){exit("device directory not found");}
    if (!is_dir($_SESSION["conf"]["user_dir"])){mkdir($_SESSION["conf"]["user_dir"]);}
    create_original_announce();
    split_to_display_objects();
    # as answer token <-> operate token:
    read_a_o();
    # like interface ... : after split_to_display_objects (some updates there)
  # read_special_token();
    # ct for "as" commands (ct of corresponding "o" command)
 #  ct_of_as();
    # length of properties
    calculate_property_len();
    # list of all token with identical basic token + answertoken + oo token:
    calculate_cor_token();
    # max values for each display element
    max_for_send();
    # calculate max values for ADD
    max_for_ADD();
    # actual data for all displaed elements
    init_data();
    # start time events
    # create $_SESSION["to_cerrect"]
    create_to_correct();
    sort_chapzernames();
    start_time_events();
}

function read_a_o(){
    # original_announce contain expanded as commands
    global $language, $device;
    $last_tok = 0;
    foreach ($_SESSION["original_announce"][$device] as $tok => $line) {
        $ct = explode(",", $line[0]);
        if (count($ct) > 1) {
            if (substr($ct[1], 0, 3) == "ext"){
                $temp = str_replace("ext", "", $ct[1]);
                if (is_numeric($temp)){
                    $ct[1] = "as".$temp;
                }
            }
            if (substr($ct[1], 0, 2) == "as") {
                $a_e_tok = str_replace("as", "", $ct[1]);
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

function calculate_property_len(){
    # for all basic-toks !!
    # stacks added with stacktoken
    # length of all properties for data transmission for basic_tok
    global $language, $device;
    $tok_len = length_of_number(count($_SESSION["original_announce"][$device]));
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

function stack_len($key, $value){
    global $language, $device;
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

function calculate_cor_token(){
    global $language, $device;
    # oo is added to op
    $last_p = 0;
    foreach ($_SESSION["announce_all"][$device] as $key => $value){
        if (array_key_exists(basic_tok($key),$_SESSION["a_to_o"][$device])){
            $_SESSION["cor_token"][$device][$_SESSION["a_to_o"][$device][basic_tok($key)]][] = basic_tok($key)."a";
        }
        else {
            if ($value != "oo") {
                $_SESSION["cor_token"][$device][basic_tok($key)][] = $key;
                if( $value == "op"){$last_p = basic_tok($key);}
            }
            else {
                # oo
                if (strstr($key, "r") or strstr($key, "s") or strstr($key, "t")) {
                    $_SESSION["cor_token"][$device][$last_p][] = $key;
                }
            }
        }
    }
}

function max_for_send(){
    global $language, $device;
    # _SESSION["des]  always: max,....
    foreach ($_SESSION["des"][$device] as $token => $value){
        $_SESSION["max_for_send"][$device][$token] = explode(",", $_SESSION["des"][$device][$token])[0];
    }
}

function max_for_ADD(){
    global $language, $device;
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

function init_data(){
    global $device;
    # create $_SESSION["actuadata"][$device]
    # $_SESSION["actuadata"][$device] contain real data!
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
               if (array_key_exists($key, $_SESSION["default_value"][$device])){
                   $_SESSION["actual_data"][$device][$key] = $_SESSION["default_value"][$device][$key];
               }
               else {
                   $ct = $value[1];
                   if ($ct == "m" or $ct == "n" or $ct == "a" or $ct == "b" or $ct == "f") {
                       $type = $_SESSION["type_for_memories"][$device][$key][0];
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
           }
           else {
               # others
               $_SESSION["actual_data"][$device][$key] = "0";
           }
        }
    }
}

function create_to_correct(){
    # all token with manual inputs
    # stack and memoryposition with big nuimber of entries should be avoided
    global $language, $device;
    foreach ($_SESSION["announce_all"][$device] as $key => $value){
        if ($value[0] == "m"){continue;}
        $of = $value[1];
        if ($of == "m" or $of == "n" or $of == "a" or $of == "b" or $of == "f"){
            if (strstr($key, "d")){
                # all data for all memories
                $_SESSION["to_correct"][$device][$key] = 1;
            }
        }
    }
}

function sort_chapzernames(){
    # sort chapter_names by CHAPTER
    global $device;
    $new_announce =[];
    $ch = [];
    foreach ($_SESSION["chapter_names"][$device] as $chapter) {
        if ($chapter != "ADMINISTRATION") {
            $ch[$chapter] = $chapter;
        }
    }
    $ch["ADMINISTRATION"] = "ADMINISTRATION";
    $_SESSION["chapter_names"][$device] = $ch;
}

function start_time_events(){
    global $language, $device;
    if ($_SESSION["meter_min_time"][$device] > 0){
        #for later use
  #     <script>
   #         let conter = 0
    #        setInterval(update_window, 1000);
     #   </script>
    }
}
?>
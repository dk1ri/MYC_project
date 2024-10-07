<?php
# read_new_device.php
# DK1RI 20240124
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function create_new_device(){
    # not actually used devices were not deleted from $SESSION
    $device = $_SESSION["device"];
    if (array_key_exists($_SESSION["device"], $_SESSION["announce_all"])) {return;}
    if (file_exists("devices\\".$device."\\session_original_announce")){
        # data already available
        read_device_from_file();
    }
}

function create_new_device_first_time(){
    # this device is not available
    # read as new device once oly
    $device = $_SESSION["device"];
    $_SESSION["activ_tok_list"][$device] = [];
    $_SESSION["actual_data"][$device] = [];
    $_SESSION["ALL"][$device] = [];
    $_SESSION["announce_all"][$device] = [];
    $_SESSION["a_to_o"][$device] = [];
    $_SESSION["alpha"][$device] = [];
    $_SESSION["chapter_names"][$device] = [];
    $_SESSION["chapter_names_with_space"][$device] = [];
    # without "as" commands
    $_SESSION["chapter_token_pure"][$device]= [];
    $_SESSION["cor_token"][$device] = [];
    $_SESSION["default_value"][$device] = [];
    $_SESSION["des"][$device] = [];
    $_SESSION["des_name"][$device] = [];
    $_SESSION["dev"][$device] = [];
    $_SESSION["max_for_ADD"][$device] = [];
    $_SESSION["max_for_send"][$device] = [];
    $_SESSION["meter"][$device] = [];
    $_SESSION["meter_announce_line"][$device] = [];
    $_SESSION["meter_min_time"][$device] = 0;
    $_SESSION["o_to_a"][$device] = [];
    $_SESSION["oo_tok"][$device] = [];
    $_SESSION["original_announce"][$device] = [];
    $_SESSION["property_len"][$device] = [];
    $_SESSION["property_len_byte"][$device] = [];
    $_SESSION["rules"][$device] = [];
    $_SESSION["to_correct"][$device] = [];
    $_SESSION["translate_by_language"][$device] = [];
    $_SESSION["type_for_memories"][$device] = [];
    $_SESSION["unit"][$device] = [];
    $_SESSION["actual_sequencelist"][$device] = [];
    $_SESSION["actual_sequencelist_by_sequence"][$device] = [];
    $_SESSION["final_actual_sequencelist_by_sequence"][$device]= [];
    $_SESSION["toks_to_ignore"][$device] = [];
    # without as commands
    $_SESSION["edit_toks_to_ignore"][$device] = [];
    $_SESSION["command_len"][$device][0] = 0;
    #
    create_original_announce();
    # as answer token <-> operate token:
    read_a_o();
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
    # create $_SESSION["to_cerrect"]
    create_to_correct();
    sort_chapternames();
    create_actual_sequence_list();
    create_final_actual_sequencelist();
    create_command_len();
    write_device_to_file();
    # default: all chapters are activ
 #   $_SESSION["activ_chapters"][$device] = $_SESSION["chapter_names"][$device];
    # overwrite?
    if (file_exists("devices\\".$device."\\session_original_announce")){
        # data already available
        read_device_from_file();
    }
}

function read_a_o(){
    # original_announce contain expanded as commands
    $last_tok = 0;
    foreach ($_SESSION["original_announce"][$_SESSION["device"]] as $tok => $line) {
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
                    $_SESSION["a_to_o"][$_SESSION["device"]][$tok] = $last_tok;
                    $_SESSION["o_to_a"][$_SESSION["device"]][$last_tok] = $tok;
                    $_SESSION["edit_toks_to_ignore"][$_SESSION["device"]][$last_tok] = 1;
                }
            }
            else{
                $last_tok = $tok;
                $_SESSION["edit_toks_to_ignore"][$_SESSION["device"]][$tok] = 1;
            }
        }
        else{
            $last_tok = $tok;
            $_SESSION["edit_toks_to_ignore"][$_SESSION["device"]][$tok] = 1;
        }
    }
}

function calculate_property_len(){
    # for all basic-toks !!
    # stacks added with stacktoken
    # length of all properties for data transmission for basic_tok
    $device = $_SESSION["device"];
    $tok_len = length_of_number(count($_SESSION["original_announce"][$device]));
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
    $stacks = explode(",",$value)[0];
    if ($stacks == 1) {
        $_SESSION["property_len"][$_SESSION["device"]][$key][] = 0;
        $_SESSION["property_len_byte"][$_SESSION["device"]][$key][] = 0;
    }
    else {
        $_SESSION["property_len"][$_SESSION["device"]][$key][] = length_of_number($stacks);
        $_SESSION["property_len_byte"][$_SESSION["device"]][$key][] = (length_of_number($stacks))/ 2;
    }
}

function calculate_cor_token(){
    # oo is added to op
    $device = $_SESSION["device"];
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
    $device = $_SESSION["device"];
    # _SESSION["des]  always: max,....
    foreach ($_SESSION["des"][$device] as $token => $value){
        $_SESSION["max_for_send"][$device][$token] = explode(",", $_SESSION["des"][$device][$token])[0];
    }
}

function max_for_ADD(){
    foreach ($_SESSION["original_announce"][$_SESSION["device"]] as $basic_tok => $value){
        if (strstr(implode(";", $value), "ADD")){
            $max = 1;
            $i = 0;
            $found = 0;
            while (!$found){
                $tok = $basic_tok."m".$i;
                if(array_key_exists($tok, $_SESSION["des"][$_SESSION["device"]])) {
                    $max *= (int)explode(",", $_SESSION["des"][$_SESSION["device"]][$tok])[0];
                }
                else{$found = 1;}
                $i++;
            }
            $_SESSION["max_for_ADD"][$_SESSION["device"]][$basic_tok . "n0"] = $max;
        }
    }

}

function init_data(){
    # create $_SESSION["actualdata"][$_SESSION["device"]]
    # $_SESSION["actualdata"][$_SESSION["device"]] contain real data!
    # set data  for all numeric token to "0", strings to "input test"
    # except "big" values for positions stacks (not supported now
    # ranges for memory data not supported
    foreach ($_SESSION["announce_all"][$_SESSION["device"]] as $key => $value) {
        if ($key == "0a") {
            # basic command
            $field = $_SESSION["original_announce"][$_SESSION["device"]][basic_tok($key)];
            $_SESSION["actual_data"][$_SESSION["device"]][$key] = $field[2] . "," . $field[3] . "," . $field[1];
        }
        else{
           if (strstr($key,"d")){
               # only "d" toks can have types
               if (array_key_exists($key, $_SESSION["default_value"][$_SESSION["device"]])){
                   $_SESSION["actual_data"][$_SESSION["device"]][$key] = $_SESSION["default_value"][$_SESSION["device"]][$key];
               }
               else {
                   $ct = $value[1];
                   if ($ct == "m" or $ct == "n" or $ct == "a" or $ct == "b" or $ct == "f") {
                       $type = $_SESSION["type_for_memories"][$_SESSION["device"]][$key][0];
                       if (is_numeric($type)) {
                           # for string data
                           $_SESSION["actual_data"][$_SESSION["device"]][$key] = "";
                       } else {
                           $_SESSION["actual_data"][$_SESSION["device"]][$key] = "0";
                       }
                   } else {
                       # switches and range commands
                       $_SESSION["actual_data"][$_SESSION["device"]][$key] = "0";
                   }
               }
           }
           else {
               # others
               $_SESSION["actual_data"][$_SESSION["device"]][$key] = "0";
           }
        }
    }
}

function create_to_correct(){
    # all token with manual inputs
    # stack and memoryposition with big nuimber of entries should be avoided
    foreach ($_SESSION["announce_all"][$_SESSION["device"]] as $key => $value){
        if ($value[0] == "m"){continue;}
        $of = $value[1];
        if ($of == "m" or $of == "n" or $of == "a" or $of == "b" or $of == "f"){
            if (strstr($key, "d")){
                # all data for all memories
                $_SESSION["to_correct"][$_SESSION["device"]][$key] = 1;
            }
        }
    }
}

function sort_chapternames(){
    # sort chapter_names by CHAPTER
    $device = $_SESSION["device"];
    $ch = [];
    foreach ($_SESSION["chapter_names"][$device] as $chapter) {
        if ($chapter != "ADMINISTRATION") {
            $ch[$chapter] = $chapter;
            $_SESSION["edit_chapter_to_ignore"][$device][$chapter] = 1;
        }
    }
    $ch["ADMINISTRATION"] = "ADMINISTRATION";
    $_SESSION["edit_chapter_to_ignore"][$device]["ADMINISTRATION"] = 1;
    $_SESSION["chapter_names"][$_SESSION["device"]] = $ch;
}

function create_actual_sequence_list(){
    $device = $_SESSION["device"];
    $i = 0;
    foreach ($_SESSION["chapter_token_pure"][$device] as $dev => $dat1){
        foreach ($dat1 as $chapter => $dat2){
            foreach ($dat2 as $tok){
                $_SESSION["actual_sequencelist"][$device][$tok] = $i;
                $_SESSION["actual_sequencelist_by_sequence"][$device][$i] = $tok;
                $i++;
            }
        }
    }
}

function start_time_events(){
    if ($_SESSION["meter_min_time"][$_SESSION["device"]] > 0){
        #for later use
  #     <script>
   #         let conter = 0
    #        setInterval(update_window, 1000);
     #   </script>
    }
}
?>
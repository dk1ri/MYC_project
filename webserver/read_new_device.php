<?php
# read_new_device.php
# DK1RI 20230613
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function read_new_device($device){
    #create additional device (old ones not deleted)
    # split anouncelist to display objects and get chapter_names
    # define device dependent data
    # basic_tok is the token given in the original annoucelist
    #
    # for including necessary code only
    $_SESSION["includes"][$device] = [];
    $_SESSION["chapter_index"][$device] = [];
    $_SESSION["chapter_token"][$device] = [];
    # _POST is crrected / translated to data  for transmit
    # contain transmitted data (not the displayed ones)
    $_SESSION["corrected_POST"][$device] = [];
    # original_announce: spltted original announcefile token; array data: array: line split by ";"
    $_SESSION["original_announce"][$device] = [];
    # announce_all: commandtype only for all displayed elements by token
    # but: "as" commands have no entry (but a display element). They are handled with the corresponding operate command
    # and get the basic_tok of the operating command
    # token : basic_tok"identifier"
    # identifiers:
    # m selectors for stack, memoryposition
    # n selector for ADD
    # o selector for number of data to send for an /on commands
    # d data
    # a answer element
    $_SESSION["announce_all"][$device] = [];
    # token of "as" command -> corresponding token
    $_SESSION["a_to_o"][$device] = [];
    # reverse
    $_SESSION["o_to_a"][$device] = [];
    # list of _POST indices, which are not tokens
    $_SESSION["special_token"][$device] = [];
    # length of property (for send data) for each property
    # for memorypositions the property may have more than one display elements _ stored in the first element only
    $_SESSION["property_len"][$device] = [];
    $_SESSION["property_len_byte"][$device] = [];
    # all token (of displayed elements for a basic_tok
    $_SESSION["cor_token"][$device] = [];
    # actual data for each display element
    # valid data; decimal not hex (or alpha), values to transmit (not displayed values)
    $_SESSION["actual_data"][$device] = [];
    # not used ?
    $_SESSION["chapter_array"][$device] = [];
    # actual tokens, depend on selected chapters
    $_SESSION["tok_list"][$device] = [];
    # commandtype of "os" commands used but may be error -> to check
    $_SESSION["ct_of_as"][$device] = [];
    # token for as commands: as-token array data master-token (num)
    $_SESSION["as_token"][$device] = [];
    # token for as commands: master-token array data as-token (num)
    $_SESSION["as_token_as_to_basic"][$device] = [];
    # type for memoried per display tok
    $_SESSION["type_for_memories"][$device] = [];
    # token of oo commands
    $_SESSION["oo_tok"][$device] = [];
    # per displaytoken:
    # for memory data :
    #       string: "alpha" (restriction not supported)
    #       small numeric: max,0,0,1,1,2,4....
    #       big numeric: max,<des-range>    (token is in "to_correct")
    # others (all numeric)
    #       small numeric: max,0,0,1,1,2,4....
    #       big numeric: max,<des-range>     (token is in "to_correct")
    $_SESSION["des"][$device] = [];
    # names for display elements
    $_SESSION["des_name"][$device] = [];
    # contain "1"" used if values are "big"
    $_SESSION["to_correct"][$device] = [];
    # to calculate stacks / memoryposition max values are required
    $_SESSION["max_for_send"][$device] = [];
    # for ADD token ("n"):
    # product of MULS
    $_SESSION["max_for_ADD"][$device] = [];
    # for p / o commands: unit
    $_SESSION["unit"][$device] = [];
    # chapter_names: array
    $_SESSION["chapter_names"][$device] = [];
    $_SESSION["chapter_names"][$device]["all_basic"] = "all_basic";
    $_SESSION["activ_chapters"][$device]["all_basic"] = "all_basic";
    $_SESSION["chapter_names"][$device]["ADMINISTRATION"] = "ADMINISTRATION";
    $_SESSION["activ_chapters"][$device]["ADMINISTRATION"] = "ADMINISTRATION";
    $_SESSION["chapter_token"][$device]["all_basic"] = [];
    $_SESSION["chapter_token"][$device]["ADMINISTRATION"] = [];
    $_SESSION["chapter"] = "all";
    # as answer token <-> operate token:
    read_a_o($device);
    # for details see there:
    split_to_display_objects();
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
    # actual data for all displaed elements
    init_data($device);
}

function read_a_o($device){
    # list of token with same $basic_tok; exception : oo commands and y,asx commands
    $asfile = "devices/" . $device . "/as_commands";
    if (file_exists($asfile)) {
        $file = fopen($asfile, "r");
        while (!(feof($file))) {
            $line = fgets($file);
            $line = str_replace("\r", "", $line);
            $line = str_replace("\n", "", $line);
            if ($line != "") {
                $li = explode(" ", $line);
                $_SESSION["a_to_o"][$device][$li[0]] = $li[1];
                $_SESSION["o_to_a"][$device][$li[1]] = $li[0];
            }
        }
        fclose($file);
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
                stack_len($key, $value[1]);
                $_SESSION["property_len"][$device][$key][] = length_of_number(key($value) -2);
                $_SESSION["property_len_byte"][$device][$key][] = (length_of_number(key($value) -2))/ 2;
                break;
            case "op":
            case "ap":
            case "oo":
                # token + stacks + no_of_range
                stack_len($key, $value[1]);
                $_SESSION["property_len"][$device][$key][] = length_of_number(explode(",",$value[2])[0]);
                $_SESSION["property_len_byte"][$device][$key][] = (length_of_number(explode(",",$value[2])[0])) / 2;
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
            case "oa":
            case "aa":
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
        foreach ($value as $data){
            if (strstr($data, "ADD")){
                $bn = $basic_tok . "m";
                $max = 1;
                foreach ($_SESSION["max_for_send"][$device] as $ctoken => $cdat) {
                    if (strstr($ctoken, $bn)) {
                        $max *= explode(",", $_SESSION["des"][$device][$ctoken])[0];
                    }
                }
                $_SESSION["max_for_ADD"][$device][$basic_tok . "n0"] = $max;
            }
        }
    }

}

function init_data($device){
    # create $_SESSION[actual_data][$device]
    # actual_data contain transmitted data!
    # set data  for all numeric token to "0", strings to "input test"
    foreach ($_SESSION["announce_all"][$device] as $key => $value) {
        $ct = explode(",", $value[0])[0];
            if ($ct == "m") {
                $field = $_SESSION["original_announce"][$device][basic_tok($key)];
                $_SESSION["actual_data"][$device][$key] = $field[2] . "," . $field[3] . "," . $field[1];
            }
           else{
            if (count($value) > 1) {
                if (is_numeric($value[1])) {
                    # for string data
                    $_SESSION["actual_data"][$device][$key] = "input text";
                } else {
                    $_SESSION["actual_data"][$device][$key] = "0";
                }
            }
            else{
                $_SESSION["actual_data"][$device][$key] = "0";
            }
        }
    }
}
?>
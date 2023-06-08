<?php
# read_new_device.php
# DK1RI 20230608
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function read_new_device($device){
    #create additional device (old ones not deleted)
    # split anouncelist to display objects and get chapter_names
    $_SESSION["chapter"] = "all";
    $_SESSION["chapter_array"][$device] = [];
    $_SESSION["special_token"][$device] = [];
    $_SESSION["tok_list"][$device] = [];
    $_SESSION["ct_of_as"][$device] = [];
    # as answer token <-> operate token:
    read_a_o($device);
    # like interface ... :
    read_special_token();
    # for details see there:
    split_to_display_objects();
    # ct for "as" commands (ct of corresponding "o" command
    ct_of_as();
    # length of properties for all commands in $_SESSION["property_len"][$device]
    calculate_property_len();
    # list of all token with identical basic token + answertoken + oo token:
    calculate_cor_token($device);
    # for active chapters:
    create_tok_list($device);
    # actual data for all announcelines in $_SESSION["actual_data"]:
    init_data($device);
}

function read_a_o($device){
    $_SESSION["a_to_o"][$device] = [];
    $_SESSION["o_to_a"][$device] = [];
    # list of token with same $basic_tok; exception : oo commands and y,asx commands
    $asfile = "devices/" . $device . "/as_commands";
    $as_command = [];
    if (file_exists($asfile)) {
        $file = fopen($asfile, "r");
        while (!(feof($file))) {
            $line = fgets($file);
            $line = str_replace("\r", "", $line);
            $line = str_replace("\n", "", $line);
            if ($line != "") {
                $li = explode(" ", $line);
                $as_command[$li[0]] = $li[1];
                $_SESSION["a_to_o"][$device][$li[0]] = $li[1];
                $_SESSION["o_to_a"][$device][$li[1]] = $li[0];
            }
        }
        fclose($file);
    }
}

function read_special_token(){
    $device =$_SESSION["device"];
    $_SESSION["special_token"][$device]["interface"] = 1;
    $_SESSION["special_token"][$device]["user_name"] = 1;
    $_SESSION["special_token"][$device]["user"] = 1;
    $_SESSION["special_token"][$device]["language"] = 1;
    $_SESSION["special_token"][$device]["device"] = 1;
}

function ct_of_as(){
    # token for as commands are set to "o" token but have no announce_all entry
    $device =$_SESSION["device"];
    foreach ($_SESSION["o_to_a"][$device] as $key => $value) {
        # there is a "d0" token always
        $_SESSION["ct_of_as"][$device][$key] = $_SESSION["announce_all"][$device][$key."d0"][0];
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
    $_SESSION["property_len"][$device] = [];
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
            case "oa":
            case "aa":
                $number_of_elements = count($value);
                if ($number_of_elements > 3){
                    # additional "b0" token for length og pos and number
                    $_SESSION["property_len"][$device][$key. "b0"][0] = length_of_number($number_of_elements);
                    $_SESSION["property_len_byte"][$device][$key."b0"][0] = (length_of_number($number_of_elements)) / 2;
                }
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
    $_SESSION["cor_token"][$device] = [];
    # all except oo and as:
    foreach ($_SESSION["announce_all"][$device] as $key => $value){
        $_SESSION["cor_token"][$device][basic_tok($key)][] = $key;
    }
    # add oo comands
    $last_is_op = 0;
    $last_op_tok = "";
    foreach ($_SESSION["announce_all"][$device] as $key => $value) {
        if ($value[0] == "oo"){
            $_SESSION["cor_token"][$device][$last_op_tok][] = $_SESSION["oo_tok"][$device][$key];
        }
    }
    # for oo commands:
 #   foreach ($_SESSION["announce_all"][$device] as $key => $value) {
  #      if ($value[0] == "oo"){
   #         if (strstr($key, "r") or strstr($key, "s") or strstr($key, "t")) {
    #            $_SESSION["cor_token"][$device][basic_tok($key)][] = $key;
     #       }
      #  }
     #}
    #as commands
    # as command get the tok of the corresponding op tok!
    foreach ($_SESSION["o_to_a"][$device] as $key => $value) {
        $_SESSION["cor_token"][$device][basic_tok($key)][] = $key. "a";
    }
}

function init_data($device){
    # create $_SESSION[actual_data][$device]
    # actual_data contain transmitted data!
    # set data  for all numeric token to "0", strings to "input test"
    $_SESSION["actual_data"][$device] = [];
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
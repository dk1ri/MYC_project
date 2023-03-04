<?php
# read_new_device.php
# DK1RI 20230224
function read_new_device($device){
    #create additional device (old ones not deleted)
    # split anouncelist to display objects and get chapter_names
    split_to_display_objects();
    $_SESSION["chapter"] = $_SESSION["chapter_names"][$device][0];
    calculate_property_len();
    # now length of properties for all commands in $_SESSION["property_len"][$device] ??
    calculate_cor_token($device);
    # now list of all token with identical basic token
    calculate_add_token($device);
    # now list of all token with ADD selector
    calculate_tok_hex($device);
    # now basic token for all announcelines in $_SESSION["tok_hex"][$device]
    init_data($device);
    # now actual data for all commands in $_SESSION["actual_data"]
}

function calculate_property_len(){
    # for all basic-toks !!
    # stacks added with stacktoken
    # length of all properties for data transmission for basic_tok
    # this will replace tok_len, sel_len,
    $device = $_SESSION["device"];
    end($_SESSION["original_announce"][$device]);
    $tok_len = length_of_type(basic_tok(key($_SESSION["original_announce"][$device])));
    $_SESSION["command_len"][$device] = $tok_len;
    $_SESSION["property_len"][$device] = [];
    foreach ($_SESSION["original_announce"][$device] as $key => $value) {
        $_SESSION["property_len"][$device][$key][] = $tok_len;
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
                $t = end ($value);
                $_SESSION["property_len"][$device][$key][] = length_of_type(key($value) -2);
                break;
            case "op":
            case "ap":
            case "oo":
                # token + stacks + no_of_range
                stack_len($key, $value[1]);
                $_SESSION["property_len"][$device][$key][] = length_of_type(explode(",",$value[2])[0]);
                break;
            case "om":
            case "am":
                # token + type + pos
                # type:
                $_SESSION["property_len"][$device][$key][] = length_of_type(explode(",",$value[1])[0]);
                # pos:
                $i = 2;
                $result = 1;
                while ($i < count($value)){
                    if (!strstr($value[$i],"CHAPTER")) {
                        $result *= (int)explode(",", $value[$i])[0];
                    }
                    $i += 1;
                }
                $_SESSION["property_len"][$device][$key][] = length_of_type($result);
                break;
            case "on":
            case "an":
                # token + type + no_of_element, start
                # type:
                $_SESSION["property_len"][$device][$key][] = length_of_type(explode(",",$value[1])[0]);
                $_SESSION["property_len"][$device][$key][] = length_of_type(explode(",",$value[2])[0]);
                $i = 3;
                $result = 1;
                while ($i < count($value)){
                    if (!strstr($value[$i],"CHAPTER")) {
                        $result *= (int)explode(",",$value[$i])[0];
                    }
                    $i += 1;
                }
                $_SESSION["property_len"][$device][$key][] = length_of_type($result);
                break;
            case "oa":
            case "aa":
                # token + type + type
                $i = 1;
                while ($i < count($value)) {
                    if (!strstr($value[$i], "CHAPTER")) {
                        $_SESSION["property_len"][$device][$key][] = (int)explode(",", $value[$i])[0];
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
    }
    else {
        $_SESSION["property_len"][$device][$key][] = length_of_type($stacks);
    }
}

function calculate_cor_token($device){
    $_SESSION["as_token"][$device] = [];
    # list of token with same $basic_tok; exception : oo commands and y,asx commands
    $asfile = "devices/".$device."/as_commands";
    $as_command =[];
    if (file_exists($asfile)) {
        $file = fopen($asfile, "r");
        while (!(feof($file))) {
            $line = fgets($file);
            $line = str_replace("\r", "", $line);
            $line = str_replace("\n", "", $line);
            if ($line != "") {
                $li = explode(" ", $line);
                $as_command[$li[0]] = $li[1];
                $_SESSION["as_token"][$device][$li[0]] = $li[1];
                $_SESSION["as_token_as_to_basic"][$device][$li[1]] = $li[0];
            }
        }
        fclose($file);
    }
    $_SESSION["cor_token"][$device] = [];
    $new_basic_tok = 0;
    $oo_found = "";
    $as_found = "";
    foreach ($_SESSION["announce_all"][$device] as $key => $value) {
        if (explode(",",$_SESSION["announce_all"][$device][$key][0])[0] == "oo") {
            $oo_found .= ",".$key;
            $_SESSION["cor_token"][$device][basic_tok($key)][] = $key;
        }
        elseif (array_key_exists(basic_tok($key),$as_command)){
            $as_found = $key;
            $_SESSION["cor_token"][$device][basic_tok($key)][] = $key;
        }
        else{
            # new: append oo as
            $basic_tok = basic_tok($key);
            if($basic_tok != $new_basic_tok) {
                if ($oo_found != "") {
                    $oo_a = explode(",", $oo_found);
                    $j = 1;
                    while ($j < count($oo_a)){
                        $_SESSION["cor_token"][$device][$new_basic_tok][] = $oo_a[$j];
                        $j += 1;
                    }
                }
                if ($as_found != "") {
                    $_SESSION["cor_token"][$device][$new_basic_tok][] = $as_found;
                }
                $new_basic_tok = $basic_tok;
                $oo_found = "";
                $as_found = "";
            }
            $_SESSION["cor_token"][$device][$basic_tok][] = $key;
        }
    }
    # if last entry was as or oo
    if($as_found != "" or $oo_found != ""){
        $j = 1;
        $oo_a = explode(",", $oo_found);
        while ($j < count($oo_a)){
            $_SESSION["cor_token"][$device][$new_basic_tok][] = $oo_a[$j];
            $j += 1;
        }
        if ($as_found != "") {
            $_SESSION["cor_token"][$device][$new_basic_tok][] = $as_found;
        }
    }
}

function calculate_add_token($device){
    $_SESSION["adder_token"][$device] = [];
    foreach ($_SESSION["announce_all"][$device] as $key => $value) {
        if (strstr($key, "b")) {
            $found = "";
            $basic_tok = basic_tok($key);
            $ann = $_SESSION["original_announce"][$device][$basic_tok];
            $i = 0;
            while ($i < count($ann)) {
                if (strstr($ann[$i], ",ADD")) {
                    $found = $key;
                }
                $i += 1;
            }
            if ($found != "") {
                $_SESSION["adder_token"][$device][$basic_tok] = $found;
            }
        }
    }
}

function calculate_tok_hex($device){
    # for basic_tok only
    $_SESSION["tok_hex"][$device] = [];
    foreach ($_SESSION["announce_all"][$device] as $key => $value) {
        if ($key == "0") {
            continue;
        }
        $tok = (int)basic_tok($key);
        if (!array_key_exists($tok, $_SESSION["tok_hex"][$device])){
            $_SESSION["tok_hex"][$device][$tok] = dec_hex($tok, $_SESSION["property_len"][$device][$tok][0]);
        }
    }
}

function init_data($device){
    # set data  for all token to "0" (or corresponding real data by translate)
    # all actual_data are strings
    # create $_SESSION[actual_data][$device]
    $_SESSION["actual_data"][$device] = [];
    foreach ($_SESSION["announce_all"][$device] as $key => $value) {
        $ct = explode(",", $value[0])[0];
        switch ($ct) {
            case "m":
                $field = $_SESSION["original_announce"][$device][$key];
                $_SESSION["actual_data"][$device][$key] = $field[2] . "," . $field[3] . "," . $field[1];
                break;
            case "as":
            case "os":
            case "ou":
            case "at":
                if (strstr($key, "x")) {
                    # always one dimension data
                    $_SESSION["actual_data"][$device][$key] = explode(",",$_SESSION["announce_all"][$device][$key][1])[0];
                }
                elseif (strstr($key, "b")) {
                    # stack
                    $_SESSION["actual_data"][$device][$key] = strval(explode(",",$_SESSION["des_range"][$device][$key])[0]);
                }
                else {
                    # for answer command
                    $_SESSION["actual_data"][$device][$key] = 0;
                }
                break;
            case "ar":
            case "or":
                if (strstr($key, "x")) {
                    $_SESSION["actual_data"][$device][$key] = "0";
                }
                elseif (strstr($key, "b")) {
                    # stack
                    $_SESSION["actual_data"][$device][$key] = strval($_SESSION["des_range"][$device][$key]);
                }
                else{
                    # answer
                    $_SESSION["actual_data"][$device][$key] = 0;
                }
                break;
            case "ap":
            case "op":
                # always one dimension data or stack
                $start = 0;
                if (strstr($key, "x")) {
                    # always one dimension data
                    if (!strstr($key, "x0")) {
                        # x0 is dummy
                        $range = $_SESSION["des_range"][$device][$key];
                        $ra = explode(",", $range);
                        if (count($ra) > 1) {
                            if (!strstr($ra[1], "to")) {
                                # a,g,b 1_...
                                $r = explode(",", $ra[1])[0];
                                $start = str_replace("{", "", $r);
                            }
                            else {
                                # range
                                $start = explode("_", explode("to", $ra[1])[0])[1];
                            }
                        }
                        } else {
                            $start = 0;
                        }
                        $_SESSION["actual_data"][$device][$key] = $start;
                }
                elseif (strstr($key, "b")) {
                    # stack
                    $_SESSION["actual_data"][$device][$key] = strval(explode(",",$_SESSION["des_range"][$device][$key])[1]);
                }
                else {
                    # for answer command
                    $_SESSION["actual_data"][$device][$key] = 0;
                }
                break;
            case "oo":
                # data only
                $_SESSION["actual_data"][$device][$key] = 0;
                break;
            case "om":
            case "am":
            case "on":
            case "an":
                if (strstr($key, "b")) {
                    # for memory positions
                    $_SESSION["actual_data"][$device][$key] = 0;
                }
                elseif(strstr($key, "x1")) {
                    # for data
                    $_SESSION["actual_data"][$device][$key] = explode(";",$_SESSION["des_type"][$device][$key])[4];
                }
                else{
                    # for answer command
                    $_SESSION["actual_data"][$device][$key] = 0;
                }
                break;
            case "oa":
            case "aa":
                if (strstr($key, "b")) {
                    # for pos
                    $_SESSION["actual_data"][$device][$key] = "0";
                }
                elseif(strstr($key, "x")) {
                    # for data, comma separated value
                    if(!strstr($key,"x0")) {
                        $start = explode(";", $_SESSION["des_type"][$device][$key])[4];
                        $_SESSION["actual_data"][$device][$key] = $start;
                    }
                }
                else {
                    # for answer command
                    $_SESSION["actual_data"][$device][$key] = 0;
                }
                break;
            case "ob":
            case "ab":
                if (strstr($key, "b")) {
                    # for pos and number
                    $_SESSION["actual_data"][$device][$key] = "0";
                }
                elseif(strstr($key, "x")) {
                    # for data, comma separated value
                    if(!strstr($key,"x0")) {
                        $start = explode(";", $_SESSION["des_type"][$device][$key])[4];
                        $_SESSION["actual_data"][$device][$key] = $start;
                    }
                    else {
                        $_SESSION["actual_data"][$device][$key] = 0;
                    }
                }
                else {
                    # for answer command
                    $_SESSION["actual_data"][$device][$key] = 0;
                }
                break;
            default:
                # not used
                $_SESSION["actual_data"][$device][$key] = "0";
                break;
            }
    }
}
?>
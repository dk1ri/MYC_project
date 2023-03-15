<?php
# translate.php
# DK1RI 20230302
function correct_POST($device){
    # make mods on op ap oo commands only (???)
    # now data beyond the limits can be inputted for op oo commands with > 100 distinct values
    # before using for send and actual_data, they will be corrected to nearest valid data
    # all $_SESSION["corrected_POST"] values are strings
    $_SESSION["corrected_POST"][$device] = [];
    foreach ($_POST as $token => $value) {
        if (array_key_exists($token, $_SESSION["announce_all"][$device])) {
            $basic_tok = basic_tok($token);
            $ct = explode(",", $_SESSION["announce_all"][$device][$token][0])[0];
            switch ($ct) {
                case "ap":
                case "op":
                case "oo":
                    $_SESSION["corrected_POST"][$device][$token] = correct_op_oo_range($token, $value);
                    break;
                case "om":
                case "am":
                case "an":
                    if (strstr($token, "b")) {
                        $_SESSION["corrected_POST"][$device][$token] = correct_memory_range($token, $value);
                    }
                    elseif (strstr($token, "x")){
                        # data
                        $des_type = explode(";", $_SESSION["des_type"][$device][$token])[0];
                        $_SESSION["corrected_POST"][$device][$token] = correct_data($value, $des_type);
                    }
                    else {
                        $_SESSION["corrected_POST"][$device][$token] = $value;
                    }
                    break;
                case "oa";
                    if (strstr($token, "b")){
                        # position: no correction
                        $_SESSION["corrected_POST"][$device][$token] = $value;
                    }
                    else{
                        # $_POST has data for a specific element; with number of either corrected_POST or actual_data
                        if (array_key_exists($basic_tok."b0", $_SESSION["corrected_POST"][$device])) {
                            $tok_sub_number = $_SESSION["corrected_POST"][$device][$basic_tok."b0"];
                        }
                        else{
                            if (array_key_exists($basic_tok."b0", $_SESSION["actual_data"][$device])) {
                                $tok_sub_number = $_SESSION["actual_data"][$device][$basic_tok . "b0"];
                            }
                            else {
                                # one element only
                                $tok_sub_number = 0;
                            }
                        }
                        $des_type = explode(";", $_SESSION["des_type"][$device][$token])[0];
                        $_SESSION["corrected_POST"][$device][$token] = correct_data($value, $des_type);
                    }
                    break;
                case "aa":
                    # no correction
                    $_SESSION["corrected_POST"][$device][$token] = $value;
                    break;
                default:
                    # switches and on ( comman separated list
                    $_SESSION["corrected_POST"][$device][$token] = $value;
            }
        }
    }
}

function correct_op_oo_range($token, $value){
    # for op/oo commands
    $device = $_SESSION["device"];
    if (strstr($token, "x") and explode(",",$_SESSION["announce_all"][$device][$token][1])[0] > 256){
        # only these may have not valid data
        # not ready
    }
    return $value;
}

function correct_memory_range($token, $value){
    # for memory-positions (and some op/oo commands
    # has discrete values always !
    #  needed only, if manual entry is provided (not now)
    $device = $_SESSION["device"];
    $found = "";
    $positions = explode(",",$_SESSION["des_range"][$device][$token]);
    $i = 0;
    $stop = 0;
    while ($i < count($positions) and !$stop){
        if ($positions[$i] == $value){
            $found = $value;
            $stop = 1;
        }
        else {
            if ($value > $positions[$i]){
                $found = $positions[$i];
            }
        }
        $i += 1;
    }
    if ($found == ""){
        # should not happen, set to max
        $found = $positions[$i];
    }
    return $found;
}

function correct_data($data, $type){
    if ($data != ""){
        switch ($type) {
            case "a":
                if ($data < 0) {
                    $data = 0;
                }
                if ($data > 1) {
                    $data = 1;
                }
                break;
            case "b":
                if ($data < 0) {
                    $data = 0;
                }
                if ($data > 255) {
                    $data = 255;
                }
                break;
            case "c":
                if ($data < -128) {
                    $data = -128;
                }
                if ($data > 127) {
                    $data = 127;
                }
                break;
            case "i":
                if ($data < -32768) {
                    $data = -32768;
                }
                if ($data > 32767) {
                    $data = 32767;
                }
                break;
            case "w":
                if ($data < 0) {
                    $data = 0;
                }
                if ($data > 65535) {
                    $data = 65535;
                }
                break;
            case "e":
                if ($data > 2147483647) {
                    $data = 2147483647;
                }
                if ($data < -2147483648) {
                    $data = -2147483648;
                }
                break;
            case "L":
                if ($data < 0) {
                    $data = 0;
                }
                if ($data > 4294967295) {
                    $data = 4294967295;
                }
                break;
            case (is_numeric($data)):
                # length of string
                if (strlen($data) > $type) {
                    $data = substr($data, 0, $type);
                }
                # other restriction: missing
                break;
        }
    }
    return strval($data);
}

function translate_dec_to_hex($basic_tok, $type, $data, $length){
    # $type is a MYC datatype
    # $type == n is unsigned number with $length
    # $data is already corrected
    switch ($type) {
        case "n":
            return dec_hex((int)$data, $length);
        case "a":
        case "b":
            # 0 or 1
            # byte
            return dec_hex((int)$data,2);
        case "c":
            # 1 byte signed short
            return dec_hex($data + 128, 2) ;
        case "i":
            # 2 byte signed integer
            return dec_hex($data + 32768, 4);
        case "w":
            # 2 byte unsigned word
            return dec_hex((int)$data, 4);
        case "e":
            # 4 byte signed long
            return dec_hex($data + 2147483647, 4);
        case "L":
            # 4 byte unsigned long
            return dec_hex((int)$data, 8);
        case (is_numeric($type)):
            # string
            # length is length_of_length
            # $type is max of string_length
            $device = $_SESSION["device"];
            $string_length = strlen($data);
            if ($string_length > $type){
                $string_length = $type;
                $data = substr($data,0,$string_length);
            }
            $result = dec_hex($string_length, $length);
            return $result . bin2hex($data);
    }
    return "";
}

function fillup($data, $length){
    if(strlen($data) > $length){
        # drop leading chars
        $length *= -1;
        $data = substr($data, $length);
    }
    else{
        # fill up with leading "0" (characters!!!)
        $dat = "";
        $i = strlen(strval($data));
        while ($i < $length) {
            $dat .= "0";
            $i += 1;
        }
        $data = $dat . $data;
    }
    return $data;
}

function translate_actual_to_hex_for_p($token){
    # create hex string to send for p commands from actual data
    $device = $_SESSION["device"];
    if (strstr($token,"d")){
        #these are memory type data
        # not ready!!!
        return($_SESSION["actual_data"][$device][$token][0]);
    }
    else {
        $elements = $_SESSION["des_range"][$device][$token];
        $no_of_elements = count($elements);
        $element = 0;
        $no_of_steps_to_now = 0;
        $actual = convert($_SESSION["actual_data"][$device][$token][0]);
        while ($element < $no_of_elements) {
            $spacing = $elements[$element];
            $to = $elements[$element + 2];
            $i = $elements[$element + 1];
            while ($i <= $to) {
                if ($i >= $actual) {
                    break;
                }
                $i += $spacing;
                $no_of_steps_to_now += 1;
            }
            $element += 3;
        }
        return dec_hex($no_of_steps_to_now, $_SESSION["property_len"][$device][$token][2]);
    }
}

function translate_hex_to_actual($device, $token, $data){
    # data for memory type
    # input: array of ascii value (string) from device; must be converted to actual data for GUI
    # in $_SESSION["actual_data"]..
    $type = explode(";",$_SESSION["des_type"][$device][$token])[0];
    $dat = "";
    switch ($type){
        case "a";
        case "b":
            $dat = chr($data);
            break;
        case "c":
            $dat = (int)chr($data) - 128;
            break;
        case "w":
            $dat = (int)chr($data[0]) * 256 + (int)chr($data[1]);
            break;
        case "i":
            $dat = (int)chr($data[0]) * 256 + (int)chr($data[1]) - 32768;
            break;
        case "e":
            $dat = (int)chr($data[0]) * 16777216 + (int)chr($data[0]) * 65536 + (int)chr($data[0]) * 256 + (int)chr($data[1]) - 2147483647;
            break;
        case "L":
            $dat = (int)chr($data[0]) * 16777216 + (int)chr($data[0]) * 65536 + (int)chr($data[0]) * 256 + (int)chr($data[1]);
            break;
        case "s":
            $dat = $data[0] . "," . strval((int)chr($data[0]) * 65536 + (int)chr($data[0]) * 256 + (int)chr($data[1]));
            break;
        case (is_numeric($type)):
            $i = 1;
            while ($i < count($data)){
                $dat .= chr($data[$i]);
                $i += 1;
            }
    }
    return $dat;
}

function translate_simple_range($tok, $pos){
    # range is comma separated list 1,a,2,b,3,1,4,2,5,4...
    # return the value for the postion
    $device = $_SESSION["device"];
    $range = explode(",", $_SESSION["des_range"][$device][$tok]);
    return $range[$pos];
}

function retranslate_simple_range($range, $actual, $add ){
    # this is the inverse of translate_simple_range
    # range is comma separated list 1,a,2,b,3,1,4,2,5,4...
    # return is position of actual in range
    # actual is found always
    # for stacks: $add = 2
    # for memory-positions $add = 1
    $i = 0;
    $found = 0;
    $value = 0;
    while ($i <  count($range) and $found == 0) {
        if ($actual == $range[$i + 1]) {
            $found = 1;
        }
        else {
            $value += 1;
        }
        $i += $add;
    }
    return $value;
}

function retranslate_full($tok, $actual){
    # for $actual > 255 $_SESSION["des_range"][$device][$tok] has copy of original announcement
    # max[,label][{a,b,c,x_ytoz}]
    $device = $_SESSION["device"];
    $found = 0;
    $value = 0;
    $ranges = explode(",",$_SESSION["des_range"][$device][$tok]);
    if (count($ranges) == 1){
        # no translation
        $value = $actual;
    }
    # remove max
    $t = array_splice($ranges,0,1);
    if (count($ranges)> 0){
        if (!strstr($ranges[0],"_") and !strstr($ranges[0], "to")){
            # label has no _ and to
            $t = array_splice($ranges,0,1);
        }
    }
    if (count($ranges)> 0){
        $ra = implode(",", $ranges[0]);
        $ra = str_replace("{", "",$ra);
        $ra = str_replace("{", "",$ra);
        $ra = explode(",", $ra);
        $i = 0;
        while ($i < count($ra)){
            if (strstr($ra[$i], "_")){
                #
                $to_a = explode("to", $ra[$i]);
                $to = $to_a[1];
                $spacing_a = explode("_", $to_a[0]);
                $spacing = $spacing_a[0];
                $from = $spacing_a[1];
                $number_of_values = ($to - $from) / $spacing;
                if ($actual > $to){
                    $value .= $number_of_values;
                }
                else{
                    # something with the range
                    $rel_pos = ($to - $from) / $actual;
                    $value .= $rel_pos / $spacing;
                    $found = 1;
                }
            }
            else {
                #deskrete valuse
                if ($ra[$i] == $actual){
                    $found = 1;
                }
            }
            if (!$found) {
                $value += 1;
            }
            $i += 1;
        }
    }
    return $value;
}
?>


<?php
# subs.php
# DK1RI 20230608
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function basic_tok($o_tok){
    # return basic_token
    if (strstr($o_tok, "a")) {
        # for answer commands
        $tok = explode("a", $o_tok)[0];
    } elseif (strstr($o_tok, "b")) {
        # for stack
        $tok = explode("b", $o_tok)[0];
    } elseif (strstr($o_tok, "c")) {
        # for ADD
        $tok = explode("c", $o_tok)[0];
    } elseif (strstr($o_tok, "x")) {
        # for data
        $tok = explode("x", $o_tok)[0];
    } elseif (strstr($o_tok, "d")) {
        # for data
        $tok = explode("d", $o_tok)[0];
    } elseif (strstr($o_tok, "m")) {
        # for stack
        $tok = explode("m", $o_tok)[0];
    } elseif (strstr($o_tok, "n")) {
        # for ADD
        $tok = explode("n", $o_tok)[0];
    } else {
        $tok = $o_tok;
    }
    return $tok;
}

function dec_hex($key, $len){
    $val = dechex((int)$key);
    $i = strlen($val);
    while ($i < $len){
        $val = "0".$val;
        $i += 1;
    }
    return $val;
}

function convert($num){
    if (strstr($num, ".")){
        return floatval($num);
    }
    else {
        return intval($num);
    }
}

function length_of_number($data){
    # no of bytes for transmit
    # include 0!!!
    if (is_numeric($data)){
        $number = (int)$data;
        # length of binary number
        $len = 2;
        if ($number > 16777216){
            $len = 8;
        } elseif ($number > 65536) {
            $len = 6;
        } elseif ($number > 256){
            $len = 4;
        }
    }
    else{
        $len = 0;
    }
    # dummy
    return $len;
}

function length_of_type($data){
    # no of bytes for transmit
    if (is_numeric($data)){
        # for strings: length of length, not the max number allowed
        return length_of_number($data);
    }
    else {
        switch ($data) {
            case "a":
            case "b":
            case "c":
                return 2;
            case "i":
            case "w":
                return 4;
            case "k":
            case "l":
                return 6;
            case "e":
            case "L":
            case "s":
                return 8;
            case "d":
            case "t":
            case "u":
                return 16;
        }
    }
    # dummy
    return $data;
}

function display_length($type){
    # max length to display the real value
    if (is_numeric($type)){
        # string
        return $type;
    }
    else {
        switch ($type) {
            case "a":
                return 1;
            case "b":
            case "f":
                return 3;
            case "c":
                return 4;
            case "w":
                return 5;
            case "i":
                return 6;
            case "s":
                return 8;
            case "L":
                return 10;
            case "e":
                return 11;
            case "d":
            case "t":
            case "u":
                return 18;
            default:
                return 2;
        }
    }
}

function find_allowed($type){
    switch ($type){
        case "a":
            return [0, 1];
        case "b":
        case "s":
        case "d":
            return [0, 255];
        case "c":
            return [-128, 127];
        case "i":
            return [-32768, 32767];
        case "w":
            return [0 , 65535];
        case "e":
            return [-2147483648, 2147483647];
        case "L":
            return [0, 4294967295];
        default:
            return ["",""];
    }
}

function real_to_transmit_simple($data, $type){
    # numeric values are shifted if necessary
    # convert to integer
    if (is_numeric($data)) {
        list($min,$max) = find_allowed($type);
        switch ($type) {
            case "c":
                $data += 128;
                break;
            case "i":
                $data += 32768;
                break;
            case "e":
                $data += 2147483648;
                break;
        }
        $data = intval($data);
        if ($data < 0){$data = 0;}
        if ($data < $max){$data = $max;}
    }
    return $data;
}

function adapt_len($token, $element, $actual){
    $device =$_SESSION["device"];
    $result = "";
    $length = $_SESSION["property_len"][$device][basic_tok($token)][2];
    $i = strlen(strval($actual));
    if ($length > 20){
        $length = 20;
    }
    while ($i < $length){
        $result .= " ";
        $i += 1;
    }
    return $result.$actual;
}

function hex_to_decimal($byte_values){
    # bytes_values array contain decimal values -> to decimal
    $real = 0;
    $i = 0;
    while ($i < count($byte_values)){
        $real *= 256;
        $real += $byte_values[$i];
        $i += 1;
    }
    return $real;
}

function no_lower_case($data){
    # return 1 if string not contain any lower case characters
    $i = 0;
    $ret = 1;
    while ($i < strlen($data)){
        $asci = $data[$i];
        if ($asci >  96 and $asci < 123){
            $ret = 0;
            continue;
        }
        $i += 1;
    }

    return$ret;
}

function create_tok_list($device){
    $_SESSION["tok_list"][$device] = [];
    foreach ($_SESSION["original_announce"][$device] as $tok => $value) {
        foreach ($_SESSION["activ_chapters"][$device] as $chapter => $val){
            if (array_key_exists($tok, $_SESSION["chapter_token"][$device][$chapter])) {
                if (!array_key_exists($tok, $_SESSION["tok_list"][$device])) {
                    $_SESSION["tok_list"][$device][$tok] = 1;
                }
            }
        }
    }
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
            $string_length = strlen($data);
            if ($string_length > $type){
                $data = substr($data,0,$string_length);
            }
            $result = dec_hex($string_length, length_of_number($type));
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

function retranslate_simple_range($range, $actual, $add ){
    # this is the inverse of translate_simple_range
    # range is comma separated list 1,a,2,b,3,1,4,2,5,4...
    # return is position of actual in range
    # actual is found always
    # for stacks: $add = 2
    # for memory-positions $add =
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

function translate_received_data_type($tok, $data){
    # transmitted (actual) -> real
    # data returned from device (in actual_data) will be translated to real values, if necessary
    $device = $_SESSION["device"];
    $des_type = $_SESSION["des_type"][$device];
    if (array_key_exists($tok, $des_type)) {
        # $range : maxnumber {... }
        if (!is_numeric($des_type[$tok][0])) {
            # numeric type
            $range_pure = explode(",", explode(";", $des_type[$tok])[3]);
            $data = numeric_range($range_pure, $data);
        }
    }
    #else: string; all data from device are valid
    return $data;
}

function numeric_range($range_pure, $data)
{
# range_pure (array): n1 n2 n3_n4ton5 ...
# if $real_value_number == $data -> realvalue is found
    if ($data == "") {
        return $data;
    }
    $real_value_number = 0;
    $nummber_range_elements = count($range_pure);
    $i = 0;
    $found = 0;
    while ($i < $nummber_range_elements and $found == 0) {
        $range_to = explode("_", $range_pure[$i]);
        if (count($range_to) > 1) {
            # n3_n4ton5,
            $separator = $range_to[0];
            $exp2 = explode("to", $range_to[1]);
            $from = $exp2[0];
            $to = $exp2[1];
            $max_counts = ($to - $from) / $separator;
            if ($real_value_number + $max_counts > $data) {
                $data = ($data - $real_value_number) * $separator + $from;
                $found = 1;
            } else {
                $real_value_number += $max_counts;
            }
        } else {
            # one value element
            if ($real_value_number == $data) {
                $data = $range_pure[$i];
                $found = 1;
            }
            $real_value_number += 1;
        }
        $i += 1;
    }
    return $data;
}
function split_range($data){
    $range = explode("_", $data);
    $separator = $range[0];
    $range2 = explode("to", $range[1]);
    return [$separator, $range2[0], $range2[1]];
}
function delete_bracket($data){
    $data = str_replace("{","",$data);
    $data = str_replace("}","",$data);
    return $data;
}
?>


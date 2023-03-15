<?php
# subs.php
# DK1RI 20230302
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
    if (is_numeric($data)){
        $number = (int)$data;
        # length of binary number
        $len = 2;
        if ($number > 16777215){
            $len = 8;
        } elseif ($number > 65535) {
            $len = 6;
        } elseif ($number > 255){
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
        $number = length_of_number($data);
        return $number;
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
            case "e":
            case "L":
            case "s":
                return 8;
            case "d":
            case "t":
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
                return 18;
            default:
                return 2;
        }
    }
}

function find_allowed($type){
    switch ($type){
        case "a":
            return "0|1";
        case "b":
            return "0 to 255";
        case "c":
            return "-128 to 127";
        case "i":
            return "-32768 to 32767";
        case "w":
            return "0 to 65535";
        case "e":
            return "-2147483648 to 2147483647";
        case "L":
            return "0 to 4294967295";
        case "s":
            return "3 byte / 0 to 255";
        case "d":
            return "7byte / 0 to 255";
        default:
            return "";
    }
}

function find_name($type){
    switch ($type){
        case "a":
            return "bit";
        case "b":
            return "byte";
        case "c":
            return "signedshort";
        case "i":
            return "signed word";
        case "w":
            return "word";
        case "e":
            return "signed long";
        case "L":
            return "long";
        case "s":
            return "single";
        case "d":
            return "double";
        case is_numeric($type):
            return "alpha";
    }
    # dummy
    return $type;
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
?>


<?php
# subs.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function basic_tok($o_tok){
    # return basic_token
    # for answer commands
    $tok = explode("a", $o_tok)[0];
    # for data
    $tok = explode("d", $tok)[0];
    # for stack and memorypositions
    $tok = explode("m", $tok)[0];
    # for ADD
    $tok = explode("n", $tok)[0];
    # for on elements
    $tok = explode("o", $tok)[0];
    if (!is_numeric($tok)){$tok = "";}
    return $tok;
}

function dec_hex($key, $len){
    # for numeric values: fill leading "0"
    $val = dechex((int)$key);
    $i = strlen($val);
    while ($i < $len){
        $val = "0".$val;
        $i += 1;
    }
    return $val;
}

function length_of_number($data){
    # number of characters for transmit as hex (2 characters per byte)
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
            case "n":
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
    # displayed data (check b!! -> not numeric
    switch ($type){
        case "a":
            return [0, 1];
        case "b":
            # should not be used for numbers; for backward compatibility
            return [0, 255];
        case "c":
            return [-128, 127];
        case "n":
            return [0, 255];
        case "i":
            return [-32768, 32767];
        case "w":
            return [0 , 65535];
        case "l":
            return [-8388608, 8388607];
        case "k":
            return [0, 16777215];
        case "e":
            return [-2147483648, 2147483647];
        case "L":
            return [0, 4294967295];
        case "s":
            return [-3.4e38,3.4e38];
        case "d":
            return[-9.9e96, 9.9e96];
        default:
            return ["",""];
    }
}
function find_length_of_displayed_vars($type){
    # displayed data (real max length + 1)
    switch ($type){
        case is_numeric($type);
            if ($type > 20){
                return 21;
            }
            else{
                return $type +1;
            }
        case "a":
            return 2;
        case "b":
            # should not be used for numbers; for backward compatibility
            return 11;
        case "c":
            return 5;
        case "n":
            return 4;
        case "i":
            return 7;
        case "w":
            return 6;
        case "l":
            return 8;
        case "k":
            return 9;
        case "e":
            return 10;
        case "L":
            return 11;
        case "s":
            return 14;
        case "d":
            return 20;
        default:
            return 1;
    }
}

function find_name_of_type($type){
    switch ($type){
        case "a":
            return "bit";
        case "b":
            return "byte";
        case "c":
            return "signed short";
        case "n":
            return "short";
        case "i":
            return "signed word";
        case "w":
            return "word";
        case "l":
            return "signed 3byte";
        case "k":
            return "3byte";
        case "e":
            return "signed long";
        case "L":
            return "long";
        case "s":
            return "single";
        case "d":
            return "double";
        case is_numeric(($type)):
            return "string";
        default:
            return "";
    }
}

function translate_dec_to_hex($type, $data, $length){
    # $type is a MYC datatype
    # $type == m is unsigned number with $length (if $lenth > 0)
    switch ($type) {
        case "m":
            return dec_hex(intval($data), $length);
        case "n":
            return dec_hex(intval($data), 2);
        case "a":
        case "b":
            # 0 or 1
            # byte
            return dec_hex((int)$data,2);
        case "c":
            # 1 byte signed short
            return dec_hex($data + 128, 2);
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

function split_range($data){
    $range = explode("_", $data);
    $range2 = explode("to", $range[1]);
    return [string_to_num($range[0]), string_to_num($range2[0]), string_to_num($range2[1])];
}

function string_to_num($dat){
    if (strstr($dat, ".")){
        $dat = floatval($dat);
    }
    else{
        $dat = intval($dat);
    }
    return $dat;
}

function delete_bracket($data){
    $replace = array("{","}");
    return str_replace($replace,"",$data);
}

function type_coding($coding){
    # return: min, max
    switch ($coding[1]) {
        case "UNIXTIME8":
            return [0,1000000000000];
        case "TIME":
            return [0, 86400];
        case "DAYSEC":
        case "DAYMIN":
        case "DAYHOUR":
            return [0,60];
        case "DAY":
            return [0,31];
        case "YEARDAY":
            return [0, 365];
        case "YEARDAY0":
        case "UNIXTIME4":
            return [0, 4294967295];
        case "MON":
            return [0, 12];
        case "YEAR0":
            return [0, 65535];
        case "YEARNA":
            return [-2147483648,2147483647];
    }
    return [0, 0];
}

function stuff_bin($data){
    # expand (binary) string to multiple of 8 bytes
    $result = "";
    $mod_len = strlen($data) % 8 ;
    if ($mod_len != 0){
        $i = 0;
        while ($i < 8 - $mod_len){
            $result .= "0";
            $i++;
        }
        $result.= $data;
    }
    else {$result = $data;}
    return $result;
}

function convert_bin_hex($value, $type){
    # $type is myc type
    # strings:
    # convert ascii hex and binary string $value to chars ( not hex !!!)
    # hex values must start with $H, binary with &B
    # stringlength is not !!! added
    # numbers: for hex or bin: must start with &H or &B; comomplete string must be hex or bin
    # minus numbers start with "-"; one . or e or e- is allowed
    # non valid numbers will set $_SESSION["send_ok] = 0
    $result = "";
    if (is_numeric($type) or $type == "b"){
        $char_type = "T";
        $last_char = "";
        $string_to_convert = "";
        for ($i = 0; $i < strlen($value); $i++){
            if ($char_type == "T") {
                # character_type == "T"
                if ($value[$i] == "&") {
                    $last_char = "&";
                } elseif ($value[$i] == "H" or $value[$i] == "B" or $value[$i] == "T") {
                    if ($last_char == "&") {
                        $char_type = $value[$i];
                    } else {
                        $result .= $last_char;
                        $result .= $value[$i];
                        $last_char = "";
                    }
                }
                else {
                    # other chars
                    if ($last_char != "&") {
                        $result .= $last_char;
                    }
                    $result .= $value[$i];
                }
            }
            elseif ($char_type == "B"){
                if ($value[$i] == "0" or $value[$i] == "1"){
                    $string_to_convert .= $value[$i];
                    if (strlen($string_to_convert) == 8){
                        # one byte found
                        $result .= chr(dechex(bindec($string_to_convert)));
                        $string_to_convert = "";
                    }
                }
                else{
                    # other character -> end
                    if (strlen($string_to_convert) > 0) {
                        $result .= chr(dechex(bindec(stuff_bin($string_to_convert))));
                    }
                    $string_to_convert = "";
                    if ($value[$i] != "&") {
                        $result .= $value[$i];
                        $char_type = "T";
                        $last_char = "";
                    }
                    else{
                        $last_char = "&";
                    }
                }
            }
            elseif($char_type == "H"){
                if (trim($value[$i], '0..9A..Fa..f') == ''){
                    $string_to_convert .= $value[$i];
                    if (strlen($string_to_convert) == 2){
                        $result .=  hex2bin($string_to_convert);
                        $string_to_convert = "";
                    }
                }
                else{
                    # other character -> end
                    if (strlen($string_to_convert) > 0) {
                        if (strlen($string_to_convert) == 1){$string_to_convert = "0".$string_to_convert;}
                        $result .= hex2bin($string_to_convert);
                        $string_to_convert = "";
                    }
                    if ($value[$i] != "&") {
                        $result .= $value[$i];
                        $string_to_convert = "";
                        $char_type = "T";
                        $last_char = "";
                        $bin_hex_started = 0;
                    }
                    else{
                        $last_char = "&";
                        $bin_hex_started = 1;
                    }
                }
            }
        }
        if (strlen($string_to_convert) > 0) {
            if($char_type == "H") {
                if (strlen($string_to_convert) == 1) {
                    $string_to_convert = "0" . $string_to_convert;
                }
                $result .= hex2bin($string_to_convert);
            }
            elseif ($char_type == "B"){
                $result .= chr(dechex(bindec(stuff_bin($string_to_convert))));
            }
        }
    }
    else{
        # number
        $n_b = substr($value,0, 2);
        if ($n_b == "&H"){
            if (strlen($value) % 2 != 0){
                $value = "0". $value;
            }
            $result = hexdec(substr($value,3));
        }
        elseif ($n_b == "&B"){
            $result .= bindec(stuff_bin($value));
        }
        else{
            $minus = 0;
            If (substr($value,0, 1) == "-"){
                $minus = 1;
                $value = substr($value,1);
            }
            if (is_numeric($value)){
                # one "." only
                $n1to9 = array("1","2","3","4","5","6","7","8","9","0","e");
                $dot_e = str_replace($n1to9, "", $value);
                if (strlen($dot_e) > 1){$_SESSION["send_ok"]= 0;}
                # one "e" only
                $n1to9 = array("1","2","3","4","5","6","7","8","9","0",".");
                $dot_e = str_replace($n1to9, "",$value);
                if (strlen($dot_e) > 1){$_SESSION["send_ok"]= 0;}
                # no single "-"
                if (strstr($value,"-") and !strstr($value,"e-")) {$_SESSION["send_ok"]= 0;}
                $result = 0;
                if ($_SESSION["send_ok"] == 1){
                    if (strstr($value, ".") or strstr($value,"e-")){
                        $result = (float)$value;
                        }
                   else {
                       $result = (int)$value;
                    }
                   if ($minus){$result = $result * -1;}
                }
            }
            else{
                $_SESSION["send_ok"] = 0;
            }
        }
    }
    return $result;
}
function check_valid_hex($data){
    # delete 0H
    $data = substr($data,2);
    $valid = 1;
    if ($data != "") {
        $data = strtoupper($data);
        $hex_vals = array("1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "A", "B", "C", "D", "E", "F");
        $i = 0;
        while ($i < strlen($data) and $valid) {
            $ch = substr($data, $i, 1);
            $null = str_replace($hex_vals, "", $ch);
            if ($null != "") {
                $valid = 0 ;
            }
            $i++;
        }
    }
    else {$valid = 0;}
    return $valid;
}

function check_valid_bin($data){
    # delete 0B
    $data = substr($data,2);
    $valid = 1;
    if ($data != "") {
        $data = strtoupper($data);
        $hex_vals = array("1", "0");
        $i = 0;
        while ($i < strlen($data) and $valid) {
            $ch = substr($data, $i, 1);
            $null = str_replace($hex_vals, "", $ch);
            if ($null != "") {
                $valid = 0 ;
            }
            $i++;
        }
    }
    else {$valid = 0;}
    return $valid;
}

function checkusername($username){
    $i = 0;
    $s = "";
    while ($i < strlen($username)){
        $chr = substr($username,$i, 1);
        if (is_numeric($chr)){$s .=$chr;}
        elseif (ord($chr) > 63 and ord($chr)< 91){$s .= $chr;}
        elseif (ord($chr) > 96 and ord($chr)< 123){$s .= $chr;}
        $i++;
    }
    if ($username == ""){$username = "user";}
    return $username;
}

function tr($label){
    # translate
    if (array_key_exists($_SESSION["is_lang"],$_SESSION["translate"])) {
        if (array_key_exists($label, $_SESSION["translate"][$_SESSION["is_lang"]])) {
            return $_SESSION["translate"][$_SESSION["is_lang"]][$label];
        }
    }
    if (array_key_exists($_SESSION["is_lang"],$_SESSION["additional_language"])) {
        if (array_key_exists($label, $_SESSION["additional_language"][$_SESSION["is_lang"]])) {
            return $_SESSION["additional_language"][$_SESSION["is_lang"]][$label];
        }
    }
    return $label;
}

function ignore_some_POSTs($data){
    if(array_key_exists($data,$_SESSION["other_POSTS"])){return 1;}
    else{return 0;}
}

function create_command_len(){
    $device = $_SESSION["device"];
    if (array_key_exists("65520", $_SESSION["original_announce"][$device])){
        $_SESSION["command_len"][$device] = 2;
    }
   else {
       $_SESSION["command_len"][$device] = 1;
   }
}
?>
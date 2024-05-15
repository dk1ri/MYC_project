<?php
# update_received.php
# DK1RI 20240324
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function receive_civ(){
    read_from_device();
    $i = 0;
    while ($_SESSION["received_data"]  != "" and $i < 100) {
        # update actual_data by data from device
        update_received();
        $i++;
    }
    # should never happen
    if ($i == 100){
        if ($_SESSION["conf"]["testmode"]){print " error";}
        $_SESSION["received_data"]  = "";
    }

}
function update_received(){
    # data from device
    $from_device = $_SESSION["received_data"] ;
    $error = 0;
    if ($_SESSION["command_len"][$_SESSION["device"]] == 2) {
        if (strlen($_SESSION["received_data"] ) < 2){return;}
        # 2 -> 1 byte
        $basic_tok = hexdec(substr($from_device,0, 2));
        $from_device = substr($from_device,2, null);
    }
    else{
        if (strlen($_SESSION["received_data"] ) < 4){return;}
        $basic_tok = hexdec(substr($from_device, 0, 2)) * 256 + hexdec(substr($from_device,2,2));
        $from_device = substr($from_device,4, null);
    }
    if( !array_key_exists($basic_tok, $_SESSION["original_announce"][$_SESSION["device"]])){
        return;
    }
    $announce = $_SESSION["original_announce"][$_SESSION["device"]][$basic_tok];
    $ct = explode(",", $announce[0])[0];
    switch ($ct) {
        case "m";
            # basic command
            $length = hexdec(substr($from_device, 0, 2));
            $line = substr($from_device, 2, $length);
            $to_delete = ($length + 1) * 2;
            $i = 0;
            $field[0] = "";
            $j = 0;
            $strlen = strlen($line);
            while ($i < $strlen and $j < 5){
                $num = hexdec(substr($line,0,2));
                $line = substr($line,0,2);
                $character = chr($num);
                If ($character == ";") {
                    $j += 1;
                    $field[$j] = "";
                }
                else{
                    $field[$j] .= $character;
                }
                $i += 2;
            }
            if($i == 4){
                $_SESSION["actual_data"][$_SESSION["device"]][$basic_tok. "a"] = "Device: ".$field[3] . " Version: " . $field[4] . " Author: " . $field[2];
            }
            break;
        case "as":
        case "at":
            $to_delete = receive_st($basic_tok, $from_device);
           break;
        case "ar":
            $to_delete = receive_r($basic_tok, $from_device);
            break;
        case "ap":
            $to_delete = receive_p($basic_tok, $from_device);
            break;
        case "am":
            $to_delete = receive_m($basic_tok, $from_device);
            break;
        case "an":
            $to_delete = receive_n($basic_tok, $from_device);
            break;
        case "aa":
            $to_delete = receive_a($basic_tok, $from_device);
            break;
        case "ab":
            $to_delete = receive_b($basic_tok, $from_device);
            break;
        case "af":
            $to_delete = receive_f($basic_tok, $from_device);
            break;
        default:
            $error = 1;
            $to_delete = 0;
            break;
    }
    # for one command $from_device should be empty
    if ($error) {
        $_SESSION["received_data"]  = "";
        if ($_SESSION["conf"]["testmode"]){print "civ receive error";}
    }
    else {
        $from_device = substr($from_device, $to_delete, null);
        $missing_revieved = strlen($from_device);
        $_SESSION["received_data"]  = $from_device;
        if ($_SESSION["conf"]["testmode"]){print "Restlaenge " . $missing_revieved;}
    }
}

function update_memory_data($token, $from_device, $length_of_length){
    # translate (first part of) received hex string depending on type for one element
    # translated data start at position "0"
    # $length_of_length is used for strings only
    if($from_device == ""){return["",0];}
    $bytes_to_delete = 0;
    $type = $_SESSION["type_for_memories"][$_SESSION["device"]][$token];
    $result = "";
    switch ($type){
        case (is_numeric($type)):
            $stringlength = hexdec(substr($from_device,0,$length_of_length));
            # charcters -> *2
            $bytes_to_delete = $stringlength * 2 + $length_of_length;
            $i = $length_of_length;
            $end = $stringlength * 2;
            while ($i <= $end){
                $one_byte = substr($from_device, $i, 2);
                $result .=  convert_hex_to_readable($one_byte);
                $i += 2;
            }
            break;
        case "a":
        case "n":
            $result = hexdec(substr($from_device, 0, 2));
            $bytes_to_delete = 2;
            break;
        case "b":
            $value = substr($from_device, 0, 2);
            $v = hexdec($value);
            if ($v < 32 or $v > 126 or $v == 0x7c) {
                $result = "&H" . $value;
            }
            else{
                $result = hex2bin($value);
            }
            $bytes_to_delete = 2;
            break;
        case "c":
            # 1 byte signed short
            $result = hexdec(substr($from_device, 0, 2)) - 128;
            $bytes_to_delete = 2;
            break;
        case "w":
            $result = hexdec(substr($from_device, 0, 4));
            $bytes_to_delete = 4;
            break;
        case "i":
            # 2 byte signed
            $result = hexdec(substr($from_device, 0, 4));
            $result -= 32768;
            $bytes_to_delete = 4;
            break;
        case "k":
            $result = hexdec(substr($from_device, 0, 6));
            $bytes_to_delete = 6;
            break;
        case "l":
            # 3bate signed
            $result = hexdec(substr($from_device, 0, 6));
            $result -= 8388608;
            $bytes_to_delete = 6;
            break;
        case "e":
            # 4 byte signed long
            $result = hexdec(substr($from_device, 0, 8));
            $result -= 2147483647;
            $bytes_to_delete = 8;
            break;
        case "L":
            # 4 byte unsigned long
            $result = hexdec(substr($from_device, 0, 8));
            $bytes_to_delete = 8;
            break;
        case "t":
            # 8 byte
            $result = hexdec(substr($from_device, 0, 16));
            $bytes_to_delete = 16;
            break;
        case "u":
            # 8 byte signed
            $result = hexdec(substr($from_device, 0, 16));
            $result -= 0x8000000000000000 ;
            $bytes_to_delete = 16;
            break;
    }
    return [$result,$bytes_to_delete];
}

function update_memory_position_stack($basic_tok, $from_device){
    # used for memory-positions and stacks
    # data are correct and stored to $_SESSION["actual_data"][$_SESSION["device"]] directly but splited as <des...>
    $pos = hexdec(substr($from_device,0,$_SESSION["property_len"][$_SESSION["device"]][$basic_tok][1]));
    array_key_exists($basic_tok,$_SESSION["a_to_o"][$_SESSION["device"]]) ? $basic_tok_ = $_SESSION["a_to_o"][$_SESSION["device"]][$basic_tok]: $basic_tok_ = $basic_tok;
    $add_found = 0;
    if (array_key_exists($basic_tok_."n0", $_SESSION["max_for_ADD"][$_SESSION["device"]])){
        # with ADDer
        if ($pos > $_SESSION["max_for_ADD"][$_SESSION["device"]][$basic_tok_."n0"]){
            $i = 0;
            $found = 1;
            while ($found){
                # set others to 0
                if (array_key_exists($basic_tok_."m".$i, $_SESSION["actual_data"][$_SESSION["device"]])){
                    $_SESSION["actual_data"][$_SESSION["device"]][$basic_tok_."m".$i] = 0;
                }
                else{$found = 0;}
                $i++;
            }
            $_SESSION["actual_data"][$_SESSION["device"]][$basic_tok_."n0"] = $pos - $_SESSION["max_for_ADD"][$_SESSION["device"]][$basic_tok_."n0"];
            $add_found = 1;
        }
        else{$_SESSION["actual_data"][$_SESSION["device"]][$basic_tok_."n0"] = 0;}
    }
    if (!$add_found){
        $i = 0;
        $found = 1;
        while ($found){
            $tok = $basic_tok_."m".$i;
            if (!array_key_exists($tok, $_SESSION["des"][$_SESSION["device"]])) {$found = 0;}
            $i++;
        }
        $max_i = $i - 2;
        $i = 0;
        while ($i <= $max_i){
            $tok = $basic_tok_."m".$i;
            $next_tok = $basic_tok_."m".($i + 1);
            if (array_key_exists($next_tok, $_SESSION["des"][$_SESSION["device"]])) {
                $divisor = explode(",",$_SESSION["des"][$_SESSION["device"]][$next_tok])[0];
                $value = intdiv($pos , $divisor);
                $_SESSION["actual_data"][$_SESSION["device"]][$tok] = $value;
                $pos = ($pos % $divisor);
            }
            else{$_SESSION["actual_data"][$_SESSION["device"]][$tok] = $pos;}
            $i++;
        }
    }
}
function update_corresponding_opererating($basic_tok, $extension, $data){
    array_key_exists($basic_tok, $_SESSION["a_to_o"][$_SESSION["device"]]) ? $tok = $_SESSION["a_to_o"][$_SESSION["device"]][$basic_tok]:$tok = $basic_tok;
    $_SESSION["actual_data"][$_SESSION["device"]][$tok . $extension] = $data;
}

function convert_hex_to_readable($one_byte){
    # used for received data string  of memory -> convert received &Hxx data to "&Hxx for non printable characters
    if (hexdec($one_byte) < 32 or hexdec($one_byte) > 126){
        $result = "&H".$one_byte;
    }
    else{$result = chr(hexdec($one_byte));}
    return $result;
}
?>
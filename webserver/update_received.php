<?php
# update_received.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function update_received(){
    # data from device
    $from_device = $_SESSION["received_data"];
    $device = $_SESSION["device"];
    if ($_SESSION["command_len"][$device] == 2) {
        $basic_tok = hexdec(substr($from_device,0, 2));
        $from_device = substr($from_device,2, null);
    }
    else{
        $basic_tok = hexdec($from_device[0] * 256 + $from_device[1]);
        $from_device = substr($from_device,4, null);
    }
    if( !array_key_exists($basic_tok, $_SESSION["original_announce"][$device])){
        return;
    }
    $announce = $_SESSION["original_announce"][$device][$basic_tok];
    $ct = explode(",", $announce[0])[0];
    # characters to delete after handling
    switch ($ct) {
        case "m";
        #   basic command
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
                $_SESSION["actual_data"][$device][$basic_tok. "a"] = $field[3] . "," . $field[4] . "," . $field[2];
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
            $to_delete = 0;
            break;
    }
    # for one command $from_device should be empty
    $from_device = substr($from_device, $to_delete, null );
    print "Restlaenge ".  strlen($from_device)." ";
}

function update_memory_data($token, $from_device, $length_of_length){
    # translate (first part of)received hex string depending on type for one element
    # translated data strat at position "0"
    # $length_of_length is used for strings only
    if($from_device == ""){return["",0];}
    $device = $_SESSION["device"];
    $bytes_to_delete = 0;
    $type = $_SESSION["type_for_memories"][$device][$token];
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
            if ($v < 32 or $v > 126) {
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

function update_memory_position($basic_tok, $from_device){
    # used for memory-positions and stacks
    $device = $_SESSION["device"];
    $pos = hexdec(substr($from_device,0,$_SESSION["property_len"][$device][$basic_tok][1]));
    $pos_with_adder = 0;
    array_key_exists($basic_tok,$_SESSION["a_to_o"][$device]) ? $basic_tok_ = $_SESSION["a_to_o"][$device][$basic_tok]: $basic_tok_ = $basic_tok;
    if (array_key_exists($basic_tok_."n0", $_SESSION["max_for_ADD"][$device])){
        # ADDer possible
        if ($pos > $_SESSION["max_for_ADD"][$device][$basic_tok_."n0"]){
            $i = 0;
            $found = 1;
            while ($found){
                if (array_key_exists($basic_tok_."m".$i, $_SESSION["actual_data"][$device])){
                    $_SESSION["actual_data"][$device][$basic_tok_."m".$i] = 0;
                }
                else{$found = 0;}
                $i++;
            }
            $_SESSION["actual_data"][$device][$basic_tok_."n0"] = $pos - $_SESSION["max_for_ADD"][$device][$basic_tok_."n0"];
            $pos_with_adder = 1;
        }
    }
    if (!$pos_with_adder){
        $i = 0;
        $found = 1;
        while ($found){
            $tok = $basic_tok_."m".$i;
            if (!array_key_exists($tok, $_SESSION["des"][$device])) {$found = 0;}
            $i++;
        }
        $max_i = $i - 2;
        while ($max_i >= 0){
            $tok = $basic_tok_."m".$max_i;
            if (array_key_exists($tok, $_SESSION["des"][$device])) {
                $divisor = explode(",", $_SESSION["des"][$device][$basic_tok_."m".$max_i])[0];
                $value = $pos % $divisor;
                $_SESSION["actual_data"][$device][$basic_tok_ . "m" . $max_i] = $value;
                $pos = floor($pos / $divisor);

            }
            $max_i--;
        }
    }
}
function update_corresponding_opererating($basic_tok, $extension, $data){
    $device = $_SESSION["device"];
    array_key_exists($basic_tok, $_SESSION["a_to_o"][$device]) ? $tok = $_SESSION["a_to_o"][$device][$basic_tok]:$tok = $basic_tok;
    print $tok;
    $_SESSION["actual_data"][$device][$tok . $extension] = $data;
}

function convert_hex_to_readable($one_byte){
    # used for received data string  of memory -> convert received &Hxx data to "&Hxx for non printable characters
    if (hexdec($one_byte) < 32 or hexdec($one_byte) > 126){
        $result = "&H".$one_byte;
    }
    else{$result = chr(hexdec($one_byte));}
    return $result;
}
function retranslate_simple_range($tok, $data){
    # used for "op" command of received data with <des> translation
    # return $sum_counts for actual data
    $device = $_SESSION["device"];
    $result = $data;
    if (array_key_exists($tok, $_SESSION["des_range"][$device])){
        $range = explode(",", $_SESSION["des_range"][$device][$tok]);
        $i = 0;
        $found = 0;
        $result = 0;
        $sum_counts = 0;
        while ($i <  count($range) and $found == 0) {
            if (!strstr($range[$i], "_")) {
                # single characters
                if ($data == $sum_counts) {
                    $found = 1;
                    $result = $range[$i];
                }
                $sum_counts++;
            } else {
                # range
                $step = explode("_", $range[$i])[0];
                $max = explode("to", $range[$i])[1];
                $min = explode("to", explode("_", $range[$i])[1])[0];
                $counts = ($max - $min) / $step;
                if ($sum_counts + $counts < $data) {
                    $sum_counts += $counts;
                } else {
                    $found = 1;
                    $co = $min;
                    $fou = 0;
                    while ($co < $max and $fou == 0) {
                        if ($sum_counts == $data) {
                            $fou = 1;
                            $result = $co;
                        }
                        $co += $step;
                        $sum_counts++;
                    }
                }
            }
            $i++;
        }
    }
    return $result;
}
?>
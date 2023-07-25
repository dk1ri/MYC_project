<?php
# update_received.php
# DK1RI 20230701
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
    $announce = $_SESSION["original_announce"][$device][$basic_tok];
    $ct = explode(",", $announce[0])[0];
    # characters to delete after handling
    $to_delete = 0;
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
            $to_delete = receive_s($basic_tok, explode(",",$announce[1])[0], $from_device);
           break;
        case "ar":
            $to_delete = receive_r($basic_tok, explode(",",$announce[1])[0], $from_device);
            break;
        case "ap":
            $to_delete = receive_p($basic_tok, explode(",",$announce[1])[0], $from_device);
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
        default:
            $to_delete = 0;
            break;
    }
    # for one command $from_device should be empty
    $from_device = substr($from_device, $to_delete, null );
    print "Restlaenge ".  strlen($from_device)." ";
}

function read_to_stacks(){
    #not yet supported
}

function update_memory_pos($basic_tok, $position, $start){
    # for number_of_elements and position
    # start = 0 : number_of_elements
    # start  = 2 position m command
    # start  = 3 position n command
    $mul= [];
    $device = $_SESSION["device"];
    # real value of position
    $real_pos = hexdec($position);
    # find the max values of the dimension (row . col ...)
    if ($start == 0){
        $_SESSION["actual_data"][$device][$basic_tok."b0"] = $real_pos;
        return $real_pos;
    }
    else {
        $i = $start;
        $mulmaxmax = 1;
        while ($i < count($_SESSION["original_announce"][$device][basic_tok($basic_tok)])) {
            $mul[$i] = explode(",", $_SESSION["original_announce"][$device][basic_tok($basic_tok)][$i])[0];
            $mulmaxmax *= $mul[$i];
            $i += 1;
        }
    }
    $mulmax = 1;
    $j = 0;
    # z =…n_x *m_col*m_row + n_col* m_row + n_row
    #return $real_pos;
    while($j <  count($mul)){
        $i = $j+1;
        # with one element -> mulmax = 1!
        while ($i < count($mul)) {
            $mulmax *= $mul[$i];
            $i += 1;
        }
        # result > 0 always:
        $res = 0;
        if($mulmax < $real_pos){
            $res = $real_pos / $mulmax;
            # reminder for next loop
            $real_pos = $real_pos % $mulmax;
        }
        $_SESSION["actual_data"][$device][$basic_tok."b".$j] = $res;
        $j += 1;
    }
    return $real_pos;
}

function update_memory_data($token, $from_device, $typeindex, $lenindex){
    # translate received hex string depending on type
    if($from_device == ""){return["",0];}
    $basic_tok = basic_tok($token);
    $device = $_SESSION["device"];
    $bytes_to_delete = 0;
    $type = explode(";", $_SESSION["type_for_memories"][$device][$token])[$typeindex];
    $result = "";
    switch ($type){
        case (is_numeric($type)):
            $length_of_length = $_SESSION["property_len"][$device][$basic_tok][$lenindex];
            # charcters -> *2
            $stringlength = hexdec(substr($from_device,0,$length_of_length)) * 2;
            $bytes_to_delete = $stringlength * 2 + $length_of_length;
            $i = $length_of_length;
            while ($i <= $stringlength + $length_of_length){
                $result .= chr(hexdec(substr($from_device, 0, 2)));
                $from_device = substr($from_device, 2, null);
                $i += 2;
            }
            break;
        case "a":
        case "b":
            $result = hexdec(substr($from_device, 0, 2));
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

function one_numeric_element ($basic_tok, $from_device, $pos){
    #for pos or number_of_elements  (a / b commands)
    # $pos is position in property_len_byte (one byte supported)
    $device = $_SESSION["device"];
    $result = 0;
    if(count($_SESSION["original_announce"][$device][$basic_tok]) < 3){
        # one element only
        $result = hexdec(substr($from_device,0, 2));
    }
    else {
        $length_of_pos = $_SESSION["property_len"][$device][$basic_tok][$pos];
        if($length_of_pos == 1){
            $result = $rec[0];
        }
        else{
            $i = 0;
            while ($i < count($rec)){
                $result *= 256 + $rec[$i];
                $i += 1;
            }
        }
    }

    return $result;
}

function update_corresponding_opererating($basic_tok, $extension, $data){
    $device = $_SESSION["device"];
    if (array_key_exists($basic_tok, $_SESSION["a_to_o"][$device])) {
        $tok = $_SESSION["a_to_o"][$device][$basic_tok];
        $_SESSION["actual_data"][$device][$tok . $extension] = $data;
    }
}
return;
?>
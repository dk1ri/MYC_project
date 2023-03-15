<?php
# update_received.php
# DK1RI 20230315
function update_received(){
    $from_device = $_SESSION["received_data"];
    $i = 0;
    $rec = [];
    while ($i < strlen($from_device)) {
        $rec[] = hexdec(substr($from_device, $i, 2));
        $i += 2;
    }
    while (count($rec) > 0) {
        # more than one command in a line possible
        $rec = update_one_command($rec);
    }
    $_SESSION["received_data"] = "";
}

function update_one_command($rec){
    # $rec is array_spliced by every commandproperty found for a command
    $device = $_SESSION["device"];
    if ($_SESSION["command_len"][$device] == 2) {
        $basic_tok = $rec[0];
        array_splice($rec, 0, 1);
    }
    else{
        $basic_tok = $rec[0] * 256 + $rec[1];
        array_splice($rec, 0, 2);
    }
    if(!array_key_exists($basic_tok, $_SESSION["original_announce"][$device])){
        # error
        return [];
    }
    $announce = $_SESSION["original_announce"][$device][$basic_tok];
    $ct = explode(",",$announce[0])[0];
    switch ($ct) {
        case "m";
            $length = array_splice($rec, 0, 1);
            $line = array_splice($rec, 0, $length[0]);
            $i = 0;
            $field[0] = "";
            $j = 0;
            while ($i < count($line) and $j < 5){
                $character = chr($line[$i]);
                If ($character == ";") {
                    $j += 1;
                    $field[$j] = "";
                }
                else{
                    $field[$j] .= $character;
                }
                $i += 1;
            }
            $rec = [];
            if($i == 4){
                $_SESSION["actual_data"][$device][$basic_tok. "a0"] = $field[3] . "," . $field[4] . "," . $field[2];
            }
            break;
        case "as":
        case "at":
            $stacks = explode(",", $announce[1])[0];
            if ($stacks != 1) {
                read_to_stacks();
                $rec = array_splice($rec, 0, 1);
            }
            $data = array_splice($rec, 0, 1);
            $_SESSION["actual_data"][$device][$basic_tok. "x0"] = $data[0];
            if (array_key_exists($basic_tok,$_SESSION["as_token"][$device])){
                $org_token = $_SESSION["as_token"][$device][$basic_tok];
                $_SESSION["actual_data"][$device][$org_token. "x0"] = $data[0];
            }
           break;
        case "ar":
            $stacks = explode(",", $announce[1])[0];
            if ($stacks != 1) {
                read_to_stacks();
                $rec = array_splice($rec, 0, 1);
            }
            $position = array_splice($rec, 0, 1);
            $value = array_splice($rec, 0, 1);
            $_SESSION["actual_data"][$device][$basic_tok. "x".$position[0]] = $value[0];
            if (array_key_exists($basic_tok,$_SESSION["as_token"][$device])){
                $org_token = $_SESSION["as_token"][$device][$basic_tok];
                $_SESSION["actual_data"][$device][$org_token. "x".$position[0]] = $value[0];
            }
            break;
        case "ap":
            $stacks = explode(",", $announce[1])[0];
            if ($stacks == 1){
                $i = 1;
                while (array_key_exists($basic_tok."x".$i, $_SESSION["announce_all"][$device])) {
                    # for all demensions
                    $data_length = $_SESSION["property_len_byte"][$device][$basic_tok][($i + 1)];
                    $data = array_splice($rec, 0, $data_length);
                    $real_data = calculate_real($data);
                    $_SESSION["actual_data"][$device][$basic_tok . "x".$i] = $real_data;
                    if (array_key_exists($basic_tok, $_SESSION["as_token"][$device])) {
                        $org_token = $_SESSION["as_token"][$device][$basic_tok];
                        $_SESSION["actual_data"][$device][$org_token . "x".$i] = $real_data;
                    }
                    $i += 1;
                }
            }
            else{
                read_to_stacks();
            }
            break;
        case "am":
            $position_length = $_SESSION["property_len_byte"][$device][$basic_tok][1];
            $position = array_splice($rec,$position_length);
            $position = update_memory_pos($basic_tok, $position, 2);
            $data_length = $_SESSION["property_len_byte"][$device][$basic_tok][2];
            $data = array_splice($rec,$data_length);
            list($data, $delete_bytes) =update_memory_data($basic_tok, $rec, 0, 3);
            array_splice($rec,$delete_bytes);
            $_SESSION["actual_data"][$device][$basic_tok] = $data;
            break;
        case "an":
            $no_of_elements_length = $_SESSION["property_len_byte"][$device][$basic_tok][1];
            $no_of_elements = array_splice($rec, 0, $no_of_elements_length);
            $no_of_elements = update_memory_pos($basic_tok."b0", $no_of_elements, 0);
            $position_length = $_SESSION["property_len_byte"][$device][$basic_tok][2];
            $position = array_splice($rec, 0, $position_length);
            $position = update_memory_pos($basic_tok."b0", $position, 3);
            $_SESSION["actual_data"][$device][$basic_tok."x1"] = "";
            for ($i=0; $i <$no_of_elements; $i ++){
                if ($i != 0){$_SESSION["actual_data"][$device][$basic_tok."x1"].=",";}
                list($data, $delete_bytes) = update_memory_data($basic_tok."x1", $rec, 0, 3);
                array_splice($rec, 0,$delete_bytes);
                $_SESSION["actual_data"][$device][$basic_tok."x1"] .= $data;
            }
            break;
        case "aa":
            if(count($_SESSION["original_announce"][$device][$basic_tok]) < 3){
                # no position
                list($data, $delete_bytes) = update_memory_data($basic_tok . "x1" , $rec, 0, 1);
            }
            else {
                $element_number = one_numeric_element($basic_tok, $rec);
                # < 256 elemen allowed only -> length: 1
                array_splice($rec, 0, 1);
                list($data, $delete_bytes) = update_memory_data($basic_tok . "x" . ($element_number + 1), $rec, 0, $element_number);
            }
            $_SESSION["actual_data"][$device][$basic_tok."x".($element_number +1)] = $data;
            array_splice($rec, 0, $delete_bytes);
            break;
        case "ab":
            $element_number = one_numeric_element ($basic_tok, $rec);
            $start = one_numeric_element ($basic_tok, $rec);
            $i = $start;
            while ($i < $element_number){
                list($data, $delete_bytes) = update_memory_data($basic_tok . "x" . ($element_number + 1), $rec, $i + 2, $element_number);
                $_SESSION["actual_data"][$device][$basic_tok . "x" . ($element_number + 1)] = $data;
                array_splice($rec, 0, $delete_bytes);
            }
            break;
        default:
            $rec = [];
            break;
    }
    return $rec;
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
    $real_pos = calculate_real($position);
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

function update_memory_data($token, $rec, $typeindex, $lenindex){
    # translate received array of byte (decimal) depending on type
    print $token;
    var_dump($rec);
    if($rec==[]){return["",0];}
    $basic_tok = basic_tok($token);
    $device = $_SESSION["device"];
    $bytes_to_delete = 0;
    $type = explode(";", $_SESSION["des_type"][$device][$token])[$typeindex];
    print $type." t ";
    $result = "";
    switch ( $type){
        case (is_numeric($type)):
            $length_of_length = $_SESSION["property_len_byte"][$device][$basic_tok][$lenindex];
            $bytes_to_delete_a = array_splice($rec,0,$length_of_length);
            $i = 0;
            while ($i < count($bytes_to_delete_a)) {
                $bytes_to_delete = 256 * $bytes_to_delete;
                $bytes_to_delete += $bytes_to_delete_a[$i];
                $i += 1;
            }
            $i = 0;
            while ($i < count($rec)){
                $result .= chr($rec[$i]);
                $i += 1;
            }
            # due to length
            $bytes_to_delete ++;
            break;
        case "a":
        case "b":
            $result = $rec[0];
            $bytes_to_delete = 1;
            break;
        case "c":
            # 1 byte signed short
            $result = $rec[0] - 128;
            $bytes_to_delete = 1;
            break;
        case "w":
            $result = 256 * $rec[0] + $rec[1];
            $bytes_to_delete = 2;
            print " ".$result. " r ";
            break;
        case "e":
            # 4 byte signed long
            $result =  $rec[1] * 16777215 + $rec[2] * 65535 + $rec[3] * 256 + $rec[4];
            $result -= 2147483647;
            $bytes_to_delete = 4;
            break;
        case "L":
            # 4 byte unsigned long
            $result =  $rec[1] * 16777215 + $rec[2] * 65535 + $rec[3] * 256 + $rec[4];
            $bytes_to_delete = 4;
            break;
    }
    return [$result,$bytes_to_delete];
}

function calculate_real($byte_values){
    $real = 0;
    $i = 0;
    while ($i < count($byte_values)){
        $real *= 256;
        $real += $byte_values[$i];
        $i += 1;
    }
    return $real;
}

function one_numeric_element ($basic_tok, $rec){
    #for pos or number_of_elements  (a / b commands)
    $device = $_SESSION["device"];
    $length_of_pos = 1;
    $result = 0;
    if(count($_SESSION["original_announce"][$device][$basic_tok]) < 3){
        # one element only
        $result = $rec[0];
    }
    else {
        $length_of_pos = $_SESSION["property_len_byte"][$device][$basic_tok."b0"][0];
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
    array_splice($rec, 0, $length_of_pos);
    return $result;
}
?>
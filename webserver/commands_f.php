<?php
# commands_f.php
# DK1RI 20231211
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
#
function create_of($basic_tok){
    global $language, $device;
    echo "<div><h3 class='of'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    $m0 = $basic_tok."m0";
    $d0 = $basic_tok."d0";
    $number_of_elements = explode(",", $_SESSION["des"][$device][$basic_tok . "m0"])[0];
    if (array_key_exists($d0, $_SESSION["des_name"][$device]) and $_SESSION["des_name"][$device][$d0] != "") {
        echo $_SESSION["des_name"][$device][$d0];
    }
    else{
        echo " up to " . $number_of_elements . " space separated ";
    }
    $type = explode(",", $_SESSION["original_announce"][$device][$basic_tok][1])[0];
    echo " " . find_name_of_type($type) . ": ";
    # $_SESSION["actual_data"][$device] may contain spaces: space_to_nbsp()
    echo "<input type=text name=" . $basic_tok."d0" . " size = ". find_length_of_displayed_vars($type)."<br>";
    echo "<br>";
    stack_memory_selector($basic_tok. "m0");
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])) {
        echo "<marquee>". str_replace(" ","&nbsp;",$_SESSION["actual_data"][$device][$_SESSION["o_to_a"][$device][$basic_tok]."d0"]) . "</marquee>";
        # add selector for answer command
        echo " ";
        display_as($_SESSION["o_to_a"][$device][$basic_tok]);
    }
    echo "</h3></div>";
}

function create_af($basic_tok){
    global $language, $device;
    echo "<div><h3 class='af'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ":&nbsp;";
    echo "<marquee>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $value){
        if (strstr($value, "d")){
            echo str_replace(" ","&nbsp;",$_SESSION["actual_data"][$device][$value]). "&nbsp;";
        }
    }
    echo "</marquee><br>";
    stack_memory_selector($basic_tok. "m0");
    echo " elements ";
    display_as($basic_tok. "a");
    echo "</h3></div>";
}

function correct_for_send_of($basic_tok){
    global $device, $send_ok, $tok_to_send, $send_string_by_tok;
    check_send_if_a_exists($basic_tok);
    if ($send_ok) {$send_ok = $_POST[$basic_tok."d0"] != "";}
    if ($send_ok == 1) {
        # handle all token for a $basic_tok -> for creation of complete sendstring:
        $data = "";
        # there is one m0 and d0 token only
        $token = $basic_tok . "d0";
        $type = $_SESSION["type_for_memories"][$device][$token];
        $splitted = split_and_correct_multiple($token, $_POST[$token], $type);
        $part_of_string = 0;
        while ($part_of_string < count($splitted)) {
            if ($send_ok == 0) {
                $part_of_string++;
                continue;
            }
            if (is_numeric($type) or $type == "b") {
                # $splitted[$part_of_string], is string of chrs
                if ($type == "b" and strlen($splitted[$part_of_string]) > 1) {
                    $send_ok = 0;
                } elseif (strlen($splitted[$part_of_string]) > $type) {
                    # $type is length of string
                    $send_ok = 0;
                } else {
                    if (is_numeric($type)) {
                        # stringlenth not for "b"
                        $data .= dec_hex(strlen($splitted[$part_of_string]), $_SESSION["property_len"][$device][$basic_tok][1]);
                    }
                    $data .= bin2hex($splitted[$part_of_string]);
                }
            } else {
                # $splitted[$part_of_string], is number
                # check, if number is correct
                if ($send_ok == 1) {
                    $data .= translate_dec_to_hex($type, $splitted[$part_of_string], $_SESSION["property_len"][$device][$basic_tok][1]);
                }
            }
            $part_of_string++;
        }
    }
    if ($send_ok == 1) {
        # basic_tok
        $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
        # number of elements
        $send .= translate_dec_to_hex("m", count($splitted), $_SESSION["property_len"][$device][$basic_tok][0]);
        $send .= $data;
        $tok_to_send[$basic_tok] = 1;
        $send_string_by_tok[$basic_tok] = $send;
    }
}

function correct_for_send_af($basic_tok){
    global $language, $device, $send_ok, $tok_to_send, $send_string_by_tok;
    if (array_key_exists($basic_tok . "a", $_POST) and $_POST[$basic_tok . "a"] == 1) {
        if (array_key_exists($basic_tok . "m0", $_POST)) {
            # pure answer command
            $value = $_POST[$basic_tok . "m0"];
        } else {
            # with corresponding operating command
            $value = $_POST[$_SESSION["a_to_o"][$device][$basic_tok] . "m0"];
        }
        if (!is_numeric($value)) {
            # manual entry
            # " for numeric#
            # $send_ok may be set to 0
            $value = convert_bin_hex($value, "n");
            if ($send_ok == 1) {
                $value = (int)$value;
            }
        } else {
            $value = (int)$value;
        }
        if ($value > explode(",", $_SESSION["des"][$device][$basic_tok . "m0"])[0]) {
            $send_ok = 0;
        }
        if ($value == 0) {
            $send_ok = 0;
        }
        if ($send_ok == 1) {
            array_key_exists($basic_tok,$_SESSION["a_to_o"][$device]) ? $basic_tok_ = $_SESSION["a_to_o"][$device][$basic_tok]: $basic_tok_ = $basic_tok;
            update_actual_data_from_POST($basic_tok_);
            $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
            $send .= translate_dec_to_hex("m", $value, $_SESSION["property_len"][$device][$basic_tok][2]);
            $_SESSION["read"] = 1;
            $tok_to_send[$basic_tok] = 1;
            $send_string_by_tok = $send;
        }
    }
}

function  receive_f($basic_tok, $from_device){
    #  $from_device is without token!!
    global $language, $device;
    $number_length = $_SESSION["property_len"][$device][$basic_tok][2];
    # number of elements:
    $number = substr($from_device, 0, $number_length);
    $number = hexdec($number);
    $i = 0;
    $start = $number_length;
    $data = "";
    while ($i < $number) {
        if ($i != 0) {
            $data .= " ";
        }
        $from_device_ = substr($from_device,$start);
        list($data_, $delete_bytes) = update_memory_data($basic_tok . "d0", $from_device_,$_SESSION["property_len"][$device][$basic_tok][1]);
        $start += $delete_bytes;
        $data .= $data_." ";
        $i++;
    }
    $_SESSION["actual_data"][$device][$basic_tok."d0"] = $data;
    $_SESSION["actual_data"][$device][$basic_tok."m0"] = $number;
    # add length of $basictok
    return $start + $_SESSION["property_len"][$device][$basic_tok][0];
}
?>
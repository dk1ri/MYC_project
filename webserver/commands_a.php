<?php
# commands_a.php
# DK1RI 20230615
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function create_oa($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='oa'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ":<br>";
    $tok = $basic_tok. "m0";
    $range = explode(",", $_SESSION["des"][$device][$tok]);
    array_splice($range, 0, 1);
    if (count($range) > 2) {
        simple_selector($tok, $range, $_SESSION["actual_data"][$device][$tok]);
    }
    else {
        # one type of data
        echo $_SESSION["des_name"][$device][$basic_tok. "d0"];
    }
    echo " ";
    # data
    $position = $_SESSION["actual_data"][$device][$tok];
    $tok = $basic_tok. "d" . $position;
    echo "<input type=text name=" . $tok . " size = 20  placeholder =" . $_SESSION["actual_data"][$device][$tok] . "><br>";
    echo "<br>";
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])) {
        display_as($_SESSION["o_to_a"][$device][$basic_tok]);
    }
    echo "</h3></div>";
}

function create_aa($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='aa'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ":<br>";
    $tok = $basic_tok. "m0";
    $range = explode(",", $_SESSION["des"][$device][$tok]);
    array_splice($range, 0, 1);
    if (count($range) > 2) {
        simple_selector($tok, $range, $_SESSION["actual_data"][$device][$tok]);
    }
    else {
        # one type of data
        echo $_SESSION["des_name"][$device][$basic_tok. "d0"];
    }
    echo " ";
    # data
    $position = $_SESSION["actual_data"][$device][$tok];
    $tok = $basic_tok. "d" . $position;
    # data
    # actual_data[$basic_tok."m0"] hold the position
    $dat = translate_received_data_type($tok, $_SESSION["actual_data"][$device][$tok]);
    echo " " . $dat . "<br>";
    display_as($basic_tok."a");
    echo "</h3></div>";
}
function send_oa($basic_tok, $send){
    $device = $_SESSION["device"];
    $send_ok = 0;
    $pos = 0;
    $send_ok__= 0;
    $tok = $basic_tok. "a";
    if (array_key_exists($tok, $_SESSION["corrected_POST"][$device]) and $_SESSION["corrected_POST"][$device][$tok] == 1) {
        # if answer set-> ignore change of data
        $send_ok = 1;
        $_SESSION["read"] = 1;
    }
    else {
        # one element may have changed
        if (explode(",",$_SESSION["des"][$device][$basic_tok. "m0"])[0] > 1) {
            # if more than one element
            $send_ok_ = update($device, $basic_tok, 0);
            # position: mx exists
            $pos = calculate_pos_from_actual_to_hex($basic_tok);
            $send .= translate_dec_to_hex("n", $pos, 2);
        }
        $send_ok__ = update($device, $basic_tok, 0);
    }
    # data
    $send_ok_ = update($device, $basic_tok, 1);
    if ($send_ok_ or $send_ok__){
        $tok = $basic_tok."d". hexdec($pos);
        $data = translate_dec_to_hex($_SESSION["type_for_memories"][$device][$tok], $_SESSION["actual_data"][$device][$tok], 0);
        $send .= $data;
        $send_ok = 1;}
    return [$send, $send_ok];
}

function send_aa($basic_tok, $send){
    $send_ok = 0;
    $device = $_SESSION["device"];
    $send_ok_ = update($device, $basic_tok, 0);
    # position: mx exists
    if (count($_SESSION["original_announce"][$device][$basic_tok]) > 2) {
        $pos = calculate_pos_from_actual_to_hex($basic_tok);
        # < 255
        $send .= translate_dec_to_hex("n", $pos, 2);
    }
    $tok = $basic_tok . "a";
    if (array_key_exists($tok, $_SESSION["corrected_POST"][$device]) and $_SESSION["corrected_POST"][$device][$tok] == 1) {
        $send_ok_ = 1;
    }
    if ($send_ok_){
        # send read, if position is changed , as well
        $send_ok = 1;
        $_SESSION["read"] = 1;
    }
    return [$send, $send_ok];
}

function  receive_a($basic_tok, $from_device){
    $device = $_SESSION["device"];
    $element_number = 0;
    if(count($_SESSION["original_announce"][$device][$basic_tok]) < 3){
        # one element, no position
        list($data, $delete_bytes) = update_memory_data($basic_tok . "d0" , $from_device, 0, 1);
        update_corresponding_opererating($basic_tok, "d0", $data);
    }
    else {
        # max 256 elements only
        $element_number = hexdec(substr($from_device,0, 2));
        # < 256 elemen allowed only -> length: 1 byte
        $from_device = substr($from_device, 2, null);
        list($data, $delete_bytes) = update_memory_data($basic_tok . "d" . ($element_number), $from_device, 0, $element_number);
        # due to position
        $delete_bytes += 2;
        update_corresponding_opererating($basic_tok, "d" . ($element_number), $data);
    }
    $_SESSION["actual_data"][$device][$basic_tok."d".($element_number)] = $data;
    $_SESSION["actual_data"][$device][$basic_tok."m0"] = $element_number;
    return $delete_bytes;
}
?>
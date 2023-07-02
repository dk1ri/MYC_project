<?php
# commands_m.php
# DK1RI 20230621
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
#
function create_om($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='om'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ":<br>";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more stack display elements available
        selector($basic_tok);
    }
    echo "<br>";
    $token = $basic_tok. "d0";
    foreach($_SESSION["cor_token"][$device][$basic_tok] as $value) {
        if (strstr($value, "d0")) {
            # data
            stack_memory_selector($token);
        }
    }
    display_as($token, 0);
    echo "</h3></div>";
}

function create_am($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='am'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . "<br>";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more stack display elements available
        selector($basic_tok);
    }
    echo "<br>";
    $token = $basic_tok. "d0";
    if (array_key_exists($basic_tok. "d0", $_SESSION["actual_data"][$device])) {
        $dat = translate_received_data_type($token, $_SESSION["actual_data"][$device][$token]);
        echo $dat;
        echo " ";
    }
    display_as($token, 1);
    echo "</h3></div>";
}

function send_om($basic_tok, $send, $senda){
    $device = $_SESSION["device"];
    $send_ok = update($device, $basic_tok,0);
    # positions are updated
    $tok = $basic_tok. "a";
    if (array_key_exists($tok, $_SESSION["corrected_POST"][$device]) and $_SESSION["corrected_POST"][$device][$tok] == 1) {
        # if answer set-> ignore change of data
        $send = $senda;
        # position
        $send .= calculate_pos_from_actual_to_hex($basic_tok);
        $send_ok = 1;
        $_SESSION["read"] = 1;
    }
    else {
        $send_ok_ = update($device, $basic_tok, 1);
        if ($send_ok_) {$send_ok = 1;}
        if ($send_ok) {
            # data
            $send .= calculate_pos_from_actual_to_hex($basic_tok);
            $des_type = $_SESSION["type_for_memories"][$device][$basic_tok . "d0"];
            $send .= translate_dec_to_hex($des_type[0], $_SESSION["actual_data"][$device][$basic_tok . "d0"], 2);
        }
    }
    return [$send, $send_ok];
}

function send_am($basic_tok, $send, $senda){
    $device = $_SESSION["device"];
    $send_ok = update($device, $basic_tok, 0);
    if (array_key_exists($basic_tok . "a", $_POST)) {
        if ($_POST[$basic_tok . "a"] == "1") {
            # position, use data of om command
            $send .= calculate_pos_from_actual_to_hex($basic_tok);
            $send_ok = 1;
            $_SESSION["read"] = 1;
        }
    }
    return [$send, $send_ok];
}

function receive_m($basic_tok, $from_device){
    $device = $_SESSION["device"];
    # multiple dimensions not yet supported
    $position_length = $_SESSION["property_len_byte"][$device][$basic_tok][1];
    $position = hexdec(substr($from_device,0, $position_length));
    $data_length = $_SESSION["property_len_byte"][$device][$basic_tok][2];
    $from_device = substr($from_device,$position_length, null);
    $data = array_splice($from_device,0, $data_length);
    list($data, $delete_bytes) = update_memory_data($basic_tok."d0", $data, 0, 3);
    $_SESSION["actual_data"][$device][$basic_tok."d0"] = $data;
    update_corresponding_opererating($basic_tok, "x1", $data);
    # to delete
    return $delete_bytes + $position_length + $data_length;
}
?>
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
        echo find_name_of_type($_SESSION["type_for_memories"][$device][$basic_tok. "d0"]);
    }
    echo " ";
    # data
    $position = $_SESSION["actual_data"][$device][$tok];
    $tok = $basic_tok. "d" . $position;
    echo "<input type=text name=" . $tok . " size = 20  placeholder =" . $_SESSION["actual_data"][$device][$tok] . "><br>";
    echo "<br>";
    display_as($basic_tok."a", 0);
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
        echo find_name_of_type($_SESSION["type_for_memories"][$device][$basic_tok. "d0"]);
    }
    echo " ";
    # data
    $position = $_SESSION["actual_data"][$device][$tok];
    $tok = $basic_tok. "d" . $position;
    # data
    # actual_data[$basic_tok."m0"] hold the position
    $dat = translate_received_data_type($tok, $_SESSION["actual_data"][$device][$tok]);
    echo " " . $dat . "<br>";
    display_as($basic_tok."a", 1);
    echo "</h3></div>";
}
function send_oa($basic_tok, $send){
    $device = $_SESSION["device"];
    $send_ok = 0;
    $pos = 0;
    $send_ok_= 0;
    if (explode(",",$_SESSION["des"][$device][$basic_tok. "m0"])[0] > 1) {
        # not if one element only
        $send_ok_ = update($device, $basic_tok, 0);
        # position: mx exists
        $pos = calculate_pos_from_actual_to_hex($basic_tok);
        $send .= translate_dec_to_hex("n", $pos, 2);
    }
    $tok = $basic_tok. "a";
    if (array_key_exists($tok, $_SESSION["corrected_POST"][$device]) and $_SESSION["corrected_POST"][$device][$tok] == 1) {
        # if answer set-> ignore change of data
        $send_ok = 1;
        $_SESSION["read"] = 1;
    }
    else {
        # more than one element may have changed, each generate a send
        $c_token = $basic_tok. "d".$pos;
        # update data for ps only
        $send_ok__ = update_one_only($c_token);
        if ($send_ok__) {
            # data for position
            if (array_key_exists($c_token, $_SESSION["actual_data"][$device])){
                if (array_key_exists($c_token, $_SESSION["corrected_POST"][$device])) {
                    $type = $_SESSION["type_for_memories"][$device][$c_token];
                    $length = length_of_type($type);
                    $send .= translate_dec_to_hex($type, $_SESSION["corrected_POST"][$device][$c_token], $length);
                }
            }
            $send_ok = 1;
        }
        else{
            # read if pos is changed
            if ($send_ok_){
                $send_ok = 1;
                $_SESSION["read"] = 1;
            }
        }
    }
    return [$send, $send_ok];
}

function send_aa($basic_tok, $send){
    $send_ok = 0;
    $device = $_SESSION["device"];
    $send_ok_ = update($device, $basic_tok, 0);
    # position: mx exists
    $pos = calculate_pos_from_actual_to_hex($basic_tok);
    # < 255
    $send .= translate_dec_to_hex("n", $pos, 2);
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
?>
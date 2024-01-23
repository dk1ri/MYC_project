<?php
# commands_m.php
# DK1RI 20240123
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
    # data
    $tok = $basic_tok. "d0";
    if (array_key_exists($tok, $_SESSION["actual_data"][$device])){
        $type = $_SESSION["type_for_memories"][$device][$tok];
        echo find_name_of_type($type). " ";
        echo "<input type=text name=" . $tok . " size =". find_length_of_displayed_vars($type)."  placeholder =" . $_SESSION["actual_data"][$device][$tok] . "><br>";
    }
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])) {
        display_as($_SESSION["o_to_a"][$device][$basic_tok]);
    }
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
    if (array_key_exists($token, $_SESSION["actual_data"][$device])) {
        echo "<marquee>" . $_SESSION["actual_data"][$device][$token] . "</marquee><br>";
        echo " ";
    }
    display_as($token);
    echo "</h3></div>";
}

function correct_for_send_om($basic_tok){
    $device = $_SESSION["device"];
    check_send_if_a_exists($basic_tok);
    if ($_SESSION["send_ok"]) {$_SESSION["send_ok"] = check_send_if_change_of_actual_data($basic_tok);}
    if ($_SESSION["send_ok"] == 1) {
        $pos = calculate_memory_pos_from_POST($basic_tok);
        $type = $_SESSION["type_for_memories"][$device][$basic_tok . "d0"];
        $data = check_memory_data($basic_tok."d0", $device, $type,0);
        }
    if ($_SESSION["send_ok"]) {
        update_actual_data_from_POST($basic_tok);
        # basic_tok
        $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
        # $pos
        $send .= translate_dec_to_hex("m", $pos, $_SESSION["property_len"][$device][$basic_tok][2]);
        # data
        $send .= $data;
        $_SESSION["tok_to_send"][(int)$basic_tok] = 1;
        $_SESSION["send_string_by_tok"][$basic_tok] = $send;
    }
}

function correct_for_send_am($basic_tok){
    $device = $_SESSION["device"];
    if (array_key_exists($basic_tok . "a", $_POST) and $_POST[$basic_tok . "a"] == 1) {
        array_key_exists($basic_tok,$_SESSION["a_to_o"][$device]) ? $basic_tok_ = $_SESSION["a_to_o"][$device][$basic_tok]: $basic_tok_ = $basic_tok;
        update_actual_data_from_POST($basic_tok_);
        $pos = calculate_memory_pos_from_POST($basic_tok_);
        $_SESSION["read"] = 1;
        $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
        $send .= translate_dec_to_hex("m", $pos,$_SESSION["property_len"][$device][$basic_tok_][2]);
        $_SESSION["read"] = 1;
        $_SESSION["tok_to_send"][(int)$basic_tok] = 1;
        $_SESSION["send_string_by_tok"][$basic_tok]= $send;
    }
}

function receive_m($basic_tok, $from_device){
    #without $basic_tok
    $device = $_SESSION["device"];
    $position_length = $_SESSION["property_len"][$device][$basic_tok][2];
    update_memory_position($basic_tok,$from_device);
    $from_device = substr($from_device,$position_length, null);
    list($data, $delete_bytes) = update_memory_data($basic_tok."d0", $from_device, $_SESSION["property_len"][$device][$basic_tok][1]);
    update_corresponding_opererating($basic_tok, "d0", $data);
    # to delete
    return $delete_bytes + $position_length;
}
?>
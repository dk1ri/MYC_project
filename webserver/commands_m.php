<?php
# commands_m.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
#
function create_om($basic_tok) {
    global $language, $device, $actual_data;
    echo "<div><h3 class='om'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ":<br>";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more stack display elements available
        selector($basic_tok);
    }
    echo "<br>";
    # data
    $tok = $basic_tok. "d0";
    if (array_key_exists($tok, $actual_data)){
        $type = $_SESSION["type_for_memories"][$device][$tok];
        echo find_name_of_type($type). " ";
        $data = str_replace(" ","&nbsp;",$actual_data[$tok]);
        $length = find_length_of_displayed_vars($type);
        if (strlen($data) > $length){$length = strlen($data);}
        if ($length > 30){$length = 30;}
        echo "<input type=text name=" . $tok . " size =". $length."  placeholder = " . $data ,"><br>";
    }
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])) {
        display_as($_SESSION["o_to_a"][$device][$basic_tok]);
    }
    echo "</h3></div>";
}

function create_am($basic_tok){
    global $language, $device,$actual_data;
    echo "<div><h3 class='am'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . "<br>";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more stack display elements available
        selector($basic_tok);
    }
    echo "<br>";
    $token = $basic_tok. "d0";
    if (array_key_exists($token, $actual_data)) {
        echo "<marquee>" . $actual_data[$token] . "</marquee><br>";
        echo " ";
    }
    display_as($token);
    echo "</h3></div>";
}

function correct_for_send_om($basic_tok){
    global $language, $device;
    check_send_if_a_exists($basic_tok);
    if ($_SESSION["send_ok"]) {$_SESSION["send_ok"] = check_send_if_change_of_actual_data($basic_tok);}
    if ($_SESSION["send_ok"] == 1) {
        $pos = calculate_memory_pos_from_POST($basic_tok);
        $type = $_SESSION["type_for_memories"][$device][$basic_tok . "d0"];
        list($send_data, $display_data) = check_memory_data($basic_tok."d0", $type,0, $basic_tok."d0");
        }
    if ($_SESSION["send_ok"]) {
        update_actual_data_from_POST($basic_tok);
        # basic_tok
        $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
        # $pos
        $send .= translate_dec_to_hex("m", $pos, $_SESSION["property_len"][$device][$basic_tok][2]);
        # data
        $send .= $send_data;
        $_SESSION["tok_to_send"][$basic_tok] = 1;
        $_SESSION["send_string_by_tok"][$basic_tok] = $send;
    }
}

function correct_for_send_am($basic_tok){
    global $language, $device;
    if (array_key_exists($basic_tok . "a", $_POST) and $_POST[$basic_tok . "a"] == 1) {
        array_key_exists($basic_tok,$_SESSION["a_to_o"][$device]) ? $basic_tok_ = $_SESSION["a_to_o"][$device][$basic_tok]: $basic_tok_ = $basic_tok;
        update_actual_data_from_POST($basic_tok_);
        $pos = calculate_memory_pos_from_POST($basic_tok_);
        $_SESSION["read"] = 1;
        $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
        $send .= translate_dec_to_hex("m", $pos,$_SESSION["property_len"][$device][$basic_tok_][2]);
        $_SESSION["read"] = 1;
        $_SESSION["tok_to_send"][$basic_tok] = 1;
        $_SESSION["send_string_by_tok"][$basic_tok]= $send;
    }
}

function receive_m($basic_tok, $from_device){
    #without $basic_tok
    global $language, $device;
    $position_length = $_SESSION["property_len"][$device][$basic_tok][2];
    update_memory_position_stack($basic_tok,$from_device);
    $from_device = substr($from_device,$position_length, null);
    list($data, $delete_bytes) = update_memory_data($basic_tok."d0", $from_device, $_SESSION["property_len"][$device][$basic_tok][1]);
    update_corresponding_opererating($basic_tok, "d0", $data);
    # to delete
    return $delete_bytes + $position_length;
}
?>
<?php
# commands_n.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
#
function create_on($basic_tok) {
    global $language, $device;
    echo "<div><h3 class='on'>";
    echo tr($_SESSION["des_name"][$_SESSION["device"]][$basic_tok]);
    echo "<br>";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$_SESSION["device"]])) {
        echo $_SESSION["des_name"][$_SESSION["device"]][$basic_tok."mx"];
        # one or more display elements available
        selector($basic_tok);
    }
    $o_tok = $basic_tok . "o0";
    $range = explode(",", $_SESSION["des"][$_SESSION["device"]][$o_tok]);
    $number_of_elements = $range[0];
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$_SESSION["device"]])) {
        # display number_of_elements only if corresponding answer comannd exist
        echo $_SESSION["des_name"][$_SESSION["device"]][$basic_tok."o0"]." ";
        if (array_key_exists($o_tok, $_SESSION["des"][$_SESSION["device"]])) {
            array_splice($range, 0, 1);
            most_simple_selector_for_simple_des($o_tok, $range, $_SESSION["actual_data"][$_SESSION["device"]][$o_tok]);
            echo"<br>";
        }
    }
    else{
        echo "<br> max ".$number_of_elements." elements ";
    }
    $tok  = $basic_tok."d0";
    $type = $_SESSION["type_for_memories"][$_SESSION["device"]][$tok];
    echo find_name_of_type($type). " ";
    echo "<input type=text name=" . $tok . " size = 20 placeholder =" . str_replace(" ","&nbsp;",$_SESSION["actual_data"][$_SESSION["device"]][$tok]) . "><br>";
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$_SESSION["device"]])) {
        display_as($_SESSION["o_to_a"][$_SESSION["device"]][$basic_tok]);
    }
    echo "</h3></div>";
}

function create_an($basic_tok){
    echo "<div><h3 class='an'>";
    echo tr($_SESSION["des_name"][$_SESSION["device"]][$basic_tok]) . "<br>";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$_SESSION["device"]])) {
        # one or more memory display elements available
        echo $_SESSION["des_name"][$_SESSION["device"]][$basic_tok."mx"];
        stack_memory_selector($basic_tok."m0");
    }
    if (array_key_exists($basic_tok. "o0", $_SESSION["des"][$_SESSION["device"]])) {
        # one or more display elements available
        stack_memory_selector($basic_tok. "o0");
    }
    echo "<br>";
    array_key_exists($basic_tok,$_SESSION["a_to_o"][$_SESSION["device"]]) ? $basic_tok_ = $_SESSION["a_to_o"][$_SESSION["device"]][$basic_tok] : $basic_tok_ = $basic_tok;
    $token = $basic_tok_. "d0";
    if (array_key_exists($token, $_SESSION["actual_data"][$_SESSION["device"]])) {
        echo "<marquee>" . str_replace(" ","&nbsp;",$_SESSION["actual_data"][$_SESSION["device"]][$token]) . "</marquee><br>";
        echo " ";
    }
    display_as($basic_tok);
    echo "</h3></div>";
}

function correct_for_send_on($basic_tok){
    check_send_if_a_exists($basic_tok);
    if ($_SESSION["send_ok"]) {$send_ok = check_send_if_change_of_actual_data($basic_tok);}
    if ($send_ok == 1) {
        $pos = calculate_memory_pos_from_POST($basic_tok);
        # number of elements are calculated by using data
        # space separeted input
        $dataelements = explode(" ", $_POST[$basic_tok . "d0"]);
        $no_element = count($dataelements);
        $type = $_SESSION["type_for_memories"][$_SESSION["device"]][$basic_tok."d0"];
        $i = 0;
        $send_data = "";
        while($i < $no_element and $send_ok == 1) {
            list($send_data, $display_data) = check_memory_data($dataelements[$i], $type, 1, $basic_tok."d".$i);
            $i++;
        }
        if ($send_ok) {
            update_actual_data_from_POST($basic_tok);
            # basic_tok
            $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][0]);
            # $pos
            $send .= translate_dec_to_hex("m", $pos, $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][2]);
            # elements
            $send .= translate_dec_to_hex("m", $no_element, $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][3]);
            # data
            $send .= $send_data;
            $_SESSION["tok_to_send"][$basic_tok] = 1;
            $_SESSION["send_string_by_tok"][$basic_tok] = $send;
        }
    }
}

function correct_for_send_an($basic_tok){
    if (array_key_exists($basic_tok . "a", $_POST) and $_POST[$basic_tok . "a"] == 1) {
        update_actual_data_from_POST($basic_tok);
        array_key_exists($basic_tok, $_SESSION["a_to_o"][$_SESSION["device"]]) ? $basic_tok_ = $_SESSION["a_to_o"][$_SESSION["device"]][$basic_tok] : $basic_tok_ = $basic_tok;
        $pos = calculate_memory_pos_from_POST($basic_tok_);
        # basic_tok
        $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][0]);
        # position
        $send .= translate_dec_to_hex("m", $pos, $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][2]);
        # number_of_elements
        array_key_exists($basic_tok,$_SESSION["a_to_o"][$_SESSION["device"]]) ? $o_tok = $_SESSION["a_to_o"][$_SESSION["device"]][$basic_tok]."o0" : $o_tok = $basic_tok."o0";
        $send .= translate_dec_to_hex("m", $_POST[$o_tok], $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][3]);
        $_SESSION["read"] = 1;
        $_SESSION["tok_to_send"][$basic_tok] = 1;
        $_SESSION["send_string_by_tok"][$basic_tok] = $send;
    }
}

function receive_n($basic_tok, $from_device){
    update_memory_position_stack($basic_tok, $from_device);
    $position_length = $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][2];
    $from_device = substr($from_device,$position_length, null);
    $no_of_elements_length = $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][3];
    $no_of_elements = hexdec(substr($from_device, 0, $no_of_elements_length));
    $from_device = substr($from_device, $no_of_elements_length, null);
    $data = "";
    $all_to_delete = 0;
    for ($i=0; $i < $no_of_elements; $i ++){
        if ($i != 0){$data .="&nbsp;&nbsp;";}
        list($data_, $delete_bytes) = update_memory_data($basic_tok."d0", $from_device, $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][1]);
        $from_device = substr($from_device, $delete_bytes, null);
        $data .= $data_;
        $all_to_delete += $delete_bytes;
    }
    update_corresponding_operating($basic_tok,"d0", $data);
    update_corresponding_operating($basic_tok,"o0", $no_of_elements);
    $_SESSION["actual_data"][$_SESSION["device"]][$basic_tok."d0"] = $data;
    # to delete
    return $no_of_elements_length + $position_length + $all_to_delete;
}
?>
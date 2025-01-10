<?php
# commands_s.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function create_os($basic_tok) {
    echo "<div><h3 class='os'>";
    display_start_with_stack($basic_tok);
    $tok = $basic_tok."d0";
    echo "<select name=" . $tok . " id=" . $tok . ">";
    $field_x = explode(",", $_SESSION["des"][$_SESSION["device"]][$tok]);
    $i = 0;
    while ($i < count($field_x)) {
        $pos = $field_x[$i];
        $i += 1;
        $value = $field_x[$i];
        if ($value == ""){$value = "x";}
        echo "<option value=" . $pos;
        if ($pos == $_SESSION["actual_data"][$_SESSION["device"]][$tok]) {
            echo " selected";
        }
        echo ">" . tr($value) . "</option>";
        $i += 1;
    }
    echo "</select>";
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$_SESSION["device"]])) {
        display_as($_SESSION["o_to_a"][$_SESSION["device"]][$basic_tok]);
    }
    echo "</h3></div>";
}

function create_as($basic_tok){
    echo "<div><h3 class='as'>";
    display_start_with_stack($basic_tok);
    create_as_at($basic_tok);
    echo "</h3></div>";
}

function create_at($basic_tok){
    echo "<div><h3 class='at'>";
    display_start_with_stack($basic_tok);
    create_as_at($basic_tok);
    echo "</h3></div>";
}

function create_as_at($basic_tok){
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$_SESSION["device"]])) {
        # one or more stack display elements available
        selector($basic_tok);
    }
    $actual = $_SESSION["actual_data"][$_SESSION["device"]][$basic_tok."d0"];
    $label = explode(",",$_SESSION["des"][$_SESSION["device"]][$basic_tok."d0"])[2 * ($actual) + 1];
    echo  " ". $label. " read: ";
    echo "<input type='checkbox'id='".$basic_tok."a' name='".$basic_tok."a' value='1'>";;
}

function correct_for_send_os($basic_tok){
    check_send_if_a_exists($basic_tok);
    if ($_SESSION["send_ok"]) {$_SESSION["send_ok"] = check_send_if_change_of_actual_data($basic_tok);}
    if ($_SESSION["send_ok"]) {
        $d0 = $basic_tok."d0";
        $sw_pos_changed = 0;
        $max_switches = count(explode(",", $_SESSION["des"][$_SESSION["device"]][$d0])) / 2;
        if ($_POST[$d0] > $max_switches) {
            $_SESSION["send_ok"] = 0;
        }
        else{
            if ($_POST[$d0] != $_SESSION["actual_data"][$_SESSION["device"]][$d0]){
                $_SESSION["actual_data"][$_SESSION["device"]][$d0] = $_POST[$d0];
                $sw_pos_changed = 1;
            }
        }
    }
    if ($_SESSION["send_ok"]) {
        list($stack, $stack_changed) = handle_stacks($basic_tok);
        if ($stack_changed or $sw_pos_changed) {
            $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][0]);
            $send .= $stack;
            $send .= translate_dec_to_hex("n", $_POST[$basic_tok."d0"], $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][2]);
            $_SESSION["tok_to_send"][$basic_tok] = 1;
            $_SESSION["send_string_by_tok"][$basic_tok] = $send;
        }
    }
}

function correct_for_send_asat($basic_tok){
    $tok = $basic_tok . "a";
    if (array_key_exists($tok, $_POST) and  $_POST[$tok] == 1){
        list($stack, $stack_changed) = handle_stacks($basic_tok);
        $_SESSION["read"] = 1;
        $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][0]);
        $send .= $stack;
        $_SESSION["tok_to_send"][$basic_tok] = 1;
        $_SESSION["send_string_by_tok"][$basic_tok]= $send;
    }
}

function receive_st($basic_tok, $from_device){
    $stacklen = $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][1];
    $switchlen = $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][2];
    if ($stacklen > 0) {
        update_memory_position_stack($basic_tok, $from_device);
        $from_device = substr($from_device,$stacklen);
    }
    if ($switchlen == 0){$switchlen = 2;}
    $data = substr($from_device, 0, $switchlen);
    $_SESSION["actual_data"][$_SESSION["device"]][$basic_tok. "d0"] = hexdec($data);
    update_corresponding_operating($basic_tok, "d0", hexdec($data));
    return $stacklen + $switchlen;
}
?>
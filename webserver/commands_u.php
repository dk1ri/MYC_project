<?php
# commands_u.php
# DK1RI 20240422
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function create_ou($basic_tok) {
    global $language, $device;
    echo "<div><h3 class='ou'>";
    display_start_with_stack($basic_tok);
    $des = explode(",", $_SESSION["des"][$device][$basic_tok."d0"]);
    if (count($des) == 2) {
        echo "<input type='checkbox' id=" . $basic_tok."d0" . " name=" . $basic_tok."d0 value=1>";
    }
    else {
        echo "<select name=",$basic_tok."d0"," id=",$basic_tok."d0",">";
        $i = 0;
        while ($i < count($des)) {
            echo "<option value=".$des[$i];
            $i += 1;
            echo ">".$des[$i], "</option>";
            $i += 1;
        }
        echo "</select>";
    }
    echo "</h3></div>";
}

function correct_for_send_ou($basic_tok){
    global $device, $send_ok, $tok_to_send, $send_string_by_tok;
    $sw_pos_changed = 0;
    if ($send_ok) {$send_ok = check_send_if_change_of_actual_data($basic_tok);}
    if ($send_ok) {
        # $actual_data is 0 always
        # send, if corrected_POST is not idle (no send with change of stack only)
        if ($_POST[$basic_tok."d0"] != 0) {$sw_pos_changed = 1;}
    }
if ($send_ok) {
        list($stack, $stack_changed) = handle_stacks($basic_tok);
        if ($stack_changed or $sw_pos_changed) {
            $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
            $send .= $stack;
            if (count(explode(",", $_SESSION["des"][$device][$basic_tok."d0"])) > 4) {
                $send .= translate_dec_to_hex("n", $_POST[$basic_tok . "d0"], $_SESSION["property_len"][$device][$basic_tok][2]);
            }
            $tok_to_send[$basic_tok] = 1;
            $send_string_by_tok[$basic_tok] = $send;
        }
    }
}
?>
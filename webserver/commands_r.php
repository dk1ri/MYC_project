<?php
# commands_s.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function create_or($basic_tok){
    global $device;
    # selecting a switch as operate will toggle the status
    echo "<div><h3 class='or'>";
    display_start_with_stack($basic_tok);
    create_or_ar($basic_tok);
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])) {
        display_as($_SESSION["o_to_a"][$device][$basic_tok]);
    }
    echo "</h3></div>";
}
function create_ar($basic_tok){
    global $language, $device;
    # selecting a switch as operate will toggle the status
    echo "<div><h3 class='ar'>";
    display_start_with_stack($basic_tok);
    create_or_ar($basic_tok);
    echo " read: ";
    echo "<input type='checkbox' id=".$basic_tok."a" . " name=".$basic_tok."a value=1>";
    echo "</h3></div>";
}

function create_or_ar($basic_tok){
    # selecting a switch as operate will toggle the status
    global $device;
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])){
        # one or more stack display elements available
        selector($basic_tok);
    }
    echo "<br>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "d")) {
            $actual = $_SESSION["actual_data"][$device][$tok];
            if($actual == "0"){
                echo "<strong class = 'red'>";
            }
            else{
                echo "<strong class = 'green'>";
            }
            echo explode(",", $_SESSION["des"][$device][$tok])[1];
            echo "<input type='checkbox' name=" . $tok . " id=" . $tok . " label=" . $tok . "> ";
        }
        echo "</strong>";
    }
}

function correct_for_send_or($basic_tok){
    global $device, $send_ok, $tok_to_send, $send_string_by_tok;
    check_send_if_a_exists($basic_tok);
    $sw_changed = 0;
    $positions_to_change = [];
    $add = [];
    if ($send_ok) {
        $i = 0;
        foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
            if (strstr($tok, "d")) {
                if (array_key_exists($tok, $_POST)) {
                    # data for one changed switch can be sent!
                    # $_POST delivers "" or "on" for all checkbox token (on ,means toggeling!
                    if ($_POST[$tok] == "on") {
                        $positions_to_change[] = $tok;
                        if (count($_SESSION["original_announce"][$device][$basic_tok]) > 3) {
                            # only, if more than 1 element possible
                            $add[$tok] = dec_hex($i, 2);
                        }
                        # send only with change
                        # toggle for operating
                        if ($_SESSION["actual_data"][$device][$tok] == "0") {
                            $add[$tok] .= "01";
                            $_SESSION["actual_data"][$device][$tok] = "1";
                        } else {
                            $add[$tok] .= "00";
                            $_SESSION["actual_data"][$device][$tok] = "0";
                        }
                    }
                }
                $i++;
            }
        }
    }
    if ($send_ok) {
        $send = "";
        if (!array_key_exists($basic_tok,$_SESSION["ALL"][$device])) {
            foreach ($positions_to_change as $tok) {
                list($stack, $stack_changed) = handle_stacks($basic_tok);
                $send .= translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
                $send .= $stack;
                $send .= $add[$tok];
            }
        }
        else {
            $i = 0;
            foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
                if (strstr($tok, "d")) {
                    list($stack, $stack_changed) = handle_stacks($basic_tok);
                    $send .= translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
                    $send .= $stack;
                    $send .= translate_dec_to_hex("n", $i,2);
                    $send .= translate_dec_to_hex("n", $_SESSION["actual_data"][$device][$tok], 2);
                    $i++;
                }
            }
        }
        $tok_to_send[$basic_tok] = 1;
        $send_string_by_tok[$basic_tok] = $send;
    }
}

function correct_for_send_ar($basic_tok){
    global $device, $tok_to_send, $send_string_by_tok;
    $tok = $basic_tok . "a";
    if (array_key_exists($tok, $_POST) and  $_POST[$tok] == 1) {
        $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
        list($stack, $stack_changed) = handle_stacks($basic_tok);
        $_SESSION["read"] = 1;
        $send .= $stack;
        $sw_changed = 0;
        if (!array_key_exists($basic_tok,$_SESSION["ALL"][$device])) {
            $i = 0;
            $add = "";
            array_key_exists($basic_tok, $_SESSION["a_to_o"][$device]) ? $basic_tok_ = $_SESSION["a_to_o"][$device][$basic_tok] : $basic_tok_ = $basic_tok;
            foreach ($_SESSION["cor_token"][$device][$basic_tok_] as $tok) {
                if (!$sw_changed and strstr($tok, "d")) {
                    # data for one changed switch can be sent!
                    # $_POST delivers 0 or "on" for all checkbox token (on ,means toggeling!
                    if (array_key_exists($tok, $_POST) and $_POST[$tok] == "on") {
                        if (count($_SESSION["original_announce"][$device][$basic_tok]) > 3) {
                            # only, if more than 1 element possible
                            $add .= dec_hex($i, 2);
                        }
                        $sw_changed = 1;
                    }
                    $i++;
                }
            }
            if ($sw_changed) {
                # one switch must be selected
                list($stack, $stack_changed) = handle_stacks($basic_tok);
                $_SESSION["read"] = 1;
                $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
                $send .= $stack;
                $send .= $add;
            }
        }
        else{$sw_changed = 1;}
        if ($sw_changed) {
            $tok_to_send[$basic_tok] = 1;
            $send_string_by_tok[$basic_tok] = $send;
        }
    }
}

function receive_r($basic_tok, $from_device){
    global $username, $language, $is_lang, $new_sequncelist, $device;
    $stacklen = $_SESSION["property_len"][$device][$basic_tok][1];
    $switchlen = $_SESSION["property_len"][$device][$basic_tok][2];
    $position = 0;
    if ($stacklen > 0) {
        # 256 switch positions supported
        update_memory_position_stack($basic_tok, $from_device);
        $from_device = substr($from_device,$stacklen);
    }
    if (array_key_exists($basic_tok."d1", $_SESSION["announce_all"][$device])){
        # more than one element -> $position
        $position = hexdec(substr($from_device, 0, $switchlen));
        $from_device = substr($from_device,$switchlen);
    }
    $value = hexdec(substr($from_device, 0, 2));
    $_SESSION["actual_data"][$device][$basic_tok. "d".$position] = $value;
    update_corresponding_opererating($basic_tok, "d".$position, $value);
    return $stacklen + $switchlen + 2;
}
?>
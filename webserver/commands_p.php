<?php
# commands_o.php
# DK1RI 20240304
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function  create_op_oo($basic_tok){
    echo "<div><h3 class='op'>";
    display_start_with_stack($basic_tok);
    echo "<br>";
    $reset_or_ignore = 0;
    foreach ($_SESSION["cor_token"][$_SESSION["device"]][$basic_tok] as $tok) {
        if (strstr($tok, "d")) {
            # no "a"
            $des = explode(",", $_SESSION["des"][$_SESSION["device"]][$tok]);
            if ($_SESSION["announce_all"][$_SESSION["device"]][$tok] == "oo") {
                if (strstr($tok, "r") and $des[0] == 0) {
                    # special case: command is reset or ...
                    echo "<br>";
                    $reset_or_ignore = 1;
                    $tok_ = substr($tok, 0, strlen($tok) - 1);
                    if ($_SESSION["des"][$_SESSION["device"]][$tok_ . "s"] != "0" or $_SESSION["des"][$_SESSION["device"]][$tok_ . "t"] != "0") {
                        # reset to default
                        $label = tr($_SESSION["des_name"][$_SESSION["device"]][basic_tok($tok)]);
                        echo tr("set_default") . ": " . $label . " ";
                        echo "<input type='checkbox' id=" . $tok . " name=" . $tok . " value=set_def>";
                    }
                    # else ignore this dimension
                }
            }
            else{
                $reset_or_ignore = 0;
            }
            if (!$reset_or_ignore){
                # "op" or other "oo"
                $number_of_elements = $des[0];
                $des = array_splice($des, 1);
                if (strstr($tok, "r")) {
                    echo "<br>";
                }
                if (array_key_exists($tok, $_SESSION["des_name"][$_SESSION["device"]])){
                    echo tr($_SESSION["des_name"][$_SESSION["device"]][$tok]);
                    if($_SESSION["des_name"][$_SESSION["device"]][$tok] != " " and $_SESSION["des_name"][$_SESSION["device"]][$tok] != "") {
                        echo ":";
                    }
                }
                if ($number_of_elements < $_SESSION["conf"]["selector_limit"]) {
                    $actual = $_SESSION["actual_data"][$_SESSION["device"]][$tok];
                    most_simple_selector_for_simple_des($tok, $des, $actual);
                    if (strstr($tok, "t")) {
                        echo $_SESSION["unit"][$_SESSION["device"]][$tok] . " ";
                    }
                }
                else {
                    # > $_SESSION["conf"]["selector_limit"]
                    $data = retranslate_op_oo($tok);
                    echo "<input type='text' name = " . $tok . " size = 14 placeholder =" . $data . ">";
                }
                if (!strstr($tok, "r") and !strstr($tok, "s") and !strstr($tok, "t")) {
                    echo $_SESSION["unit"][$_SESSION["device"]][$tok] . "<br>";
                }
            }
        }
    }
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$_SESSION["device"]])) {
        display_as($_SESSION["o_to_a"][$_SESSION["device"]][$basic_tok]);
    }
    echo "</h3></div>";
}

function create_ap($basic_tok){
    echo "<div><h3 class='ap'>";
    display_start_with_stack($basic_tok);
    echo tr("read").": <input type='checkbox' id=".$basic_tok."a" . " name=".$basic_tok."a value=1>";
    foreach ($_SESSION["cor_token"][$_SESSION["device"]][$basic_tok] as $tok) {
        if (strstr($tok, "d")) {
            #data
            if (array_key_exists($tok,$_SESSION["des_name"][$_SESSION["device"]])){echo $_SESSION["des_name"][$_SESSION["device"]][$tok] . ": ";}
            # retranslate always, because no selectors are used
            echo retranslate_op_oo($tok);
            echo " ".$_SESSION["unit"][$_SESSION["device"]][$tok]."<br>";
        }
    }
    echo "</h3></div>";
}

function correct_for_send_op($basic_tok){
    check_send_if_a_exists($basic_tok);
    if ($_SESSION["send_ok"]) {$_SESSION["send_ok"] = check_send_if_change_of_actual_data($basic_tok);}
    $change_found = 0;
    $translated = "";
    $send = "";
    if ($_SESSION["send_ok"]) {
        # create $data for transmit and update actual data if no error
        list($change_found, $translated) = collect_op($basic_tok);
        if ($change_found == 0){
            # if no op change only !
            # find "oo" basic_tok
            $already_done = [];
            foreach ($_SESSION["cor_token"][$_SESSION["device"]][$basic_tok] as $values) {
                if (!strstr($values,"a")) {
                    $basic_tok_ = basic_tok($values);
                    if ($basic_tok_ == $basic_tok) {
                        continue;
                    }
                    if (array_key_exists($basic_tok_, $already_done)) {
                        continue;
                    }
                    list($change_found, $translated) = collect_op($basic_tok_);
                    $already_done[$basic_tok_] = 1;
                }
            }
        }
    }
    if ($_SESSION["send_ok"]) {
        list($stack, $stack_changed) = handle_stacks($basic_tok);
        if (!array_key_exists($basic_tok,$_SESSION["ALL"][$_SESSION["device"]])) {
            if ($stack_changed or $change_found) {
                $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][0]);
                $send .= $stack;
                $send .= $translated;
            }
        }
        else{
            # ALL
            $i = 0;
            foreach ($_SESSION["cor_token"][$_SESSION["device"]][$basic_tok] as $tok){
                if (strstr($tok,"d")) {
                    $send .= translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][0]);
                    $send .= $stack;
                    $send .= translate_dec_to_hex("n", $i, 2);
                    $send .= translate_dec_to_hex("m", $_SESSION["actual_data"][$_SESSION["device"]][$tok], $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][$i + 2]);
                    $i++;
                }
            }
        }
        $_SESSION["tok_to_send"][$basic_tok] = 1;
        $_SESSION["send_string_by_tok"][$basic_tok] = $send;
    }
}

function correct_for_send_ap($basic_tok){
    $tok = $basic_tok . "a";
    if (array_key_exists($tok, $_POST) and  $_POST[$tok] == 1){
        $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][0]);
        list($stack, $stack_changed) = handle_stacks($basic_tok);
        $_SESSION["read"] = 1;
        $send .= $stack;
        if (!array_key_exists($basic_tok,$_SESSION["ALL"][$_SESSION["device"]])) {
            if (array_key_exists($basic_tok."o0", $_SESSION["actual_data"][$_SESSION["device"]])) {
                $send .= translate_dec_to_hex("m", $_SESSION["actual_data"][$_SESSION["device"]][$basic_tok . "o0"], $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][0]);
            }
        }
        # else send no position
        $_SESSION["tok_to_send"][$basic_tok] = 1;
        $_SESSION["send_string_by_tok"][$basic_tok] = $send;
    }
}

function receive_p($basic_tok, $from_device){
    $stacklen = $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][1];
    if ($stacklen > 0) {
        update_memory_position_stack($basic_tok, $from_device);
        $from_device = substr($from_device,$stacklen);
    }
    $to_delete = 0;
    $i = 0;
    $pointer = 0;
    # it is assumed, that the device delivers the correct number of data
    while (array_key_exists($basic_tok."d".$i, $_SESSION["announce_all"][$_SESSION["device"]])) {
        # for all dimensions
        # data_len is the number of chars to delete
        $data_len = $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][$i + 2];
        $data = substr($from_device, $pointer,$data_len);
        $data = hexdec(($data));
        $to_delete += $data_len;
        # directly stored
        $_SESSION["actual_data"][$_SESSION["device"]][$basic_tok . "d".$i] = $data;
        update_corresponding_opererating($basic_tok, "d".$i, $data);
        $i += 1;
        $pointer += $data_len;
    }
    return $stacklen + $to_delete;
}

function retranslate_op_oo($tok){
    # translate $_SESSION["actual_data"][$_SESSION["device"]] of op /oo to display data using <des>
    # return integer to display
    $data = $_SESSION["actual_data"][$_SESSION["device"]][$tok];
    $result = $data;
    if (array_key_exists($tok, $_SESSION["des"][$_SESSION["device"]])){
        $range = explode(",", $_SESSION["des"][$_SESSION["device"]][$tok]);
        if (count($range) > 1) {
            $range = array_splice($range, 1);
            $i = 0;
            $found = 0;
            $result = 0;
            $sum_counts = 0;
            while ($i < count($range) and $found == 0) {
                if (!strstr($range[$i], "_")) {
                    # single number
                    if ($data == $sum_counts) {
                        $found = 1;
                        $result = $range[$i];
                    }
                    $sum_counts++;
                } else {
                    # range
                    # min, max.. may be float
                    $step_size = (float)explode("_", $range[$i])[0];
                    $max = (float)explode("to", $range[$i])[1];
                    $min = (float)explode("to", explode("_", $range[$i])[1])[0];
                    $counts = ($max - $min) / $step_size;
                    if ($sum_counts + $counts < $data) {
                        $sum_counts += $counts;
                    } else {
                        $result = ($data - $sum_counts) * $step_size + $min;
                        $found = 1;
                    }
                }
                $i ++;
            }
            # $data may be higher than $count, so $found = 0
            # if $sum_counts > 0 $sum_count is returned
            if (!$found and $sum_counts > 0) {
                $result = intval($sum_counts);
            }
        }
    }
    # result is int or string
    return $result;
}

function collect_op($basic_tok){
    # used for "op" command for transmit to device
    # translate $_POST from $_SESSION["actual_data"][$_SESSION["device"]] to MYC data for "big values"
    # collect data for all dimensions
    # return "" if error or hex string ready for transmit if there was a change by $_POST and no error
    $result = "";
    $i = 0;
    $found = 0;
    # check for change
    while (array_key_exists($basic_tok."d".$i, $_SESSION["des"][$_SESSION["device"]])) {
        $tok = $basic_tok . "d" . $i;
        if ($_SESSION["des"][$_SESSION["device"]][$tok] > $_SESSION["conf"]["selector_limit"]){
            if (array_key_exists($tok, $_POST) and $_POST[$tok] != "" and $_POST[$tok] != $_SESSION["actual_data"][$_SESSION["device"]][$tok]) {
                $found = 1;
            }
        }
        else{$found = 1;}
        $i++;
    }
    # for "big values" $_POSt has the real data -> check (translate to MYC values)
    if ($found){
        $i = 0;
        $ok = 1;
        while (array_key_exists($basic_tok."d".$i, $_SESSION["des"][$_SESSION["device"]]) and $ok) {
            $tok = $basic_tok . "d" . $i;
            if (array_key_exists($tok, $_POST) and $_POST[$tok] != "" and $_POST[$tok] != $_SESSION["actual_data"][$_SESSION["device"]][$tok]) {
                # for big values $_POST[$tok] may have string values -> check and translate to positions
                $des = explode(",", $_SESSION["des"][$_SESSION["device"]][$tok]);
                if ($des[0] > $_SESSION["conf"]["selector_limit"]) {
                    if (count($des) > 1) {
                        $range = explode(",", $des[1]);
                        # translate
                        list($ok, $_POST[$tok]) = check_translate_range($range, $_POST[$tok], 1);
                    }
                }
            }
            $i++;
        }
        if (!$ok){$found = 0;}
    }
    if($found){
        # modify
        $i = 0;
        while (array_key_exists($basic_tok."d".$i, $_SESSION["des"][$_SESSION["device"]])) {
            # for each dimension
            $tok = $basic_tok . "d" . $i;
            if (array_key_exists($tok, $_POST) and $_POST[$tok] != "" and $_POST[$tok] != $_SESSION["actual_data"][$_SESSION["device"]][$tok]) {
                $_SESSION["actual_data"][$_SESSION["device"]][$tok] = $_POST[$tok];
            }
            $result .= translate_dec_to_hex("m", $_SESSION["actual_data"][$_SESSION["device"]][$tok], $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][2 + $i]);
            $i++;
        }
    }
    return [$found, $result];
}
?>
<?php
# send_and_update.php
# DK1RI 20240201
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

# The following are subs used by command send
function calculate_memory_pos_from_POST($basic_tok){
    $error = 0;
    # ADD token ?
    if (array_key_exists($basic_tok. "n0", $_POST)){
        $Add_data = $_POST[$basic_tok."n0"];
        if (!is_numeric($Add_data)){$error = 1;}
        }
    elseif(array_key_exists($basic_tok. "n0",$_SESSION["actual_data"][$_SESSION["device"]])){
        $Add_data = $_SESSION["actual_data"][$_SESSION["device"]][$basic_tok."n0"];
    }
    else {$Add_data = 0;}
    # with ADDer
    $tok = $basic_tok . "m0";
    if ($Add_data != 0 and $error == 0){
        $pos = $_SESSION["max_for_ADD"][$_SESSION["device"]][$basic_tok."n0"];
    }
    else {
        # no ADDer
        $i = 0;
        $found = 0;
        $pos = 0;
        $value = 0;
        while (!$found) {
            $tok = $basic_tok . "m" . $i;
            if (!array_key_exists($tok, $_SESSION["des"][$_SESSION["device"]])) {
                $found = 1;
            }
            else {
                if (array_key_exists($tok, $_POST)){
                    if (is_numeric($_POST[$tok])){
                        $value = $_POST[$tok];
                    }
                    else{
                        $error = 1;
                    }
                }
                $pos += $value;
                if (array_key_exists($basic_tok."m".($i+1), $_SESSION["des"][$_SESSION["device"]])){
                   $pos *= (int)explode(",",$_SESSION["des"][$_SESSION["device"]][$basic_tok."m".($i+1)])[0];
                }
            }
            $i++;
        }
    }
    if ($error == 0){
        $pos = $pos + $Add_data;
    }
    else{
        $pos = $_SESSION["actual_data"][$_SESSION["device"]][$tok];
    }
    return $pos + $Add_data;
}

function check_send_if_change_of_actual_data($basic_tok){
    $change_found = 0;
    foreach ($_SESSION["cor_token"][$_SESSION["device"]][$basic_tok] as $tok){
        if (!$change_found) {
            if (array_key_exists($tok, $_POST) and array_key_exists($tok, $_SESSION["actual_data"][$_SESSION["device"]])and $_POST[$tok]!= "") {
                if ($_POST[$tok] != $_SESSION["actual_data"][$_SESSION["device"]][$tok]) {
                    $change_found = 1;
                }
            }
        }
    }
    return $change_found;
}

function update_actual_data_from_POST($basic_tok){
    $i = 0;
    $found = 1;
    while ($found == 1){
        $tok = $basic_tok."m".$i;
        $found = u_a_d_f_($tok);
        $i++;
    }
    $i = 0;
    $found = 1;
    while ($found == 1){
        $tok = $basic_tok."d".$i;
        $found = u_a_d_f_($tok);
        $i++;
    }
    $found = u_a_d_f_($basic_tok."n0");
    $found = u_a_d_f_($basic_tok."o0");
}

function u_a_d_f_($tok){
    $found = 1;
    if (array_key_exists($tok, $_SESSION["actual_data"][$_SESSION["device"]])) {
        if (array_key_exists($tok, $_POST)){$_SESSION["actual_data"][$_SESSION["device"]][$tok] = $_POST[$tok];}
    }
    else{$found = 0;}
    return  $found;
}

function handle_stacks($basic_tok){
    # create stack (for send) if necessary
    # return: $stack
    $stack = "";
    # do nothing, if stacks == 1
    if (explode(",", $_SESSION["original_announce"][$_SESSION["device"]][$basic_tok][1])[0] == 1){
        return $stack;
    }
    if (array_key_exists($basic_tok, $_SESSION["a_to_o"][$_SESSION["device"]])) {
        # use all (identical) data of corresponding o token
        $basic_tok = $_SESSION["a_to_o"][$_SESSION["device"]][$basic_tok];
    }
    # update $_SESSION["actual_data"][$_SESSION["device"]]
    # the key of the number_of_selects array is 0, 1, ... (as tokenbx)
    $i = 0;
    $found = 1;
    $stack_changed = 0;
    while ($found){
        # all m token only
        $c_token = $basic_tok."m".$i;
        if (array_key_exists($c_token, $_POST)) {
            if ($_POST[$c_token] != $_SESSION["actual_data"][$_SESSION["device"]][$c_token]) {
                $stack_changed = 1;
                $_SESSION["actual_data"][$_SESSION["device"]][$c_token] = $_POST[$c_token];
            }
        }
        else{$found = 0;}
        $i++;
    }
    $i = 0;
    $found = 1;
    while ($found){
        # all n token only
        $c_token = $basic_tok."n".$i;
        if (array_key_exists($c_token, $_POST)) {
            if ($_POST[$c_token] != $_SESSION["actual_data"][$_SESSION["device"]][$c_token]) {
                $stack_changed = 1;
                $_SESSION["actual_data"][$_SESSION["device"]][$c_token] = $_POST[$c_token];
            }
        }
        else{$found = 0;}
        $i++;
    }
    # create stack for transmit rom $_SESSION["actual_data"][$_SESSION["device"]] data:
    # ADD token ?
    if (array_key_exists($basic_tok. "n0", $_POST)){
        $Add_data = $_POST[$basic_tok."n0"];
    }
    elseif(array_key_exists($basic_tok. "n0",$_SESSION["actual_data"][$_SESSION["device"]])){
        $Add_data = $_SESSION["actual_data"][$_SESSION["device"]][$basic_tok."n0"];
    }
    else {$Add_data = 0;}
    # with ADDer
    if ($Add_data != 0){
        $stack = $_SESSION["max_for_ADD"][$_SESSION["device"]][$basic_tok."n0"] + $Add_data;
    }
    else {
        # no ADDer
        $stack = 0;
        $i = 0;
        print $basic_tok;
        while (!$found) {
            $tok = $basic_tok . "m" . $i;
            print $tok." ";
            if (!array_key_exists($tok, $_SESSION["des"][$_SESSION["device"]])) {
                print "found ";
                $found = 1;
            }
            else {
                print $tok." ";
                if(array_key_exists($tok, $_POST)) {
                    $value = $_POST[$tok];
                    print "POST";
                }
                else{
                    $value = $_SESSION["actual_data"][$_SESSION["device"]][$tok];
                }
                var_dump($value);
                $stack += $value;
                if (array_key_exists($basic_tok . "m" . ($i + 1), $_SESSION["des"][$_SESSION["device"]])) {
                    $stack *= (int)explode(",", $_SESSION["des"][$_SESSION["device"]][$basic_tok . "m" . ($i + 1)])[0];
                }
            }
            print " e ";
            $i++;
        }
    }
    $stack_len = $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][1];
    $stack = dec_hex($stack,$stack_len);
    return [$stack, $stack_changed];
}

function check_memory_data($tok, $type, $mode,$tok_for_des){
    # for a b m n commands
    # mode == 0: use $_POST[$tok] to check
    # mode == 1: $tok is part of $_POST[$tok]
    if(!$mode) {
        $corrected = $_POST[$tok];
    }
    else {
        # for n command
        $corrected = $tok;
    }
    $corrected = check_data_of_manual_entries($tok_for_des,$corrected);
    $send_data = "";
    $display_data = "";
    if ($_SESSION["send_ok"]){
        $dat = convert_bin_hex($corrected, $type);
        $basic_tok = basic_tok($tok);
        switch ($type) {
            case "b":
                if (strlen($dat) > 1) {
                    $_SESSION["send_ok"] = 0;
                } else {
                    $send_data .= bin2hex($dat);
                    $display_data = $send_data;
                }
                break;
            case is_numeric($type):
                $send_data .= dec_hex(strlen($dat), $_SESSION["property_len"][$_SESSION["device"]][$basic_tok][1]);
                $send_data .= bin2hex($dat);
                $display_data = $dat;
                break;
            default:
                # numbers
                # parameter length used for strings only -> 0
                $send_data = translate_dec_to_hex($type, intval($dat), 0);
                $display_data = $send_data;
                break;
        }
    }
    return [$send_data, $display_data];
}
function split_and_correct_multiple($tok, $value, $type){
    # for manual entries (of f commands) (send)
    # split by "|", spaces of text are entered as &H7C
    $splitted = explode("|", $value);
    $result = [];
    $i = 0;
    $j = 0;
    while ($i < count($splitted)) {
        if ($splitted[$i] != "") {
            $data= check_data_of_manual_entries($tok, $splitted[$i]);
            if ($_SESSION["send_ok"]) {
                $result[$j] = convert_bin_hex($data, $type);
            }
            else {$result = "";}
            $j ++;
        }
        $i++;
    }
    # return array
    return $result;
}

function check_data_of_manual_entries($tok, $data){
    # $data (for all memory commands is checked for des (ranges)
    # one string or one number
    $ok = 0;
    $range = explode(",",$_SESSION["des"][$_SESSION["device"]][$tok]);
    if ($range[0] == "") {
        # string
        # $data is checked for des (ranges)
        # data is string
        # non valid characters are skipped
        # if $data is too long -> empty string is returned
        $result = "";
        $ok = 0;
        $range = explode(",", $_SESSION["des"][$_SESSION["device"]][$tok]);
        # range[1] (length) exists always
        if (strlen($data) <= $range[1]) {
            if (count($range) == 3) {
                #  range[2] is alpharestriction
                $i = 0;
                while ($i < strlen($data)) {
                    $done = 0;
                    if ($i < (strlen($data) - 4) and (substr($data, $i, 2) == "0H")) {
                        $valid = check_valid_bin(substr($data, $i, 4));
                        if ($valid) {
                            $result .= hexdec(substr($data, $i, 4));
                            $i += 3;
                            $done = 1;
                        }
                    } elseif ($i < (strlen($data) - 10) and (substr($data, $i, 2) == "0B")) {
                        $valid = check_valid_bin(substr($data, $i, 4));
                        if ($valid) {
                            $result .= hexdec(substr($data, $i, 4));
                            $i += 9;
                            $done = 1;
                        }
                    }
                    if (!$done) {
                        if (strstr($range[2], substr($data, $i, 1))) {
                            $result .= substr($data, $i, 1);
                        }
                    }
                    $i++;
                }
            } else {
                # no restriction
                $result = $data;
            }
            $ok = 1;
        }
    }
    else{
        # $data for one number is real value and may be wrong.
        # check data
        # convert hex or bin
        $range = explode(",", $_SESSION["des"][$_SESSION["device"]][$tok]);
        $ok = 1;
        if (strlen($data) > 3 and substr($data,0,2) == "0B") {
            $valid = check_valid_bin($data);
            if ($valid) {
                $data = hexdec($data);
            } else {
                $ok = 0;
            }
        }
        elseif (strlen($data) > 3 and substr($data,0,2) == "0H") {
            $valid = check_valid_hex($data);
            if ($valid) {
                $data = bindec($data);
            }
            else {
                $ok = 0;
            }
        }
        if ($ok){
            # $data is number now
            # number must exactly match the range
            list($min, $max) = find_allowed($range[0]);
            if ($data < $min or $data > $max){
                $ok = 0;
            }
            if ($ok) {
                # int or float
                # <codingname> not yet supported
                list($ok_, $data) = check_translate_range($range, $data, 0);
                if (!$ok_){$ok = 0;}
            }
            if (!$ok) {
                $data = 0;
            }
        }
    }
    if (!$ok){$_SESSION["send_ok"] = 0;}
    return $data;
}

function check_translate_range($range, $data, $check_translate){
    # $check_translate == 0: $data must match the range exactly; otherwise $ok=0; for op /oo / (memory ?) manual entries (no translation)
    # $check_translate == 1: the result is the count of the nearest match to $part_of_range ( transmotted data (for op /oo command)
    $i = 0;
    $found = 0;
    $result = 0;
    while ($i < count($range) and !$found) {
        $ok = 1;
        if (strstr($range[$i], "_") and strstr($range[$i], "to")) {
            $range_ = explode("_", $range[$i]);
            $step_size = (float)$range_[0];
            if ($step_size == 0 or !is_numeric($step_size)){
                # announcement error -> avoid programm crash
                $ok = 0;
                $result = 0;
            }
            else {
                $max = (float)explode("to", $range_[1])[1];
                $min = (float)explode("to", $range_[1])[0];
                # must not be smaller than first $min
                if ((float)$data < $min) {
                    $found = 1;
                    $ok = 0;
                    # for $check_translate==1: last value of $result is used
                } elseif ($data <= $max) {
                    $difference_to_min = $data - $min;
                    $steps = $difference_to_min / $step_size;
                    $steps = (int)$steps;
                    if ($steps * $step_size + $min != $data) {
                        # there is a reminder -> do not match exactly
                        if (!$check_translate) {$ok = 0;}
                    }
                    $found = 1;
                    $result += $steps;
                }
            }
        } else {
            if ($data == $range[$i]) {
                $found = 1;
            }
            else {$result ++;}
        }
        $i++;
    }
    if ($check_translate){$data = $result;}
    return [$ok, $data];
}
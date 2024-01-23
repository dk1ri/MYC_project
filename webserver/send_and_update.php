<?php
# send_and_update.php
# DK1RI 20240122
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function send()
{
    # input:  $_SESSION["tok_to_send"]
    # output: $send  (hex string -> to device)
    foreach ($_SESSION["tok_to_send"] as $key => $value_f) {
        if ($value_f == 1) {
            if (array_key_exists($key, $_SESSION["send_string_by_tok"])) {
                print "send: ".$_SESSION["send_string_by_tok"][$key];
                serial_write($_SESSION["send_string_by_tok"][$key]);
            }
            $_SESSION["tok_to_send"][$key] = 0;
        }
    }
}

# The following are subs used by command send
function calculate_memory_pos_from_POST($basic_tok){
    # no check of $_POST necessary, (manual entry is not supported)
    $device = $_SESSION["device"];
    # ADD token ?
    if (array_key_exists($basic_tok. "n0", $_POST)){
        $Add_data = $_POST[$basic_tok."n0"];
        }
    elseif(array_key_exists($basic_tok. "n0",$_SESSION["actual_data"])){
        $Add_data = $_SESSION["actual_data"][$basic_tok."n0"];
    }
    else {$Add_data = 0;}
    # with ADDer
    if ($Add_data != 0){
        $pos = $_SESSION["max_for_ADD"][$device][$basic_tok."n0"];
    }
    else {
        # no ADDer
        $i = 0;
        $found = 0;
        $pos = 0;
        while (!$found) {
            $tok = $basic_tok . "m" . $i;
            if (!array_key_exists($tok, $_SESSION["des"][$device])) {
                $found = 1;
            } else {
                array_key_exists($tok, $_POST) ? $value = $_POST[$tok] : $value = $_SESSION["actual_data"][$device][$tok];
                $pos += $value;
                if (array_key_exists($basic_tok."m".($i+1), $_SESSION["des"][$device])){
                   $pos *= (int)explode(",",$_SESSION["des"][$device][$basic_tok."m".($i+1)])[0];
                }
            }
            $i++;
        }
    }
    return $pos + $Add_data;
}

function check_send_if_change_of_actual_data($basic_tok){
    # $_POST != $_SESSION{"actual_data"]
    $device = $_SESSION["device"];
    $change_found = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok){
        if (!$change_found) {
            if (array_key_exists($tok, $_POST) and array_key_exists($tok, $_SESSION["actual_data"][$device])) {
                if ($_POST[$tok] != $_SESSION["actual_data"][$device][$tok]) {
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
    $device = $_SESSION["device"];
    if (array_key_exists($tok, $_SESSION["actual_data"][$device])) {
        if (array_key_exists($tok, $_POST)){$_SESSION["actual_data"][$device][$tok] = $_POST[$tok];}
    }
    else{$found = 0;}
    return  $found;
}

function handle_stacks($basic_tok){
    # create stack (for send) if necessary
    # return: $stack
    $device = $_SESSION["device"];
    $stack = "";
    # do nothing, if stacks == 1
    if (explode(",", $_SESSION["original_announce"][$device][$basic_tok][1])[0] == 1){
        return $stack;
    }
    if (array_key_exists($basic_tok, $_SESSION["a_to_o"][$device])) {
        # use all (identical) data of corresponding o token
        $basic_tok = $_SESSION["a_to_o"][$device][$basic_tok];
    }
    # update $_SESSION["actual_data"][$device]
    # the key of the number_of_selects array is 0, 1, ... (as tokenbx)
    $i = 0;
    $found = 1;
    $stack_changed = 0;
    while ($found){
        # all m token only
        $c_token = $basic_tok."m".$i;
        if (array_key_exists($c_token, $_POST)) {
            if ($_POST[$c_token] != $_SESSION["actual_data"][$device][$c_token]) {
                $stack_changed = 1;
                $_SESSION["actual_data"][$device][$c_token] = $_POST[$c_token];
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
            if ($_POST[$c_token] != $_SESSION["actual_data"][$device][$c_token]) {
                $stack_changed = 1;
                $_SESSION["actual_data"][$device][$c_token] = $_POST[$c_token];
            }
        }
        else{$found = 0;}
        $i++;
    }
    # create stack for transmit rom actual data:
    # ADD token ?
    if (array_key_exists($basic_tok. "n0", $_POST)){
        $Add_data = $_POST[$basic_tok."n0"];
    }
    elseif(array_key_exists($basic_tok. "n0",$_SESSION["actual_data"])){
        $Add_data = $_SESSION["actual_data"][$basic_tok."n0"];
    }
    else {$Add_data = 0;}
    # with ADDer
    if ($Add_data != 0){
        $stack = $_SESSION["max_for_ADD"][$device][$basic_tok."n0"];
    }
    else {
        # no ADDer
        $stack = 0;
        $i = 0;
        while (!$found) {
            $tok = $basic_tok . "m" . $i;
            if (!array_key_exists($tok, $_SESSION["des"][$device])) {
                $found = 1;
            } else {
                array_key_exists($tok, $_POST) ? $value = $_POST[$tok] : $value = $_SESSION["actual_data"][$device][$tok];
                $stack += $value;
                if (array_key_exists($basic_tok . "m" . ($i + 1), $_SESSION["des"][$device])) {
                    $stack *= (int)explode(",", $_SESSION["des"][$device][$basic_tok . "m" . ($i + 1)])[0];
                }
            }
            $i++;
        }
    }
    $stack_len = $_SESSION["property_len"][$device][$basic_tok][1];
    $stack = dec_hex($stack,$stack_len);
    return [$stack, $stack_changed];
}

function check_memory_data($tok, $device, $type, $mode){
    # mode == 0: use $_POST[$tok] to check
    # mode == 1: $tok is part of $_POST[$tok]
    !$mode ? $input_value = $_POST[$tok] : $input_value = $tok;
    $dat = convert_bin_hex($input_value, $type);
    $basic_tok = basic_tok($tok);
    $data = "";
    switch ($type) {
        case "b":
            if (strlen($dat) > 1) {
                $_SESSION["send_ok"] = 0;
            } else {
                $data .= bin2hex($dat);
            }
            break;
        case is_numeric($type):
            if (strlen($dat) > $type) {
                $_SESSION["send_ok"] = 0;
            } else {
                $data .= dec_hex(strlen($dat), $_SESSION["property_len"][$device][$basic_tok][1]);
                $data .= bin2hex($dat);
            }
            break;
        default:
            # numbers
            $data = check_if_number_is_correct(intval($input_value), $type);
            if ($_SESSION["send_ok"]) {
                # parameter length used for strings only -> 0
                $data = translate_dec_to_hex($type, $data, 0);
            }
            break;
    }
    return $data;
}
function split_and_correct_multiple($value, $type){
    # for manual entries (of memory) (send)
    # split by " ", spaces of text are entered as &H20
    $splitted = explode(" ", $value);
    $result = [];
    $i = 0;
    $j = 0;
    while ($i < count($splitted)) {
        if ($splitted[$i] != "") {
            $result[$j] = convert_bin_hex($splitted[$i], $type);
            $j ++;
        }
        $i++;
    }
    # return array
    return $result;
}
function check_if_number_is_correct($data, $type){
    # check range by $type; correct by type (for entered data)
    # for data to send
    list($min, $max) = find_allowed($type);
    if ($data < $min or $data > $max){
        $_SESSION["send_ok"] = 0;
    }
    return $data;
}

<?php
# send_and_update.php
# DK1RI 20230208
function send_and_update(){
    # input:  $_SESSION["corrected_POST"]
    # output:  $_SESSION["actual_data"][$device]
    # output: $send  (hex string -> to device)
    # $_SESSION["corrected_POST"]:
    # for xs xt xu : string (always)
    # for or : array with numbers of changed fields (only, if changed)
    $device = $_SESSION["device"];
    $announce_a = $_SESSION["announce_all"][$device];
    $allready_done = 0;
    foreach ($_SESSION["corrected_POST"][$device] as $tok => $value) {
        if (!array_key_exists($tok, $announce_a)) {
            # interface.. name ....
            if (array_key_exists($tok, $_SESSION)) {
                $_SESSION[$tok] = $_POST[$tok];
            }
        }
        else {
            $basic_tok = basic_tok($tok);
            if ($basic_tok != $allready_done) {
                # every $basic_tok is handled once only
                # different $tok with same $basic_tok in $_SESSION["corrected_POST"] are handled with the first $tok found
                $send_ok = 0;
                # update and generate $send for basic_tok
                $ct = $_SESSION["announce_all"][$device][$tok][0];
                $send = $_SESSION["tok_hex"][$device][$basic_tok];
                switch ($ct) {
                    case "m":
                        $send_ok = update($device, $basic_tok);
                        $send = "00";
                        if (array_key_exists($basic_tok . "a0", $_POST)) {
                            if ($_POST[$basic_tok] == "1") {
                                $send_ok = 1;
                            }
                        }
                        if ($send_ok){
                            $_SESSION["read"] = 1;
                        }
                        break;
                    case "os":
                        $send_ok = update($device, $basic_tok);
                        $send .= handle_stacks($basic_tok);
                        $send .= dec_hex($_SESSION["actual_data"][$device][$basic_tok . "x0"], $_SESSION["property_len"][$device][$basic_tok][2]);
                        break;
                    case "as":
                    case "at":
                        $send_ok = update($device, $basic_tok);
                        $send = $send . handle_stacks($basic_tok);
                        if (array_key_exists($basic_tok . "a0", $_POST)) {
                            if ($_POST[$basic_tok . "a0"] == "1") {
                                $send_ok = 1;
                            }
                        }
                        if ($send_ok){
                            $_SESSION["read"] = 1;
                        }
                        break;
                    case "or":
                        # $send_ok_ used: no immediate send!
                        $stack = "";
                        $send_ok_ = update_or_b($device, $basic_tok . "b0");
                        $send .= handle_stacks($basic_tok);
                        $announce = $_SESSION["announce_all"][$device][$basic_tok . "x0"];
                        if (array_key_exists($basic_tok . "x0", $_SESSION["corrected_POST"][$device])) {
                            update_and_send_or_x($send . $stack, $device, $basic_tok . "x0");
                        } else {
                            if (count($announce) == 3) {
                                if ($send_ok_) {
                                    # toggle and send, if stack was changed only
                                    $actual_a = explode(",", $_SESSION["actual_data"][$device][$basic_tok . "x0"]);
                                    $data = $_SESSION["corrected_POST"][$device][$tok];
                                    if ($data != 0) {
                                        # there are two values of actual_a only
                                        if ($actual_a[1] == 1) {
                                            $actual_a[1] = 0;
                                            $send .= "00";
                                        } else {
                                            $actual_a[1] = 1;
                                            $send .= "01";
                                        }
                                        $send_ok = $send_ok_;
                                    }
                                    $_SESSION["actual_data"][$device][$basic_tok . "x0"] = implode(",", $actual_a);
                                }
                            }
                            # else { do nothing, because it is not known, which switch to operate }
                        }
                        break;
                    case "ar":
                        $send_ok = update($device, $basic_tok);
                        $send = $send . handle_stacks($basic_tok);
                        $announce = $_SESSION["announce_all"][$device][$basic_tok . "x0"];
                        if (count($announce) == 2) {
                            if (array_key_exists($basic_tok . "a0", $_POST)) {
                                # send always
                                $send_ok = 1;
                            }
                            ($send_ok == 1) ? $_SESSION["read"] = 1 : $_SESSION["read"] = 0;
                        } else {
                            if (array_key_exists($basic_tok . "x0", $_SESSION["corrected_POST"][$device])) {
                                $data = $_SESSION["corrected_POST"][$device][$basic_tok . "x0"];
                                $send .= dec_hex($data, $_SESSION["property_len"][$device][$basic_tok][2]);
                                if (array_key_exists($basic_tok . "a0", $_POST)) {
                                    $send_ok = 1;
                                }
                            }
                        }
                        if ($send_ok){
                            $_SESSION["read"] = 1;
                        }
                        break;
                    case "ou":
                        $send_ok = update($device, $basic_tok);
                        $x0 = $basic_tok . "x0";
                        # send, if one value only or one selected (no send with change of stack only)
                        $send = $send . handle_stacks($basic_tok);
                        if (array_key_exists($x0, $_SESSION["corrected_POST"][$device])) {
                            if ($_SESSION["corrected_POST"][$device][$x0] != 0) {
                                if (count($_SESSION["announce_all"]) > 2) {
                                    $send .= $_SESSION["corrected_POST"][$device][$x0] - 1;
                                }
                                $send_ok = 1;
                            }
                        } else {
                            $send_ok = 0;
                        }
                        break;
                    case "op":
                        $send_ok = update($device, $basic_tok);
                        # stack:
                        $send .= handle_stacks($basic_tok);
                        if ($send_ok != 0){
                            foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
                                if (basic_tok($tok) == $basic_tok) {
                                    # not "oo" commands!
                                    if (!(strstr($tok, "b") or strstr($tok, "x0"))) {
                                        # not "x0"
                                        $max = $_SESSION["announce_all"][$device][$tok][1];
                                        $range = $_SESSION["des_range"][$device][$tok];
                                        if ($max < 256){
                                            $value = retranslate_simple_range($range, $_SESSION["actual_data"][$device][$tok], 2);
                                        }
                                        else{
                                            $value = retranslate_full($range, $_SESSION["actual_data"][$device][$tok]);
                                        }
                                        $length = $_SESSION["property_len"][$device][$basic_tok][2];
                                        $send .= translate_dec_to_hex("n", $value, $length);
                                    }
                                }
                            }
                        }
                        break;
                    case "oo":
                        $send_ok = update($device, $basic_tok);
                        if ($_SESSION["actual_data"][$device][$basic_tok . "x1r"] == "idle") {
                            # do not send
                            break;
                        } else {
                            # stack:
                            $send .= handle_stacks($basic_tok);
                            # data:
                            foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
                                if (!(strstr($tok, "b") or strstr($tok, "x0"))) {
                                    $length = $_SESSION["property_len"][$device][$basic_tok][2];
                                    $send .= translate_dec_to_hex("n", $_SESSION["actual_data"][$device][$tok], $length);
                                }
                            }
                            # set to idle again
                            $_SESSION["actual_data"][$device][$basic_tok . "x1r"] = "idle";
                        }
                        break;
                    case "ap":
                        $send_ok = update($device, $basic_tok);
                        $stack_value = handle_stacks($basic_tok);
                        $send .= $stack_value;
                        if (array_key_exists($basic_tok . "a0", $_POST)) {
                            if ($_POST[$basic_tok . "a0"] == "1") {
                                $send_ok = 1;
                            }
                        }
                        if ($send_ok){
                            $_SESSION["read"] = 1;
                        }
                        break;
                    case "om":
                        $send_ok = update($device, $basic_tok);
                        if ($send_ok) {
                            # position
                            $send .= calculate_pos_hex($basic_tok, 0);
                            # data
                            $type = $_SESSION["des_type"][$device][$basic_tok . "x0"][0];
                            $length = $_SESSION["property_len"][$device][$basic_tok][2];
                            $send .= translate_dec_to_hex($type, $_SESSION["actual_data"][$device][$basic_tok . "x0"], $length);
                        }
                        break;
                    case "am":
                        $send_ok = update($device, $basic_tok);
                        if ($send_ok) {
                            # position
                            $send .= calculate_pos_hex($basic_tok, 0);
                            if (array_key_exists($basic_tok . "a0", $_POST)) {
                                if ($_POST[$basic_tok . "a0"] == "1") {
                                    $send_ok = 1;
                                }
                            }
                        }
                        if ($send_ok){
                            $_SESSION["read"] = 1;
                        }
                        break;
                    case "on":
                        $send_ok = update($device, $basic_tok);
                        if ($send_ok) {
                            # number of elements are calculated by using data
                            $no_element = count(explode(",", $_SESSION["actual_data"][$device][$basic_tok . "b0"]));
                            $length = $_SESSION["property_len"][$device][$basic_tok][1];
                            $send .= translate_dec_to_hex("n", $no_element, $length);
                            # position
                            if ($_SESSION["des_range"][$device][$basic_tok . "b1"] == 0) {
                                # FIFO
                                $send .= "00";
                            } else {
                                $send .= calculate_pos_hex($basic_tok, 1);
                            }
                            # data
                            $type = $_SESSION["des_type"][$device][$basic_tok . "x0"][0];
                            $length = $_SESSION["property_len"][$device][$basic_tok][2];
                            $dataelements = explode(",", $_SESSION["actual_data"][$device][$basic_tok . "x0"]);
                            $i = 0;
                            while ($i < count($dataelements)) {
                                $send .= translate_dec_to_hex($type, $dataelements[$i], $length);
                                $i += 1;
                            }
                        }
                        break;
                    case "an":
                        $send_ok = update($device, $basic_tok);
                        if ($send_ok) {
                            # do not send with 0 elements
                            if ($_SESSION["actual_data"][$device][$basic_tok . "b0"] != 0) {
                                # number of elements + position
                                $length = $_SESSION["property_len"][$device][$basic_tok][2];
                                $send .= translate_dec_to_hex("n", $_SESSION["actual_data"][$device][$basic_tok . "b0"], $length);
                                $length = $_SESSION["property_len"][$device][$basic_tok][3];
                                $send .= translate_dec_to_hex("n", $_SESSION["actual_data"][$device][$basic_tok . "b1"], $length);
                                if (array_key_exists($basic_tok . "a0", $_POST)) {
                                    if ($_POST[$basic_tok . "a0"] == "1") {
                                        $send_ok = 1;
                                    }
                                }
                            } else {
                                $send_ok = 0;
                            }
                        }
                        if ($send_ok){
                            $_SESSION["read"] = 1;
                        }
                        break;
                    case "oa":
                        # more than one element may have changed, each generate a send
                        $b0 = $basic_tok . "b0";
                        foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token){
                            if (strstr($c_token,"x")){
                                if (array_key_exists($c_token, $_SESSION["corrected_POST"][$device])){
                                    if ($_SESSION["corrected_POST"][$device][$c_token] != "") {
                                        if ($_SESSION["corrected_POST"][$device][$c_token] != $_SESSION["actual_data"][$device][$c_token]) {
                                            # position:
                                            $send_a = $send;
                                            if (array_key_exists($b0, $_SESSION["actual_data"][$device])) {
                                                $pos = explode("x",$c_token)[1] - 1;
                                                $send_a .= translate_dec_to_hex("n", $pos, 2);
                                            }
                                            $type = $_SESSION["des_type"][$device][$c_token][0];
                                            $length = length_of_type($type);
                                            $send_a .= translate_dec_to_hex($type, $_SESSION["corrected_POST"][$device][$c_token], $length);
                                            $_SESSION["actual_data"][$device][$c_token] = $_SESSION["corrected_POST"][$device][$c_token];
                                            send_to_device($send_a);
                                        }
                                    }
                                }
                            }
                        }
                        break;
                    case "aa":
                        $send_ok = update($device, $basic_tok);
                        # position of element
                        $b0 = $basic_tok . "b0";
                        if (array_key_exists($b0, $_SESSION["actual_data"][$device])){
                            $pos = $_SESSION["actual_data"][$device][$b0];
                            $send .= translate_dec_to_hex("n", $pos, 2);
                        }
                        if (array_key_exists($basic_tok . "a0", $_POST)) {
                            if ($_POST[$basic_tok . "a0"] == "1") {
                                $send_ok = 1;
                            }
                        }
                        if ($send_ok){
                            $_SESSION["read"] = 1;
                        }
                        break;
                    case "ob":
                        $send_ok = update($device, $basic_tok);
                        # any change will generate a send
                        $number = $_SESSION["actual_data"][$device][$basic_tok. "b0"];
                        if ($number > 0) {
                            $send .= translate_dec_to_hex("n", $number, 2);
                            $start = retranslate_simple_range($basic_tok . "b1", $_SESSION["actual_data"][$device][$basic_tok . "b1"], 2);
                            $send .= translate_dec_to_hex("n", $start, 2);
                            $i = 0;
                            $j = $start + 1;
                            while ($i < $number) {
                                $tok = $basic_tok . "x" . $j;
                                if (!array_key_exists($tok, $_SESSION["actual_data"][$device])){
                                    # continue at first element
                                    $j = 1;
                                    $tok = $basic_tok . "x1";
                                }
                                $type = $_SESSION["des_type"][$device][$tok][0];
                                $length = length_of_type($type);
                                $send .= translate_dec_to_hex($type, $_SESSION["actual_data"][$device][$tok], $length);
                                $i += 1;
                            }
                            # reset to 0 again
                            $_SESSION["actual_data"][$device][$basic_tok. "b0"] = 0;
                        }
                        else{
                            $send_ok = 0;
                        }
                        break;
                    case "ab":
                        $send_ok = update($device, $basic_tok);
                        # number of elements
                        $b0 = $basic_tok . "b0";
                        $b1 = $basic_tok . "b1";
                        $number = $_SESSION["actual_data"][$device][$b0];
                        if ($number > 0) {
                            $send .= translate_dec_to_hex("n", $number, 2);
                            # pos of elements
                            if (array_key_exists($b1, $_SESSION["actual_data"][$device])) {
                                $pos = $_SESSION["actual_data"][$device][$b1];
                                $send .= translate_dec_to_hex("n", $pos, 2);
                            }
                            if (array_key_exists($basic_tok . "a0", $_POST)) {
                                if ($_POST[$basic_tok . "a0"] == "1") {
                                    $send_ok = 1;
                                }
                            }
                        }
                        else{
                            $send_ok = 0;
                        }
                        if ($send_ok){
                            $_SESSION["read"] = 1;
                        }
                        break;
                }
                if ($send_ok) {
                    send_to_device($send);
                }
                $allready_done = $basic_tok;
            }
        }
    }
}

function update($device, $basic_tok){
    # check all
    # for switches for answer-commands stacks only
    $send_ok = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token){
        $ct = explode(",", $_SESSION["original_announce"][$device][$basic_tok][0])[0];
        if ($ct== "as" or $ct == "ar" or $ct == "at"){
            if (strstr($token, "x") or strstr($token, "a")) {
                continue;
            }
        }
        if (array_key_exists($token, $_SESSION["corrected_POST"][$device])) {
            $data = $_SESSION["corrected_POST"][$device][$token];
            if ($_SESSION["actual_data"][$device][$token] != $data and $data != "") {
                $_SESSION["actual_data"][$device][$token] = $data;
                $send_ok = 1;
            }
        }
    }
    return $send_ok;
}

function update_or_b($device, $token){
    # stack for or command
    $send_ok = 0;
    if (array_key_exists($token, $_SESSION["corrected_POST"][$device])) {
        $data = $_SESSION["corrected_POST"][$device][$token];
        if ($_SESSION["actual_data"][$device][$token] != $data and $data != "") {
            $_SESSION["actual_data"][$device][$token] = $data;
            $send_ok = 1;
        }
    }
    return $send_ok;
}

function update_and_send_or_x($send, $device, $token){
    #data
    # data
    $actual_a = explode(",", $_SESSION["actual_data"][$device][$token]);
    $data = $_SESSION["corrected_POST"][$device][$token];
    $announce = $_SESSION["announce_all"][$device][$token];
    if (count($announce) == 3){
        if ($actual_a[1] == 1) {
            $actual_a[1] = 0;
            $send .= "00";
        }
        else {
            $actual_a[1] = 1;
            $send .= "01";
        }
        send_to_device($send);
    }
    else {
        if ($data == 0) {
            # reset if "1"
            $i = 0;
            while ($i < count($actual_a)) {
                if ($actual_a[$i] == 1) {
                    $actual_a[$i] = 0;
                    if ($i > 0) {
                        # not for resetall
                        $send_fin = $send . dec_hex($i - 1, $_SESSION["property_len"][$device][basic_tok($token)][2]) . "00";
                        send_to_device($send_fin);
                    }
                }
                $i += 1;
            }
        } else {
            # toggle
            if ($actual_a[$data] == 1) {
                $actual_a[$data] = 0;
            } else {
                $actual_a[$data] = 1;
            }
            $send .= dec_hex($data - 1, $_SESSION["property_len"][$device][basic_tok($token)][2]) . "0" . $actual_a[($data)];
            send_to_device($send);
        }
    }
    $_SESSION["actual_data"][$device][$token] = implode(",", $actual_a);
}

function calculate_pos_hex($basic_tok, $on_an_adder){
    # for position for m commands
    # for 3 dimensions: z = n_x*my*mz + n_y*mz + nz
    $device = $_SESSION["device"];
    $maxmax = 1;
    $max = [];
    $i = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $key => $token) {
        if (strstr($token, "b")) {
            if ($on_an_adder and $key == $basic_tok . "b0") {
                $i += 1;
                continue;
            }
            $positions = explode(",", $_SESSION["des_range"][$device][$basic_tok . "b" . $i]);
            $maxmax *= (int)end($positions);
            $max[] = $maxmax;
            $i += 1;
        }
    }
    $maxcount = count($max) - 1;
    $i = 0;
    $pos = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $key => $token) {
        if (strstr($token, "b")) {
            if ($on_an_adder and $key == $basic_tok . "b0"){
                $i += 1;
                continue;
            }
            $val = $_SESSION["actual_data"][$device][$token];
            # after "b" tok a "x" tok is following always
            $temp =  $_SESSION["cor_token"][$device][$basic_tok][$key + 1];
            if (strstr($temp, "x")) {
                if (array_key_exists($basic_tok, $_SESSION["adder_token"][$device])) {
                    if ($val != 0 and $token == $_SESSION["adder_token"][$device][$basic_tok]) {
                        $pos = $maxmax + $val;
                    }
                }
                else {
                    $pos += $val;
                }
            }
            else {
                $pos += $val * $max[$maxcount - 1];
            }
            $i += 1;
            $maxcount -= 1;
        }
    }
    $i = 2 + $on_an_adder;
    # max length of pos:
    $length = 1;
    while($i < count($_SESSION["original_announce"][$device][$basic_tok])) {
        $l = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$i])[0];
        $length *= (int)$l;
        $i += 1;
    }
    $length = length_of_type($length);
    return translate_dec_to_hex("n", $pos, $length);
}

function handle_stacks($basic_tok){
    $device = $_SESSION["device"];
    $stack = "";
    $multiplier = 1;
    # the key of the number_of_selects array is 0, 1, ...:
    $stack_display_number = 0;
    # the transmitted values count over the different (MUL/ADD) display stacksparts:
    $actual_value = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token) {
        if (strstr($c_token,"b") and $basic_tok == basic_tok($c_token)) {
            # avoid oo token for op token
            $actual_value = (int)$_SESSION["actual_data"][$device][$c_token];
            # $nr: 0, 1, ...
            $des = explode(",",$_SESSION["des_range"][$device][$c_token]);
            $_max_stack_per_tok = count($des) / 2;
            $value = retranslate_simple_range($des, $actual_value, 2 );
            # _: Multiplier
            $multiplier *= $_max_stack_per_tok;
            if ($stack_display_number == 0) {
                $stack = $value;
            }
            else {
                $stack = $stack * $_max_stack_per_tok + $value;
            }
            $stack_display_number += 1;
        }
        elseif (strstr($c_token,"c"))  {
            # adder
            if ($actual_value) {
                $stack = $multiplier + $actual_value;
            }
        }
    }
    if ($stack == ""){
        return "";
    }
    else {
        return dec_hex($stack, $_SESSION["property_len"][$device][$basic_tok][1]);
    }
}

function send_to_device($send){
    print (" send: ". $send);
    serial_write($send);
}

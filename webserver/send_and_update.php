<?php
# send_and_update.php
# DK1RI 20230609
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function send_and_update(){
    # input:  $_SESSION["corrected_POST"]
    # output:  $_SESSION["actual_data"][$device]
    # output: $send  (hex string -> to device)
    # $_SESSION["corrected_POST"]:
    # for or : array with numbers of changed fields (only, if changed)
    #
    $device = $_SESSION["device"];
    $announce = $_SESSION["announce_all"][$device];
    $already_done = [];
    $_SESSION["read"] = 0;
    foreach ($_SESSION["corrected_POST"][$device] as $tok => $value) {
        # interface.. name .... device is updated in correct_POST
        # values of ($_SESSION["corrected_POST"][$device] are correct (updated by correct_POST before)
        if (!array_key_exists($tok, $_SESSION["special_token"][$device])){
            $basic_tok = basic_tok($tok);
            if (!array_key_exists($basic_tok, $already_done)) {
                # every $basic_tok is handled once only
                # different $tok with same $basic_tok in $_SESSION["corrected_POST"] are handled with the first $tok found
                $send_ok = 0;
                # update and generate $send for basic_tok
                if (array_key_exists($basic_tok, $_SESSION["ct_of_as"][$device])){
                    # for "as"token the ct of the o token must be used
                    $ct = $_SESSION["ct_of_as"][$device][$basic_tok];
                }
                else {
                    $ct = $_SESSION["announce_all"][$device][$tok][0];
                }
                $send = dec_hex($basic_tok, $_SESSION["command_len"][$device]);
                # $senda is used, if as answer token is activ
                if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])) {
                    $tok2 = $_SESSION["o_to_a"][$device][$basic_tok];
                    $senda = dec_hex($tok2, $_SESSION["command_len"][$device]);
                }
                else {$senda = $send;}
                switch ($ct) {
                    case "m":
                        if (array_key_exists($basic_tok . "a0", $_POST)) {
                            if ($_POST[$basic_tok . "a0"] == "1") {
                                $send_ok = 1;
                                $_SESSION["read"] = 1;
                            }
                        }
                        break;
                    case "os":
                        list($send, $senda, $change_found) = handle_stacks($basic_tok, $send, $senda);
                        # $send has stacks now, if necessary
                        $tok = $basic_tok. "a";
                        if (array_key_exists($tok, $_SESSION["corrected_POST"][$device]) and $_SESSION["corrected_POST"][$device][$tok] == 1) {
                            # if answer set-> ignore change of data
                            $send = $senda;
                            $send_ok = 1;
                            $_SESSION["read"] = 1;
                        }
                        else {
                            list($send, $change_found_) = update_one($basic_tok . "d0", $send, 2);
                            if ($change_found_) {
                                $change_found = 1;
                                change_as_data($basic_tok . "d0");
                            }
                            if ($change_found) {
                                $send_ok = 1;
                            }
                        }
                        break;
                    case "as":
                    case "at":
                    list($send, $senda, $change_found) = handle_stacks($basic_tok, $send, $senda);
                        $tok = $basic_tok. "a";
                        if (array_key_exists($tok, $_SESSION["corrected_POST"][$device])) {
                            if ($_SESSION["corrected_POST"][$device][$tok] == 1) {
                                $change_found = 1;
                            }
                            $_SESSION["actual_data"][$device][$tok] = 0;
                        }
                        if ($change_found){
                            $send_ok = 1;
                            $_SESSION["read"] = 1;
                        }
                        break;
                    case "or":
                        $add = "";
                        list($send, $senda, $change_found) = handle_stacks($basic_tok, $send, $senda);
                        # $send has stacks now, if necessary
                        $tok = $basic_tok. "a";
                        if (array_key_exists($tok, $_SESSION["corrected_POST"][$device]) and $_SESSION["corrected_POST"][$device][$tok] == 1) {
                            # only "a" command delivers !1!, if answer set-> ignore change of data
                            $number_of_switches = count($_SESSION["original_announce"][$device][$basic_tok]) - 2;
                            $found = 0;
                            if ($number_of_switches > 0){
                                $i = 0;
                                while ($i < $number_of_switches and $found == 0) {
                                    $tok3 = $basic_tok . "d" . $i;
                                    if (array_key_exists($tok3, $_SESSION["corrected_POST"][$device]) and $_SESSION["corrected_POST"][$device][$tok3] == "on") {
                                        # one only
                                        $found = 1;
                                        $add = dec_hex($i, 2);
                                    }
                                    $i += 1;
                                }
                            }
                            else {$found = 1;}
                            if ($found == 1) {
                                $send = $senda . $add;
                                $send_ok = 1;
                                $_SESSION["read"] = 1;
                            }
                        }
                        else {
                            # $_POST delivers 0 or "on" for all checkbox token (on ,eans toggeling!
                            foreach ($_SESSION["corrected_POST"][$device] as $tok1 => $value1) {
                                # for $actual $basic_tok only
                                if ($basic_tok == basic_tok($tok1)) {
                                    if (strstr($tok1, "d")) {
                                        if (count($_SESSION["original_announce"][$device][$basic_tok]) > 3){
                                            # only, if more than 1 element
                                            $sub_token = explode("d", $tok1)[1];
                                            $send .= dec_hex($sub_token, 2);
                                        }
                                        if ($_SESSION["corrected_POST"][$device][$tok1] == "on") {
                                            # send onnly with change, changed stack not sufficient
                                            # now the changes, toggle for operating
                                            if ($_SESSION["actual_data"][$device][$tok1] == "0") {
                                                $add = "01";
                                                $_SESSION["actual_data"][$device][$tok1] = "1";
                                            } else {
                                                $add = "00";
                                                $_SESSION["actual_data"][$device][$tok1] = "0";
                                            }
                                            send_to_device($send . $add);
                                        }
                                    }
                                }
                            }
                        }
                        # no further send:
                        break;
                    case "ar":
                        # either ar command (no or) or no switch button of or command but read button
                        list($send, $senda, $change_found) = handle_stacks($basic_tok, $send, $senda);
                        foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token){
                            if (strstr($c_token, "d")){
                                if (array_key_exists($c_token, $_SESSION["corrected_POST"][$device])) {
                                    if ($_SESSION["corrected_POST"][$device][$c_token] == "on") {
                                        $sub_token = explode("d", $c_token)[1];
                                        if (count($_SESSION["original_announce"][$device][$basic_tok]) > 3) {
                                            $send = $send . dec_hex($sub_token, 1);
                                        }
                                        $_SESSION["read"] = 1;
                                        send_to_device($send);
                                    }
                                }
                            }
                        }
                        # no further send:
                        $send_ok = 0;
                        break;
                    case "ou":
                        list($send, $senda, $change_found) = handle_stacks($basic_tok, $send, $senda);
                        if (array_key_exists($basic_tok."d0", $_SESSION["corrected_POST"][$device])){
                            $tok = $basic_tok."d0";
                            # $actual_data is 0 always
                            # send, if corrected_POST is not idle (no send with change of stack only)
                            if ($_SESSION["corrected_POST"][$device][$tok] != 0) {
                                $send .= dec_hex($_SESSION["corrected_POST"][$device][$tok], 2);
                                $send_ok = 1;
                            }
                        }
                        break;
                    case "op":
                        list($send, $senda, $change_found) = handle_stacks($basic_tok, $send, $senda);
                        $tok = $basic_tok. "a";
                        if (array_key_exists($tok, $_SESSION["corrected_POST"][$device]) and $_SESSION["corrected_POST"][$device][$tok] == 1) {
                            # if answer set-> ignore change of data
                            $send = $senda;
                            $send_ok = 1;
                            $_SESSION["read"] = 1;
                        }
                        else {
                            foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
                                if (basic_tok($tok) == $basic_tok) {
                                    # not "oo" commands!
                                    if (strstr($tok, "d")) {
                                        $change_found_ = update_one_only($tok);
                                        if ($change_found_) {
                                            $change_found = 1;
                                        }
                                    }
                                }
                            }
                            # add to send:
                            foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
                                if (basic_tok($tok) == $basic_tok) {
                                    # not "oo" commands!
                                    if (strstr($tok, "d")) {
                                        $length = $_SESSION["property_len"][$device][$basic_tok][2];
                                        $send .= translate_dec_to_hex($basic_tok, "n", $_SESSION["actual_data"][$device][$tok], $length);
                                    }
                                }
                            }
                            if ($change_found) {
                                $send_ok = 1;
                            }
                        }
                        break;
                    case "oo":
                        list($send, $senda, $change_found) = handle_stacks($basic_tok, $send, $senda);
                        # data:
                        $add = 0;
                        foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
                            if (strstr($tok, "d")) {
                                if (array_key_exists($tok, $_SESSION["corrected_POST"][$device])) {
                                    if ($_SESSION["actual_data"][$device][$tok] != $_SESSION["corrected_POST"][$device][$tok]) {
                                        $_SESSION["actual_data"][$device][$tok] = $_SESSION["corrected_POST"][$device][$tok];
                                        $change_found = 1;
                                    }
                                }
                            }
                        }
                        # send data:
                        foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
                            if (strstr($tok, "d")) {
                                $length = $_SESSION["property_len"][$device][$basic_tok][2];
                                $send .= translate_dec_to_hex($basic_tok, "n", $_SESSION["actual_data"][$device][$tok] + $add, $length);
                                if (strstr($tok, "r")) {
                                    if ($_SESSION["actual_data"][$device][$tok] != 0) {
                                        $change_found = 1;
                                    }
                                    # set to idle again
                                    $_SESSION["actual_data"][$device][$tok] = 0;
                                }
                            }
                        }
                        if ($change_found){$send_ok = 1;}
                        break;
                    case "ap":
                        list($send, $senda, $change_found) = handle_stacks($basic_tok, $send, $senda);
                        $tok = $basic_tok."a";
                        if (array_key_exists($tok, $_SESSION["corrected_POST"][$device])) {
                            if ($_SESSION["corrected_POST"][$device][$tok] == "1") {
                                $change_found = 1;
                            }
                        }
                        if ($change_found) {
                            $send_ok = 1;
                            $_SESSION["read"] = 1;
                        }
                        break;
                    case "om":
                        $send_ok = check_a_in_POST($basic_tok);
                        if ($send_ok) {
                            $send_ok = update($device, $basic_tok);
                            if ($send_ok) {
                                # position
                                $send .= calculate_pos_hex($basic_tok, 0);
                                # data
                                $des_type = explode(";", $_SESSION["des_type"][$device][$basic_tok . "x1"]);
                                $send .= translate_dec_to_hex($basic_tok, $des_type[0], $_SESSION["actual_data"][$device][$basic_tok . "x1"], $des_type[0]);
                            }
                        }
                        break;
                    case "am":
                        $send_ok = update($device, $basic_tok);
                        if (array_key_exists($basic_tok . "a0", $_POST)) {
                            if ($_POST[$basic_tok . "a0"] == "1") {
                                # position, use data of om command
                                $send .= calculate_pos_hex($basic_tok, 0);
                                $send_ok = 1;
                                $_SESSION["read"] = 1;
                            }
                        }
                        break;
                    case "on":
                        $send_ok = update($device, $basic_tok);
                        $data = "";
                        if ($send_ok) {
                            # number of elements are calculated by using data
                            $dataelements = explode(",", $_SESSION["actual_data"][$device][$basic_tok . "x1"]);
                            $no_element = count($dataelements);
                            $length = $_SESSION["property_len"][$device][$basic_tok][1];
                            $data .= translate_dec_to_hex($basic_tok, "n", $no_element, $length);
                            $send .= $data;
                            # position
                            if ($_SESSION["des_range"][$device][$basic_tok . "b1"] == 0) {
                                # FIFO
                                $send .= "00";
                            } else {
                                $send .= calculate_pos_hex($basic_tok, 1);
                            }
                            # data
                            $des_type = explode(";", $_SESSION["des_type"][$device][$basic_tok . "x1"]);
                            $length = $des_type[0];
                            $i = 0;
                            while ($i < count($dataelements)) {
                                $send .= translate_dec_to_hex($basic_tok, $des_type[0], $dataelements[$i], $length);
                                $i += 1;
                            }
                        }
                        break;
                    case "an":
                        $send_ok = update($device, $basic_tok);
                        if (array_key_exists($basic_tok . "a0", $_POST)) {
                            # do not send with 0 elements
                            if ($_SESSION["actual_data"][$device][$basic_tok . "b0"] != 0) {
                                # number of elements + position
                                $length = $_SESSION["property_len"][$device][$basic_tok][2];
                                $data = translate_dec_to_hex($basic_tok, "n", $_SESSION["actual_data"][$device][$basic_tok . "b0"], $length);
                                $send .= fillup($data, $length);
                                $length = $_SESSION["property_len"][$device][$basic_tok][3];
                                $data = calculate_pos_hex($basic_tok, 1);
                                $send .= fillup($data, $length);
                                $send_ok = 1;
                                $_SESSION["read"] = 1;
                            }
                        }
                        break;
                    case "oa":
                        # more than one element may have changed, each generate a send
                        foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token) {
                            if (strstr($c_token, "d")) {
                                if (array_key_exists($c_token, $_SESSION["corrected_POST"][$device])) {
                                    if ($_SESSION["corrected_POST"][$device][$c_token] != "") {
                                        if ($_SESSION["corrected_POST"][$device][$c_token] != $_SESSION["actual_data"][$device][$c_token]) {
                                            # position:
                                            $send_a = $send;
                                            if (array_key_exists($basic_tok . "b1", $_SESSION["actual_data"][$device])) {
                                                $pos = explode("d", $c_token)[1] - 1;
                                                $send_a .= translate_dec_to_hex($basic_tok, "n", $pos, 2);
                                            }
                                            $des_type = explode(";", $_SESSION["des_type"][$device][$c_token]);
                                            $length = length_of_type($des_type[0]);
                                            $send_a .= translate_dec_to_hex($basic_tok, $des_type[0], $_SESSION["corrected_POST"][$device][$c_token], $length);
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
                        $b1 = $basic_tok . "b1";
                        if (array_key_exists($b1, $_SESSION["actual_data"][$device])) {
                            $pos = $_SESSION["actual_data"][$device][$b1];
                            $send .= translate_dec_to_hex($basic_tok, "n", $pos, 2);
                        }
                        if (array_key_exists($basic_tok . "a0", $_POST)) {
                            if ($_POST[$basic_tok . "a0"] == "1") {
                                $send_ok = 1;
                            }
                        }
                        if ($send_ok) {
                            $_SESSION["read"] = 1;
                        }
                        break;
                    case "ob":
                        $send_ok = update($device, $basic_tok);
                        # any change will generate a send
                        if (!array_key_exists($basic_tok . "b0", $_SESSION["actual_data"][$device])) {
                            # one element only
                            $des_type = explode(";", $_SESSION["des_type"][$device][$basic_tok . "x1"][0])[0];
                            $length = length_of_type($des_type);
                            $send .= "0100" . translate_dec_to_hex($basic_tok, $des_type, $_SESSION["actual_data"][$device][$basic_tok . "x1"], $length);
                        } else {
                            $number = $_SESSION["actual_data"][$device][$basic_tok . "b0"];
                            if ($number > 0) {
                                $send .= translate_dec_to_hex($basic_tok, "n", $number, 2);
                                $start = retranslate_simple_range(explode(",", $_SESSION["des_range"][$device][$basic_tok . "b1"]), $_SESSION["actual_data"][$device][$basic_tok . "b1"], 2);
                                $send .= translate_dec_to_hex($basic_tok, "n", $start, 2);
                                $i = 0;
                                $j = $start + 1;
                                while ($i < $number) {
                                    $tok = $basic_tok . "d" . $j;
                                    if (!array_key_exists($tok, $_SESSION["actual_data"][$device])) {
                                        # continue at first element
                                        $j = 1;
                                        $tok = $basic_tok . "x1";
                                    }
                                    $des_type = explode(";", $_SESSION["des_type"][$device][$tok][0])[0];
                                    $length = length_of_type($des_type);
                                    $send .= translate_dec_to_hex($basic_tok, $des_type, $_SESSION["actual_data"][$device][$tok], $length);
                                    $i += 1;
                                }
                                # reset to 0 again
                                $_SESSION["actual_data"][$device][$basic_tok . "b0"] = 0;
                                $send_ok = 1;
                            } else {
                                $send_ok = 0;
                            }
                        }
                        break;
                    case "ab":
                        $send_ok_ = update($device, $basic_tok);
                        $b0 = $basic_tok . "b0";
                        $b1 = $basic_tok . "b1";
                        if (array_key_exists($basic_tok . "a0", $_POST)) {
                            if ($_POST[$basic_tok . "a0"] == "1") {
                                if (!array_key_exists($b0, $_SESSION["actual_data"][$device])) {
                                    # one element only
                                    send_to_device($send . "0100");
                                } else {
                                    $number = $_SESSION["actual_data"][$device][$b0];
                                    if ($number > 0) {
                                        $send .= translate_dec_to_hex($basic_tok, "n", $number, 2);
                                        # pos of elements
                                        if (array_key_exists($b1, $_SESSION["actual_data"][$device])) {
                                            $pos = $_SESSION["actual_data"][$device][$b1];
                                            $send .= translate_dec_to_hex($basic_tok, "n", $pos, 2);
                                        }
                                        $send_ok = 1;
                                        $_SESSION["read"] = 1;
                                        send_to_device($send);
                                    }
                                }
                            }
                        }
                        break;
                }
            }
            if ($send_ok){send_to_device($send);}
            $already_done[$basic_tok] = 1;
            $send_ok  = 0;
        }
    }
}

function change_as_data($tok){
    # change answer data as well
    if (array_key_exists($tok, $_SESSION["o_to_a"])) {
        $_SESSION["actual_data"][$_SESSION["device"][$_SESSION["o_to_a"]][$tok]] = $_SESSION["actual_data"][$_SESSION["device"]][$tok];
    }
}

function update_one($token, $send, $property_len_pos){
    # update one and add to send
    # return $send, $change_found
    $device = $_SESSION["device"];
    $change_found = 0;
    if (array_key_exists($token, $_SESSION["corrected_POST"][$device])) {
        $change_found = update_one_only($token);
        $send .= dec_hex($_SESSION["actual_data"][$device][$token], $_SESSION["property_len"][$device][basic_tok($token)][$property_len_pos]);
    }
    return [$send, $change_found];
}

function update_one_only($token){
    # update one
    # return $change_found
    $device = $_SESSION["device"];
    $change_found = 0;
    if (array_key_exists($token, $_SESSION["corrected_POST"][$device])) {
        $data = $_SESSION["corrected_POST"][$device][$token];
        if ($_SESSION["actual_data"][$device][$token] != $data and $data != "") {
            $_SESSION["actual_data"][$device][$token] = $data;
            $change_found = 1;
        }
    }
    return $change_found;
}

function update($device, $basic_tok){
    # check all
    # for memories only for d and m and n token
    $send_ok = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token){
        if (strstr($c_token, "m") or (strstr($c_token, "d") and !strstr($c_token, "d0"))) {
            $send_ok = update_one($c_token);
        }
    }
    return $send_ok;
}

function calculate_pos_hex($basic_tok, $on_an_adder){
    # for position for momory commands
    # for 3 dimensions: z = n_x*my*mz + n_y*mz + nz
    $device = $_SESSION["device"];
    $maxmax = 1;
    $max = [];
    $i = 0;
    $adder_exist = 0;
    # max of 0,0,1,1,2,2,... max,max for eaxh b token:
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "m")) {
            # for on / an b0 is number of elements
            if ($on_an_adder and $token == $basic_tok . "b0") {
                $i += 1;
                continue;
            }
            if (array_key_exists( $basic_tok, $_SESSION["adder_token"][$device])){
                if ($token == $_SESSION["adder_token"][$device][$basic_tok]) {
                    # not for adder
                    $i += 1;
                    $adder_exist = $token;
                    continue;
                }
            }
            $positions = explode(",", $_SESSION["des_range"][$device][$basic_tok . "m" . $i]);
            $max_ = (int)(count($positions) / 2);
            $max[] = $max_;
            # for ADD:
            $maxmax *= $max_;
            $i += 1;
        }
    }
    # max length of pos:
    $length = $_SESSION["property_len"][$device][$basic_tok][2];
    if ($adder_exist){
        $pos = $maxmax + $_SESSION["actual_data"][$device][$token];
    }
    else{
        $maxcount = count($max) - 1;
        $pos = 0;
        foreach ($_SESSION["cor_token"][$device][$basic_tok] as $key => $token) {
            if (strstr($token, "m")) {
                if ($on_an_adder and $token == $basic_tok . "b0") {
                    # skip number of elements
                    continue;
                }
                if (array_key_exists($token, $_SESSION["adder_token"][$device])) {
                    # not for adder
                    continue;
                }
                $val = $_SESSION["actual_data"][$device][$token];
                # after "m" tok a "d" tok is following always
                $temp = $_SESSION["cor_token"][$device][$basic_tok][$key + 1];
                if (strstr($temp, "d")) {
                    if (array_key_exists($basic_tok, $_SESSION["adder_token"][$device])) {
                        if ($val != 0 and $token == $_SESSION["adder_token"][$device][$basic_tok]) {
                            $pos = $maxmax + $val;
                        }
                    } else {
                        $pos += $val;
                    }
                } else {
                    $pos += $val * $max[$maxcount - 1];
                }
                $maxcount -= 1;
            }
        }
    }
    return translate_dec_to_hex($basic_tok,"n", $pos, $length);
}

function handle_stacks($basic_tok, $send, $senda){
    # if stack is modified: update actual_data for stacks
    # add stack to send
    # return: send, change_found
    $change_found = 0;
    $device = $_SESSION["device"];
    # do nothing, if stacks == 1
    if (explode(",", $_SESSION["original_announce"][$device][$basic_tok][1])[0] == 1){
        return [$send, $senda, $change_found];
    }
    $stack = 0;
    if (array_key_exists($basic_tok, $_SESSION["a_to_o"][$device])) {
        # use all (identical) data of corresponding o token
        $basic_tok = $_SESSION["a_to_o"][$device][$basic_tok];
    }
    # the key of the number_of_selects array is 0, 1, ... (as tokenbx)
    # the transmitted values count over the different (MUL/ADD) display stack-parts:
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token) {
        # all m and n token only
        if (strstr($c_token, "m") or strstr($c_token, "n")) {
            if (array_key_exists($c_token, $_SESSION["corrected_POST"][$device])) {
                if ($_SESSION["corrected_POST"][$device][$c_token] != $_SESSION["actual_data"][$device][$c_token]) {
                    $_SESSION["actual_data"][$device][$c_token] = $_SESSION["corrected_POST"][$device][$c_token];
                    $change_found = 1;
                    # change answer / operate as well
                    $other_tok = 0;
                    if (strstr($c_token, "m")) {
                        $subtoken = explode("m", $c_token)[1];
                    }
                    else{
                        $subtoken = explode("n", $c_token)[1];
                    }
                    # if a anwer -tok is avalable , one will work:
                    if (array_key_exists($basic_tok, $_SESSION["a_to_o"][$device])) {
                        $other_tok = $_SESSION["a_to_o"][$device][$basic_tok];
                    }
                    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])) {
                        $other_tok = $_SESSION["o_to_a"][$device][$basic_tok];
                    }
                    if ($other_tok != 0) {
                        $tok = $other_tok . "m" . $subtoken;
                        $_SESSION["actual_data"][$device][$tok] = $_SESSION["actual_data"][$device][$c_token];
                    }
                }
            }
        }
    }
    # actual stack:
    $i = 0;
    $max_for_add = 1;
    $lastmulti = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token) {
        # all m and n token only
        if (strstr($c_token, "m") or strstr($c_token, "n")) {
            if (strstr($c_token, "m")) {
                $stack *= $lastmulti;
                $stack += $_SESSION["actual_data"][$device][$c_token];
                $lastmulti = $_SESSION["max_for_send"][$device][$c_token];
                $max_for_add *= $lastmulti;
            }
            else {
                # ADD available
                if ($_SESSION["actual_data"][$device][$c_token] != 0) {
                    $stack = $max_for_add + $_SESSION["actual_data"][$device][$c_token];
                }
            }
        }
        $i += 1;
    }
    $send .= dec_hex($stack, $_SESSION["property_len"][$device][$basic_tok][1]);
    $senda .= dec_hex($stack, $_SESSION["property_len"][$device][$basic_tok][1]);
    return [$send, $senda, $change_found];
}


function check_a_in_POST($basic_tok){
    # check , if "a"token is of corresponding tok is activ in corrected_POST
    # return a token
    $device = $_SESSION["device"];
    $a_found = 0;
    if (array_key_exists($basic_tok, $_SESSION["a_to_o"][$device])){
        $as_token = $_SESSION["a_to_o"][$device][$basic_tok];
        if (array_key_exists($as_token, $_SESSION["corrected_POST"][$device])){
            if ($_SESSION["corrected_POST"][$device][$as_token] == 1) {
                $a_found = $as_token;
            }
        }
    }
    return $a_found;
}

function send_to_device($send){
    print (" send: ". $send);
    serial_write($send);
}

<?php
# send_and_update.php
# DK1RI 20230327
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function send_and_update(){
    # input:  $_SESSION["corrected_POST"]
    # output:  $_SESSION["actual_data"][$device]
    # output: $send  (hex string -> to device)
    # $_SESSION["corrected_POST"]:
    # for xs xt xu : string (always)
    # for or : array with numbers of changed fields (only, if changed)
    #
    # this is the actual device
    $device = $_SESSION["device"];
    $announce = $_SESSION["announce_all"][$device];
    $allready_done = -1;
    foreach ($_SESSION["corrected_POST"][$device] as $tok => $value) {
        # interface.. name .... device is updated in correct_POST
        if (array_key_exists($tok, $announce)) {
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
                        if (array_key_exists($basic_tok . "a0", $_POST)) {
                            if ($_POST[$basic_tok. "a0"] == "1") {
                                $send_ok = 1;
                                $_SESSION["read"] = 1;
                            }
                        }
                        break;
                    case "os":
                        list($answer_sent,$a0_exist) = update_stack_b($basic_tok , 0);
                        if ($answer_sent){
                            # possible changes of switches are ignored:
                            continue 2;
                        }
                        # no stack change
                        $send_ok = 0;
                        if ($a0_exist) {
                            if(array_key_exists($a0_exist,$_SESSION["corrected_POST"][$device])){
                                if ($_SESSION["corrected_POST"][$device][$a0_exist] == 1) {
                                    $send = $_SESSION["tok_hex"][$device][basic_tok($a0_exist)];
                                    $send .= handle_stacks($basic_tok);
                                    $send_ok = 1;
                                }
                            }
                        }
                        $send_ok_ = update_one($basic_tok. "x0");
                        if ($send_ok_) {
                            $send .= handle_stacks($basic_tok);
                            $send .= dec_hex($_SESSION["actual_data"][$device][$basic_tok . "x0"], $_SESSION["property_len"][$device][$basic_tok][2]);
                            $send_ok = 1;
                        }
                        break;
                    case "as":
                    case "at":
                        list($answer_sent,$a0_exist) = update_stack_b($basic_tok, 0);
                        if ($answer_sent){
                            # possible changes of switches are ignored:
                            continue 2;
                        }
                        # no stack change
                        if ($a0_exist) {
                            if(array_key_exists($a0_exist,$_SESSION["corrected_POST"][$device])){
                                if ($_SESSION["corrected_POST"][$device][$a0_exist] == 1) {
                                    $send = $_SESSION["tok_hex"][$device][basic_tok($a0_exist)];
                                    $send .= handle_stacks($basic_tok);
                                    $send_ok = 1;
                                    $_SESSION["read"] = 1;
                                }
                            }
                        }
                        break;
                    case "or":
                    case "ar":
                        # $_POST delivers 0 or "on" for all checkbox token
                        # this is reached once only per basic_tok !
                        list($answer_sent,$a0_exist) = update_stack_b($basic_tok, 1);
                        if ($answer_sent){
                            # possible changes of switches are ignored:
                            continue 2;
                        }
                        # no stack change
                        $add = "";
                        $no_stack = 1;
                        $send_ = "";
                        foreach ($_SESSION["corrected_POST"][$device] as $tok1 => $value1) {
                            # for $actual $basic_tok only
                            if ($basic_tok == basic_tok($tok1)) {
                                if (strstr($tok1, "x")) {
                                    if ($_SESSION["corrected_POST"][$device][$tok1] == "on") {
                                        if ($no_stack) {
                                            $send_ = $send . handle_stacks(basic_tok($tok1));
                                            $no_stack = 0;
                                        }
                                        $position = explode("x", $tok1)[1];
                                        # small values assumed only:
                                        $send = $send_ . dec_hex($position, 2);
                                        if($a0_exist or  $ct == "ar"){
                                            # no stack change but answer for selected switches
                                            # read without data
                                            $_SESSION["read"] = 1;
                                        }
                                        else {
                                            # now the changes, toggle for operating
                                            # add data
                                            if ($_SESSION["actual_data"][$device][$tok1] == "0") {
                                                $add = "01";
                                                $_SESSION["actual_data"][$device][$tok1] = "1";
                                            } else {
                                                $add = "00";
                                                $_SESSION["actual_data"][$device][$tok1] = "0";
                                            }
                                        }
                                        send_to_device($send . $add);
                                    }
                                }
                            }
                        }
                        # no further send:
                        $send_ok = 0;
                        break;
                    case "ou":
                        list($answer_sent,$a0_exist) = update_stack_b($basic_tok, 0);
                        if ($answer_sent){
                            # possible changes of switches are ignored:
                            continue 2;
                        }
                        # no stack change
                        $add = "";
                        $send_ok = update_one($basic_tok. "x0");
                        $x0 = $basic_tok . "x0";
                        # send, if one value only or one selected (no send with change of stack only)
                        if (array_key_exists($x0, $_SESSION["corrected_POST"][$device])) {
                            if ($_SESSION["corrected_POST"][$device][$x0] != 0) {
                                if (count($_SESSION["announce_all"]) > 2) {
                                    $add .= $_SESSION["corrected_POST"][$device][$x0] - 1;
                                }
                                $send_ok = 1;
                            }
                        }
                        if ($send_ok){
                            $send .= handle_stacks($basic_tok);
                            $send .= $add;
                        }
                        break;
                    case "op":
                        list($answer_sent,$a0_exist) = update_stack_b($basic_tok, 0);
                        if ($answer_sent){
                            # possible changes of ranges are ignored:
                            continue 2;
                        }
                        # no stack change
                        $send_ok = update_x($device, $basic_tok);
                        # stack:
                        $send .= handle_stacks($basic_tok);
                        if ($send_ok != 0){
                            foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
                                if (basic_tok($tok) == $basic_tok) {
                                    # not "oo" commands!
                                    if (!(strstr($tok, "b") or strstr($tok, "x0"))) {
                                        # not "x0"
                                        $max = $_SESSION["announce_all"][$device][$tok][1];
                                        $range = explode(",",$_SESSION["des_range"][$device][$tok]);
                                        if ($max < 256){
                                            $value = retranslate_simple_range($range, $_SESSION["actual_data"][$device][$tok], 2);
                                        }
                                        else{
                                            $value = retranslate_full($tok, $_SESSION["actual_data"][$device][$tok]);
                                        }
                                        $length = $_SESSION["property_len"][$device][$basic_tok][2];
                                        $send .= translate_dec_to_hex($basic_tok,"n", $value, $length);
                                    }
                                }
                            }
                        }
                        break;
                    case "oo":
                        if($_SESSION["corrected_POST"][$device][$tok] == "set_def"){
                            $send .= "000000";
                            $send_ok = 1;
                        }
                        else {
                            $send_ok = update_x($device, $basic_tok);
                            if ($_SESSION["actual_data"][$device][$basic_tok . "x1r"] == "0") {
                                # do not send
                                break;
                            } else {
                                # stack:
                                $send .= handle_stacks($basic_tok);
                                # data:
                                $add = 0;
                                foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
                                    if (!(strstr($tok, "b") or strstr($tok, "x0"))) {
                                        if (strstr($tok, "r")) {
                                            if ($_SESSION["actual_data"][$device][$tok] == 0) {
                                                $send_ok = 0;
                                            } else {
                                                $add = -1;
                                            }
                                        }
                                        $length = $_SESSION["property_len"][$device][$basic_tok][2];
                                        $send .= translate_dec_to_hex($basic_tok,"n", $_SESSION["actual_data"][$device][$tok] + $add, $length);
                                    }
                                }
                                # set to idle again
                                $_SESSION["actual_data"][$device][$basic_tok . "x1r"] = "0";
                            }
                        }
                        break;
                    case "ap":
                        list($answer_sent,$a0_exist) = update_stack_b($basic_tok, 0);
                        if ($answer_sent){
                            # possible changes of ranges are ignored:
                            continue 2;
                        }
                        # no stack change
                        $send_ok = update_one( $basic_tok."x0");
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
                        $send_ok = check_a0_in_POST($basic_tok);
                        if ($send_ok) {
                            $send_ok = update($device, $basic_tok);
                            if ($send_ok) {
                                # position
                                $send .= calculate_pos_hex($basic_tok, 0);
                                # data
                                $des_type = explode(";", $_SESSION["des_type"][$device][$basic_tok . "x1"]);
                                $send .= translate_dec_to_hex($basic_tok,$des_type[0], $_SESSION["actual_data"][$device][$basic_tok . "x1"], $des_type[0]);
                            }
                        }
                        break;
                    case "am":
                        $send_ok = update($device, $basic_tok);
                        if(array_key_exists($basic_tok. "a0", $_POST)){
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
                            $data .= translate_dec_to_hex($basic_tok,"n", $no_element, $length);
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
                        if(array_key_exists($basic_tok. "a0", $_POST)){
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
                        foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token){
                            if (strstr($c_token,"x")){
                                if (array_key_exists($c_token, $_SESSION["corrected_POST"][$device])){
                                    if ($_SESSION["corrected_POST"][$device][$c_token] != "") {
                                        if ($_SESSION["corrected_POST"][$device][$c_token] != $_SESSION["actual_data"][$device][$c_token]) {
                                            # position:
                                            $send_a = $send;
                                            if (array_key_exists($b1, $_SESSION["actual_data"][$device])) {
                                                $pos = explode("x",$c_token)[1] - 1;
                                                $send_a .= translate_dec_to_hex($basic_tok,"n", $pos, 2);
                                            }
                                            $des_type = explode(";",$_SESSION["des_type"][$device][$c_token]);
                                            $length = length_of_type($des_type[$pos]);
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
                        if (array_key_exists($b1, $_SESSION["actual_data"][$device])){
                            $pos = $_SESSION["actual_data"][$device][$b1];
                            $send .= translate_dec_to_hex($basic_tok,"n", $pos, 2);
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
                        if (!array_key_exists($basic_tok."b0", $_SESSION["actual_data"][$device])){
                            # one element only
                            $des_type = explode(";", $_SESSION["des_type"][$device][$basic_tok. "x1"][0])[0];
                            $length = length_of_type($des_type);
                            $send .= "0100" . translate_dec_to_hex($basic_tok,$des_type, $_SESSION["actual_data"][$device][$basic_tok. "x1"], $length);
                        }
                        else{
                            $number = $_SESSION["actual_data"][$device][$basic_tok. "b0"];
                            if ($number > 0) {
                                $send .= translate_dec_to_hex($basic_tok,"n", $number, 2);
                                $start = retranslate_simple_range(explode(",",$_SESSION["des_range"][$device][$basic_tok."b1"]), $_SESSION["actual_data"][$device][$basic_tok . "b1"], 2);
                                $send .= translate_dec_to_hex($basic_tok,"n", $start, 2);
                                $i = 0;
                                $j = $start + 1;
                                while ($i < $number) {
                                    $tok = $basic_tok . "x" . $j;
                                    if (!array_key_exists($tok, $_SESSION["actual_data"][$device])){
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
                                $_SESSION["actual_data"][$device][$basic_tok. "b0"] = 0;
                                $send_ok = 1;
                            }
                            else {
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
                                }
                                else {
                                    $number = $_SESSION["actual_data"][$device][$b0];
                                    if ($number > 0) {
                                        $send .= translate_dec_to_hex($basic_tok,"n", $number, 2);
                                        # pos of elements
                                        if (array_key_exists($b1, $_SESSION["actual_data"][$device])) {
                                            $pos = $_SESSION["actual_data"][$device][$b1];
                                            $send .= translate_dec_to_hex($basic_tok,"n", $pos, 2);
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
                if ($send_ok){send_to_device($send);}
                $allready_done = $basic_tok;
            }
        }
    }
}

function update_one($token){
    $device = $_SESSION["device"];
    $send_ok = 0;
    if (array_key_exists($token, $_SESSION["corrected_POST"][$device])) {
        $data = $_SESSION["corrected_POST"][$device][$token];
        if ($_SESSION["actual_data"][$device][$token] != $data and $data != "") {
            if (!strstr($token, "a")) {
                # do not update the answer token
                $_SESSION["actual_data"][$device][$token] = $data;
                # copy actual for "b" token (memoryposition) to corresponding "as" baisc_toks
                if (array_key_exists(basic_tok($token), $_SESSION["as_token_as_to_basic"][$device])){
                    $basic_as_token =  $_SESSION["as_token_as_to_basic"][$device][basic_tok($token)];
                    if (count(explode("b",$token)) > 1){
                        $as_token = $basic_as_token . "b" . explode("b",$token)[1];
                        $_SESSION["actual_data"][$device][$as_token] = $data;
                    }
                }
            }
            $send_ok = 1;
        }
    }
    return $send_ok;
}

function update_x($device, $basic_tok){
    # for all x token with identical basic_tok
    $send_ok = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token){
        if (strstr($token, "x")) {
            if (basic_tok($token) == $basic_tok) {
                $send_ok_ = update_one($token);
                if ($send_ok_) {
                    $send_ok = 1;
                }
            }
        }
    }
    return $send_ok;
}

function update($device, $basic_tok){
    # check all
    # for memories only for x and b token
    $send_ok = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token){
        if (strstr($c_token, "b") or (strstr($c_token, "x") and !strstr($c_token, "x0"))) {
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
        if (strstr($token, "b")) {
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
            $positions = explode(",", $_SESSION["des_range"][$device][$basic_tok . "b" . $i]);
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
            if (strstr($token, "b")) {
                if ($on_an_adder and $token == $basic_tok . "b0") {
                    # skip number of elements
                    continue;
                }
                if (array_key_exists($token, $_SESSION["adder_token"][$device])) {
                    # not for adder
                    continue;
                }
                $val = $_SESSION["actual_data"][$device][$token];
                # after "b" tok a "x" tok is following always
                $temp = $_SESSION["cor_token"][$device][$basic_tok][$key + 1];
                if (strstr($temp, "x")) {
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

function handle_stacks($basic_tok){
    $device = $_SESSION["device"];
    # send only, if stacks > 1
    if (explode(",", $_SESSION["original_announce"][$device][$basic_tok][1])[0] == 1){
        return "";
    }
    $stack = "";
    $multiplier = 1;
    # the key of the number_of_selects array is 0, 1, ... (as tokenbx)
    $stack_display_number = 0;
    # the transmitted values count over the different (MUL/ADD) display stack-parts:
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token) {
        # avoid oo token for op token
        if (basic_tok($c_token) == $basic_tok){continue;}
        $actual_value = (int)$_SESSION["actual_data"][$device][$c_token];
        if (strstr($c_token,"b")){
            # $nr: 0, 1, ...
            $des = explode(",", $_SESSION["des_range"][$device][$c_token]);
            $_max_stack_per_tok = count($des) / 2;
            # _: Multiplier
            $multiplier *= $_max_stack_per_tok;
            if ($stack_display_number == 0) {
                $stack = $actual_value;
            }
            else {
                $stack = $stack * $_max_stack_per_tok + $actual_value;
            }
            $stack_display_number += 1;
        }
        elseif (strstr($c_token,"c")) {
             # adder (follow the "b" tokens)
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

function update_stack_b($basic_tok, $pos){
    # for stacks: if stackschange is found, read command for all "x"token is sent
    # if a readcommand is available
    $device = $_SESSION["device"];
    $a0_exist = "";
    $answer_sent = 0;
    $send_ok = 0;
    if (explode(",", $_SESSION["original_announce"][$device][$basic_tok][0])[0] == "oo"){
        return["",""];
    }
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $value) {
        if (strstr($value, "a0")) {
            $a0_exist = $value;
        }
    }
    foreach ($_SESSION["corrected_POST"][$device] as $tok1 => $value1) {
        # for $actual $basic_tok only
        if ($basic_tok == basic_tok($tok1) and (strstr($tok1, "b") or strstr($tok1, "c"))) {
            $send_ok_ = update_one($tok1);
            if ($send_ok_){$send_ok = 1;};
        }
    }
    if($send_ok) {
        if($a0_exist != "") {
            $no_stack = 1;
            $send_ = "";
            # a change of stack result in a read of all, answer-command available
            $position = "";
            $send = $_SESSION["tok_hex"][$device][basic_tok($a0_exist)];
            foreach ($_SESSION["announce_all"][$device] as $tok1 => $value1) {
                if ($basic_tok == basic_tok($tok1) and strstr($tok1, "x")) {
                    if ($no_stack) {
                        $send_ = $send . handle_stacks(basic_tok($tok1));
                        $no_stack = 0;
                    }
                    if ($pos) {
                        $position = dec_hex(explode("x", $tok1)[1], 2);
                    }
                    $_SESSION["read"] = 1;
                    send_to_device($send_ . $position);
                }
            }
            # possible changes of switches are ignored:
            $answer_sent = 1;
        }
    }
    return [$answer_sent, $a0_exist];
}
function check_a0_in_POST($basic_tok){
    # do not send, if "a0"token is activ in _POST
    $device = $_SESSION["device"];
    $send_ok = 1;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token){
        if(strstr($c_token," a0")) {
            if (array_key_exists($c_token, $_POST)) {
                if ($_POST[$c_token] == 1) {
                    $send_ok = 0;
                }
            }
        }
    }
    return $send_ok;
}

function send_to_device($send){
    print (" send: ". $send);
    serial_write($send);
}

<?php
# send_and_update.php
# DK1RI 20230621
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function send_and_update(){
    # input:  $_SESSION["corrected_POST"]
    # output:  $_SESSION["actual_data"][$device]
    # output: $send  (hex string -> to device)
    # $_SESSION["corrected_POST"]:
    # for or : array with numbers of changed fields (only, if changed)
    #
    $device = $_SESSION["device"];
    $already_done = [];
    $_SESSION["read"] = 0;
    foreach ($_SESSION["corrected_POST"][$device] as $tok => $value) {
        # interface.. name .... device is updated in correct_POST
        # values of ($_SESSION["corrected_POST"][$device] are correct (updated by correct_POST before)
        if (!array_key_exists($tok, $_SESSION["special_token"][$device])){
            $send = "";
            $send_ok = 0;
            $basic_tok = basic_tok($tok);
            if (!array_key_exists($basic_tok, $already_done)) {
                # every $basic_tok is handled once only
                # different $tok with same $basic_tok in $_SESSION["corrected_POST"] are handled with the first $tok found
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
                        if (array_key_exists($basic_tok . "a", $_POST)) {
                            if ($_POST[$basic_tok . "a"] == "1") {
                                $send_ok = 1;
                                $_SESSION["read"] = 1;
                            }
                        }
                        break;
                    case "os":
                        list($send, $send_ok) = send_os($basic_tok, $send, $senda);
                        break;
                    case "as":
                    case "at":
                        list($send, $send_ok) = send_asat($basic_tok, $send, $senda);
                        break;
                    case "or":
                        list($send, $send_ok) = send_or($basic_tok, $send, $senda);
                        # no further send:
                        break;
                    case "ar":
                        list($send, $send_ok) = send_ar($basic_tok, $send, $senda);
                        break;
                    case "ou":
                        list($send, $send_ok) = send_u($basic_tok, $send, $senda);
                        break;
                    case "op":
                        list($send, $send_ok) = send_op($basic_tok, $send, $senda);
                        break;
                    case "oo":
                        list($send, $send_ok) = send_oo($basic_tok, $send, $senda);
                        break;
                    case "ap":
                        list($send, $send_ok) = send_ap($basic_tok, $send, $senda);
                        break;
                    case "om":
                        list($send, $send_ok) = send_om($basic_tok, $send, $senda);
                        break;
                    case "am":
                        list($send, $send_ok) = send_am($basic_tok, $send, $senda);
                        break;
                    case "on":
                        list($send, $send_ok) = send_on($basic_tok, $send, $senda);
                        break;
                    case "an":
                        list($send, $send_ok) = send_an($basic_tok, $send);
                        break;
                    case "of":
                        list($send, $send_ok) = send_of($basic_tok, $send, $senda);
                        break;
                    case "af":
                        list($send, $send_ok) = send_af($basic_tok, $send);
                        break;
                    case "oa":
                        list($send, $send_ok) = send_oa($basic_tok, $send);
                        break;
                    case "aa":
                        list($send, $send_ok) = send_aa($basic_tok, $send);
                        break;
                    case "ob":
                        list($send, $send_ok) = send_ob($basic_tok, $send);
                        break;
                    case "ab":
                        list($send, $send_ok) = send_ab($basic_tok, $send);
                        break;
                }
            }
            if ($send_ok){send_to_device($send);}
            $already_done[$basic_tok] = 1;
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
        if ($_SESSION["actual_data"][$device][$token] != $data) {
            $_SESSION["actual_data"][$device][$token] = $data;
            $change_found = 1;
        }
    }
    return $change_found;
}

function update($device, $basic_tok, $data_only){
    # for memories only for d and m and n token
    # $data_only = 0 : position...
    # $data_only = 1 : data
    # (position is necessary for read commands as well)
    $change_found_ = 0;
    $change_found = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token){
        if (!strstr($c_token, "a")) {
            if ($data_only == 0) {
                # position...
                if (!strstr($c_token, "d")) {
                    $change_found_ = update_one_only($c_token);
                }
            }
            elseif ($data_only == 1) {
                # data
                if (strstr($c_token, "d")) {
                    $change_found_ = update_one_only($c_token);
                }
            }
            elseif ($data_only == 2) {
                # position + data
                $change_found_ = update_one_only($c_token);
            }
            if ($change_found_) {
                $change_found = 1;
            }
        }
    }
    return $change_found;
}

function calculate_pos_from_actual_to_hex($basic_tok){
    $device = $_SESSION["device"];
    # ADD token ?
    $n_tok = "";
    if (array_key_exists($basic_tok. "n0", $_SESSION["actual_data"][$device])){
        $n_tok = $basic_tok. "n0";
        }
    elseif (array_key_exists($basic_tok. "n0", $_SESSION["actual_data"][$device])){
        # o /p commands
        $n_tok = $basic_tok. "d0";
    }
    if ($n_tok != ""){
        if (array_key_exists($n_tok, $_SESSION["max_for_ADD"])){
            if ($_SESSION["actual_data"][$device][$n_tok] != 0){
               $result = $_SESSION["max_for_ADD"][$n_tok] + $_SESSION["actual_data"][$device][$n_tok];
               return $result;
            }
        }
    }
    # other positions:
    $pos = 0;
    $multiplier = 1;

    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "m")) {
            $actual = $_SESSION["actual_data"][$device][$token];
            $pos *= $multiplier;
            $pos += $actual;
            $multiplier = $_SESSION["max_for_send"][$device][$token];
        }
    }
    # max length of pos:
    $length = $_SESSION["property_len"][$device][$basic_tok][2];
    $result = translate_dec_to_hex("n", $pos, $length);
    return $result;
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
                $stack += (int)$_SESSION["actual_data"][$device][$c_token];
                $lastmulti = (int)$_SESSION["max_for_send"][$device][$c_token];
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

function send_to_device($send){
    print (" send: ". $send);
    serial_write($send);
}

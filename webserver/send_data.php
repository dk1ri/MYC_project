<?php
function send_data(){
    #set multiple (or ar) to 0 if not in $_SESSION["corrected_POST"][$device] ($post_token)
    $device = $_SESSION["device"];
    $chapter = $_SESSION["chapter"];
    if (array_key_exists($device,$_SESSION["or_ar_tokens"]) != false){
        foreach ($_SESSION["or_ar_tokens"][$device] as $key_ => $tok) {
            if (array_key_exists($tok, $_SESSION["announce_lines"][$device][$chapter])) {
                if (!array_key_exists($tok, $_SESSION["correccted_POST"][$device])) {
                    # not in $_SESSION["corrected_POST"][$device]: set to 0
                    # corresponding selector tokens may exist
                    $selector_hex = calclate_actual_selector($tok);
                    foreach ($_SESSION["all_real_data"][$device] as $key_ => $value) {
                        if ($_SESSION["all_real_data"][$device][$key_] == 1) {
                            send_to_device($_SESSION["tok_hex"][$device][$key_] . $selector_hex . "00", 1, 0);
                        }
                    }
                }
            }
        }
    }
    $blocked = 0;
    foreach ($_SESSION["corrected_POST"][$device] as $key => $value) {
        print $key." ".$value." ";
        $found = 0;
        if (array_key_exists($key, $_SESSION["all_announce"][$device])) {
            $tok = basic_tok($key, "_");
            $t_tok = basic_tok($key, "a");
            $t_tok = basic_tok($key, "p");
            if ($t_tok == $key){
                # ou command without selector
                $ct = explode(",",$_SESSION["all_announce"][$device][$t_tok][0])[0];
                if ($ct == "ou" and $t_tok != $blocked){
                    send_by_ct($device, $t_tok, $value, $_SESSION["tok_hex"][$device][$key], 0);
                    $found = 1;
                }
            }
            if ($found == 0 and array_key_exists($key, $_SESSION["all_real_data"][$device])) {
                if (array_key_exists($tok, $_SESSION["sele_toks"][$device])) {
                    if ($blocked != $tok) {
                        # send command with selector and further block basic tok
                        $blocked = calculate_selector($device, $tok, $value);
                    }
                } else {
                    if ($blocked != $tok) {
                        # other commands without selector (not blocked)
                        send_by_ct($device, $tok, $value, $_SESSION["tok_hex"][$device][$tok], 0);
                    }
                }
            }
        }
    }
}

function send_by_ct($device, $tok, $value, $send, $send_ok){
    # adds data to send and send_to_device
    $len = strlen($send);
    $field = $_SESSION["all_announce"][$device][$tok];
    $ct = explode(",", $field[0])[0];
    switch ($ct) {
        case "os":
            if( $value != $_SESSION["all_real_data"][$device][$tok]) {
                $send .= dec_hex($value, 2);
                $send_ok = 1;
            } else {
                if  ($send_ok == 1) {
                    # selector modified but no data
                    # send command without data -> answer command
                    $_SESSION["read_data"] = 1;
                }
            }
            send_to_device($send, $send_ok, 0);
            break;
        case "as":
            send_to_device($send, 1, 0);
            $_SESSION["read_data"] = 1;
            break;
        case "or":
            if (count($field) == 3) {
                if (array_key_exists($tok, $_SESSION["corrected_POST"][$device])){
                    if ($_SESSION["all_real_data"][$device][$tok][0] == 0) {
                        $send .= "01";
                    } else {
                        $send .= "00";
                    }
                $send_ok = 1;
                } else {
                    if  ($send_ok == 1) {
                        # selector modified but no data
                        # send command without data -> answer command
                        $_SESSION["read_data"] = 1;
                    }
                }
                send_to_device($send, $send_ok, $len);
            } else {
                $i = 0;
                $send_tok = $send;
                $len = strlen($send);
                while ($i < count($_SESSION["all_real_data"][$device][$tok])) {
                    # all positions
                    $actual_on_off = $_SESSION["all_real_data"][$device][$tok][$i];
                    $send = $send_tok;
                    if (array_key_exists($tok, $_SESSION["corrected_POST"][$device])) {
                        # $_POST[$tok] show position, which are set
                        $found = 0;
                        foreach ($_SESSION["corrected_POST"][$device][$tok] as $keys => $value) {
                            if ($value == $i) {
                                # $_SESSION["corrected_POST"][$device] set a value to 1 if previously 0:
                                if ($actual_on_off == 0) {
                                    $send .= dec_hex($i, 2) . "01";
                                    $send_ok = 1;
                                    $found = 1;
                                    break;
                                }
                            }
                        }
                        if ($found == 0) {
                            # not in $_SESSION["corrected_POST"][$device]: set to 0
                            if ($actual_on_off == 1) {
                                $send .= dec_hex($i, 2) . "00";
                                $send_ok = 1;
                            }
                        }
                    }
                    send_to_device($send, $send_ok, $len);
                    $i += 1;
                }
            }
            break;
        case "ar":
            send_to_device($send, 1, 0);
            $_SESSION["read_data"] = 1;
            break;
        case "at":
            send_to_device($send, 1, 0);
            $_SESSION["read_data"] = 1;
            break;
        case "ou":
            $le = calculate_len(count($_SESSION["all_announce"][$device][$tok]) - 2);
            $send .= dec_hex($value, $le);
            send_to_device($send, 1, 0);
            break;
        case "op":
            $le = calculate_len(explode(",",$_SESSION["all_announce"][$device][$tok][3][0]));
            $i = 1;
            $s_value = 0;
            while ($i < $_SESSION["des"][$tok]) {
                if ($value < $_SESSION["des"][$tok][$i + 3]) {
                    $s_value += $_SESSION["des"][$tok][$i + 2];
                } else{
                    $s_value += $_SESSION["des"][$tok][$i + 3] - $_SESSION["des"][$tok][$i + 2];
                }
                $i += 4;
            }
            send_to_device($send.dec_hex($s_value,$le), 1, 0);
            break;
        case "ap":
            send_to_device($send, 1, 0);
            $_SESSION["read_data"] = 1;
            break;
    }
}

function calculate_selector($device, $tok, $value){
    # $tok is basictok of a selector
    # send the command
    # following selectors and command is blocked : same basictok (return_value = basictoken)
    $send = $_SESSION["tok_hex"][$device][$tok];
    $selector = 0;
    $send_ok = 0;
    $i = 0;
    $nuber_of_sel_toks = count($_SESSION["sele_toks"][$device][$tok]);
    foreach ($_SESSION["sele_toks"][$device][$tok] as $s_tok){
        if (isset($_SESSION["corrected_POST"][$device][$s_tok])){
            $sel_val = $_SESSION["corrected_POST"][$device][$s_tok];
            if ($sel_val != $_SESSION["all_real_data"][$_SESSION["device"]][$s_tok]){
                $send_ok = 1;
            }
        } else {
            $sel_val = $_SESSION["all_real_data"][$_SESSION["device"]][$s_tok];
        }
        if (strstr($s_tok, "a") != false){
            # if avalilable -> overwrite MUL is the last) if real != 0
            if ($sel_val != 0) {
                $selector = $_SESSION["maxsel"][$device][$tok] + $sel_val - 2;
            }
        } else {
            if (strstr($s_tok, "_") != false) {
                if ($i > 0) {
                    $selector = $selector * $_SESSION["number_of_selects"][$device][$tok][$i] + $sel_val;
                } else  {
                    $selector = $sel_val;
                }
            }
        }
        $i += 1;
    }
    $device = $_SESSION["device"];
    # now I have token + stacknumber (combination of selectors) to send:
    $send .= dec_hex($selector,$_SESSION["sel_len"][$device][$tok]);
    if (array_key_exists($tok, $_SESSION["corrected_POST"][$device]) == false){
        # basictok not in $_SESSION["corrected_POST"][$device]: send always answercommad
        if ($send_ok == 1) {
            send_to_device($send, 1, 0);
            $_SESSION["read_data"] = 1;
        }
    } else {
        send_by_ct($device, $tok, $_SESSION["corrected_POST"][$device][$tok], $send, $send_ok);
    }
    return $tok;
}


function send_to_device($send, $send_ok, $len){
    if  ($send_ok == 1 and strlen($send) > $len) {
        print " send: ";
        var_dump($send);
        print "<br>";
    }
}

function calclate_actual_selector($tok){
    #calculate the value of the selector from $_SESSION["all_real_data for send (->  in hex)
    # search corresponding toks
    $device = $_SESSION["device"];
    foreach ($_SESSION["all_announce"][$device] as $key => $value){
        $key_ = basic_tok($key,"_");
        $key_ = basic_tok($key_,"a");
        if ($tok == $key_){
            $all_toks[]= $key;
        }
    }
    foreach ($all_toks as $sel_tok){
        $value = 0;
        var_dump($_SESSION["all_real_data"][$device]);
        $v = $_SESSION["all_real_data"][$device][$sel_tok];
        if (strstr ($sel_tok, "_") != false) {
            if ($value == 0) {
                $value = $v;
            } else {
                $value *= $v;
            }
        }
        if (strstr($sel_tok, "a") != false){
            $value += $v;
        }
    }
    return dec_hex($value, calculate_len($_SESSION["all_announce"][$device][$tok][1]));
}
?>
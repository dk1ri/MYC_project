<?php
# send_and_update.php
# DK1RI 20221110
function send_and_update(){
    # $_SESSION["corrected_POST"] send:
    # for xs xt xu : string (always)
    # for or : aray with numebers of changed fields (only, if changed)
    $device = $_SESSION["device"];
    foreach ($_SESSION["corrected_POST"] as $key => $value) {
        if (!array_key_exists($key, $_SESSION["all_announce"][$device])) {
            # interface.. name ....
            if ($key == "name") {
                $_SESSION["name"] = $_POST["name"];
            }
            if ($key == "interface") {
                $_SESSION["interface"] = $_POST["interface"];
            }
            if ($key == "device") {
                $_SESSION["device"] = $_POST["device"];
            }
            if ($key == "chapter") {
                $_SESSION["chapter"] = $_POST["chapter"];
            }
        } else {
            # commands
            $basic_tok = basic_tok($key);
            if ($basic_tok != $key){
                continue;
            }
            # basic_toks only
            # corresponding toks are handled together with basic_tok
            $field = $_SESSION["all_announce"][$device][$basic_tok];
            $ct = explode(",", $field[0])[0];
            $send = dec_hex($basic_tok, $_SESSION["tok_len"][$device]);
            if ($ct == "at"){
                $ct = "ar";
            }
            switch ($ct) {
                case "os":
                    list($stack_value, $to_send) = handle_stacks($basic_tok);
                    $send = $send . $stack_value;
                    if (array_key_exists($basic_tok, $_SESSION["corrected_POST"])) {
                        # update, if available, (should be true always
                        if ($_SESSION["actual_data"][$device][$basic_tok][0] != $_SESSION["corrected_POST"][$basic_tok]) {
                            # update, if available
                            $_SESSION["actual_data"][$device][$basic_tok][0] = $_SESSION["corrected_POST"][$basic_tok];
                            $to_send = 1;
                        }
                    }
                    $send = $send . dec_hex($_SESSION["actual_data"][$device][$basic_tok][0], 2);
                    if ($to_send == 1){
                        send_to_device($send);
                        }
                    break;
                case "as":
                    list($stack_value, $to_send) = handle_stacks($basic_tok);
                    $send = $send . $stack_value;
                    if ($_SESSION["corrected_POST"][$basic_tok]){
                        $_SESSION["read_data"] = 1;
                        send_to_device($send);
                    }
                    break;
                case "or":
                    list($stack_value, $to_send) = handle_stacks($basic_tok);
                    $send = $send . $stack_value;
                    if (array_key_exists($basic_tok, $_SESSION["corrected_POST"])) {
                        $i = 0;
                        if (gettype($_SESSION["corrected_POST"][$basic_tok]) == "string") {
                            # on off switch
                            if ($_SESSION["actual_data"][$device][$basic_tok] == "on") {
                                $_SESSION["actual_data"][$device][$basic_tok] = "off";
                                $send .= "00";
                            }
                            else{
                                $_SESSION["actual_data"][$device][$basic_tok] = "on" ;
                                $send .= "01";
                            }
                            send_to_device($send);
                        } else {
                            var_dump($_SESSION["corrected_POST"][$basic_tok]);
                            var_dump($_SESSION["actual_data"][$device][$basic_tok]);
                            if ($_SESSION["actual_data"][$device][$basic_tok] != $_SESSION["corrected_POST"][$basic_tok]) {
                                while ($i < count($_SESSION["corrected_POST"][$basic_tok]) - 1) {
                                    $element = $_SESSION["corrected_POST"][$basic_tok][$i];
                                    if ($_SESSION["actual_data"][$device][$basic_tok][$element] == "0") {
                                        $_SESSION["actual_data"][$device][$basic_tok][$element] = "1";
                                    } else {
                                        $_SESSION["actual_data"][$device][$basic_tok][$element] = "0";
                                    }
                                    $i += 1;
                                    $send .= dec_hex($element, 2);
                                    $send .= dec_hex($_SESSION["actual_data"][$device][$basic_tok][$element], 2);
                                    if ($to_send == 1) {
                                        send_to_device($send);
                                    }
                                    $i += 1;
                                }
                            }
                        }
                    }
                    break;
                case "ar":
                    list($stack_value, $to_send) = handle_stacks($basic_tok);
                    $send = $send . $stack_value;
                    $_SESSION["read_data"] = 1;
                    if ($to_send == 1){
                        send_to_device($send);
                    }
                    break;
                case "ou":
                    list($stack_value, $to_send) = handle_stacks($basic_tok);
                    $send = $send . $stack_value;
                    if (array_key_exists($basic_tok, $_SESSION["corrected_POST"])) {
                        if ($_SESSION["actual_data"][$device][$basic_tok][0] != $_SESSION["corrected_POST"][$basic_tok][0]) {
                            $_SESSION["actual_data"][$device][$basic_tok][0] = $_SESSION["corrected_POST"][$basic_tok][0];
                            $to_send = 1;
                        }
                    }
                    if ($to_send == 1){
                        send_to_device($send);
                    }
                    break;
                case "op":
                    $le = calculate_len(explode(",", $_SESSION["all_announce"][$device][$basic_tok][3][0]));
                    $i = 1;
                    $s_value = 0;
                    while ($i < $_SESSION["des"][$basic_tok]) {
                        if ($value < $_SESSION["des"][$basic_tok][$i + 3]) {
                            $s_value += $_SESSION["des"][$basic_tok][$i + 2];
                        } else {
                            $s_value += $_SESSION["des"][$basic_tok][$i + 3] - $_SESSION["des"][$basic_tok][$i + 2];
                        }
                        $i += 4;
                    }
                    send_to_device($send . dec_hex($s_value, $le));
                    break;
                case "ap":
                    if ($to_send == 1){
                        send_to_device($send);
                    }
                    $_SESSION["read_data"] = 1;
                    break;
            }
        }
    }
}

function handle_stacks($basic_tok){
    $to_send = 0;
    $device = $_SESSION["device"];
    if (array_key_exists($basic_tok, $_SESSION["corresponding_tokens"][$_SESSION["device"]])) {
        # there are  more than one token
        # update corresponding toks and calculate stack
        $stack = 0;
        $multiplier = 1;
        # the key of the number_of_selects array is 0, 1, ...:
        $stack_length_number = 0;
        foreach ($_SESSION["corresponding_tokens"][$device][$basic_tok] as $nr => $c_token) {
            # $nr: 0, 1, ...
            $_max_stack_per_tok = $_SESSION["number_of_selects"][$device][$basic_tok][$stack_length_number];
            if (array_key_exists($c_token, $_SESSION["corrected_POST"])){
                # true always
                if ($_SESSION["actual_data"][$device][$c_token][0] != $_SESSION["corrected_POST"][$c_token]) {
                    # update if different
                    $_SESSION["actual_data"][$device][$c_token][0] = $_SESSION["corrected_POST"][$c_token];
                    $to_send = 1;
                }
                $actual_value = (int) $_SESSION["actual_data"][$device][$c_token][0];
                if (strstr($c_token,"_")) {
                    # _: Multiplier
                    $multiplier *= $_max_stack_per_tok;
                    if ($stack_length_number == 0){
                        $stack = $actual_value;
                    }
                    else {
                        $stack = $stack * $_max_stack_per_tok + $actual_value;
                    }
                }
                elseif (strstr($c_token,"a")) {
                    # a: adder
                    if($actual_value){
                        $stack = $multiplier + $actual_value;
                    }
                }
                else{
                    $stack = $actual_value;
                }
            }
            $stack_length_number += 1;
        }
        return [dec_hex($stack, $_SESSION["stack_len"][$device][$basic_tok]), $to_send];
    }
    else {
        return ["", $to_send];
    }
}

function send_to_device($send) {
    print " send: ";
    var_dump($send);
    print "<br>";
}

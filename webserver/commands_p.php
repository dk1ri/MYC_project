<?php
# commands_o.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function  create_op_oo($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='op'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])){
        # one or more stack display elements available
        selector($basic_tok);
    }
    echo "<br>";
    $reset_ignore = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "d")) {
            if ($_SESSION["announce_all"][$device][$tok][0] == "oo") {
                if (strstr($tok, "r")) {
                    if ($_SESSION["des"][$device][$tok] == 0) {
                        echo "<br>";
                        $reset_ignore = 1;
                        $tok_ = substr($tok, 0, strlen($tok) - 1);
                        if ($_SESSION["des"][$device][$tok_ . "s"] != "0" or $_SESSION["des"][$device][$tok_ . "t"] != "0") {
                            # reset to default
                            $label = $_SESSION["des_name"][$device][basic_tok($tok)];
                            echo $_SESSION["user"]["language"][$_SESSION["user"]["username"]]["set_default"] . ": " . $label . " ";
                            echo "<input type='checkbox' id=" . $tok . " name=" . $tok . " value=set_def>";
                        }
                        # else ignore this dimension
                    }
                }
            }
            else{
                $reset_ignore = 0;
            }
            if (!$reset_ignore){
                # "op" or other "oo"
                $des = explode(",", $_SESSION["des"][$device][$tok]);
                $max = $des[0];
                array_splice($des, 0, 1);
                if ($max < $_SESSION["conf"]["selector_limit"]) {
                    if (strstr($tok, "r")) {
                        echo "<br>";
                    }
                    $actual = $_SESSION["actual_data"][$device][$tok];
                    echo " " . $_SESSION["des_name"][$device][$tok] . ": ";
                    most_simple_selector($tok, $des, $actual);
                    if (strstr($tok, "t")) {
                        echo $_SESSION["unit"][$device][$tok] . " ";
                    }
                }
                else {
                    # > $_SESSION["conf"]["selector_limit"]
                    echo " new " . $_SESSION["des_name"][$device][$tok] . ": ";
                    echo "<input type='text' name = " . $tok . " size = 14 placeholder =" . $_SESSION["actual_data"][$device][$tok] . ">";
                }
                if (!strstr($tok, "r") and !strstr($tok, "s") and !strstr($tok, "t")) {
                    echo $_SESSION["unit"][$device][$tok] . "<br>";
                }
            }
        }
    }
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])) {
        display_as($_SESSION["o_to_a"][$device][$basic_tok]);
    }
    echo "</h3></div>";
}

function create_ap($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='ap'>";
    echo $_SESSION["des_name"][$device][$basic_tok]  . ": ";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more stack display elements available
        selector($basic_tok);
    }
    echo "read: <input type='checkbox' id=".$basic_tok."a" . " name=".$basic_tok."a value=1>";
    print "<br>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "d")) {
            #data
            echo $_SESSION["des_name"][$device][$tok] . ": ";
            echo $_SESSION["actual_data"][$device][$tok];
            echo " ".$_SESSION["unit"][$device][$tok]."<br>";
        }
    }
    echo "</h3></div>";
}

function correct_for_send_op($basic_tok){
    $device = $_SESSION["device"];
    check_send_if_a_exists($basic_tok);
    if ($_SESSION["send_ok"]) {$_SESSION["send_ok"] = check_send_if_change_of_actual_data($basic_tok);}
    $data = "";
    $change_found = 0;
    if ($_SESSION["send_ok"]) {
        foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
            if (basic_tok($tok) == $basic_tok) {
                # "op" commands are preferred!
                if (strstr($tok, "d")) {
                    if ($_POST[$tok]  != $_SESSION["actual_data"][$device][$tok]) {
                        $_SESSION["actual_data"][$device][$tok] = $_POST[$tok];
                        $length = $_SESSION["property_len"][$device][$basic_tok][2];
                        $data .= translate_dec_to_hex("n", $_SESSION["actual_data"][$device][$tok], $length);
                        $change_found = 1;
                    }
                }
            }
        }
        if ($change_found == 0){
            # if no op change only !
            foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
                if (basic_tok($tok) != $basic_tok) {
                    # "oo" commands!
                    if (strstr($tok, "d")) {
                        if ($_POST[$tok]  != $_SESSION["actual_data"][$device][$tok]) {
                            $_SESSION["actual_data"][$device][$tok] = $_POST[$tok];
                            $length = $_SESSION["property_len"][$device][$basic_tok][2];
                            $data .= translate_dec_to_hex("n", $_SESSION["actual_data"][$device][$tok], $length);
                            $change_found = 1;
                        }
                    }
                }
            }
        }
    }
    if ($_SESSION["send_ok"]) {
        list($stack, $stack_changed) = handle_stacks($basic_tok);
        if ($stack_changed or $change_found) {
            $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
            $send .= $stack;
            $send .= $data;
            $_SESSION["tok_to_send"][(int)$basic_tok] = 1;
            $_SESSION["send_string_by_tok"][$basic_tok] = $send;
        }
    }
}

function correct_for_send_ap($basic_tok){
    $device = $_SESSION["device"];
    $tok = $basic_tok . "a";
    if (array_key_exists($tok, $_POST) and  $_POST[$tok] == 1){
        list($stack, $stack_changed) = handle_stacks($basic_tok);
        $_SESSION["read"] = 1;
        $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
        $send .= $stack;
        $_SESSION["tok_to_send"][(int)$basic_tok] = 1;
        $_SESSION["send_string_by_tok"][$basic_tok]= $send;
    }
}

function receive_p($basic_tok, $from_device){
    $device = $_SESSION["device"];
    $stacklen = $_SESSION["property_len"][$device][$basic_tok][1];
    if ($stacklen > 0) {
        update_memory_position($basic_tok, $from_device);
        $from_device = substr($from_device,$stacklen);
    }
    $to_delete = 0;
    $i = 0;
    while (array_key_exists($basic_tok."d".$i, $_SESSION["announce_all"][$device])) {
        # for all dimensions
        # datalenth is the number of chars to delete
        $data_len = $_SESSION["property_len"][$device][$basic_tok][$i + 2];
        $data = substr($from_device, $to_delete,$data_len);
        $to_delete += $data_len;
        $data = (int)hexdec(retranslate_simple_range($basic_tok, $data));
        $_SESSION["actual_data"][$device][$basic_tok . "d".$i] = $data;
        update_corresponding_opererating($basic_tok, "d".$i, $data);
        $i += 1;
    }
    return $stacklen + $to_delete;
}
?>
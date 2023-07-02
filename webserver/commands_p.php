<?php
# commands_o.php
# DK1RI 20230621
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function  create_op_oo($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='op'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])){
        # one or more stack display elements available
        selector($basic_tok);
    }
    $count_zero = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "d")) {
            $des = explode(",",$_SESSION["des"][$device][$tok]);
            $max = $des[0];
            array_splice($des,0,1);
            if ($max < $_SESSION["conf"]["selector_limit"]) {
                if (strstr($tok,"r")){echo "<br>";}
                if ($des == 0) {
                    $label  = "?";
                    # for default 3 times a "0" will appear
                    $count_zero += 1;
                    if ($count_zero == 1){
                        if (array_key_exists($tok, $_SESSION["des_name"][$device])) {
                            $label = $_SESSION["des_name"][$device][$tok];
                        }
                    }
                    if ($count_zero == 3) {
                        echo $_SESSION["user"]["language"][$_SESSION["user"]["username"]]["set_default"] . ": " .$label. " ";
                        echo "<input type='checkbox' id=" . $tok." name=" . $tok . " value=set_def>";
                    }
                }
                else{
                    $actual = $_SESSION["actual_data"][$device][$tok];
                    echo " " . $_SESSION["des_name"][$device][$tok] . ": ";
                    most_simple_selector($tok, $des, $actual);
                    if (strstr($tok, "t")){echo $_SESSION["unit"][$device][$tok] . " ";}
                    if (!strstr($tok, "r") and !strstr($tok, "s") and !strstr($tok,"t")) {
                        echo $_SESSION["unit"][$device][$tok] . "<br>";
                    }
                    $count_zero = 0;
                }
            } else {
                # > $_SESSION["conf"]["selector_limit"]
                echo " new " . $_SESSION["des_name"][$device][$tok] . ": ";
                $actual_real = actual_data_to_real($tok);
                echo implode(",",$des). ": ";
                echo "<input type='text' name = " . $tok . " size = 14 placeholder =" . $actual_real . ">";
                if (strstr($tok, "t")){echo $_SESSION["unit"][$device][$tok]. " ";}
                if (!strstr($tok, "r") and !strstr($tok, "s") and !strstr($tok,"t")) {
                    echo $_SESSION["unit"][$device][$tok] . "<br>";
                }
            }
        }
    }
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok){
        if (strstr($tok, "a")) {
            display_as($tok, 0);
        }
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
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "d")) {
            $des = explode(",",$_SESSION["des"][$device][$tok]);
            array_splice($des,0,1);
            #data
            echo $_SESSION["des_name"][$device][$tok] . ": ";
            echo actual_data_to_real($tok);
            echo $_SESSION["unit"][$device][$tok]."<br>";
        }
    }
    echo "read: <input type='checkbox' id=".$basic_tok."a" . " name=".$basic_tok."a value=1>";
    echo "</h3></div>";
}

function send_op($basic_tok, $send, $senda){
    $device = $_SESSION["device"];
    $send_ok = 0;
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
                    $send .= translate_dec_to_hex("n", $_SESSION["actual_data"][$device][$tok], $length);
                }
            }
        }
        if ($change_found) {
            $send_ok = 1;
        }
    }
    return [$send, $send_ok];
}

function send_ap($basic_tok, $send, $senda){
    $send_ok = 0;
    $device = $_SESSION["device"];
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
    return [$send, $send_ok];
}

function send_oo($basic_tok, $send, $senda){
    $send_ok = 0;
    $device = $_SESSION["device"];
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
            $send .= translate_dec_to_hex("n", $_SESSION["actual_data"][$device][$tok] + $add, $length);
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
    return [$send, $send_ok];
}

 function receive_p($basic_tok, $stacks, $from_device){
     $device = $_SESSION["device"];
     $to_delete = 0;
    if ($stacks == 1){
        $i = 0;
        while (array_key_exists($basic_tok."d".$i, $_SESSION["announce_all"][$device])) {
            # for all dimensions
            # datalenth is the number of chars to delete
            $to_delete = $_SESSION["property_len"][$device][$basic_tok][$i + 2];
            $data = hexdec(substr($from_device, 0, $to_delete));
            $_SESSION["actual_data"][$device][$basic_tok . "d".$i] = $data;
            if (array_key_exists($basic_tok, $_SESSION["as_token"][$device])) {
                $org_token = $_SESSION["as_token"][$device][$basic_tok];
                $_SESSION["actual_data"][$device][$org_token . "x".$i] = $data;
            }
            $i += 1;
        }
    }
    else{
        read_to_stacks();
    }
    return $to_delete;
}
?>
<?php
# commands_s.php
# DK1RI 20230621
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function create_or($basic_tok){
    # selecting a switch as operate will toggle the status
    echo "<div><h3 class='or'>";
    create_or_ar($basic_tok);
    echo "</h3></div>";
}
function create_ar($basic_tok){
    # selecting a switch as operate will toggle the status
    echo "<div><h3 class='ar'>";
    create_or_ar($basic_tok);
    echo "</h3></div>";
}

function create_or_ar($basic_tok){
    # selecting a switch as operate will toggle the status
    $device = $_SESSION["device"];
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])){
        # one or more stack display elements available
        selector($basic_tok);
    }
    $announce = $_SESSION["original_announce"][$device][$basic_tok];
    echo "<br>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "d")) {
            $announce = $_SESSION["announce_all"][$device][$tok];
            $actual = $_SESSION["actual_data"][$device][$tok];
            if($actual == "0"){
                echo "<strong class = 'red'>";
            }
            else{
                echo "<strong class = 'green'>";
            }
            echo explode(",", $_SESSION["des"][$device][$tok])[1]. " ";
            echo "<input type='checkbox' name=" . $tok . " id=" . $tok . " label=" . $tok . ">";
        }
        echo "</strong>";
    }
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])) {
        display_as($_SESSION["o_to_a"][$device][$basic_tok]);
    }
}

function send_or($basic_tok, $send, $senda){
    $device = $_SESSION["device"];
    $send_ok = 0;
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
    return [$send, $send_ok];
}

function send_ar($basic_tok, $send, $senda){
    $device = $_SESSION["device"];
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
    return [$send, $send_ok];
}

function receive_r($basic_tok, $stacks, $from_device){
    $device = $_SESSION["device"];
    if ($stacks != 1) {
        read_to_stacks();
    }
    # 256 switch positions supported
    $position = hexdec(substr($from_device, 0, 2));
    $value = hexdec(substr($from_device, 2, 2));
    $_SESSION["actual_data"][$device][$basic_tok. "d".$position[0]] = $value;
    if (array_key_exists($basic_tok,$_SESSION["as_token"][$device])){
        $org_token = $_SESSION["as_token"][$device][$basic_tok];
        $_SESSION["actual_data"][$device][$org_token. "d".$position[0]] = $value;
        update_corresponding_opererating($basic_tok, "d".$position[0], $value);
    }
    return 4;
}
?>
<?php
# commands_b.php
# DK1RI 20230615
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function create_ob($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='ob'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ":<br>";
    $tok = $basic_tok. "m0";
    $range = explode(",", $_SESSION["des"][$device][$tok]);
    array_splice($range, 0, 1);
    if (count($range) > 2) {
        foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
            if (strstr($token, "m") or strstr($token, "o")) {
                if (strstr($token, "m")) {
                    echo "number of elements: ";
                } elseif (strstr($token, "o")) {
                    echo "start at: ";
                }
                simple_selector($token, $range, $_SESSION["actual_data"][$device][$token]);
                echo "<br>";
            }
        }
    }
    else {
        # one type of data
        echo find_name_of_type($_SESSION["type_for_memories"][$device][$basic_tok. "d0"]);
    }
    echo " ";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "d")) {
            # data
            echo "<input type=text name=" . $token . " size = 20  placeholder =" . $_SESSION["actual_data"][$device][$token] . "><br>";
        }
    }
    display_as($basic_tok. "a", 0);
    echo "</h3></div>";
}

function create_ab($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='ab'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    # number of elements
    $tok = $basic_tok. "m0";
    $range = explode(",", $_SESSION["des"][$device][$tok]);
    array_splice($range, 0, 1);
    if (count($range) > 2) {
        simple_selector($tok, $range, $_SESSION["actual_data"][$device][$tok]);
    }
    else {
        # one type of data
        echo find_name_of_type($_SESSION["type_for_memories"][$device][$basic_tok. "d0"]);
    }
    # start at
    $tok = $basic_tok. "o0";
    $range = explode(",", $_SESSION["des"][$device][$tok]);
    array_splice($range, 0, 1);
    if (count($range) > 2) {
        simple_selector($tok, $range, $_SESSION["actual_data"][$device][$tok]);
    }
    else {
        # one type of data
        echo find_name_of_type($_SESSION["type_for_memories"][$device][$basic_tok. "d0"]);
    }
    echo " ";
    # data
    $data = "";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "d")) {
            $data = $_SESSION["actual_data"][$device][$token] . ",";
        }
    }
    echo " <marquee>" . $data. "</marquee>";
    echo "<br>";
    display_as($basic_tok. "a", 1);
    echo "</h3></div>";
}

function send_ob($basic_tok, $send){
    $device = $_SESSION["device"];
    $send_ok = update($device, $basic_tok, 0);
    $tok = $basic_tok . "a";
    if (array_key_exists($tok, $_SESSION["corrected_POST"][$device]) and $_SESSION["corrected_POST"][$device][$tok] == 1) {
        # if answer set-> ignore change of data
        # position
        $send .= calculate_pos_from_actual_to_hex($basic_tok);
        $send_ok = 1;
        $_SESSION["read"] = 1;
    } else {
        $send_ok = update($device, $basic_tok, 1);

        if (!array_key_exists($basic_tok . "b0", $_SESSION["actual_data"][$device])) {
            # one element only
            $des_type = explode(";", $_SESSION["des_type"][$device][$basic_tok . "x1"][0])[0];
            $length = length_of_type($des_type);
            $send .= "0100" . translate_dec_to_hex($des_type, $_SESSION["actual_data"][$device][$basic_tok . "x1"], $length);
        } else {
            $number = $_SESSION["actual_data"][$device][$basic_tok . "b0"];
            if ($number > 0) {
                $send .= translate_dec_to_hex("n", $number, 2);
                $start = retranslate_simple_range(explode(",", $_SESSION["des_range"][$device][$basic_tok . "b1"]), $_SESSION["actual_data"][$device][$basic_tok . "b1"], 2);
                $send .= translate_dec_to_hex("n", $start, 2);
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
                    $send .= translate_dec_to_hex($des_type, $_SESSION["actual_data"][$device][$tok], $length);
                    $i += 1;
                }
                # reset to 0 again
                $_SESSION["actual_data"][$device][$basic_tok . "b0"] = 0;
                $send_ok = 1;
            } else {
                $send_ok = 0;
            }
        }
    }
    return [$send, $send_ok];
}

function send_ab($basic_tok, $send){
    $device = $_SESSION["device"];
    $send_ok = update($device, $basic_tok, 1);
    $m0 = $basic_tok . "m0";
    $o0 = $basic_tok . "o0";
    if (array_key_exists($basic_tok . "a0", $_POST)) {
        if ($_POST[$basic_tok . "a0"] == "1") {
            if (!array_key_exists($m0, $_SESSION["actual_data"][$device])) {
                # one element only
                send_to_device($send . "0100");
            } else {
                $number = $_SESSION["actual_data"][$device][$m0];
                if ($number > 0) {
                    $send .= translate_dec_to_hex("n", $number, 2);
                    # pos of elements
                    if (array_key_exists($o0, $_SESSION["actual_data"][$device])) {
                        $pos = $_SESSION["actual_data"][$device][$o0];
                        $send .= translate_dec_to_hex("n", $pos, 2);
                    }
                    $send_ok = 1;
                    $_SESSION["read"] = 1;
                    send_to_device($send);
                }
            }
        }
    }
    return [$send, $send_ok];
}
?>
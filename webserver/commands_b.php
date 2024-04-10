<?php
# commands_b.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function create_ob($basic_tok){
    global $device;
    echo "<div><h3 class='ob'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ":<br>";
    # data
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "d")) {
            if (!strstr($token, "dx")) {
                $type = $_SESSION["type_for_memories"][$device][$token];
                echo find_name_of_type($type). " ";
                echo "<input type=text name=" . $token . " size =". find_length_of_displayed_vars($type)."  placeholder =" . str_replace(" ","&nbsp;",$_SESSION["actual_data"][$device][$token]) . "><br>";
            }
        }
    }
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])) {
        $token = $_SESSION["o_to_a"][$device][$basic_tok];
        $range_m0 = explode(",", $_SESSION["des"][$device][$token. "m0"]);
        $range_o0 = explode(",", $_SESSION["des"][$device][$token. "o0"]);
        $number_of_elements = $range_m0[0];
        array_splice($range_m0, 0, 1);
        array_splice($range_o0, 0, 1);
        if ($number_of_elements > 1) {
            echo "start at: ";
            simple_selector($token."m0", $range_m0, $_SESSION["actual_data"][$device][$token."m0"]);
            echo "number of elements: ";
            simple_selector($token."o0", $range_o0, $_SESSION["actual_data"][$device][$token."o0"]);
        }
        display_as($_SESSION["o_to_a"][$device][$basic_tok]);
        echo "<br>";
    }
    echo "</h3></div>";
}

function create_ab($basic_tok) {
    global $language, $device;
    echo "<div><h3 class='ab'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ":<br>";
    # start at
    $tok = $basic_tok. "m0";
    $range = explode(",", $_SESSION["des"][$device][$tok]);
    $number_of_elements = $range[0];
    array_splice($range, 0, 1);
    if ($number_of_elements > 1) {
        echo "start at ";
        simple_selector($tok, $range, $_SESSION["actual_data"][$device][$tok]);
    }
    else {
        # one type of data
        echo find_name_of_type($_SESSION["type_for_memories"][$device][$basic_tok. "d0"]);
    }
    # number of elements
    $tok = $basic_tok. "o0";
    $range = explode(",", $_SESSION["des"][$device][$tok]);
    array_splice($range, 0, 1);
    echo " elements: ";
    simple_selector($tok, $range, $_SESSION["actual_data"][$device][$tok]);
    echo " ";
    # data
    if ($number_of_elements == 1){
        $data = str_replace(" ", "&nbsp;", $_SESSION["actual_data"][$device][$basic_tok . "d0"]);
    }
    else {
        $data = "";
        $i = 0;
        $j = $_SESSION["actual_data"][$device][$basic_tok . "m0"];
        while ($i < $_SESSION["actual_data"][$device][$tok]) {
            if ($j >= explode(",", $_SESSION["des"][$device][$basic_tok . "m0"])[0]) {
                $j = 0;
            }
            $data .= str_replace(" ", "&nbsp;", $_SESSION["actual_data"][$device][$basic_tok . "d" . $j]) . "&nbsp;.&nbsp;";
            $i++;
            $j++;
        }
    }
    echo " <marquee>" . $data. "</marquee>";
    echo "<br>";
    display_as($basic_tok. "a");
    echo "</h3></div>";
}

function correct_for_send_ob($basic_tok){
    # $_SESSION["actual_data"][$device] data is not updated
    # transmitted are tok until the first empty tok
    global $device, $send_ok, $tok_to_send, $send_string_by_tok;
    check_send_if_a_exists($basic_tok);
    if ($send_ok) {$send_ok = check_send_if_change_of_actual_data($basic_tok);}
    if ($send_ok) {
        # create data to send
        $send_data = "";
        $display_data = "";
        $stop = 0;
        $start = 0;
        $number_of_elements = 0;
        $start_pos = 0;
        foreach ($_SESSION["cor_token"][$device][$basic_tok] as $value) {
            if ($send_ok and $stop == 0) {
                if (strstr($value, "d")) {
                    if (!strstr($value, "dx")) {
                        if ($start == 0) {
                            $start_pos++;
                        }
                        if (array_key_exists($value, $_POST) and $_POST[$value] != "") {
                            # type_for_memories is one char only for $tok.d..
                            $type = $_SESSION["type_for_memories"][$device][$value];
                            list($send_data, $display_data) = check_memory_data($value, $type, 0, $value);
                            $start = 1;
                            $number_of_elements++;
                        } else {
                            if ($start == 1) {
                                $stop = 1;
                            }
                        }
                    }
                }
            }
        }
    }
    if ($send_ok == 1) {
        # update data (only if no error before!!)
        $stop = 0;
        $start = 0;
        $start_pos = 0;
        foreach ($_SESSION["cor_token"][$device][$basic_tok] as $value) {
            if ($stop == 0) {
                if (strstr($value, "d")) {
                    if (!strstr($value, "dx")) {
                        if ($start == 0) {
                            $start_pos++;
                        }
                        if (array_key_exists($value, $_POST) and $_POST[$value] != "") {
                            $_SESSION["actual_data"][$device][$value] = $_POST[$value];
                            $start = 1;
                        } else {
                            if ($start == 1) {
                                $stop = 1;
                            }
                        }
                    }
                }
            }
        }
    }
    if ($send_ok) {
        if ($number_of_elements > 0) {
            # basic_tok
            $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
            # number of element if more than 1 possible
            if (count(explode(",", $_SESSION["type_for_memories"][$device][$basic_tok . "m0"])) > 2) {
                $send .= translate_dec_to_hex("n", $start_pos - 1, 2);
                $send .= translate_dec_to_hex("n", $number_of_elements, 2);
            }
            $send .= $send_data;
            $tok_to_send[$basic_tok] = 1;
            $send_string_by_tok[$basic_tok] = $send;
        }
    }
}

function correct_for_send_ab($basic_tok){
    global $device, $tok_to_send, $send_string_by_tok;
    $dat = "";
    if (array_key_exists($basic_tok . "a", $_POST) and $_POST[$basic_tok . "a"] == "1") {
        $m0 = $basic_tok . "m0";
        $o0 = $basic_tok . "o0";
        if (count(explode(",", $_SESSION["des"][$device][$basic_tok . "m0"])) > 3) {
            # more than 1 element
            $number = $_POST[$o0];
            if ($number > 0) {
                $dat .= translate_dec_to_hex("n", $_POST[$m0], 2);
                $dat .= translate_dec_to_hex("n", $number, 2);
            }
            $_SESSION["actual_data"][$device][$m0] = $_POST[$m0];
            $_SESSION["actual_data"][$device][$o0] = $_POST[$o0];
        }
        if ($_POST[$o0] > 0) {
            # basic_tok
            $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
            $send .= $dat;
            $_SESSION["read"] = 1;
            $tok_to_send[$basic_tok] = 1;
            $send_string_by_tok[$basic_tok] = $send;
        }
    }
}

function receive_b($basic_tok, $from_device){
    # $fromdevice: without basic_tok !!
    global $device;
    $max_element_number = count($_SESSION["original_announce"][$device][$basic_tok]) - 2;
    if ($max_element_number > 0){
        # 256 elemnets supported only
        $start = hexdec(substr($from_device,0,2));
        $element_number = hexdec(substr($from_device,2,2));
        $from_device = substr($from_device,4, null);
        $del_adder= 4;
    }
    else{
        # one element
        $start = 0;
        $element_number = 1;
        $del_adder = 0;
    }
    $i = $start;
    $j = 0;
    $all_to_delete = 0;
    while ($j < $element_number){
        list($data, $delete_bytes) = update_memory_data($basic_tok . "d" . $i, $from_device,$_SESSION["property_len"][$device][$basic_tok][$element_number + 1]);
        $from_device = substr($from_device,$delete_bytes, null);
        update_corresponding_opererating($basic_tok, "d".$i, $data);
        $all_to_delete += $delete_bytes;
        $i ++;
        if ($i > $max_element_number){$i = 0;}
        $j++;
    }
    # to delete
    return $del_adder + $all_to_delete;
}
?>
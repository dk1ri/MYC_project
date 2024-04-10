<?php
# commands_a.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function create_oa($basic_tok){
    global $language, $device;
    echo "<div><h3 class='oa'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ":<br>";
    if (!array_key_exists($basic_tok,$_SESSION["ALL"][$device])) {
        $tok = $basic_tok. "m0";
        if (array_key_exists($tok, $_SESSION["des"][$device])){
            $range = explode(",", $_SESSION["des"][$device][$tok]);
            array_splice($range, 0, 1);
            if (count($range) > 2) {
                most_simple_selector_for_simple_des($tok, $range, $_SESSION["actual_data"][$device][$tok]);
            }
        }
        echo " ";
        # data
        $position = $_SESSION["actual_data"][$device][$tok];
        $tok = $basic_tok. "d" . $position;
        # the input field is empty always
        $type = $_SESSION["type_for_memories"][$device][$tok];
        $data = str_replace(" ","&nbsp;",$_SESSION["actual_data"][$device][$tok]);
        echo "<input type=text name=" . $basic_tok."dx" . " size = ". find_length_of_displayed_vars($type)."  placeholder =" . $data . ">";
    }
    else{
        # ALL
        $stop = 0;
        $i = 0;
        while (!$stop){
            $tok = $basic_tok."d".$i;
            if (array_key_exists($tok,$_SESSION["actual_data"][$device])){
                echo $_SESSION["des_name"][$device][$tok]. " ";
                $type = $_SESSION["type_for_memories"][$device][$tok];
                $data = str_replace(" ", "&nbsp;", $_SESSION["actual_data"][$device][$tok]);
                echo "<input type=text name=" . $tok . " size = " . find_length_of_displayed_vars($type) . "  placeholder =" . $data . ">";
                echo "<BR>";
            }
            else{$stop = 1;}
            $i++;
        }
    }
    echo "<br>";
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])) {
     #   echo "<marquee>" . $_SESSION["actual_data"][$device][$tok] . "</marquee><br>";
        display_as($_SESSION["o_to_a"][$device][$basic_tok]);
    }
    echo "</h3></div>";
}

function create_aa($basic_tok) {
    global $language, $device;
    echo "<div><h3 class='aa'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ":<br>";
    if (!array_key_exists($basic_tok,$_SESSION["ALL"][$device])) {
        $tok = $basic_tok . "m0";
        if (array_key_exists($tok, $_SESSION["des"][$device])) {
            $range = explode(",", $_SESSION["des"][$device][$tok]);
            array_splice($range, 0, 1);
            if (count($range) > 2) {
                most_simple_selector_for_simple_des($tok, $range, $_SESSION["actual_data"][$device][$tok]);
            }
            #else {
            #   # one type of data
            #  echo $_SESSION["des_name"][$device][$basic_tok. "d0"];
        }
        echo " ";
        # data
        $position = $_SESSION["actual_data"][$device][$tok];
        $tok = $basic_tok . "d" . $position;
        # data
        # $_SESSION["actual_data"][$device][$basic_tok."m0"] hold the position
        echo "<marquee>" . $_SESSION["actual_data"][$device][$tok] . "</marquee><br>";
    }
    else{
        $stop = 0;
        $i = 0;
        while (!$stop){
            echo "<marquee>" . $_SESSION["actual_data"][$device][$basic_tok."d".$i] . "</marquee><br>";
            $i++;
        }

    }
    echo "<br>";
    display_as($basic_tok."a");
    echo "</h3></div>";
}
function correct_for_send_oa($basic_tok){
    global $language, $device, $send_ok, $tok_to_send, $send_string_by_tok;
    check_send_if_a_exists($basic_tok);
    if ($send_ok) {$send_ok = check_send_if_change_of_actual_data($basic_tok);}
    if (!array_key_exists($basic_tok,$_SESSION["ALL"][$device])) {
        if ($send_ok == 1) {
            array_key_exists($basic_tok . "m0", $_POST) ? $pos = $_POST[$basic_tok . "m0"] : $pos = 0;
            $send_data = "";
            $display_data= "";
            if (array_key_exists($basic_tok . "dx", $_POST) and $_POST[$basic_tok . "dx"] != "") {
                # send with no changes as well:
                # one element of type of $pos have changed
                $type = explode(",", $_SESSION["type_for_memories"][$device][$basic_tok . "m0"])[2 * $pos + 1];
                list($send_data, $display_data) = check_memory_data($basic_tok . "dx", $type, 0, $basic_tok . "d" . ($pos));
            } else {
                $send_ok = 0;
            }
            if ($send_ok == 1) {
                # update correct only
                $_SESSION["actual_data"][$device][$basic_tok . "d" . $pos] = $display_data;
                $_SESSION["actual_data"][$device][$basic_tok . "m0"] = $pos;
                # basic_tok
                $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
                # number of element if more than possible
                if (count(explode(",", $_SESSION["type_for_memories"][$device][$basic_tok . "m0"])) > 2) {
                    $send .= translate_dec_to_hex("n", $pos, 2);
                }
                $send .= $send_data;
            }
        }
    }
    else{
        # send all
        $send_tok = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
        $stop = 0;
        $i = 0;
        $send = "";
        while (!$stop){
            $tok = $basic_tok."d".$i;
            if (array_key_exists($tok, $_SESSION["type_for_memories"][$device])){
                $send .= $send_tok;
                $send .= translate_dec_to_hex("n", $i, 2);
                $type = explode(",", $_SESSION["type_for_memories"][$device][$tok])[0];
                list($send_data, $display_data) = check_memory_data($tok, $type, 0, $tok);
                $send .= $send_data;
                $_SESSION["actual_data"][$device][$tok] = $display_data;
            }
            else{
                # stop
                $stop = 1;
            }
            $i++;
        }

    }
    if ($send_ok == 1) {
        $tok_to_send[$basic_tok] = 1;
        $send_string_by_tok[$basic_tok] = $send;
    }
}

function correct_for_send_aa($basic_tok){
    global $language, $device,$tok_to_send, $send_string_by_tok;
    if (array_key_exists($basic_tok . "a", $_POST) and $_POST[$basic_tok . "a"] == 1) {
        $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
        if (!array_key_exists($basic_tok,$_SESSION["ALL"][$device])) {
            array_key_exists($basic_tok, $_SESSION["a_to_o"][$device]) ? $basic_tok_ = $_SESSION["a_to_o"][$device][$basic_tok] : $basic_tok_ = $basic_tok;
            update_actual_data_from_POST($basic_tok_);
            $send = translate_dec_to_hex("m", $basic_tok, $_SESSION["property_len"][$device][$basic_tok][0]);
            if (count($_SESSION["original_announce"][$device][$basic_tok_]) > 2) {
                $send .= translate_dec_to_hex("n", $_POST[$basic_tok_ . "m0"], 2);
            }
        }
        # else send no parameter
        $_SESSION["read"] = 1;
        $tok_to_send[$basic_tok] = 1;
        $send_string_by_tok[$basic_tok] = $send;
    }
}

function  receive_a($basic_tok, $from_device){
    global $language, $device;
    $element_number = 0;
    if(count($_SESSION["original_announce"][$device][$basic_tok]) > 2) {
        # max 256 elements only
        $element_number = hexdec(substr($from_device, 0, 2));
        # < 256 elements allowed only -> length: 1 byte
        update_corresponding_opererating($basic_tok, "m0", $element_number);
        $from_device = substr($from_device, 2, null);
    }
    list($data, $delete_bytes) = update_memory_data($basic_tok . "d" . $element_number, $from_device,$_SESSION["property_len"][$device][$basic_tok][$element_number + 2]);
    update_corresponding_opererating($basic_tok, "d" . $element_number, $data);
    return $delete_bytes + 2;
}
?>
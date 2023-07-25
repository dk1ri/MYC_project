<?php
# commands_n.php
# DK1RI 20230615
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
#
function create_on($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='on'>";
    echo $_SESSION["des_name"][$device][$basic_tok];
    echo "<br>";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more display elements available
        selector($basic_tok);
    }
    if (array_key_exists($basic_tok. "o0", $_SESSION["des"][$device])) {
        # one or more display elements available
        selector_for_o($basic_tok);
    }
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "d")){
            # data
            stack_memory_selector($token);
            echo "<br>";
        }
    }
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])) {
        display_as($_SESSION["o_to_a"][$device][$basic_tok]);
    }
    echo "</h3></div>";
}

function create_an($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='an'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . "<br>";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more stack display elements available
        selector($basic_tok);
    }
    if (array_key_exists($basic_tok. "o0", $_SESSION["des"][$device])) {
        # one or more display elements available
        selector_for_o($basic_tok);
    }
    $dat = "";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "d")) {
            $dat .= $_SESSION["actual_data"][$device][$token]. ", ";
        }
    }
    echo " <marquee width='200' scrollamount='2'>" . $dat . "</marquee>" . " ";
    echo "<br>";
    display_as($basic_tok);
    echo "</h3></div>";
}

function send_on($basic_tok, $send, $senda){
    $device = $_SESSION["device"];
    $send_ok = update($device, $basic_tok,0);
    # positions are updated
    $tok = $basic_tok. "a";
    if (array_key_exists($tok, $_SESSION["corrected_POST"][$device]) and $_SESSION["corrected_POST"][$device][$tok] == 1) {
        # if answer set-> ignore change of data
        $send = $senda;
        # position
        $send .= calculate_pos_from_actual_to_hex($basic_tok);
        $send_ok = 1;
        $_SESSION["read"] = 1;
    }
    else {
        $send_ok_ = update($device, $basic_tok, 1);
        if ($send_ok_) {
            $send_ok = 1;
        }
        if ($send_ok) {
            # number of elements are calculated by using data
            $dataelements = explode(",", $_SESSION["actual_data"][$device][$basic_tok . "o0"]);
            $no_element = count($dataelements);
            $length = $_SESSION["property_len"][$device][$basic_tok][1];
            $data = translate_dec_to_hex("n", $no_element, $length);
            $send .= $data;
            # position
            $send .= calculate_pos_from_actual_to_hex($basic_tok);
            # data
            $des_type = explode(";", $_SESSION["des"][$device][$basic_tok . "d0"]);
            $length = $des_type[0];
            $i = 0;
            while ($i < count($dataelements)) {
                $send .= translate_dec_to_hex($des_type[0], $dataelements[$i], $length);
                $i += 1;
            }
        }
    }
    return [$send, $send_ok];
}

function send_an($basic_tok, $send){
    $device = $_SESSION["device"];
    $send_ok = update($device, $basic_tok, 0);
    if (array_key_exists($basic_tok . "a", $_POST) and $_SESSION["corrected_POST"][$device][$basic_tok. "a"] == 1) {
        # do not send with 0 elements
        if ($_SESSION["actual_data"][$device][$basic_tok . "o0"] != 0) {
            # startposition
            $length = $_SESSION["property_len"][$device][$basic_tok][2];
            $data = translate_dec_to_hex("n", $_SESSION["actual_data"][$device][$basic_tok . "m0"], $length);
            $send .= fillup($data, $length);
            # number_of_elements
            $length = $_SESSION["property_len"][$device][$basic_tok][3];
            $data = translate_dec_to_hex("n", $_SESSION["actual_data"][$device][$basic_tok . "o0"], $length);
            $send .= fillup($data, $length);
            $send_ok = 1;
            $_SESSION["read"] = 1;
        }
        else{
            $send = "";
        }
    }
    return [$send, $send_ok];
}

function receive_n($basic_tok, $from_device){
    $device = $_SESSION["device"];
    $position_length = $_SESSION["property_len"][$device][$basic_tok][2];
    $position = hexdec(substr($from_device, 0, $position_length));
    $from_device = substr($from_device,$position_length, null);
    var_dump($position);
    $position = update_memory_pos($basic_tok."m0", $position, 3);
    #
    $no_of_elements_length = $_SESSION["property_len"][$device][$basic_tok][3];
    $no_of_elements = hexdec(substr($from_device, 0, $no_of_elements_length));
    $no_of_elements = update_memory_pos($basic_tok."o0", $no_of_elements, 0);
    $from_device = substr($from_device, $no_of_elements_length, null);
    $data = "";
    $all_to_delete = 0;
    for ($i=0; $i < $no_of_elements; $i ++){
        if ($i != 0){$data .=",";}
        list($data_, $delete_bytes) = update_memory_data($basic_tok."d0", $from_device, 0, 3);
        update_corresponding_opererating($basic_tok,"d0", $data);
        $from_device = substr($from_device, $delete_bytes, null);
        $data .= $data_;
        $all_to_delete += $delete_bytes;
    }
    $_SESSION["actual_data"][$device][$basic_tok."d0"] = $data;
    # to delete
    return $no_of_elements_length + $position_length + $all_to_delete;
}
?>
<?php
# commands_f.php
# DK1RI 20230615
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
#
function create_of($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='of'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    stack_memory_selector($basic_tok. "m0");
    $number_of_elements = explode(",",$_SESSION["des"][$device][$basic_tok."m0"])[0];
    echo " up to ". $number_of_elements. " comma separated elements";
    $type = explode(",", $_SESSION["original_announce"][$device][$basic_tok][1])[0];
    echo " " . find_name_of_type($type) . ": ";
    echo "<input type=text name=" . $basic_tok."d0" . " size = 10 placeholder =" . $_SESSION["actual_data"][$device][$basic_tok."d0"] . ">";
    echo "<br>";
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])) {
        display_as($_SESSION["o_to_a"][$device][$basic_tok]);
    }
    echo "</h3></div>";
}

function create_af($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='af'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    echo "<b>";
    echo "<marquee>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $key => $value){
        if (strstr($value, "d")){
            echo $_SESSION["actual_data"][$device][$value]. " ";
        }
    }
    echo "</marquee><br>";
    stack_memory_selector($basic_tok. "m0");
    display_as($basic_tok. "a");
    echo "</h3></div>";
}

function send_of($basic_tok, $send, $senda){
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
        $send_ok = update($device, $basic_tok,1);
        $data = explode(",", $_SESSION["actual_data"][$device][$basic_tok. "d0"]);
        $send .= translate_dec_to_hex("n", count($data), 2);
        $type = $_SESSION["type_for_memories"][$device][$basic_tok."d0"];
        $i = 0;
        while ( $i < count($data)){
            $length = $_SESSION["property_len"][$device][$basic_tok][2];
            $send .= translate_dec_to_hex($type, $data[$i], $length);
            $i += 1;
        }
    }
    return [$send, $send_ok];
}

function send_af($basic_tok, $send){
    $device = $_SESSION["device"];
    $send_ok = update($device, $basic_tok, 0);
    $tok = $basic_tok . "a";
    if (array_key_exists($tok, $_POST) and $_POST[$tok] == 1) {
        if ($_SESSION["actual_data"][$device][$basic_tok . "m0"] != 0) {
            # only if number of elements > 0
            $length = $_SESSION["property_len"][$device][$basic_tok][2];
            $send .= translate_dec_to_hex("n", $_SESSION["actual_data"][$device][$basic_tok . "m0"], $length);
            $send_ok = 1;
            $_SESSION["read"] = 1;
        }
    }
    return [$send, $send_ok];
}
?>
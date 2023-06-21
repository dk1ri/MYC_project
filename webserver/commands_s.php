<?php
# commands_s.php
# DK1RI 20230621
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function create_os($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='op'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])){
        # one or more stack display elements available
        selector($basic_tok);
    }
    $tok = $basic_tok."d0";
    echo "<select name=" . $tok . " id=" . $tok . ">";
    $field_x = explode(",", $_SESSION["des"][$device][$tok]);
    $i = 0;
    while ($i < count($field_x)) {
        $pos = $field_x[$i];
        $i += 1;
        $value = $field_x[$i];
        if ($value == ""){$value = "x";}
        echo "<option value=" . $pos;
        if ($pos == $_SESSION["actual_data"][$device][$tok]) {
            echo " selected";
        }
        echo ">" . $value . "</option>";
        $i += 1;
    }
    echo "</select>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok){
        if (strstr($tok, "a")) {
            display_as($tok, 0);
        }
    }
    echo "</h3></div>";
}

function create_as($basic_tok){
    echo "<div><h3 class='as'>";
    create_as_at($basic_tok);
    echo "</h3></div>";
}

function create_at($basic_tok){
    echo "<div><h3 class='at'>";
    create_as_at($basic_tok);
    echo "</h3></div>";
}

function create_as_at($basic_tok){
    $device = $_SESSION["device"];
    echo $_SESSION["des_name"][$device][$basic_tok]  . ": ";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more stack display elements available
        selector($basic_tok);
    }
    $actual = $_SESSION["actual_data"][$device][$basic_tok."d0"];
    $label = explode(",",$_SESSION["des"][$device][$basic_tok."d0"])[2 * ($actual + 1) + 1];
    echo  " ". $label. " read: ";
    echo "<input type='checkbox' id=".$basic_tok."a" . " name=".$basic_tok."a value=1>";
}

function send_os($basic_tok, $send, $senda){
    $send_ok = 0;
    $device = $_SESSION["device"];
    list($send, $senda, $change_found) = handle_stacks($basic_tok, $send, $senda);
    # $send has stacks now, if necessary
    $tok = $basic_tok. "a";
    if (array_key_exists($tok, $_SESSION["corrected_POST"][$device]) and $_SESSION["corrected_POST"][$device][$tok] == 1) {
        # if answer set-> ignore change of data
        $send = $senda;
        $send_ok = 1;
        $_SESSION["read"] = 1;
    }
    else {
        list($send, $change_found_) = update_one($basic_tok . "d0", $send, 2);
        if ($change_found_) {
            $change_found = 1;
            change_as_data($basic_tok . "d0");
        }
        if ($change_found) {
            $send_ok = 1;
        }
    }
    return [$send, $send_ok];
}

function send_asat($basic_tok, $send, $senda){
    $send_ok = 0;
    $device = $_SESSION["device"];
    list($send, $senda, $change_found) = handle_stacks($basic_tok, $send, $senda);
    $tok = $basic_tok . "a";
    if (array_key_exists($tok, $_SESSION["corrected_POST"][$device])) {
        if ($_SESSION["corrected_POST"][$device][$tok] == 1) {
            $change_found = 1;
        }
        $_SESSION["actual_data"][$device][$tok] = 0;
    }
    if ($change_found) {
        $send_ok = 1;
        $_SESSION["read"] = 1;
    }
    return [$send, $send_ok];
}
?>
<?php
# commands_u.php
# DK1RI 20230621
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function create_ou($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='ou'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])){
        # one or more stack display elements available
        selector($basic_tok);
    }
    $des = explode(",", $_SESSION["des"][$device][$basic_tok."d0"]);
    if (count($des) == 2) {
        echo "<input type='checkbox' id=" . $basic_tok."d0" . " name=" . $basic_tok."d0 value=1>";
    }
    else {
        echo "<select name=",$basic_tok."d0"," id=",$basic_tok."d0",">";
        $i = 0;
        while ($i < count($des)) {
            echo "<option value=".$des[$i];
            $i += 1;
            echo ">".$des[$i], "</option>";
            $i += 1;
        }
        echo "</select>";
    }
    echo "</h3></div>";
}

function send_u($basic_tok, $send, $senda){
    $send_ok = 0;
    $device = $_SESSION["device"];
    list($send, $senda, $change_found) = handle_stacks($basic_tok, $send, $senda);
    if (array_key_exists($basic_tok."d0", $_SESSION["corrected_POST"][$device])){
        $tok = $basic_tok."d0";
        # $actual_data is 0 always
        # send, if corrected_POST is not idle (no send with change of stack only)
        if ($_SESSION["corrected_POST"][$device][$tok] != 0) {
            $send .= dec_hex($_SESSION["corrected_POST"][$device][$tok], 2);
            $change_found = 1;
        }
    }
    if ($change_found){$send_ok= 1;}
    return [$send, $send_ok];
}
?>
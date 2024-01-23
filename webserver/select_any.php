<?php
# select_any.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function most_simple_selector($token, $range, $actual){
    # simple selector for limited number of elements (array)
    # range with numbers; 0,0,1,1..
    # no max!
    echo "<select name=" . $token . " id=" . $token . ">";
    $i = 0;
    while ($i < count($range)) {
        echo "<option value=" . $range[$i];
        if ($range[$i] == $actual) {
            echo " selected";
        }
        $i += 1;
        echo ">" . $range[$i]."</option>";
        $i += 1;
    }
    echo "</select>";
}

function simple_selector($token, $range, $actual){
    # simple selector for limited number of elements
    # range with numbers; 0,0,1,1..
    # no max
    if (count($range) > 3) {
        echo "<select name=" . $token . " id=" . $token . ">";
        $i = 0;
        while ($i < count($range)) {
            echo "<option value=" . $range[$i];
            if ($range[$i] == $actual) {
                echo " selected";
            }
            echo ">" . $range[$i + 1] . "</option>";
            $i += 2;
        }
        echo "</select>";
    }
}

function selector($basic_tok){
    # create stack / memory display elements
    # 0 for m n token, 1 for o token
    $device = $_SESSION["device"];
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $ctoken) {
        if (strstr($ctoken, "m") or strstr($ctoken, "n")) {
            stack_memory_selector($ctoken);
        }
    }
}

function stack_memory_selector($ctoken){
    # one display element
    $device = $_SESSION["device"];
    $actual = $_SESSION["actual_data"][$device][$ctoken];
    if (array_key_exists($ctoken, $_SESSION["des_name"][$device])) {echo $_SESSION["des_name"][$device][$ctoken] . ": ";}
    $stacks = explode(",", $_SESSION["des"][$device][$ctoken]);
    array_splice($stacks, 0, 1);
    most_simple_selector($ctoken, $stacks, $actual);
    echo " ";
}
?>
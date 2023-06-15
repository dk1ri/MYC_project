<?php
# select_any.php
# DK1RI 20230615
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function most_simple_selector($token, $range, $actual){
    # simple selector for limited number of elements (array)
    # range with numbers; max,0,0,1,1..
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
    # range with numbers; max,0,0,1,1..
    if (count($range) > 1) {
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

function other_selector($token, $range, $actual){
    # simple selector for limited number of elements
    # range: like 1_1to10
    list($separator, $from, $to) = split_range($range);
    if ($from > $to){return;}
    echo "<select name=" . $token . " id=" . $token . ">";
    $i = 0;
    $j = $from;
    while ($j < $to) {
        echo "<option value=" . $i;
        if ($i == $actual) {
            echo " selected";
        }
        echo ">" . $j . "</option>";
        $j += $separator;
    }
    echo "</select>";
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

function selector_for_o($basic_tok){
    # create stack / memory display elements
    # 0 for m n token, 1 for o token
    $device = $_SESSION["device"];
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $ctoken) {
        if (strstr($ctoken,"o")) {
            stack_memory_selector($ctoken);
        }
    }
}

function stack_memory_selector($ctoken){
    $device = $_SESSION["device"];
    $actual = $_SESSION["actual_data"][$device][$ctoken];
    echo $_SESSION["des_name"][$device][$ctoken] . ": ";
    $stacks = explode(",", $_SESSION["des"][$device][$ctoken]);
    $max_r = $stacks[0];
    # remove max
    array_splice($stacks, 0, 1);
    if ($max_r > $_SESSION["conf"]["selector_limit"]){
        if (array_key_exists($ctoken,$_SESSION["to_correct"][$device])){
            # must be translated
            $actual = actual_data_to_real($ctoken);
            echo $_SESSION["to_correct"][$device][$ctoken]. ": ";
        }
        else {
            echo $_SESSION["des"][$device][$ctoken] . ": ";
        }
        echo "<input type='text' id=" . $ctoken . " name=" . $ctoken . " value=". $actual.">";

    }
    else {
        most_simple_selector($ctoken, $stacks, $actual);
    }
    echo " ";
}
?>
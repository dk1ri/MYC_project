<?php
# select_any.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function array_selector($token,$range,$actual){
    echo "<select name=" . $token . " id=" . $token . ">";
    foreach ($range as $key => $value){
        echo "<option value=" . $value;
        if ($value == $actual) {
            echo " selected";
        }
        echo ">" . $value."</option>";
    }
    echo "</select>";
}
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

function most_simple_selector_for_simple_des($token, $range, $actual){
    # simple selector for limited number of elements (array)
    # range with data as; 0,01,a,x,   ..
    # no max in $range!
    echo "<select name=" . $token . " id=" . $token . ">";
    $i = 0;
    while ($i < count($range)) {
        echo "<option value=" . $i;
        if ($i == $actual) {
            echo " selected";
        }
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
            echo ">" . $range[$i] . "</option>";
            $i += 2;
        }
        echo "</select>";
    }
}

function selector_with_Labels($token, $range, $actual){
    # selector for limited number of elements showing labels
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
    global $language, $device;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $ctoken) {
        if (strstr($ctoken, "m") or strstr($ctoken, "n")) {
            stack_memory_selector($ctoken);
        }
    }
}

function stack_memory_selector($ctoken){
    # one display element
    global $language, $device;
    $actual = $_SESSION["actual_data"][$device][$ctoken];
    if (array_key_exists($ctoken, $_SESSION["des_name"][$device])) {echo $_SESSION["des_name"][$device][$ctoken] . ": ";}
    $stacks = explode(",", $_SESSION["des"][$device][$ctoken]);
    $stacks = array_splice($stacks, 0, 1);
    if ($stacks[0] < $_SESSION["conf"]["selector_limit"]){
        most_simple_selector_for_simple_des($ctoken, $stacks, $actual);
    }
    else{
        echo "<input type=text name=" . $ctoken . " size = 20 placeholder =" . str_replace(" ","&nbsp;",$_SESSION["actual_data"][$device][$ctoken]) . "><br>";
    }
    echo " ";
}
?>
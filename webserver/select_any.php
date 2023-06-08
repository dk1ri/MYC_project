<?php
# select_any.php
# DK1RI 20230217
function most_simple_selector($token, $range, $actual){
    # simple selector for limited number of elements (array)
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

function display_memory_selector($token){
    # generate display for memory-selectors for des - string ( {...} )
    # pa is: max_number,name,{ ..}
    $device = $_SESSION["device"];
    $desc = explode("," , $_SESSION["des_range"][$device][$token]);
    $max_number = (int)$desc[0];
    echo $_SESSION["des_name"][$device][$token] . ": ";
    $actual = $_SESSION["actual_data"][$device][$token];
    if ($max_number < 100) {
        echo "<select name=" . $token . " id=" . $token . ">";
        # valid for op commands only:
        for ($des_pointer = 0; $des_pointer < count($desc); $des_pointer += 2) {
            $value = $desc[$des_pointer];
            $value1 = $desc[$des_pointer + 1];
            echo "<option value=" . $value;
            if ($actual == $value) {
                echo(" selected>");
            } else {
                echo ">";
            }
            echo $value1 . "</option>";
        }
        echo "</select>";
    }
    else {
        $ranges = "";
        for ($des_pointer = 0; $des_pointer < count($desc); $des_pointer += 1) {
            if (!strstr($desc[$des_pointer], "a")) {
                $ranges .= " " . $desc[$des_pointer + 1] . "to" . $desc[$des_pointer +2] . " ";
                $des_pointer += 2;
            } else {
                $ranges .= ", " . substr($desc[$des_pointer],1);
            }
        }
        echo " " . $ranges;
        echo "<input type='text' name = " . $token . " size = " . strlen(adapt_len($token,0, $actual[0])) . " placeholder =" . $actual[0] . ">";
    }
}
?>
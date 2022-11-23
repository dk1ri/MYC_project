<?php
# create_commands.php
# DK1RI 20221123

function head_corresponding($token){
    $device = $_SESSION["device"];
    if ($_SESSION["corresponding_tokens"][$_SESSION["device"]][$token] != []) {
        echo "<div class = flex-container><div>";
    }
}
function tail_correspondig($token){
    $device = $_SESSION["device"];
    if ($_SESSION["corresponding_tokens"][$device][$token] != []) {
        foreach ($_SESSION["corresponding_tokens"][$device][$token] as $ctoken) {
            $value = $_SESSION["all_announce"][$device][$ctoken];
            create_os_stack($ctoken, $value, $_SESSION["actual_data"][$device][$ctoken][0]);
        }
        echo "</div></div>";
    }
}
function create_os($token, $field, $real) {
    head_corresponding($token);
    explode(",", $field[0]) > 1 ? $labe = explode(",", $field[0])[1] : $labe = "?";
    $i = 2;
    $labe = "???";
    echo "<div><label for=",$token,">",$labe,"</label>&nbsp <select name=",$token," id=",$token,">";
    while ($i < count($field)) {
        # omit commandtype and stack:
        $selector_name = explode(",", $field[$i]);
        $val = "x";
        if (count($selector_name) > 0) {
            $val = $selector_name[1];
        }
        echo "<option value=".$selector_name[0];
        if ($selector_name[0]== $real) {
            echo " selected ";
        }
        echo ">$val", "</option>";
    $i += 1;
    }
    echo "</select></div>";
    tail_correspondig($token);
}

function create_os_stack($token, $field, $real) {
    explode(",", $field[0]) > 1 ? $labe = explode(",", $field[0])[1] : $labe = "?";
    $i = 2;
    echo "<div><label for=",$token,">",$labe,"</label>&nbsp <select name=",$token," id=",$token,">";
    while ($i < count($field)) {
        # omit commandtype and stack:
        $selector_name = explode(",", $field[$i]);
        $val = "x";
        if (count($selector_name) > 0) {
            $val = $selector_name[1];
        }
        echo "<option value=".$selector_name[0];
        if ($selector_name[0]== $real) {
            echo " selected ";
        }
        echo ">$val", "</option>";
        $i += 1;
    }
    echo "</select></div>";
}

function create_as($token, $field, $actual) {
    head_corresponding($token);
    $name = (explode(',', $field[0])[1]);
    echo $name.": ".$actual[0];
    echo "<div> new data:";
    echo "<input type='checkbox' id=".$token." name=".$token.">";
    echo "</div>";
    tail_correspondig($token);
}

function create_or($token, $line_array, $actual){
    # _POST deliver no data, if no switch is selected, so a possible reset of switche connat be done
    # therefor the all_off is necessary
    head_corresponding($token);
    $labe = "?";
    if (count(explode(',', ($line_array[0]))) > 1) {
        $labe = explode(',', $line_array[0])[1];
        }
    if (count($line_array) == 3){
        # simple switch
        $name = (explode(',', $line_array[0])[1]);
        echo "<div>".$name.": ". $actual[0]."</br> change:";
        echo "<input type='checkbox' id=".$token." name=".$token." value=0>";
        echo "</div>";
    } else {
        echo "<div><label for=", $token, ">", $labe, "</label>&nbsp; <select name=" . $token, "[] id=", $token, " multiple='multiple'>";
        echo "<option value=0";
        if ($actual[0] == "1") {
            echo(" selected='selected'>");
        } else {
            echo ">";
        }
        echo "all_off";
        echo "</option>";
        $i = 2;
        while ($i < count($line_array)) {
            $f = explode(",", $line_array[$i]);
            $val = "x";
            if (count($f) > 1) {
                $val = $f[1];
            }
            echo "<option value=", $i - 1;
            if ($actual[$i - 1] == "1") {
                echo(" selected='selected'>");
            } else {
                echo ">";
            }
            echo $val;
            echo "</option>";
            $i += 1;
        }
        echo "</select></div>";
    }
    tail_correspondig($token);
}

function create_ar($token, $line_array, $actual) {
    head_corresponding($token);
    $name = (explode(',', $line_array[0])[1]);
    $t = "";
    foreach ($actual as $switchstate)
    if ($switchstate == 1){
        $t .= "o ";
    } else {
        $t .= "- ";
    }
    echo " status: ". $t;

    $labe = "?";
    if (count(explode(',', ($line_array[0]))) > 1) {
        $labe = explode(',', $line_array[0])[1];
    }
    echo "<div><label for=", $token, ">", $labe, "</label>&nbsp; <select name=" . $token, "[] id=", $token, " multiple='multiple'>";
    $i = 2;
    while ($i < count($line_array)) {
        $f = explode(",", $line_array[$i]);
        $val = "x";
        if (count($f) > 1) {
            $val = $f[1];
        }
        echo "<option value=", $i - 1, ">";
        echo $val;
        echo "</option>";
        $i += 1;
    }
    echo "</select></div>";
    tail_correspondig($token);
}

function create_ou($token, $line_array) {
    head_corresponding($token);
    $name = (explode(',', $line_array[0])[1]);
    $labe = "";
    echo "<div><label for=",$token,">",$labe,"</label>";
    echo $name.": ";
    if (count($line_array) == 4) {
        $label = explode(",", $line_array[3]);
        echo $label[1] . " ";
        echo "<input type='checkbox' id=" . $token . " name=" . $token . ">";
    }
    else {
        echo "<select name=",$token," id=",$token,">";
        $i =2;
        while ($i < count($line_array)) {
            $selector_name = explode(",", $line_array[$i]);
            $val = "x";
            if (count($selector_name) > 0) {
                $val = $selector_name[1];
            }
            echo "<option value=".$selector_name[0];
            echo ">$val", "</option>";
            $i += 1;
        }
        echo "</select>";
    }
    echo "</div>";
    tail_correspondig($token);
}

function  create_op_oo($token)
{
    #
    head_corresponding($token);
    $device = $_SESSION["device"];
    echo "<div>";
    #this is the op ap command 1st dimension
    one_command($token );
    if (key_exists($token, $_SESSION["p_token"][$device])) {
        foreach ($_SESSION["p_token"][$device][$token] as $tok) {
            one_command($tok);
        }
    }
    tail_correspondig($token);
    echo "</div></div>";
}

function one_command($token){
    $device = $_SESSION["device"];
    $announce = $_SESSION["all_announce"][$device][$token];
    $ct = explode(",", $announce[0]);
    if (count($ct) > 1){
        echo $ct[1].": ";
    }
  #  var_dump($_SESSION["des_range"][$device][$token]);
    $no_of_subjects = count($_SESSION["des_range"][$device][$token]);
    $subject = 0;
    while ($subject < $no_of_subjects) {
        $no_of_elements = count($_SESSION["des_range"][$device][$token][$subject]);
        $element = 0;
        while ($element < $no_of_elements) {
            if ($subject != 2) {
                $no_of_subelements = count($_SESSION["des_range"][$device][$token][$subject][$element]);
                $actual = $_SESSION["actual_data"][$device][$token];
                $max_number = 0;
                $l = 0;
                while ($l < $no_of_subelements) {
                    $des = $_SESSION["des_range"][$device][$token][$subject][$element][$l];
                    $max_number += $des[2]- $des[1];
                    $l += 1;
                }
                if ($max_number < 100) {
                    echo " " . $_SESSION["des_name"][$device][$token][$subject] . ": ";
                    echo "<select name=" . $token, " id=", $token, " multiple='multiple'>";
                    if ($ct[0] == "oo"and $subject == 0){
                        echo "<option value=idle>idle</option>";
                    }
                    $value = 0;
                    $subelement = 0;
                    while ($subelement < $no_of_subelements) {
                        $des = $_SESSION["des_range"][$device][$token][$subject][$element][$subelement];
                        $steps = $des[0];
                        $value = $des[1];
                        $to = $des[2];
                        while ($value <= $to) {
                            echo "<option value=", $value;
                            if($ct[0] == "op")
                                if ($actual[0] == $value) {
                                    echo(" selected='selected'>");
                                } else {
                                    echo ">";
                                }
                            else {
                                echo ">";
                            }
                            echo $value . "</option>";
                            $value += $steps;
                        }
                        $subelement += 1;
                    }
                    echo "</select>";
                }
                else {
                    $subelement = 0;
                    while ($subelement < $no_of_subelements) {
                        $des = $_SESSION["des_range"][$device][$token][$subject][$element][$subelement];
                        echo $des[1] . " to " . $des[2] . " ";
                        $subelement += 1;
                    }
                    echo "<input type='text' name = " . $token . " size = 14 placeholder =" . $actual[$element] . ">";
                }
            }
            $element += 1;
        }
        $subject += 1;
    }
}

function create_ap($token, $field, $actual) {
    echo "<div>;";
    $device = $_SESSION["device"];
    $announce = $_SESSION["all_announce"][$device][$token];
    $ct = explode(",", $announce[0]);
    if (count($ct) > 1){
        echo $ct[1].": ";
    }
    $i = 0;
    while ($i < count($actual)){
        echo $actual[$i]. " ";
        $i += 1;
        }
    echo "<br>new data:";
    echo "<input type='checkbox' id=".$token." name=".$token.">";
    echo "</div>";
}

function create_om($token, $field, $real_data) {
    $l = explode(',', $field[0]);
    count($l) > 1 ? $labe = $l[1] : $labe = "?";
    echo "<div><label for=",$token,">",$labe,"</label><input type=text id=",$token," name=",$token," value=";
    if (array_key_exists($token, $_POST)) {
        echo $_POST[$token],">";
    }
    else {
        echo "?>";
    }
    echo "</div>";
}
?>
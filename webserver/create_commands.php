<!--
# es fehlt
-->
<?php
function create_os($token, $field, $real_data) {
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
        if ($selector_name[0]== $real_data) {
            echo " selected ";
        }
        echo ">$val", "</option>";
    $i += 1;
    }
    echo "</select></div>";
}

function create_as($token, $field, $real) {
    $name = (explode(',', $field[0])[1]);
    echo $name.": ".explode(",",$field[$real + 2])[1];
    echo "<div> new data:";
    echo "<input type='checkbox' id=".$token." name=".$token.">";
    echo "</div>";
}

function create_or($token, $field, $real) {
    $labe = "?";
    if (count(explode(',', ($field[0]))) > 1) {
        $labe = explode(',', $field[0])[1];
        }
    if (count($field) == 3){
        $name = (explode(',', $field[0])[1]);
        var_dump($real);
        if ($real == 0){
            $t = "off";
        } else {
            $t ="on";
        }
        echo "<div>".$name.": ". $t." change:";
        echo "<input type='checkbox' id=".$token." name=".$token." value=0>";
        echo "</div>";
    } else {
        echo "<div><label for=", $token, ">", $labe, "</label>&nbsp; <select name=" . $token, "[] id=", $token, " multiple='multiple'>";
        $i = 2;
        while ($i < count($field)) {
            $f = explode(",", $field[$i]);
            $val = "x";
            if (count($f) > 1) {
                $val = $f[1];
            }
            echo "<option value=", $f[0];
            if ($real[$i - 2] == 1) {
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
}

function create_ar($token, $field, $real) {
    $name = (explode(',', $field[0])[1]);
    $i=0;
    $t = "";
    while ($i < count($real)){
        if ( $real[$i] == 1){
            $t .= "x";
        } else {
            $t .= "o";
        }
        $i+=1;
    }
    echo $name.": ". $t;
    echo "<div>new data";
    echo "<input type='checkbox' id=".$token." name=".$token.">";
    echo "</div>";
}

function create_at($token, $field, $real) {
    if (count(explode(",", $field[0])) > 1) {
        $name = explode(',', $field[0])[1];
    }
    else{
        $name = "toggle";
    }
    echo $name.": ".explode(',', $field[$real[0] + 2])[1];
    echo "<div>toggle:";
    echo "<input type='checkbox' id=".$token." name=".$token.">";
    echo "</div>";
}

function create_ou($token, $field) {
    $name = (explode(',', $field[0])[1]);
    echo $name.": ";
    echo "<div>";
    $i = 2;
    while ($i < count ($field)) {
        $button = explode(",", $field[$i]);
        if (count($button) > 1) {
            $label = $button[1];
        } else {
            $label = "set";
        }
        echo $label.":";
        echo "<input type='radio' name=".$token." value=".$button[0].">";
        $i += 1;
    }
    echo "</div>";
}

function  create_op($device, $token, $field, $real, $fcu){
    $des = $_SESSION["des"][$device][$token];
    $name = $des[0];
    if ($fcu == 1) {
        echo $name . ": ";
    }
    echo "<div>";
    $i = 1;
    while ($i < count($des)) {
        if ($i != 1){
            echo ", ";
        }
        echo $des[$i + 1]." to ".$des[$i + 2]."/".$des[$i];
        $i += 3;
    }
    echo "<br>";
    echo "<input type='text' name = ".$token." size = 14 placeholder =".$real.">";
    echo "</div>";
}

function create_ap($device, $token, $field, $real) {
    if (count(explode(",", $field[0])) > 1) {
        $name = explode(',', $field[0])[1];
    }
    else{
        $name = "range";
    }
    echo $name.": <br>".$real;
    echo "<div>new data:";
    echo "<input type='checkbox' id=".$token." name=".$token.">";
    echo "</div>";
}

function  create_oo($device, $token, $field, $real, $fcu){
    if (count(explode(",",$field[0])) > 1){
        $name = explode(",", $field[0])[2];
    } else{
        $name = "stepcount";
    }
    echo $name . ": ";
    $i = 0;
    echo "<div><select name=",$token,"0"," id=",$token."0",">";
    while ($i < explode(",",$field[2])[0]){
        echo "<option value=".$i;
        if ($i == $real[0]) {
            echo " selected ";
        }
        echo ">$i", "</option>";
        $i += 1;
    }
    echo "</select></div>";
    if (count(explode(",",$field[5])) > 2){
        $name = explode(",", $field[5])[2];
    } else{
        $name = "stepsize";
    }
    echo $name.":";
    $i = 0;
    echo "<div><select name=",$token."2"," id=",$token."2",">";
    while ($i < explode(",",$field[2])[0]){
        echo "<option value=".$i;
        if ($i == $real[2]) {
            echo " selected ";
        }
        echo ">$i", "</option>";
        $i += 1;
    }
    echo "</select></div>";
    echo "<div><select name=",$token."3"," id=",$token."3",">";
    $i = 1;
    $add = explode(",",$field[6]);
    while ($i < count($add)){
        echo "<option value=".$i;
        if ($i == $real[3]) {
            echo " selected ";
        }
        echo ">".$add[$i + 1]."</option>";
        $i += 2;
    }
    echo "</select></div>";
    echo "<br>";
    echo "steptime:";
    echo "<input type='text' name = ".$token." size = 14 placeholder =".$real[1]."><br>";

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
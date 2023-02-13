<?php
# create_commands.php
# DK1RI 20230119

function head_stack($basic_tok){
    $device = $_SESSION["device"];
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $ctoken) {
        if (strstr($ctoken,"b") or strstr($ctoken,"c")){
            $ct = explode(",", $_SESSION["announce_all"][$device][$ctoken][0])[0];
            if ($ct != "oo") {
                $actual = $_SESSION["actual_data"][$device][$ctoken];
                echo $_SESSION["des_name"][$device][$ctoken] . ": ";
                $stacks = explode(",", $_SESSION["des_range"][$device][$ctoken]);
                simple_selector($ctoken, $stacks, $actual);
            }
        }
    }
}

function simple_selector($token, $range, $actual){
    # simple selector for limited number of elements
    if (count($range) > 2) {
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

function create_basic_command($basic_tok){
    $device = $_SESSION["device"];
    $field = explode(",", $_SESSION["actual_data"][$device][$basic_tok]);
    echo "<div>Device: " . $field[0] . ", Version: " . $field[1] . ", Author: ". $field[2];
    echo "<br> new data: ";
    echo "<input type='checkbox' id=".$basic_tok . " name=".$basic_tok." value=1>";
    echo "</div>";
}

function create_os($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='os'>";
    head_stack($basic_tok);
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ": ";
    # one "x0" tok
    echo "<select name=" . $basic_tok."x0" . " id=" . $basic_tok. "x0" . ">";
    $field_x = $_SESSION["announce_all"][$device][$basic_tok."x0"];
    $i = 1;
    while ($i < count($field_x)){
        $switch = explode(",", $field_x[$i]);
        count($switch) > 1 ? $val = $switch[1] : $val = "x";
        echo "<option value=" . $switch[0];
        if ($switch[0] == $_SESSION["actual_data"][$device][$basic_tok."x0"]) {
            echo " selected";
        }
        echo ">" . $val . "</option>";
        $i += 1;
    }
    echo "</select>";
    echo "</h3></div>";
}

function create_as($basic_tok, $actual) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='as'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"];
    head_stack($basic_tok);
    $label = explode(",",$_SESSION["announce_all"][$device][$basic_tok."x0"][$actual + 1])[1];
    echo  ": " . $label;
    echo " new data:";
    echo "<input type='checkbox' id=".$basic_tok."a0" . " name=".$basic_tok."x0 value=1>";
    echo "</h3></div>";
}

function create_or($basic_tok){
    # _POST deliver no data, if no switch is selected, so a possible reset of switches cannot be done
    # therefor the all_off is necessary
    echo "<div><h3 class='or'>";
    $device = $_SESSION["device"];
    head_stack($basic_tok);
    $actual = explode(",",$_SESSION["actual_data"][$device][$basic_tok . "x0"]);
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ": ";
    $announce = $_SESSION["announce_all"][$device][basic_tok($basic_tok)."x0"];
    if (count($announce) == 3){
        # simple switch
        echo $actual[0]."</br> change:";
        echo "<input type='checkbox' id=".$basic_tok."x0"." name=".$basic_tok."x0 value=1>";
    } else {
        echo "<label for=" . $basic_tok."x0" . ">".  "</label>&nbsp; <select name=" . $basic_tok."x0".  " id=" . $basic_tok."x0" . " multiple='multiple'>";
        $i = 1;
        while ($i < count($announce)) {
            $f = explode(",", $announce[$i]);
            count($f) > 1 ? $label = $f[1] : $label = "x";
            echo "<option value=", $i - 1;
            if ($actual[$i -1] == "1") {
                echo(" selected='selected'>");
            }
            echo ">".$label . "</option>";
            $i += 1;
        }
        echo "</select>";
    }
    echo "</h3></div>";
}

function create_ar($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='ar'>";
    $actual = explode(",", $_SESSION["actual_data"][$device][$basic_tok."x0"]);
    head_stack($basic_tok);
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"];
    $announce = $_SESSION["announce_all"][$device][$basic_tok."x0"];
    if (count($announce) > 3) {
        echo "<label for=" . $basic_tok."x0" . ">".  "</label>&nbsp; <select name=" . $basic_tok."x0".  " id=" . $basic_tok."x0" . ">";
        $i = 1;
        while ($i < count($announce)) {
            $f = explode(",", $announce[$i]);
            count($f) > 1 ? $label = $f[1] : $label = "x";
            echo "<option value=", $i;
            if ($actual[$i - 1] == "1") {
                echo(" selected='selected'>");
            }
            echo  ">" . $label . "</option>";
            $i += 1;
        }
        echo "</select>";
    }
    $sw_a = explode(",", $_SESSION["actual_data"][$device][$basic_tok."x0"]);
    $i = 1;
    $result = "";
    while ($i < count($announce)){
        $label = explode(",",$announce[$i])[1];
        if ($sw_a[$i - 1] == 0){
            $result .= "<strong class = 'green'>".$label . "</strong>";
        }
        else{
            $result .= "<strong class = 'red'>".$label . "</strong>";
        }
        $result .= " ";
        $i += 1;
    }
    echo " status: ". $result;
    echo " new data:";
    echo "<input type='checkbox' id=".$basic_tok. "a0"." name=".$basic_tok. "x0 value=1>";
echo "</h3></div>";
}

function create_ou($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='ou'>";
    $announce = $_SESSION["announce_all"][$device][basic_tok($basic_tok)."x0"];
    head_stack($basic_tok);
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"]. ": ";
    if (count($announce) == 2) {
        echo "<input type='checkbox' id=" . $basic_tok."x0" . " name=" . $basic_tok."x0 value=1>";
    }
    else {
        echo "<select name=",$basic_tok."x0"," id=",$basic_tok."x0",">";
        $i = 1;
        while ($i < count($announce)) {
            $switch = explode(",", $announce[$i]);
            echo "<option value=".$switch[0];
            echo ">".$switch[1], "</option>";
            $i += 1;
        }
        echo "</select>";
    }
    echo "</h3></div>";
}

function  create_op_oo($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='op'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ": ";
    if (array_key_exists($basic_tok. "b0", $_SESSION["des_range"][$device])){
        head_stack($basic_tok);
    }
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "b") or strstr($tok, "c") or strstr($tok, "x0")) {
            continue;
        }
        if ($_SESSION["announce_all"][$device][$tok][1] < 255){
            $des = $_SESSION["des_range"][$device][$tok];
            if ($des != 0) {
                $actual = $_SESSION["actual_data"][$device][$tok];
                echo " " . $_SESSION["des_name"][$device][$tok] . ": ";
                echo "<select name=" . $tok, " id=", $tok, ">";
                if (strstr($tok, "r")) {
                    echo "<option value=idle>idle</option>";
                }
                $i = 0;
                # discrete values only.
                $des_a = explode(",", $des);
                while ($i < count($des_a)) {
                    echo "<option value=", $des_a[$i];
                    echo "<option value=", $des_a[$i];
                    if ($actual == $des_a[$i]) {
                        echo(" selected='selected'");
                    }
                    echo ">" . $des_a[$i + 1] . "</option>";
                    $i += 2;
                }
                echo "</select>";
            }
        }
        else{
            if (strstr($tok, "r")) {
                $label = "count";
            }
            elseif (strstr($tok, "s")){
                $label = "step";
            }
            elseif (strstr($tok, "t")){
                $label = "steptime";
            }
            else{
                $label = "value";
            }
            echo " new ". $label . ": ";
            echo "<input type='text' name = " . $tok . " size = 14 placeholder =" . $actual = $_SESSION["actual_data"][$device][$tok] . ">";
        }
    }
    echo "</h3></div>";
}

function create_ap($basic_tok) {
    echo "<div><h3 class='ap'>";
    head_stack($basic_tok);
    $device = $_SESSION["device"];
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "b")){
            continue;
        }
        if (strstr($tok, "x")) {
            if (!strstr($tok, "x0")) {
                # x0 is dummy
                #data
                echo $_SESSION["des_name"][$device][$tok] . ": ";
                echo $_SESSION["actual_data"][$device][$tok][0] . " ";
            }
        }
        else {
            # answer command
            echo "<br>new data:";
            echo "<input type='checkbox' id=" . $basic_tok."a0" . " name=" . $basic_tok . "a0 value=1>";
        }
    }
    echo "</h3></div>";
}

function create_om($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='om'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . "<br>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "b")) {
            # memory- selector
            display_memory_selector($token);
        } else {
            # data
            echo explode(",",$_SESSION["des_type"][$device][$token])[2] . ": ";
            $dat = $_SESSION["actual_data"][$device][$token];
            $type = $_SESSION["des_type"][$device][$token][0];
            echo "<input type=text name=" . $token . " size =" . display_length($type)." placeholder =" . $dat . ">";
        }
        echo "<br>";
    }
    echo "</h3></div>";
}

function create_am($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='am'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . "<br>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "b")) {
            display_memory_selector($token);
        }
        elseif (strstr($token, "x")) {
            echo explode(",", $_SESSION["des_type"][$device][$token])[2] . ": ";
            $dat = $_SESSION["actual_data"][$device][$token][0];
            echo " " . $dat;
        }
        else {
            echo "<br>new data: ";
            echo "<input type='checkbox' id=" . $basic_tok."a0" . " name=" . $basic_tok . "a0 value=1>";
            # reset
            $_SESSION["actual_data"][$device][$token] = 0;
        }
        echo "<br>";
    }
    echo "</h3></div>";
}

function create_on($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='on'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . "<br>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        $type = "";
        if (strstr($token, "b")) {
            if (!strstr($token, "b0")) {
                # b0 is max number of transmitted elements -> not used
                if ($_SESSION["des_range"][$device][$token] != 0) {
                    # not for FIFO
                    display_memory_selector($token);
                }
            }
        } else {
            # data
            echo explode(",",$_SESSION["des_type"][$device][$token])[2] . ": ";
            $max_elements = explode(",", $_SESSION["original_announce"][$device][basic_tok($token)][2])[0];
            echo "max: " . $max_elements . " elements ";;
            $dat = $_SESSION["actual_data"][$device][$token];
            $type = $_SESSION["des_type"][$device][$token][0];
            echo "<input type=text name=" . $token . " size = " . display_length($type)." placeholder =" . $dat . ">";
        }
        if ($type != "s") {
            echo "<br>";
        }
    }
    echo "</h3></div>";
}

function create_an($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='an'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . "<br>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "b")) {
            # b0 is number of required elements
            if ($token == $basic_tok."b1"){
                if (!$_SESSION["des_range"][$device][$basic_tok."b1"] == 0) {
                    # no position for FIFO
                    display_memory_selector($token);
                }
            }
            else {
                display_memory_selector($token);
            }
        } elseif (strstr($token, "x")) {
            echo explode(",", $_SESSION["des_type"][$device][$token])[2] . ": ";
            $dat = $_SESSION["actual_data"][$device][$token];
            echo " <marquee width='20'>" . $dat . "</marquee>";
        }
        else{
            echo "<br>new data: ";
            echo "<input type='checkbox' id=" . $basic_tok."a0" . " name=" . $basic_tok . "a0 value=1>";
            # reset
            $_SESSION["actual_data"][$device][$token] = 0;
        }
        echo "<br>";
    }
    echo "</h3></div>";
}

function create_oa($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='oa'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ":<br>";
    $actual_pos = 0;
    $i = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "x")) {
            # data
            if (!strstr($token, "x0")) {
                $name = explode(",", $_SESSION["des_type"][$device][$token])[2];
                if ($name != ""){
                    echo explode(",", $_SESSION["des_type"][$device][$token])[2] . ": ";
                }
                $dat = explode(",", $_SESSION["actual_data"][$device][$token])[$actual_pos];
                $type = $_SESSION["des_type"][$device][$token][0];
                echo "<input type=text name=" . $token . " size = " . display_length($type)." placeholder =" . $dat . ">";
                echo "<br>";
            }
        }
        $i += 5;
    }
    echo "</h3></div>";
}

function create_aa($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='aa'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ": ";
    $actual_pos = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "b")) {
            $range = explode(",", $_SESSION["des_range"][$device][$token]);
            simple_selector($token, $range, $_SESSION["actual_data"][$device][$token]);
            $actual_pos = $_SESSION["actual_data"][$device][basic_tok($token) . "b0"];
        }
        elseif (strstr($token, "x")) {
            # data
            if (!strstr($token, "x0")) {
                echo explode(",", $_SESSION["des_type"][$device][$token])[2] . ": ";
                $dat = $_SESSION["actual_data"][$device][$token];
                echo " " . $dat . "<br>";
            }
        }
        else{
            echo "new data: ";
            echo "<input type='checkbox' id=" . $basic_tok."a0" . " name=" . $basic_tok . "a0 value=1>";
            # reset
            $_SESSION["actual_data"][$device][$token] = 0;
        }
    }
    echo "</h3></div>";
}
function create_ob($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='ob'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ":<br>";
    $i = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        $type = "";
        if (strstr($token, "b")) {
            if (strstr($token, "b")) {
                if (strstr($token, "b0")) {
                    echo "number of elements: ";
                }
                else{
                    echo "start at: ";
                }
                $range = explode(",", $_SESSION["des_range"][$device][$token]);
                simple_selector($token, $range, $_SESSION["actual_data"][$device][$token]);
                $actual_pos = $_SESSION["actual_data"][$device][basic_tok($token) . "b0"];
            }
        }
        else {
            # data
            if (!strstr($token, "x0")) {
                $name = explode(",", $_SESSION["des_type"][$device][$token])[2];
                if ($name != ""){
                    echo explode(",", $_SESSION["des_type"][$device][$token])[2] . ": ";
                }
                $type = $_SESSION["des_type"][$device][$token][0];
                echo "<input type=text name=" . $token . " size = " . display_length($type)." placeholder =" . $_SESSION["actual_data"][$device][$token] . ">";
            }
        }
        if ($type != "s") {
            echo "<br>";
        }
        $i += 5;
    }
    echo "</h3></div>";
}

function create_ab($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='ab'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ": ";
    $actual_pos = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "b")) {
            if (strstr($token, "b0")) {
                echo "number of elements: ";
            }
            else{
                echo "start at: ";
            }
            $range = explode(",", $_SESSION["des_range"][$device][$token]);
            simple_selector($token, $range, $_SESSION["actual_data"][$device][$token]);
            $actual_pos = $_SESSION["actual_data"][$device][basic_tok($token) . "b0"];
        }
        elseif (strstr($token, "x")) {
            # data
            if (!strstr($token, "x0")) {
                echo explode(",", $_SESSION["des_type"][$device][$token])[2] . ": ";
                $dat =  $_SESSION["actual_data"][$device][$token];
                echo " " . $dat . "<br>";
            }
        }
        else{
            echo "new data: ";
            echo "<input type='checkbox' id=" . $basic_tok."a0" . " name=" . $basic_tok . "a0 value=1>";
            # reset
            $_SESSION["actual_data"][$device][$token] = 0;
        }
    }
    echo "</h3></div>";
}
?>
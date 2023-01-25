<?php
# create_commands.php
# DK1RI 20230119

function head_stack($basic_token){
    $device = $_SESSION["device"];
    foreach ($_SESSION["cor_token"][$device][$basic_token] as $ctoken) {
        if (strstr($ctoken,"b") or strstr($ctoken,"c")){
            $actual = $_SESSION["actual_data"][$device][$ctoken];
            echo $_SESSION["des_name"][$device][$ctoken] .": ";
            $stacks = explode(",",$_SESSION["des_range"][$device][$ctoken]);
            simple_selector($ctoken, $stacks, $actual);
        }
    }
}

function simple_selector($token, $range, $actual){
    # simple selector for limited number of elements
    # used stacks
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
        for ($des_pointer = 0; $des_pointer < count($desc); $des_pointer += 1) {
            $value = $desc[$des_pointer];
            echo "<option value=" . $value;
            if ($actual == $value) {
                echo(" selected>");
            } else {
                echo ">";
            }
            echo $value . "</option>";
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

function create_basic_command($lin){
    echo "<div>Device: " . $lin[2] . ", Version: " . $lin[3] . ", Author: ". $lin[1] . "</div>";
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
    echo "<div> new data:";
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
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"];
    head_stack($basic_tok);
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "b") or strstr($tok, "c") or strstr($tok, "x0")){
            continue;
        }
        $actual = $_SESSION["actual_data"][$device][$tok];
        echo " " . $_SESSION["des_name"][$device][$tok] . ": ";
        $des = explode(",", $_SESSION["des_range"][$device][$tok]);
        echo "<select name=" . $tok, " id=", $tok, ">";
        if (strstr($tok, "r")) {
            echo "<option value=idle>idle</option>";
        }
        $des_pointer = 0;
        while (($des_pointer) < count($des)) {
            $des1 = $des[$des_pointer];
            if (strstr($des1, "_") and strstr($des1, "to")) {
                $des1_a = explode("_", $des1);
                $steps = $des1_a[0];
                $des1_b = explode("to", $des1_a[1]);
                $value = $des1_b[0];
                $to = $des1_b[1];
                while ($value <= $to) {
                    echo "<option value=", $value;
                    if ($actual == $value) {
                        echo(" selected='selected'>");
                    } else {
                        echo ">";
                    }
                    echo $des1 . "</option>";
                    $value += $steps;
                }
            } else {
                echo "<option value=", $des1;
                if ($actual == $des1) {
                    echo(" selected='selected'>");
                } else {
                    echo ">";
                }
                echo $des1 . "</option>";
            }
            $des_pointer += 1;
        }
        echo "</select>";
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
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "b")) {
            # memory- selector
            display_memory_selector($token);
        } else {
            # data
            # has (default)label always:
            echo $_SESSION["des_name"][$device][$token] . ": ";
            echo explode(",",$_SESSION["des_type"][$device][$token])[3] . ": ";
            echo explode(",",$_SESSION["des_type"][$device][$token])[1] . ": ";
            $dat = $_SESSION["actual_data"][$device][$token];
            echo "<input type=text name=" . $token . " size = 14 placeholder =" . $dat . ">";
        }
    }
    echo "</h3></div>";
}

function create_am($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='am'>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "b")) {
            display_memory_selector($token);
        } elseif (strstr($token, "x")) {
            echo $_SESSION["des_name"][$device][$token] . ": ";
            echo $_SESSION["des_type"][$device][$token][1] . ": ";
            $dat = $_SESSION["actual_data"][$device][$token][0];
            echo " " . $dat;
        }
        else {
            echo "<br>new data: ";
            echo "<input type='checkbox' id=" . $basic_tok."a0" . " name=" . $basic_tok . "a0 value=1>";
            # reset
            $_SESSION["actual_data"][$device][$token] = 0;
        }
    }
    echo "</h3></div>";
}

function create_on($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='on'>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
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
            echo $_SESSION["des_name"][$device][$token] . ": ";
            echo explode(",",$_SESSION["des_type"][$device][$token])[3] . ": ";
            echo explode(",",$_SESSION["des_type"][$device][$token])[1] . ": ";
            $max_elements = explode(",", $_SESSION["original_announce"][$device][basic_tok($token)][2])[0];
            $max_string = "max: " . $max_elements . " elements ";
            echo $_SESSION["des_type"][$device][$token][1] . ": " . $max_string;
            $dat = $_SESSION["actual_data"][$device][$token];
            echo "<input type=text name=" . $token . " size = 14 placeholder =" . $dat . ">";
        }
    }
    echo "</h3></div>";
}

function create_an($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='an'>";
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
            echo $_SESSION["des_name"][$device][$token] . ": ";
            echo $_SESSION["des_type"][$device][$token][1] . ": ";
            $dat = $_SESSION["actual_data"][$device][basic_tok($token) . "x0"];
            echo " <marquee width='20'>" . $dat . "</marquee>";
        }
        else{
            echo "<br>new data: ";
            echo "<input type='checkbox' id=" . $basic_tok."a0" . " name=" . $basic_tok . "a0 value=1>";
            # reset
            $_SESSION["actual_data"][$device][$token] = 0;
        }
    }
    echo "</h3></div>";
}

function create_oa($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='oa'>";
    $actual_pos = 0;
    $b_found = 0;
    $i = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "b")) {
            $range = explode(",", $_SESSION["des_range"][$device][$token]);
            simple_selector($token, $range, $_SESSION["actual_data"][$device][$token]);
            $actual_pos = $_SESSION["actual_data"][$device][basic_tok($token) . "b0"];
            $b_found = 1;
        } else {
            # data
            if ($b_found == 0){
                echo explode(",", $_SESSION["des_type"][$device][$basic_tok."x0"])[$i + 1] . ": ";
            }
            echo $_SESSION["des_name"][$device][$token] . ": ";
            $dat = explode(",", $_SESSION["actual_data"][$device][$token])[$actual_pos];
            echo "<input type=text name=" . $token . " size = 14 placeholder =" . $dat . ">";
        }
        $i += 5;
    }
    echo "</h3></div>";
}

function create_aa($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='aa'>";
    $actual_pos = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        echo "<div>";
        if (strstr($token, "b")) {
            $range = explode(",", $_SESSION["des_range"][$device][$token]);
            simple_selector($token, $range, $_SESSION["actual_data"][$device][$token]);
            $actual_pos = $_SESSION["actual_data"][$device][basic_tok($token) . "b0"];
        }
        elseif (strstr($token, "x")) {
            # data
            echo $_SESSION["des_name"][$device][$token] . ": ";
            $des = explode(",", explode(";", $_SESSION["des_type"][$device][$token])[$actual_pos])[1];
            echo $des . ": ";
            $actual = explode(",", $_SESSION["actual_data"][$device][$token]);
            $dat = $actual[$actual_pos];
            echo " " . $dat . "<br>";
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
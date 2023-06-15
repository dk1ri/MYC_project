<?php
# create_commands.php
# DK1RI 20230615
#The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
# creates display elements
function create_basic_command($basic_tok){
    $device = $_SESSION["device"];
    $field = explode(",", $_SESSION["actual_data"][$device][$basic_tok."a"]);
    echo "<div>Device: " . $field[0] . ", Version: " . $field[1] . ", Author: ". $field[2];
    echo "<br>" . $_SESSION["user"]["language"][$_SESSION["user"]["username"]]["new_data"] . ": ";
    echo "<input type='checkbox' id=".$basic_tok . "a0 name=".$basic_tok."a0 value=1>";
    echo "</div>";
}

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
        display_as($tok, 0);
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

function create_or($basic_tok){
    # selecting a switch as operate will toggle the status
    echo "<div><h3 class='or'>";
    create_or_ar($basic_tok);
    echo "</h3></div>";
}
function create_ar($basic_tok){
    # selecting a switch as operate will toggle the status
    echo "<div><h3 class='ar'>";
    create_or_ar($basic_tok);
    echo "</h3></div>";
}

function create_or_ar($basic_tok){
    # selecting a switch as operate will toggle the status
    $device = $_SESSION["device"];
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])){
        # one or more stack display elements available
        selector($basic_tok);
    }
    $announce = $_SESSION["original_announce"][$device][$basic_tok];
    echo "<br>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "d")) {
            $announce = $_SESSION["announce_all"][$device][$tok];
            $actual = $_SESSION["actual_data"][$device][$tok];
            if($actual == "0"){
                echo "<strong class = 'red'>";
            }
            else{
                echo "<strong class = 'green'>";
            }
            echo explode(",", $_SESSION["des"][$device][$tok])[1]. " ";
            echo "<input type='checkbox' name=" . $tok . " id=" . $tok . " label=" . $tok . ">";
        }
        elseif (explode(",", $announce[0])[0] == "or") {
            display_as($tok, 0);
        }
        echo "</strong>";
    }
}

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

function  create_op_oo($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='op'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])){
        # one or more stack display elements available
        selector($basic_tok);
    }
    $count_zero = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "d")) {
            $des = explode(",",$_SESSION["des"][$device][$tok]);
            $max = $des[0];
            array_splice($des,0,1);
            if ($max < $_SESSION["conf"]["selector_limit"]) {
                if (strstr($tok,"r")){echo "<br>";}
                if ($des == 0) {
                    $label  = "?";
                    # for default 3 times a "0" will appear
                    $count_zero += 1;
                    if ($count_zero == 1){
                        if (array_key_exists($tok, $_SESSION["des_name"][$device])) {
                            $label = $_SESSION["des_name"][$device][$tok];
                        }
                    }
                    if ($count_zero == 3) {
                        echo $_SESSION["user"]["language"][$_SESSION["user"]["username"]]["set_default"] . ": " .$label. " ";
                        echo "<input type='checkbox' id=" . $tok." name=" . $tok . " value=set_def>";
                    }
                }
                else{
                    $actual = $_SESSION["actual_data"][$device][$tok];
                    echo " " . $_SESSION["des_name"][$device][$tok] . ": ";
                    most_simple_selector($tok, $des, $actual);
                    if (strstr($tok, "t")){echo $_SESSION["unit"][$device][$tok] . " ";}
                    if (!strstr($tok, "r") and !strstr($tok, "s") and !strstr($tok,"t")) {
                        echo $_SESSION["unit"][$device][$tok] . "<br>";
                    }
                    $count_zero = 0;
                }
            } else {
                # > $_SESSION["conf"]["selector_limit"]
                echo " new " . $_SESSION["des_name"][$device][$tok] . ": ";
                $actual_real = actual_data_to_real($tok);
                echo implode(",",$des). ": ";
                echo "<input type='text' name = " . $tok . " size = 14 placeholder =" . $actual_real . ">";
                if (strstr($tok, "t")){echo $_SESSION["unit"][$device][$tok]. " ";}
                if (!strstr($tok, "r") and !strstr($tok, "s") and !strstr($tok,"t")) {
                    echo $_SESSION["unit"][$device][$tok] . "<br>";
                }
            }
        }
    }
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok){
        display_as($tok, 0);
    }
    echo "</h3></div>";
}

function create_ap($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='ap'>";
    echo $_SESSION["des_name"][$device][$basic_tok]  . ": ";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more stack display elements available
        selector($basic_tok);
    }
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "d")) {
            $des = explode(",",$_SESSION["des"][$device][$tok]);
            array_splice($des,0,1);
            #data
            echo $_SESSION["des_name"][$device][$tok] . ": ";
            echo actual_data_to_real($tok);
            echo $_SESSION["unit"][$device][$tok]."<br>";
        }
    }
    echo "read: <input type='checkbox' id=".$basic_tok."a" . " name=".$basic_tok."a value=1>";
    echo "</h3></div>";
}

function create_om($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='om'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ":<br>";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more stack display elements available
        selector($basic_tok);
    }
    echo "<br>";
    $token = $basic_tok. "d0";
    foreach($_SESSION["cor_token"][$device][$basic_tok] as $value) {
        if (strstr($value, "d0")) {
            # data
            stack_memory_selector($token);
        }
    }
    display_as($token, 0);
    echo "</h3></div>";
}

function create_am($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='am'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . "<br>";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more stack display elements available
        selector($basic_tok);
    }
    echo "<br>";
    $token = $basic_tok. "d0";
    if (array_key_exists($basic_tok. "d0", $_SESSION["actual_data"][$device])) {
        $dat = translate_received_data_type($token, $_SESSION["actual_data"][$device][$token]);
        echo $dat;
        echo " ";
    }
    display_as($token, 1);
    echo "</h3></div>";
}

function create_on($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='on'>";
    echo $_SESSION["des_name"][$device][$basic_tok];
    echo "<br>";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more display elements available
        selector($basic_tok);
    }
    if (array_key_exists($basic_tok. "o0", $_SESSION["des"][$device])) {
        # one or more display elements available
        selector_for_o($basic_tok);
    }
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "d")){
            # data
            stack_memory_selector($token);
            echo "<br>";
        }
    }
    display_as($basic_tok . "a", 0);
    echo "</h3></div>";
}

function create_an($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='an'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . "<br>";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more stack display elements available
        selector($basic_tok);
    }
    if (array_key_exists($basic_tok. "o0", $_SESSION["des"][$device])) {
        # one or more display elements available
        selector_for_o($basic_tok);
    }
    $dat = "";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "d")) {
            $dat .= $_SESSION["actual_data"][$device][$token]. ", ";
        }
    }
    echo " <marquee width='200'>" . $dat . "</marquee>" . " ";
    echo "<br>";
    display_as($basic_tok, 1);
    echo "</h3></div>";
}

function create_oa($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='oa'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ":<br>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token) {
        if (strstr($c_token, "d")) {
            # data
            $des_type = explode(";", $_SESSION["des"][$device][$c_token]);
            if (!($des_type[0] == "alpha")) {
                stack_memory_selector($c_token);
            }
            echo "<br>";
        }
    }
    display_as($basic_tok."a", 0);
    echo "</h3></div>";
}

function create_aa($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='aa'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    print count($_SESSION["original_announce"][$device]);
    other_selector($basic_tok."m0", "1_1to".count($_SESSION["original_announce"][$device]), $_SESSION["actual_data"][$device][$basic_tok."m0"]);
    # data
    # actual_data[$basic_tok."m0"] hold the position
    $dat_token = $basic_tok."m".$_SESSION["actual_data"][$device][$basic_tok."m0"];
    $dat = translate_received_data_type($dat_token, $_SESSION["actual_data"][$device][$dat_token]);
    echo " " . $dat . "<br>";
    display_as($basic_tok."a", 1);
    echo "</h3></div>";
}
function create_ob($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='ob'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ":<br>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (!strstr($token, "D")) {
            if (strstr($token, "m0")) {
                echo "number of elements: ";
            }
            elseif (strstr($token, "o0")){
                echo "start at: ";
            }
            $range = explode(",", $_SESSION["des"][$device][$token]);
            simple_selector($token, $range, $_SESSION["actual_data"][$device][$token]);
        }
        else {
            # data
            echo "<input type=text name=" . $token . " size = 20  placeholder =" . $_SESSION["actual_data"][$device][$token] . ">";
        }
        display_as($basic_tok. "a", 0);
    }
    echo "</h3></div>";
}

function create_ab($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='ab'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "m")) {
            if (strstr($token, "m0")) {
                echo "number of elements: ";
            }
            else{
                echo "start at: ";
            }
            $range = explode(",", $_SESSION["des"][$device][$token]);
            simple_selector($token, $range, $_SESSION["actual_data"][$device][$token]);
        }
        elseif (strstr($token, "x")) {
            # data
            if (!strstr($token, "x0")) {
                echo "<br>".explode(";", $_SESSION["des"][$device][$token])[2] . ": ";
                echo " " . $_SESSION["actual_data"][$device][$token];
            }
        }
        echo "<br>";
    }
    display_as($basic_tok. "a", 1);
    echo "</h3></div>";
}

function create_of($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='of'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    $number_of_elements = explode(",",$_SESSION["des"][$device][$basic_tok."m0"])[0];
    echo "up to ". $number_of_elements. " comma separated elements";
    echo "<input type=text name=" . $basic_tok."d0" . " size = 10 placeholder =" . $_SESSION["actual_data"][$device][$basic_tok."d0"] . ">";
    echo "<br>";
    display_as($basic_tok. "a", 0);
    echo "</h3></div>";
}

function create_af($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='af'>";
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    echo "<b>";
    echo "<marquee>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $key => $value){
        if (strstr($value, "d")){
            echo $_SESSION["actual_data"][$device][$value]. " ";
        }
    }
    echo "</marquee><br>number of elements";
    stack_memory_selector($basic_tok. "m0");
    display_as($basic_tok. "a", 1);
    echo "</h3></div>";
}

function display_as($tok, $display){
    # for "as"token
    $device = $_SESSION["device"];
    $tok = basic_tok($tok)."a";
    if (array_key_exists(basic_tok($tok), $_SESSION["ct_of_as"][$device]) or $display) {
        echo $_SESSION["user"]["language"][$_SESSION["user"]["username"]]["read_data"] . ": ";
        echo "<input type='checkbox' id=" . $tok . " name=" . $tok . " value=1>";
    }
    # reset
    $_SESSION["actual_data"][$device][$tok] = 0;
}

function actual_data_to_real($tok){
    # $_SESSION["to_correct"][$device][$tok] must exist
    $device = $_SESSION["device"];
    $data = $_SESSION["actual_data"][$device][$tok];
    if (!array_key_exists($tok, $_SESSION["to_correct"][$device])){return $data;}
    $range_elements = explode(",", $_SESSION["to_correct"][$device][$tok]);
    $act_value = 0;
    $i = 0;
    $found = 0;
    $result = "";
    while ($i < count($range_elements) and $found == 0){
        if (strstr($range_elements[$i], "_")){
           list ($separator, $from, $to) = split_range($range_elements[$i]);
           if ($separator <= 0){$separator = 1;}
           $temp_result = $from;
           while ($temp_result < $to and $found == 0){
               if ($act_value >= $data){
                   $found = 1;
                   $result = $temp_result;
               }
               $act_value += 1;
               $temp_result += $separator;
           }
        }
        else{
            if ($i >= $data){
                $found = 1;
                $result = $range_elements[$i];
            }
            $act_value += 1;
        }
        $i += 1;
    }
    return $result;
}
?>

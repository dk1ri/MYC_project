<?php
# create_commands.php
# DK1RI 20230608
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
        head_memory($basic_tok);
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
        if(strstr($tok,"a")) {
           display_as($tok);
        }
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
        head_memory($basic_tok);
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
        head_memory($basic_tok);
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
        elseif (strstr($tok, "a") and explode(",", $announce[0])[0] == "or") {
            display_as($tok);
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
        head_memory($basic_tok);
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
        head_memory($basic_tok);
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
        if (strstr($tok, "a")){
            display_as($tok);
        }
    }
    echo "</h3></div>";
}

function create_ap($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='ap'>";
    echo $_SESSION["des_name"][$device][$basic_tok]  . ": ";
    if (array_key_exists($basic_tok. "m0", $_SESSION["des"][$device])) {
        # one or more stack display elements available
        head_memory($basic_tok);
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
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ":<br>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "b")) {
            # memory- selector
            display_memory_selector($token);
            echo "<br>";
        }
        elseif(strstr($token, "x1")) {
            # data
            $destype =  explode(";",$_SESSION["des_type"][$device][$token]);
            echo $destype[2] . ": ";
            if ($destype[3] != ""){
                echo $destype[3] . ": ";
            }
            $dat = translate_received_data_type($token, $_SESSION["actual_data"][$device][$token]);
            echo "<input type=text name=" . $token . " size =" . display_length($destype[0])." placeholder =" . $dat . ">";
            echo "<br>";
        }
        elseif(strstr($token, "a")) {
            display_as($token);
        }
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
            echo "<br>";
        }
        elseif (strstr($token, "x1")) {
            echo explode(";", $_SESSION["des_type"][$device][$token])[2] . ": ";
            $dat = translate_received_data_type($token, $_SESSION["actual_data"][$device][$token]);
            echo " " . $dat;
            echo "<br>";
        }
        elseif(strstr($token, "a")) {
            display_as($token);
        }
    }
    echo "</h3></div>";
}

function create_on($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='on'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"];
    echo "<br>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "b")) {
            if (!strstr($token, "b0")) {
                # b0 is max number of transmitted elements -> not used
                if ($_SESSION["des_range"][$device][$token] != 0) {
                    # not for FIFO
                    display_memory_selector($token);
                    echo "<br>";
                }
            }
        }
        elseif (strstr($token, "x1")){
            # data
            $des_type = explode(";",$_SESSION["des_type"][$device][$token]);
            echo $des_type[2] . ": ";
            $max_elements = explode(",", $_SESSION["original_announce"][$device][basic_tok($token)][2])[0];
            echo "max: " . $max_elements . " elements ";
            $dat = $_SESSION["actual_data"][$device][$token];
            echo "<input type=text name=" . $token . " size = " . display_length($des_type[0])." placeholder =" . $dat . ">";
            echo "<br>";
        }
        elseif(strstr($token, "a")) {
            display_as($token);
        }
    }
    if(array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])){
        if(array_key_exists($basic_tok. "b1", $_SESSION["des_range"][$device])){
            if ($_SESSION["des_range"][$device][$basic_tok. "b1"] == 0) {
                # for FIFO
                display_memory_selector($basic_tok. "b0");
            }
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
            echo "<br>";
        } elseif (strstr($token, "x1")) {
            echo explode(";", $_SESSION["des_type"][$device][$token])[2] . ": ";
            $dat = $_SESSION["actual_data"][$device][$token];
          #  echo "<div class='marquee'><h3>". $dat. "</h3></div>";
            echo " <marquee width='200'>" . $dat . "</marquee>";
            echo "<br>";
        }
        elseif(strstr($token, "a")) {
            display_as($token);
        }
    }
    echo "</h3></div>";
}

function create_oa($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='oa'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ":<br>";
    $i = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token) {
        if (strstr($c_token, "x") and !strstr($c_token, "x0")) {
            # data
            $des_type = explode(";", $_SESSION["des_type"][$device][$c_token]);
            echo explode(";", $_SESSION["des_type"][$device][$c_token])[2] . ": ";
            if (!is_numeric(($des_type[0]))) {
                echo $des_type[4] . "-" . $des_type[5] . " ";
            }
            $dat = translate_received_data_type($c_token, explode(",", $_SESSION["actual_data"][$device][$c_token])[0]);
            echo "<input type=text name=" . $c_token . " size = " . display_length($des_type[0]) . " placeholder =" . strval($dat) . ">";
            echo "<br>";
        }
        elseif(strstr($c_token, "a")){
            display_as($basic_tok);
        }
        $i += 5;
    }
    echo "</h3></div>";
}

function create_aa($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='aa'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ": ";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token) {
        if (strstr($c_token, "b")) {
            $range = explode(",", $_SESSION["des_range"][$device][$c_token]);
            simple_selector($c_token, $range, $_SESSION["actual_data"][$device][$c_token]);
            echo "<br>";
        }
        elseif (strstr($c_token, "x")) {
            # data
            if (!strstr($c_token, "x0")) {
                if (count($_SESSION["original_announce"][$device][basic_tok($c_token)]) > 2) {
                    echo explode(";", $_SESSION["des_type"][$device][$c_token])[2] . ": ";
                }
                $dat = translate_received_data_type($c_token, explode(",", $_SESSION["actual_data"][$device][$c_token])[0]);
                echo " " . $dat . "<br>";
            }
        }
        elseif(strstr($c_token, "a")){
            display_as($c_token);
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
            if (strstr($token, "b0")) {
                echo "number of elements: ";
            }
            else{
                echo "start at: ";
            }
            $range = explode(",", $_SESSION["des_range"][$device][$token]);
            simple_selector($token, $range, $_SESSION["actual_data"][$device][$token]);
        }
        elseif(strstr($token, "d")) {
            # data
            if (!strstr($token, "x0")) {
                $des_type = explode(";", $_SESSION["des_type"][$device][$token]);
                $name =$des_type[2];
                if ($name != ""){
                    echo $des_type[2] . ": ";
                }
                echo "<input type=text name=" . $token . " size = " . display_length($des_type[0])." placeholder =" . $_SESSION["actual_data"][$device][$token] . ">";
            }
        }
        else {
            display_as($basic_tok. "a");
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
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "m")) {
            if (strstr($token, "m0")) {
                echo "number of elements: ";
            }
            else{
                echo "start at: ";
            }
            $range = explode(",", $_SESSION["des_range"][$device][$token]);
            simple_selector($token, $range, $_SESSION["actual_data"][$device][$token]);
        }
        elseif (strstr($token, "x")) {
            # data
            if (!strstr($token, "x0")) {
                echo "<br>".explode(";", $_SESSION["des_type"][$device][$token])[2] . ": ";
                echo " " . $_SESSION["actual_data"][$device][$token];
            }
        }
        else{
            echo "<br>";
            display_as($basic_tok. "a");
        }
    }
    echo "</h3></div>";
}

function head_memory($basic_tok){
    # create stack / memory display elements
    $device = $_SESSION["device"];
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $ctoken) {
        if (strstr($ctoken,"m") or  strstr($ctoken,"n")){
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
    }
}

function display_as($tok){
    # for "as"token
    $device = $_SESSION["device"];
    echo $_SESSION["user"]["language"][$_SESSION["user"]["username"]]["read_data"] . ": ";
    echo "<input type='checkbox' id=".$tok . " name=".$tok." value=1>";
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

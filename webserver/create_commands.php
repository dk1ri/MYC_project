<?php
# create_commands.php
# DK1RI 20230409
#The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
# creates display elements
function create_basic_command($basic_tok){
    $device = $_SESSION["device"];
    $field = explode(",", $_SESSION["actual_data"][$device][$basic_tok."a0"]);
    echo "<div>Device: " . $field[0] . ", Version: " . $field[1] . ", Author: ". $field[2];
    echo "<br>" . $_SESSION["user"]["language"][$_SESSION["user"]["username"]]["new_data"] . ": ";
    echo "<input type='checkbox' id=".$basic_tok . "a0 name=".$basic_tok."a0 value=1>";
    echo "</div>";
}

function create_os($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='op'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ": ";
    if (array_key_exists($basic_tok. "b0", $_SESSION["des_range"][$device])){
        head_stack($basic_tok);
    }
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "x0")) {
            echo "<select name=" . $tok . " id=" . $tok . ">";
            $field_x = $_SESSION["announce_all"][$device][$basic_tok . "x0"];
            $i = 1;
            while ($i < count($field_x)) {
                $switch = explode(",", $field_x[$i]);
                count($switch) > 1 ? $val = $switch[1] : $val = "x";
                echo "<option value=" . $switch[0];
                if ($switch[0] == $_SESSION["actual_data"][$device][$basic_tok . "x0"]) {
                    echo " selected";
                }
                echo ">" . $val . "</option>";
                $i += 1;
            }
            echo "</select>";
        } elseif(strstr($tok, "a0")) {
            display_as($tok,"read_data");
        }
    }
    echo "</h3></div>";
}

function create_as($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='as'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"];
    head_stack($basic_tok);
    $actual =$_SESSION["actual_data"][$device][$basic_tok."x0"];
    $label = explode(",",$_SESSION["announce_all"][$device][$basic_tok."x0"][$actual + 1])[1];
    echo  ": " . $label;
    echo "<br>" . $_SESSION["user"]["language"][$_SESSION["user"]["username"]]["new_data"] . ": ";
    echo "<input type='checkbox' id=".$basic_tok."a0" . " name=".$basic_tok."a0 value=1>";
    echo "</h3></div>";
}

function create_or_ar($basic_tok){
    # selecting a switch as operate will toggle the status
    echo "<div><h3 class='or'>";
    $device = $_SESSION["device"];
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ": ";
    if (array_key_exists($basic_tok. "b0", $_SESSION["des_range"][$device])){
        head_stack($basic_tok);
    }
    $announce = $_SESSION["original_announce"][$device][$basic_tok];
    echo "<br>";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "x")) {
            $announce = $_SESSION["announce_all"][$device][$tok];
            $actual = $_SESSION["actual_data"][$device][$tok];
            $f = explode(",", $announce[1]);
            count($f) > 1 ? $label = $f[1] : $label = "x";
            echo "<input type='checkbox' name=" . $tok . " id=" . $tok . " label=" . $tok . ">";
            if($actual == "0"){
                echo "<strong class = 'red'>";
            }
            else{
                echo "<strong class = 'green'>";
            }
            echo "<label for " .$tok . ">" . $label . "</label></strong><br>";
        }
        elseif (strstr($tok, "a0") and explode(",", $announce[0])[0] == "or") {
            display_as($tok,"read_data");
        }
    }
    echo "</h3></div>";
}

function create_ou($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='ou'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ": ";
    if (array_key_exists($basic_tok. "b0", $_SESSION["des_range"][$device])){
        head_stack($basic_tok);
    }
    $announce = $_SESSION["announce_all"][$device][basic_tok($basic_tok)."x0"];
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
    $count_zero = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if(strstr($tok, "b") or strstr($tok, "c") or strstr($tok, "x0")){continue;}
        elseif (strstr($tok, "x")) {
            if ($_SESSION["announce_all"][$device][$tok][1] < 255) {
                if (strstr($tok,"r")){echo "<br>";}
                $des = $_SESSION["des_range"][$device][$tok];
                if ($des == 0) {
                    $label  = "?";
                    # for default 3 times a "0" will apear
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
                    echo "<select name=" . $tok, " id=", $tok, ">";
                    $i = 0;
                    # discrete values only.
                    $des_a = explode(",", $des);
                    while ($i < count($des_a)) {
                        echo "<option value=", $des_a[$i];
                        if ($actual == $des_a[$i]) {
                            echo(" selected='selected'");
                        }
                        echo ">" . $des_a[$i + 1] . "</option>";
                        $i += 2;
                    }
                    echo "</select>";
                    if (!strstr($tok, "r") and !strstr($tok, "s") and !strstr($tok,"t")) {
                        echo $_SESSION["unit"][$device][$tok] . "<br>";
                    }
                    $count_zero = 0;
                }
            } else {
                if (strstr($tok, "r")){$label = "count";}
                elseif (strstr($tok, "s")){$label = "step";}
                elseif (strstr($tok, "t")){$label = "steptime";}
                else{$label = "value";}
                echo " new " . $label . ": ";
                echo "<input type='text' name = " . $tok . " size = 14 placeholder =" . $_SESSION["actual_data"][$device][$tok] . ">";
                if (!strstr($tok, "r") and !strstr($tok, "s") and !strstr($tok,"t")) {
                    echo $_SESSION["unit"][$device][$tok] . "<br>";
                }
            }
        }
        else{
            display_as($tok,"read_data");
        }
    }
    echo "</h3></div>";
}

function create_ap($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='ap'>";
    head_stack($basic_tok);
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $tok) {
        if (strstr($tok, "b")){continue;}
        if (strstr($tok, "x")) {
            if (!strstr($tok, "x0")) {
                # x0 is dummy
                #data
                echo $_SESSION["des_name"][$device][$tok] . ": ";
                echo $_SESSION["actual_data"][$device][$tok] . " ";
                echo $_SESSION["unit"][$device][$tok]."<br>";
            }
        }
        else {
            display_as($basic_tok. "a0", "new_data");
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
            echo "<br>";
        }
        elseif(strstr($token, "x1")) {
            # data
            $destype =  explode(";",$_SESSION["des_type"][$device][$token]);
            echo $destype[2] . ": ";
            $dat = $_SESSION["actual_data"][$device][$token];
            echo "<input type=text name=" . $token . " size =" . display_length($destype[0])." placeholder =" . $dat . ">";
            echo "<br>";
        }
        elseif(strstr($token, "a0")) {
            display_as($token, "read_data");
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
            $dat = $_SESSION["actual_data"][$device][$token."x1"][0];
            echo " " . $dat;
            echo "<br>";
        }
        elseif(strstr($token, "a0")) {
            display_as($token, "new_data");
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
        elseif(strstr($token, "a0")) {
            display_as($token, "read_data");
        }
    }
    if(array_key_exists($basic_tok, $_SESSION["as_token_as_to_basic"][$device])){
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
        elseif(strstr($token, "a0")) {
            display_as($token, "new_data");
        }
    }
    echo "</h3></div>";
}

function create_oa($basic_tok){
    $device = $_SESSION["device"];
    echo "<div><h3 class='oa'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ":<br>";
    $actual_pos = 0;
    $i = 0;
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $c_token) {
        if (strstr($c_token, "x") and !strstr($c_token, "x0")) {
            # data
            $des_type = explode(";", $_SESSION["des_type"][$device][$c_token]);
            $name = $des_type[2];
            if ($name != "") {
                echo $des_type[2] . ": ";
            }
            $dat = explode(",", $_SESSION["actual_data"][$device][$c_token])[$actual_pos];
            echo "<input type=text name=" . $c_token . " size = " . display_length($des_type[0]) . " placeholder =" . $dat . ">";
            echo "<br>";
        }
        elseif(strstr($c_token, "a0")){
            display_as($c_token, "read_data");
        }
        $i += 5;
    }
    echo "</h3></div>";
}

function create_aa($basic_tok) {
    $device = $_SESSION["device"];
    echo "<div><h3 class='aa'>";
    echo $_SESSION["des_name"][$device][$basic_tok. "x0"] . ": ";
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $token) {
        if (strstr($token, "b")) {
            $range = explode(",", $_SESSION["des_range"][$device][$token]);
            simple_selector($token, $range, $_SESSION["actual_data"][$device][$token]);
            echo "<br>";
        }
        elseif (strstr($token, "x")) {
            # data
            if (!strstr($token, "x0")) {
                if (count($_SESSION["original_announce"][$device][basic_tok($token)]) > 2) {
                    echo explode(";", $_SESSION["des_type"][$device][$token])[2] . ": ";
                }
                $dat = $_SESSION["actual_data"][$device][$token];
                echo " " . $dat . "<br>";
            }
        }
        else{
            display_as($token, "new_data");
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
        elseif(strstr($token, "x")) {
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
            display_as($token, "read_data");
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
        elseif (strstr($token, "x")) {
            # data
            if (!strstr($token, "x0")) {
                echo "<br>".explode(";", $_SESSION["des_type"][$device][$token])[2] . ": ";
                echo " " . $_SESSION["actual_data"][$device][$token];
            }
        }
        else{
            echo "<br>";
            display_as($token, "new_data");
        }
    }
    echo "</h3></div>";
}

function head_stack($basic_tok){
    # create stack display elements at first element of a command
    $device = $_SESSION["device"];
    foreach ($_SESSION["cor_token"][$device][$basic_tok] as $ctoken) {
        if (strstr($ctoken,"b") or strstr($ctoken,"c")){
            # for basic_tok only
            if ($basic_tok == basic_tok($ctoken)){
                $actual = $_SESSION["actual_data"][$device][$ctoken];
                echo $_SESSION["des_name"][$device][$ctoken] . ": ";
                $stacks = explode(",", $_SESSION["des_range"][$device][$ctoken]);
                simple_selector($ctoken, $stacks, $actual);
            }
        }
    }
}

function display_as($token,$label){
    # for "as"token
    $device = $_SESSION["device"];
    echo $_SESSION["user"]["language"][$_SESSION["user"]["username"]][$label] . ": ";
    echo "<input type='checkbox' id=" .$token . " name=" . $token . " value=1>";
    # reset
    $_SESSION["actual_data"][$device][$token] = 0;
}
?>
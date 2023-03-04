<?php
# split_to_display_objects.php
# DK1RI 20230227
function split_to_display_objects(){
    $device = $_SESSION["device"];
    $_SESSION["chapter_names"][$device] = "0,all,1,no_ADMINISTRATION";
    $_SESSION["chapter_index"][$device] = [];
    $_SESSION["chapter_token"][$device] = [];
    $_SESSION["announce_all"][$device] = [];
    $_SESSION["des_name"][$device] = [];
    $_SESSION["des_range"][$device] = [];
    $_SESSION["des_type"][$device] = [];
    $_SESSION["unit"][$device] = [];
    # create $_SESSION["original_announce"][$device] from announcefile
    if (file_exists("./devices/".$device."/announcements")) {
        $l = 2;
        $file = fopen("./devices/".$device . "/announcements", "r");
        while (!(feof($file))) {
            $pure = fgets($file);
            $pure = str_replace("\n", '', $pure);
            $pure = str_replace("\r", '', $pure);
            $field = explode(";", $pure);
            $token = $field[0];
            $lda =[];
            $i= 1;
            while ($i < count($field)) {
                if(!strstr($field[$i],"CHAPTER")) {
                    $lda[] = $field[$i];
                }
                $i += 1;
            }
            $_SESSION["original_announce"][$device][$token] =  $lda;
            $line = implode(";", $field);
            $pos = strpos($line, "CHAPTER");
            # referenced by index (that is what POST delivers for dospay
            $_SESSION["chapter_token"][$device][0][$token] = 1;
            $admin_pos = strpos($line, "14,CHAPTER,ADMINISTRATION");
            if (!$admin_pos){
                $_SESSION["chapter_token"][$device][1][$token] = 1;
            }
            # CHAPTER comes with all toks with required CHAPTER
            if ($pos) {
                $ar = explode("CHAPTER", "$line");
                $chap = explode(",", $ar[1])[1];
                $chap_comma = "," . $chap;
                if (!strstr($_SESSION["chapter_names"][$device], $chap_comma)) {
                    $_SESSION["chapter_names"][$device] .= ",". $l . "," . $chap;
                    $_SESSION["chapter_token"][$device][$l][$token] = 1;
                    $l += 1;
                }
                else {
                    $_SESSION["chapter_token"][$device][$chap][$token] = 1;
                }
            }
        }
        fclose($file);
    }
    # create display-objects and other data
    foreach ($_SESSION["original_announce"][$device] as $basic_tok => $announce_o) {
        $ctm = substr(explode(",", $announce_o[0])[0],1);
        if ($announce_o[0] == "m") {
            expand_m($basic_tok, $announce_o);
        }
        if ($ctm == "r" or $ctm == "s" or $ctm == "t" or $ctm == "u" or $ctm == "p" or $ctm == "o") {
            add_stack($basic_tok, $announce_o);
        }
        if ($ctm == "s" or $ctm == "t" or $ctm == "u") {
            expand_s($basic_tok, $announce_o);
        }
        if ($ctm == "r") {
            expand_r($basic_tok, $announce_o);
        }
        if ($ctm == "p") {
            expand_p($basic_tok, $announce_o);
        }
        if ($ctm == "o"){
            expand_o($basic_tok, $announce_o);
        }
        if ($ctm == "m" or $ctm == "n") {
            expand_m_n($basic_tok, $announce_o);
        }
        if ($ctm == "a" or $ctm == "b") {
            expand_a_b($basic_tok, $announce_o);
        }
    }
}

function add_stack($basic_tok, $announce_o){
    # for stacks:  additional lines are added as a selector
    $device = $_SESSION["device"];
    $ct = explode(",",$announce_o[0])[0];
    $stack = explode(",",$announce_o[1]);
    $stacks = (int)$stack[0];
    $max = explode(",", $announce_o[1])[0];
    if ($stacks > 1){
        # selectors necessary
        # remove $stacks:
        $t = array_splice( $stack,0, 1);
        if (!strstr($announce_o[1],"MUL")) {
            # no MUL no ADD
            # [name],[{max,[name],[{..}]]
            if (count($stack) == 0) {
                # no name, no range
                set_some($basic_tok, $stacks, $ct, $max);
                $_SESSION["des_name"][$device][$basic_tok . "b0"] = "stack";
            }
            if (count($stack) == 1) {
                if (!strstr($stack[0], "{")) {
                    # name only no range
                    set_some($basic_tok, $stacks, $ct, $max);
                    $_SESSION["des_name"][$device][$basic_tok . "b0"] = $stack[0];
                    $t = array_splice($stack, 0, 1);
                }
            }
            if (count($stack) > 0) {
                # name,{   } or {... }
                if (!strstr($stack[0], "{")) {
                    # name
                    set_some($basic_tok, $stacks, $ct, $max);
                    $_SESSION["des_name"][$device][$basic_tok . "b0"] = $stack[0];
                    $t = array_splice($stack, 0, 1);
                }
            }
            if (count($stack) > 0) {
                # {... }
                $value = implode(",", $stack);
                $value = str_replace("{", "", $value);
                $value =str_replace("}", "", $value);
                $_SESSION["des_range"][$device][$basic_tok . "b0"] = expand_range($value);
                $_SESSION["announce_all"][$device][$basic_tok . "b0"][0] = $ct;
                $_SESSION["announce_all"][$device][$basic_tok . "b0"][1] = $max;
            }
        }
        else{
            # stack: array: [name] {....MUL...}
            if (!strstr($stack[0], "{")) {
                # name is not used
                $t = array_splice( $stack,0, 1);
            }
            $stack_minus_max = implode(",", $stack);
            # remove { } at begin and end
            if (strpos("x" . $stack_minus_max, "{") == 1) {
                $stack_minus_max = substr($stack_minus_max, 1);
            }
            $last_char = substr($stack_minus_max, strlen($stack_minus_max));
            if($last_char == "}"){
                $stack_minus_max = substr($stack_minus_max, -1 );
            }
            $add = explode("ADD", $stack_minus_max);
            $mul = explode("MUL", $add[0]);
            $i = 0;
            while ($i < count($mul)) {
                # selections,[name],[{   }]
                $result = create_selector($basic_tok. "b". $i, $mul[$i],$_SESSION["user"]["language"][$_SESSION["user"]["username"]]["stack"]);
                $_SESSION["des_range"][$device][$basic_tok .  "b" . $i] = $result;
                $_SESSION["announce_all"][$device][$basic_tok .  "b" . $i][0] = $ct;
                $_SESSION["announce_all"][$device][$basic_tok . "b" . $i][1] = $max;
                $i += 1;
            }
            if (count($add) > 1) {
                $result = create_selector($basic_tok . "c0", $add[1], $_SESSION["user"]["language"][$_SESSION["user"]["username"]]["add"]);
                $_SESSION["des_range"][$device][$basic_tok . "c0"] = $result;
                $_SESSION["announce_all"][$device][$basic_tok . "c0"][0] = $ct;
                $_SESSION["announce_all"][$device][$basic_tok . "c0"][1] = $max;
            }
        }
    }
}

function expand_m($token, $announce){
    $device = $_SESSION["device"];
    $_SESSION["announce_all"][$device][$token][0] = $announce[0][0];
    $_SESSION["des_name"][$device][$token] = "basic_ command";

}

function expand_s($token, $announce){
    $device = $_SESSION["device"];
    # one element only
    $result[] = explode(",", $announce[0])[0];
    $i = 2;
    while ($i < count($announce)) {
        $result[] = $announce[$i];
        $i += 1;
    }
    $_SESSION["announce_all"][$device][$token . "x0"] = $result;
    count(explode(",",$announce[0])) > 1 ? $name = explode(",",$announce[0])[1]: $name = "1/n switch";
    $_SESSION["des_name"][$device][basic_tok($token) . "x0"] = $name;
    $ct = explode(",",$announce[0])[0];
    if($ct == "as" or $ct == "at"){
        $_SESSION["announce_all"][$device][basic_tok($token) . "a0"][0] = explode(",", $announce[0])[0];
    }
}

function expand_r($basic_tok, $announce){
    $device = $_SESSION["device"];
    count(explode(",",$announce[0])) > 1 ? $name = explode(",",$announce[0])[1]: $name = $_SESSION["user"]["language"][$_SESSION["user"]["username"]]["switch"];
    # one token per switch strating witg 0
    $ct = explode(",", $announce[0])[0];
    $i = 2;
    while ($i < count($announce)) {
        $sw = explode(",", $announce[$i]);
        $_SESSION["announce_all"][$device][$basic_tok . "x". ($i - 2)][] = $ct;
        $_SESSION["announce_all"][$device][$basic_tok . "x". ($i - 2)][] = ($i - 2) . "," . $sw[1];
        $_SESSION["des_name"][$device][basic_tok($basic_tok) . "x" .  ($i - 2)] = $name;
        $i += 1;
    }
    if($ct == "ar"){
        $_SESSION["announce_all"][$device][basic_tok($basic_tok) . "a0"][0] = explode(",", $announce[0])[0];
    }
}

function expand_p($basic_tok, $announce){
    $device = $_SESSION["device"];
    # split dimension
    # basic command: for name only
    $_SESSION["announce_all"][$device][$basic_tok . "x0"][0] = explode(",",$announce[0])[0];
    # dummy, x0 is used for name only, range is empty
    $_SESSION["des_range"][$device][$basic_tok . "x0"] = 1;
    count(explode(",", $announce[0])) > 1 ? $name = explode(",", $announce[0])[1] : $name = "value";
    $_SESSION["des_name"][$device][basic_tok($basic_tok) . "x0"] = $name;
    # dimensions:
    $dim = 2;
    $ip = 1;
    while ($dim < count($announce)) {
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $ip][0] = explode(",",$announce[0])[0];
        $max = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim])[0];
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $ip][1] = $max;
        $_SESSION["unit"][$device][$basic_tok . "x" . $ip] = $_SESSION["original_announce"][$device][$basic_tok][$dim + 2];
        if ($max < 256) {
            $desc_part = create_selector($basic_tok . "x" . $ip, $announce[$dim], "value");
            $_SESSION["des_range"][$device][$basic_tok . "x" . $ip] = $desc_part;
        }
        else{
            $_SESSION["des_range"][$device][$basic_tok . "x" . $ip] = $announce[$dim];
            $_SESSION["des_name"][$device][$basic_tok . "x" . $ip] = $name;
        }
        $dim += 3;
        $ip += 1;
    }
    $ct = explode(",",$announce[0]);
    if($ct[0] == "ap"){
        $_SESSION["announce_all"][$device][$basic_tok . "a0"][0] = explode(",", $announce[0])[0];
    }
}

function expand_o($basic_tok, $announce){
    $device = $_SESSION["device"];
    # split dimensions
    $no_use = 0;
    $i = 0;
    while ($i < count($announce)){
        if (strstr($announce[$i], "4,LOOP")) {
            # optional byte available
            $no_use += 1;
        }
        if (strstr($announce[$i], "6,LIMIT")) {
            # optional byte available
            $no_use += 1;
        }
        if (strstr($announce[$i], "a,0") or strstr($announce[$i], "a,1")) {
            # optional LOOP LIMIT available
            $no_use += 1;
        }
        $i += 1;
    }
    # basic command: for name only
    $_SESSION["announce_all"][$device][$basic_tok . "x0"][0] = explode(",",$announce[0])[0];
    # dummy:
    $_SESSION["des_range"][$device][$basic_tok . "x0"] = 1;
    count(explode(",", $announce[0])) > 1 ? $name = explode(",", $announce[0])[1] : $name = "rotate";
    $_SESSION["des_name"][$device][basic_tok($basic_tok) . "x0"] = $name;
    # dimensions:
    $dim = 2;
    $io = 1;
    while ($dim < (count($announce) - $no_use)){
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $io . "r"][0] = explode(",",$announce[0])[0];
        $max = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim])[0];
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $io . "r"][1] = $max;
        if ($max < 256) {
            $desc_part = create_selector($basic_tok . "x" . $io . "r", $announce[$dim], "steps");
            # add idle
            $a = explode(",", $desc_part);
            $desc_part_ = "0,idle";
            $i = 0;
            if($desc_part == 0){
                $desc_part_ = $desc_part;
            }
            else {
                while ($i < count($a)) {
                    $desc_part_ .= "," . ($a[$i] + 1) . "," . $a[$i + 1];
                    $i += 2;
                }
            }
            $_SESSION["des_range"][$device][$basic_tok . "x" . $io . "r"] = $desc_part_;
        }
        else{
            $_SESSION["des_range"][$device][$basic_tok . "x" . $io . "r"] = $announce[$dim];
        }
        #
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $io . "s"][0] = explode(",",$announce[0])[0];
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $io . "s"][1] = $max;
        if ($max < 256) {
            $desc_part = create_selector($basic_tok . "x" . $io . "s", $announce[$dim + 1], "stepsize");
            $_SESSION["des_range"][$device][$basic_tok . "x" . $io . "s"] = $desc_part;
        }
        else{
            $_SESSION["des_range"][$device][$basic_tok . "x" . $io . "s"] = $announce[$dim + 1];
        }
        #
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $io . "t"][0] = explode(",",$announce[0])[0];
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $io . "t"][1] = $max;
        if ($max < 256) {
            $desc_part = create_selector($basic_tok . "x" . $io . "t", $announce[$dim + 2], "steptime");
            $_SESSION["des_range"][$device][$basic_tok . "x" . $io . "t"] = $desc_part;
        }
        else{
            $_SESSION["des_range"][$device][$basic_tok . "x" . $io] = $announce[$dim + 2];
        }
        $dim += 4;
        $io += 1;
    }
}


function expand_m_n($basic_tok, $announce){
    # create display-object for each row, column and data
    # first row (or count) at pos 3 of announcement
    $device = $_SESSION["device"];
    $ct = explode(",",$announce[0]);
    count($ct) > 1 ? $name = $ct[1] : $name = "memory";
    # for selectors one display-object (tok) per dimension
    # tok;ct;dimension_data
    $row_col = 2;
    while ($row_col < count($announce)){
        $tok = $basic_tok . "b" . strval($row_col - 2);
        # announce_all
        $_SESSION["announce_all"][$device][$tok][0] = $ct[0];
        # des_range
        if (($ct[0] == "on" or $ct[0] == "an") and $row_col == 2) {
            $desc_part = create_selector($basic_tok . "b" . strval($row_col - 2), $announce[$row_col], "elements");
        }
        else{
            $desc_part = create_selector($basic_tok . "b" . strval($row_col - 2), $announce[$row_col], "position");
        }
        $_SESSION["des_range"][$device][$tok] = $desc_part;
        $row_col += 1;
    }
    # data
    $_SESSION["des_name"][$device][basic_tok($basic_tok) . "x0"] = $name;
    $_SESSION["announce_all"][$device][$basic_tok . "x0"][0] = $ct[0];
    $_SESSION["announce_all"][$device][$basic_tok . "x1"][0] = $ct[0];
    # des-type
    $typ_a = explode(",", $announce[1]);
    $_SESSION["des_type"][$device][$basic_tok . "x1"] = add_type($typ_a);
    if($ct[0] == "am" or $ct[0] == "an"){
        $_SESSION["announce_all"][$device][$basic_tok . "a0"][0] = $ct[0];
    }
}

function expand_a_b($basic_tok, $announce){
    # [ b0 and b1] one tok per <ty> element
    $device = $_SESSION["device"];
    $name = "array element";
    $ct = explode(",", $announce[0]);
    if (count($ct) > 1) {
        $name = $ct[1];
    }
    $_SESSION["des_name"][$device][basic_tok($basic_tok) . "x0"] = $name;
    # sequence determines the display - sequence -> do this first:
    if (count($announce) > 2) {
        # additional selector for <ty>
        $_SESSION["announce_all"][$device][$basic_tok . "b0"][0] = $ct[0];
        $_SESSION["des_name"][$device][$basic_tok . "b0"] = $name;
        if ($ct[0] == "ob" or $ct[0] == "ab") {
            $_SESSION["announce_all"][$device][$basic_tok . "b1"][0] = $ct[0];
            $_SESSION["des_name"][$device][$basic_tok . "b1"] = $name;
        }
        # x0 used for basic name
        $_SESSION["announce_all"][$device][$basic_tok . "x0"][0] = $ct[0];
        $_SESSION["des_name"][$device][$basic_tok . "x0"] = $name;
        # ob /ab as number of elements to transmit
        # des_type stat with "x1"
    }
    # then calculate the type
    $i = 1;
    $j = 1;
    while ($i < count($announce)) {
        $typ_a = explode(",", $announce[$i]);
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $j][0] = $ct[0];
        $_SESSION["des_name"][$device][basic_tok($basic_tok) . "x" . $j] = $name;
        $_SESSION["des_type"][$device][$basic_tok . "x" . $j] = add_type($typ_a);
        $i += 1;
        $j += 1;
    }
    if (count($announce) > 2) {
        # add selector for more than 2 elements
        $li = "";
        $li_n = "0,0,";
        $i = 1;
        $j = 1;
        $found = 1;
        while ($found) {
            $tok = $basic_tok . "x" . $i;
            if (!array_key_exists($tok, $_SESSION["des_type"][$device])) {
                $found = 0;
            } else {
                if ($_SESSION["des_type"][$device][$tok][0] != "f") {
                    # ignore exponent
                    if ($j != 1) {
                        $li .= ",";
                        $li_n .= ",";
                    }
                    $value = explode(";", $_SESSION["des_type"][$device][$tok])[2];
                    $li .= strval($j - 1) . "," . $j . "_" . $value;
                    $li_n .= $j . "," . $j;
                    $j += 1;
                }
            }
            $i += 1;
        }
        $_SESSION["des_range"][$device][$basic_tok . "b0"] = $li_n;
        # additional selector for <ty> (number for b and) position
        $_SESSION["des_range"][$device][$basic_tok . "b1"] = $li;
    }
    if($ct[0] == "ab" or $ct[0] == "aa"){
        $_SESSION["announce_all"][$device][$basic_tok . "a0"][0] = $ct[0];
    }
}

function add_type($desc){
    #create des_type
    # $desc: array: type [CODING] [name] [{...}]
    # return:type;CODING;name;range;startvalue;allowed (some may be empty
    $typ = $desc[0];
    if ($typ == "s" or $typ == "d") {
        # add exponent
        return "f;;exponent;0 to 255;0;;end";
    }
    # else
    $type = $typ . ";;;;;;end";
    $type_a = explode(";", $type);
    if (is_numeric($desc[0])){
        $type_a[2] = "alpha";
        $type_a[3] = "ALPHA";
        $type_a[4]= "a";
    }
    else {
        $type_a[5] .= find_allowed($desc[0]);
        $type_a[4]= "0";
        # default, may be overwritten
        $type_a[2] =  $type_a[5];
    }
    # eliminate type:
    $t = array_splice($desc,0, 1);
    if (count($desc) > 0){
        $upcase = strtoupper($desc[0]);
        if ($upcase == $desc[0]){
            $type_a[1] = $desc[0];
            $t = array_splice($desc,0, 1);
        }
    }
    if (count($desc) > 0){
        if (!strstr($desc[0], "{")){
            $type_a[2] = $desc[0];
            $t = array_splice($desc,0, 1);
        }
    }
    if (count($desc) > 0){
        # {...,.},xxx
        $desc = implode(",", $desc);
        $desc = explode("}", $desc);
        $desc = str_replace("{", "", $desc[0]);
        $type_a[3] = $desc;
        # find displaystart
        $desc_a = explode(",", $desc);
        if (!strstr($desc_a[0], "_") and !strstr($desc_a[0], "to")){
           $type_a[4] = $desc_a[0];
        }
        else{
            $type_a[4]  = explode("_", explode("to",$desc_a[0])[0])[1];
        }
    }
    return implode(";",$type_a);
}

function create_selector($tok, $desc, $default_name){
    # for p, o, m, n commands and stack
    # desc in: max,[label][,{desranges}][,additional]
    #out: $_SESSION["des_name"][$device][$tok]
    # return: for full (expanded) range
    $name = $default_name;
    $device = $_SESSION["device"];
    $result = "";
    $desca = explode(",",$desc);
    # max:
    $max = 0;
    if ($desca[0] != 0) {
        $max = (int)$desca[0] - 1;
    }
    else{
        # FIFO
        $result = "0";
    }
    $t = array_splice($desca,0,1);
    # max stripped
    # name:
    if (count($desca)> 0) {
        if (!strstr($desca[0], "{")) {
            $name = $desca[0];
            if ($name =="ADD"){
                if (!strstr($desca[1],"{")){
                    $name = $desca[1];
                    $t = array_splice($desca, 0, 1);
                }
                else {
                    $name = "adder";
                }
            }
            $t = array_splice($desca, 0, 1);
        }
    }
    if (count($desca)> 0) {
        # leave { , },add
        $descb = explode("}", $desc)[0];
        $result = expand_range(explode("{", $descb)[1]);
    }
    if ($result == ""){
        $result = expand_range("1_0to". $max);
    }
    $name = str_replace("}", "", $name);
    $_SESSION["des_name"][$device][$tok] = $name;
    return $result;
}
function expand_range($value){
    # in: a,b,c,ntom,....
    # return: sequence of values
    $i = 0;
    $result = "";
    $value_a = explode(",",$value);
    $k = 0;
    while ($i < count($value_a)){
        if(strstr($value_a[$i], "to") and strstr($value_a[$i], "_")){
            $split_to = explode("to",$value_a[$i]);
            $split__ = explode("_", $split_to[0]);
            $j = $split__[1];
            $to = $split_to[1];
            $spacing = $split__[0];
            while ($j <= $to){
                if ($k != 0){
                    $result .= ",";
                }
                $result .= $k . ",". $j;
                $j += $spacing;
                $k += 1;
            }
        }
        else{
            if ($k != 0){
                $result .= ",";
            }
            $result .= $k. "," . $value_a[$i];
            $k += 1;
        }
        $i += 1;
    }
    return $result;
}

function add_selector_for_max($all_selections){
    $i = 0;
    $result = "";
    while ($i < $all_selections){
        if ($i != 0){
            $result .= ",";
        }
        $result .= $i. ",". $i;
        $i += 1;
    }
    return $result;
}

function set_some($basic_tok, $stacks, $ct, $max){
    $device = $_SESSION["device"];
    $_SESSION["des_range"][$device][$basic_tok . "b0"] = add_selector_for_max($stacks);
    $_SESSION["announce_all"][$device][$basic_tok . "b0"][0] = $ct;
    $_SESSION["announce_all"][$device][$basic_tok . "b0"][1] = $max;
}
?>
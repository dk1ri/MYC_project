<?php
# split_to_display_objects.php
# DK1RI 20230121
function split_to_display_objects(){
    $device = $_SESSION["device"];
    $_SESSION["chapter_names"][$device] = [];
    $_SESSION["chapter_names"][$device][] = "all";
    $_SESSION["chapter_token"][$device] = [];
    $_SESSION["announce_all"][$device] = [];
    $_SESSION["des_name"][$device] = [];
    $_SESSION["des_range"][$device] = [];
    $_SESSION["des_type"][$device] = [];
    # create $_SESSION["original_announce"][$device] from announcefile
    if (file_exists($device."/announcements")) {
        $file = fopen($device . "/announcements", "r");
        while (!(feof($file))) {
            $pure = fgets($file);
            $pure = str_replace("\n", '', $pure);
            $pure = str_replace("\r", '', $pure);
            $field = explode(";", $pure);
            $token = $field[0];
            $t = array_slice($field, 1);
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
            $_SESSION["chapter_token"][$device]["all"][$token] = 1;
            # CHAPTER comes with all toks with required CHAPTER
            if ($pos) {
                $ar = explode("CHAPTER", "$line");
                $chap = explode(",", $ar[1])[1];
                if (!in_array($chap, $_SESSION["chapter_names"][$device])) {
                    $_SESSION["chapter_names"][$device][] = $chap;
                }
                $_SESSION["chapter_token"][$device][$chap][] = $token;
            }
            $_SESSION["original_announce"][$device][$token] = $lda;
        }
        fclose($file);
    }
    # create display-objexts and other data
    foreach ($_SESSION["original_announce"][$device] as $basic_tok => $announce) {
        $ctm = substr(explode(",", $announce[0])[0],1);
        if ($ctm == "r" or $ctm == "s" or $ctm == "t" or $ctm == "u" or $ctm == "p") {
            add_stack($basic_tok, $announce);
        }
        if ($ctm == "s" or $ctm == "t" or $ctm == "u") {
            expand_s($basic_tok, $announce);
        }
        if ($ctm == "r") {
            expand_r($basic_tok, $announce);
        }
        if ($ctm == "p") {
            expand_p($basic_tok, $announce);
        }
        if ($ctm == "o"){
            expand_o($basic_tok, $announce);
        }
        if ($ctm == "m" or $ctm == "n") {
            expand_m_n($basic_tok, $announce);
        }
        if ($ctm == "a") {
            expand_a($basic_tok, $announce);
        }
        if ($ctm == "b") {
            expand_b($basic_tok, $announce);
        }
    }
}

function add_stack($basic_tok, $field){
    # for stacks:  additional lines are added as a selector
    $device = $_SESSION["device"];
    $ct = explode(",",$field[0])[0];
    $stack = explode(",",$field[1]);
    $stacks = (int)$stack[0];
    if ($stacks > 1){
        # selectors necessary
        $t = array_splice( $stack,0, 1);
        if (!strstr($field[1],"MUL")) {
            # no MUL no ADD
            # [name],[{max,[name],[{..}]]
            if (count($stack) == 0) {
                # no name, no range
                $_SESSION["des_name"][$device][$basic_tok . "b0"] = "stack";
                $_SESSION["des_range"][$device][$basic_tok . "b0"] = add_selector_for_max($stacks);
                $_SESSION["announce_all"][$device][$basic_tok . "b0"][0] = explode(",", $field[0])[0];
            }
            if (count($stack) == 1) {
                if (!strstr($stack[0], "{")) {
                    # name only no range
                    $_SESSION["des_name"][$device][$basic_tok . "b0"] = $stack[0];
                    $_SESSION["des_range"][$device][$basic_tok . "b0"] = add_selector_for_max($stacks);
                    $_SESSION["announce_all"][$device][$basic_tok . "b0"][] = $ct;
                    $t = array_splice($stack, 0, 1);
                }
            }
            if (count($stack) > 0) {
                # name,{   } or {... }
                if (!strstr($stack[0], "{")) {
                    # name
                    $_SESSION["des_name"][$device][$basic_tok . "b0"] = $stack[0];
                    $_SESSION["des_range"][$device][$basic_tok . "b0"] = add_selector_for_max($stacks);
                    $_SESSION["announce_all"][$device][$basic_tok . "b0"][] = $ct;
                    $t = array_splice($stack, 0, 1);
                }
            }
            if (count($stack) > 0) {
                # {... }
                $value = str_replace("{", "", $stack[0]);
                $value =str_replace("}", "", $value);
                $_SESSION["des_range"][$device][$basic_tok . "b0"] = expand_range($value);
                $_SESSION["announce_all"][$device][$basic_tok . "b0"][] = $ct;
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
                $result = create_selector($basic_tok. "b". $i, $mul[$i], "stack");
                $_SESSION["des_range"][$device][$basic_tok .  "b" . $i] = $result;
                $_SESSION["announce_all"][$device][$basic_tok .  "b" . $i][] = $ct;
                $i += 1;
            }
            if (count($add) > 1) {
                $result = create_selector($basic_tok . "c0", $add[1], "ADD");
                $_SESSION["des_range"][$device][$basic_tok . "c0"] = $result;
                $_SESSION["announce_all"][$device][$basic_tok . "c0"][] = $ct;
            }
        }
    }
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
    $ct = explode(",",$announce[0]);
    if($ct[0] == "as"){
        $_SESSION["announce_all"][$device][basic_tok($token) . "a0"][0] = explode(",", $announce[0])[0];
    }
}

function expand_r($token, $announce){
    $device = $_SESSION["device"];
    # one element per switch
    $ct = explode(",", $announce[0])[0];
    $result[] = $ct;
    if ($ct == "or") {
        $result[] = "0,all_off";
        $i = 2;
        # the real swichtes start with 1 now
        while ($i < count($announce)) {
            $sw = explode(",", $announce[$i]);
            $result[] = $i - 1 . "," . $sw[1];
            $i += 1;
        }
    }
    else{
        $i = 2;
        while ($i < count($announce)) {
            $sw = explode(",", $announce[$i]);
            $result[] = $i - 2 . "," . $sw[1];
            $i += 1;
        }
    }
    $_SESSION["announce_all"][$device][$token . "x0"] = $result;
    count(explode(",",$announce[0])) > 1 ? $name = explode(",",$announce[0])[1]: $name = "switch";
    $_SESSION["des_name"][$device][basic_tok($token) . "x0"] = $name;
    $ct = explode(",",$announce[0]);
    if($ct[0] == "ar"){
        $_SESSION["announce_all"][$device][basic_tok($token) . "a0"][0] = explode(",", $announce[0])[0];
    }
}

function expand_p($basic_tok, $announce){
    $device = $_SESSION["device"];
    # split dimension
    $ip = 1;
    # basic command: for name only
    $_SESSION["announce_all"][$device][$basic_tok . "x0"][0] = explode(",",$announce[0])[0];
    # dummy, x0 is used for name only, range is empty
    $_SESSION["des_range"][$device][$basic_tok . "x0"] = 1;
    count(explode(",", $announce[0])) > 1 ? $name = explode(",", $announce[0])[1] : $name = "value";
    $_SESSION["des_name"][$device][basic_tok($basic_tok) . "x0"] = $name;
    # dimensions:
    $_SESSION["des_range"][$device][$basic_tok . "x0"] = "";
    $dim = 2;
    while ($dim < count($announce)) {
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $ip][0] = explode(",",$announce[0])[0];
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $ip][1] = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim])[0];
        $desc_part = create_selector($basic_tok . "x" . $ip, $announce[$dim] , "value");
        $_SESSION["des_range"][$device][$basic_tok . "x" . $ip] = $desc_part;
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
        $desc_part = create_selector($basic_tok . "x" . $io . "r", $announce[$dim] , "steps");
        $_SESSION["des_range"][$device][$basic_tok . "x" . $io . "r"] = $desc_part;
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $io . "r"][1] = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim])[0];
        #
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $io . "s"][0] = explode(",",$announce[0])[0];
        $desc_part = create_selector($basic_tok . "x" . $io . "s", $announce[$dim + 1] , "stepsize");
        $_SESSION["des_range"][$device][$basic_tok . "x" . $io . "s"] = $desc_part;
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $io . "s"][1] = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim])[0];
        #
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $io . "t"][0] = explode(",",$announce[0])[0];
        $desc_part = create_selector($basic_tok . "x" . $io . "t", $announce[$dim + 2] , "steptime");
        $_SESSION["des_range"][$device][$basic_tok . "x" . $io . "t"] = $desc_part;
        $_SESSION["announce_all"][$device][$basic_tok . "x" . $io . "t"][1] = explode(",", $_SESSION["original_announce"][$device][$basic_tok][$dim])[0];
        $dim += 4;
        $io += 1;
    }
}


function expand_m_n($basic_tok, $announce){
    # create display-object for each row, column and data
    # first row (or count) at pos 3
    $device = $_SESSION["device"];
    $ct = explode(",",$announce[0]);
    count($ct) > 1 ? $name = $ct[1] : $name = "memory";
    # for selectors one display-object (tok) per dimension
    # tok;ct;dimension_data
    $row_col = 2;
    while ($row_col < count($announce)){
        $tok = $basic_tok . "b" . strval($row_col - 2);
        # announce_all
        $_SESSION["announce_all"][$device][$tok][0] = explode(",",$announce[0])[0];
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
    # des-type
    $typ_a = explode(",", $announce[1]);
    $_SESSION["des_type"][$device][$basic_tok . "x0"] = add_type($typ_a);
    if($ct[0] == "am" or $ct[0] == "an"){
        $_SESSION["announce_all"][$device][$basic_tok . "a0"][0] = $ct[0];
    }
}

function expand_a($basic_tok, $announce){
    # [one b0 and] one x0 display element
    $device = $_SESSION["device"];
    $name = "array element";
    $ct = explode(",",$announce[0]);
    if (count($ct) > 1) {
        $name = $ct[1];
    }
    # selector for more than one <ty> element
    if (count($announce) > 2) {
        # additional selector for <ty>
        $_SESSION["announce_all"][$device][$basic_tok . "b0"][0] = $ct[0];
        $_SESSION["des_name"][$device][$basic_tok . "b0"] = $name;
        $li = "";
        $i = 1;
        while ($i < count($announce)) {
            $typ_a = explode(",", $announce[$i]);
            $type = add_type($typ_a);
            # $type : type,allowed,start,name,{..}
            $type_b = explode(",", $type);
            if ($i != 1){
                $li .= ",";
            }
            $li .= strval($i - 1) . "," . strval($i - 1) . "_" . $type_b[3] . ": " . $type_b[1];
            $i += 1;
        }
        $_SESSION["des_range"][$device][$basic_tok . "b0"] = $li;
    }
    # des_type
    $i = 1;
    $type = "";
    while ($i < count($announce)){
        $typ_a = explode(",",$announce[$i]);
        if($i != 1){
            $type .= ";";
        }
        $type .= add_type($typ_a);
        $i += 1;
    }
    $_SESSION["des_type"][$device][$basic_tok . "x0"] = $type;
    #
    $_SESSION["announce_all"][$device][$basic_tok . "x0"][0] = $ct[0];
    $_SESSION["des_name"][$device][$basic_tok . "x0"] = $name;
    if($ct[0] == "aa"){
        $_SESSION["announce_all"][$device][$basic_tok . "a0"][0] = $ct[0];
    }
}

function  expand_b($basic_tok, $announce){

}

function add_type($desc){
    #create des_type
    # array: type [name] [{...}]
    # return: type,allowed,start,name,{..}
    $type = $desc[0] . ",";
    if (is_numeric($desc[0])) {
        $type .= "alpha,a";
    }
    else {
        $type .= find_allowed($desc[0]) . ",0";
    }
    $name = find_name($desc[0]);
    if (count($desc) == 1) {
        $type .= "," . $name . ",{}";
    }
    if (count($desc) == 2) {
        if (strstr($desc[1],"{")) {
            $type .= "," . $name . "," . $desc[1];
        }
        else {
            $type .= "," . $desc[1] . ",{}";
        }
    }
    if (count($desc) == 3) {
        $type .= "," . $desc[1] . "," . $desc[2];
    }
    return $type;
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
    $temp = array_splice($desca,0,1);
    # max stripped
    # name:
    if (count($desca)> 0) {
        if (!strstr($desca[0], "{")) {
            $name = $desca[0];
            if ($name =="ADD"){
                if (!strstr($desca[1],"{")){
                    $name = $desca[1];
                    $temp = array_splice($desca, 0, 1);
                }
                else {
                    $name = "adder";
                }
            }
            $temp = array_splice($desca, 0, 1);
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

function double($result){
    $i = 0;
    $result_a = explode(",", $result);
    $result = "";
    while ( $i < count($result_a)){
        if ($i != 0){
            $result .= ",";
        }
        $result .= $i. "," .$result_a[$i];
        $i += 1;
    }
    return $result;
}
?>
<?php
function read_new_device($device){
    #create additional device (old ones not deleted)
    read_chapter_names($device);
    $chapter = $_SESSION["chapter_names"][$device][0];
    $_SESSION["chapter"] = $chapter;
    $_SESSION["announce_lines"][$device][$chapter] = [];
    foreach ($_SESSION["chapter_names"][$device] as $chapt) {
        readchapter($device, $chapt);
    }
    find_all_token($device);
    find_selector_tokens($device);
    or_ar_tokens($device);
    calculate_tok_len($device);
    calculate_sel_len($device);
    calculate_p_len($device);
    calculate_p_token($device);
    calculate_tok_hex($device);
    calculate_max_mul($device);
    prepare_des($device);
    read_data($device);
}

function read_chapter_names($device){
    $_SESSION["chapter_names"][$device] = array();
    $handle = opendir($device);
    while ($d_name = readdir($handle)){
        if (strstr($d_name, "announce_lines_")){
            $_SESSION["chapter_names"][$device][] = explode("announce_lines_", $d_name)[1];
        }
    }
}

function readchapter($device, $chapter){
    $_SESSION["all_announce"][$device] = [];
    if (file_exists($device."/announce_lines_".$chapter) == true) {
        $file = fopen($device."/announce_lines_". $chapter, "r");
        while (!(feof($file))) {
            $pure = fgets($file);
            $pure = str_replace("\n", '', $pure);
            $pure = str_replace("\r", '', $pure);
            $field = explode(";", $pure);
            $key = $field[0];
            $value = array_slice($field,1);
            $_SESSION["announce_lines"][$device][$chapter][$key] = $value;
            $_SESSION["all_announce"][$device][$key] = $value;
        }
        fclose($file);
    }
}

function find_all_token($device){
    foreach ($_SESSION["all_announce"][$device] as $token => $line_as_array){
        $_SESSION["all_token"][$device][] = explode(";",$token)[0];
    }
}

# to speed up operation
# token "_"token ... "a"token
# sequence in announcefile is: "_"token..."a"token token
# not splitted by chapter
function find_selector_tokens($device){
    $_SESSION["sele_toks"][$device] = [];
    $_SESSION["number_of_selects"][$device] = [];
    foreach ($_SESSION["all_announce"][$device] as $token => $line_as_array){
        $tok = basic_tok($token, "_");
        $tok = basic_tok($tok, "a");
        if ((strstr($token, "_") != false) or (strstr($token, "a") != false)){
            if (!array_key_exists($tok, $_SESSION["sele_toks"][$device])) {
                $_SESSION["sele_toks"][$device][$tok] = [];
                $_SESSION["number_of_selects"][$device][$tok] = [];
            }
            $_SESSION["sele_toks"][$device][$tok][] = $token;
            $val = count($_SESSION["all_announce"][$_SESSION["device"]][$token]) - 2;
            $_SESSION["number_of_selects"][$device][$tok][] = $val;
        }
        #else: token for selector or other token
    }
}

function read_data($device){
    # read data form device: hex, as send by device
    # create all_real_data for all token (including selectors, op dimension etc)
    $orgdata = [];
    if (file_exists($device . "/_all_answer_data")) {
        $file = fopen($device . "/_all_answer_data", "r");
        while (!(feof($file))) {
            $pure = fgets($file);
            $pure = str_replace("\n", '', $pure);
            $pure = str_replace("\r", '', $pure);
            # must have 2 elements:
            $key_val = explode(" ", $pure);
            $orgdata[$key_val[0]] = $key_val[1];
        }
        fclose($file);
        foreach ($_SESSION["all_announce"][$device] as $key => $value) {
            $tok = basic_tok_all($key);
            if (array_key_exists($tok, $orgdata)) {
                $dat = $orgdata[$tok];
            } else {
                $dat = "";
            }
            $r_data = analyze_trx_data($key, $value, $device, $dat);
            translate_data($r_data, $device, $key, $value);
        }
    } else {
        foreach ($_SESSION["all_announce"][$device] as $key => $value) {
            $r_data[$key] = 0;
        }
        translate_data($r_data, $device, $key, $value);
    }
}

function or_ar_tokens($device){
    # $POST do not deliver data if form select multiple has nothing selected, but otherwise  alway.
    # all_real_data must be set to 0 for all position in this case.
    foreach ($_SESSION["all_announce"][$_SESSION["device"]] as $token => $line_as_array) {
        $_SESSION["or_ar_tokens"][$device] = [];
        $ct = explode(",", $line_as_array[0])[0];
        if ($ct == "or" or $ct == "ar") {
            # only, if selectors > 1
            if (count($_SESSION["all_announce"][$_SESSION["device"]][$token]) > 2){
                $_SESSION["or_ar_tokens"][$device][] = $token;
            }
        }
    }
}

function calculate_tok_len($device){
    $_SESSION["tok_len"][$device] = [];
    foreach ($_SESSION["all_announce"][$device] as $key => $value){
        $_SESSION["tok_len"][$device] = calculate_len($key);
        break;
    }
}

function calculate_sel_len($device){
    # selecttoken with value, other tokeen =
    $_SESSION["sel_len"][$device] = [];
    $sel_old = 0;
    foreach ($_SESSION["all_announce"][$device] as $key => $value) {
        # not for memories
        $ct = explode(",",$value[0])[0][1];
        if (!($ct == "m" or $ct == "n" or $ct == "a" or $ct == "b" or $ct == "f")) {
            if (strstr($key,"_") or strstr($key,"a")) {
                $no_pos =  count($value) + 1;
                if ($no_pos == 1) {
                    $_SESSION["sel_len"][$device][$key] = 0;
                    $sel_old = 0;
                } else {
                    $_SESSION["sel_len"][$device][$key] = calculate_len($no_pos);
                    $sel_old = calculate_len($no_pos);
                }
            } else{
                $_SESSION["sel_len"][$device][$key] = $sel_old;
                if (!strstr($key,"p")){
                    # keep sel_old for px commands reset for otherd
                    $sel_old = 0;
                }
             }
        } else {
            # memories
            $_SESSION["sel_len"][$device][$key] = 0;
        }
    }
}
function calculate_p_len($device){
    # op ap token (one dimension) with value, others 0
    $_SESSION["p_len"][$device] = [];
    foreach ($_SESSION["all_announce"][$device] as $key => $value) {
        $ct = explode(",",$value[0])[0];
        if ($ct == "op" or $ct == "ap") {
            $_SESSION["p_len"][$device][$key] = calculate_len(explode(",",$value[2])[0]);
        } else {
            $_SESSION["p_len"][$device][$key] = 0;
        }
    }
}

function calculate_p_token($device){
  #  $_SESSION["p_token"][$device] = [];
    foreach ($_SESSION["all_announce"][$device] as $key => $value) {
        $ct = explode(",",$value[0])[0];
        if ($ct == "op" or $ct == "ap") {
            $i = 3;
            while ($i < count($value)){
                $_SESSION["p_token"][$device][] = $key;
                $i += 3;
            }
        }
    }
}

function calculate_tok_hex($device){
    # return basic tok also for selector toks
    $_SESSION["tok_hex"][$device] = [];
    foreach ($_SESSION["all_announce"][$device] as $key => $value) {
        $tok = basic_tok($key,"_");
        $tok = basic_tok($tok,"a");
        $_SESSION["tok_hex"][$device][$key] = dec_hex($tok, $_SESSION["tok_len"][$device]);
    }
}

function calculate_max_mul($device){
    $_SESSION["maxsel"][$device] = [];
    # for selectors with "ADD" calculate the maximum value of MUL
    foreach ($_SESSION["all_announce"][$device] as $key => $field) {
        if( strstr($key,"_") == false and strstr($key,"a") == false){
            if (strstr( $field[1], "ADD") != false){
                # selectorline with ADD
                $add = explode("ADD", $field[1]);
                # the ADD selectornames are in{}
                $selector_na = explode("{", $add[1]);
                $max_sel = explode(",",$field[1])[0];
                $max_sel -= count(explode(",", $selector_na[1]));
                # + 1: first ADD selector is 0
                $_SESSION["maxsel"][$device][$key] = $max_sel + 1;
            }
        }
    }
}

function prepare_des($device){
    # create $SESSION["des"] for op ap oo commands:
    # name spacing from to <spacing ....
    # commands <token>px have one dimension each only!!
    foreach ($_SESSION["all_announce"][$device] as $key => $field) {
        $cta = explode(",",$field[0]);
        if ($cta[0] == "op" or $cta[0] == "ap"){
            # op ap only
            $l_name = "range";
            $u_field = $field[2];
            $_SESSION["des"][$device][$key]= [];
            $desc = explode(",", $u_field);
            # skip transmit-range:
            $desc = array_splice($desc, 1);
            if (count($desc) > 0){
                list($desc, $name) = des_name($desc, $cta);
                $_SESSION["des"][$device][$key][] = $name;
                if (count($desc) > 0) {
                    # range(s) available {...}
                    # there is one { and one } only
                    $desc = implode(",", $desc);
                    $desc = str_replace("{", "", $desc);
                    $desc = str_replace("}", "", $desc);
                    $desc = explode(",", $desc);
                    $k = 0;
                    while ($k < count($desc)) {
                        $_SESSION["des"][$device][$key][] = $desc[$k];
                        $num = explode("to", $desc[$k + 1]);
                        $_SESSION["des"][$device][$key][] =  expand_comma($num[0]);
                        $_SESSION["des"][$device][$key][] =  expand_comma($num[1]);
                        $k += 2;
                    }
                } else {
                    # name only
                    $_SESSION["des"][$device][$key][] = 1;
                    $_SESSION["des"][$device][$key][] = 0;
                    $_SESSION["des"][$device][$key][] = explode(",",$field[2])[0];
                }
            } else {
                # no des at all
                $_SESSION["des"][$device][$key][] = $l_name;
                $_SESSION["des"][$device][$key][] = 1;
                $_SESSION["des"][$device][$key][] = 0;
                $_SESSION["des"][$device][$key][] = $field[2];
            }
        }
        elseif ($cta[0] == "oo") {
            # oo only
            # name number_of_steps, stepsize real_steptime_min max ... real_steptime_min max
            $_SESSION["des"][$device][$key]= [];
            $l_name = "step";
            $f = explode(",",$field[0]);
            # name
            if (count($f) > 1) {
                $_SESSION["des"][$device][$key][] = $f[1];
            }
            else {
                $_SESSION["des"][$device][$key][] = $l_name;
            }
            # number_of_steps
            $_SESSION["des"][$device][$key][] = $field[2];
            $_SESSION["des"][$device][$key][] = $field[4];
            # step_time
            $u_field = $field[3];
            $desc = explode(",", $u_field);
            # skip step_time:
            $desc = array_splice($desc, 1);
            if (count($desc) > 0){
                list($desc, $name) = des_name($desc, $cta);
                $_SESSION["des"][$device][$key][] = $name;
                if (count($desc) > 0) {
                    # range(s) available {...}
                    # there is one { and one } only
                    $desc = implode(",", $desc);
                    $desc = str_replace("{", "", $desc);
                    $desc = str_replace("}", "", $desc);
                    $desc = explode(",", $desc);
                    $k = 0;
                    while ($k < count($desc)) {
                        $_SESSION["des"][$device][$key][] = $desc[$k];
                        $num = explode("to", $desc[$k + 1]);
                        $_SESSION["des"][$device][$key][] =  expand_comma($num[0]);
                        $_SESSION["des"][$device][$key][] =  expand_comma($num[1]);
                        $k += 2;
                    }
                } else {
                    # name only
                    $_SESSION["des"][$device][$key][] = 1;
                    $_SESSION["des"][$device][$key][] = 0;
                    $_SESSION["des"][$device][$key][] = explode(",",$field[2])[0];
                }
            } else {
                # no des at all
                $_SESSION["des"][$device][$key][] = $l_name;
                $_SESSION["des"][$device][$key][] = 1;
                $_SESSION["des"][$device][$key][] = 0;
                $_SESSION["des"][$device][$key][] = $field[2];
            }
        }
    }
    var_dump($_SESSION["des"][$device]);
    print ("<br>");
}

function des_name($des, $cta){
    if (strstr($des[0], "{") == false) {
        # must be name
        if (count($cta) > 1) {
            return [array_splice($des, 1), $des[0]];
        } else {
            return [array_splice($des, 1), "range"];
        }
    } else {
        return [$des, "range"];
    }

}
function one_des($des, $device, $key, $tr_range, $factor){
    # ..to..
    $num = explode("to", $des);
    # num[0] and num[1] must "match" ; same number of pos after "," eg
    $num0 = expand_comma($num[0]);
    $num1 = expand_comma($num[1]);
    $_SESSION["des"][$device][$key][] = $tr_range;
    $_SESSION["des"][$device][$key][] = $num0;
    $_SESSION["des"][$device][$key][] = $num1;
    if ($factor == 0) {
        $fabs = intdiv($num1 - $num0 ,$tr_range) + 1;
        $_SESSION["des"][$device][$key][] = $fabs;
    } else{
        $_SESSION["des"][$device][$key][] = $factor;
    }
    return;
}

function find_bracket($string, $left, $right){
    #  for stacked bracketing: find closing bracket. string without opening bracket
    $j = 0;
    $no_of_brackets = 1;
    while ($j < strlen($string)){
        if ($string[$j] == $left){
            $no_of_brackets += 1;
        }
        if ($string[$j] == $right){
            $no_of_brackets -= 1;
        }
        if ( $no_of_brackets == 0){
            break;
        }
        $j += 1;
    }
    return substr($string, 0, $j);
}

function hex_to_type($type, $data){
    /* $data contains one or more 2 byte hex values
    $type is a MYC datatype
    */
    $temp =[];
    switch ($type) {
        case "a":
            # 0 or 1
            return hexdec($data);
        case "b":
            # byte
            return hexdec($data);
        case "i":
            # 2 complement
            $i =0;
            # 4 hex bytes
            while (($i + 4) < count($data)) {
                $dat = substr($data, $i, 4);
                if (hexdec(($dat) < (2 ** (4 - 1)))) {
                    $temp[] = hexdec(($dat));
                } else {
                    $temp[]=  ("-" . (2 ** 4 - hexdec($dat)));
                }
                $temp[]=" ";
                $i += 4;
            }
            return $temp;
        case "w":
            # 2 complement
            $i =0;
            # 4 hex bytes
            while (($i + 4) < count($data)) {
                $dat = substr($data, $i, 4);
                $temp[] = hexdec(($dat));
                $temp[]=" ";
                $i += 4;
            }
            return $temp;
        case "e":
            # 2 complement
            $i =0;
            # 8 hex bytes
            while (($i + 8) < count($data)) {
                $dat = substr($data, $i, 8);
                if (hexdec(($dat) < (2 ** (8 - 1)))) {
                    $temp[] = hexdec(($dat));
                } else {
                    $temp[]=  ("-" . (2 ** 8 - hexdec($dat)));
                }
                $temp[]=" ";
                $i += 8;
            }
            return $temp;
        case "L":
            # 2 complement
            $i =0;
            # 8 hex bytes
            while (($i + 8) < count($data)) {
                $dat = substr($data, $i, 8);
                $temp[] = hexdec(($dat));
                $temp[]=" ";
                $i += 8;
            }
            return $temp;
        case "s":
            # double
            $i =0;
            # 8 hex bytes
            while ($i + 8 < count($data)) {
                $dat = substr($data, $i, 8);
                $hex = sscanf($dat, "%02x%02x%02x%02x%02x%02x%02x%02x");
                $hex = array_reverse($hex);
                $bin = implode('', array_map('chr', $hex));
                $temp = unpack("dnum", $bin);
                $i += 8;
            }
            return $temp['num'];
        case "d":
            # double
            $i =0;
            # 8 hex bytes
            while ($i + 16 < count($data)) {
                $dat = substr($data, $i, 16);
                $hex = sscanf($dat, "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x");
                $hex = array_reverse($hex);
                $bin = implode('', array_map('chr', $hex));
                $temp = unpack("dnum", $bin);
                $i += 16;
            }
            return $temp['num'];
        case is_numeric($data):
            $string='';
            for ($i=0; $i < strlen($data)-1; $i+=2) {
                $string .= chr(hexdec($data[$i] . $data[$i + 1]));
            }
            return $string;
        case "t":
            #date missing
            return("");
    }
}

?>
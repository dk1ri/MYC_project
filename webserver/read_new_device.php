<?php
# read_new_device.php
# DK1RI 20221108
function read_new_device($device){
    #create additional device (old ones not deleted)
    read_device($device);
    create_session_data_file_array($device, "all_announce", $_SESSION["all_announce"][$device]);
    # all announcelines are now in $_SESSION["all_announce"][$device]
    read_chapter_names($device);
    create_session_data_file($device, "chapter_names", $_SESSION["chapter_names"][$device]);
    foreach ($_SESSION["chapter_names"][$device] as $key => $ch) {
        create_session_data_file($device, "chapter_token ".$ch, $_SESSION["chapter_token"][$device][$ch]);
    }
    $chapter = $_SESSION["chapter_names"][$device][0];
    $_SESSION["chapter"] = $chapter;
    find_all_token($device);
    create_session_data_file($device, "all_token", $_SESSION["all_token"][$device]);
    # all token now in $_SESSION["all_token"][$device][]
    find_selector_tokens($device);
    create_session_data_file_array($device, "sele_toks", $_SESSION["sele_toks"][$device]);
    create_session_data_file_array($device, "number_of_selects", $_SESSION["number_of_selects"][$device]);
    # now have the selector token and the number of selects in
    # $_SESSION["sele_toks"][$device] and $_SESSION["number_of_selects"][$device]
    corresponding_token($device);
    # create_session_data_file_array($device, "corresponding_tokens", $_SESSION["corresponding_tokens"][$device]);
    # now have a list of corresponding tokens with more then one selector: $_SESSION["corresponding_tokens"][$device]
    calculate_tok_len($device);
    create_session_data_file_val($device, "tok_len", $_SESSION["tok_len"][$device]);
    # now the length of the (binary token) in $_SESSION["tok_len"][$device]
    calculate_sel_len($device);
    create_session_data_file($device, "sel_len", $_SESSION["sel_len"][$device]);
    calculate_stack_len($device);
    create_session_data_file($device, "stack_len", $_SESSION["stack_len"][$device]);
    # ???
    calculate_p_len($device);
    create_session_data_file($device, "p_len", $_SESSION["p_len"][$device]);
    # now value for range commands (one dimension) in $_SESSION["p_len"][$device] ??
    calculate_p_token($device);
    create_session_data_file($device, "p_token", $_SESSION["p_token"][$device]);
    # now ???
    calculate_tok_hex($device);
    create_session_data_file($device, "tok_hex", $_SESSION["tok_hex"][$device]);
    # now absic token for all announcelines in $_SESSION["tok_hex"][$device]
    calculate_max_mul($device);
    create_session_data_file($device, "maxsel", $_SESSION["maxsel"][$device]);
    # now for selectors with ADD in $_SESSION["maxsel"][$device]
    prepare_des($device);
    create_session_data_file($device, "des", $_SESSION["des"][$device]);
    # now descriptions in $_SESSION["des"]
    init_data($device);
    create_session_data_file_array($device, "actual_data", $_SESSION["actual_data"][$device]);
    # now actual data for all commands in $_SESSION["actual_data"]
}

function read_device($device){
    $_SESSION["all_announce"][$device] = [];
    if (file_exists($device."/announce_lines")) {
        $file = fopen($device."/announce_lines", "r");
        while (!(feof($file))) {
            $pure = fgets($file);
            $pure = str_replace("\n", '', $pure);
            $pure = str_replace("\r", '', $pure);
            $field = explode(";", $pure);
            $key = $field[0];
            $value = array_slice($field,1);
            $_SESSION["all_announce"][$device][$key] = $value;
        }
        fclose($file);
    }
}

function read_chapter_names($device){
    # result is never empty
    # crate list of capternames and lost of token per chapter
    # $_SESSION["all_announce"][$device] start with basic_token, _, a_ p_.. lines follow
    $_SESSION["chapter_names"][$device] = [];
    $_SESSION["chapter_names"][$device][] = "all";
    $_SESSION["chapter_token"][$device] = [];
    $_SESSION["chapter_token"][$device]["all"] = [];
    $last_chapter = "all";
    $last_basic_token = 0;
    foreach ($_SESSION["all_announce"][$device] as $token => $lin){
        $_SESSION["chapter_token"][$device]["all"][] = $token;
        $basic_token = basic_tok($token);
        $line = implode(";", $lin);
        $pos = strpos($line, "CHAPTER");
        if (!$pos and $basic_token == $last_basic_token) {
            # _,a, p ... lines have no CHAPTER
            $_SESSION["chapter_token"][$last_chapter][] = $token;
        }
        else{
            $ar = explode("CHAPTER", "$line");
            if (count($ar) == 1){
                $chap = "all";
            }
            else {
                $chap = explode(";", $ar[1])[1];
            }
            if (!in_array($chap, $_SESSION["chapter_names"][$device])) {
                $_SESSION["chapter_names"][$device][] = $chap;
            }
            $_SESSION["chapter_token"][$device][$chap][]= $token;
            $_SESSION["chapter_token"][$device]["all"][]= $token;
            # delete the complete CHAPTER entry
            $mod_line = [];
            foreach ($lin as $field){
                $pos1 = strpos($field, "CHAPTER");
                if (!$pos1){
                    $mod_line[] = $field;
                }
            $_SESSION["all_announce"][$device][$token] = $mod_line;
            }
        }
        $last_basic_token = $basic_token;
    }
}

function find_all_token($device){
    foreach ($_SESSION["all_announce"][$device] as $token => $line_as_array){
        $_SESSION["all_token"][$device][] = explode(";",$token)[0];
    }
}


function find_selector_tokens($device){
    # to speed up operation
    # token "_"token ... "a"token
    # sequence in announcefile is: "_"token..."a"token token
    # not splited by chapter
    $_SESSION["sele_toks"][$device] = [];
    $_SESSION["number_of_selects"][$device] = [];
    foreach ($_SESSION["all_announce"][$device] as $token => $line_as_array){
        $tok = basic_tok($token);
        if ((strstr($token, "_")) or (strstr($token, "a"))){
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

function corresponding_token($device){
    # created list of _, a_p_ ... token with basictoken as key (no empty key!)
    $_SESSION["corresponding_tokens"][] = $device;
    $_SESSION["corresponding_tokens"][$device] =[];
    $last_basic_token = 0;
    $cor_tokens = [];
    $start = 1;
    foreach ($_SESSION["all_announce"][$_SESSION["device"]] as $token => $line_as_array) {
        if ($start){
            # skip first entry
            $start = 0;
            $last_basic_token = basic_tok($token);
        }
        else {
            $basic_token = basic_tok($token);
            if ($basic_token != $last_basic_token) {
                #finish last_basic_tok
                if ($cor_tokens != []) {
                #    print($last_basic_token);
                 #   print(" fff ");
                    $_SESSION["corresponding_tokens"][$device][] = $last_basic_token;
                    $_SESSION["corresponding_tokens"][$device][$last_basic_token] = $cor_tokens;
                }
                # else: no entry
                $cor_tokens = [];
            } else {
                $cor_tokens[] = $token;
            }
            $last_basic_token = $basic_token;
        }
    }
    if ($cor_tokens != []){
        # last element, if available
        $_SESSION["corresponding_tokens"][$device][] = $last_basic_token;
        $_SESSION["corresponding_tokens"][$device][$last_basic_token] = $cor_tokens;
    }
}

function calculate_tok_len($device){
    # too complicate :(
    $_SESSION["tok_len"][$device] = [];
    foreach ($_SESSION["all_announce"][$device] as $key => $value){
        $_SESSION["tok_len"][$device] = calculate_len($key);
        break;
    }
}

function calculate_sel_len($device){
    # selecttoken with value, other token = 0
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
                    # keep sel_old for px commands reset for others
                    $sel_old = 0;
                }
             }
        } else {
            # memories
            $_SESSION["sel_len"][$device][$key] = 0;
        }
    }
}

function calculate_stack_len($device)
{
    # basic_token with number of bytes for hex data
    $_SESSION["stack_len"][$device] = [];
    foreach ($_SESSION["all_announce"][$device] as $token => $value) {
        # basic_token only
        if (!strstr($token, "_") and !strstr($token, "a") and !strstr($token, "p")){
            $ct = explode(",", $value[0])[0][1];
            # switches and range only
            if (!($ct == "m" or $ct == "n" or $ct == "a" or $ct == "b" or $ct == "f")) {
                $stac = explode(",", $value[1])[0];
                $stack = (int) $stac;
                if ( $stack < 256) {
                    $_SESSION["stack_len"][$device][$token] = 2;
                }
                elseif ( $stack < 65536) {
                    $_SESSION["stack_len"][$device][$token] = 4;
                }
                else{
                    $_SESSION["stack_len"][$device][$token] = 4;
                }
            }
        }
    }
}

function calculate_p_len($device){
    # op ap token (one dimension) with value, others  0
    # ap ap token splitted by dimensions before??
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
    # ??
    $_SESSION["p_token"][$device] = [];
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
        $tok = basic_tok($key);
        $_SESSION["tok_hex"][$device][$key] = dec_hex($tok, $_SESSION["tok_len"][$device]);
    }
}

function calculate_max_mul($device){
    $_SESSION["maxsel"][$device] = [];
    # for selectors with "ADD" calculate the maximum value of MUL
    foreach ($_SESSION["all_announce"][$device] as $key => $field) {
        if( !strstr($key,"_") and !strstr($key,"a")){
            if (strstr( $field[1], "ADD")){
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
    $_SESSION["des"][$device] = [];
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
}

function des_name($des, $cta){
    if (!strstr($des[0], "{")) {
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
    } else {
        $_SESSION["des"][$device][$key][] = $factor;
    }
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
    # $data contains one or more 2 byte hex values
    # $type is a MYC datatype
    # ???
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
    return;
}

function init_data($device){
    # set data  for all token to "0" (or corresponding real data by translate)
    # create $_SESSION[actual_data]
    $_SESSION["actual_data"][$device] = [];
    foreach ($_SESSION["all_announce"][$device] as $key => $value) {
        $data = [];
        $tok = basic_tok($key);
        if ($tok == $key) {
            # data
            $ct = explode(",", $value[0])[0];
            if ($ct == "ar") {
                $ct = "or";
            }
            if ($ct == "ap") {
                $ct = "op";
            }
            switch ($ct) {
                case "or":
                    # result is array with one element per position
                    $i = 3;
                    while ($i < count($value)) {
                        $data[] = "0";
                        $i += 1;
                    }
                    break;
                case "op":
                    # result is array with one element per dimension
                    $i = 3;
                    while ($i < count($value)) {
                        $data[] = "0";
                        $i += 3;
                    }
                    break;
                case "oo":
                    # result is array with four elements for count, time, size and add  per dimension
                    $i = 3;
                    while ($i < count($value)) {
                        $data[] = "0";
                        $i += 3;
                    }
                    break;
                default:
                    # os/as : one element array!!
                    $data[] = "0";
                    break;
            }
            $_SESSION["actual_data"][$device][$key] = translate_data($data, $device, $key, $value);
        }
        else {
            # stacks etc: one element array !
            $data[] = "0";
            $_SESSION["actual_data"][$device][$key] = $data;
        }
    }

}
?>
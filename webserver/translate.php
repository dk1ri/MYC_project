<?php
# translate.php
# DK1RI 20230119
function correct_POST($device){
    # make mods on op ap oo commands only
    # now data beyond the limits can be inputted for op oo commands with > 100 distinct values
    # before using for send and actual_data, they will be corrected to nearest valid data
    # all $_SESSION["corrected_POST"] values are strings
    $_SESSION["corrected_POST"] = [];
    foreach ($_POST as $token => $value) {
        if (!array_key_exists($token, $_SESSION["announce_all"][$device])) {
            #interface device ...
            if ($token == "device") {
                if ($value != $_SESSION["device"]) {
                    $_SESSION["device"] = $value;
                }
                # other than device are not used now
            }
        }
       else{
            $basic_tok = basic_tok($token);
            $ct = explode(",", $_SESSION["announce_all"][$device][$token][0])[0];
            switch ($ct) {
                case "ap":
                case "op":
                case "oo":
                    $_SESSION["corrected_POST"][$token] = correct_memory_range($token, $value);
                    break;
                case "om":
                case "am":
                case "on";
                case "an":
                    if (strstr($token, "b")) {
                        $_SESSION["corrected_POST"][$token] = correct_memory_range($token, $value);
                    }
                    elseif (strstr($token, "x")){
                        # data
                        $type = $_SESSION["des_type"][$device][$token][0];
                        $_SESSION["corrected_POST"][$token] = correct_data($value, $type);
                    }
                    else {
                        $_SESSION["corrected_POST"][$token] = $value;
                    }
                    break;
                case "oa";
                    if (strstr($token, "b")){
                        # position: no correction
                        $_SESSION["corrected_POST"][$token] = $value;
                    }
                    else{
                        # $_POST has data for a specific element; with number of either corrected_POST or actual_data
                        if (array_key_exists($basic_tok."b0", $_SESSION["corrected_POST"])) {
                            $tok_sub_number = $_SESSION["corrected_POST"][$basic_tok."b0"];
                        }
                        else{
                            if (array_key_exists($basic_tok."b0", $_SESSION["actual_data"][$device])) {
                                $tok_sub_number = $_SESSION["actual_data"][$device][$basic_tok . "b0"];
                            }
                            else {
                                # one element only
                                $tok_sub_number = 0;
                            }
                        }
                        $type = $_SESSION["des_type"][$device][$token][0];
                        $_SESSION["corrected_POST"][$token] = correct_data($value, $type);
                    }
                    break;
                case "aa":
                    # no correction
                    $_SESSION["corrected_POST"][$token] = $value;
                    break;
                default:
                    # switches
                    $_SESSION["corrected_POST"][$token] = $value;
            }
        }
    }
}

function correct_memory_range($token, $value){
    # for memory-positions
    # has discrete values always !
    #  needed only, if manual entry is provided (not now)
    $device = $_SESSION["device"];
    $found = "";
    $positions = explode(",",$_SESSION["des_range"][$device][$token]);
    $i = 0;
    $stop = 0;
    while ($i < count($positions) and !$stop){
        if ($positions[$i] == $value){
            $found = $value;
            $stop = 1;
        }
        else {
            if ($value > $positions[$i]){
                $found = $positions[$i];
            }
        }
        $i += 1;
    }
    if ($found == ""){
        # should not happen, set to max
        $found = $positions[$i];
    }
    return $found;
}

function correct_data($data, $type){
    if ($data != ""){
        switch ($type) {
            case "a":
                if ($data < 0) {
                    $data = 0;
                }
                if ($data > 1) {
                    $data = 1;
                }
                break;
            case "b":
                if ($data < 0) {
                    $data = 0;
                }
                if ($data > 255) {
                    $data = 255;
                }
                break;
            case "c":
                if ($data < -128) {
                    $data = -128;
                }
                if ($data > 127) {
                    $data = 127;
                }
                break;
            case "i":
                if ($data < -32768) {
                    $data = -32768;
                }
                if ($data > 32767) {
                    $data = 32767;
                }
                break;
            case "w":
                if ($data < 0) {
                    $data = 0;
                }
                if ($data > 65535) {
                    $data = 65535;
                }
                break;
            case "e":
                if ($data > 2147483647) {
                    $data = 2147483647;
                }
                if ($data < -2147483648) {
                    $data = -2147483648;
                }
                break;
            case "L":
                if ($data < 0) {
                    $data = 0;
                }
                if ($data > 4294967295) {
                    $data = 4294967295;
                }
                break;
            case (is_numeric($data)):
                # length of string
                if (strlen($data) > $type) {
                    $data = substr($data, 0, $type);
                }
                # other restriction: missing
                break;
        }
    }
    return strval($data);
}

function translate_dec_to_hex($type, $data, $length){
    # $type is a MYC datatype
    # $type == n is number with length
    # $type == n is unsigned number with $length
    switch ($type) {
        case "n":
            return fillup(dechex((int)$data), $length);
        case "a":
        case "b":
            # 0 or 1
            # byte
            return fillup(dechex((int)$data),2);
        case "c":
            # 1 byte signed short
            if (strstr($data, "-")) {
                $data = str_replace("-", "", $data);
                $data = dechex((~(int)$data) +1);
            }
            else{
                $data = dechex((int)$data);
            }
  #         print ($data);
            return fillup($data, 2) ;
        case "i":
            # 2 byte signed integer
            if (strstr($data, "-")) {
                $data = str_replace("-", "", $data);
                $data = dechex((~(int)$data) + 1);
            }
            else{
                $data = dechex((int)$data);
            }
            return fillup($data, 4);
        case "w":
            # 2 byte unsigned word
            return fillup(dechex((int)$data), 4);
        case "e":
            # 4 byte signed long
            if (strstr($data, "-")) {
                $data = str_replace("-", "", $data);
                $data = dechex(~(int)$data);
            }
            else{
                $data = dechex((int)$data);
            }
            return fillup($data, 8) ;
        case "L":
            # 4 byte unsigned long
            return fillup(dechex((int)$data), 8);
        case (is_numeric($type)):
            # string
            $length_of_len = length_of_type($length);
            return fillup(strlen($data), $length_of_len).bin2hex($data);
    }
    #dummy
    return "";
}

function fillup($data, $length){
    if(strlen($data) > $length){
        # drop leading chars
        $length *= -1;
        $data = substr($data, $length);
    }
    else{
        # fill up with leading "0" (characters!!!)
        $dat = "";
        $i = strlen(strval($data));
        while ($i < $length) {
            $dat .= "0";
            $i += 1;
        }
        $data = $dat . $data;
    }
    return $data;
}

function translate_hex_to_actual($device, $token, $data){
    # input: one line decimal value (string) from device; must be converted to actual data for GUI
    # in $_SESSION["actual_data"]..
    $ct = explode(",",$_SESSION["announce_all"][$device][$token][1]);
    $real_value = "";
    if ($ct == "op" or $ct == "ap") {
        $des = $_SESSION["des"][$device][$token];
        # des: name factor min max ...
        if ($des[1] == 0 and count($des) == 4) {
            # one range only and no translation,
            $real_value = $data;
        } else {
            $real_value = 0;
            $i = 1;
            $tx_data_range = 0;
            while ($i < count($des)) {
                # actual range of transmitted values
                $tx_data_range += ($des[$i + 2] - $des[$i + 1]) / $des[$i];
                if ($data * $des[$i] + $des[$i + 1] < $des[$i + 2]) {
                    # found!
                    $real_value = $data * $des[$i] + $des[$i + 1];
                    break;
                } else {
                    $data -= $tx_data_range;
                }
                $i += 3;
            }
        }
        return $real_value;
    }
    elseif ($ct == "oo"){
        foreach ($data as $item) {
            $real_value[] = hexdec($item);
        }
        return $real_value;
    }
    else{
        return $data;
    }
}

function translate_actual_to_hex_for_p($token){
    # create hex string to send for p commands from actual data
    $device = $_SESSION["device"];
    if (strstr($token,"d")){
        #these are memory type data
        # not ready!!!
        return($_SESSION["actual_data"][$device][$token][0]);
    }
    else {
        $elements = $_SESSION["des_range"][$device][$token];
        $no_of_elements = count($elements);
        $element = 0;
        $no_of_steps_to_now = 0;
        $actual = convert($_SESSION["actual_data"][$device][$token][0]);
        while ($element < $no_of_elements) {
            $spacing = $elements[$element];
            $to = $elements[$element + 2];
            $i = $elements[$element + 1];
            while ($i <= $to) {
                if ($i >= $actual) {
                    break;
                }
                $i += $spacing;
                $no_of_steps_to_now += 1;
            }
            $element += 3;
        }
        return dec_hex($no_of_steps_to_now, $_SESSION["property_len"][$device][$token][2]);
    }
}

function hex_to_dec_for_type($type, $data){
    # $data contains one or more 2 byte hex values
    # $type is a MYC datatype
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
            for ($i=0; $i < strlen($data) ; $i+=2) {
                $string .= chr(hexdec($data[$i] . $data[$i + 1]));
            }
            return $string;
        case "t":
            #date missing
            return("");
    }
    return($data);
}

function device_data_to_actual($type, $data){
    # translate data from device
    # $data contains one or more 2 byte hex values
    # $type is a MYC datatype
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


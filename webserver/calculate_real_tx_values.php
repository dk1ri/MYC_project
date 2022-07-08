<?php
/*
 * is called once at start only, convert initial data (or after update of device data ???)
$_SESSION[device_data][$Device][$chapter] has token => data in hex  or blank
converts to $_SESSION[real_data][$Device][$chapter]: content depent on commandtype
-> token + realdata (for SK)
the real daata depend on the format, defined by the announcements
*/
function calculate_real_tx_values($device, $chapter){
foreach ($_SESSION["device_data"][$device][$chapter] as $token => $data){
    foreach ($_SESSION["announce_lines"][$device][$chapter] as $key => $line) {
        if ($key == $token) {
            $int_token = intval($token);
            # annonceline for device_data_value line found
            $ct= explode(",",$line[0]);
            switch ($ct[0]) {
                case "os":
                    # stores selected item (up to 256 ositions only -> one byte)
                    if ($data != "") {
                        $_SESSION["real_data"][$device][$chapter][$int_token] = strval(hexdec(($data)));
                    } else {
                        $_SESSION["real_data"][$device][$chapter][$int_token] = 0;
                    }
                    break;
                case "as":
                    if ($data != "") {
                        $_SESSION["real_data"][$device][$chapter][$int_token] = strval(hexdec(($data)));
                    } else {
                        $_SESSION["real_data"][$device][$chapter][$int_token] = 0;
                    }
                    break;
                case "or":
                    # stores a set of key => 0|1 (seleted or not)
                    $_SESSION["real_data"][$device][$chapter][$int_token] = [];
                    if ($data != "") {
                        $i = 2;
                        while ($i < count($line)) {
                            if ($data == "01") {
                                $value = 1;
                            } else {
                                $value = 0;
                            }
                            $_SESSION["real_data"][$device][$chapter][$int_token][$i - 2] = strval($value);
                            $i += 1;
                        }
                    }
                    else {
                        $i = 2;
                        while ($i < count($line)) {
                            if ($i == 2) {
                                $value = 1;
                            } else {
                                $value = 0;
                            }
                            $_SESSION["real_data"][$device][$chapter][$int_token][$i - 2] = strval($value);
                            $i += 1;
                        }
                    }
                    break;
                case "ar":
                    $_SESSION["real_data"][$device][$chapter][$int_token] = [];
                    if ($data != "") {
                        $i = 2;
                        while ($i < count($line)) {
                            if (substr($data, 2) == "01") {
                                $value = 1;
                            } else {
                                $value = 0;
                            }
                            $_SESSION["real_data"][$device][$chapter][$int_token][$i - 2] = $value;
                            $i += 1;
                        }
                    }
                    else {
                        $i = 2;
                        while ($i < count($line)) {
                            if ($i == 2) {
                                $value = 1;
                            } else {
                                $value = 0;
                            }
                            $_SESSION["real_data"][$device][$chapter][$int_token][$i - 2] = $value;
                            $i += 1;
                        }
                    }
                    break;
                case "om":
                    $type = explode(";", $line[2]);
                    $_SESSION["real_data"][$device][$chapter][$int_token] = hex_to_type($type, $data);
                    break;
            }
        }
    }
}
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
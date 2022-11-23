<?php
function correct_POST($device){
    # make mods on op ap oo commands only
    # now data beyond the limits can be inputted for some commands
    # before using for send and actual_data, they will be corrected to nearest valid data
    $_SESSION["corrected_POST"] = [];
    foreach ($_POST as $token => $value) {
        # basic_token may have something added:
        $basic_token = basic_tok($token);
        if (array_key_exists($token, $_SESSION["all_announce"][$device])) {
            $ct = explode(",", $_SESSION["all_announce"][$device][$basic_token][0])[0];
            if ($ct == "ap" or $ct == "oo") {
                $ct = "op";
            }
            switch ($ct) {
                case "op":
                    if ($value != "") {
                        $desval = $_SESSION["des"][$device][$basic_token];
                        # array for dimension: name min1 max1 factor1 min2...
                        $i = 1;
                        $distance = 0;
                        $best_val = 0;
                        $valok = 0;
                        while ($i +1 < count($desval)) {
                            if ($value > $desval[$i + 1] and $value < $desval[$i + 2]) {
                                $valok = 1;
                                break;
                            } else {
                                $distance1 = abs($value - $desval[$i + 1]);
                                $distance2 = abs($value - $desval[$i + 2]);
                                if ($distance1 > $distance2) {
                                    $distancea = $distance2;
                                    $best_valuea = $desval[$i + 2];
                                } else {
                                    $distancea = $distance1;
                                    $best_valuea = $desval[$i + 1];
                                }
                                if ($i = 1){
                                    $distance = $distancea;
                                    $best_val = $best_valuea;
                                } else {
                                    if ($distance > $distancea) {
                                        $distance = $distancea;
                                        $best_val = $best_valuea;
                                    }
                                }
                            }
                            $i += 4;
                        }
                        if ($valok == 0) {
                            $_SESSION["corrected_POST"][$token] = $best_val;
                        } else {
                            $_SESSION["corrected_POST"][$token] = $value;
                        }
                    }
                    break;
                default:
                    $_SESSION["corrected_POST"][$token] = $value;
            }
        }
        else {
            $_SESSION["corrected_POST"][$token] = $value;
        }
    }
}

function translate_hex_to_actual($device, $token, $data){
    # input: one line decimal value (string) from device; must be converted to actual data for GUI
    # in $_SESSION["actual_data"]..
    $ct = explode(",",$_SESSION["all_announce"][$device][$token][1]);
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
    }elseif ($ct == "oo"){
        foreach ($data as $item) {
            $real_value[] = hexdec($item);
        }
        return $real_value;
    }else{
        return $data;
    }
}

function translate_actual_to_hex_for_p($device,$token){
    # create hex string to send for p commands from actual data
    # $_SESSION["des_coded"][$device[$token] : array: spacing from to spacing ...
    $actual = $_SESSION["actual"][$token];
    $des_range = $_SESSION["des_range"][$device][$token];
    $i = 1;
    $result = 0;
    $no_of_steps_to_now = 0;
    while ($i < $des_range) {
        $spacing = $des_range[$i];
        $from = $des_range[$i + 1];
        $to = $des_range[$i + 2];
        $steps_per_real = ($to -  $from) / $spacing;
        if ($actual <= $to){
            $result += ($actual - $from) / $spacing + $no_of_steps_to_now;
        }
        $no_of_steps_to_now +=  $steps_per_real;
        $i += 3;
    }
    return $result;
}

?>


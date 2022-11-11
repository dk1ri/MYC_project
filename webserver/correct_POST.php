<?php
function correct_POST($device){
    # make mods on op ap oo commands only
    # now data beyond the limits can be inputted for some commands
    # before using for send and actualdata, they will be corrected to nearest valid data
    # real values are used in case of corrections
    $_SESSION["corrected_POST"] = [];
    foreach ($_POST as $token => $value) {
        # basic_token may have something added:
        $basic_token = basic_tok($token, "p");
        $basic_token = basic_tok($basic_token, "o");
        if (array_key_exists($token, $_SESSION["all_announce"][$device])) {
            $ct = explode(",", $_SESSION["all_announce"][$device][$basic_token][0])[0];
            if ($ct == "ap" or $ct == "oo") {
                $ct = "op";
            }
         #   Fpvar_dump($_SESSION["all_announce"][$device][$basic_token]);
            switch ($ct) {
                case "op":
                    correct($device, $token, $basic_token, $value);
                    break;
                default:
                    $_SESSION["corrected_POST"][$token] = $value;
            }
        }
        else {
            $_SESSION["corrected_POST"][$token] = $value;
        }
    }
    return;
}

function correct($device,  $token, $basic_token, $value){
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
    return;
}
?>

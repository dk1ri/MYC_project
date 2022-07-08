<?php
function correct_POST($device){
    # now data beoynd the limits can be inputted for some commands
    # before using for send and real_data, they will be corrected to nearest valid data
    # real values are used in case of corrections
    if (!array_key_exists($device, $_SESSION["corrected_POST"])) {
        $_SESSION["corrected_POST"][$device] = [];
    }
    foreach ($_POST as $token => $value) {
        # basic_token may have something added:
        $basic_token = basic_tok($token, "p");
        $basic_token = basic_tok($token, "o");
        if (array_key_exists($token, $_SESSION["all_announce"][$device])) {
            $ct = explode(",", $_SESSION["all_announce"][$device][$basic_token][0])[0];
            switch ($ct) {
                case "op":
                    correct($device, $token, $basic_token, $value);
                    break;
                case "ap";
                    correct($device, $token, $basic_token, $value);
                    break;
                case "oo":
                    correct($device, $token, $basic_token, $value);
                    break;
                default:
                    $_SESSION["corrected_POST"][$device][$token] = $value;
            }
        }
    }
    var_dump($_SESSION["corrected_POST"][$device]);
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
            $_SESSION["corrected_POST"][$device][$token] = $best_val;
        } else {
            $_SESSION["corrected_POST"][$device][$token] = $value;
        }
    }
    return;
}
?>

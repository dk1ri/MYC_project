<?php
function translate_data($data, $device, $token, $value){
    # input: one line decimal value (string) from device; must be converted to real data for GUI
    # in $_SESSION["real_data"]..
    $ct = explode(",",$value[0])[0];
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
?>


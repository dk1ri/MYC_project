<?php
function analyze_trx_data($token, $field, $device,$orgdata){
    # orgdata is hexstring by device without (original) token
    $tok = basic_tok_all($token);
    $sel_length = $_SESSION["sel_len"][$device][$token];
    $ct = explode(",", $field[0])[0];
    if ($ct == "ar") {
        $ct = "or";
    }
    if ($ct == "ap") {
        $ct = "op";
    }
    switch ($ct) {
        case "or":
            # array with one element per position, 1st set by orgdata
            # 256 pos only -> last 2 bytes
            if ($orgdata != "") {
                $data = hexdec(substr($orgdata, -2));
            } else {
                $data = 0;
            }
            # other elements set to 0
            $i = 3;
            while ($i < count($field)) {
                $data = 0;
                $i += 1;
            }
            break;
        case "op":
            # array with one element and one dimension only
            $pos = $sel_length;
            # position for actual dimension in orgdata must be found
            $i = 0;
            foreach ($_SESSION["p_token"][$device] as $key => $value){
                if (basic_tok_all($value) == $tok) {
                    $ctok = $tok."p".$i;
                    if (strval($token) == strval($ctok)){
                        break;
                    } else {
                        if (array_key_exists($tok . "p" . $i, $_SESSION["p_len"][$device])){
                            $pos += $_SESSION["p_len"][$device][$tok . "p" . $i];
                        }
                    }
                    $i += 1;
                }
            }
            $data = hexdec(substr($orgdata, $pos, $_SESSION["p_len"][$device][$token]));
            break;
        case "oo":
            # there is no orgata (empty)
            # array with four elements for count, time, size and add (
            $i = 4;
            while ($i > 0) {
                $data[] = 0;
                $i -= 1;
            }
            break;
        default:
            # other have one element (integer) 1st set by orgdata
            # 256 pos only -> last 2 bytes
            if ($orgdata != "") {
                $data[] = hexdec(substr($orgdata, -2));
            } else {
                $data[] = 0;
            }
            break;
    }
  ##  print $token." ";
    #    var_dump($data);
   # print "<br>";
    return $data;
}

function translate_data($data, $device, $token, $ann){
    # input: one line decimal value (string) from device; must be converted to real data for GUI
    # set $_SESSION["real_data]..
    $ct = explode(",",$ann[0])[0];
    if ($ct == "op" or $ct == "ap") {
        $des = $_SESSION["des"][$device][$token];
        # des: min max factor
        if ($des[3] == 0 and $des[4] == 0) {
            # one range only and no translation,
            $real_value = $data;
        } else {
            $real_value = 0;
            $counts_tx = 0;
            $i = 2;
            while ($i < count($des)) {
                if ($data < $counts_tx + $des[$i + 2]) {
                    $real_value = $des[$i + 1] + ($data - $counts_tx) * $des[$i + 3];
                    break;
                } else {
                    $counts_tx += $des[$i];
                }
                $i += 4;
            }
        }
        $_SESSION["all_real_data"][$device][$token] = $real_value;
    }elseif ($ct == "oo"){
        foreach ($data as $item) {
            $real_value[] = hexdec($item);
        }
        $_SESSION["all_real_data"][$device][$token] = $real_value;
    }else{
        $_SESSION["all_real_data"][$device][$token] = hexdec($data);
    }
    return;
}
?>


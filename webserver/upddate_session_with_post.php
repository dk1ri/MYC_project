<?php
function upddate_session_with_post(){
    # set multiple (or ar) to 0 if not in $_SESSION["corrected_POST"][$device] ($post_token)
    $device = $_SESSION["device"];
    $chapter = $_SESSION["chapter"];
    if (array_key_exists($device,$_SESSION["or_ar_tokens"]) != false){
        foreach ($_SESSION["or_ar_tokens"][$device] as $key_ => $tok) {
            # for actual chapter only
            if (array_key_exists($tok, $_SESSION["announce_lines"][$device][$chapter])) {
                if (!array_key_exists($tok, $_SESSION["corrected_POST"][$device])) {
                    # not in $_SESSION["corrected_POST"][$device]: set to 0
                    # corresponding selector tokens may exist
                    $selector_hex = calclate_actual_selector($tok);
                    $i = 0;
                    foreach ($_SESSION["all_real_data"][$device][$tok] as $key_ => $value) {
                        $_SESSION["all_real_data"][$device][$tok][$i] = 0;
                        $i += 1;
                    }
                }
            }
        }
    }
    foreach ($_SESSION["corrected_POST"][$device] as $key => $value) {
        # for some tokens basictoken must be used
        $key = basic_tok($key, "u");
        #  token only
        if (array_key_exists($key, $_SESSION["all_announce"][$_SESSION["device"]])){
            $field = $_SESSION["all_announce"][$_SESSION["device"]][$key];
            $ct = explode(",", $field[0])[0];
            # answerscommands are updated after new data read
            switch ($ct) {
                case  "os":
                    $_SESSION["all_real_data"][$_SESSION["device"]][$key] = strval($value);
                    break;
                case "or":
                    if (count($field) == 3){
                        if ($_SESSION["all_real_data"][$_SESSION["device"]][$key][0] == 0) {
                            $_SESSION["all_real_data"][$_SESSION["device"]][$key][0] = 1;
                        } else{
                            $_SESSION["all_real_data"][$_SESSION["device"]][$key][0] = 0;
                        }
                    }else {
                        # set selected to 1 ; others to 0
                        $i = 0;
                        $da = $_SESSION["all_real_data"][$_SESSION["device"]][$key];
                        $i = 0;
                        while ($i < count($da)) {
                            # set position, which are found in $_SESSION["corrected_POST"][$device] to 1, others to 0
                            $j = 0;
                            $found = 0;
                            while ($j < count($value)) {
                                if ($value[$j] == $i) {
                                    $_SESSION["all_real_data"][$_SESSION["device"]][$key][$i] = 1;
                                    $found = 1;
                                }
                                $j += 1;
                            }
                            if ($found == 0){
                                $_SESSION["all_real_data"][$_SESSION["device"]][$key][$i] = 0;
                            }
                            $i += 1;
                        }
                    }
                    break;
                case "op":
                    $_SESSION["all_real_data"][$_SESSION["device"]][$key] = strval($value);
                    break;
                case "ap":
                    $_SESSION["all_real_data"][$_SESSION["device"]][$key] = strval($value);
                    break;
            }
        }
    }
}
?>

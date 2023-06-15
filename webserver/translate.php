<?php
# translate.php
# DK1RI 20230615
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function correct_POST($device){
    # real values are converted to nearest valid data and translated for transmit (stored as actual data), if necessary
    # -> only those, where $_SESSION["to_correct"][$device][$basictok].*) exists (others are correct)
    $_SESSION["corrected_POST"][$device] = [];
    foreach ($_POST as $token => $value) {
        if ($value == ""){continue;}
        if (array_key_exists($token, $_SESSION["to_correct"][$device])) {
            # to_correct: 1,2,..m_ntoo, ... (numeric or alpha
            # hex values not supported
            $des = explode(",", $_SESSION["to_correct"][$device][$token]);
            $i = 0;
            $result = 0;
            $found = 0;
            $value_for_actual_data = 0;
            if (is_numeric($value)) {
                while ($i < count($des) and $found == 0) {
                    if (strstr($des[$i], "_")) {
                        list($separator, $from, $to) = split_range($des[$i]);
                        if (is_numeric($from)) {
                            $act_value = $from;
                            while (($act_value < $to) and $found == 0) {
                                if ($act_value >= $value) {
                                    $found = 1;
                                    $result =   $value_for_actual_data;
                                } else {
                                    $act_value += $separator;
                                }
                                $value_for_actual_data += 1;
                            }
                        } else {
                            # skip range
                            $value_for_actual_data += (ord($to) - ord($from)) / $separator;
                        }
                    } else {
                        if (is_numeric($des[$i])){
                            if ($value <= $des[$i]) {
                                $found = 1;
                                $result =   $value_for_actual_data;
                            }
                        }
                        $value_for_actual_data += 1;
                    }
                    $i += 1;
                }
            }
            else{
                # alpha value
                while ($i < count($des) and $found == 0) {
                    if (strstr($des[$i], "_")) {
                        list($separator, $from, $to) = split_range($des[$i]);
                        if (is_numeric($from)) {
                            # skip range
                            $value_for_actual_data += ($to - $from) / $separator;
                        }
                        else {
                            $act_value = ord($from);
                            while ($act_value < ord($to) and $found == 0) {
                                if ($act_value >= ord($value)) {
                                    $found = 1;
                                    $result =   $value_for_actual_data;
                                } else {
                                    $act_value += $separator;
                                }
                                $value_for_actual_data += 1;
                            }
                        }
                    } else {
                        if (!is_numeric($des[$i])){
                            if ($value <= $des[$i]) {
                                $found = 1;
                                $result =   $value_for_actual_data;
                            }
                        }
                        $value_for_actual_data += 1;
                    }
                    $i += 1;
                }
            }
            $_SESSION["corrected_POST"][$device][$token] = $result;
        }
        else{
            $_SESSION["corrected_POST"][$device][$token] = $value;
        }
    }
    print "<br>";
}
?>
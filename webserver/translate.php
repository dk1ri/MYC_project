<?php
# translate.php
# DK1RI 20230615
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function correct_POST($device){
    # real (displayed) values are converted to nearest valid MYC data (as stored as actual data)
    # only those with manual data entry must be checked
    # -> only those, where $_SESSION["to_correct"][$device][$basictok].*) exists (-> string data are not checked)
    $_SESSION["corrected_POST"][$device] = [];
    foreach ($_POST as $token => $value) {
        # string limitations are not supported
        # check for absolute max values (given by type)
        if (!array_key_exists($token, $_SESSION["to_correct"][$device])) {
            $_SESSION["corrected_POST"][$device][$token] = $value;
            continue;
        }
        # remaining; numeric values only
        # they have "des", 1,2,1_2to3... only
        # This should not happen:
        if ($value == "") {
            continue;
        }
        $limit = 0;
        if (array_key_exists($token, $_SESSION["type_for_memories"][$device])) {
            list ($min, $max) = find_allowed($_SESSION["type_for_memories"][$device][$token]);
            if ($value > $max) {
                # max for transmit
                $value = $_SESSION["max_for_send"][$device][$token];
                $limit = 1;
            }
            if ($value < $min) {
                # min for transmit
                $value = 0;
                $limit = 1;
            }
        }
        # no futher correction, if value was beyond limit
        if (!$limit) {
            # hex values not supported
            $des= explode(",", $_SESSION["des"][$device][$token]);
            $i = 0;
            $found = 0;
            $result = 0;
            while ($i < count($des)and $found == 0) {
                if (strstr($des[$i],"_")) {
                    list($separator, $from, $to) = split_range($des[$i]);
                    while ($from < $to and $found == 0) {
                        if ($value <= $from) {
                            $found = 1;
                        }
                        else{
                            $result += 1;
                        }
                        $from += $separator;
                    }
                }
                else{
                    if ($result = $des[$i]){$found = 1;}
                    else{
                        $result += 1;
                    }
                }
                $i += 1;
            }
            $value = $result;
        }
        $_SESSION["corrected_POST"][$device][$token] = $value;
    }
}
?>
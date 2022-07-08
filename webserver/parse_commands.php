<?php
function parse_commands($device, $chapter){
    $announcelines = $_SESSION["announce_lines"][$device][$chapter];
    include "create_commands.php";
    $tokenindex = 0;
    # 1: start, 2: continue
    $start_container = 1;
    foreach ($announcelines as $token => $value) {
        str_replace(chr(10), "", $value);
        $actual_ct = explode(",", $announcelines[$token][0])[0][1];
        $actual_ot = explode(",", $announcelines[$token][0])[0][0];
        $next_ct = "";
        $new_index = $tokenindex + 1;
        while ($new_index < count($_SESSION["all_token"][$device])) {
            # find next ct ignoring selectors
            $new_tok = $_SESSION["all_token"][$device][$new_index];
            if (strstr($new_tok, "_") == false and strstr($new_tok, "a") == false) {
                $next_ct = explode(",", $announcelines[$new_tok][0])[0][1];
                $next_ot = explode(",", $announcelines[$new_tok][0])[0][0];
                break;
            }
            $new_index += 1;
        }
        if ($start_container == 1) {
            echo "<div class = flex-container><div>";
        }
        # analyze commanddtype
        $command_type = explode(',', $value[0]);
        switch ($command_type[0]) {
            case "os":
                create_os($token, $value, $_SESSION["all_real_data"][$device][$token]);
                break;
            case "as":
                create_as($token, $value, $_SESSION["all_real_data"][$device][$token]);
                break;
            case "or":
                create_or($token, $value, $_SESSION["all_real_data"][$device][$token]);
                break;
            case "ar":
                create_ar($token, $value, $_SESSION["all_real_data"][$device][$token]);
                break;
            case "at":
                create_at($token, $value, $_SESSION["all_real_data"][$device][$token]);
                break;
            case "ou":
                create_ou($token, $value);
                break;
            case "op":
                create_op($device, $token, $value, $_SESSION["all_real_data"][$device][$token], $start_container);
                break;
            case "ap":
                create_ap($device, $token, $value, $_SESSION["all_real_data"][$device][$token]);
                break;
            case "oo":
                create_oo($device, $token, $value, $_SESSION["all_real_data"][$device][$token], $start_container);
                break;
            case "om":
                create_om($token, $value, $_SESSION["all_real_data"][$device][$token]);
                break;
        }
        if ($actual_ot == $next_ot) {
            if (strpos($token, "_") > 0 or strpos($token, "a") > 0 or strpos($token, "p") > 0 or strpos($token, "o") > 0) {
                $start_container = 2;
            } elseif (($actual_ct == "p" and $next_ct == "o") or ($actual_ct == "o" and $next_ct == "o") or ($actual_ct == "p" and strstr("$next_ct", "o") != false)) {
                $start_container = 2;
            } else {
                if ($next_ct != "o" and $next_ct != "p" and strstr($token, "_") == false and strstr($token, "a") == false) {
                    echo "</div></div";
                    $start_container = 1;
                } else {
                    if ($start_container = 2 and strstr($token, "p") == false and strstr($token, "o") == false) {
                        echo "</div></div";
                        $start_container = 1;
                    }
                }
            }
        } else {
            # change a <-> o command
            echo "</div></div";
            $start_container = 1;
        }
        $tokenindex += 1;
    }
}
?>

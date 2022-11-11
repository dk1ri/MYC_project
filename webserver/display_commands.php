<?php
# display_commands.php
# DK1RI 20221108
function display_commands($device, $chapter){
    $announcelines = $_SESSION["all_announce"][$device];
    $tokenindex = 0;
    # 1: start, 2: continue
    $start_container = 1;
    foreach ($announcelines as $token => $value) {
        if (!in_array($token,$_SESSION["chapter_token"][$device][$chapter])){
            continue;
        }
        # token for actual chapter only
        $actual_ct = explode(",", $value[0])[0];
        $actual_ot = explode(",", $value[0][0]);
        $next_ct = "";
        $next_ot = "";
        $new_index = $tokenindex + 1;
        while ($new_index < count($_SESSION["all_token"][$device])) {
            # find next ct ignoring selectors
            $new_tok = $_SESSION["all_token"][$device][$new_index];
            if (!strstr($new_tok, "_") and !strstr($new_tok, "a")) {
                $next_ct = explode(",", $announcelines[$new_tok][0])[0];
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
                create_os($token, $value, $_SESSION["actual_data"][$device][$token][0]);
                break;
            case "as":
                create_as($token, $value, $_SESSION["actual_data"][$device][$token][0]);
                break;
            case "or":
                create_or($token, $value, $_SESSION["actual_data"][$device][$token]);
                break;
            case "ar":
                create_ar($token, $value, $_SESSION["actual_data"][$device][$token]);
                break;
            case "at":
                create_at($token, $value, $_SESSION["actual_data"][$device][$token][0]);
                break;
            case "ou":
                create_ou($token, $value);
                break;
            case "op":
                create_op($device, $token, $value, $_SESSION["actual_data"][$device][$token], $start_container);
                break;
            case "ap":
                create_ap($device, $token, $value, $_SESSION["actual_data"][$device][$token]);
                break;
            case "oo":
                create_oo($device, $token, $value, $_SESSION["actual_data"][$device][$token], $start_container);
                break;
            case "om":
                create_om($token, $value, $_SESSION["actual_data"][$device][$token]);
                break;
        }
        if ($actual_ot == $next_ot) {
            if (strpos($token, "_") > 0 or strpos($token, "a") > 0 or strpos($token, "p") > 0 or strpos($token, "o") > 0) {
                $start_container = 2;
            } elseif (($actual_ct == "p" and $next_ct == "o") or ($actual_ct == "o" and $next_ct == "o") or ($actual_ct == "p" and strstr("$next_ct", "o"))) {
                $start_container = 2;
            } else {
                if ($next_ct != "o" and $next_ct != "p" and !strstr($token, "_") and !strstr($token, "a")) {
                    echo "</div></div";
                    $start_container = 1;
                } else {
                    if ($start_container = 2 and !strstr($token, "p") and !strstr($token, "o")) {
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

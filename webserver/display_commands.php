<?php
# display_commands.php
# DK1RI 20221114
function display_commands($device, $chapter){
    $announcelines = $_SESSION["all_announce"][$device];
    foreach ($announcelines as $token => $value) {
        if (!in_array($token,$_SESSION["chapter_token"][$device][$chapter])){
            continue;
        }
        # token for actual chapter only
        $basic_token = basic_tok($token);
        if ($basic_token == $token) {
            echo "<div class = flex-container><div>";
            $command_type = explode(',', $value[0]);
            if ($command_type[0] == "at"){
                $command_type[0] = "as";
            }
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
                case "ou":
                    create_ou($token, $value);
                    break;
                case "op":
                    create_op_oo($token);
                    break;
                case "ap":
                    create_ap($token, $value, $_SESSION["actual_data"][$device][$token]);
                    break;
                case "om":
                    create_om($token, $value, $_SESSION["actual_data"][$device][$token]);
                    break;
            }
            echo "</div></div>";
        }
    }
}
?>

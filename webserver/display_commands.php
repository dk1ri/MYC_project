<?php
# display_commands.php
# DK1RI 20230615
function display_commands(){
    $device = $_SESSION["device"];
    if ($_SESSION["conf"]["testmode"]){create_session_data_file($device, "actual_data", $_SESSION["actual_data"][$device]);}
    $announcelines = $_SESSION["announce_all"][$device];
    $already_done = "";
    foreach ($announcelines as $tok => $value) {
        $basic_tok = basic_tok($tok);
        if (array_key_exists($basic_tok, $_SESSION["tok_list"][$device])){
            if ($already_done == $basic_tok) {
                # for same basic_tok
                continue;
            }
            if (explode(",",$value[0])[0] == "oo"){
                # oo token are handled with op token
                continue;
            }
            if (array_key_exists($basic_tok, $_SESSION["a_to_o"][$device])){
                # as token are handled with corresponding token
                continue;
            }
            $announce = $_SESSION["announce_all"][$device][$tok];
            echo "<div>";
            switch ($announce[0]) {
                case "m":
                    create_basic_command($basic_tok);
                    break;
                case "os":
                    create_os($basic_tok);
                    break;
                case "at":
                    create_at($basic_tok);
                    break;
                case "as":
                    create_as($basic_tok);
                    break;
                case "or":
                    create_or($basic_tok);
                    break;
                case "ar":
                    create_ar($basic_tok);
                    break;
                case "ou":
                    create_ou($basic_tok);
                    break;
                case "op":
                    # "oo is handled here as well
                    create_op_oo($basic_tok);
                    break;
                case "ap":
                    create_ap($basic_tok);
                    break;
                case "om":
                    create_om($basic_tok);
                    break;
                case "on":
                    create_on($basic_tok);
                    break;
                case "am":
                    create_am($basic_tok);
                    break;
                case "an":
                    create_an($basic_tok);
                    break;
                case "oa":
                    create_oa($basic_tok);
                    break;
                case "aa":
                    create_aa($basic_tok);
                    break;
                case "ob":
                    create_ob($basic_tok);
                    break;
                case "ab":
                    create_ab($basic_tok);
                    break;
                case "of":
                    create_of($basic_tok);
                    break;
                case "af":
                    create_af($basic_tok);
                    break;
            }
            echo "</div>";
            $already_done = $basic_tok;
        }
    }
}
?>

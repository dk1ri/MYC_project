<?php
# display_commands.php
# DK1RI 20230205
function display_commands(){
    $device = $_SESSION["device"];
    create_session_data_file($device, "actual_data", $_SESSION["actual_data"][$device]);
    $tok_list = $_SESSION["chapter_token"][$device][$_SESSION["chapter"]];
    $announcelines = $_SESSION["announce_all"][$device];
    $actual = $_SESSION["actual_data"][$device];
    $already_done = "";
    foreach ($announcelines as $tok => $value) {
        $basic_tok = basic_tok($tok);
        if (array_key_exists($basic_tok, $tok_list)){
            $announce = $_SESSION["announce_all"][$device][$tok];
            switch ($announce[0]) {
                case "m":
                    if ($already_done != $basic_tok) {
                        echo "<div>";
                        create_basic_command($basic_tok);
                        echo "</div>";
                        $already_done = $basic_tok;
                    }
                    break;
                case "os":
                    if ($already_done != $basic_tok) {
                        echo "<div>";
                        create_os($basic_tok);
                        echo "</div>";
                        $already_done = $basic_tok;
                    }
                    break;
                case "at":
                case "as":
                    if ($already_done != $basic_tok) {
                        echo "<div>";
                        create_as($basic_tok, $actual[$tok]);
                        echo "</div>";
                        $already_done = $basic_tok;
                    }
                    break;
                case "or":
                    if ($already_done != $basic_tok) {
                        echo "<div>";
                        create_or($basic_tok);
                        echo "</div>";
                        $already_done = $basic_tok;
                    }
                    break;
                case "ar":
                    if ($already_done != $basic_tok) {
                        echo "<div>";
                        create_ar($basic_tok);
                        echo "</div>";
                        $already_done = $basic_tok;
                    }
                    break;
                case "ou":
                    if ($already_done != $basic_tok) {
                        echo "<div>";
                        create_ou($basic_tok);
                        echo "</div>";
                        $already_done = $basic_tok;
                    }
                    break;
                case "op":
                    # "oo is handled here as well
                    if ($already_done != $basic_tok) {
                        echo "<div>";
                        create_op_oo($basic_tok);
                        echo "</div>";
                        $already_done = $basic_tok;
                    }
                    break;
                case "ap":
                    if ($already_done != $basic_tok) {
                        echo "<div>";
                        create_ap($basic_tok);
                        echo "</div>";
                        $already_done = $basic_tok;
                    }
                    break;
                case "om":
                    if ($already_done != basic_tok($tok)) {
                        echo "<div>";
                        create_om(basic_tok($tok));
                        echo "</div>";
                        $already_done = basic_tok($tok);
                    }
                    break;
                case "on":
                    if ($already_done != basic_tok($tok)) {
                        echo "<div>";
                        create_on(basic_tok($tok));
                        echo "</div>";
                        $already_done = basic_tok($tok);
                    }
                    break;
                case "am":
                    if ($already_done != basic_tok($tok)) {
                        echo "<div>";
                        create_am(basic_tok($tok));
                        echo "</div>";
                        $already_done = basic_tok($tok);
                    }
                    break;
                case "an":
                    if ($already_done != basic_tok($tok)) {
                        echo "<div>";
                        create_an(basic_tok($tok));
                        echo "</div>";
                        $already_done = basic_tok($tok);
                    }
                    break;
                case "oa":
                    if ($already_done != basic_tok($tok)) {
                        echo "<div>";
                        create_oa(basic_tok($tok));
                        echo "</div>";
                        $already_done = basic_tok($tok);
                    }
                    break;
                case "aa":
                    if ($already_done != basic_tok($tok)) {
                        echo "<div>";
                        create_aa(basic_tok($tok));
                        echo "</div>";
                        $already_done = basic_tok($tok);
                    }
                case "ob":
                    if ($already_done != basic_tok($tok)) {
                        echo "<div>";
                        create_ob(basic_tok($tok));
                        echo "</div>";
                        $already_done = basic_tok($tok);
                    }
                    break;
                case "ab":
                    if ($already_done != basic_tok($tok)) {
                        echo "<div>";
                        create_ab(basic_tok($tok));
                        echo "</div>";
                        $already_done = basic_tok($tok);
                    }
                    break;
            }
        }
    }
}
?>

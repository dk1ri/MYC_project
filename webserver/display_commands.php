<?php
# display_commands.php
# DK1RI 20240124
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
#
# display one element for each tok (with some exceptions)
function display_commands(){
    global $username, $language, $is_lang, $new_sequncelist, $device, $actual_data, $tok_list;
    if ($_SESSION["conf"]["testmode"]){create_session_data_file($device, "actual_data", $_SESSION["actual_data"][$device]);}
    $announcelines = $_SESSION["announce_all"][$device];
    $already_done = "";
    foreach ($announcelines as $tok => $value) {
        $basic_tok = basic_tok($tok);
        if (array_key_exists($basic_tok,$_SESSION["meter"][$device])){
            $field = $_SESSION["original_announce"][$device][basic_tok($tok)];
            if (strstr(explode(",",$field[0])[1],"ext")){
                # no display, if this is ext command
                continue;
            }
        }
        if (array_key_exists($basic_tok, $tok_list)){
            if ($already_done == $basic_tok) {
                # for same basic_tok
                continue;
            }
            if ($value == "oo"){
                # oo token are handled with op token
                continue;
            }
            if (array_key_exists($basic_tok, $_SESSION["a_to_o"][$device])){
                # as token are handled with corresponding token
                continue;
            }
            $announce = $_SESSION["announce_all"][$device][$tok];
            echo "<div>";
            # most create_"xx" functions are found in commands_"x".php
            switch ($announce) {
             #   case "m":
              #      create_basic_command($basic_tok);
               #     break;
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
                case "ka":
                    create_oa($basic_tok);
                    break;
                case "aa":
                case "la":
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

function create_basic_command($basic_tok){
    global $username, $language, $is_lang, $new_sequncelist, $device, $actual_data;
    $field = explode(",", $_SESSION["actual_data"][$device][$basic_tok."a"]);
    echo "<div>Device: " . $field[0] . ", Version: " . $field[1] . ", Author: ". $field[2]."<br></div>";
}

function display_start_with_stack($basic_tok){
    global $username, $language, $is_lang, $new_sequncelist, $device, $actual_data;
    echo $_SESSION["des_name"][$device][$basic_tok] . ": ";
    if (array_key_exists($basic_tok."mx", $_SESSION["des_name"][$device])) {
        echo $_SESSION["des_name"][$device][$basic_tok . "mx"] . ": ";
        if (array_key_exists($basic_tok . "m0", $_SESSION["des"][$device])) {
            # one or more stack display elements available
            selector($basic_tok);
        }
    }
}

function display_as($tok){
    # for "as"token
    global $username, $language, $is_lang, $new_sequncelist, $device, $actual_data;
    $tok = basic_tok($tok)."a";
    echo $language["read"] . ": ";
    echo "<input type='checkbox' id=" . $tok . " name=" . $tok . " value=1>";
    # reset
    $_SESSION["actual_data"][$device][$tok] = 0;
}
?>

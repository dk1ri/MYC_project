<?php
# display_commands.php
# DK1RI 20240512
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
#
# display one element for each tok (with some exceptions)
function display_commands(){
    $device = $_SESSION["device"];
    if ($_SESSION["conf"]["testmode"]){for_tests();}
    $already_done = "";
    foreach ($_SESSION["activ_chapters"][$device] as $chapter){
        $list = $_SESSION["new_sequencelist"][$device][$chapter];
        foreach ($list as $sequence => $basic_tok) {
            # $value is ct!
            $value = explode(",", $_SESSION["original_announce"][$device][$basic_tok][0])[0];
            if (array_key_exists($basic_tok,$_SESSION["meter"][$device])){
                $field = $_SESSION["original_announce"][$device][$basic_tok];
                if (strstr(explode(",",$field[0])[1],"ext")){
                    # no display, if this is ext command
                    continue;
                }
            }
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
            echo "<div>";
            # most create_"xx" functions are found in commands_"x".php
            switch ($value) {
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

function create_basic_command(){
    $field = $_SESSION["original_announce"][$_SESSION["device"]][0];
    echo "<div>".tr("device").": " . tr($field[2]) . ", ",tr("version").": " . tr($field[3]) . ", ".tr("author").": ". $field[1]."<br></div>";
}

function display_start_with_stack($basic_tok){
    echo tr($_SESSION["des_name"][$_SESSION["device"]][$basic_tok]) . ": ";
    if (array_key_exists($basic_tok."mx", $_SESSION["des_name"][$_SESSION["device"]])) {
        echo tr($_SESSION["des_name"][$_SESSION["device"]][$basic_tok . "mx"]) . ": ";
        if (array_key_exists($basic_tok . "m0", $_SESSION["des"][$_SESSION["device"]])) {
            # one or more stack display elements available
            selector($basic_tok);
        }
    }
}

function display_as($tok){
    # for "as"token
    $tok = basic_tok($tok)."a";
    echo tr("read") . ": ";
    echo "<input type='checkbox' id=" . $tok . " name=" . $tok . " value=1>";
    # reset
    $_SESSION["actual_data"][$_SESSION["device"]][$tok] = 0;
}

function display_chapter($chapters){
    echo "<div>";
    $i = 0;
    foreach ($_SESSION["chapter_names_with_space"][$_SESSION["device"]] as $key => $value) {
        echo "<td>";
        echo "<input type='checkbox' name=" . "chapter_".$value . " id=" . "chapter_".$key . ">";
        if (array_key_exists($value,$chapters)) {
            echo "<strong class = 'green'>";
        } else {
            echo "<strong class = 'red'>";
        }
        echo "<label for " .$value . ">" . tr($key) . "</label></strong></td>";
        $i += 2;
    }
    echo "</div>";
}
?>

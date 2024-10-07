<?php
# display_commands.php
# DK1RI 20240913
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
#
# display one element for each tok (with some exceptions)
function display_commands(){
    $device = $_SESSION["device"];
    if ($_SESSION["conf"]["testmode"]){create_data_file("actual_data", "0", 0,1);}
    $already_done = "";
    foreach ($_SESSION["final_actual_sequencelist_by_sequence"][$device] as $basic_tok){
        if ($_SESSION["toks_to_ignore"][$device][$basic_tok] == 0) {
            continue;
        }
        # $value is ct!
        $value = explode(",", $_SESSION["original_announce"][$device][$basic_tok][0])[0];
        if (array_key_exists($basic_tok, $_SESSION["meter"][$device])) {
            $field = $_SESSION["original_announce"][$device][$basic_tok];
            if (strstr(explode(",", $field[0])[1], "ext")) {
                # no display, if this is ext command
                continue;
            }
        }
        if ($already_done == $basic_tok) {
            # for same basic_tok
            continue;
        }
        if ($value == "oo") {
            # oo token are handled with op token
            continue;
        }
        if (array_key_exists($basic_tok, $_SESSION["a_to_o"][$device])) {
            # as token are handled with corresponding token
            continue;
        }
        echo "<div>";
        # most create_"xx" functions are found in commands_"x".php
        switch ($value) {
            case "m":
                create_basic_command($basic_tok);
                break;
            case "os":
            case "ks":
                create_os($basic_tok);
                break;
            case "at":
            case "lt":
                create_at($basic_tok);
                break;
            case "as":
            case "ls":
                create_as($basic_tok);
                break;
            case "or":
            case "kr":
                create_or($basic_tok);
                break;
            case "ar":
            case "lr":
                create_ar($basic_tok);
                break;
            case "ou":
            case "ku":
                create_ou($basic_tok);
                break;
            case "op":
            case "kp":
                # "oo is handled here as well
                create_op_oo($basic_tok);
                break;
            case "ap":
            case "lp":
                create_ap($basic_tok);
                break;
            case "om":
            case "km":
                create_om($basic_tok);
                break;
            case "on":
            case "kn":
                create_on($basic_tok);
                break;
            case "am":
            case "lm":
                create_am($basic_tok);
                break;
            case "an":
            case "ln":
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
            case "kb":
                create_ob($basic_tok);
                break;
            case "ab":
            case "lb":
                create_ab($basic_tok);
                break;
            case "of":
            case "kf":
                create_of($basic_tok);
                break;
            case "af":
            case "lf":
                create_af($basic_tok);
                break;
        }
        echo "</div>";
        $already_done = $basic_tok;
    }
}

function create_basic_command($basic_tok){
    echo "<div>".tr("device").": " . $_SESSION["dev"][$_SESSION["device"]][$basic_tok]."<br></div>";
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

function display_chapter(){
    echo "<div>";
    foreach ($_SESSION["chapter_names_with_space"][$_SESSION["device"]] as $key => $value) {
        echo "<td>";
        echo "<input type='checkbox' name=" . "chapter_".$key . " id=" . "chapter_".$key . ">";
        if (array_key_exists($key,$_SESSION["activ_chapters"][$_SESSION["device"]])) {
            echo "<strong class = 'green'>";
        } else {
            echo "<strong class = 'red'>";
        }
        echo "<label for " .$key . ">" . tr($value) . "</label></strong></td>";
    }
    echo "</div>";
}
function create_final_actual_sequencelist(){
    # updated form $_SESSION["chapter_token_pure"][$device] when chapters or toks_to_ignore and sequence is changed
    $device = $_SESSION["device"];
    $_SESSION["final_actual_sequencelist_by_sequence"][$device] = [];
    foreach ($_SESSION["actual_sequencelist_by_sequence"][$device] as $sequence => $tok){
        if (array_key_exists($tok, $_SESSION["toks_to_ignore"][$device]) and $_SESSION["toks_to_ignore"][$device][$tok] == 1){
            foreach ($_SESSION["activ_chapters"][$device] as $chapter){
                foreach ($_SESSION["chapter_token_pure"][$device] as $dat1){
                    foreach ($dat1 as $chap => $dat2){
                        if($chap == $chapter) {
                            foreach ($dat2 as $tok_ => $value) {
                                if ($tok_ == $tok) {
                                    $_SESSION["final_actual_sequencelist_by_sequence"][$device][$sequence] = $tok;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
?>

<?php
# translate.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function correct_POST(){
    # $_POST values are stored in $actual_data, even if they are wrong (for manual entries)
    # for sending:
    # only those $POST commands with manual data entry must be checked
    # -> only those, where $_SESSION["to_correct"][$device]][$basictok].*) exists
    # for invalid data (for manual entries) $_SESSION["send_ok"] is set to 0
    # &B and &H values are checked and converted
    # positive result is in $_SESSION["tok_to_send"]  and $_SESSION["send_string_by_tok"]
    # send of data with no change is decided by commandtype
    $device = $_SESSION["device"];
    $_SESSION["tok_to_send"] = [];
    $_SESSION["send_string_by_tok"] = [];
    foreach ($_POST as $token => $value) {
        $basic_tok = basic_tok($token);
        # special POST (no tok)
        if (!is_numeric($basic_tok)){continue;}
        if ($basic_tok ==""){continue;}
        $_SESSION["send_ok"] = 1;
        # $_POST copied to $actual_data without modifications (if copied, see correct_xx)
        # something like interface ..:
        if (!array_key_exists($basic_tok, $_SESSION["original_announce"][$device])) {
            # not transmitted
            continue;
        }
        if (array_key_exists($token, $_SESSION["to_correct"][$device]) and $value == "") {
            # manual entry without entry in _POST (no new entry)
            continue;
        }
        # not again for token with same basic_tok:
        # check, if answer for operate exists in $_POST - > ignore operate
        if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$device])){
            if (array_key_exists($_SESSION["o_to_a"][$device][$basic_tok] . "a", $_POST)) {
                if ($_POST[$_SESSION["o_to_a"][$device][$basic_tok] . "a"] == 0) {
                    $_SESSION["send_ok"] = 0;
                    continue;
                }
            }
        }
        # ############################################################# ???: (! entfernt
        if (!array_key_exists($basic_tok, $_SESSION["tok_to_send"])) {
            $ct = $_SESSION["announce_all"][$device][$token];
            switch ($ct) {
                case "os":
                    correct_for_send_os($basic_tok);
                    break;
                case "as":
                case "at":
                    correct_for_send_asat($basic_tok);
                    break;
                case "or":
                    correct_for_send_or($basic_tok);
                    break;
                case "ar":
                    correct_for_send_ar($basic_tok);
                    break;
                case "ou":
                    correct_for_send_ou($basic_tok);
                    break;
                case "op":
                case "oo":
                    correct_for_send_op($basic_tok);
                    break;
                case "ap":
                    correct_for_send_ap($basic_tok);
                    break;
                case "oa":
                    correct_for_send_oa($basic_tok);
                    break;
                case "aa":
                    correct_for_send_aa($basic_tok);
                    break;
                case "ob":
                    correct_for_send_ob($basic_tok);
                    break;
                case "ab":
                    correct_for_send_ab($basic_tok);
                    break;
                case "om":
                    correct_for_send_om($basic_tok);
                    break;
                case "am":
                    correct_for_send_am($basic_tok);
                    break;
                case "on":
                    correct_for_send_on($basic_tok);
                    break;
                case "an":
                    correct_for_send_an($basic_tok);
                    break;
                case "of":
                    correct_for_send_of($basic_tok);
                    break;
                case "af":
                    correct_for_send_af($basic_tok);
                    break;
            }
        }
    }
}

function check_send_if_a_exists($basic_tok){
    # for "o" command: do not send, if POST of corresponding "a" command was set
    if (array_key_exists($basic_tok, $_SESSION["o_to_a"][$_SESSION["device"]])) {
        $a_tok = $_SESSION["o_to_a"][$_SESSION["device"]][$basic_tok]."a";
        # do not send if answer is set
        if (array_key_exists($a_tok, $_POST) and $_POST[$a_tok] == 1) {
            $_SESSION["send_ok"] = 0;
        }
    }
}
?>
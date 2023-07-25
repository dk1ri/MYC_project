<?php
# display_commands.php
# DK1RI 20230615
# display one element for each tok (with some exceptions)
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
            # most create_"xx" functions are found in commands_"x".php
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

function create_basic_command($basic_tok){
    $device = $_SESSION["device"];
    $field = explode(",", $_SESSION["actual_data"][$device][$basic_tok."a"]);
    echo "<div>Device: " . $field[0] . ", Version: " . $field[1] . ", Author: ". $field[2];
    echo "<br>" . $_SESSION["user"]["language"][$_SESSION["user"]["username"]]["new_data"] . ": ";
    echo "<input type='checkbox' id=".$basic_tok . "a name=".$basic_tok."a value=1>";
    echo "</div>";
}

function display_as($tok){
    # for "as"token
    $device = $_SESSION["device"];
    $tok = basic_tok($tok)."a";
    echo $_SESSION["user"]["language"][$_SESSION["user"]["username"]]["read_data"] . ": ";
    echo "<input type='checkbox' id=" . $tok . " name=" . $tok . " value=1>";
    # reset
    $_SESSION["actual_data"][$device][$tok] = 0;
}

function actual_data_to_real($tok){
    # $_SESSION["to_correct"][$device][$tok] must exist
    $device = $_SESSION["device"];
    $data = $_SESSION["actual_data"][$device][$tok];
    if (!array_key_exists($tok, $_SESSION["to_correct"][$device])){return $data;}
    $range_elements = explode(",", $_SESSION["to_correct"][$device][$tok]);
    if ($range_elements[0] == 1){
        # big value, use des
        $range_elements = explode(",", $_SESSION["des"][$device][$tok]);
        # drop max value
        array_splice($range_elements,0,1);
    }
    $act_value = 0;
    $i = 0;
    $found = 0;
    $result = "";
    while ($i < count($range_elements) and $found == 0){
        if (strstr($range_elements[$i], "_")){
            list ($separator, $from, $to) = split_range($range_elements[$i]);
            if ($separator <= 0){$separator = 1;}
            $maxcount = ($to - $from)/ $separator;
            if ($maxcount < $data){
                # next
                $act_value += $maxcount;
                # should not be used
                $result = $to;
            }
            else {
                # will be found here
                # number of counts to find the real value
                $counts = $data - $act_value;
                $result = $from + $counts * $separator;
            }
        }
        else{
            if ($i >= $data){
                $found = 1;
                $result = $range_elements[$i];
            }
            $act_value += 1;
        }
        $i += 1;
    }
    return $result;
}
?>

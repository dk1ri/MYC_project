<?php
# user_data.php
# DK1RI 20240902
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function read_user_data(){
    # read existing data from _SESSION or file or create a new set
    # userdata are: $language, $_SESSION["is_lang"] and (preferred) device, color, translate_by_language,
    # and per device: $active_chapters, actual_sequencelist tok_to_ignore
    $username = $_SESSION["username"];
    $old_dev = $_SESSION["device"];
    if (array_key_exists($_SESSION["username"],$_SESSION["user_data"])) {
        # SESSION exist -> copy; device data are read already
        read_data_from_user_data($username);
    }
    elseif (is_dir( $_SESSION["conf"]["user_dir"] . "\\" . $username)) {
        # read from file
        read_user_data_from_file($_SESSION["conf"]["user_dir"] . "\\" . $_SESSION["username"]);
        # SESSION exist now -> copy
        read_data_from_user_data($username);
        if ($old_dev != $_SESSION["device"]) {
            # create new device if not existing
            create_new_device();
            # some data my have been overwritten -> read again
            read_data_from_user_data($username);
        }
    }
    else{
        # nothing exist; create data for new user
        create_SESSION_user_data($username);
        # create new device if not existing
        create_new_device();
        }
}

function create_SESSION_user_data($username){
    # nothing exist; create data for new user
    if (!array_key_exists($username,$_SESSION["user_data"])){$_SESSION["user_data"][$username] = [];}
    $_SESSION["user_data"][$username]["is_lang"] = $_SESSION["is_lang"];
    $_SESSION["user_data"][$username]["color"] = $_SESSION["color"];
    $_SESSION["user_data"][$username]["device"] = $_SESSION["device"];
    $device = $_SESSION["device"];
    $_SESSION["user_data"][$username][$device]["activ_chapters"] = $_SESSION["activ_chapters"][$device];
    $_SESSION["user_data"][$username][$device]["actual_sequencelist"] = $_SESSION["actual_sequencelist"][$device];
    $_SESSION["user_data"][$username][$device]["actual_sequencelist_by_sequence"] = $_SESSION["actual_sequencelist_by_sequence"][$device];
    $_SESSION["user_data"][$username][$device]["final_actual_sequencelist_by_sequence"] = $_SESSION["final_actual_sequencelist_by_sequence"][$device];
    $_SESSION["user_data"][$username][$device]["translate_by_language"] = $_SESSION["translate_by_language"][$device];
    $_SESSION["user_data"][$username][$device]["toks_to_ignore"] = $_SESSION["toks_to_ignore"][$device];
    $_SESSION["user_data"][$username][$device]["edit_toks_to_ignore"] = $_SESSION["edit_toks_to_ignore"][$device];
}

function read_data_from_user_data($username){
    $_SESSION["is_lang"] = $_SESSION["user_data"][$username]["is_lang"];
    $_SESSION["device"] = $_SESSION["user_data"][$username]["device"];
    $device = $_SESSION["device"];
    $_SESSION["color"] = $_SESSION["user_data"][$_SESSION["username"]]["color"];
    $_SESSION["activ_chapters"][$device] = $_SESSION["user_data"][$username][$device]["activ_chapters"];
    $_SESSION["actual_sequencelist"][$device] = $_SESSION["user_data"][$username][$device]["actual_sequencelist"];
    $_SESSION["actual_sequencelist_by_sequence"][$device] = $_SESSION["user_data"][$username][$device]["actual_sequencelist_by_sequence"];
    $_SESSION["final_actual_sequencelist_by_sequence"][$device] = $_SESSION["user_data"][$username][$device]["final_actual_sequencelist_by_sequence"];
    $_SESSION["translate_by_language"][$device] = $_SESSION["user_data"][$username][$device]["translate_by_language"];
    $_SESSION["toks_to_ignore"][$device] = $_SESSION["user_data"][$username][$device]["toks_to_ignore"];
    $_SESSION["edit_toks_to_ignore"][$device] = $_SESSION["user_data"][$username][$device]["edit_toks_to_ignore"];
}

function  read_user_data_from_file($user_dir){
    # read from file or create default dir and $_SESSION"user_data"]...
    # user data exist
    # not used read from file:
    $username = $_SESSION["username"];
    $data_file = $user_dir."\\data";
    $file = fopen($data_file, "r");
    $i = 0;
    while (!(feof($file))) {
        $line = fgets($file);
        $line = str_replace("\r", "", $line);
        $line = str_replace("\n", "", $line);
        switch ($i) {
            case  0:
                $_SESSION["is_lang"] = $line;
                $_SESSION["user_data"][$username]["is_lang"] = $line;
                break;
            case 1:
                $_SESSION["device"] = $line;
                $_SESSION["user_data"][$username]["device"] = $line;
        }
        $i++;
    }
    fclose($file);
    # $S_SESSION["device"] required
    # color list
    read_data_file("color", 2, 0);
    # activ_chapters exist
    read_data_file("activ_chapters", 0, 0);
    # actual_sequencelist
    read_data_file("actual_sequencelist", 0, 0);
    read_data_file("actual_sequencelist_by_sequence", 0, 0);
    read_data_file("final_actual_sequencelist_by_sequence", 0, 0);
    # translate
    read_data_file("translate_by_language", 0, 1);
    # toks_to_ignore
    read_data_file("toks_to_ignore",0, 0);
    read_data_file("edit_toks_to_ignore",0, 0);
    read_data_file("named_tok_list",0, 0);
    $_SESSION["named_tok_lists"][$_SESSION["username"]] = $_SESSION["named_tok_list"] ;
}

function store_permanent(){
    if ($_SESSION["username"] != "user") {
        $username = $_SESSION["username"];
        create_SESSION_user_data($username);
        check_user_dir_exist();
        # store actual data to username
        $file = fopen($_SESSION["conf"]["user_dir"] . $username . "\\data", "w");
        fwrite($file, $_SESSION["is_lang"] . "\r\n");
        fwrite($file, $_SESSION["user_data"][$username]["device"] . "\r\n");
        fclose($file);
        # color
        create_data_file("color", 1,0,0);
        # activ_chapters
        create_data_file("activ_chapters", 1,0,1);
        # actual_sequencelist
        create_data_file("actual_sequencelist", 1,0,1);
        create_data_file("actual_sequencelist_by_sequence", 1,0,1);
        create_data_file("final_actual_sequencelist_by_sequence", 1,0,1);
        # translatactual_sequenceliste
        create_data_file("translate_by_language", 1,1,1);
        # toks_to_ignore
        create_data_file("toks_to_ignore", 1,0,1);
        create_data_file("edit_toks_to_ignore", 1,0,1);
        if (array_key_exists($_SESSION["username"], $_SESSION["named_tok_lists"])) {
            $_SESSION["named_tok_list"] = $_SESSION["named_tok_lists"][$_SESSION["username"]];
            create_data_file("named_tok_list", 1, 1,1);
        }
    }
}
function check_user_dir_exist(){
    if (!is_dir($_SESSION["conf"]["user_dir"])){mkdir($_SESSION["conf"]["user_dir"]);}
    if (!is_dir($_SESSION["conf"]["user_dir"]."/".$_SESSION["username"])){
        mkdir($_SESSION["conf"]["user_dir"]."/".$_SESSION["username"]);
    }
    if (!is_dir($_SESSION["conf"]["user_dir"]."/".$_SESSION["username"]."/".$_SESSION["device"])){
        mkdir($_SESSION["conf"]["user_dir"]."/".$_SESSION["username"]."/". $_SESSION["device"]);
    }
}

?>
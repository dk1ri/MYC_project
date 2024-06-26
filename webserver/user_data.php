<?php
# user_data.php
# DK1RI 20240420
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function read_user_data(){
    # userdata are: $language, $_SESSION["is_lang"] and (preferred) device
    # and per device: color, $active_chapters, new_sequencelist
    $device = $_SESSION["device"];
    $username = $_SESSION["username"];
    $new_device = 0;
    if (array_key_exists($_SESSION["username"],$_SESSION["user_data"])) {
        # SESSION exist -> copy
        $_SESSION["is_lang"] = $_SESSION["user_data"][$username]["is_lang"];
        if ($_SESSION["device"] != $_SESSION["user_data"][$username]["device"]) {
            $_SESSION["device"] = $_SESSION["user_data"][$username]["device"];
            $device = $_SESSION["device"];
            $new_device = 1;
        }
        $_SESSION["color"] = $_SESSION["user_data"][$_SESSION["username"]]["color"];
        $_SESSION["activ_chapters"][$device] = $_SESSION["user_data"][$username][$device]["activ_chapters"];
        $_SESSION["new_sequencelist"][$device] = $_SESSION["user_data"][$username][$device]["new_sequencelist"];
    }
    elseif (is_dir( $_SESSION["conf"]["user_dir"] . "\\" . $_SESSION["username"])) {
        #read from file or copy default
        $dev = read_user_data_from_file();
        if ($_SESSION["device"] != $dev) {
            $_SESSION["device"] = $dev;
            $new_device = 1;
        }
    }
    else{
        # nothing exist; create data for new user
        $_SESSION["user_data"][$username]["is_lang"] = $_SESSION["is_lang"];
        $_SESSION["user_data"][$username]["color"] = $_SESSION["color"];
        $_SESSION["user_data"][$username]["device"] = $_SESSION["device"];
        $_SESSION["user_data"][$username][$device]["activ_chapters"] = $_SESSION["activ_chapters"][$device];
        $_SESSION["user_data"][$username][$device]["new_sequencelist"] = $_SESSION["new_sequencelist"][$device];
        # no default for translate
        }
    if ($new_device){init_data();}
}

function  read_user_data_from_file(){
    # read from file or create default dir and $_SESSION"user_data"]...
    check_user_dir_exist();
    $device = $_SESSION["device"];
    $username = $_SESSION["username"];
    $data_file = $_SESSION["conf"]["user_dir"] . "\\" . $username."\\data";
    if (file_exists($data_file)) {
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
                    $device = $line;
                    $_SESSION["device"] = $line;
            }
            $i++;
        }
        fclose($file);
    }
    else{
        # no change
        $_SESSION["user_data"][$username]["is_lang"] = $_SESSION["is_lang"];
        $device = $_SESSION["device"];
    }
    # color list
    prepare_read_file("color",1);
    # activ_chapters exist
    prepare_read_file("activ_chapters",1);
    # new_sequencelist
    prepare_read_file("new_sequencelist", 1);
    # translate
    prepare_read_file("translate", 0);
    return $device;
}

function prepare_read_file($name, $default){
    $device = $_SESSION["device"];
    $username = $_SESSION["username"];
    $data_file = $_SESSION["conf"]["user_dir"] . "\\" . $username."\\". $name;
    if (file_exists($data_file)) {
        read_data_file("$name", 1);
        $_SESSION[$name] = $_SESSION["user_data"][$username]["$name"];
    }
    else {
        if ($default) {
            $_SESSION["user_data"][$username][$name] = $_SESSION[$name];
        }
    }
}

function write_user_data_to_file(){
    if ($_SESSION["username"] != "user") {
        check_user_dir_exist();
        $username = $_SESSION["username"];
        # store actual data to username
        $file = fopen($_SESSION["conf"]["user_dir"] . $username . "\\data", "w");
        fwrite($file, $_SESSION["is_lang"] . "\r\n");
        fwrite($file, $_SESSION["user_data"][$username]["device"] . "\r\n");
        fclose($file);
        # color
        create_data_file("color", 1);
        # activ_chapters
        create_data_file("activ_chapters", 1);
        # new_sequencelist
        create_data_file_array("new_sequencelist", 1);
    }
}

function create_tok_list_one_chapter($chapter){
    $device = $_SESSION["device"];
    $i = 0;
    foreach ($_SESSION["chapter_token_pure"][$device][$chapter] as $basic_tok ) {
        if ($basic_tok != 0) {
            $tok_list[$i] = $basic_tok;
            $i++;
        }
    }
    return $tok_list;
}

function create_tok_list(){
    # $tok_list contain basic_tok for active chapters
    $device = $_SESSION["device"];
    foreach ($_SESSION["chapter_names"][$device] as $chapter){
        $_SESSION["new_sequencelist"][$device][$chapter] = create_tok_list_one_chapter($chapter);
    }
}

function create_default_chapter_names(){
    $device = $_SESSION["device"];
    if (count($_SESSION["chapter_names"][$device]) > 5) {
        $_SESSION["activ_chapters"][$device]["all_basic"] = "all_basic";
        $_SESSION["activ_chapters"][$device]["ADMINISTRATION"] = "ADMINISTRATION";
    }
    else{
        foreach ($_SESSION["chapter_names"][$device] as $chpter){
            $_SESSION["activ_chapters"][$device][$chpter] = $chpter;
        }
    }
}
?>
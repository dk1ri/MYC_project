<?php
# user_data.php
# DK1RI 20240423
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function read_user_data(){
    global $username, $language, $is_lang;
    if ($username == ""){$username = "user";}
    # userdata are: $language, $is_lang
    # and per devive: $active_chapters, $tok_list(all toks, sorted per chapter)
    # $device is not stored, because the stored may be not available
    $user_dir = $_SESSION["conf"]["user_data_dir"] . "\\" . $username;
    if (array_key_exists($username, $_SESSION["user_data"])) {
        read_from_session();
        # exist device_dir?
        read_device_from_session();
    }
    elseif (is_dir($user_dir)) {
        # check file
        read_from_file();
        # exist device_dir
        read_device_from_file();
    }
    else {
        # default
        # create new $_SESSION[>"user"} is done at end of action.php
        $is_lang = "english";
        $language = $_SESSION["lang"][$is_lang];
        get_default_for_device();
    }
}

function read_from_session(){
    global $username, $device, $language, $is_lang;
    $language = $_SESSION["user_data"][$username]["language"];
    $is_lang = $_SESSION["user_data"][$username]["is_lang"];
    if ($device == "") {$device = $_SESSION["user_data"][$username]["device"];}
}

function read_device_from_session(){
    global $username, $device, $activ_chapters, $activ_tok_list;
    if (array_key_exists($device, $_SESSION["user_data"][$username])) {
        $activ_chapters = $_SESSION["user_data"][$username][$device]["activ_chapters"];
        $activ_tok_list = $_SESSION["user_data"][$username][$device]["activ_tok_list"];
    }
    else{
        get_default_for_device();
    }
}

function  read_from_file(){
    global $username, $language, $is_lang;
    $user_data = $_SESSION["conf"]["user_data_dir"] . "\\" . $username."\\data";
    if (file_exists($user_data)){
        # file exits
        $file = fopen($user_data, "r");
        $i = 0;
        while (!(feof($file))) {
            $line = fgets($file);
            $line = str_replace("\r", "", $line);
            $line = str_replace("\n", "", $line);
            switch ($i) {
                case  0:
                    $language = $line;
                    break;
                case  1:
                    $is_lang = $line;
                    break;
            }
            $i++;
        }
        fclose($file);
    }
    write_to_session();
}

function read_device_from_file(){
    global $username, $device, $activ_chapters, $activ_tok_list;
    $device_dir = $_SESSION["conf"]["user_data_dir"] . "\\" . $username."\\".$device;
    if (is_dir($device_dir)){
        $file_name = $device_dir."\\". "activ_chapters";
        $file = fopen($file_name, "r");
        $line = fgets($file);
        $activ_chapters = hex_to_array($line);
        fclose($file);
        $file_name = $device_dir."\\". "activ_tok_list";
        $file = fopen($file_name, "r");
        $line = fgets($file);
        $activ_tok_list = hex_to_array($line);
        fclose($file);
    }
    else{
        # not yet saved for user -> default
        get_default_for_device();
    }
}
function write_to_session(){
    global $username, $device, $language, $is_lang;
    # store actual data to$SESSION
    $_SESSION["user_data"][$username]["language"] = $language;
    $_SESSION["user_data"][$username]["is_lang"] = $is_lang;
    $_SESSION["user_data"][$username]["device"] = $device;
}

function write_device_to_session(){
    global $username, $device, $activ_chapters, $activ_tok_list;
    if (!array_key_exists($device, $_SESSION["user_data"][$username])) {
        $_SESSION["user_data"][$username][$device]["activ_chapters"][$device] = [];
    }
    $_SESSION["user_data"][$username][$device]["activ_chapters"] = $activ_chapters;
    $_SESSION["user_data"][$username][$device]["activ_tok_list"] = $activ_tok_list;
}
function write_to_file(){
    global $username, $device,$language, $is_lang;
    $user_data = $_SESSION["conf"]["user_data_dir"] . "\\" . $username."\\".$device;
    # store actual data to username
    $file = fopen($user_data, "w");
    fwrite($file,$language."\r\n");
    fwrite($file,$is_lang."\r\n");
    fclose($file);
    write_to_session();
}

function get_default_for_device(){
    global $device, $activ_chapters;
    $activ_chapters = [];
    if (count($_SESSION["chapter_names"][$device]) > 5) {
        $activ_chapters["all_basic"] = "all_basic";
        $activ_chapters["ADMINISTRATION"] = "ADMINISTRATION";
    }
    else{
        foreach ($_SESSION["chapter_names"][$device] as $ch) {
            $activ_chapters[$ch] = $ch;
        }
    }
    create_tok_list();
}
function create_tok_list(){
    # $activ_tok_list contain basic_tok for activ chapters
    global $device,$activ_chapters, $activ_tok_list;
    $activ_tok_list = [];
    foreach ($_SESSION["chapter_token_pure"][$device] as  $chapter => $data) {
        if (array_key_exists($chapter, $activ_chapters)){
            foreach ($_SESSION["chapter_token_pure"][$device][$chapter] as $basic_tok => $val){
                if (!array_key_exists($basic_tok, $activ_tok_list)) {
                    $ct = explode(",", $_SESSION["original_announce"][$device][$basic_tok][0]);
                    if (count($ct) > 1) {$activ_tok_list[$basic_tok] =  $ct[0];}
                }
            }
        }
    }
}

function hex_to_array($line){
    # convert hex string of datafile to array
    # sequence is: key;data,data...;key, data
    $i = 0;
    $key = "";
    $is_data = 0;
    $ar = [];
    $data = "";
    while ($i < strlen($line)) {
        $hex_character = substr($line, $i, 2);
        $char = hexdec($hex_character);
        if ($char == 59) {
            # ;
            $ar[$key][] = $data;
            $key = "";
            $is_data = 0;
        } elseif ($char == 44) {
            if ($data == "") {
                $is_data = 1;
            } else {
                $ar[$key][] = $data;
                $data = "";
            }
        } else {
            if ($is_data == 0) {
                $key .= chr($char);
            } else {
                $data .= chr($char);
            }
        }
        $i += 2;
    }
    return $ar;
}

function array_to_hex($array){
    $line = "";
    foreach ($array as $key => $value){
        $i = 0;
        while ($i < strlen($key)){
            $line .= dec_hex(ord($key), 2);
            $i ++;
        }
        $i = 0;
        $line[] = 0x2C;
        while ( $i < strlen($value)){
            $line .= dec_hex(($key), 2);
            $i ++;
        }
        $line .= 0x3B;
    }
}

?>
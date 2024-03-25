<?php
# user_data.php
# DK1RI 20240423
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function read_user_data(){
    global $username, $language, $is_lang,$new_sequncelist, $device, $actual_data,$activ_chapters, $tok_list;;
    if ($username == ""){$username = "uswer";}
    $user_data = $_SESSION["conf"]["user_data_dir"]."\\".$username;
    if (array_key_exists($username, $_SESSION["user_data"])){
        read_from_session();
    }
    elseif (file_exists($user_data)) {
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
                case 2:
                    $new_sequncelist = hex_to_array($line);
                    break;
                case 3:
                    $device = $line;
                    break;
                case 4:
                    $actual_data = hex_to_array($line);
                    break;
                case 5:
                    $activ_chapters = hex_to_array($line);
                    break;
                case 6:
                    $tok_list = hex_to_array($line);
                    break;
            }
            $i++;
        }
    }
    else{
        write_user_data($user_data);
    }
}

function hex_to_array($line){
    # sequence is: key;data,data...;key, data
    $i = 0;
    $key = "";
    $is_data = 0;
    while ($i < strlen($line)){
        $hex_character = substr($line,$i, 2);
        $char = hexdec($hex_character);
        if ($char == 59){
            # ;
            $ar[$key][] = $data;
            $data = "";
            $key = "";
            $is_data = 0;
        }
        elseif ($char == 44) {
            if ($data == ""){
                $is_data = 1;
            }
            else{
                $ar[$key][] = $data;
                $data = "";
            }
        }
        else{
            if ($is_data == 0){
                $key .= chr($char);
            }
            else{
                $data .= chr($char);
            }
        }
        $i += 2;
    }
    return $ar;
}
function write_user_data($user_data){
    global $language, $is_lang,$new_sequncelist, $device, $actual_data, $activ_chapters, $tok_list;
    # store actual data to new name
    $file = fopen($user_data, "w");
    fwrite($file,$language."\r\n");
    fwrite($file,$is_lang."\r\n");
    fwrite($file,array_to_hex($new_sequncelist)."\r\n");
    fwrite($file,$device."\r\n");
    fwrite($file,array_to_hex($actual_data)."\r\n");
    fwrite($file,array_to_hex($activ_chapters)."\r\n");
    fwrite($file,array_to_hex($tok_list)."\r\n");
    fclose($file);
    write_to_session();
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

function write_to_session(){
    global $username, $language, $is_lang,$new_sequncelist, $device, $actual_data, $activ_chapters,$tok_list;
    # store actual data to$SESSION
    $_SESSION["user_data"][$username]["language"] = $language;
    $_SESSION["user_data"][$username]["$is_lang"] = $is_lang;
    $_SESSION["user_data"][$username]["new_sequncelist"] = $new_sequncelist;
    $_SESSION["user_data"][$username]["device"] = $device;
    $_SESSION["user_data"][$username]["actual_data"][] = $actual_data;
    $_SESSION["user_data"]["user"]["activ_chapters"] = $activ_chapters;
    $_SESSION["user_data"]["user"]["tok_list"] = $tok_list;
}

function read_from_session(){
    global $username, $language, $is_lang, $new_sequncelist, $device, $actual_data, $activ_chapters, $tok_list;
    $language = $_SESSION["user_data"][$username]["language"];
    $is_lang = $_SESSION["user_data"][$username]["is_lang"];
    $new_sequncelist = $_SESSION["user_data"][$username]["new_sequncelist"];
    $device = $_SESSION["user_data"][$username]["device"];
    $actual_data = $_SESSION["user_data"][$username]["actual_data"];
    $activ_chapters = $_SESSION["user_data"]["user"]["activ_chapters"];
    $tok_list = $_SESSION["user_data"]["user"]["tok_list"];
}

function create_active_chapters(){
    # initially set all chapters active with all_basic and ADMINISTATION
    global $username, $activ_chapters;
    $activ_chapters["all_basic"] = 1;
    $activ_chapters["ADMINISTRATION"] = 1;
    $_SESSION["user_data"][$username]["activ_chapters"] = $activ_chapters;
}

function create_tok_list(){
    # $tok_list contain basic_tok for activ chapters in the sequnce of $new_sequencelist
    global $device,$activ_chapters, $tok_list;
    foreach ($_SESSION["chapter_token"][$device] as  $chapter => $data) {
        if (array_key_exists($chapter, $activ_chapters)){
            foreach ($_SESSION["chapter_token"][$device][$chapter] as $key => $val){
                if (!array_key_exists($key, $tok_list)) {
                    $tok_list[$key] = 1;
                }
            }
        }
    }
}
?>

>
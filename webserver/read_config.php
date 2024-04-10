<?php
# read_config.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
# called at start only
function read_config(){
    # initializing at start
    global $username, $language, $is_lang, $new_sequncelist, $device, $activ_chapters, $activ_tok_list,$send_ok;
    global $tok_to_send, $send_string_by_tok, $received_data ;
    $_SESSION = [];
    # contain individual data per user
    $_SESSION["user"] = [];
    $_SESSION["languages"] = [];
    #
    # command length
    $_SESSION["command_len"] = [];
    $_SESSION["started"] = 0;
    # missing, not used now
    $_SESSION["interface"] = '';
    # answer command sent; read data
    $_SESSION["read"] = 0;
    # last command status ok?
    $_SESSION["last_command_status"] = 0;
    # list of available device; used for display only
    $_SESSION["device_list_with_spaces"] = [];
    # spaces replaced by "_x_"
    $_SESSION["device_list"] = [];
    # chapter_token: token: array data: 1
    # without "as" commands
    $_SESSION["chapter_token_pure"] = [];
    # must be defined here, used before read_new_device
    $_SESSION["announce_all"] = [];
    $_SESSION["actual_data"] = [];
    # reveived data
    $received_data  = "";
    $_SESSION["edit_operate"] = [];
    $_SESSION["edit_operate"]["operate"] = "operate";
    $_SESSION["edit_operate"]["edit_sequence"] = "edit_sequence";
    $_SESSION["update"] = 0;
    $send_ok = 0;
    $tok_to_send = [];
    $send_string_by_tok = [];
    $_SESSION["_edit_operate_"] = "operate";
    $_SESSION["new_sequencelist"] = [];
    #
    $_SESSION["conf"] = [];
    $config = "_config";
    if (file_exists($config)) {
        $file = fopen($config, "r");
        $i = 0;
        while (!(feof($file))) {
            $line = fgets($file);
            $line = str_replace("\r", "", $line);
            $line = str_replace("\n", "", $line);
            $line = explode(";", $line);
            switch ($i) {
                case  0:
                    $_SESSION["conf"]["announcefile"] = $line[1];
                    break;
                case  1:
                    $_SESSION["conf"]["serialwrite"] = $line[1];
                    break;
                case  2:
                    $_SESSION["conf"]["serialread"] = $line[1];
                    break;
                case  3:
                    $_SESSION["conf"]["bgb"] = $line[1];
                    break;
                case  4:
                    $_SESSION["conf"]["bgs"] = $line[1];
                    break;
                case  5:
                    $_SESSION["conf"]["bga"] = $line[1];
                    break;
                case  6:
                    $_SESSION["conf"]["s"] = $line[1];
                    break;
                case  7:
                    $_SESSION["conf"]["r"] = $line[1];
                    break;
                case  8:
                    $_SESSION["conf"]["at"] = $line[1];
                    break;
                case  9:
                    $_SESSION["conf"]["ou"] = $line[1];
                    break;
                case  10:
                    $_SESSION["conf"]["p"] = $line[1];
                    break;
                case  11:
                    $_SESSION["conf"]["m"] = $line[1];
                    break;
                case  12:
                    $_SESSION["conf"]["n"] = $line[1];
                    break;
                case  13:
                    $_SESSION["conf"]["a"] = $line[1];
                    break;
                case  14:
                    $_SESSION["conf"]["b"] = $line[1];
                    break;
                case  15:
                    $_SESSION["conf"]["f"] = $line[1];
                    break;
                case  16:
                    $_SESSION["conf"]["selector_limit"] = $line[1];
                    break;
                case  17:
                    $_SESSION["conf"]["testmode"] = $line[1];
                    break;
                case  18:
                    $_SESSION["conf"]["device_dir"] = $line[1];
                    break;
                case  19:
                    $_SESSION["conf"]["user_dir"] = $line[1];
                    break;
                case 20:
                    $_SESSION["conf"]["alpha"] = $line[1];
                    break;
                case 21:
                    $_SESSION["conf"]["coding"] = $line[1];
                    break;
                case 22:
                    $_SESSION["conf"]["language"] = $line[1];
                    break;
                case 23:
                    $_SESSION["conf"]["user_data_dir"] = $line[1];
                    break;
                case 24:
                    $_SESSION["conf"]["usb_interface_dir"] = $line[1];
                    break;
            }
            $i++;
        }
        fclose($file);
    }

    $_SESSION["coding"] = [];
    $config = $_SESSION["conf"]["coding"];
    if (file_exists($config)) {
        $file = fopen($config, "r");
        while (!(feof($file))) {
            $line = fgets($file);
            $line = str_replace("\r", "", $line);
            $line = str_replace("\n", "", $line);
            $_SESSION["coding"][$line] = $line;
        }
        fclose($file);
    }
    # language
    $_SESSION["lang"] = [];
    # for selection of languages only
    # used for selector
    $config = $_SESSION["conf"]["language"];
    if (file_exists($config)) {
        $file = fopen($config, "r");
        $i = 0;
        while (!(feof($file))) {
            # 1st line: item
            $line = fgets($file);
            $line = str_replace("\r", "", $line);
            $line = str_replace("\n", "", $line);
            $li = explode(";",$line);
            if ($i == 0){
                $j = 1;
                while ($j < count($li)) {
                    $_SESSION["lang"][$li[$j]] = [];
                    $pointer[$j] = $li[$j];
                    $_SESSION["languages"][] = $li[$j];
                    $j++;
                }
            }
            else{
                $j = 1;
                while ($j < count($li)) {
                    $l = $pointer[$j];
                    $_SESSION["lang"][$l][$li[0]]= $li[$j];
                    $j++;
                }
            }
            $i  += 1;
        }
    }
    # defaultname is "user"
    $username = "user";
    $_SESSION["user_data"] = [];
    $is_lang = "english";
    $language = $_SESSION["lang"][$is_lang];
    read_device_list($_SESSION["conf"]["device_dir"]);
}

function read_device_list($device_dir){
    $handle = opendir($device_dir);
    $i = 0;
    while (($file = readdir($handle)) !== false){
        if ($file != "." and $file != ".." ) {
            $replaced = str_replace(" ","_x_", $file);
            $_SESSION["device_list"][$replaced] = $replaced;
            $_SESSION["device_list_with_spaces"][$replaced] = $file;
            If ($i == 0){$_SESSION["device"] = $replaced;}
        }
        $i++;
    }
    closedir($handle);
}
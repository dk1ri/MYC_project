<?php
# read_config.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
# called at start only
function read_config(){
    # initializing at start
    global $username, $language, $is_lang, $new_sequncelist, $device, $actual_data,$activ_chapters, $tok_list;
    $_SESSION = [];
    # contain individual data per user
    $_SESSION["user"] = [];
    $_SESSION["languages"] = [];
    #
    # command length
    $_SESSION["command_len"] = [];
    $_SESSION["started"] = 0;
    # not used
  # $_SESSION["config"] = '';
    # missing
    $_SESSION["interface"] = '';
    # answer command sent; read data
    $_SESSION["read"] = 0;
    # last command status ok?
    $_SESSION["last_command_status"] = 0;
    # not used
 #  $_SESSION["init_read"] = 0;
    # actual user name
 #   $_SESSION["name"] = '';
    # list of available device; used for display only
    $_SESSION["device_list_with_spaces"] = [];
    # spaces replaced by "_x_"
    $_SESSION["device_list"] = [];
    # read $_SESSION["device_list"] (dirnames of devices directory)
    # defaullt (1st) device; device_list: array
    read_device_list();
    # chapter_token: token: array data: 1
    $_SESSION["chapter_token"] = [];
    # must be defined here, used before read_new_device
    $_SESSION["announce_all"] = [];
    # actual_data: used for device and chapter (and commands / per device)
    $_SESSION["actual_data"] = [];
    $_SESSION["actual_data"]["_device_"] = 0;
    $_SESSION["actual_data"]["_chapter_"] = 0;
    # reveived data
    $_SESSION["received_data"] = "";
    $_SESSION["edit_operate"] = [];
    $_SESSION["edit_operate"]["operate"] = "operate";
    $_SESSION["edit_operate"]["edit_sequence"] = "edit_sequence";
    $_SESSION["update"] = 0;
    $_SESSION["send_ok"] = 0;
    $_SESSION["tok_to_send"] = [];
    $_SESSION["send_string_by_tok"] = [];
    $_SESSION["_edit_operate_"] = "operate";
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
                case  20:
                    $_SESSION["conf"]["usb_interface_dir"] = $line[1];
                    break;
                case 21:
                    $_SESSION["conf"]["alpha"] = $line[1];
                case 22:
                    $_SESSION["conf"]["coding"] = $line[1];
                case 23:
                    $_SESSION["conf"]["language"] = $line[1];
                case 24:
                    $_SESSION["conf"]["user_data_dir"] = $line[1];
            }
            $i++;
        }
        fclose($file);
    }

    $_SESSION["coding"] = [];
    $config = "_coding";
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
    $config = "_lang";
    $islang = "";
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
    $username = "user";
    # defaultname is "user"
    $_SESSION["user_data"]["user"] = [];
    $is_lang = "english";
    $_SESSION["user_data"]["user"]["is_lang"] = $is_lang;
    $_SESSION["user_data"]["user"]["language"] = $_SESSION["lang"][$is_lang];
    $_SESSION["user_data"]["user"]["device"] = "";
    $_SESSION["user_data"]["user"]["new_sequncelist"] = [];
    $_SESSION["user_data"]["user"]["actual_data"] = [];
    $_SESSION["user_data"]["user"]["activ_chapters"] = [];
    $_SESSION["user_data"]["user"]["tok_list"] = [];
    $_SESSION["user_data"]["user"]["activ_chapters"][] = "all_basic";
    $language= $_SESSION["user_data"]["user"]["language"];
    $new_sequncelist = $_SESSION["user_data"]["user"]["new_sequncelist"];
    $actual_data = $_SESSION["user_data"]["user"]["actual_data"];
    $device = $_SESSION["user_data"]["user"]["device"];
    $activ_chapters = $_SESSION["user_data"]["user"]["activ_chapters"];
    $tok_list = $_SESSION["user_data"]["user"]["tok_list"];

}

function read_device_list(){
    $handle = opendir("./devices");
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
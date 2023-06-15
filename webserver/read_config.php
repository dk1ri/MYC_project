<?php
# read_config.php
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
# DK1RI 20220614
function read_config(){
    $_SESSION = [];
    # user data
    $_SESSION["user"] = [];
    $_SESSION["user"]["username"] = "user";
    $_SESSION["user"]["language"] = [];
    # for individual langusge
    $_SESSION["lang_select"] = [] ;
    # command length
    $_SESSION["command_len"] = [];
    $_SESSION["started"] = 1;
    # not used
    $_SESSION["config"] = '';
    # missing
    $_SESSION["interface"] = '';
    # answer command sent; read data
    $_SESSION["read"] = 0;
    # last command status ok?
    $_SESSION["last_command_status"] = 0;
    # not used
    $_SESSION["init_read"] = 0;
    # actual user name
    $_SESSION["name"] = '';
    # list of available device
    $_SESSION["device_list"] = "";
    # read $_SESSION["device_list"] (dirnames of devices directory)
    read_device_list();
    # device_list: array
    $_SESSION["device"] = explode(",",$_SESSION["device_list"])[1];
    # chapter_token: token: array data: 1
    $_SESSION["chapter_token"] = [];
    # must be defined here, used before read_new_device
    $_SESSION["announce_all"] = [];
    # actual_data: used for device and chapter (and commands / per device)
    $_SESSION["actual_data"] = [];
    $_SESSION["actual_data"]["_device_"] = 0;
    $_SESSION["actual_data"]["_chapter_"] = 0;
    # actual device: string
    $_SESSION["device"] = explode(",",$_SESSION["device_list"])[1];
    # reveived data
    $_SESSION["received_data"] = "";
    #
    $_SESSION["conf"] = [];
    $config = "_config";
    if (file_exists($config)) {
        $file = fopen($config, "r");
        $i = 0;
        while (!(feof($file))) {
            $line = fgets($file);
            $line = fgets($file);
            $line = str_replace("\r", "", $line);
            $line = str_replace("\n", "", $line);
            switch ($i) {
                case  0:
                    $_SESSION["conf"]["announcefile"] = $line;
                    break;
                case  1:
                    $_SESSION["conf"]["serial_dir"] = $line;
                    break;
                case  2:
                    $_SESSION["conf"]["bgb"] = $line;
                    break;
                case  3:
                    $_SESSION["conf"]["bgs"] = $line;
                    break;
                case  4:
                    $_SESSION["conf"]["bga"] = $line;
                    break;
                case  5:
                    $_SESSION["conf"]["s"] = $line;
                    break;
                case  6:
                    $_SESSION["conf"]["r"] = $line;
                    break;
                case  7:
                    $_SESSION["conf"]["at"] = $line;
                    break;
                case  8:
                    $_SESSION["conf"]["ou"] = $line;
                    break;
                case  9:
                    $_SESSION["conf"]["p"] = $line;
                    break;
                case  10:
                    $_SESSION["conf"]["m"] = $line;
                    break;
                case  11:
                    $_SESSION["conf"]["n"] = $line;
                    break;
                case  12:
                    $_SESSION["conf"]["a"] = $line;
                    break;
                case  13:
                    $_SESSION["conf"]["b"] = $line;
                    break;
                case  14:
                    $_SESSION["conf"]["f"] = $line;
                    break;
                case  15:
                    $_SESSION["conf"]["selector_limit"] = $line;
                    break;
                case  16:
                    $_SESSION["conf"]["testmode"] = $line;
                    break;
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
    $_SESSION["serialwrite"] = $_SESSION["conf"]["serial_dir"] . "from_web";
    $_SESSION["serialread"] = $_SESSION["conf"]["serial_dir"] . "to_web";
    # language
    $_SESSION["lang"] = [];
    # for selection of languages only
    $_SESSION["is_lang"] = "";
    # used for selector
    $config = "_lang";
    $islang = "";
    if (file_exists($config)) {
        $file = fopen($config, "r");
        $i = 0;
        while (!(feof($file))) {
            # 1st line: item
            $itemname = fgets($file);
            $itemname = str_replace("\r", "", $itemname);
            $itemname = str_replace("\n", "", $itemname);
            $_SESSION["lang"][$itemname] = "";
            # 2nd line: translations
            $translated_to = fgets($file);
            $translated_to = str_replace("\r", "", $translated_to);
            $translated_to = str_replace("\n", "", $translated_to);
            $li = explode(";",$translated_to);
            $j = 0;
            $k = 0;
            while ($j < count($li)){
                if ($i == "0" and $j == 0){$islang = $li[0];}
                if ($i == "0"){
                   $l[$j]  =  $li[$j];
                   # for language select;
                   $_SESSION["lang_select"][$k] = $j;
                   $_SESSION["lang_select"][$k + 1] = $li[$j];
                   $_SESSION["lang"][$li[$j]] = [];
                }
                $index = $l[$j];
                $_SESSION["lang"][$index][$itemname] =  $li[$j];
                $j += 1;
                $k += 2;
            }
            $i  += 1;
        }
    }
    $name = $_SESSION["user"]["username"];
    $_SESSION["user"]["is_lang"][$name] = $islang;
    $_SESSION["user"]["language"][$name] = $_SESSION["lang"][$islang];
}

function read_device_list(){
    $j = 0;
    $_SESSION["device_list"] = "";
    $handle = opendir("./devices");
    while (($file = readdir($handle)) !== false){
        if ($file != "." and $file != ".." ) {
            if ($j != "0"){
                $_SESSION["device_list"] .= ",";
            }
            $_SESSION["device_list"] .= $j . ",";
            $_SESSION["device_list"] .= $file;
            $j += 1;
        }
    }
    closedir($handle);
}
?>

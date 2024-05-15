<?php
# read_config.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
# called at start only
function read_config(){
    # initializing at start
    $_SESSION = [];
    # must be defined here, used before read_new_device
    $_SESSION["activ_chapters"] = [];
    $_SESSION["actual_data"] = [];
    $_SESSION["announce_all"] = [];
    # contain individual data per user
    $_SESSION["colornames"] = [];
    # command length
    $_SESSION["command_len"] = [];
    # spaces replaced by "_x_"
    $_SESSION["device_list"] = [];
    # list of available device; used for display only
    $_SESSION["device_list_with_spaces"] = [];
    $_SESSION["edit_operate"] = [];
    $_SESSION["edit_operate"]["operate"] = "operate";
    $_SESSION["edit_operate"]["edit_sequence"] = "edit_sequence";
    $_SESSION["edit_operate"]["edit_color"] = "edit_color";
    $_SESSION["edit_operate"]["edit_language"] = "edit_language";
    $_SESSION["_edit_operate_"] = "operate";
    # missing, not used now
    $_SESSION["interface"] = '';
    $_SESSION["known_devices"] = "";
    $_SESSION["languages"] = [];
    # last command status ok?
    $_SESSION["last_command_status"] = 0;
    $_SESSION["new_sequencelist"] = [];
    # answer command sent; read data
    $_SESSION["read"] = 0;
    $_SESSION["started"] = 0;
    $_SESSION["update"] = 0;;
    $_SESSION["user_data"] = [];
    #
    # read config
    $_SESSION["conf"] = [];
    $c = read_from_file("_config", 1);
    $_SESSION["conf"]["bas_dir"] = $c[0][1];
    $_SESSION["conf"]["sys"] = $_SESSION["conf"]["bas_dir"].$c[1][1];
    $_SESSION["conf"]["usb_interface_dir"] = $_SESSION["conf"]["bas_dir"].$c[2][1];
    $_SESSION["conf"]["device_dir"] = $_SESSION["conf"]["bas_dir"].$c[3][1];
    $_SESSION["conf"]["user_dir"] = $_SESSION["conf"]["bas_dir"].$c[4][1];
    $_SESSION["conf"]["announcefile"] = $_SESSION["conf"]["sys"].$c[5][1];
    $_SESSION["conf"]["serialwrite"] = $_SESSION["conf"]["usb_interface_dir"].$c[6][1];
    $_SESSION["conf"]["serialread"] = $_SESSION["conf"]["usb_interface_dir"].$c[7][1];
    $_SESSION["conf"]["selector_limit"] = $c[8][1];
    $_SESSION["conf"]["testmode"] = $c[9][1];
    $_SESSION["conf"]["alpha"] = $_SESSION["conf"]["bas_dir"].$c[10][1];
    $_SESSION["conf"]["coding"] = $_SESSION["conf"]["bas_dir"].$c[11][1];
    $_SESSION["conf"]["translate"] = $_SESSION["conf"]["sys"].$c[12][1];
    $_SESSION["conf"]["actual_data"] = $_SESSION["conf"]["sys"].$c[13][1];
    $_SESSION["conf"]["known_devices"] = $_SESSION["conf"]["sys"].$c[14][1];
    $_SESSION["conf"]["default_color"] = $_SESSION["conf"]["bas_dir"].$c[15][1];
    $_SESSION["conf"]["default_translate"] = $_SESSION["conf"]["bas_dir"].$c[16][1];
    $_SESSION["additional_language"] = [];
    # language used in edit_language
    $_SESSION["edit_language"] = "";
    #
    # check, if essential dirs exist
    if (!dir($_SESSION["conf"]["sys"])){mkdir($_SESSION["conf"]["sys"]);}
    if (!dir($_SESSION["conf"]["usb_interface_dir"])){mkdir($_SESSION["conf"]["usb_interface_dir"]);}
    if (!dir($_SESSION["conf"]["device_dir"])){mkdir($_SESSION["conf"]["device_dir"]);}
    if (!dir($_SESSION["conf"]["user_dir"])){mkdir($_SESSION["conf"]["user_dir"]);}
    #
    $_SESSION["default_color"] = [];
    $c = read_from_file($_SESSION["conf"]["default_color"], 1);
    foreach ($c as $line){
        $_SESSION["default_color"][strtolower($line[0])] = $line[1];
    }
    $_SESSION["color"] = $_SESSION["default_color"];
    #
    $_SESSION["coding"] = [];
    $c = read_from_file($_SESSION["conf"]["coding"],1);
    $i = 0;
    foreach ($c as $line){
        $_SESSION["coding"][$c[$i][0]] = $c[$i][0];
        $i++;
    }
    #
    $_SESSION["translate"] = [];
    $filename = $_SESSION["conf"]["translate"];
    if (!file_exists($filename)) {
        copy($_SESSION["conf"]["default_translate"],$filename);
    }
    $c = read_from_file($_SESSION["conf"]["translate"], 1);
    $i = 0;
    foreach ($c as $line){
        if ($i == 0){
            $j = 1;
            while ($j < count($line)) {
                $_SESSION["translate"][$line[$j]] = [];
                $pointer[$j] = $line[$j];
                $_SESSION["languages"][$line[$j]] = $line[$j];
                $j++;
            }
        }
        else{
            $j = 1;
            while ($j < count($line)) {
                $_SESSION["translate"][$pointer[$j]][$line[0]]= $line[$j];
                $j++;
            }
        }
        $i  += 1;
    }
    # defaultname is "user"
    $_SESSION["username"] = "user";
    $_SESSION["is_lang"] = "english";
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
            if ($i == 0){
                $_SESSION["device"] = $replaced;
            }
            $i++;
        }
    }
    closedir($handle);
}
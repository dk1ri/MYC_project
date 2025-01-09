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
    $_SESSION["edit_operate"]["edit_toks_to_ignore"] = "edit_toks_to_ignore";
    $_SESSION["select_mode"] = "operate";
    # missing, not used now
    $_SESSION["interface"] = '';
    $_SESSION["languages"] = [];
    # last command status ok?
    $_SESSION["last_command_status"] = 0;
    # answer command sent; read data
    $_SESSION["read"] = 0;
    $_SESSION["update"] = 0;
    $_SESSION["user_data"] = [];
    $_SESSION["default_lang"] = "english";
    $_SESSION["languages"] = [];
  #  $_SESSION["additional_languages"] = ["-"];
    $_SESSION["actual_additional_language"] = "";
    $_SESSION["default_translate_by_language"] = [];
    $_SESSION["translate_by_language"] = [];
    $_SESSION["edit_toks_to_ignore"] = [];
    $_SESSION["edit_chapter_name"] = "all_basic";
    $_SESSION["with_command_router"] = 1;
    $_SESSION["last_mode"] = "";
    $_SESSION["named_tok_lists"] = [];
    $_SESSION["last_user"] = "user";
    # temporary use:
    $_SESSION["named_tok_list"] = [];
    $_SESSION["named_tok_list_with_spaces"] = [];
    #
    # read config
    $_SESSION["conf"] = [];
    $c = read_from_file("_config", 1);
    $_SESSION["conf"]["sys"] = $c[0][1] . "/";
    $_SESSION["conf"]["usb_interface_dir"] = $c[1][1] . "/";
    $_SESSION["conf"]["device_dir"] = $c[2][1] . "/";
    $_SESSION["conf"]["user_dir"] = $c[3][1] . "/";
    $_SESSION["conf"]["announcefile"] = $_SESSION["conf"]["sys"].$c[4][1];
    $_SESSION["conf"]["serialwrite"] = $_SESSION["conf"]["usb_interface_dir"].$c[5][1];
    $_SESSION["conf"]["serialread"] = $_SESSION["conf"]["usb_interface_dir"].$c[6][1];
    $_SESSION["conf"]["selector_limit"] = $c[7][1];
    $_SESSION["conf"]["testmode"] = $c[8][1];
    $_SESSION["conf"]["alpha"] = $c[9][1];
    $_SESSION["conf"]["coding"] = $c[10][1];
    $_SESSION["conf"]["translate"] = $c[11][1];
    $_SESSION["conf"]["actual_data"] = $c[12][1];
    $_SESSION["conf"]["default_color"] = $c[13][1];
    $_SESSION["conf"]["default_translate"] = $c[14][1];
    $_SESSION["conf"]["other_POSTS"] = $c[15][1];
    $_SESSION["conf"]["with_command_router"] = $c[16][1];
    $_SESSION["conf"]["last_user_file"] = $c[17][1];
    if (is_file($_SESSION["conf"]["sys"]."//".$_SESSION["conf"]["last_user_file"])) {
        $c = read_from_file($_SESSION["conf"]["sys"] . "//" . $_SESSION["conf"]["last_user_file"], 0);
        $_SESSION["last_user"] = $c[0];
    }
    # else{$_SESSION["last_user"] = "user";}
        # language used in edit_language
    $_SESSION["edit_language"] = "";
    #
    # check, if essential dirs exist
    if (!dir($_SESSION["conf"]["sys"])){mkdir($_SESSION["conf"]["sys"]);}
    if (!dir($_SESSION["conf"]["usb_interface_dir"])){mkdir($_SESSION["conf"]["usb_interface_dir"]);}
    if (!dir($_SESSION["conf"]["device_dir"])){mkdir($_SESSION["conf"]["device_dir"]);}
    if (!dir($_SESSION["conf"]["user_dir"])){mkdir($_SESSION["conf"]["user_dir"]);}
    #
    $c = read_from_file($_SESSION["conf"]["default_color"], 1);
    foreach ($c as $line){
        $_SESSION["color"][strtolower($line[0])] = $line[1];
    }
    #
    $_SESSION["other_POSTS"] = [];
    $c = read_from_file($_SESSION["conf"]["other_POSTS"], 1);
    foreach ($c as $line){
        $_SESSION["other_POSTS"][$line[0]] = $line[0];
    }
    #
    $_SESSION["coding"] = [];
    $c = read_from_file($_SESSION["conf"]["coding"],1);
    $i = 0;
    foreach ($c as $line){
        $_SESSION["coding"][$c[$i][0]] = $c[$i][0];
        $i++;
    }
    #
    $filename = $_SESSION["conf"]["translate"];
    if (!file_exists($filename)) {
        copy($_SESSION["conf"]["default_translate"],$filename);
    }
    # defaultname is "user"
    $_SESSION["username"] = $_SESSION["last_user"];
    $_SESSION["is_lang"] = $_SESSION["default_lang"];
    read_device_list($_SESSION["conf"]["device_dir"]);
}

function read_device_list($device_dir){
    # do not work with RASPI: rad files in first subdir !!??!!
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
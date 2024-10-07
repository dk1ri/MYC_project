<?php
# filehandling.phhp
# DK1RI 20240919
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function write_to_file($filename,$data, $array){
    $file = fopen($filename, "w");
    if (!$array){
        #write one line
        fwrite($file, $data . "\r\n");
    }
    fclose($file);
}

function  read_from_file($filename, $array){
    # result is an array with an array or string per line
    $result = [];
    if (file_exists($filename)) {
        if (filesize($filename) != 0) {
            $file = fopen($filename, "r");
            $i = 0;
            while (!feof($file)) {
                $line = fgets($file);
                $line = str_replace("\r", "", $line);
                $line = str_replace("\n", "", $line);
                if ($array) {
                    $result[$i] = explode(";", $line);
                }
                else{
                    $result[$i] = $line;
                }
                $i++;
            }
            fclose($file);
        }
    }
    return $result;
}

function create_data_file($name, $userdata, $dim, $dev){
    # the resultlines $fin_data have dim +2 ";" separarated elements
    if ($dev){
        if ($userdata) {
            if (array_key_exists($name, $_SESSION["user_data"][$_SESSION["username"]][$_SESSION["device"]])) {
                $file = fopen($_SESSION["conf"]["user_dir"] . $_SESSION["username"] . "/" . $_SESSION["device"] . "/" . $name, "w");
                $data = $_SESSION["user_data"][$_SESSION["username"]][$_SESSION["device"]][$name];
            } else {
                $file = fopen($_SESSION["conf"]["user_dir"] . $_SESSION["username"] . "/" . $_SESSION["device"]. "/" . $name, "w");
                $data = $_SESSION["user_data"][$_SESSION["username"]][$name];
            }
        } else {
            $file = fopen($_SESSION["conf"]["device_dir"] . $_SESSION["device"] . "/session_" . $name, "w");
            $data = $_SESSION[$name][$_SESSION["device"]];
        }
    }
    else{
        if ($userdata) {
            if (array_key_exists($name, $_SESSION["user_data"][$_SESSION["username"]])) {
                $file = fopen($_SESSION["conf"]["user_dir"] . $_SESSION["username"] . "/" . $name, "w");
                $data = $_SESSION["user_data"][$_SESSION["username"]][$name];
            } else {
                $file = fopen($_SESSION["conf"]["user_dir"] . $_SESSION["username"] . "/" . $name, "w");
                $data = $_SESSION["user_data"][$_SESSION["username"]][$name];
            }
        } else {
            $file = fopen($_SESSION["conf"]["device_dir"] . $_SESSION["device"] . "/session_" . $name, "w");
            $data = $_SESSION[$name];
        }
    }
    foreach ($data as $key1 => $dat1){
        if ($dim == 0){
            fwr($file,$key1 . ";" . $dat1);
        }
        elseif ($dim == 1) {
            foreach ($dat1 as $key2 => $dat2) {
                fwr($file,$key1 . ";" . $key2 . ";" . $dat2);
            }
        }
        elseif ($dim == 2){
            foreach ($dat1 as $key2 => $dat2) {
                foreach ($dat2 as $key3 => $dat3) {
                    fwr($file,$key1 . ";" . $key2 . ";" . $key3 . ";" . $dat3);
                }
            }
        }
        elseif ($dim == 3){
            foreach ($dat1 as $key2 => $dat2) {
                foreach ($dat2 as $key3 => $dat3) {
                    foreach ($dat3 as $key4 => $dat4) {
                        fwr($file,$key1 . ";" . $key2 . ";" . $key3 . ";" . $key4 . ";" . $dat4);
                    }
                }
            }
        }
    }
    fclose($file);
}

function fwr($file, $fin_dat){
    if ($fin_dat != "") {
        fwrite($file, $fin_dat . "\r\n");
    }
}

function write_device_to_file(){
    create_data_file("activ_chapters","0",0, 1);
    create_data_file("actual_data","0",0, 1);
    create_data_file("ALL","0",0, 1);
    create_data_file("announce_all","0",0, 1);
    create_data_file("a_to_o", "0",0, 1);
    create_data_file("alpha", "0",0, 1);
    create_data_file("chapter_names", "0",0, 1);
    create_data_file("chapter_names_with_space", "0",0, 1);
    create_data_file("chapter_token_pure", "0",2, 1);
    create_data_file("cor_token", "0",1,1);
    create_data_file("default_value", "0",0,1 );
    create_data_file("des", "0",0, 1);
    create_data_file("des_name", "0",0, 1);
    create_data_file("max_for_ADD",  "0",0,1 );
    create_data_file("max_for_send", "0",0, 1);
    create_data_file("meter",  "0",0,1);
    create_data_file("meter_announce_line", "0",0, 1);
    create_data_file("actual_sequencelist_by_sequence", "0",0, 1);
    create_data_file("final_actual_sequencelist_by_sequence", "0",0, 1);
    create_data_file("actual_sequencelist", "0",0, 1);
    create_data_file("o_to_a", "0",0, 1);
    create_data_file("oo_tok", "0",0, 1);
    create_data_file("original_announce", "0",1, 1);
    create_data_file("property_len", "0",1, 1);
    create_data_file("property_len_byte", "0",1, 1);
    create_data_file( "rules", "0",0, 1);
    create_data_file("to_correct", "0",0, 1);
    create_data_file("type_for_memories", "0",0, 1);
    create_data_file("unit","0",0, 1);
    create_data_file("toks_to_ignore","0",0, 1);
    create_data_file("dev","0",0, 1);
    create_data_file("edit_toks_to_ignore","0",0, 1);
    create_data_file("translate_by_language","0",1, 1);
    create_data_file("command_len","0",0, 1);
}

function read_data_file($name, $mode,$dim){
    $device = $_SESSION["device"];
    $username =  $_SESSION["username"];
    $data_array = [];
    switch ($mode){
        case 0:
            # device userdata
            $_SESSION["user_data"][$username][$device][$name] = [];
            $filename = $_SESSION["conf"]["user_dir"] . $username . "/" . $device . "/" . $name;
            break;
        case 1:
            # device, no userdata
            $_SESSION[$name][$device] = [];
            $filename = $_SESSION["conf"]["device_dir"] . $device . "/session_" . $name;
            break;
        case 2:
            # userdata
            $_SESSION["user_data"][$username][$name] = [];
            $filename = $_SESSION["conf"]["user_dir"] . $username . "/" . $name;
            break;
        case 3:
            # no dev, no userdata
            $filename = $_SESSION["conf"]["device_dir"] . "/session_" . $name;
            break;
        }
    $c = read_from_file($filename,1);
    if ($c != []){
        foreach ($c as $data) {
            if ($data == ""){continue;}
            if ($dim == 0){
                if (count($data) < 2){continue;}
                $k1 = $data[0];
                array_splice($data, 0, 1);
                $dat = implode(";", $data);
                $data_array[$k1] = $dat;
            }
            elseif ($dim == 1){
                if (count($data) < 3){continue;}
                $k1 = $data[0];
                $k2 = $data[1];
                array_splice($data, 0, 2);
                $data_array[$k1][$k2] = implode(";", $data);
            }
            elseif ($dim == 2){
                if (count($data) < 3){continue;}
                $k1 = $data[0];
                $k2 = $data[1];
                $k3 = $data[2];
                array_splice($data, 0, 3);
                $dat = implode(";", $data);
                $data_array[$k1][$k2][$k3] = $dat;
            }
            elseif ($dim == 3) {
                if (count($data) < 4) {continue;}
                $k1 = $data[0];
                $k2 = $data[1];
                $k3 = $data[2];
                $k4 = $data[3];
                array_splice($data, 0, 4);
                $dat = implode(";", $data);
                $data_array[$k1][$k2][$k3][$k4] = $dat;
            }
        }

    }
    switch ($mode) {
        case 0:
            $_SESSION["user_data"][$username][$device][$name] = $data_array;
            break;
        case 1:
            $_SESSION[$name][$device] = $data_array;
            break;
        case 2:
            $_SESSION["user_data"][$username][$name] = $data_array;
            break;
        case 3:
            $_SESSION[$name] = $data_array;
            break;
    }
}

function read_device_from_file(){
    read_d_from_file(1);
}
function read_d_from_file($mode){
    read_data_file( "activ_chapters", $mode,0);
    read_data_file( "actual_data", $mode,0);
    read_data_file( "ALL", $mode,0);
    read_data_file("announce_all", $mode,0);
    read_data_file("a_to_o", $mode,0);
    read_data_file("alpha", $mode,0);
    read_data_file("chapter_names", $mode,0);
    read_data_file("chapter_names_with_space", $mode,0);
    read_data_file("chapter_token_pure", $mode,2);
    read_data_file( "cor_token", $mode,1);
    read_data_file("default_value", $mode,0);
    read_data_file("des", $mode,0);
    read_data_file("des_name", $mode,0);
    read_data_file("max_for_ADD", $mode,0);
    read_data_file("max_for_send", $mode,0);
    read_data_file("meter", $mode,0);
    read_data_file("meter_announce_line", $mode,0);
    read_data_file("actual_sequencelist", $mode,0);
    read_data_file("actual_sequencelist_by_sequence", $mode,0);
    read_data_file("final_actual_sequencelist_by_sequence", $mode,0);
    read_data_file("o_to_a", $mode,0);
    read_data_file("oo_tok", $mode,0);
    read_data_file("original_announce", $mode,1);
    read_data_file("property_len", $mode,1);
    read_data_file("property_len_byte", $mode,1);
    read_data_file( "rules", $mode,0);
    read_data_file("to_correct", $mode,0);
    read_data_file("type_for_memories", $mode,0);
    read_data_file("unit", $mode,0);
    read_data_file("toks_to_ignore", $mode,0);
    read_data_file("dev", $mode,0);
    read_data_file("edit_toks_to_ignore", $mode,0);
    read_data_file("translate_by_language", $mode,1);
    read_data_file("command_len", $mode,0);
}
?>
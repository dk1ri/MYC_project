<?php
# filehandling.phhp
# DK1RI 20240512
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function write_file_one_item($filename, $data){;
    $file = fopen($filename, "w");
    fwrite($file, $data . "\r\n");
    fclose($file);
}

function write_to_file($filename, $data, $array){
    $file = fopen($filename, "w");
    foreach ($data as $dat) {
        if (!$array) {
            fwrite($file, $dat . "\r\n");
        }
        else{
            fwrite($file, implode(";",$dat) . "\r\n");
        }
    }
    fclose($file);
}

function read_one_item_from_file($filename){
    $file = fopen($filename, "r");
    $line = fgets($file);
    $line = str_replace("\r", "", $line);
    $line = str_replace("\n", "", $line);
    fclose($file);
    return $line;
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
                $linea = explode(";", $line);
                if ($array) {
                    $result[$i] = $linea;
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

function check_user_dir_exist(){
    if (!is_dir($_SESSION["conf"]["user_dir"])){mkdir($_SESSION["conf"]["user_dir"]);}
    if (!is_dir($_SESSION["conf"]["user_dir"]."/".$_SESSION["username"])){
        mkdir($_SESSION["conf"]["user_dir"]."/".$_SESSION["username"]);
    }
    if (!is_dir($_SESSION["conf"]["user_dir"]."/".$_SESSION["username"]."/".$_SESSION["device"])){
        mkdir($_SESSION["conf"]["user_dir"]."/".$_SESSION["username"]."/". $_SESSION["device"]);
    }
}

function create_data_file($name, $userdata){
    if ($userdata){
        check_user_dir_exist();
        if (array_key_exists($name, $_SESSION["user_data"][$_SESSION["username"]][$_SESSION["device"]])) {
            $file = fopen($_SESSION["conf"]["user_dir"].$_SESSION["username"] ."/". $_SESSION["device"] . "/".$name, "w");
            $data = $_SESSION["user_data"][$_SESSION["username"]][$_SESSION["device"]][$name];
        }
        else{
            $file = fopen($_SESSION["conf"]["user_dir"].$_SESSION["username"] ."/". $name, "w");
            $data = $_SESSION["user_data"][$_SESSION["username"]][$name];
        }
    }
    else {
        $file = fopen($_SESSION["conf"]["device_dir"] . $_SESSION["device"] . "/session_" . $name, "w");
        $data = $_SESSION[$name][$_SESSION["device"]];
    }
    $n = count ($data);
    $i = 1;
    foreach ($data as $key=> $value) {
        if ($i < $n) {
            fwrite($file, $key . ";" . $value . "\r\n");
        }
        else{
            fwrite($file, $key . ";" . $value);
        }
        $i++;
    }
    fclose($file);
}

function create_data_file_array($name, $userdata){
    if ($userdata){
        check_user_dir_exist();
        $file = fopen($_SESSION["conf"]["user_dir"].$_SESSION["username"] . "/" . $_SESSION["device"] . "/". $name, "w");
        $data = $_SESSION["user_data"][$_SESSION["username"]][$_SESSION["device"]][$name];
    }
    else {
        $file = fopen($_SESSION["conf"]["device_dir"] . $_SESSION["device"] . "/session_" . $name, "w");
        $data = $_SESSION[$name][$_SESSION["device"]];
    }
    $n = count ($data);
    $i = 1;
    foreach ($data as $key=> $value){
        $line = $key. ";";
        $nn = count($value);
        $j = 0;
        foreach ($value as $key_ => $val) {
            if ($j < $nn) {
                $line .= $key_ . ";" . $val . ";";
            }
            else{
                $line .= $key_ . ";" . $val;
            }
            $j++;
        }
        if ($i < $n) {
            fwrite($file, $line . "\r\n");
        }
        else{
            fwrite($file, $line);
        }
        $i++;
    }
    fclose($file);
}

function write_device_to_file(){
    create_data_file("activ_chapters",0);
    create_data_file("actual_data",0);
    create_data_file("ALL",0);
    create_data_file("announce_all",0);
    create_data_file("a_to_o", 0);
    create_data_file("alpha", 0);
    create_data_file("chapter_names", 0);
    create_data_file("chapter_names_with_space", 0);
    create_data_file_array("chapter_token_pure", 0);
    create_data_file_array("cor_token", 0);
    create_data_file("default_value", 0);
    create_data_file("des", 0);
    create_data_file("des_name", 0);
    create_data_file("des_name", 0);
    create_data_file("individual_tok_list", 0);
    create_data_file("max_for_ADD",  0);
    create_data_file("max_for_send", 0);
    create_data_file("meter",  0);
    create_data_file("meter_announce_line", 0);
    create_data_file_array("new_sequencelist", 0);
    create_data_file("o_to_a", 0);
    create_data_file("oo_tok", 0);
    create_data_file_array("original_announce", 0);
    create_data_file_array("property_len", 0);
    create_data_file_array("property_len_byte", 0);
    create_data_file( "rules", 0);
    create_data_file("to_correct", 0);
    create_data_file("type_for_memories", 0);
    create_data_file("unit",0);
}

function read_data_file($name, $userdata){
    $device = $_SESSION["device"];
    if ($userdata){
        $_SESSION["user_data"][$_SESSION["username"]][$name] = [];
        $filename = $_SESSION["conf"]["user_dir"] . $_SESSION["username"] . "/" . $device. "/" . $name;
    }
    else {
        $_SESSION[$name][$_SESSION["device"]] = [];
        $filename = $_SESSION["conf"]["device_dir"] . $device . "/session_" . $name;
    }
    $c = read_from_file($filename,1);
    if ($c != []){
        foreach ($c as $key => $data) {
            if (array_key_exists("1", $data)) {
                if (is_numeric($data[0])) {
                    $data[0] = (int)$data[0];
                }
                $_SESSION[$name][$_SESSION["device"]][$data[0]] = $data[1];
            } else {
                if (is_numeric($data[0])) {
                    $data[1] = (int)$data[1];
                }
                $_SESSION[$name][$_SESSION["device"]][] = $data[0];
            }
        }
    }
  #  if ($userdata){$_SESSION["user_data"][$_SESSION["username"]][$device][$name] = $_SESSION[$name][$device];}
}

function read_data_file_array($name, $userdata){
    $device = $_SESSION["device"];
    if ($userdata){
        $_SESSION["user_data"][$_SESSION["username"]][$name] = [];
        $filename = $_SESSION["conf"]["user_dir"] . $_SESSION["username"] . $_SESSION["device"]. $name;
    }
    else {
        $filename = $_SESSION["conf"]["device_dir"] . $device . "/session_" . $name;
    }
    $c = read_from_file($filename,1);
    foreach ($c as $key => $data){
        $_SESSION[$name][$device][$data[0]] = [];
        $i = 1;
        while($i < count($data) - 1){
            $_SESSION[$name][$device][$data[0]][$data[$i]] = $data[$i + 1];
            $i +=2;
        }
    }
    if ($userdata){$_SESSION["user_data"][$_SESSION["username"]][$device][$name] = $_SESSION[$name][$device];}
}

function read_device_from_file(){
    read_data_file( "activ_chapters",0);
    read_data_file( "actual_data", 0);
    read_data_file( "ALL", 0);
    read_data_file("announce_all", 0);
    read_data_file("a_to_o", 0);
    read_data_file("alpha", 0);
    read_data_file("chapter_names", 0);
    read_data_file("chapter_names_with_space", 0);
    read_data_file_array("chapter_token_pure", 0);
    read_data_file_array( "cor_token", 0);
    read_data_file("default_value", 0);
    read_data_file("des", 0);
    read_data_file("des_name", 0);
    read_data_file("includes", 0);
    read_data_file("individual_tok_list", 0);
    read_data_file("max_for_ADD", 0);
    read_data_file("max_for_send", 0);
    read_data_file("meter", 0);
    read_data_file("meter_announce_line", 0);
    read_data_file_array("new_sequencelist", 0);
    read_data_file("o_to_a", 0);
    read_data_file("oo_tok", 0);
    read_data_file_array("original_announce", 0);
    read_data_file_array("property_len", 0);
    read_data_file_array("property_len_byte", 0);
    read_data_file( "rules", 0);
    read_data_file("to_correct", 0);
    read_data_file("type_for_memories", 0);
    read_data_file("unit", 0);
}
?>
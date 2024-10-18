<?php
# edit_language.php
# DK1RI 20240919
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function edit_language(){
    $device = $_SESSION["device"];
    if ($_SESSION["edit_language"] == ""){$_SESSION["edit_language"] = $_SESSION["is_lang"];}
    echo tr("w3")."<br>";
    echo tr("w4")."<br>";
    echo "&nbsp;<br>";
    echo "<div>";
    echo "<input type='text' id='new_language' name='new_language' size=15  placeholder = ".$_SESSION["edit_language"]. "><br>";
    foreach ($_SESSION["translate_by_language"][$device][$_SESSION["edit_language"]] as $key => $name) {
        if ($name != "language_name") {
           # $mod_name = str_replace(" ", "&nbsp;", tr($name));
            echo "<input type=text name=edit_language_".$key . " size=15  placeholder = " . $name, ">";
            echo " " . $key;
            echo "<br>";
        }
    }
    $additional_language = [];
    foreach ($_SESSION["languages"] as $lang){
        if (!array_key_exists($lang, $_SESSION["default_translate_by_language"])){$additional_language[$lang] = $lang;}
    }
    if (count($additional_language)) {
        echo "</div><div>";
        echo tr("w6");
        array_selector("delete_language", $additional_language, $additional_language);
    }
}

function edit_language_post(){
    $device = $_SESSION["device"];
    if(array_key_exists("new_language", $_POST) and $_POST["new_language"] != ""){
        # new_language is not stored with the device
        $_SESSION["languages"][] = $_POST["new_language"];
        $newkey = str_replace(" ", "&nbsp;", $_POST["new_language"]);
        $_SESSION["edit_language"] = $_POST["new_language"];
    }
    foreach ($_POST as $tok => $value) {
        if (substr($tok, 0, 14) == "edit_language_") {
            if ($value != "") {
                $key_for_translate = substr($tok, 14);
                if ($value != $_SESSION["translate_by_language"][$device][$_SESSION["edit_language"]][$key_for_translate]) {
                    $_SESSION["translate_by_language"][$device][$_SESSION["edit_language"]][$key_for_translate] = $value;
                }
            }
        }
    }
    if (array_key_exists("delete_language", $_POST) and $_POST["delete_language"] != "-"){
        $i = 0;
        foreach ($_SESSION["languages"] as $l){
            if ($l == $_POST["delete_language"]){
                array_splice($_SESSION["languages"], $i,1);
                continue;
            }
            $i++;
        }
    }
}
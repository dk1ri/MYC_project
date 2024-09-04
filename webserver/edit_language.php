<?php
# edit_language.php
# DK1RI 2024815
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function edit_language(){
    if ($_SESSION["edit_language"] == ""){$_SESSION["edit_language"] = $_SESSION["is_lang"];}
    echo tr("w3")."<br>";
    echo tr("w4")."<br>";
    echo "&nbsp;<br>";
    echo "<div>";
    echo "<input type='text' id='new_language' name='new_language' size=15  placeholder = ".$_SESSION["edit_language"]. "><br>";
    foreach ($_SESSION["translate_by_language"][$_SESSION["edit_language"]] as $key => $name) {
        if ($name != "language_name") {
           # $mod_name = str_replace(" ", "&nbsp;", tr($name));
            echo "<input type=text name=edit_language_".$key . " size=15  placeholder = " . $name, ">";
            echo " " . $key;
            echo "<br>";
        }
    }
    if (count($_SESSION["additional_languages"]) != 1) {
        echo "</div><div>";
        echo tr("w6");
        array_selector("delete_language", $_SESSION["additional_languages"], $_SESSION["actual_additional_language"]);
    }
}

function edit_language_post(){
    if(array_key_exists("new_language", $_POST) and $_POST["new_language"] != ""){
        # new_language is not stored with the device
        $_SESSION["languages"][] = $_POST["new_language"];
        $newkey = str_replace(" ", "&nbsp;", $_POST["new_language"]);
        $_SESSION["translate_by_language"][$newkey] = $_SESSION["translate_by_language"][$_SESSION["edit_language"]];
        $_SESSION["edit_language"] = $_POST["new_language"];
        $_SESSION["additional_languages"][] = $_POST["new_language"];
    }
    foreach ($_POST as $tok => $value) {
        if (substr($tok, 0, 14) == "edit_language_") {
            if ($value != "") {
                $key_for_translate = substr($tok, 14);
                if ($value != $_SESSION["translate_by_language"][$_SESSION["edit_language"]][$key_for_translate]) {
                    $_SESSION["translate_by_language"][$_SESSION["edit_language"]][$key_for_translate] = $value;
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
        $i = 0;
        foreach ($_SESSION["additional_languages"] as $l){
            if ($l == $_POST["delete_language"]){
                array_splice($_SESSION["additional_languages"], $i,1);
                continue;
            }
            $i++;
        }
    }
}
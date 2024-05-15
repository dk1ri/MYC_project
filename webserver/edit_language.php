<?php
# edit_color.php
# DK1RI 20240514
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function edit_language(){
    # collect all translate items
    foreach ($_SESSION["languages"] as $lang){
        if (array_key_exists($lang, $_SESSION["translate"])){
            foreach ($_SESSION["translate"][$lang] as $key => $item) {
                $all_keys[] = $key;
            }
        }
        if (array_key_exists($lang, $_SESSION["additional_language"])){
            foreach ($_SESSION["additional_language"][$lang] as $key => $item) {
                if(!array_key_exists($key, $all_keys)) {
                    $all_keys[] = $key;
                }
            }
        }
    }
    if ($_SESSION["edit_language"] == ""){$_SESSION["edit_language"] = $_SESSION["is_lang"];}
    echo tr("w3")."<br>";
    echo tr("w4")."<br>";
    echo "&nbsp;<br>";
    echo "<div>";
    echo "<input type='checkbox' id=store_translate name = store_translate value=1>";
    echo tr("store_data") ." ". tr("new_language").": ";
    echo "<input type='text' id='new_language1' name='new_language1' size=15  placeholder = ".$_SESSION["edit_language"]. "><br>";
    foreach ($all_keys as $name) {
        if ($name != "language_name") {
            if (array_key_exists($name, $_SESSION["additional_language"])){
                $data = $_SESSION["additional_language"][$name];
            }
            else{
                $data = $name;
            }
            echo "<input type=text name=" . $name . " size=15  placeholder = " . $data, ">";
            echo " " . tr($name);
            echo "<br>";
        }
    }
}

function edit_language_post(){
    $new_language = "";
    if(array_key_exists("new_language1", $_POST)){
        $new_language = $_POST["new_language1"];
        print $new_language;
        if (array_key_exists($new_language, $_SESSION["languages"]) or $new_language == "" or $new_language == "language_name"){
            $new_language = "";
            $_SESSION["edit_language"] = $_SESSION["is_lang"];
        }
        else{
            $_SESSION["languages"][] = $new_language;
            $_SESSION["edit_language"] = $new_language;
        }
    }
    var_dump($_SESSION["languages"]);
    print $new_language."nl";
    # ignore all if no valid other language
    if ($new_language == ""){return;}
    foreach ($_POST as $original => $new_lang) {
        if ($original == "language_name"){continue;}
        if($new_lang != ""){
            $_SESSION["additional_language"][$new_language][$original] = $new_lang;
        }
    }
    if (array_key_exists("store_translate", $_POST) and $_POST["store_translate"]){
        if ($_SESSION["username"] != "user"){
            $user_dir = $_SESSION["conf"]["user_data_dir"] . "\\" . $_SESSION["username"];
            if (!file_exists($user_dir)) {
                mkdir($user_dir);
            }
            $user_data = $user_dir."\\translate";
            $file = fopen($user_data, "w");
            foreach ($_SESSION["translate"] as $translate_name => $tr) {
                fwrite($file, $translate_name . ";" . $tr . "\r\n");
            }
            fclose($file);
        }
    }
}
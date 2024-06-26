<?php
# edit_color.php
# DK1RI 20240412
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function edit_color(){
    if ($_SESSION["colornames"] == []) {
        $config = "_colornames";
        if (file_exists($config)) {
            $file = fopen($config, "r");
            while (!(feof($file))) {
                $line = fgets($file);
                $line = str_replace("\r", "", $line);
                $line = str_replace("\n", "", $line);
                $_SESSION["colornames"][strtolower($line)] = $line;
            }
            fclose($file);
        }
    }
    echo tr("w5")."<br>";
    echo "&nbsp;<br>";
    $i = 0;
    foreach ($_SESSION["colornames"] as $colorname) {
        echo $colorname . " ";
        if ($i == 5) {
            echo "<br>";
            $i = 0;
        }
        $i++;
    }
    echo "<div>";
    echo "<input type='checkbox' id=store_color name=store_color value=1>";
    echo tr("store_data");
    foreach ($_SESSION["color"] as $name => $color) {
        echo "<div>";
        echo "<input type=text name=" . $name . " size=15  placeholder = " . $color, ">";
        echo "<font color =".$color."> " . $name . " " . $color . " <font>";
        echo "<br>";
    }
}

function edit_color_post(){
    foreach ($_POST as $function_name => $newcolor) {
        if ($newcolor != "") {
            $n1 = strtolower($newcolor);
            if (array_key_exists($n1, $_SESSION["colornames"])){
                $_SESSION["color"][$function_name] = $_SESSION["colornames"][$n1];
            }
            elseif (strlen($newcolor) == 7 and strpos($newcolor,"#") == 0) {
                $newc = substr($newcolor, 1);
                if (ctype_xdigit($newc)) {
                    $_SESSION["color"][$function_name] = $newcolor;
                }
            }
        }
    }
    $_SESSION["user_data"]["color"] = $_SESSION["color"];
    if (array_key_exists("store_color", $_POST) and $_POST["store_color"]){
        if ($_SESSION["username"] != "user"){
            check_user_dir_exist();
            $user_data = $_SESSION["conf"]["user_dir"] . "\\" . $_SESSION["username"]."\\color";
            $file = fopen($user_data, "w");
            foreach ($_SESSION["color"] as $colorname => $color) {
                fwrite($file, $colorname . ";" . $color . "\r\n");
            }
            fclose($file);
        }
    }
}
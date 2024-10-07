<?php
# edit_color.php
# DK1RI 20240919
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
    echo "<input type='checkbox' id=set_color_default name=set_color_default value=1>";echo tr("default")."<br>";
    foreach ($_SESSION["color"] as $name => $color) {
        echo "<div>";
        echo "<input type=text name=" . $name . " size=15  placeholder = " . $color, ">";
        echo "<font color =".$color."> " . $name . " " . $color . " <font>";
        echo "<br>";
    }
}

function edit_color_post(){
    if (array_key_exists("set_color_default", $_POST) and $_POST["set_color_default"] == 1){
        $c = read_from_file($_SESSION["conf"]["default_color"], 1);
        foreach ($c as $line){
            $_SESSION["color"][strtolower($line[0])] = $line[1];
        }
        # do nothing else
        return;
    }
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
}
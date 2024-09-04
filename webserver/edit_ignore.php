<?php
# edit_ignore.php
# DK1RI 20240813
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function edit_toks_to_ignore(){
    $device = $_SESSION["device"];
    echo "<div>";
    echo tr("token") . ";<br>";
    foreach ($_SESSION["original_announce"][$device] as $tok => $dat) {
        echo $tok. " ";
        $an = explode(",",$dat[0]);
        if (count($an) > 1) {
            if ($_SESSION["edit_toks_to_ignore"][$device][$tok] == 0){
                echo "<strong class = 'red'>".tr($an[1])."</strong>";
            }
            elseif ($_SESSION["edit_toks_to_ignore"][$device][$tok] == 1) {
                echo "<strong class = 'green'>".tr($an[1])."</strong>";
            }
        }
        echo "<input type='checkbox' id=tok_store_ignore". $tok." name=tok_store_ignore".$tok." value=1>";
        echo "<br>";
    }
}

function edit_toks_to_ignore_post(){
    $device = $_SESSION["device"];
    foreach ($_POST as $tok => $value) {
        if (substr($tok, 0, 16) == "tok_store_ignore") {
            $key = substr($tok, 16);
            if ($_SESSION["edit_toks_to_ignore"][$device][$key] == 0) {
                $_SESSION["edit_toks_to_ignore"][$device][$key] = 1;
            } else {
                $_SESSION["edit_toks_to_ignore"][$device][$key] = 0;
            }
        }
    }
    # modify toks_to_ignore also for as commands
    foreach ($_SESSION["toks_to_ignore"][$device] as $key => $ignore){
        if (array_key_exists($key, $_SESSION["edit_toks_to_ignore"])){
            $_SESSION["toks_to_ignore"][$device][$key] = $_SESSION["edit_toks_to_ignore"][$key];
        }
        else{
            if ($_SESSION["o_to_a"][$device] != []) {
                if (array_key_exists($key, $_SESSION["o_to_a][$device"])) {
                    $_SESSION["toks_to_ignore"][$device][$key] = $_SESSION["edit_toks_to_ignore"][$key];
                }
            }
        }
    }
    create_final_actual_sequencelist();
}
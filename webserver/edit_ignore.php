<?php
# edit_ignore.php
# DK1RI 20240919
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function edit_toks_to_ignore(){
    $device = $_SESSION["device"];
    echo "<div>";
    echo "<input type='checkbox' id=tok_ignore_default name=tok_ignore_default value=1>";echo tr("default")."<br>";
    foreach ($_SESSION["original_announce"][$device] as $tok => $dat) {
        if (!array_key_exists($tok,$_SESSION["a_to_o"][$device])) {
            echo $tok . " ";
            $an = explode(",", $dat[0]);
            if (count($an) > 1) {
                if ($_SESSION["edit_toks_to_ignore"][$device][$tok] == 0) {
                    echo "<strong class = 'red'>" . tr($an[1]) . "</strong>";
                } elseif ($_SESSION["edit_toks_to_ignore"][$device][$tok] == 1) {
                    $found = 0;
                    foreach ($_SESSION["chapter_token_pure"][$device] as $dev => $val){
                        foreach ($_SESSION["chapter_token_pure"][$device][$dev] as $key => $val1){
                            if (array_key_exists($key,$_SESSION["activ_chapters"][$device])) {
                                if (array_key_exists($tok, $_SESSION["chapter_token_pure"][$device][$dev][$key])) {
                                    $found = 1;
                                }
                            }
                        }
                    }
                    if ($found) {
                        echo "<strong class = 'green'>" . tr($an[1]) . "</strong>";
                    }
                    else{
                        echo "<strong class = 'orange'>" . tr($an[1]) . "</strong>";
                    }
                }
            }
            echo "<input type='checkbox' id=tok_store_ignore" . $tok . " name=tok_store_ignore" . $tok . " value=1>";
            echo "<br>";
        }
    }
}

function edit_toks_to_ignore_post(){
    $device = $_SESSION["device"];
    if (array_key_exists("tok_ignore_default", $_POST) and $_POST["tok_ignore_default"] == 1){
        foreach ($_SESSION["edit_toks_to_ignore"][$device] as $key => $val){
            $_SESSION["edit_toks_to_ignore"][$device][$key] = 1;
        }
        # do nothing else
        return;
    }
    foreach ($_POST as $tok => $value) {
        if (substr($tok, 0, 16) == "tok_store_ignore") {$key = substr($tok, 16);
            if ($_SESSION["edit_toks_to_ignore"][$device][$key] == 0) {
                $_SESSION["edit_toks_to_ignore"][$device][$key] = 1;
            } else {
                $_SESSION["edit_toks_to_ignore"][$device][$key] = 0;
            }
        }
    }
    # $_SESSION["toks_to_ignore"][$device] contain all toks
    # modify toks_to_ignore also for as commands
    foreach ($_SESSION["toks_to_ignore"][$device] as $key => $ignore){
        if (array_key_exists($key, $_SESSION["edit_toks_to_ignore"][$device])){
            # all except "as"
            $_SESSION["toks_to_ignore"][$device][$key] = $_SESSION["edit_toks_to_ignore"][$device][$key];
        }
        else{
            if ($_SESSION["o_to_a"][$device] != []) {
                if (array_key_exists($key, $_SESSION["o_to_a"][$device])) {
                    $_SESSION["toks_to_ignore"][$device][$device][$key] = $_SESSION["edit_toks_to_ignore"][$device][$key];
                }
            }
        }
    }
    create_final_actual_sequencelist();
}
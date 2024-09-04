<?php
# edit_sequence.php
# DK1RI 20240415
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function edit_sequence(){
    $device = $_SESSION["device"];
    $username = $_SESSION["username"];
    echo "<div>";
    echo tr("w1")."<br>";
    $i = 0;
    foreach ($_SESSION["actual_sequencelist"][$device] as $tok => $value) {
        echo "<input type=text name=" . $i . " size=5  placeholder = " . $i, ">";
        echo " " . $i . " " . $tok . " ";
        $an = explode(",", $_SESSION["original_announce"][$device][$tok][0]);
        if (count($an) > 1) {
            echo tr($an[1]);
        }
        else{
            echo $an[0];
        }
        echo "<br>";
        $i++;
    }
    echo "</div><div>";
    echo tr("save_as"). " ";
    echo "<input type=text name= sequncelist_name size=7>";
    echo "<input type='checkbox' id=store_sequencelist name=store_sequencelist value=1>";
    if (array_key_exists($device, $_SESSION["named_tok_lists"])) {
        if (array_key_exists($username, $_SESSION["named_tok_lists"][$device])) {
            if (count($_SESSION["named_tok_lists"][$device][$username]) > 0) {
                echo "<br><br>";
                # find first element
                $listnames = [];
                foreach ($_SESSION["named_tok_lists"][$device][$username] as $listname => $dat) {
                    $listnames[] = $listname;
                }
                array_selector("sequencelist_to_delete_or_load", $listnames, $listnames[0]);
                echo "<br>" . tr("w7") . " ";
                echo "<input type='checkbox' id=delete_sequencelist name=delete_sequencelist value=1>";
                echo "<br>" . tr("w8"). " ";
                echo "<input type='checkbox' id=load_sequencelist name=load_sequencelist value=1>";
            }
        }
    }
}

function edit_sequence_post(){
    # return at first call:
    $device = $_SESSION["device"];
    $username = $_SESSION["username"];
    # one element only
    $temp = [];
    $count = count($_SESSION["actual_sequencelist"][$device]);
    foreach ($_POST as $original_sequence => $new_sequence) {
        # avoid device language etc
        if ($new_sequence == "" or !is_numeric($new_sequence)  or $new_sequence > $count) {continue;}
        if ($original_sequence == "" or !is_numeric($original_sequence)  or $original_sequence > $count) {continue;}
        if ($new_sequence < 0){continue;}
        $new_sequence = abs($new_sequence);
        if ($original_sequence != $new_sequence){
            $i = 0;
            while ($i < $count) {
                if ($i < $original_sequence) {
                    if ($i < $new_sequence) {
                        $temp[$i] = $i;
                    } elseif ($i == $new_sequence) {
                        $temp[$i] = $original_sequence;
                    } else {
                        $temp[$i] = $i - 1;
                    }
                }
                elseif ($i == $original_sequence) {
                    if ($i < $new_sequence) {
                        $temp[$i] = $i+ 1;
                    } elseif ($i == $new_sequence) {
                        $temp[$i] = $i + 1;
                    } else {
                        $temp[$i] = $i - 1;
                    }
                }
                else {
                    if ($i < $new_sequence) {
                        $temp[$i] = $i + 1;
                    } elseif ($i == $new_sequence) {
                        $temp[$i] = $original_sequence;
                    } else {
                        $temp[$i] = $i;
                    }
                }
                $i++;
            }
        }
    }
    #store old list
    $old_list = $_SESSION["actual_sequencelist"][$device];
    $_SESSION["actual_sequencelist"][$device]= [];
    $_SESSION["actual_sequencelist_by_sequence"][$device] = [];
    if ($temp != []) {
        foreach ($temp as $new => $old){
            $key = "";
            foreach ($old_list as $tok => $sequence){
                if ($sequence == $old){$key = $tok;}
            }
            if( $key!= "") {
                $_SESSION["actual_sequencelist"][$device][$key] = $new;
                $_SESSION["actual_sequencelist_by_sequence"][$device][$new] = $key;
            }
        }
    }
    create_final_actual_sequencelist();
    #
    if (array_key_exists("store_sequencelist", $_POST) and $_POST["store_sequencelist"]){
        if (array_key_exists("sequncelist_name", $_POST) and $_POST["sequncelist_name"] != "") {
            $_SESSION["named_tok_lists"][$device][$username][$_POST["sequncelist_name"]] = $_SESSION["actual_sequencelist"][$device];
        }
    }
    elseif (array_key_exists("load_sequencelist", $_POST) and $_POST["load_sequencelist"]){
        if (array_key_exists("sequencelist_to_delete_or_load", $_POST) and $_POST["sequencelist_to_delete_or_load"] != "") {
            if ($_SESSION["username"] == "user") {
                $_SESSION["actual_sequencelist"][$device] = $_SESSION["named_tok_lists"][$device][$username][$_POST["sequencelist_to_delete_or_load"]];
            }
        }
    }
    elseif (array_key_exists("delete_sequencelist", $_POST) and $_POST["delete_sequencelist"]){
        if (array_key_exists("sequencelist_to_delete_or_load", $_POST) and $_POST["sequencelist_to_delete_or_load"] != "") {
            if ($_SESSION["username"] == "user") {
                unset ($_SESSION["named_tok_lists"][$device][$device][$username][$_POST["sequencelist_to_delete_or_load"]]);
            }
        }
    }
}
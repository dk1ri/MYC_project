<?php
# edit_sequence.php
# DK1RI 20240919
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function edit_sequence(){
    $device = $_SESSION["device"];
    $username = $_SESSION["username"];
    echo "<div>";
    echo "<input type='checkbox' id=sequence_default name=sequence_default value=1>";echo tr("default")."<br>";
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
}

function edit_sequence_post(){
    if (array_key_exists("sequence_default", $_POST) and $_POST["sequence_default"] == 1){
        create_actual_sequence_list();
        create_final_actual_sequencelist();
        # do nothing else
        return;
    }
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
    #remember old list
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
    var_dump($_SESSION["final_actual_sequencelist_by_sequence"][$device]);
}
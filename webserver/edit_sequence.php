<?php
# edit_sequence.php
# DK1RI 20240415
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

function edit_sequence(){
    $device = $_SESSION["device"];
    # one element only
    foreach ($_SESSION["chapter_for_edit_sequence"][$device]as $ch){if($ch != ""){$chapter = $ch;}}
    echo tr("w1")."<br>";
    echo tr("w2")."<br>";
    echo "<div>";
    echo "<input type='checkbox' id=store_edit name=store_edit value=1>";
    echo tr("store_data");
    $i = 0;
    foreach ($_SESSION["new_sequencelist"][$device][$chapter] as $sequence => $tok) {
        echo "<div>";
        echo "<input type=text name=" . $i . " size=5  placeholder = " . $i, ">";
        echo " " . $i . " " . $tok . " ";
        $an = explode(",", $_SESSION["original_announce"][$device][$tok][0]);
        if (count($an) > 1) {
            echo tr($an[1]);
        }
        echo "<br>";
        $i++;
    }
}

function edit_sequence_post(){
    # return at first call:
    $device = $_SESSION["device"];
    # one element only
    foreach ($_SESSION["chapter_for_edit_sequence"][$device]as $ch){$chapter = $ch;}
    if ($_SESSION["new_sequencelist"][$device] == []){return;}
    $temp = [];
    $count = count($_SESSION["new_sequencelist"][$device][$chapter]);
    foreach ($_POST as $original_sequence => $new_sequence) {
        print $new_sequence." ";
        # avoid device language etc
        if ($new_sequence != "" and is_numeric($new_sequence)) {
            $i = 0;
            # original:
            $j = 0;
            while ($i < $count) {
                if ($j == $new_sequence) {
                        $temp[$i] = $original_sequence;
                        $temp[$i+1]= $j;
                        $i++;
                }
                else {
                    $temp[$i] = $j;
                }
                if($original_sequence == $i){$j++;}
             #   else{$j--;}
                $j++;
                $i++;
            }
        }
    }
    var_dump($temp);
    if ($temp != []) {
        $i = 0;
        while ($i < $count) {
            $n = $temp[$i];
            $t[$i] = $_SESSION["new_sequencelist"][$device][$chapter][$n];
            $i++;
        }
        $_SESSION["new_sequencelist"][$device][$chapter] = $t;
    }
    if (array_key_exists("store_edit", $_POST) and $_POST["store_edit"]){
        if ($_SESSION["username"] != "user"){
            $user_dir = $_SESSION["conf"]["user_data_dir"] . "\\" . $_SESSION["username"];
            if (!file_exists($user_dir)) {
                mkdir($user_dir);
            }
            $user_dir = $_SESSION["conf"]["user_data_dir"] . "\\" . $_SESSION["username"]."\\".$device;
            if (!file_exists($user_dir)) {
                mkdir($user_dir);
            }
            $user_data = $user_dir."\\".$_SESSION["actual_chapter"];
            # store actual data to username
            $file = fopen($user_data, "w");
            foreach ($_SESSION["new_sequencelist"][$device][$chapter] as $seq => $tok) {
                fwrite($file, $seq . "," . $tok . "\r\n");
            }
            fclose($file);
        }
    }
}
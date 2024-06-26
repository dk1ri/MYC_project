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
    foreach ($_SESSION["new_sequencelist"][$device][$chapter] as $tok) {
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
    $count = count($_SESSION["new_sequencelist"][$device][$chapter]);print "sss";
    foreach ($_POST as $original_sequence => $new_sequence) {
        # avoid device language etc
        if ($new_sequence == "" or !is_numeric($new_sequence)  or $new_sequence > $count) {continue;}
        if ($new_sequence < 0){continue;}
        $new_sequence = abs($new_sequence);
        if ($original_sequence != $new_sequence){
            $i = 0;
            while ($i < $count) {
                print $i."1 ";
                if ($i < $original_sequence) {
                    if ($i < $new_sequence) {
                        print $i."<< ";
                        $temp[$i] = $i;
                    } elseif ($i == $new_sequence) {
                        print $i."<= ";
                        $temp[$i] = $original_sequence;
                    } else {
                        print $i."<> ";
                        $temp[$i] = $i - 1;
                    }
                }
                elseif ($i == $original_sequence) {
                    if ($i < $new_sequence) {
                        print $i."=< ";
                        $temp[$i] = $i+ 1;
                    } elseif ($i == $new_sequence) {
                        print $i."== ";
                        $temp[$i] = $i + 1;
                    } else {
                        print $i."=> ";
                        $temp[$i] = $i - 1;
                    }
                }
                else {
                    if ($i < $new_sequence) {
                        $temp[$i] = $i + 1;
                        print $i.">< ";
                    } elseif ($i == $new_sequence) {
                        $temp[$i] = $original_sequence;
                        print $i.">= ";
                    } else {
                        $temp[$i] = $i;
                        print $i.">> ";
                    }
                }
                $i++;
            }
        }
    }
    var_dump($temp);
    if ($temp != []) {
        $i = 0;
        while ($i < count($temp)) {
            $n = $temp[$i];
            $t[$i] = $_SESSION["new_sequencelist"][$device][$chapter][$n];
            $i++;
        }
        $_SESSION["new_sequencelist"][$device][$chapter] = $t;
    }
    if (array_key_exists("store_edit", $_POST) and $_POST["store_edit"]){
        check_user_dir_exist();
        $user_data = $_SESSION["conf"]["user_dir"] . "\\" . $_SESSION["username"]."\\".$device."\\new_sequencelist";
        # store actual data to username
        $file = fopen($user_data, "w");
        foreach ($_SESSION["new_sequencelist"][$device][$chapter] as $seq => $tok) {
            fwrite($file, $seq . "," . $tok . "\r\n");
        }
        fclose($file);
    }
}
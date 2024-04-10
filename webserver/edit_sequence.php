<?php
# display_commands.php
# DK1RI 20240124
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
#
# display one element for each tok (with some exceptions)
function edit_sequence(){
    global $language, $device, $activ_chapters;
    if ($_SESSION["new_sequencelist"] == []) {
        $i = 0;
        foreach ($activ_chapters as $ch => $eins) {
            if ($i == 0) {
                $_SESSION["new_sequencelist"] = $_SESSION["chapter_token_pure"][$device][$ch];
            }
            $i++;
        }
    }
    echo $language["w1"]."<br>";
    echo $language["w2"]."<br>";
    echo "<div>";
    echo "<input type='checkbox' id=store_edit name=store_edit value=1>";
    echo $language["store_data"];
    $j = 0;
    # first chapter only
    foreach ($activ_chapters as $ch => $eins) {
        if ($j == 0) {
            $i = 0;
            foreach ($_SESSION["new_sequencelist"] as $tok => $one) {
                echo "<div>";
                echo "<input type=text name=" . $tok . " size=5  placeholder = " . $i, ">";
                echo " " . $i . " " . $tok . " ";
                $an = explode(",", $_SESSION["original_announce"][$device][$tok][0]);
                if (count($an) > 1) {
                    echo $an[1];
                }
                echo "<br>";
                $i++;
            }
        }
        $j++;
    }
}

function edit_sequence_post(){
    # return at first call:
    if ($_SESSION["new_sequencelist"] == []){return;}
    $temp = [];
    foreach ($_POST as $tok => $new_sequence) {
        if ($new_sequence != "" and is_numeric($new_sequence)) {
            $i = 0;
            $found = 0;
            $old_sequence = array_keys($_SESSION["new_sequencelist"],$tok );
            foreach ($_SESSION["new_sequencelist"] as $sequence => $stok) {
                if ($found == 0) {
                    if ($i == $old_sequence) {
                        $found = 1;
                        $temp[$i] = $tok;
                    } else {
                        $temp[$i] = $_SESSION["new_sequencelist"][$i];
                    }
                }
                $i++;
            }
        }
    }
}
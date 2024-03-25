<?php
# display_commands.php
# DK1RI 20240124
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
#
# display one element for each tok (with some exceptions)
function edit_sequence(){
    global $username, $language, $is_lang, $new_sequncelist, $device, $actual_data;
    echo $language["w1"]."<br>";
    echo $language["w2"]."<br>";
    echo "<div>";
    echo "<input type='checkbox' id=store_edit name=store_edit value=1>";
    $announcelines = $_SESSION["announce_all"][$device];
    $i = 0;
    $done =  0;
    foreach ($announcelines as $tok => $value) {
        $basic_tok = basic_tok($tok);
        if (array_key_exists($basic_tok, $_SESSION["tok_list"][$device])) {
            if ($basic_tok != $done) {
                echo "<div>";
                echo "<input type=text name=" . $basic_tok . " size=5  placeholder = " . $i, ">";
                echo " " . $i . " " . $basic_tok . " ";
                $an = explode(",", $_SESSION["original_announce"][$device][$basic_tok][0]);
                if (count($an) > 1) {
                    echo $an[1];
                }
                echo "<br>";
                $done = $basic_tok;
                $i++;
            }
        }
    }
}

function edit_sequence_post(){
    global $username, $language, $is_lang, $new_sequncelist, $device, $actual_data;
    foreach (array_keys($_POST) as $key){
       if (is_numeric($key)){
           $i = 0;
           if ($_POST[$key] != ""){
                foreach ($new_sequncelist as $tok){
                    if ($key == $tok and $i = $_POST[$key]){
                        $new_list[] = $tok;
                    }
                    else {
                        if ($i < $_POST[$key]){
                            $new_list[] = $tok;
                        }
                        else {
                            $new_list[] = $key;
                            if ($key != $tok) {
                                $new_list[] = $tok;
                            }
                        }
                    }

                }
           }
       }
   }
}
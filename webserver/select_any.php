<?php
function select_any($selections, $first, $name) {
    echo($name . " : <select name=$name id='$name'>");
    $i = 0;
    $n = count($selections);
    while ($i < $n) {
        echo "<option value=$selections[$i]";
        if  ($first == $selections[$i]) {
            echo(" selected");
            }
        echo ">$selections[$i]", "</option>" ;
        $i += 1;
        }
    echo "</select>";
    }
?>
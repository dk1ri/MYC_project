<?php
# select_includes.php
# DK1RI 20240123
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function select_includes(){
# intention is to load necessary code only
    global $language, $device;
    foreach($_SESSION["includes"][$device] as $inc){
        if ($inc == "m"){include "commands_m.php";}
        elseif ($inc == "a"){include "commands_a.php";}
        elseif ($inc == "s"){include "commands_s.php";}
        elseif ($inc == "r"){include "commands_r.php";}
        elseif ($inc == "b"){include "commands_b.php";}
        elseif ($inc == "p"){include "commands_p.php";}
        elseif ($inc == "u"){include "commands_u.php";}
        elseif ($inc == "f"){include "commands_f.php";}
        elseif ($inc == "n"){include "commands_n.php";}
    }
}
?>
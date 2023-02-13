<?php
function read_device_list(){
    $handle = opendir("./devices");
    while (($file = readdir($handle)) !== false){
        if ($file != "." and $file != ".." ) {
            $_SESSION["device_list"][] = $file;
        }
    }
    closedir($handle);
    }
?>

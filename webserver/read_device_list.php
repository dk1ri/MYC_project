<?php
function read_device_list(){
    $handle = opendir(".");
    while (($file = readdir($handle)) !== false){
        if (is_dir ($file) and $file != "." and $file != ".." and $file != ".idea" ) {
            $_SESSION["device_list"][] = $file;
        }
    }
    closedir($handle);
    }
?>

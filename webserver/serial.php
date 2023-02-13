<?php
function serial_write($data){
    # data exchange with USB via file
    if (file_exists($_SESSION["serialwrite"])) {
        unlink($_SESSION["serialwrite"]);
    }
    $file = fopen($_SESSION["serialwrite"], "w");
    fwrite($file, $data);
    ob_end_flush();
    fclose($file);
    $_SESSION["last_command_status"] = 0;
    if ($_SESSION["read"]){
        sleep(2);
        serial_read();
    }
}

function serial_read(){
    # data exchange with USB via file
    $data = "";
    $i = 1;
    while ( $i < 100 and $data == ""){
        if (!file_exists($_SESSION["serialread"])) {
            usleep(50000);
        }
        else{
            $file = fopen($_SESSION["serialread"], "r");
            $data = fgets($file);
            fclose($file);
        }
        $i += 1;
    }
    if ($data == ""){
        # error
        $_SESSION["last_command_status"] = 1;
    }
    $_SESSION["read"] = 0;
   # if (file_exists($_SESSION["serialread"])) {
    #    unlink($_SESSION["serialread"]);
    #}
    $_SESSION["received_data"] = $data;
}
?>
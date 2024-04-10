<?php
# serial.php
# DK1RI 20240202
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
# the filetransfer uses hex values (2 byte per character)
function send_to_device($data){
    # send to device via file
    if (file_exists($_SESSION["conf"]["serialwrite"])) {
        unlink($_SESSION["conf"]["serialwrite"]);
    }
    # file overwrite!
    $file = fopen($_SESSION["conf"]["serialwrite"], "w");
    fwrite($file, $data);
    fclose($file);
    $_SESSION["last_command_status"] = 0;
}

function read_from_device(){
    # check serialread always
    global $received_data;
    # check serialread at start as well
    $received_data = "";
    if (!$_SESSION["read"]){
        if (file_exists($_SESSION["conf"]["serialread"])) {
            $file = fopen($_SESSION["conf"]["serialread"], "r");
            $received_data  = fgets($file);
            fclose($file);
            unlink($_SESSION["conf"]["serialread"]);
            if ($received_data  == "") {
                # error
                $_SESSION["last_command_status"] = 1;
            }
        }
    }
    else {
        $i = 1;
        $found = 0;
        while ($i <= 1000 and "!$found") {
            if (!file_exists($_SESSION["conf"]["serialread"])) {
                usleep(5000);
            } else {
                $file = fopen($_SESSION["conf"]["serialread"], "r");
                $received_data  = fgets($file);
                fclose($file);
                $found = 1;
                if ($received_data  == ""){
                    # error
                    $_SESSION["last_command_status"] = 1;
                }
            }
            $i++;
        }
        # the device write to file with append -> delete file
        if (file_exists($_SESSION["conf"]["serialread"])) {unlink($_SESSION["conf"]["serialread"]);}
    }
    if ($_SESSION["conf"]["testmode"]){print " from device: ".$received_data ." ";}
    # convert 2 byte each to 1 byte char
 #   $string = $received_data
  #  $received_data  = "";
   # $offset = 0;
    #while ($offset < strlen($string)){
     #   $received_data  .= chr(hexdec(substr($string,$offset, 2)));
      #  $offset += 2;
#
 #   }
}
?>
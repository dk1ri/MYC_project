<?php
# update_received.php
# DK1RI 20230301
function update_received(){
    $from_device = str_replace("0x", "", $_SESSION["received_data"]);
    $i = 0;
    $rec = [];
    while ($i < strlen($from_device)) {
        $rec[] = hexdec(substr($from_device, $i, 2));
        $i += 2;
    }
    while (count($rec) > 0) {
        # more than one command in a line possible
        $rec =update_one_command($rec);
    }
}

function update_one_command($rec){
    # $rec is array_spliced by every commandproperty found for a command
    $device = $_SESSION["device"];
    return [];
    if ($_SESSION["command_len"] == 2) {
        $token = $rec[0];
        $rec = array_splice($rec, 1);
    }
    else{
        $token = $rec[0] * 256 + $rec[1];
        $rec = array_splice($rec, 2);
    }
    # necessary ?
    if(!array_key_exists($token, $_SESSION["cor_token"][$device])){
        # error
        $_SESSION["received_data"] = "";
        return;
    }
    foreach ($_SESSION["cor_token"][$device][$token] as $c_token){
        # data of interest only:
        if (strstr($c_token, "x")) {
            print ($c_token);
            $property_len = $_SESSION["property_len"][$device][$token];
            # $property_len are bytes!
            $ct = $_SESSION["announce_all"][$device][$c_token][0];
            print($ct);
            switch ($ct) {
                case "as":
                case "at":
                    # on off as 3rd (last) value
                    $pos = $property_len[0] / 2 + $property_len[1] / 2;
                    $_SESSION["actual_data"][$device][$c_token] = $rec[$pos + 1];
                    break;
                case "ar":
                    $pos = $property_len[0] / 2 + $property_len[1] / 2 + $property_len[2] / 2;
                    # not finished
                    break;
                case "ap":
                    #
                    break;
                case "am":
                    # the position is already shown -> ignored but length of position necessary
                    $pos = $property_len[0] / 2;
                    $data = array_splice($rec, 0, $pos + 1);
                    $_SESSION["actual_data"][$device][$c_token] = translate_hex_to_actual($device, $token, $data);
                    break;
                case "an":

                    break;
                case "aa":
                    if (!strstr($c_token, "x0")) {
                        $length = $rec[2];
                        $t_rec = array_splice($rec, 1, $length);
                        $data = translate_hex_to_actual($device, $c_token, $t_rec);
                        print ($data);
                        $_SESSION["actual_data"][$device][$c_token] = $data;
                    }
                    break;
                case "ab":

                    break;
            }
        }
    }
}
?>
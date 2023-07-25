<?php
# read_new_device.php
# DK1RI 20221215
function for_tests($device){
    create_session_data("$device", "device_list", $_SESSION["device_list"]);
    create_session_data_file_array($device, "original_announce", $_SESSION["original_announce"][$device]);
    create_session_data_file_array($device, "announce_all", $_SESSION["announce_all"][$device]);
    create_session_data_file_array($device, "chapter_token", $_SESSION["chapter_token"][$device]);
    create_session_data_file($device, "chapter_names", $_SESSION["chapter_names"][$device]);
    create_session_data_file($device, "special_token", $_SESSION["special_token"][$device]);
    create_session_data_file_array($device, "property_len", $_SESSION["property_len"][$device]);
    create_session_data_file_array($device, "cor_token", $_SESSION["cor_token"][$device]);
    create_session_data_file($device, "oo_tok", $_SESSION["oo_tok"][$device]);
    create_session_data_file($device, "des_name", $_SESSION["des_name"][$device]);
    create_session_data_file($device, "ct_of_as", $_SESSION["ct_of_as"][$device]);
    create_session_data_file($device, "max_for_send", $_SESSION["max_for_send"][$device]);
    create_session_data_file($device, "to_correct", $_SESSION["to_correct"][$device]);
    create_session_data_file($device, "des", $_SESSION["des"][$device]);
    create_session_data_file($device, "to_correct", $_SESSION["to_correct"][$device]);
    create_session_data_file($device, "actual_data", $_SESSION["actual_data"][$device]);
    create_session_data_file($device, "type_for_memories", $_SESSION["type_for_memories"][$device]);
    create_session_data_file($device, "a_to_o", $_SESSION["a_to_o"][$device]);
    create_session_data_file("$device", "conf", $_SESSION["conf"]);
    create_session_data_file_array("$device", "chapter_token", $_SESSION["chapter_token"][$device]);
}

function create_session_data($device, $name, $data){
  #  print ($name);
    $file = fopen("./devices/".$device."/session_".$name, "w");
        fwrite( $file,$data."\n");
    fclose($file);
}

function create_session_data_file($device, $name, $data){
 #    print ($name);
    $file = fopen("./devices/".$device."/session_".$name, "w");
    foreach ($data as $key=> $value){
        fwrite( $file,$key." ".$value."\n");
    }
    fclose($file);
}

function create_session_data_file_array($device, $name, $data){
  # print($name);
    $file = fopen("./devices/".$device."/session_".$name, "w");
    foreach ($data as $key=> $value){
        $line = $key. ":: ";
        foreach ($value as $key_ => $val) {
            $line .= $key_ . ": " . $val . " ";
        }
        fwrite($file, $line . "\n");
    }
    fclose($file);
}
?>
<?php
# for_tests.php
# DK1RI 20240124
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
function for_tests(){
    global $device, $activ_chapters;
    create_session_data_file("$device", "device_list", $_SESSION["device_list"]);
    create_session_data_file_array($device, "original_announce", $_SESSION["original_announce"][$device]);
    create_session_data_file($device, "announce_all", $_SESSION["announce_all"][$device]);
    create_session_data_file_array($device, "chapter_token_pure", $_SESSION["chapter_token_pure"][$device]);
    create_session_data_file($device, "chapter_names", $_SESSION["chapter_names"][$device]);
    create_session_data_file($device, "special_token", $_SESSION["special_token"][$device]);
    create_session_data_file_array($device, "property_len", $_SESSION["property_len"][$device]);
    create_session_data_file_array($device, "cor_token", $_SESSION["cor_token"][$device]);
    create_session_data_file($device, "unit", $_SESSION["unit"][$device]);
    create_session_data_file($device, "oo_tok", $_SESSION["oo_tok"][$device]);
    create_session_data_file($device, "des_name", $_SESSION["des_name"][$device]);
    create_session_data_file($device, "chapter_names", $_SESSION["chapter_names"][$device]);
    create_session_data_file($device, "chapter_names_with_space", $_SESSION["chapter_names_with_space"][$device]);
    create_session_data_file($device, "ALL", $_SESSION["ALL"][$device]);
    create_session_data_file($device, "max_for_send", $_SESSION["max_for_send"][$device]);
    create_session_data_file($device, "max_for_ADD", $_SESSION["max_for_ADD"][$device]);
    create_session_data_file($device, "to_correct", $_SESSION["to_correct"][$device]);
    create_session_data_file($device, "des", $_SESSION["des"][$device]);
    create_session_data_file($device, "to_correct", $_SESSION["to_correct"][$device]);
    create_session_data_file($device, "actual_data", $_SESSION["actual_data"][$device]);
    create_session_data_file($device, "type_for_memories", $_SESSION["type_for_memories"][$device]);
    create_session_data_file($device, "a_to_o", $_SESSION["a_to_o"][$device]);
    create_session_data_file($device, "meter", $_SESSION["meter"][$device]);
    create_session_data_file($device, "meter_announce_line", $_SESSION["meter_announce_line"][$device]);
    create_session_data_file($device, "string_commands", $_SESSION["string_commands"][$device]);
    create_session_data_file("$device", "conf", $_SESSION["conf"]);
    create_session_data_file("$device", "alpha", $_SESSION["alpha"][$device]);
    create_session_data_file("$device", "rules", $_SESSION["rules"][$device]);
}

function create_session_data_file($device, $name, $data){
    $file = fopen("./devices/".$device."/session_".$name, "w");
    foreach ($data as $key=> $value){
        fwrite( $file,$key." ".$value."\n");
    }
    fclose($file);
}

function create_session_data_file_array($device, $name, $data){
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
<?php
function read_config() {
    $_SESSION = [];
    $_SESSION["started"] = 1;
    # not used
    $_SESSION["config"] = '';
    # missing
    $_SESSION["interface"] = '';
    # answer command sent; read data
    $_SESSION["read"] = 0;
    # last command status
    $_SESSION["last_command_status"] = 0;
    # not used
    $_SESSION["init_read"] = 0;
    # user name
    $_SESSION["name"] = '';
    # list of available device
    $_SESSION["device_list"] = [];
    include "read_device_list.php";
    # read $_SESSION["device_list"]
    read_device_list();
    # device_list: array
    $device = $_SESSION["device_list"][0];
    # actual device: string
    $_SESSION["device"] = $device;
    # announce_all: token: array data: array
    # switches: ct switch-labels
    # memory / range commands: ct only
    $_SESSION["announce_all"] = [];
    # chapter_token: token: arra data: 1
    $_SESSION["chapter_token"] =[];
    # token _of_a_chapter: array
    $_SESSION["chapter_token"] =[];
    # token length: string
    $_SESSION["tok_len"][$device] = 0;
    # token converted to hex: token: array, data: string
    $_SESSION["tok_hex"][$device] = [];
    # token with identical basic_tok : token: array, data: array
    $_SESSION["cor_token"][$device] = [];
    # token with ADD token : token: array, data: string
    $_SESSION["adder_token"][$device] = [];
    # transmission length for each dimension (if applicable) token: array data: string
    $_SESSION["p_len"][$device] = [];
    # actual chapter: string
    $_SESSION["chapter"] = 'all';
    # original_announce: spltted announcefile token; array data: array: line split by ";"
    $_SESSION["original_announce"] = [];
    # announcements: token: array data: , separated string
    # 0: ct
    # 1: max_length (for dimensions of range commands)
    $_SESSION["announce_all"] = [];
    # chapter_names: array
    $_SESSION["chapter_names"] =[];
    # actual read data: token: array, data: string
    $_SESSION["actual_data"] = [];
    # des_range: token: array data: string
    $_SESSION["des_range"] = [];
    # des_name: token: array data: string
    $_SESSION["des_name"] = [];
    # des_type: for memory commands: token: array data: array -> string
    # range is copy of announcement (not resolved)
    # m / n commands: type,CODING,name,startvalue,range
    # a / b commands: type,CODING,name,startvalue,range type,CODING,startvalue,range ...
    $_SESSION["des_type"] = [];
    # property_len: for transmitted data: sequence as per announcemnets: baic_tok:array data: array
    $_SESSION["property_len"] = [];
    # corrected _POST (has no [$device] !!!) (as $_POST)
    # token: array, data: string
    $_SESSION["corrected_POST"] = [];
    # actual_data: token: array: data: string
    # a command: value, value,...
    # others: one value only
    $_SESSION["actual_data"] = [];
    # reveived data
    $_SESSION["received_data"] = "";
    #
    $_SESSION["conf"] = [];
    $config = "_config";
    if (file_exists($config)) {
        $file = fopen($config, "r");
        $i = 0;
        while (!(feof($file))) {
            $line = fgets($file);
            $line = fgets($file);
            $line = str_replace("\r", "", $line);
            $line = str_replace("\n", "", $line);
            switch ($i) {
                case  0:
                    $_SESSION["conf"]["announcefile"] = $line;
                    break;
                case  1:
                    $_SESSION["conf"]["serial_dir"] = $line;
                    break;
                case  2:
                    $_SESSION["conf"]["bgb"] = $line;
                    break;
                case  3:
                    $_SESSION["conf"]["bgs"] = $line;
                    break;
                case  4:
                    $_SESSION["conf"]["bga"] = $line;
                    break;
                case  5:
                    $_SESSION["conf"]["s"] = $line;
                    break;
                case  6:
                    $_SESSION["conf"]["r"] = $line;
                    break;
                case  7:
                    $_SESSION["conf"]["at"] = $line;
                    break;
                case  8:
                    $_SESSION["conf"]["ou"] = $line;
                    break;
                case  9:
                    $_SESSION["conf"]["p"] = $line;
                    break;
                case  10:
                    $_SESSION["conf"]["m"] = $line;
                    break;
                case  11:
                    $_SESSION["conf"]["n"] = $line;
                    break;
                case  12:
                    $_SESSION["conf"]["a"] = $line;
                    break;
                case  13:
                    $_SESSION["conf"]["b"] = $line;
                    break;
            }
            $i ++;
        }
    }
    fclose($file);
    $_SESSION["serialwrite"] = $_SESSION["conf"]["serial_dir"] . "from_web";
    $_SESSION["serialread"] = $_SESSION["conf"]["serial_dir"] . "to_web";
}
?>

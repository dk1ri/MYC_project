<html lang = "de">
<!-- werbserver for MYC system
     myc.php
     Version 1.1 20230125
     not implemented / missing:
     switches: DIMENSIONS
     ext
     range commands: sequence like log, date.. (lin only)
     ob ab commands
     des for types <ty>, single, double, time
     range commands not finished
     -->
    <head>
        <title>MYC Apache Server</title>
        <meta name="author" content="DK1RI">
        <meta http-equiv="refresh" content="1030">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            .flex-container {
                display: flex;
                background-color: DodgerBlue;
                }

            .flex-container > div {
                background-color: #f1f1f1;
                margin: 10px;
                padding: 20px;
                font-size: 30px;
                }
        </style>
    </head>
    <body>
        <?php
        session_start();
        $_SESSION = [];
        $_SESSION["started"] = 1;
        # not used
        $_SESSION["config"] = '';
        # missing
        $_SESSION["interface"] = '';
        # ?
        $_SESSION["read_data"] = 0;
        # not used
        $_SESSION["init_read"] = 0;
        # not used
        include "read_config.php";
        read_config();
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
        # stack length (if applicable): token: array data: string
        $_SESSION["sel_len"][$device] = [];
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
        # des_type: for memory commands: token: array data: string
        # m /n commands: type,from_-_to, startvalue
        # a commands: type,from_-_to, startvalue;type,from_-_to, startvalue;...
        $_SESSION["des_type"] = [];
        # property_len: for transmitted data: sequence as per announcemnets: baic_tok:array data: array
        $_SESSION["property_len"] = [];
        # corrected _POST (has no [$device] !!!) (as $_POST)
        # token: array, data: string
        $_SESSION["corrected_POST"] = [];
        # actual_data: token: array: data: string
        # a command: value, value,...
        # others: one value only
        $_SESSION["actusl_data"] = [];
        #
        $date = new DateTime();
        $act_date = $date->getTimestamp();
        include "select_any.php";
        ?>
        <form action="action.php" method="post">
            <!--name will be used later to create user individual caches -->
            <p>Ihr Name: <input type="text" name = "name" size = 15>
            Interface: <input type="text" name = "interface" size = 15>
            <?php
            select_any($_SESSION["device_list"],  $_SESSION["device_list"][0], "devices")
            ?>
            </p><p><input type="submit" /></p>
        </form>
    </body>
</html>
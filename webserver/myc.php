<html lang = "de">
<!-- werbserver for MYC system
     Version 1.1 20221105 -->
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
        # not used
        $_SESSION["started"] = '';
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
        $device = $_SESSION["device_list"][0];
        # actual device
        $_SESSION["device"] = $device;
        # token length
        $_SESSION["tok_len"][$device] = 0;
        # token converted to hex for each token
        $_SESSION["tok_hex"][$device] = [];
        # selector length for each token (if applicable)
        $_SESSION["sel_len"][$device] = [];
        # transmission length for each dimension for each token (if applicable)
        $_SESSION["p_len"][$device] = [];
        # token for op / ap commands
        $_SESSION["p_token"][$device] = [];
        # actual chapter
        $_SESSION["chapter"] = 'all';
        # announcement without ext lines, include selector token
        $_SESSION["all_announce"] = [];
        # all token
        $_SESSION["all_token"] = [];
        $_SESSION["chapter_names"] =[];
        # token in differnt chapter elements (array)
        $_SESSION["chapter"] = [];
        # actual read data by device and token, include selector token
        $_SESSION["all_real_data"] = [];
        # token of or and ar commands (from $_SESSION["all_announce"])
        $_SESSION["or_ar_tokens"] = [];
        # basictoken -> all corresponding selectortoken
        $_SESSION["sele_toks"] = [];
        # basictoken -> number of selects for corresponding selectortoken
        $_SESSION["number_of_selects"] = [];
        # basictoken -> max value of MUL
        $_SESSION["maxsel"]  = [];
        # des per token
        $_SESSION["des"] = [];
        # corrected _POST
        $_SESSION["corrected_POST"] = [];
        # not used
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
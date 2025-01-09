<html lang = "de">
<!--
    Webserver for MYC system
    myc.php
    Version 1.3 20250104
    Manual Version: V01.01.09
    The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

    For description see detailed_description.php
    ================================================================
    This version is under development
    This version may have errors!
    ================================================================
    known errors:
    see detailed description
-->
    <?php
    session_start();
    include "create_new_device.php";
    include "display_commands.php";
    include "file_handling.php";
    include "read_config.php";
    include "select_any.php";
    include "split_to_display_objects.php";
    include "subs.php";
    include "user_data.php";
    # must be included always (no simple check after loading device from file):
    read_config();
    read_translate_lines_default();
    # $_SESSION["device" exists (first  entry) , create (read) device
    $device_read = 0;
    if (file_exists("devices\\".$_SESSION["device"]."\\session_original_announce")){
        # data already available
        read_device_from_file();
        $device_read = 1;
    }
    if($_SESSION["username"] != "user"){
        read_user_data();
        $device_read = 1;
    }
    if(!$device_read){create_new_device_first_time();}
    $date = new DateTime();
    $act_date = $date->getTimestamp();
    ?>
    <head>
        <title>MYC Apache Server</title>
        <meta name="author" content="DK1RI">
        <meta http-equiv="refresh" content="1000">
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
        <form action="action.php" method="post">
            <?php
            echo " " .tr("your_name") . ": ";
            # name will be used later to create user individual caches
            echo "<input type='text' name = 'user_name' size = 15 value=" . $_SESSION["username"] . ">";
            echo tr("language") . ": ";
            array_selector("language", $_SESSION["languages"], $_SESSION["is_lang"]);
            echo tr("device") . ": ";
            array_selector("device",  $_SESSION["device_list"], $_SESSION["device"]);
            echo "<p><input type='submit' value = " . tr("send") . "></p>";
            ?>
        </form>
    </body>
</html>
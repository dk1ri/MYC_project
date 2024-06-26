<html lang = "de">
<!--
    Webserver for MYC system
    myc.php
    Version 1.2 202420
    Manual Version: V01.01.06
    The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

    For description see detailed_description.php
    ================================================================
    This version is under development
    This version may have errors!
    ================================================================
    known errors
    as command not working (hang) not in _POST ???
-->
    <?php
    session_start();
    include "read_config.php";
    include "file_handling.php";
    include "subs.php";
    read_config();
    $date = new DateTime();
    $act_date = $date->getTimestamp();
    include "select_any.php";
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
<html lang = "de">
<!--
    werbserver for MYC system
    myc.php
   Version 1.1 20230621
    The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

    To understand the program, you should be familiar with the announcements and commands of the MYC system (at least)
    please read https://dk1ri.de/myc/commands.pdf or https://dk1ri.de/myc/commands.txt

    To understand the program flow see action.php

    This version should work basically, but there are some errors

    found errors:
    ct_of_as correctly used? -> ct_of_as_ ?
    command a with 1 parameter: "0" not omitted

     not implemented / missing:
     FIFO missing?
     hex input for strings
     ext
     range commands: sequence like log, date.. (lin only)
     CONVERT
-->
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
        <?php
        session_start();
        include "read_config.php";
        read_config();
        $date = new DateTime();
        $act_date = $date->getTimestamp();
        include "select_any.php";
        ?>
        <form action="action.php" method="post">
            <?php
            $name = $_SESSION["user"]["username"];
            echo $_SESSION["user"]["language"][$name]["language"] . ": ";
            simple_selector("languages", $_SESSION["lang_select"], $_SESSION["is_lang"]);
            echo " " .$_SESSION["user"]["language"][$name]["your_name"] . ": ";
            # name will be used later to create user individual caches
            echo "<input type='text' name = 'user_name' size = 15 value=" . $_SESSION["user"]["username"] . ">";
            echo " Interface: <input type='text' name = 'interface' size = 15>";
            echo $_SESSION["user"]["language"][$name]["device"] . ": ";
            simple_selector("device",  explode(",", $_SESSION["device_list"]), $_SESSION["actual_data"]["_device_"])
            ?>
           <p><input type="submit" /></p>
        </form>
    </body>
</html>
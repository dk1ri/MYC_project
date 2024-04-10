<html lang = "de">
<!--
    Webserver for MYC system
    myc.php
    Version 1.2 20240331
    Manual Version: V01.01.06
    The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

    For description see detailed_description.php
    ================================================================
    This version is under development
    This version may have errors!
    ================================================================
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
        global $username, $language, $is_lang, $device, $activ_chapters, $tok_to_send;
        include "read_config.php";
        read_config();
        $date = new DateTime();
        $act_date = $date->getTimestamp();
        include "select_any.php";
        ?>
        <form action="action.php" method="post">
            <?php
            echo " " .$language["your_name"] . ": ";
            # name will be used later to create user individual caches
            echo "<input type='text' name = 'user_name' size = 15 value=" . $username . ">";
            echo $language["language"] . ": ";
            array_selector("language", $_SESSION["languages"], $is_lang);
            echo $language["device"] . ": ";
            array_selector("device",  $_SESSION["device_list"], $device)
            ?>
           <p><input type="submit" value = senden name = 123></p>
        </form>
    </body>
</html>
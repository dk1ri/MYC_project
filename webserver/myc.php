<html lang = "de">
<!-- werbserver for MYC system
     myc.php
     Version 1.1 20230205
     to check:
     retranslate_simple_range required? or wrong?

     not implemented / missing:
     switches: DIMENSIONS
     ext
     range commands: sequence like log, date.. (lin only)
     CONVERT
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
        include "read_config.php";
        read_config();
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
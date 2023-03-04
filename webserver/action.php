<?php
# action.php
# DK1RI 20230302
?>

<html lang = "de">
<?php
    session_start();
?>
    <head>
        <title>MYC Apache Server</title>
        <meta name="author" content="DK1RI">
        <meta http-equiv="refresh" content="1030">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            .flex-container {
                display: flex;
                flex-wrap: wrap;
                background-color: #6c9ccb;
            }

            .flex-container > div {
                background-color: #d1f8ff;
                margin: 2px;
                padding: 2px;
                font-size: 15px;
            }
            .green {
                color : green;
            }
            .red{
                color : red;
            }
            <?php
            echo ".os{color: " . $_SESSION["conf"]["s"] . ";}";
            echo ".as{color: " . $_SESSION["conf"]["s"] . ";background-color: " . $_SESSION["conf"]["bga"] . "}";
            echo ".or{color: " . $_SESSION["conf"]["r"] . ";}";
            echo ".ar{color: " . $_SESSION["conf"]["r"] . ";background-color: " . $_SESSION["conf"]["bga"] . "}";
            echo ".at{color: " . $_SESSION["conf"]["at"] . ";}";
            echo ".ou{color: " . $_SESSION["conf"]["ou"] . ";}";
            echo ".op{color: " . $_SESSION["conf"]["p"] . ";}";
            echo ".ap{color: " . $_SESSION["conf"]["p"] . ";background-color: " . $_SESSION["conf"]["bga"] . "}";
            echo ".om{color: " . $_SESSION["conf"]["m"] . ";}";
            echo ".am{color: " . $_SESSION["conf"]["m"] . ";background-color: " . $_SESSION["conf"]["bga"] . "}";
            echo ".on{color: " . $_SESSION["conf"]["n"] . ";}";
            echo ".an{color: " . $_SESSION["conf"]["n"] . ";background-color: " . $_SESSION["conf"]["bga"] . "}";
            echo ".oa{color: " . $_SESSION["conf"]["a"] . ";}";
            echo ".aa{color: " . $_SESSION["conf"]["a"] . ";background-color: " . $_SESSION["conf"]["bga"] . "}";
            echo ".ob{color: " . $_SESSION["conf"]["b"] . ";}";
            echo ".ab{color: " . $_SESSION["conf"]["b"] . ";background-color: " . $_SESSION["conf"]["bga"] . "}";
            ?>
        </style>
    </head>
    <body>
        <?php
        if (array_key_exists("user_name", $_POST)) {
            $_SESSION["user"]["username"] = $_POST["user_name"];
        }
        if (array_key_exists("languages", $_POST)) {
            $_SESSION["user"]["is_lang"] = $_POST["languages"];
            # 0 englich 1 deutsch ...
            $language = $_SESSION["lang_select"][$_POST["languages"] * 2 + 1];
            $_SESSION["user"]["language"][$_SESSION["user"]["username"]] = $_SESSION["lang"][$language];
        }
        if (array_key_exists("device", $_POST)) {
            # other device?
            $post_dev = $_POST["device"];
            if ($post_dev != $_SESSION["actual_data"]["_device_"]) {
                $_SESSION["actual_data"]["_device_"] = $post_dev;
                $_SESSION["device"] = explode(",", $_SESSION["device_list"])[2 * $post_dev + 1];
                # nothing else is done:
                $_POST = [];
            }
        }
        $device = $_SESSION["device"];
        if (array_key_exists("chapter", $_POST)) {
            $post_dev = $_POST["chapter"];
            if ($post_dev != $_SESSION["actual_data"]["_device_"]) {
                $_SESSION["actual_data"]["_chapter_"] = $post_dev;
            }
        }
        # create / read new device for $_SESSION, if not existing
        # not actually used devices are not deleted
        include "translate.php";
        include "subs.php";
        include "send_and_update.php";
        include "display_commands.php";
        include "create_commands.php";
        include "select_any.php";
        include "for_tests.php";
        include "serial.php";
        include "update_received.php";
        include "split_to_display_objects.php";
        if (!array_key_exists($device, $_SESSION["announce_all"])) {
            include "read_new_device.php";
            read_new_device($device);
            for_tests($device);
        }
        correct_POST($device);
        send_and_update();
        If ($_SESSION["received_data"] != ""){
            update_received();
        }
        $actual_chapter = $_SESSION["chapter"];
        # $_SESSION ready, create new page
        ?>
        <div class = "flex-container"><div>
        <form action="action.php" method="post">
        <input type="submit" />
        </div><div>
        Interface: <input type="text" name = "interface" size = 14 name='name' value = <?php echo $_SESSION["interface"] ?>>
        <br>
        <?php
        if ($_SESSION["last_command_status"]){
            echo "<strong class = 'red'>last command not ok</strong>";
        }
        else{
            echo "<strong class = 'green'>last command ok</strong>";
        }
        ?>
        </div><div>
        <?php
        simple_selector("device",  explode(",", $_SESSION["device_list"]), $_SESSION["actual_data"]["_device_"]);
        echo ("<br>");
        simple_selector("chapter", explode(",", $_SESSION["chapter_names"][$_SESSION["device"]]), $_SESSION["actual_data"]["_chapter_"]);
        echo "</div>";
        display_commands();
        echo "</form>";
        echo"</div>";
        ?>
    </body>
</html>
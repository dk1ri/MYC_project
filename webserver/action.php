<?php
# action.php
# DK1RI 20230615
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.

# action.php is the basic page and call all other functions
# to store data the SESSION mechanism is used, which stores data for the next call of the page.
# data are stored in $_SESSION["dataname"][$device] independent for each device
# To reduce computing power most of these data are generated with the first call of the page for a device. So this will
# take some more time with the first call.
# Most of these data are stored in files "session"dataname" in the devices/"devicename" folder. This may help debugging.
# testmode must be set to 1 in _config
# The initialisation and description of these data can be found in read_new_device.php
# all other data (independent of a device) are initialized and described in read_config.php (called with myc.php)

?>
<html lang = "de">
<?php
    session_start();
?>
<script>
    function do_action() {
        document.getElementById("action").submit();
    }
</script>

    <head>
        <title>MYC Apache Server</title>
        <meta name="author" content="DK1RI">
        <meta http-equiv="refresh" content="1030">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            .flex-container {
                display:flex;
                flex-wrap:wrap;
                background-color:#6c9ccb;
            }
            .flex-container > div {
                background-color:#d1f8ff;
                margin:2px;
                padding:2px;
                font-size:15px;
            }
            <?php
            echo ".green{color : green;}";
            echo ".red{color : red;}";
            echo ".os{color: ".$_SESSION["conf"]["s"].";}";
            echo ".as{color: ".$_SESSION["conf"]["s"].";background-color:".$_SESSION["conf"]["bga"]."}";
            echo ".or{color: ".$_SESSION["conf"]["r"].";}";
            echo ".ar{color: ".$_SESSION["conf"]["r"].";background-color:".$_SESSION["conf"]["bga"]."}";
            echo ".at{color: ".$_SESSION["conf"]["at"].";background-color:".$_SESSION["conf"]["bga"]."}";
            echo ".ou{color: ".$_SESSION["conf"]["ou"].";}";
            echo ".op{color: ".$_SESSION["conf"]["p"].";}";
            echo ".ap{color: ".$_SESSION["conf"]["p"].";background-color:".$_SESSION["conf"]["bga"]."}";
            echo ".om{color: ".$_SESSION["conf"]["m"].";}";
            echo ".am{color: ".$_SESSION["conf"]["m"].";background-color:".$_SESSION["conf"]["bga"]."}";
            echo ".on{color: ".$_SESSION["conf"]["n"].";}";
            echo ".an{color: ".$_SESSION["conf"]["n"].";background-color:".$_SESSION["conf"]["bga"]."}";
            echo ".oa{color: ".$_SESSION["conf"]["a"].";}";
            echo ".aa{color: ".$_SESSION["conf"]["a"].";background-color:".$_SESSION["conf"]["bga"]."}";
            echo ".ob{color: ".$_SESSION["conf"]["b"].";}";
            echo ".ab{color: ".$_SESSION["conf"]["b"].";background-color:".$_SESSION["conf"]["bga"]."}";
            echo ".of{color: ".$_SESSION["conf"]["f"].";}";
            echo ".af{color: ".$_SESSION["conf"]["f"].";background-color:".$_SESSION["conf"]["bga"]."}";
            # marquee do no work as required:
            echo ".marquee {width:200px;height:40px;margin:0;overflow:hidden;}";
            echo ".marquee.h3{animation:marquee 5s linear infinite;";
            echo "@keyframes marquee{from {left:0%}to{left:100%}}";
            ?>
        </style>
    </head>
    <body>
        <?php
        include "subs.php";
        include "serial.php";
        include "select_includes.php";
        include "update_received.php";
        include "translate.php";
        include "send_and_update.php";
        include "display_commands.php";
        include "select_any.php";
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
            $post_ = $_POST["device"];
            if ($post_ != $_SESSION["actual_data"]["_device_"]) {
                $_SESSION["actual_data"]["_device_"] = $post_;
                $_SESSION["device"] = explode(",", $_SESSION["device_list"])[2 * $post_ + 1];
                # nothing else to do:
                $_POST = [];
            }
        }
        $device = $_SESSION["device"];
        # new chapters?
        $chapters = [];
        foreach ($_POST as $key => $value){
            if (strstr($key,"chapter_")){
                $chapters[] =   explode("chapter_", $key)[1];
            }
        }
        if ($chapters != []){
            $_SESSION["activ_chapters"][$device] = [];
            foreach ($chapters as $chap){
                $_SESSION["activ_chapters"][$device][$chap] = $chap;
            }
            create_tok_list($_SESSION["device"]);
        }
        if ($_SESSION["conf"]["testmode"]){
            include "for_tests.php";
        }
        # other device?
        if (!array_key_exists($device, $_SESSION["announce_all"])) {
            # create / read new device for $_SESSION, if not existing
            # not actually used devices are not deleted
            include "read_new_device.php";
            include "split_to_display_objects.php";
            read_new_device($device);
            if ($_SESSION["conf"]["testmode"]){
                for_tests($device);
            }
        }
        # necessary includes
        select_includes();
        if (array_key_exists("chapter", $_POST)) {
            $post_ = $_POST["chapter"];
            if ($post_ != $_SESSION["actual_data"]["_chapter_"]) {
                $_SESSION["actual_data"]["_chapter_"] = $post_;
                create_tok_list($device);
            }
        }
        correct_POST($device);
        send_and_update();
        If ($_SESSION["received_data"] != ""){
            # data from device
            update_received();
        }
        $actual_chapter = $_SESSION["chapter"];
        # $_SESSION ready, create new page
        ?>
        <div class = "flex-container"><div>
        <form id = "action" action="action.php" method="post">

        <input type="button" onclick="do_action()" value="abschicken">
        </div><div>
        Interface: <input type="text" name = "interface" size = 14 value = <?php echo $_SESSION["interface"] ?>>
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
        $i = 0;
        foreach ($_SESSION["chapter_names"][$_SESSION["device"]] as $tok) {
            echo "<input type='checkbox' name=" . "chapter_".$tok . " id=" . "chapter_".$tok . ">";
            if (array_key_exists($tok, $_SESSION["activ_chapters"][$device])) {
                echo "<strong class = 'green'>";
            } else {
                echo "<strong class = 'red'>";
            }
            echo "<label for " .$tok . ">" . $tok . "</label></strong><br>";
            $i += 2;
        }
        echo "</div>";
        display_commands();
        echo "</form>";
        echo"</div>";
        ?>
    </body>
</html>
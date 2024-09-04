<?php
# action.php
# DK1RI 20240901
# The ideas of this document can be used under GPL (Gnu Public License, V2) as long as no earlier other rights are affected.
?>
<html lang = "de">
<?php
    session_start();
?>
<script>
    function do_action() {
        document.getElementById("action").submit();
    }
    function update_window() {
        counter ++;
        window.write ("test");
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
                <?php
                echo "background-color:".$_SESSION["color"]["background_flex"].";";
                ?>
                background-color:#6c9ccb;
            }
            .flex-container > div {
                <?php
                echo "background-color:".$_SESSION["color"]["background_flex_container"].";";
                ?>
                margin:2px;
                padding:2px;
                font-size:15px;
            }
            <?php
            echo ".green{color : green;}";
            echo ".red{color : red;}";
            echo ".os{color: ".$_SESSION["color"]["switch_command_s"].";}";
            echo ".as{color: ".$_SESSION["color"]["switch_command_s"].";background-color:".$_SESSION["color"]["background_answer"]."}";
            echo ".or{color: ".$_SESSION["color"]["switch_command_r"].";}";
            echo ".ar{color: ".$_SESSION["color"]["switch_command_r"].";background-color:".$_SESSION["color"]["background_answer"]."}";
            echo ".at{color: ".$_SESSION["color"]["switch_command_at"].";background-color:".$_SESSION["color"]["background_answer"]."}";
            echo ".ou{color: ".$_SESSION["color"]["switch_command_ou"].";}";
            echo ".op{color: ".$_SESSION["color"]["range_command_p"].";}";
            echo ".ap{color: ".$_SESSION["color"]["range_command_p"].";background-color:".$_SESSION["color"]["background_answer"]."}";
            echo ".om{color: ".$_SESSION["color"]["memory_command_m"].";}";
            echo ".am{color: ".$_SESSION["color"]["memory_command_m"].";background-color:".$_SESSION["color"]["background_answer"]."}";
            echo ".on{color: ".$_SESSION["color"]["memory_command_n"].";}";
            echo ".an{color: ".$_SESSION["color"]["memory_command_n"].";background-color:".$_SESSION["color"]["background_answer"]."}";
            echo ".oa{color: ".$_SESSION["color"]["memory_command_a"].";}";
            echo ".aa{color: ".$_SESSION["color"]["memory_command_a"].";background-color:".$_SESSION["color"]["background_answer"]."}";
            echo ".ob{color: ".$_SESSION["color"]["memory_command_b"].";}";
            echo ".ab{color: ".$_SESSION["color"]["memory_command_b"].";background-color:".$_SESSION["color"]["background_answer"]."}";
            echo ".of{color: ".$_SESSION["color"]["memory_command_f"].";}";
            echo ".af{color: ".$_SESSION["color"]["memory_command_f"].";background-color:".$_SESSION["color"]["background_answer"]."}";
            # marquee do no work as required:
            echo ".marquee {width:200px;height:40px;margin:0;overflow:hidden;}";
            echo ".marquee.h3{animation:marquee 5s linear infinite;";
            echo "@keyframes marquee{from {left:0%}to{left:100%}}";
            ?>
        </style>
    </head>
    <body>
    <p id="myc"></p>
    <?php
    include "subs.php";
    include "serial.php";
    include "update_received.php";
    include "correct_POST.php";
    include "file_handling.php";
    include "send_and_update.php";
    include "display_commands.php";
    include "select_any.php";
    include "edit_sequence.php";
    include "edit_color.php";
    include "edit_language.php";
    include "edit_ignore.php";
    include "user_data.php";
    include "create_new_device.php";
    include "split_to_display_objects.php";
    # must be included always (no simple check after loading device from file):
    include "commands_a.php";
    include "commands_b.php";
    include "commands_m.php";
    include "commands_n.php";
    include "commands_f.php";
    include "commands_r.php";
    include "commands_s.php";
    include "commands_p.php";
    include "commands_u.php";
    if ($_SESSION["conf"]["testmode"]){
        include "for_tests.php";
    }
    $_SESSION["send_string_by_tok"] = [];
    $_SESSION["send_ok"] = 1;
    if (array_key_exists("language", $_POST) and $_POST["language"] != "") {
        $_SESSION["is_lang"] = $_POST["language"];
    }
    if (!$_SESSION["started"]) {
        $_SESSION["started"] = 1;
        $_SESSION["device"] = $_POST["device"];
        create_new_device();
    }
    elseif (array_key_exists("device", $_POST) and $_POST["device"] != "") {
        if ($_SESSION["device"] != $_POST["device"]) {
            $_SESSION["device"] = $_POST["device"];
            create_new_device();
            # do nohting else
            $_POST = [];
        }
    }
    $device = $_SESSION["device"];
    # username, language and device is never empty
    if (array_key_exists("user_name", $_POST) and $_POST["user_name"] != "") {
        $uname = checkusername($_POST["user_name"]);
        if ($uname != $_SESSION["username"]){
            $_SESSION["username"] = $uname;
            if ($uname != "user") {
                # load new user data
                read_user_data();
            }
            else{
                $_SESSION["color"] = $_SESSION["default_color"];
                $_SESSION["is_lang"] = $_SESSION["default_lang"];
                $_SESSION["toks_to_ignore"] = [];
                # device and activ_chapters not changed
            }
        }
    }
    # the following are the basic functions used
    $edit_sequence_not_changed = 1;
    if (array_key_exists("select_mode", $_POST)) {
       $_SESSION["select_mode"] = $_POST["select_mode"];
    }

    $chapters = [];
    foreach ($_POST as $key => $value) {
        if (strstr($key, "chapter_")) {
            $dat = explode("chapter_", $key)[1];
            $chapters[$dat] = $dat;
        }
    }
    if ($chapters != []) {
        $chapter_old =  $_SESSION["activ_chapters"][$device];
        $_SESSION["activ_chapters"][$device] = [];
        foreach ($_SESSION["chapter_names"][$device] as $chap) {
            if (array_key_exists($chap, $chapters)){
                if (!array_key_exists($chap, $chapter_old)){
                    $_SESSION["activ_chapters"][$device][$chap] = $chap;
                }
            }
            else {
                if (array_key_exists($chap, $chapter_old)){
                    $_SESSION["activ_chapters"][$device][$chap] = $chap;
                }
            }
        }
        create_final_actual_sequencelist();
    }

    if ($_SESSION["select_mode"] == "operate") {
        correct_POST();
        # one command only
        if (count($_SESSION["tok_to_send"])) {
            reset($_SESSION["tok_to_send"]);
            $key = key($_SESSION["tok_to_send"]);
            if (array_key_exists($key, $_SESSION["send_string_by_tok"])) {
                print "send: " . $_SESSION["send_string_by_tok"][$key];
                send_to_device($_SESSION["send_string_by_tok"][$key]);
            }
            $_SESSION["tok_to_send"] = [];
            $_SESSION["send_string_by_tok"] = [];
        }
        if ($_SESSION["read"]) {receive_civ();}
        $_SESSION["read"] = 0;
    }
    elseif ($_SESSION["select_mode"] == "edit_sequence") {
        if ($_SESSION["select_mode"] == $_SESSION["last_mode"]) {
            $chapter_changed = 0;
            $found = 0;
            foreach ($_POST as $key => $value) {
                if (!$found and strstr($key, "chapter_names")) {
                    $_SESSION["edit_chapter_name"] = $value;
                    $found = 1;
                    $chapter_changed = 1;
                }
            }
            if ($edit_sequence_not_changed and $chapter_changed == 0) {edit_sequence_post();}
        }
    }
    elseif ($_SESSION["select_mode"] == "edit_color") {
        if ($_SESSION["select_mode"] == $_SESSION["last_mode"]){edit_color_post();}
    }
    elseif ($_SESSION["select_mode"] == "edit_language") {
        if ($_SESSION["select_mode"] == $_SESSION["last_mode"]) {edit_language_post();}
    }
    elseif ($_SESSION["select_mode"] == "edit_toks_to_ignore") {
        if ($_SESSION["select_mode"] == $_SESSION["last_mode"]) {edit_toks_to_ignore_post();}
    }
    if (!array_key_exists($_SESSION["device"], $_SESSION["command_len"])){create_command_len();}
    # automatic update tested, but not ok
    #     while (1){
    #       stop php
    #
    #       <script>
    #           console.clear();
    #            document.body.innerHTML = "";
    #        </script>
    # <?php
    # ob_start();
    ?>
    <div class = "flex-container"><div>
    <form id = "action" action="action.php" method="post">
    <?php
    echo "<input type='button' onclick='do_action()' value=".tr("send").">";
    echo "</div><div>";
    if($_SESSION["username"] != "user"){
        $_SESSION["edit_operate"]["store_permanent"] = "store_permanent";
    }
    else {
        if (array_key_exists("store_permanent", $_SESSION["edit_operate"])) {unset($_SESSION["edit_operate"]["store_permanent"]);}
    }
    array_selector("select_mode", $_SESSION["edit_operate"], $_SESSION["select_mode"]);
    echo "</div><div>";
    echo " " .tr("your_name") . ": ";
    # name will be used later to create user individual caches
    echo "<input type='text' name = 'user_name' size = 15 value=" . $_SESSION["username"] . ">";
    echo "</div><div>";
    echo tr("language") . ": ";
    array_selector("language", $_SESSION["languages"], $_SESSION["is_lang"]);
    echo "</div><div>";
    array_selector("device", $_SESSION["device_list"], $device);
    # create_basic_command();
    echo "</div>";
    if($_SESSION["select_mode"] == "operate") {
        # echo "</div><div>";
        if ($_SESSION["last_command_status"]){
            echo "<strong class = 'red'>".tr("last_command_nok")."</strong>";
        }
        else{
            echo "<strong class = 'green'>".tr("last_commnd_ok")."</strong>";
        }
        echo "<div>";
        display_chapter();
        echo "</div>";
        display_commands();
    }
    elseif($_SESSION["select_mode"] == "edit_sequence") {
        edit_sequence();
    }
    elseif($_SESSION["select_mode"] == "edit_color") {
        edit_color();
    }
    elseif($_SESSION["select_mode"] == "edit_language") {
        edit_language();
    }
    elseif($_SESSION["select_mode"] == "edit_toks_to_ignore") {
        edit_toks_to_ignore();
    }
    elseif($_SESSION["select_mode"] == "store_permanent") {
        store_permanent();
        echo "<div>";
        display_chapter();
        echo "</div>";
        display_commands();
    }
    $_SESSION["last_mode"] = $_SESSION["select_mode"];
    echo "</form>";
    echo"</div>";
# automatic update tested, but not ok
#         sleep(5);
#        ob_flush();
#    }
    ?>
    </body>
</html>

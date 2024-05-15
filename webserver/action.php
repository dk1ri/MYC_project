<?php
# action.php
# DK1RI 20240506
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
    include "user_data.php";
    include "create_new_device.php";
    include "split_to_display_objects.php";
    # must be included always (no simple check after loading device from file)
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
    $_SESSION["tok_to_send"] = [];
    $_SESSION["send_string_by_tok"] = [];
    $_SESSION["send_ok"] = 1;
    if (array_key_exists("language", $_POST) and $_POST["language"] != "") {
        $_SESSION["is_lang"] = $_POST["language"];
    }
    $new = 0;
    if (!$_SESSION["started"]) {
        $_SESSION["started"] = 1;
        $new = 1;
        # read data from device (may exist at 1st start)
        # send one command (usually there is one command only)
        receive_civ();
    }
    if (array_key_exists("device", $_POST) and $_POST["device"] != "") {
        if ($_SESSION["device"] != $_POST["device"]) {
            $new = 1;
            $_SESSION["device"] = $_POST["device"];
            # do nohting else
            $_POST = [];
            # in edit_sequence mode $_SESSION["new_sequencelist"] must be reset
            $_SESSION["chapter_for_edit_sequence"][$_SESSION["device"]]["all_basic"]  = "all_basic";
        }
    }
    $device = $_SESSION["device"];
    if ($new){create_new_device(1);}
    # username, language and device is never empty
    if (array_key_exists("user_name", $_POST) and $_POST["user_name"] != "") {
        $uname = checkusername($_POST["user_name"]);
        if ($uname != $_POST["user_name"]) {
            # load new user data
            read_user_data();
        }
    }
    if (array_key_exists("store_user_data", $_POST) and $_POST["store_user_data"] = 1) {
        write_user_data_to_file();
    }
    # the following are the basic functions used
    $operate_not_changed = 1;
    $edit_sequence_not_changed = 1;
    $edit_color_not_changed = 1;
    $edit_language_not_changed = 1;
    if (array_key_exists("_edit_operate_", $_POST)) {
        if ($_SESSION["_edit_operate_"] != $_POST["_edit_operate_"]) {
            # change of mode
            $_SESSION["_edit_operate_"] = $_POST["_edit_operate_"];
            if ($_SESSION["_edit_operate_"] == "operate") {
                $operate_not_changed = 0;
            }
            elseif ($_SESSION["_edit_operate_"] == "edit_sequence") {
                if ($_SESSION["chapter_for_edit_sequence"][$device] == []){$_SESSION["chapter_for_edit_sequence"][$device]["all_basic"] = "all_basic";}
                $edit_sequence_not_changed = 0;
            }
            elseif ($_SESSION["_edit_operate_"] == "edit_color") {
                $edit_color_not_changed = 0;
            }
            elseif ($_SESSION["_edit_operate_"] == "edit_language") {
                $edit_language_not_changed = 0;
            }
        }
    }
    if ($_SESSION["_edit_operate_"] == "operate") {
        $chapters = [];
        foreach ($_POST as $key => $value) {
            if (strstr($key, "chapter_")) {
                $chapters[] = explode("chapter_", $key)[1];
            }
        }
        if ($chapters != []) {
            $_SESSION["activ_chapters"][$device] = [];
            foreach ($chapters as $chap) {
                $ch = $_SESSION["chapter_names"][$device][$chap];
                $_SESSION["activ_chapters"][$device][$ch] = $ch;
            }
        }
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
        if ($operate_not_changed){correct_POST();}
    }
    elseif ($_SESSION["_edit_operate_"] == "edit_sequence") {
        $chapter_changed = 0;
        $found = 0;
        $_SESSION["chapter_for_edit_sequence"][$device] = [];
        foreach ($_POST as $key => $value) {
            if (!$found and strstr($key, "chapter_")) {
                $chapter_name = explode("chapter_", $key)[1];
                $_SESSION["chapter_for_edit_sequence"][$device][$chapter_name] = $chapter_name;
                $found = 1;
                $chapter_changed = 1;
            }
        }
        if ($_SESSION["chapter_for_edit_sequence"][$device] == []){$_SESSION["chapter_for_edit_sequence"][$device]["all_basic"] = "all_basic";}
        if ($edit_sequence_not_changed and $chapter_changed == 0) {edit_sequence_post();}
    }
    elseif ($_SESSION["_edit_operate_"] == "edit_color") {
        if($edit_color_not_changed) {edit_color_post();}
    }
    elseif ($_SESSION["_edit_operate_"] == "edit_language") {
        if ($edit_language_not_changed) {edit_language_post();}
    }
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
    array_selector("_edit_operate_", $_SESSION["edit_operate"], $_SESSION["_edit_operate_"]);
    echo "</div><div>";
    echo " " .tr("your_name") . ": ";
    # name will be used later to create user individual caches
    echo "<input type='text' name = 'user_name' size = 15 value=" . $_SESSION["username"] . ">";
    echo tr("store") . " <input type='checkbox' id='store_user_data' name= 'store_user_data' value=1>";
    echo "</div><div>";
    echo tr("language") . ": ";
    array_selector("language", $_SESSION["languages"], $_SESSION["is_lang"]);
    echo "</div><div>";
    array_selector("device", $_SESSION["device_list"], $device);
    echo "</div><div>";
    if ($_SESSION["last_command_status"]){
        echo "<strong class = 'red'>".tr("last_command_nok")."</strong>";
    }
    else{
        echo "<strong class = 'green'>".tr("last_commnd_ok")."</strong>";
    }
    echo "</div><div>";
    create_basic_command();
    echo "</div>";
    if($_SESSION["_edit_operate_"] == "operate") {
        display_chapter($_SESSION["activ_chapters"][$device]);
        display_commands();
    }
    elseif($_SESSION["_edit_operate_"] == "edit_sequence") {
        display_chapter($_SESSION["chapter_for_edit_sequence"][$device]);
        edit_sequence();
    }
    elseif($_SESSION["_edit_operate_"] == "edit_color") {
        edit_color();
    }
    elseif($_SESSION["_edit_operate_"] == "edit_language") {
        edit_language();
    }
    echo "</form>";
    echo"</div>";
# automatic update tested, but not o
#         sleep(5);
#        ob_flush();
#    }
    ?>
    </body>
</html>

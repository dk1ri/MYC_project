<?php
# action.php
# DK1RI 20241223
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
    <p id="myc"></p>
        <?php
        global $username, $language, $is_lang,$new_sequncelist, $device, $actual_data, $activ_chapters, $tok_list;
        include "subs.php";
        include "serial.php";
        include "select_includes.php";
        include "update_received.php";
        include "correct_POST.php";
        include "send_and_update.php";
        include "display_commands.php";
        include "select_any.php";
        include "edit_sequence.php";
        include "user_data.php";
        if ($_SESSION["conf"]["testmode"]){
            include "for_tests.php";
        }

        if (array_key_exists("user_name", $_POST) and $_POST["user_name"] != ""){$username = $_POST["user_name"];}
        # load user data
        read_user_data();
        if (array_key_exists("language", $_POST) and $_POST["language"] != "") {
            $is_lang = $_POST["language"];
            $language = $_SESSION["lang"][$is_lang];
        }
        if (array_key_exists("device", $_POST) and $_POST["device"] != "") {
            if (!array_key_exists($device, $_SESSION["announce_all"])) {
                $device = $_POST["device"];
                # create / read new device for $_SESSION, if not existing
                # not actually used devices are not deleted
                include "read_new_device.php";
                include "split_to_display_objects.php";
                read_new_device();
                create_active_chapters();
                if ($_SESSION["conf"]["testmode"]){
                 #   include "for_tests.php";
                    for_tests();
                }
                # nothing else to do:
                $_POST = [];
            }
        }
        # necessary includes
        select_includes();
        # at start (and if not edited) ->
        if ($new_sequncelist == []){$new_sequncelist = $_SESSION["chapter_token"][$device];}
        if (array_key_exists("_edit_operate_", $_POST)) {
            $_SESSION["_edit_operate_"] = $_POST["_edit_operate_"];
        }
        $_SESSION["read"] = 0;
        # select chapters to display (or edit)
        $chapters = [];
        foreach ($_POST as $key => $value){
            if (strstr($key,"chapter_")){
                $chapters[] =   explode("chapter_", $key)[1];
            }
        }
        if ($chapters != []){
            $_SESSION["activ_chapters"][$device] = [];
            foreach ($chapters as $chap){
                $activ_chapters = array_keys($_SESSION["chapter_names"][$device],$chap);
            }
            create_tok_list();
        }
        if ($tok_list == []){ create_tok_list();}
        # preparation done
        # the following are the basic functions used
        if ($_SESSION["_edit_operate_"] == "operate") {
            correct_POST();
        }
        elseif ($_SESSION["_edit_operate_"] == "edit_sequence"){
            edit_sequence_post();
        }
        # read data from device (may exist at 1st start)
        if (!$_SESSION["started"]) {
            $_SESSION["started"] = 1;
            receive_civ();
        }
        # send one command (usually there is one command only)
        $i = 0;
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
;       if ($_SESSION["read"]) {receive_civ();}
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
            echo "<input type='button' onclick='do_action()' value=".$language["send"].">";
            echo "</div><div>";
            echo $language["store"] . " <input type='checkbox' id='store_user_data' name= 'store_user_data' value=1>";
            echo "</div><div>";
            array_selector("_edit_operate_", $_SESSION["edit_operate"], $_SESSION["_edit_operate_"]);
            echo "</div><div>";
            echo " " .$language["your_name"] . ": ";
            # name will be used later to create user individual caches
            echo "<input type='text' name = 'user_name' size = 15 value=" . $username . ">";
            echo "</div><div>";
            echo $language["language"] . ": ";
            array_selector("language", $_SESSION["languages"], $is_lang);
            echo "</div><div>";
            array_selector("device", $_SESSION["device_list"], $device);
            echo "</div><div>";
            if ($_SESSION["last_command_status"]){
                echo "<strong class = 'red'>last command not ok</strong>";
            }
            else{
                echo "<strong class = 'green'>last command ok</strong>";
            }
            echo "</div><div>";
            create_basic_command(0);
            echo "</div><div>";
            $i = 0;
            foreach ($_SESSION["chapter_names"][$device] as $tok) {
                $tok_ = $_SESSION["chapter_names"][$device][$tok];
                echo "<td>";
                echo "<input type='checkbox' name=" . "chapter_".$tok_ . " id=" . "chapter_".$tok_ . ">";
                if (array_key_exists($tok,$activ_chapters)) {
                    echo "<strong class = 'green'>";
                } else {
                    echo "<strong class = 'red'>";
                }
                echo "<label for " .$tok . ">" . $_SESSION["chapter_names_with_space"][$device][$tok] . "</label></strong></td>";
                $i += 2;
            }
            echo "</div>";
            if($_SESSION["_edit_operate_"] == "operate") {
                display_commands();
            }
            elseif($_SESSION["_edit_operate_"] == "edit_sequence") {
                edit_sequence();
            }
            echo "</form>";
            echo"</div>";
    # automatic update tested, but not o
    #         sleep(5);
    #        ob_flush();
    #    }
            # in most cases some user data were modified: so they are stored to _SESSION always
            write_to_session();
        ?>
    </body>
</html>

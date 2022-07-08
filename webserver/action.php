<?php
function dec_hex($key, $len){
            $val = dechex($key);
            while (strlen($val) < $len){
                $val= "0".$val;
            }
            return $val;
        }

function calculate_len($number){
    $len = 2;
    if ($number > 16777215){
        $len = 8;
    } elseif ($number > 65535) {
        $len = 6;
    } elseif ($number > 255){
        $len = 4;
    }
    return $len;
}

function basic_tok($o_tok, $needle){
    $tok = $o_tok;
    if (array_key_exists($o_tok, $_SESSION["all_announce"][$_SESSION["device"]])) {
        if (strstr($o_tok, $needle) != false) {
            $tok = explode($needle, $o_tok)[0];
        }
    }
    return $tok;
}

function basic_tok_all($o_tok){
    $tok = $o_tok;
    if (array_key_exists($o_tok, $_SESSION["all_announce"][$_SESSION["device"]])) {
        if (strstr($o_tok, "_") != false) {
            $tok = explode("_", $o_tok)[0];
        }
        if (strstr($o_tok, "a") != false) {
            $tok = explode("a", $o_tok)[0];
        }
        if (strstr($o_tok, "p") != false) {
            $tok = explode("p", $o_tok)[0];
        }
    }
    return $tok;
}

function expand_comma($num){
    $conti = 1;
    while ($conti != 1){
        $num_f = floor($num);
        if ($num == $num_f) {
            $conti = 0;
        } else{
            $num *= 10;
        }
        $i += 1;
    }
    return $num;
}
?>

<html lang = "de">
    <head>
        <title>MYC Apache Server</title>
        <meta name="author" content="DK1RI">
        <meta http-equiv="refresh" content="1030">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            .flex-container {
                display: flex;
                flex-wrap: wrap;
                background-color: DodgerBlue;
            }

            .flex-container > div {
                background-color: #e1f1f1;
                margin: 5px;
                padding: 10px;
                font-size: 15px;
            }
        </style>
    </head>
    <body>
        <?php
        session_start();
        (array_key_exists("name", $_POST)) ? $name = htmlspecialchars($_POST['name']) : $name = "?";
        (array_key_exists("interface", $_POST)) ? $interface = htmlspecialchars($_POST['interface']) : $interface = "?";
        $_SESSION["interface"] = $interface;
        if (array_key_exists("devices", $_POST)) {
            $device = htmlspecialchars($_POST['devices']);
            $_SESSION["device"] = $device;
        }else{
            $device = $_SESSION["device"];
        }
        # create / read new device / chapter for $_SESSION, if not existing
        # not actually used devices are not deleted
        include "analyze_trx_data.php";
        if (array_key_exists($device, $_SESSION["announce_lines"]) == false) {
            include "read_new_device.php";
           read_new_device($device);
        }
        if (array_key_exists("chapter", $_POST) == true){
            $actual_chapter = $_POST['chapter'];
            $_SESSION["chapter"] = $actual_chapter;
        }else{
            $actual_chapter = $_SESSION["chapter"];
        }
        include "correct_POST.php";
        correct_POST($device);
        include "send_data.php";
        send_data();
        include "upddate_session_with_post.php";
        upddate_session_with_post();
        if ($_SESSION["read_data"] == 1){
            include "read_device_data.php";
            read_device_data();
            $_SESSION["read_data"] = 0;
        }
        # $_SESSION ready, create new page
        include "parse_commands.php";
        include "select_any.php";
        ?>
        <div class = "flex-container"><div>
        <form action="action.php" method="post">
        <input type="submit" />
        </div><div>
        Ihr Name: <input type="text" name='name' size = 14 value = <?php echo $name?>>
        </div><div>
        Interface: <input type="text" name = "interface" size = 14 name='name' value = <?php echo $name?>>
        </div><div>
        <?php
        select_any( $_SESSION["device_list"], $_SESSION["device"], "devices");
        echo ("</div><div>");
        select_any($_SESSION["chapter_names"][$device], $actual_chapter, "chapter");
        echo "</div><div>";
        parse_commands($_SESSION["device"], $actual_chapter);
        echo("</div>");
        echo "</form>";
        ?>
    </body>
</html>
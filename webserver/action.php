<?php
# action.php
# DK1RI 20230209
function basic_tok($o_tok){
    # return basic_token
    if (strstr($o_tok, "a")) {
        # for answer commands
        $tok = explode("a", $o_tok)[0];
    } elseif (strstr($o_tok, "b")) {
        # for stack
        $tok = explode("b", $o_tok)[0];
    } elseif (strstr($o_tok, "c")) {
        # for ADD
        $tok = explode("c", $o_tok)[0];
    } elseif (strstr($o_tok, "x")) {
        # for data
        $tok = explode("x", $o_tok)[0];
    } else {
        $tok = $o_tok;
    }
    return $tok;
}

function dec_hex($key, $len){
    $val = dechex((int)$key);
    $i = strlen($val);
    while ($i < $len){
        $val = "0".$val;
        $i += 1;
    }
    return $val;
}

function convert($num){
    if (strstr($num, ".")){
        return floatval($num);
    }
    else {
        return intval($num);
    }
}

function length_of_type($data){
    # no of bytes for transmit
    if (is_numeric($data)){
        $number = (int)$data;
        # length of binary number
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
    else {
        switch ($data) {
            case "a":
            case "b":
                return 2;
            case "i":
            case "w":
                return 4;
            case "e":
            case "L":
            case "s":
                return 8;
            case "d":
            case "t":
                return 16;
        }
    }
    # dummy
    return $data;
}

function display_length($type){
    # max length to display the ral value
    if (is_numeric($type)){
        # string
        return $type;
    }
    else {
        switch ($type) {
            case "a":
                return 1;
            case "b":
            case "f":
                return 3;
            case "c":
                return 4;
            case "w":
                return 5;
            case "i":
                return 6;
            case "s":
                return 8;
            case "L":
                return 10;
            case "e":
                return 11;
            case "d":
                return 18;
            default:
                return 2;
        }
    }
}

function find_allowed($type){
    switch ($type){
        case "a":
            return "0|1";
        case "b":
            return "0 to 255";
        case "c":
            return "-128 to 127";
        case "i":
            return "-32768 to 32767";
        case "w":
            return "0 to 65535";
        case "e":
            return "-2147483648 to 2147483647";
        case "L":
            return "0 to 4294967295";
        case "s":
            return "3 byte / 0 to 255";
        case "d":
            return "7byte / 0 to 255";
        default:
            return "";
    }
}

function find_name($type){
    switch ($type){
        case "a":
            return "bit";
        case "b":
            return "byte";
        case "c":
            return "signedshort";
        case "i":
            return "signed word";
        case "w":
            return "word";
        case "e":
            return "signed long";
        case "L":
            return "long";
        case "s":
            return "single";
        case "d":
            return "double";
        case is_numeric($type):
            return "alpha";
    }
    # dummy
    return $type;
}

function adapt_len($token, $element, $actual){
    $device =$_SESSION["device"];
    $result = "";
    $length = $_SESSION["property_len"][$device][basic_tok($token)][2];
    $i = strlen(strval($actual));
    if ($length > 20){
        $length = 20;
    }
    while ($i < $length){
        $result .= " ";
        $i += 1;
    }
    return $result.$actual;
}
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
                margin: 5px;
                padding: 10px;
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
        if (array_key_exists("devices", $_POST)) {
            # other device?
            $device = htmlspecialchars($_POST['devices']);
            $_SESSION["device"] = $device;
        }else{
            $device = $_SESSION["device"];
        }
        # create / read new device for $_SESSION, if not existing
        # not actually used devices are not deleted
        include  "translate.php";
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
        Ihr Name: <input type="text" name='name' size = 14 value = <?php echo $_SESSION["name"]?>>
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
        select_any( $_SESSION["device_list"], $_SESSION["device"], "devices");
        echo ("<br>");
        select_any($_SESSION["chapter_names"][$device], $actual_chapter, "chapter");
        echo "</div>";
        display_commands();
        echo "</form>";
        echo"</div>";
        ?>
    </body>
</html>
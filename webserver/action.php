<?php
# action.php
# DK1RI 20221118
function dec_hex($key, $len){
    $val = dechex($key);
    $i = strlen($val);
    if ($i < $len){
        $val = "0".$val;
        $i += 1;
    }
    return $val;
}


function calculate_len($number){
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

function basic_tok($o_tok){
    # return basic_token for _, a, p and o token
    if (strstr($o_tok, "_")) {
        $tok = explode("_", $o_tok)[0];
    } elseif (strstr($o_tok, "a")) {
        $tok = explode("a", $o_tok)[0];
    } elseif (strstr($o_tok, "p")) {
        $tok = explode("p", $o_tok)[0];
    } elseif (strstr($o_tok, "q")) {
        $tok = explode("q", $o_tok)[0];
    }  elseif (strstr($o_tok, "u")) {
        $tok = explode("u", $o_tok)[0];
    } else {
        $tok = $o_tok;
    }
    return $tok;
}

function expand_comma($num){
    # eliminate comma (one position after comma ?
    $conti = 1;
    $i = 0;
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

function create_session_data_file_val($device, $name, $data){
    $file = fopen("./".$device."/session_".$name, "w");
        fwrite( $file,$data."\n");
    fclose($file);
}

function create_session_data_file($device, $name, $data){
    $file = fopen("./".$device."/session_".$name, "w");
    foreach ($data as $key=> $value){
        fwrite( $file,$key." ".$value."\n");
    }
    fclose($file);
}

function create_session_data_file_array($device, $name, $data){
    # print($name);
    $file = fopen("./".$device."/session_".$name, "w");
    foreach ($data as $key=> $value){
        $line = $key;
        foreach ($value as $key_ => $val){
            $line = $line." ".$key_.": ".$val;
        }
        fwrite( $file,$line."\n");
    }
    fclose($file);
}
function create_session_data_file_array_array($device, $name, $data){
    # print($name);
    $file = fopen("./".$device."/session_".$name, "w");
    foreach ($data as $key=> $value){
        $line = $key."::subject: ";
        foreach ($value as $key_ => $valu){
            $line .= $key_."::element: ";
            foreach ($valu as $key__ => $val){
                $line .= $key__ . ":subelement: ";
                foreach ($val as $key___ => $va) {
                    $line .= $key___ . ":data ";
                    foreach ($va as $key____ => $d) {
                        $line .= $key____ . ": " . $d . " ";
                    }
                }
            }
        }
        fwrite( $file,$line."\n");
    }
    fclose($file);
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
                background-color: #6c9ccb;
            }

            .flex-container > div {
                background-color: #d1f1f1;
                margin: 5px;
                padding: 10px;
                font-size: 15px;
            }
        </style>
    </head>
    <body>
        <?php
        session_start();
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
        if (!array_key_exists($device, $_SESSION["all_announce"])) {
            include "read_new_device.php";
           read_new_device($device);
        }
        correct_POST($device);
        include "send_and_update.php";
        send_and_update();
        $actual_chapter = $_SESSION["chapter"];
        if ($_SESSION["read_data"] == 1){
            # not used now
            $_SESSION["read_data"] = 0;
        }
        # $_SESSION ready, create new page
        include "display_commands.php";
        include "create_commands.php";
        include "select_any.php";
        ?>
        <div class = "flex-container"><div>
        <form action="action.php" method="post">
        <input type="submit" />
        </div><div>
        Ihr Name: <input type="text" name='name' size = 14 value = <?php echo $_SESSION["name"]?>>
        </div><div>
        Interface: <input type="text" name = "interface" size = 14 name='name' value = <?php echo $_SESSION["interface"] ?>>
        </div><div>
        <?php
        select_any( $_SESSION["device_list"], $_SESSION["device"], "devices");
        echo ("</div><div>");
        select_any($_SESSION["chapter_names"][$device], $actual_chapter, "chapter");
        echo "</div>";
        display_commands($_SESSION["device"], $actual_chapter);
        echo "</form>";
        echo"</div>";
        ?>
    </body>
</html>
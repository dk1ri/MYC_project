<?php
function read_config() {
    $config = "_config";
    if (file_exists($config)) {
        $file = fopen($config, "r");
        $i = 0;
        while (!(feof($file))) {
            $line = fgets($file);
            if (strpos($line, "#") == false) {
                if (strpos($line, chr(13)) == true) {
                    # drop CR if existing
                    $line= (explode(chr(13), $line[$i]));
                    }
                switch ($i) {
                    case  1:
                        $_SESSION["other"]["config"][$i] = $line[$i];
                        break;
                    }
                }
            $i++;
            }
    }
    fclose($file);
}
?>

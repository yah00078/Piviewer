<?php
$version="1.4";
$intelvncpath="/usr/src/piviewer/intelvnc.sh";

function stateintel($REQUEST){

    if ($REQUEST == 'ip')
    {
    $answer = shell_exec(escapeshellcmd('sudo /usr/src/piviewer/intelvnc.sh --status ip'));
    echo $answer;
    }

    elseif ($REQUEST == 'port')
    {
    $answer = shell_exec(escapeshellcmd('sudo /usr/src/piviewer/intelvnc.sh --status port'));
        echo $answer;
        
    }

    else
    {
        echo "Unknown Parameters";
    }
}
?>

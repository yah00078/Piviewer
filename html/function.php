<?php

function macaddr()
{
    $ifconfig = exec('sudo ifconfig eth0 | awk \'/HWaddr/ {print $5}\'');
    return $ifconfig;
}


function ipaddr()
{
    $host = exec('sudo hostname -i');
    return $host;
}

?>

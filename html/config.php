<?php
$version="1.2.1";
$intelvncpath="/usr/src/piviewer/intelvnc.sh";

//Statut des informations écrites
//Status 0 -> On stoppe -> On détruit le fichier 
//Status 1 -> On start -> On créé le fichier
//Status 2 -> On interroge -> Pas daction
function write_state($targetip,$targetport,$status){
    $state_file = fopen("state.vnc","w+") or die ("Unable to open state file!");
    
    if ($status == 2) {

    
    }
    
    elseif ($status == 1) {
        $Data = "IP=" . $targetip . "\nPORT=" . $targetport ."\n";
        }
    
    elseif ($status == 0) {
        $Data = "IP=\nPORT=\n";
        }
        
        fwrite($state_file, $Data);
        fclose($state_file);
        return ($status);
    }


?>

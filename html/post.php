<html>
<head>
	<link rel="stylesheet" href="style/bootstrap.min.css">
	<title>Pi Viewer</title>
	<meta http-equiv="refresh" content="3;url=index.php">
</head>
<div class="text-center">
<?php

include 'config.php';

echo '<h1> PI Viewer '.$version.'</h1>';

$targetip=$_POST['targetip'];
$targetport=$_POST['targetport'];
$password=$_POST['password'];

//Doit on changer le mot de passe ?
if (!empty($password)) {
	shell_exec(escapeshellcmd('sudo /usr/src/piviewer/intelvnc.sh --update-password'.$password));
}

//Parsing de l'action sur le VNC 
if (isset($_POST['stop'])) {
	
	shell_exec(escapeshellcmd('sudo /usr/src/piviewer/intelvnc.sh --stop '.$targetip.':'.$targetport));	
	echo 'STOPPED';

}

elseif (!empty($targetip) && !empty($targetport) && !empty($_POST['viewonly'])) {	

	shell_exec(escapeshellcmd('sudo /usr/src/piviewer/intelvnc.sh --start-view '.$targetip.':'.$targetport));
	echo 'STARTED - TARGET:'.$targetip.':'.$targetport.'- VIEW-ONLY MODE';

}

elseif (!empty($targetip) && !empty($targetport)) {

	shell_exec(escapeshellcmd('sudo /usr/src/piviewer/intelvnc.sh --start '.$targetip.':'.$targetport));	
	echo 'STARTED - TARGET:'.$targetip.':'.$targetport.'- CONTROL MODE';

}

else {
	echo "You must enter an IP and a PORT";
}
?>
<br>
<form name="inscription" action="index.php"> 
<input type="submit" class="btn btn-info" value="OK"/>
</form>
</html>

<html>
<head>
	<link rel="stylesheet" href="style/bootstrap.min.css">
	<title>Pi Viewer</title>
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
	shell_exec(escapeshellcmd('sudo '.$intelvncpath '--update-password '.$password));
	echo 'PASSWORD CHANGED - ';
}

//Parsing de l'action sur le VNC 
if (isset($_POST['stop'])) {
	
	shell_exec(escapeshellcmd('sudo '.$intelvncpath ' --stop '.$targetip.':'.$targetport));
	call_user_func('write_state',$Data,'0');	
	echo 'STOPPED';

}

elseif (!empty($targetip) && !empty($targetport) && !empty($_POST['viewonly'])) {	

	shell_exec(escapeshellcmd('sudo '.$intelvncpath ' --start-view '.$targetip.':'.$targetport));
	call_user_func('write_state',$targetip,$targetport,'1');
	echo 'STARTED - TARGET:'.$targetip.':'.$targetport.'- VIEW-ONLY MODE';

}

elseif (!empty($targetip) && !empty($targetport)) {

	shell_exec(escapeshellcmd('sudo '.$intelvncpath ' --start '.$targetip.':'.$targetport));
	call_user_func('write_state',$targetip,$targetport,'1');	
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

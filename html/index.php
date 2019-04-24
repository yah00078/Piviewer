<html>
    <head>
	<link rel="stylesheet" href="style/bootstrap.min.css">
	<title>Pi Viewer</title>
	<?php
		include 'config.php' ;


        if(isset($_POST['valider'])){
        	$targetip=$_POST['targetip'];
	   		$targerport=$_POST['targetport'];
	    	$viewonly=$_POST['viewonly'];
			$stop=$_POST['stop'];
			$password=$_POST['password'];
        }
        ?>
	
    </head>
    <body>
	<div class="text-center"> 
			<h1>PI Viewer 1.2 </h1>
        	Entrez l'adresse IP et le PORT du serveur VNC

	<form name="inscription" method="post" action="post.php">
		<table border="0" align="center">
		<tr>
			<th>IP du Serveur</th>

		</tr>
		<tr>
			<td><input type="text" name="targetip" size="15" value=<?php stateintel('ip');?>/></td>
		</tr>
		<tr>
			<th>Port (Default:5900)</th>

		</tr>
		<tr>
			<td><input type="text" name="targetport" size="15" value=<?php stateintel('port');?>/></td>
		</tr>
		<tr>
			<th>Password</th>

		</tr>
		<tr>
			<td><input type="password" name="password" size="15" Value=""/></td>
		</tr>
		</table><br>
		<input type="checkbox" name="viewonly" value="true"/>View-Only Mode <br><br>
		<input type="submit" class="btn btn-info"  name="valider" value="OK"/>
		<input type="submit" class="btn btn-info"  name="relaunch" value="Re-launch"/>
		<input type="submit" class="btn btn-info"  name="stop" value="STOP"/>
	</form>
	</div>
    </body>
</html> 

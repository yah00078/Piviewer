#!/bin/bash


#----------------------
#On demande le démarrage de VNC avec controle
function start-vnc {
TARGET=$1
echo -e "\033[34m VNC Start TARGET:$1 ***CONTROL MODE*** \033[0m"
xinit /usr/bin/vncviewer $TARGET -shared -passwordfile /root/vnc.pass -qualitylevel 9 -compresslevel 6 >/dev/null 2>&1 &
echo -e "\033[34m VNC Started ! \033[0m"
exit 0
}


#----------------------
#On demande le démarrage de VNC en mode VIEW-ONLY
function start-vnc-view {
TARGET=$1
echo -e "\033[34m VNC Start TARGET:$1 ***VIEW-ONLY MODE*** \033[0m"
xinit /usr/bin/vncviewer $TARGET -viewonly -shared -passwordfile /root/vnc.pass -qualitylevel 9 -compresslevel 6  >/dev/null 2>&1 &
echo -e "\033[34m VNC Started ! \033[0m"
exit 0
}


#----------------------
# On demande l'arret de XINIT/VNC 
function stop-vnc {
xinitprocesspid=$1
echo -e "\033[32m Kill Gracefully PID: $xinitprocess ... \033[0m"
kill -HUP $xinitprocesspid
sleep 3
echo -e "\033[32m Killed PID: $xinitprocesspid \033[0m"
return 0
}


#-----------------------
#On verifie si un process tourne déja.
function check_xinitprocess {
	xinitprocess=$(pgrep -x "xinit")
if [ -n "$xinitprocess" ]; then

	echo -e "\033[31m ! Xinit Process Found PID:$xinitprocess !\033[0m"
	stop-vnc $xinitprocess
else
return 0
fi
}

function update_password {
password=$1	
echo $password | /usr/bin/vncpasswd -f > /root/vnc.pass
echo -e "\033[31m ! Password Changed !\033[0m"

}


#Parsing des valeures reçues: --start --stop --start-view --update-password
optspec=":-:"
while getopts "$optspec" optchar; do
	case "${OPTARG}" in
		   start)
			   value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
			 check_xinitprocess
			 start-vnc $value
			 exit 0
	             ;;
		
		     stop)
			   value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
		           check_xinitprocess
				   exit 0
			     ;;

			update-password)
				   value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
		           update_password $value
				   exit 0
			     ;;
			
		    start-view)
			  value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
			  check_xinitprocess
			  start-vnc-view $value
			    exit 0
		      ;;
	    esac
done

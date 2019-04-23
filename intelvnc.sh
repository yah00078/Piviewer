#!/bin/bash


#Gestion REDIS local uniquement
function read_redis {
KEY=$1
redis-cli GET $KEY 
}

function set_redis {
KEY=$1
VALUE=$2
redis-cli SET $KEY $VALUE
}

function del_redis {
KEY=$1
redis-cli del $KEY
}
#----------------------

#On demande le dÃ©marrage de VNC avec controle
function start-vnc {
TARGET=$1
echo -e "\033[34m VNC Start TARGET:$1 ***CONTROL MODE*** \033[0m"
xinit /usr/bin/vncviewer $TARGET -shared -passwordfile /root/vnc.pass -qualitylevel 9 -compresslevel 6 >/dev/null 2>&1 &
set_redis STATUS 1
set_redis TARGETIP $TARGET
set_redis TARGETPORT $TARGET
set_redis VIEW-ONLY 0
set_redis VNCPROCESS $(pgrep -x "xinit")
echo -e "\033[34m VNC Started ! \033[0m"
exit 0
}


#----------------------
#On demande le dÃ©marrage de VNC en mode VIEW-ONLY
function start-vnc-view {
TARGET=$1
echo -e "\033[34m VNC Start TARGET:$1 ***VIEW-ONLY MODE*** \033[0m"
xinit /usr/bin/vncviewer $TARGET -viewonly -shared -passwordfile /root/vnc.pass -qualitylevel 9 -compresslevel 6  >/dev/null 2>&1 &
set_redis STATUS 1
set_redis TARGETIP $TARGET
set_redis TARGETPORT $TARGET
set_redis VIEW-ONLY 1
set_redis VNCPROCESS $(pgrep -x "xinit")
echo -e "\033[34m VNC Started ! \033[0m"
exit 0
}


#----------------------
# On demande l'arret de XINIT/VNC 
function stop-vnc {
xinitprocesspid=$1
echo -e "\033[32m Kill Gracefully PID: $xinitprocess ... \033[0m"
kill -HUP $xinitprocesspid
set_redis STATUS 0
del_redis TARGETIP
del_redis TARGETPORT
del_redis VNCPROCESS
del_redis VIEW-ONLY
sleep 3
echo -e "\033[32m Killed PID: $xinitprocesspid \033[0m"
return 0
}


#-----------------------
#On verifie si un process tourne dÃ©ja.
function kill_xinitprocess {
	xinitprocess=$(pgrep -x "xinit")
if [ -n "$xinitprocess" ]; then

	echo -e "\033[31m ! Xinit Process Found PID:$xinitprocess !\033[0m"
	stop-vnc $xinitprocess
else
return 0
fi
}

function watchdog {
	xinitprocess=$(pgrep -x "xinit")
	TARGETIP=$(read_redis TARGET)
	STATUS=$(read_redis STATUS)

	
	
	# On vérifie si il devrait y avoir un viewer en marche
if [ $STATUS -eq 1 ]; then

	# On Vérifie si un process tourne
	if [ -n "$xinitprocess" ]; then
		echo -e "\033[32m Xinit Process Found PID:$xinitprocess \033[0m"
			
			#Si on trouve le process on vérifie que $TARGET ping
			if ping -c1 $TARGETIP 1>/dev/null 2>/dev/null 
			then
				#Si ca ping on sort en succès
				echo -e "\033[32m $TARGETIP ping -> OK \033[0m"
				echo -e "\033[36m *** Watchdog end *** \033[0m"
				return 0
			else
				#Si ca ne ping pas on coupe le VNC via le xinit
				echo -e "\033[31m $TARGETIP ping -> KO \033[0m"
				echo -e "\033[31m STOP VNC \033[0m"
				kill_xinitprocess
				echo -e "\033[36m *** Watchdog end *** \033[0m"
				return 1
			fi
	
	else
		echo -e "\033[36m No Xinit Process Found\033[0m"
		#Ajouter actions de recorvery
		echo -e "\033[36m *** Watchdog end *** \033[0m"
		return 0
	fi

else
echo -e "\033[36m No Check needed \033[0m"
echo -e "\033[36m *** Watchdog end *** \033[0m"
fi
}

function update_password {
password=$1	
echo $password | /usr/bin/vncpasswd -f > /root/vnc.pass
echo -e "\033[31m ! Password Changed !\033[0m"

}


#Parsing des valeures: --start --stop --start-view --update-password --watchdog
optspec=":-:"
while getopts "$optspec" optchar; do
	case "${OPTARG}" in
		   start)
			   value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
			 kill_xinitprocess
			 start-vnc $value
			 exit 0
	             ;;
		
		     stop)
			   value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
		           kill_xinitprocess
				   exit 0
			     ;;

			update-password)
				   value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
		           update_password $value
				   exit 0
			     ;;
			
		    start-view)
			  value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
			  kill_xinitprocess
			  start-vnc-view $value
			    exit 0
		        ;;
				
			watchdog)
			  value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
				watchdog
			    exit 0
		        ;;
	    esac
done

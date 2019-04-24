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
#----------------------------------------------------------


#On demande le démarrage de VNC -> controle ou view only
function start-vnc {
TARGET=$1
VIEWONLY=$2
TARGETIP=$(awk -F: '{sub(/.*[[:blank:]]/, "", $1); print $1}' <<< "$TARGET")
TARGETPORT=$(awk -F: '{sub(/.*[[:blank:]]/, "", $1); print $2}' <<< "$TARGET")

if [ $VIEWONLY -eq 0 ]; then
echo -e "\033[34m VNC Start TARGET: $TARGETIP:$TARGETPORT ***CONTROL MODE*** \033[0m"
xinit /usr/bin/vncviewer $TARGETIP:$TARGETPORT -shared -passwordfile /root/vnc.pass -qualitylevel 9 -compresslevel 6 >/dev/null 2>&1 &
set_redis VIEW-ONLY 0

else
echo -e "\033[36m VNC Start TARGET: $TARGETIP:$TARGETPORT ***VIEW-ONLY MODE*** \033[0m"
xinit /usr/bin/vncviewer $TARGETIP:$TARGETPORT -viewonly -shared -passwordfile /root/vnc.pass -qualitylevel 9 -compresslevel 6  >/dev/null 2>&1 &
set_redis VIEW-ONLY 1
fi

set_redis STATUS 1 
set_redis TARGETIP $TARGETIP 
set_redis TARGETPORT $TARGETPORT 
set_redis VNCPROCESS $(pgrep -x "xinit")
echo -e "\033[34m VNC Started ! \033[0m"
exit 0
}
#----------------------------------------------------------


# On demande l'arret de XINIT/VNC 
function stop-vnc {
	let "retry++"
	xinitprocess=$(pgrep -x "xinit")
	if [ -n "$xinitprocess" ]; then
		echo -e "\033[36m ! Xinit Process Found PID:$xinitprocess !\033[0m"
		echo -e "\033[32m Kill Gracefully PID: $xinitprocess ... \033[0m"
		kill -HUP $xinitprocess
		sleep 1
	
	
		#Check sur le process est bien supprimé avant d'update la base
		xinitprocess=$(pgrep -x "xinit")
	
			if [ -z "$xinitprocess" ]; then
				ERROR=$(read_redis PING_ERROR)
				echo Ping error =>$ERROR
			
					#Si le process a été supprimé a cause d'un souci externe, on garde en base				
					if [ $ERROR -eq 1 ]; then
					del_redis VNCPROCESS

					#Si non on clean toutes les valeurs et on passe le status a 0
					else
					set_redis STATUS 0 
					del_redis TARGETIP 
					del_redis TARGETPORT 
					del_redis VNCPROCESS 
					del_redis VIEW-ONLY 
					echo -e "\033[32m PID Killed \033[0m"
					return 0
					fi

			#Si il est toujours la Retry jusqu'a 10
			elif [ $retry -lt 10 ]; then
			echo -e "\033[31m PID Not Killed PID: $xinitprocess, Retry $retry \033[0m"
			stop-vnc

			# Si après 10 toujours la, erreur
			else
			echo -e "\033[31m ERROR: Can't Kill PID: $xinitprocess \033[0m"
			return 2
			fi

	else
	# AJOUTER CHECK STATUS REDIS
		echo -e "\033[32m No Xinit Process Found \033[0m"
	return 0
	fi
}
#----------------------------------------------------------

function watchdog {
	xinitprocess=$(pgrep -x "xinit")
	TARGETIP=$(read_redis TARGETIP)
	STATUS=$(read_redis STATUS)	
	
	# On verifie si il devrait y avoir un viewer en marche
if [ $STATUS -eq 1 ]; then

	# On Verifie si un process tourne
	if [ -n "$xinitprocess" ]; then
		echo -e "\033[32m Xinit Process Found PID:$xinitprocess \033[0m"
			
			#Si on trouve le process on verifie que $TARGET ping
			if ping -c1 $TARGETIP > /dev/null 2>&1
			then
				#Si ca ping on sort en succes
				echo -e "\033[32m $TARGETIP ping -> OK \033[0m"
				echo -e "\033[36m *** Watchdog end *** \033[0m"
				return 0
			else
				#Si ca ne ping pas on sort en erreur (il n'y a pas de solution possible côté client)
				echo -e "\033[31m $TARGETIP ping -> KO \033[0m"
				echo -e "\033[31m WAIT FOR PING BACK OK \033[0m"
				set_redis PING_ERROR 1
				stop-vnc
				echo -e "\033[36m *** Watchdog end *** \033[0m"
				return 1
			fi
	
	else
		#Si pas de process c'est qu'il a été kill ou a crash. On verifie alors si ca ping et si oui on restart et clean des erreurs log
			if ping -c1 $TARGETIP > /dev/null 2>&1
			then
			TARGETPORT=$(read_redis TARGETPORT)
			VIEWONLY=$(read_redis VIEW-ONLY)

			echo -e "\033[36m No Xinit Process Found\033[0m"
			echo -e "\033[31m RESTARTING TO $TARGETIP:$TARGETPORT VIEWONLY: $VIEWONLY \033[0m"
			# On enleve les erreurs ping precedentes
			del_redis PING_ERROR
			sleep 1
			start-vnc $TARGETIP:$TARGETPORT $VIEWONLY
			echo -e "\033[36m *** Watchdog end *** \033[0m"
			return 0

			else
			echo -e "\033[31m $TARGETIP doesn't ping for the moment \033[0m"
			echo -e "\033[36m *** Watchdog end *** \033[0m"	
			return 1
			fi
	fi

else
echo -e "\033[36m No running operations (Status=> $STATUS) -> No Check needed \033[0m"
echo -e "\033[36m *** Watchdog end *** \033[0m"
fi
}

function update_password {
password=$1	
echo $password | /usr/bin/vncpasswd -f > /root/vnc.pass
echo -e "\033[31m ! Password Changed !\033[0m"

}
#----------------------------------------------------------


#Parsing des valeures: --start --stop --start-view --update-password --watchdog
optspec=":-:"
while getopts "$optspec" optchar; do
	case "${OPTARG}" in
		   start)
			   value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
			 stop-vnc
			 start-vnc $value 0
			 exit 0
	             ;;
		
		     stop)
			   value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
		           stop-vnc
				   exit 0
			     ;;

			update-password)
				   value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
		           update_password $value
				   exit 0
			     ;;
			
		    start-view)
			  value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
			  stop-vnc
			  start-vnc $value 1
			    exit 0
		        ;;
				
			watchdog)
			  value="${!OPTIND}" OPTIND=$(( $OPTIND + 1 ))
				watchdog
			    exit 0
		        ;;
	    esac
done
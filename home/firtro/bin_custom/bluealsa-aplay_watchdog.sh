#!/bin/bash

# Un watchdog para arrancar bluealsa-aplay y vigilar que funcione

# Configuración:
alsaDevice=jack
loop_timer=15


# 0. Define un nombre para el archivo de log de reinicios de 'bluealsa-aplay'
flog=$(echo $(basename $0) | cut -d"." -f1)".log"

# función para arrancar 'bluealsa-aplay':
function arranca_bluealsa-aplay {
    echo  "("$(basename $0)") Arrancando bluealsa-aplay ..."
    pkill -f -KILL "bluealsa-aplay -d jack"   # > /dev/null
    sleep .5
    bluealsa-aplay -d jack 00:00:00:00:00:00 &
}

# 1. Detecta si hubiera otro librespot_watchdog.sh previo y lo mata antes de seguir
# cuenta los que hubiera; '-f' busca en todo el nombre de los procesos, '-c' devuelve la cuenta.
cuentawd=$(pgrep -fc bluealsa-aplay_watchdog.sh)
if (( $cuentawd  > 1 ));then
    echo ""
    # '-a' devuelve los #pid y el #nombre_completo del proceso que usaremos a título informativo
    readarray array <<< $(pgrep -fa bluealsa-aplay_watchdog.sh)
    # recorremos los procesos excepto el último que es este mismo.
    len=${#array[@]}
    len=$(( $len - 1 ))
    for cosa in "${array[@]:0:$len}"; do
        if [[ $cosa == *"bluealsa-aplay_watchdog"* ]]; then
            pid=$(cut -d" " -f1 <<< $cosa)
            echo "(i) finalizando "$cosa
            kill -KILL $pid
            sleep 1
        fi
    done
fi

# 2. Primer arranque:
arranca_bluealsa-aplay

# 3. Loop de watchdog:
reintentos=0
while true; do
    estavivo=$(pgrep -fc "bluealsa-aplay\ \-d\ jack")

    if [[ $estavivo != 0 ]]; then
        #echo "("$(basename $0)") bluealsa-aplay en ejecución"
        :
    else
        echo "("$(basename $0)") bluealsa-aplay no detectado, reiniciando ..."
        arranca_bluealsa-aplay
        ((reintentos+=1))
        echo $reintentos
        echo $(date) >> $flog

    fi

    # Si son necesarios muchos reinicios suele ser un bug con la red,
    # no queda otro remedio que reinicar la maquina :-/
    if (( $reintentos > 5 )); then
        echo "("$(basename $0)") ¡¡¡Reiniciando la máquina!!!"
        sleep 1
        sudo reboot &
        exit 0
    fi

    sleep $loop_timer
done

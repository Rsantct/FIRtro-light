#!/bin/bash

#
# Cutre watchdog para arrancar librespot y vigilar que funcione
#
alsaDevice=jack
loop_timer=15
#
bitrate=160
# 96 (low quality), 160 (default quality), or 320 (high quality)
# OjO bitrate 320 puede ser excesiva carga de CPU
# Bitrate opcional por command line:
brvalid=(96 160 320)
if [[ $1 ]]; then
    bitrate=$1
    if [[ " ${brvalid[*]} " != *"$bitrate"* ]]; then
        echo "bitrate debe ser 90|160|320"
        exit -1
    fi
fi

### Detecta si hubiera otro librespot_watchdog.sh previo y lo mata antes de seguir
# cuenta los que hubiera
cuentawd=$(pgrep -fc librespot_watchdog)
if (( $cuentawd  > 1 ));then
    echo ""
    readarray array <<< $(pgrep -fl librespot_watchdog.sh)
    # recorremos los procesos excepto el último que es este mismo.
    len=${#array[@]}
    len=$(( $len - 1 ))
    for cosa in "${array[@]:0:$len}"; do
        if [[ $cosa == *"librespot_watch"* ]]; then
            pid=$(cut -d" " -f1 <<< $cosa)
            echo "(i) finalizando "$cosa
            kill -KILL $pid
            sleep 1
        fi
    done
fi

# Archivo de log de reinicios de 'librespot'
flog=$(echo $(basename $0) | cut -d"." -f1)".log"

# función para arrancar librespot:
function arranca_librespot {
    echo  "("$(basename $0)") Arrancando librespot ..."
    pkill -f -KILL "bin/librespot"   # > /dev/null
    sleep .5
    /usr/bin/librespot --name $(hostname) --backend alsa --device $alsaDevice --bitrate $bitrate \
                       --disable-audio-cache &
}

# Primer arranque:
arranca_librespot

# Loop de watchdog:
reintentos=0
while true; do
    estavivo=$(pgrep -fc "librespot\ \-\-name\ $(hostname)")

    if [[ $estavivo != 0 ]]; then
        #echo "("$(basename $0)") librespot en ejecución"
        :
    else
        echo "("$(basename $0)") librespot no detectado, reiniciando ..."
        arranca_librespot
        ((reintentos+=1))
        echo $reintentos
        echo $(date) >> $flog

    fi

    # Si son necesarios muchos reinicios suele ser un bug
    if (( $reintentos > 3 )); then
        echo "("$(basename $0)") ¡¡¡Demasiados reinicios de librespot, se aconseja actualizarlo desde github!!!"
        sleep 1
        #sudo reboot &
        #exit 0
    fi

    sleep $loop_timer
done

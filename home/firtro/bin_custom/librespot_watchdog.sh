#!/bin/bash

#
# Cutre watchdog para arrancar librespot y vigilar que funcione
#
alsaDevice=jack
bitrate=160
loop_timer=15
#
# OjO bitrate 320 consume demasiados recursos para RPI + Brutefir
# 96 (low quality), 160 (default quality), or 320 (high quality)
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

# Arranca librespot:
echo  "("$(basename $0)") Arrancando librespot ..."
pkill -f -KILL "bin/librespot"   # > /dev/null
/usr/bin/librespot --name $(hostname) --backend alsa --device $alsaDevice --bitrate $bitrate \
                   --disable-audio-cache &

# Loop de watchdog:
reintentos=0
while true; do
    estavivo=$(pgrep -fc "\-\-name\ $(hostname)")

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

    # Si son necesarios muchos reinicios suele ser un bug con la red,
    # no queda otro remedio que reinicar la maquina :-/
    if (( $reintentos > 3 )); then
        echo "("$(basename $0)") ¡¡¡Reiniciando la máquina!!!"
        sleep 1
        sudo reboot &
        exit 0
    fi

    sleep $loop_timer
done

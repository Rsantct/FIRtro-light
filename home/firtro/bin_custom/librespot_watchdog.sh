#!/bin/bash

#
# Cutre watchdog para arrancar librespot y vigilar que funcione
#
alsaDevice=jack
bitrate=160
loop_timer=15
#
# OjO bitrate 320 creo que consume demasiados recursos para RPI1
# 96 (low quality), 160 (default quality), or 320 (high quality)
# Bitrate opcional por command line:
if [[ $1 ]]; then
    bitrate=$1
fi


function arranca_librespot () {
    echo  "("$(basename $0)") Arrancando librespot ..."
    pkill -f -KILL "bin/librespot"   # > /dev/null
    /usr/bin/librespot --name $(hostname) --backend alsa --device $alsaDevice --bitrate $bitrate \
                             --disable-audio-cache &
}

# Archivo de log de reinicios de 'librespot'
flog=$(echo $(basename $0) | cut -d"." -f1)".log"

# Arranca librespot:
arranca_librespot

# Loop de watchdog:
reintentos=0

while true; do
    estavivo=$(pgrep -fc "\-\-name\ $(hostname)")

    if [[ $estavivo != 0 ]]; then
        echo "("$(basename $0)") librespot en ejecución"

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

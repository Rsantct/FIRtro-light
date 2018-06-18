#!/bin/bash

#
# Cutre watchdog para arrancar librespot y vigilar que funcione
#
# v1.1
#   Se añade un volumen inicial para evitar que arranque al 50%
#   Se deja de reiniciar la máquina en caso de que este script renicie librespot
#   Se deja bitrate 320 por defecto

# Uso de librespot: 
# Usage: /usr/bin/librespot [options]
# 
# Options:
#     -c, --cache CACHE   Path to a directory where files will be cached.
#         --disable-audio-cache 
#                         Disable caching of the audio data.
#     -n, --name NAME     Device name
#         --device-type DEVICE_TYPE
#                         Displayed device type
#     -b, --bitrate BITRATE
#                         Bitrate (96, 160 or 320). Defaults to 160
#         --onevent PROGRAM
#                         Run PROGRAM when playback is about to begin.
#     -v, --verbose       Enable verbose output
#     -u, --username USERNAME
#                         Username to sign in with
#     -p, --password PASSWORD
#                         Password
#         --proxy PROXY   HTTP proxy to use when connecting
#         --disable-discovery 
#                         Disable discovery mode
#         --backend BACKEND
#                         Audio backend to use. Use '?' to list options
#         --device DEVICE Audio device to use. Use '?' to list options if using
#                         portaudio
#         --mixer MIXER   Mixer to use
#         --initial-volume VOLUME
#                         Initial volume in %, once connected (must be from 0 to
#                         100)
#         --zeroconf-port ZEROCONF_PORT
#                         The port the internal server advertised over zeroconf
#                         uses.
#         --enable-volume-normalisation 
#                         Play all tracks at the same volume
#         --normalisation-pregain PREGAIN
#                         Pregain (dB) applied by volume normalisation
#         --linear-volume 
#                         increase volume linear instead of logarithmic.


#//// nuestra CONFIGURACION:
#backend=pulseaudio # OjO dtcooper/raspotify NO está compilado con el backend pulseaudio
backend=alsa
alsaDevice=jack
loop_timer=15
#\\\\

# El bitrate se puede sobreescribir añadiéndolo $1 a la linea de comando de este script
bitrate=320
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

# Función para arrancar librespot.
# Ejemplo de comando como es arrancado por defecto por el servicio estandar:
# /usr/bin/librespot --name raspotify (rpi3halcon) --backend alsa --bitrate 160 \
#                    --disable-audio-cache --enable-volume-normalisation --linear-volume --initial-volume=100
function arranca_librespot {
    echo  "("$(basename $0)") Arrancando librespot ..."
    pkill -f -KILL "bin/librespot"   # > /dev/null
    sleep .5
    beOpts='--backend '$backend' '
    if [[ $beOpts == *"alsa"* ]]; then
        beOpts+=" --device "$alsaDevice
    fi
    /usr/bin/librespot --name $(hostname) --bitrate $bitrate $beOpts \
                       --disable-audio-cache --initial-volume=99 &

    # NOTA: usamos vol=99 pq 100 da un warning a pesar de que no hemos habilitado la normalizacion ¿?:
    #         WARN:librespot_playback::player: Reducing normalisation factor to prevent clipping.
    #              Please add negative pregain to avoid.
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

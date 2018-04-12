#!/bin/bash

# v0.1beta
# Cutre script para que Ecasound haga de pote de volumen en Jack
#
# Su uso está pensado para tarjetas de sonido con poca sensibilidad en la
# entrada analógica, como es el caso de la tarjeta I2S 'audioinjector' para RPI
#
# La ganancia es la indicada en el arranque del script.
#
# 
# TODO:
#   Hablar con esta instancia de Ecasound para cambiar la ganancia al vuelo
#   sería de utilidad para pruebas de nivel.

####################### CONFIGURACION ######################
# Nombre en Jack de los puertos de esta instancia Ecasound.
# (!) Estos serán los puertos a configurar en audio/inputs 
#     de FIRtro para la entrada analógica.
jackName="capture_gain"
#
# Puertos capture a los que Ecasound se conecatará:
jackAnalogInput="system"
#
# Nota: usamos Ecasound escuchando en el puerto tcp 12868 porque 
#       el default port 2868 es usado por el PEQ de FIRtro.
tcp_port=12868
#
# Ganancia por defecto
gaindB="+3.0"
#
# Tiempo de espera en segundos a que Jack esté disponible
tJack=10
############################################################


# Leemos la Gain dB que aplicaremos, por defecto 3.0 dB
if [ $1 ]; then
    gaindB=$1
fi

# Esperamos hasta 10 segundos a que se este ejecutando JACK
c=0
jackIsRunning=false
echo "(i) esperando a Jack en "$tJack" seg ..."
while (( c <= $tJack )); do
    tmp=$(jack_lsp 2>/dev/null)
    if [[ $tmp == *"playback"* ]]; then
        echo "(i) Jack funcionando"
        jackIsRunning=true
        break
    fi
    sleep 1
    (( c++ ))
    echo "."
done
if [[ $jackIsRunning = "false" ]]; then
    echo "(i) Jack NO funciona, se CANCELA capture_gain.sh"
    exit 0
fi

# Si hemos llegado aquí es que Jack está disponible,
# matamos si hubiera otro ecasound haciendo lo mismo.
pkill -KILL -f 'jack,'$jackAnalogInput
sleep .5

# Averiguamos los puertos de entrada a FIRtro
FIRtroUsaEcasound=$(grep load_ecasound /home/firtro/audio/config | grep -v ";" | cut -d"=" -f2)
if [[ $FIRtroUsaEcasound == *"False"* ]]; then
    FIRtroPorts=brutefir
else
    FIRtroPorts=ecasound
fi

# Lanzamos Ecasound
ecasound    -q --server --server-tcp-port=$tcp_port \
            -G:jack,$jackName,notransport \
            -i:jack,$jackAnalogInput -o:jack,$FIRtroPorts \
            -eadb:$gaindB &

# Info:
echo "(i) Ejecutando 'capture_gain.sh', Gain = "$gaindB
echo "    Los puertos disponibles en jack son '"$jackName":out_x'"

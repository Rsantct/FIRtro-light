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


# Gain dB que aplicaremos
gaindB="+0.0"
if [ $1 ]; then
    gaindB=$1
fi

# matamos si hubiera otro ecasound haciendo lo mismo
pkill -KILL -f analog_lev_adj
sleep .5

# Esperamos hasta 10 segundos a que se este ejecutando JACK
c=0
jackIsRunning=false
echo "(i) esperando a Jack en 5 seg ..."
while (( c <= 5 )); do
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
    echo "(i) Jack NO funciona, se CANCELA capture_level_adj.sh"
    exit 0
fi

# Nombre visible en JACK:
jackName="analog_lev_adj"

# Puertos capture a los que nos conectamos:
jackAnalogInput="system"

# Puertos de entrada a FIRtro
FIRtroUsaEcasound=$(grep load_ecasound /home/firtro/audio/config | grep -v ";" | cut -d"=" -f2)
if [[ $FIRtroUsaEcasound == *"False"* ]]; then
    FIRtroPorts=brutefir
else
    FIRtroPorts=ecasound
fi

echo "(i) EJECUTANDO capture_level_adj.sh con ganancia: "$gaindB
echo "    Los puertos disponibles en jack son:          "$jackName":out_x"
# TCP port used by the daemon mode, by default 2868
# Usamos el puerto 12868
ecasound    -q --server --server-tcp-port=12868 \
            -G:jack,$jackName,notransport \
            -i:jack,$jackAnalogInput -o:jack,$FIRtroPorts \
            -eadb:$gaindB &

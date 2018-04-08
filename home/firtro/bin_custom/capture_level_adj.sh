#!/bin/bash

# v0.1beta
# Cutre script para que Ecasound haga de pote de volumen en Jack


killall ecasound
sleep .5

# Gain dB que aplicaremos
gaindB="+10.0"

# Nombre visible en JACK:
jackName="analog_lev_adj"

# Puertos capture a los que nos conectamos:
jackAnalogInput="system"

# Puertos de entrada a FIRtro
FIRtroUsaEcasound=$(grep load_ecasound audio/config | grep -v ";" | cut -d"=" -f2)
if [[ $FIRtroUsaEcasound == *"False"* ]]; then
    FIRtroPorts=brutefir
else
    FIRtroPorts=ecasound
fi

# TCP port used by the daemon mode, by default 2868
ecasound    -q --server --server-tcp-port=62868 \
            -G:jack,$jackName,notransport \
            -i:jack,$jackAnalogInput -o:jack,$FIRtroPorts \
            -eadb:$gaindB &



#!/bin/bash

# Audioinjector I2S sound card
#
# Se ha observado una sensibilidad escasa en la entrada analógica de esta tarjeta,
# lo que supone que algunas fuentes como una TV pueden tener un nivel muy bajo.
#
# Para ello podemos insertar la siguiente orden de patcheo antes de llamar a initfirtro.py
# en el archivo /etc/rc.local de arranque de la máquina:
#
#   /etc/rc.local
#
#     su -l firtro -c "/home/firtro/bin_custom/patch_capture_gain.sh 6.0"
#     su -l firtro -c "/home/firtro/bin/initfirtro.py"
#
# Entonces debemos asociar la entrada analógica de FIRtro a los nuevos puertos que la amplifican:
#
#   audio/inputs
#
#     [analog]
#     #in_ports:   system:capture_1 system:capture_2
#     in_ports:    capture_gain:out_1 capture_gain:out_2
#

gaindB=6.0
if [ $1 ]; then
    gaindB=$1
fi

# Averiguamos los puertos de entrada a FIRtro
FIRtroUsaEcasound=$(grep load_ecasound /home/firtro/audio/config | grep -v ";" | cut -d"=" -f2)
if [[ $FIRtroUsaEcasound == *"False"* ]]; then
    FIRtroPorts=brutefir
else
    FIRtroPorts=ecasound
fi

# Comprobamos si initfirtrosya estuviera patcheado
isPatched=$(grep capture_gain /home/firtro/bin/initfirtro.py)

if [[ $isPatched == "" ]]; then
    echo "(i) patcheando initfirtro.py"

    # Escribe una nota informativa
    echo "" >> /home/firtro/bin/initfirtro.py
    echo "    # Patch para disponer de un puerto Jack con una ganancia sobre system:capture" \
         >> /home/firtro/bin/initfirtro.py
    echo "    # https://github.com/Rsantct/FIRtro-light/wiki/205-sound-card-analog-input" \
         >> /home/firtro/bin/initfirtro.py

    # Kill de procesos jack_cable_gain existentes
    echo "    Popen('pkill -KILL -f jack_cable_gain.py', shell=True)" \
         >> /home/firtro/bin/initfirtro.py
    echo "    sleep(.5)"  >> /home/firtro/bin/initfirtro.py

    # Lanza jack_cable_gain.py:
    echo "    Popen('/home/firtro/bin_custom/jack_cable_gain.py source=system sink="$FIRtroPorts" \\" \
         >> /home/firtro/bin/initfirtro.py
    echo "           -d name=capture_gain -g="$gaindB" &', shell=True)" \
         >> /home/firtro/bin/initfirtro.py
else
    echo "(i) ya estaba patcheado initfirtro.py"
fi

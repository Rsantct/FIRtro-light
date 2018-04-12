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
# La ganancia se puede reajustar ejecutando capture_gain.sh, por ejemplo:
# 
#    $ ~/bin_custom/capture_gain.sh +3.0
#    

gaindB=0.0
if [ $1 ]; then
    gaindB=$1
fi

patched=$(grep capture_gain.sh /home/firtro/bin/initfirtro.py)

if [[ $patched == "" ]]; then
    echo "(i) patcheando initfirtro.py"
    echo "    Popen('/home/firtro/bin_custom/capture_gain.sh "$gaindB"', shell=True)" >> /home/firtro/bin/initfirtro.py
else
    echo "(i) ya estaba patcheado initfirtro.py"
fi

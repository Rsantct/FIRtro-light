#!/bin/bash

# Basado en el binario 'usbrelay', compilado con la libreria hidraw, ver detalles en:
# https://github.com/darrylb123/usbrelay
# El binario 'usbrelay':
#   - Sin argumentos muestra el estado de los reles.
#   - Con argumentos BITFT_n=x modifica los reles.
#   - El estado de los relés se ofrece en stdout, la información adicional
#     o los errores se ofrecen en stderr.

# Este script admite un parametro que puede ser 1/on para activar el rele
# cualquier otro valor lo desactivará.
# Si no se pasa parámetro, se mostrará el estado del relé al final de este script.

# NOTA: se puede usar ssh para ordenar la ejecución de usbrelay en una máquina remota.
# Se deja dos lineas comentadas más abajo.

if [[ $1 ]]; then
    tmp="BITFT_1=0"
    if [[ $1 == "on" || $1 == "1" ]]; then
        tmp="BITFT_1=1"
    fi
    cmd="$HOME/bin_custom/usbrelay "$tmp
    $cmd
    #ssh pi@rpi3clac $cmd
fi
# Vemos el estado del relé.
cmd="$HOME/bin_custom/usbrelay"
eval $($cmd)
#eval $(ssh pi@rpi3clac $cmd)
# EL resultado son variables BITFT_1=x y BITFT_2=y, con x,y in (0,1)
# que son leidas por el shell.
# En nuestro caso nos fijamos solo en el rele 1 (BITFT_1)
if [[ $BITFT_1 == "1" ]]; then
    echo ON
elif [[ $BITFT_1 == "0" ]]; then
    echo OFF
else
    echo "(!) relay status not found"
fi
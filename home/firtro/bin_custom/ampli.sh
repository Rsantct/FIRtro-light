#!/bin/bash

# (i)   Se necesita el binario 'usbrelay' en el path.
#       Recientemente DEBIAN dispone del paquete 'usbrelay'
#       En caso contrario hay que compilarlo usando la libreria hidraw:
#           https://github.com/darrylb123/usbrelay
#       Reiniciar despues de instalar para que funcione.

# El binario 'usbrelay':
#   - Sin argumentos muestra el estado de los reles.
#   - Con argumentos BITFT_n=x modifica los reles.
#   - El estado de los relés se ofrece en stdout, la información adicional
#     o los errores se ofrecen en stderr.

# Este script admite un parametro que puede ser 1/on para activar el rele
# cualquier otro valor lo desactivará.
# Si no se pasa parámetro, se mostrará el estado del relé al final de este script.

# NOTA: se puede usar ssh para ordenar la ejecución de usbrelay en una máquina remota.
# Se dejan dos lineas comentadas más abajo.

# Si se pasa parámetro on/off se ejecuta:
if [[ $1 ]]; then
    tmp="BITFT_1=0"
    if [[ $1 == "on" || $1 == "1" ]]; then
        tmp="BITFT_1=1"
    fi
    cmd="/usr/bin/usbrelay "$tmp
    # opc.1 para ejecución en local:
    $cmd
    # opc.2 para ejecución en máquina remota:
    #ssh firtro@remote_addr $cmd
fi

# Consultamos el estado del relé:
cmd="/usr/bin/usbrelay"
# opc.1 para ejecución en local:
eval $($cmd)
# opc.2 para ejecución en máquina remota:
#eval $(ssh pi@remote_addr $cmd)

# Mostramos el resultado: que son las variables 
#   BITFT_1=x y BITFT_2=y, con x,y in (0,1)
# que son leidas por el shell.
# En nuestro caso nos fijamos solo en el rele 1 (BITFT_1)
if [[ $BITFT_1 == "1" ]]; then
    echo ON
elif [[ $BITFT_1 == "0" ]]; then
    echo OFF
else
    echo "(!) relay status not found"
fi

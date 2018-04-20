#!/bin/bash

# Apaga el ampli en 30 minutos
# Basado en 'at', cada vez que se ordena este script
# se borra la queue de at y se programa de nuevo el apagado.


# 1) Borra la cola de at
for i in `atq | awk '{print $1}'`;do atrm $i;done

# 2) Apaga los reles del ampli dentro de 30 minutos
# -M es para que at no envie correo informativo del resultado de la tarea
echo "ampli.sh off" | at -M now + 1 minute

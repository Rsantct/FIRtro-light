#!/bin/bash

# Ajuste para Spotify (librespot) necesita un buffer grande
# en maquinas lentas como RPI1

/home/firtro/bin_custom/restart_jack.sh 8192
/home/firtro/bin/control level_add 0
/home/firtro/bin/control input none

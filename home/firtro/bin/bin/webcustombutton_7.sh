#!/bin/bash

# Ajuste de baja latencia para la entrada analogica 
# (es posible que provoque under runs con players que consumen %CPU)

/home/firtro/bin_custom/restart_jack_brutefir_ecasound.sh 256

/home/firtro/bin/control input analog

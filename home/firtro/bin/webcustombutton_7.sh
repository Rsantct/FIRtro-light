#!/bin/bash

# Ajuste de baja latencia para la entrada analogica
# (es posible que provoque under runs con players que consumen %CPU)

/home/firtro/bin_custom/restart_jack.sh 1024
/home/firtro/bin/control level_add 0
/home/firtro/bin/control input analog
/home/firtro/bin/control input restore

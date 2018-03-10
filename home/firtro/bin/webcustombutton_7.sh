#!/bin/bash

# Ajuste de baja latencia para la entrada analogica

/home/firtro/bin_custom/restart_jack.sh -jp=1024 -jn=3 -bflen=4096

/home/firtro/bin/control level_add 0
/home/firtro/bin/control input analog
/home/firtro/bin/control input restore

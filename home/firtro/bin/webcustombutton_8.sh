#!/bin/bash

# Ajuste para Spotify (librespot) con Jack solo Playback

/home/firtro/bin_custom/restart_jack.sh -jp=2048 -jn=3 -bflen=8192 -jP
/home/firtro/bin/control level_add 0
/home/firtro/bin/control input none

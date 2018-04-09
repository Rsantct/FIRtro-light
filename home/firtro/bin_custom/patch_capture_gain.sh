#!/bin/bash

gaindB=0.0
if [ $1 ]; then
    gaindB=$1
fi

patched=$(grep capture_gain.sh /home/firtro/bin/initfirtro.py)

if [[ $patched == "" ]]; then
    echo "(i) patcheando initfirtro.py"
    echo "    Popen('/home/firtro/bin_custom/capture_gain.sh "$gaindB"')" >> /home/firtro/bin/initfirtro.py
else
    echo "(i) ya estaba patcheado initfirtro.py"
fi

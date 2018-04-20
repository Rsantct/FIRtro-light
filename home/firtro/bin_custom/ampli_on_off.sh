#!/bin/bash

estado=$(/home/firtro/bin_custom/ampli.sh 2>&1 | tail -n 1)

if [ $estado == "OFF" ]; then
    /home/firtro/bin_custom/ampli.sh on
else
    /home/firtro/bin_custom/ampli.sh off
fi

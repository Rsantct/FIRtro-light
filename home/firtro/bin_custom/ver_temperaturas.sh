#!/bin/bash

for zone in /sys/class/thermal/* ; do
    #cat /sys/class/thermal/thermal_zone0/temp | sed 's/.\{3\}$/.&/'
    temp=$(cat $zone/temp | sed 's/.\{3\}$/.&/')
    echo $( basename $zone ) $temp
done

#!/bin/bash

# FIRtro light
# https://github.com/Rsantct/FIRtro-light/wiki/00-Firtro-light#página-web-de-control-simplificada
# Este script se llama al pulsar el botón de alerta de la
# esquina superior izq de la página de control simplificada

# Leemos la accion configurada en www/config/config.ini
#   [misc]
#   poweroff_reboot_button = "poweroff" o bien "reboot"
#
tmp=$(grep poweroff_reboot_button /home/firtro/www/config/config.ini)
tmp=$(echo $tmp | cut -d"=" -f2 | tr -d " " | tr -d "\"")
#
# Y la ejecutamos:
sudo $tmp

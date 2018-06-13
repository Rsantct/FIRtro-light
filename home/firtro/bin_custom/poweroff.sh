#!/bin/bash

# Sirve para que le web de FIRtro-light disponga de un boton de apagado de la máquina.
# Este script (o un link) debe estar en /home/bin ya que es el scope usable por el modulo php de FIRtro
# Es llamado a pedal con el comando "poweroff" de www/php/functions.php (github FIRtro-light)

logfile="/home/firtro/USER-REBOOTS.log"
timestamp=$(date +%Y%m%d-%H%M%S)
echo $timestamp "poweroff" >> $logfile
sync
sleep 1
sudo poweroff



#!/bin/bash

# Cutrescript para instalar los scripts bin_custom/* de FIRtro-light

# Baja la distro FIRtro-light
cd /home/firtro/tmp
rm -f master.zip
wget https://github.com/Rsantct/FIRtro-light/archive/master.zip
rm -rf FIRtro-light-master
unzip master.zip
rm -f master.zip

# Copia los scripts de bin_custom y las url de emisoras de radio
cd /home/firtro/
cp tmp/FIRtro-light-master/home/firtro/bin_custom/*   bin_custom/
cp tmp/FIRtro-light-master/home/firtro/audio/radio_urls   audio/

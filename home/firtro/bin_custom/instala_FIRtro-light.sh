#!/bin/bash

# Cutrescript para instalar los archivos de FIRtro-light

# Baja la distro FIRtro-light
cd /home/firtro/tmp
rm -f master.zip
wget https://github.com/Rsantct/FIRtro-light/archive/master.zip
rm -rf FIRtro-light-master
unzip master.zip
rm -f master.zip
cd /home/firtro/

# Los scripts de bin_custom
cp tmp/FIRtro-light-master/home/firtro/bin_custom/*  bin_custom/
chmod +x bin_custom/*

# El archivo con las url de emisoras de radio, y plantillas para 4 y 8 paramétricos en Ecasound
cp tmp/FIRtro-light-master/home/firtro/audio/radio_urls audio/
cp tmp/FIRtro-light-master/home/firtro/audio/PEQ*       audio/

# Actualiza la web de control con la página de control simplificada:
sh tmp/FIRtro-light-master/home/firtro/bin_custom/update_web_light.sh

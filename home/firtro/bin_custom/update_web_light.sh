#!/bin/bash

# Cutrescript para actualizar la web de control con la página simplificada

cd /home/firtro/www
mv index.php index.php.old
mv js/functions.js js/functions.js.old
mv php/functions.php php/functions.php.old
wget https://raw.githubusercontent.com/Rsantct/FIRtro-light/master/home/firtro/www/index.php
cd js
wget https://raw.githubusercontent.com/Rsantct/FIRtro-light/master/home/firtro/www/js/functions.js
cd ../php
wget https://raw.githubusercontent.com/Rsantct/FIRtro-light/master/home/firtro/www/php/functions.php

cd /home/firtro/bin
rm -f poweroff_reboot.sh
wget https://raw.githubusercontent.com/Rsantct/FIRtro-light/master/home/firtro/bin/poweroff_reboot.sh
chmod +x poweroff_reboot.sh
cd /home/firtro

# Nueva linea en www/config/config.ini
nueva='poweroff_reboot_button = "reboot"'
yaesta=$(grep poweroff_reboot_button www/config/config.ini)
if [ ! "$yaesta" ] ; then
    echo $nueva >> www/config/config.ini
fi
echo "www/config/config.ini:"
grep poweroff_reboot_button www/config/config.ini

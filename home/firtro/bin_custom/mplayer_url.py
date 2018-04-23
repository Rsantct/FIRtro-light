#!/usr/bin/python
# -*- coding: utf-8 -*-

import time
from subprocess import Popen
from ConfigParser import ConfigParser
import sys

#device = " -ao alsa:device=hw=ALSA"
device = " -ao jack:name=mplayer_url:port=ecasound"

urls_file = "/home/firtro/audio/radio_urls"
emisoras = ConfigParser()
emisoras.read(urls_file)

if __name__ == "__main__":

    emisoraName = sys.argv[1]

    if emisoraName in emisoras.options("emisoras"):

        Popen("killall mplayer", shell=True)
        time.sleep(1)

        emisoraUrl = emisoras.get("emisoras", emisoraName)
        opcionesMplayer = " -nolirc -quiet"
        opcionesMplayer += device

        # Apaño las de RTVE vienen en formato playlits que contiene el stream final mp3.
        # Pero mplayer no lo permite: "Playlist parsing disabled for security reasons."
        #   - Se puede descargar el contenido de la playlits m3u y lanzar mplayer con la url adecuada
        #   - Por comodidad optamos por permitir el parseo de playlist.
        if "rtve" in emisoraUrl:
            opcionesMplayer += " -allow-dangerous-playlist-parsing"

        Popen("mplayer " + emisoraUrl + " " + opcionesMplayer, shell=True)

    else:
        print "No existe '" + emisoraName + "' en " + urls_file

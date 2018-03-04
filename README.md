# FIRtro-light

Un FIRtro simplificado para máquinas pequeñas

Con motivo de un encargo, se pretende que sirva en un salón para oir la TV y para reproducir Spotify en modo black-box controlado desde un teléfono o tablet, con las ventajas de FIRtro: control remoto, volumen con loudness, DRC.

Sin selector de entradas

Las fuentes serán aplicaciones ALSA o bien la entrada analógica de la tarjeta de sonido:
- Raspotify (librespot) → ALSA → Jack
- Receptor de audio BlueTooth → ALSA → Jack
- LineIN → Jack

Se descarta el uso directo de Brutefir sobre ALSA (sin Jack), el pequeño consumo de CPU de Jack compensa los posibles probemas de I/O observados con el uso de Brutefir sobre ALSA (Loopbak + tarjeta física).

DRC de bajo %CPU basado en Ecasound.

# Instalación

Ver en `doc/FIRtro-Light.pdf`

# Credits

FIRtro https://github.com/AudioHumLab/FIRtro

Raspotify https://github.com/dtcooper/raspotify

bluealsa https://github.com/Arkq/bluez-alsa


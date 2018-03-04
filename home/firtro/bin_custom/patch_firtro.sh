#!/bin/bash

# Parches para este FIRtro

# Cambia la espera normal de 20 s al server, ponemos 45 s para una RPI1 antigua.
sed -i.bak s/segundos\ =\ 20/segundos\ =\ 45/g /home/firtro/bin/initfirtro.py
sed -i.bak s/20-segundos/45-segundos/g /home/firtro/bin/initfirtro.py


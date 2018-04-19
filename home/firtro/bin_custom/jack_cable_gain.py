#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
    v0.1beta
    Script para tener un cable con ganancia en Jack

    Está pensado para tarjetas de sonido con poca sensibilidad en la
    entrada analógica, como es el caso de la tarjeta I2S 'audioinjector' para RPI

    Uso:    capture_gain.py g=gaindB [source=jack_name] [sink=jack_name] [channels=N] [-d]
            channels    canales del cable (por defecto 2)
            source      cliente que se conectará a la entrada del cable
            sink        cliente que se conectará a la salida del cable
            -d          desconecta source y sink
"""

import sys
import jack
import numpy as np

def conecta (a, b, mode="connect"):
    """ conecta puertos a de captura con b de playback
    """
    # lista de puertos A
    Aports = [x for x in jack.get_ports() if a in x]
    # lista de puertos A que son de captura
    Aports = [x for x in Aports if jack.get_port_flags(x) % 2 == 0 ]
    # lista de puertos B
    Bports = [x for x in jack.get_ports() if b in x]
    # lista de puertos B que son de playback
    Bports = [x for x in Bports if jack.get_port_flags(x) % 2 == 1 ]

    # Recorremos A y lo vamos (des)conectando con B
    while Aports:
        try:
            p1 = Aports.pop(0)
            p2 = Bports.pop(0)
            #print p1, p2
            if mode == 'disconnect':
                jack.disconnect(p1, p2)
            else:
                jack.connect(p1, p2)
                
        except:
            pass

def dB2g (dB=0.0):
    # dB = 20 * log10 (g)
    # g = 10 ** (dB/20)
    return 10 ** (dB/20.0)

if __name__ == "__main__":

    gaindB = 0.0
    # Canales del cable, por defecto 2
    nchannels = 2
    # Puertos a conectar en la entrada y en la salida del cable
    source = ""
    sink = ""
    disconnect = False

    for opc in sys.argv[1:]:
        if opc.startswith("channels="):
            nchannels = int(opc.split("=")[-1])
            gaindB = float(opc.split("=")[-1])
        elif opc.startswith("source="):
            source = str(opc.split("=")[-1])
        elif opc.startswith("sink="):
            sink = str(opc.split("=")[-1])
        elif opc == -d:
            disconnect = True
        elif "-h" in opc:
            print __doc__
            sys.exit()

    # Nos atachamos a jackd
    jack.attach("cable_gain")

    # Creamos los puertos de esta instancia
    for i in range(1, 1 + nchannels):
        jack.register_port('out_' + str(i), jack.IsOutput)
        jack.register_port("in_"  + str(i), jack.IsInput)

    # Activamos los puertos
    jack.activate()

    # Los conectamos los puertos de captura y playback deseados:
    if source:
        if disconnect:
            conecta(source, "cable_gain", mode=disconnect)
        conecta(source, "cable_gain", mode=connect)
    if sink:
        if disconnect:
            conecta("cable_gain", sink, mode=disconnect)
        conecta("cable_gain", sink, mode=connect)

    # Tomamos nota de la Fs y del buffer_size en JACK:
    Fs =            float(jack.get_sample_rate())
    buffer_size =   jack.get_buffer_size()

    print "buffer: " + str(buffer_size), "delay: " + str(round(buffer_size/Fs*1000, 1)) + "ms"

    # Arrays buffer para procesar nuestros puertos con jack.process()
    # https://github.com/rknLA/pyjack
    ai = np.zeros( (nchannels, buffer_size), dtype="f")
    ao = np.zeros( (nchannels, buffer_size), dtype="f")

    # Loop infinito:
    print "capturing audio"
    underruns = 0
    overruns  = 0
    g = dB2g(gaindB)
    while True:
        try:
            # amplificamos:
            ao = ai * g
            omax = np.max(ao)

            # warnings
            if omax > 1.0:
                op = str(round(20*np.log10(omax), 1)) + " dB"
                print "out_peak: " + op

            # procesamos contra el thread real time de jackd
            jack.process(ao, ai)

        except jack.InputSyncError:
            underruns += 1
            print "input sync warnings: " + str(underruns)

        except jack.OutputSyncError:
            overruns += 1
            print "output sync warnings: " + str(overruns)

        xruns = underruns + overruns
        if xruns > 100:
            #print "esto se sale de madre"
            #break
            pass

    #jack.deactivate()
    #jack.detach()

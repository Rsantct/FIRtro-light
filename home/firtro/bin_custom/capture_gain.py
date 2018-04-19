#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
    v0.1beta
    Script para tener un cable con ganancia en Jack

    Está pensado para tarjetas de sonido con poca sensibilidad en la
    entrada analógica, como es el caso de la tarjeta I2S 'audioinjector' para RPI

    Uso:    capture_gain.py gaindB
"""

import sys
import jack
import numpy as np

channels = "1", "2"

def dB2g(dB=0.0):
    # dB = 20 * log10 (g)
    # g = 10 ** (dB/20)
    return 10 ** (dB/20.0)

if __name__ == "__main__":

    if len(sys.argv) == 2:
        gaindB = float(sys.argv[1])
    else:
        print __doc__
        sys.exit()

    # Nos atachamos a jackd
    jack.attach("capture_gain")

    # Creamos los puertos de esta instancia
    for c in channels:
        jack.register_port('out_'+c, jack.IsOutput)
        jack.register_port("in_"+c,  jack.IsInput)

    # Activamos los puertos
    jack.activate()

    # Los conectamos a la entrada analogica:
    for c in channels:
        jack.connect("system:capture_"+c, "capture_gain:in_"+c)

    # Tomamos nota de la Fs y del buffer_size en JACK:
    Fs =            float(jack.get_sample_rate())
    buffer_size =   jack.get_buffer_size()

    print "buffer: " + str(buffer_size), "delay: " + str(round(buffer_size/Fs*1000, 1)) + "ms"

    # Arrays buffer para procesar nuestros puertos con jack.process()
    # https://github.com/rknLA/pyjack
    ai = np.zeros( (len(channels), buffer_size), dtype="f")
    ao = np.zeros( (len(channels), buffer_size), dtype="f")

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

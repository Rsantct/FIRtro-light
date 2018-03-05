#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
    alsamixer levels control is tricky on Cirrus Logic / Wolfson Audio cards.

    This is a dB level control for them.

    Usage:

        clac_dBlevel.py [-cap] [-head] (+/-)xxdB | xxdB(+/-) | off | on

                        xxdB(+/-)   applies relative level
                        off/on      mute/unmute
                        -cap        will adjust capture level
                        -head       adjust Headphones-Out (default Line-Out)

"""
import subprocess as sp
import sys

#card = "sndrpiwsp" # Con el driver actual con kernel 4.x  la tarjeta se llama 'RPiCirrus'
                    # incluso para la tarjeta  Wolfson Audio Card
card = "RPiCirrus"

salidas =  {"LineOut":      ["'HPOUT2 Digital'"],
            "Headphones":   ["'HPOUT1 Digital'"]}

entradas = {"Headset":      ["'IN1L Digital'","'IN1R Digital'"],
            "DMIC":         ["'IN2L Digital'","'IN2R Digital'"],
            "LineIn":       ["'IN3L Digital'","'IN3R Digital'"]}


def dBcompensate(x):
    tmp = x.split("dB")[0]
    tmp = float(tmp) / 2.0
    return str(tmp)[:5] + "dB" + x[-1]

def setDBs(vol, mode):
    # INFO:
    # amixer dB behavior is buggy, we try to deal with it here.

    if vol[-1] in ("+","-"):
        # los incrementos de dB son ejecutados por amixer al doble de su valor
        # sin embargo los ajustes absolutos son ejecutados con normalidad ¿!?
        vol = dBcompensate(vol)
    elif vol[0] in ("+","-"):
        # amixer no responde bien con por ejemplo -15dB o -6.0dB
        # solo responde bien con valores sin signo por ejemplo 4.1dB
        # la solución es poner a cero y luego bajar o subir :-/
        if mode == "playback":
            setLevel("off", mode=mode)
        setLevel("0dB", mode=mode)
        vol = vol[1:] + vol[0]
        vol = dBcompensate(vol)
    setLevel(vol, mode=mode)
    if mode == "playback":
        setLevel("on", mode=mode)

def setLevel(x, mode, quiet=True):
    if not quiet:
        print "\n==============================================="
    if mode == "capture":
        for entrada in entradas:
            if not quiet:
                print "\n---", entrada + ":"
            for item in entradas[entrada]:
                cmd = "amixer" + " -q"*quiet + " -c " + card + " sset " + item + " " + x
                sp.call(cmd, shell=True)
    else:
        for salida in salidas:
            if salida == salida_selecc:
                if not quiet:
                    print "\n---", salida + ":"
                for item in salidas[salida]:
                    cmd = "amixer" + " -q"*quiet + " -c " + card + " sset " + item + " " + x
                    sp.call(cmd, shell=True)

def getVol(mode="playback"):
    if mode == "capture":
        for entrada in entradas:
            print "\n---", entrada + ":"
            for item in entradas[entrada]:
                cmd = "amixer -c " + card + " sget " + item
                sp.call(cmd, shell=True)
    else:
        for salida in salidas:
            print "\n---", salida + ":"
            for item in salidas[salida]:
                cmd = "amixer -c " + card + " sget " + item
                sp.call(cmd, shell=True)

if __name__ == "__main__":

    mode          = "playback"
    vol           = ''
    onoff         = ''
    salida_selecc = "LineOut"

    if sys.argv[1:]:
        for opt in sys.argv[1:]:

            if "-c" in opt or "-r" in opt:
                mode = "capture"

            elif "-h" in opt:
                if "-head" in opt:
                    salida_selecc = "Headphones"
                else:
                    print __doc__
                    sys.exit()

            elif "dB" in opt:
                vol = opt

            elif opt in ("on", "off"):
                onoff = opt

            else:
                print __doc__
                sys.exit()

    if vol:
        print "\n--- (i) setting '" + salida_selecc + "' level.\n"
        setDBs(vol, mode)
    elif onoff:
        setLevel(onoff)

    getVol(mode)
    print ""

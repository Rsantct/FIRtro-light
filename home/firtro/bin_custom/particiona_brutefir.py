#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
    v0.1beta
    Cutrescript para establecer el particionado de Brutefir en FIRtro

    Uso:

    particiona_brutefir.py -jp=XX [-jn=X -bflen=XX -bfmaxp=XX] [--verbose]

        -jp=XX       Jack -p (period size)
        -jn=XX       Jack -n (number of periods) (opcional, default: 2))

            Jack buffer size =  period size *  number of periods

        -bflen=XX    Brutefir total filter_length (opcional, default: 32K)
        -bfmax=XX    Brutefir max partitions (opcional, default: 16)

            Brutefir partition size >= Jack buffer size


    Resultado: devuelve  'partition_size,number_of_partitions'

"""

import sys

def printa(cosa):
    print "-------", cosa , "---------"
    print
    print "Jack     buffer:        ", jbuff, "(" + str(jperiod) + " x " + str(jnperiods) + ")" 
    print
    print "Brutefir filter_length: ", str(bfpsize) + "," + str(bfparts)
    print

def lee_command_line():
    global bfmaxparts, verbose
    
    # valores por defecto
    jperiod     = None
    jnperiods   = 2
    bfflength   = 2**15        # 32768

    verbose = False
    for opc in sys.argv[1:]:

        if "-jp" in opc:
            jperiod = int(opc.split("=")[1])

        elif "-jn" in opc:
            jnperiods = int(opc.split("=")[1])

        elif "-bflen" in opc:
            bfflength = int(opc.split("=")[1])

        elif "-bfmaxp" in opc:
            bfmaxparts = int(opc.split("=")[1])

        elif "-v" in opc:
            verbose = True

        elif "-h" in opc:
            print __doc__
            sys.exit(0)

    if not jperiod:
        print jperiod
        "(!) se debe especificar -jperiods"
        print __doc__
        sys.exit(0)

    return jperiod, jnperiods, bfflength, bfmaxparts


if __name__ == "__main__":

    bfmaxparts  = 16
        

    # Lee command line:
    jperiod, jnperiods, bfflength, bfmaxparts = lee_command_line()
    jbuff       = jperiod * jnperiods
    bfpsize     = bfflength
    bfparts     = 1

    if verbose:
        printa("no particionado")

    # Particionamos en potencias de 2
    pot = 0
    bfparts = 2 ** pot
    bfpsize0 = bfpsize
    while True:
        bfpsize = bfpsize0 / bfparts
        # si nos hemos pasado damos marcha atrás (si se puede)
        if (jbuff > bfpsize) or (bfparts > bfmaxparts):
            if pot >= 1:
                bfparts = 2 ** (pot - 1)
                bfpsize = bfpsize0 / bfparts
            else:
                if verbose:
                    print "(i) ERROR: Brutefir partition size >= Jack buffer size"
                sys.exit(-1)
            break
        pot += 1
        bfparts = 2 ** pot 

    if verbose:
        printa("particionado")
    else:
        print  str(bfpsize) + "," + str(bfparts)

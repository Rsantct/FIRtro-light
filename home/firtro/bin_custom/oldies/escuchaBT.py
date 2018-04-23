#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
    Cutre script para recibir audio de dispositivos BT
    SUSTITUIDO por bluealsa-aplay_watchdog.sh, basado directamente en 'bluealsa-aplay'
"""
import time
import sys
import subprocess as sp

myname = sys.argv[0].split("/")[-1]

def get_paired_devices():
    cmd = "echo 'paired-devices\nquit\n' | bluetoothctl"
    tmp = sp.check_output(cmd, shell=True)
    # [NEW] Controller 00:1A:7D:DA:71:13 wpi [default]
    # [NEW] Device 54:E4:3A:1E:FC:92 iPhone
    # [bluetooth]# paired-devices
    # Device 54:E4:3A:1E:FC:92 iPhone
    # [bluetooth]# quit
    # [DEL] Controller 00:1A:7D:DA:71:13 wpi [default]
    tmp = tmp.split("\n")
    devices = [x.split()[1] for x in tmp if x.startswith("Device ")]
    return devices

def device_is_connected(device):
    cmd = "echo 'info " + device + "\nquit\n' | bluetoothctl"
    tmp = sp.check_output(cmd, shell=True)
    tmp = tmp.split("\n")
    isConnected = [x.split()[-1] for x in tmp if "Connected: " in x]
    if isConnected == ["no"]:
        return False
    else:
        return True

def listen_device(device):
    """ inicia la captura """
    # si no usamos arecord -r44100 se pone a 8000Hz
    cmd = "arecord -D bluealsa:HCI=hci0,DEV=" + device + " -r44100 -c2 -f S16_LE | aplay -D jack"
    sp.Popen(cmd, shell=True)
    print "(" + myname + ") Escuchando: " + device

def release_device(device):
    """ termina la captura """
    cmd = "pkill -KILL -f " + device
    sp.Popen(cmd, shell=True)
    print "(" + myname + ") Liberando: " + device

if __name__ == "__main__":

    for opc in sys.argv:
        if "-h" in opc:
            print __doc__
            sys.exit()

    # inicializa los Devices desconectándolos:
    pairedDevices={}
    for device in get_paired_devices():
        release_device(device)
        pairedDevices[device] = {"connected":False, "listening":False}

    # loop:
    while True:

        for device in get_paired_devices():
            if device_is_connected(device):
                if not pairedDevices[device]['listening']:
                    # lanza la escucha:
                    listen_device(device)
                    pairedDevices[device] = {"connected":True, "listening":True}
            else:
                if pairedDevices[device]['listening']:
                    # libera la escucha:
                    release_device(device)
                    pairedDevices[device] = {"connected":False, "listening":False}

        time.sleep(5)

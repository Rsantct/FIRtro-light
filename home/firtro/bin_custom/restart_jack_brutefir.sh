#!/bin/bash

# Valores de buffer validos:
bvalid=(128 256 512 1024 2048 4096 8192)

# Leemos el valor de buffer solicitado
if [[ $1 ]]; then
    let jperiod=$1
    if [[ " ${bvalid[*]} " != *"$jperiod"* ]]; then
        echo $jperiod es incorrecto
        exit 0
    fi
else
    echo "uso: restart_jack_brutefir.sh buffer_size"
    exit 0
fi

let bpsilet bpsize=$jperiod # Brutefir partition size
let bnparts=1       # Brutefir number of partitions
# Particionado de Brutefir. Filtrado de al menos 1024 taps
if (( $jperiod < 1024 )); then
    let bpsize=1024
# NOTA descartamos el particionado ya que consume demasiado %CPU
#else
#    let bnparts=2
#    let "bpsize = $jperiod * 2"
fi
# Brutefir filter_length definition
bflength="filter_length:"$bpsize","$bnparts

# Lee audio/config
function lee_audio_config () {
system_card=$(grep ^system_card /home/firtro/audio/config | grep -v ";" | cut -d" " -f3)
jack_options=$(grep ^jack_options /home/firtro/audio/config | grep -v ";" | cut -d" " -f3-)
loudspeaker=$(grep ^loudspeaker /home/firtro/audio/config | grep -v ";" | cut -d" " -f3)
brutefir_path=$(grep ^brutefir_path /home/firtro/audio/config | grep -v ";" | cut -d" " -f3)
if [[ $1 ]]; then
    echo "system_card:   " $system_card
    echo "jack_options:  " $jack_options
    echo "brutefir_path: " $brutefir_path
    echo "loudspeaker:   " $loudspeaker
fi
}

# Prepara un brutefir_config con un particionado adecuado
function prepara_brutefir_config () {
    Bconfig="/home/firtro/lspk/"$loudspeaker"/44100/brutefir_config"
    newBconfig=$Bconfig"."$bpsize"."$bnparts
    cp $Bconfig $newBconfig
    sed -i '/.*filter_length.*/c\'$bflength';' $newBconfig
}

# Leemos la configuracion de audio/config
lee_audio_config

# Prepara un brutefir_config con un particionado adecuado
prepara_brutefir_config

# Detiene JACK y Brutefir
pkill -f -KILL jackd
sleep 1

# Arranca JACK
cmd="jackd -R -dalsa -d$system_card -p"$jperiod" -n2 --softmode -r44100"
echo "--- Arrancando JACK:"
echo $cmd
$cmd &
sleep 3

# Arranca Brutefir con el nuevo archivo brutefir_config
echo "--- Arrancando BRUTEFIR:"
echo $brutefir_path $newBconfig
$brutefir_path $newBconfig &
sleep 3

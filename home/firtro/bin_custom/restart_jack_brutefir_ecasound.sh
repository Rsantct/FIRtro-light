#!/bin/bash

# Fs (de momento a piñon fijo)
fs="44100"
home="/home/firtro"

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

let bpsize=$jperiod # Brutefir partition size
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
loudspeaker=$(grep ^loudspeaker $home/audio/config | grep -v ";" | cut -d" " -f3)
system_card=$(grep ^system_card $home/audio/config | grep -v ";" | cut -d" " -f3)

jack_options=$(grep ^jack_options $home/audio/config | grep -v ";" | cut -d" " -f3-)

brutefir_path=$(grep ^brutefir_path $home/audio/config | grep -v ";" | cut -d" " -f3)

ecasound_path=$(grep ^ecasound_path $home/audio/config | grep -v ";" | cut -d" " -f3)
ecasound_filters=$(grep ^ecasound_filters $home/audio/config | grep -v ";" | cut -d" " -f3)
ecsFile=$home/audio/"PEQx"$ecasound_filters"_defeat_"$fs".ecs"

if [[ $1 ]]; then
    echo "system_card:   " $system_card
    echo "jack_options:  " $jack_options
    echo "brutefir_path: " $brutefir_path
    echo "loudspeaker:   " $loudspeaker
    echo "ecsFile:       " $ecsFile
fi
}

# Prepara un brutefir_config con un particionado adecuado
function prepara_brutefir_config () {
    Bconfig=$home"/lspk/"$loudspeaker"/"$fs"/brutefir_config"
    newBconfig=$Bconfig"."$bpsize"."$bnparts
    cp $Bconfig $newBconfig
    sed -i '/.*filter_length.*/c\'$bflength';' $newBconfig
}

# Leemos la configuracion de audio/config
lee_audio_config

# Prepara un brutefir_config con un particionado adecuado
prepara_brutefir_config

# Detiene Jack-Brutefir y Ecasound
pkill -f -KILL jackd
pkill -f -KILL "bin/ecasound"
sleep 1

# Arranca JACK
cmd="jackd -R -dalsa -d$system_card -p"$jperiod" -n2 --softmode -r"$fs
echo "--- Arrancando JACK:"
echo $cmd
$cmd &
sleep 3

# Arranca Brutefir con el nuevo archivo brutefir_config
echo "--- Arrancando BRUTEFIR:"
echo $brutefir_path $newBconfig
$brutefir_path $newBconfig &
sleep 3

# Arranca Ecasound
cmd=$ecasound_path" -q --server -s:"$ecsFile
echo "--- Arrancando ECASOUND:"
echo $cmd
$cmd &
sleep 1

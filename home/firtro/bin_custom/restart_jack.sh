#!/bin/bash

# Permite relanzar jack/brutefir/ecasound 
# ajustando un nuevo --period XXXX en Jack y con filter_length acorde en Brutefir.
# (se creará un uevo archivo brutefir_config.XXXX al efecto)

# Fs (de momento a piñon fijo)
fs="44100"
home="/home/firtro"

# Valores de buffer validos:
bvalid=(64 128 256 512 1024 2048 4096 8192 16384)

# Leemos el valor solicitado '--period'
if [[ $1 ]]; then
    let jperiod=$1
    if [[ " ${bvalid[*]} " != *"$jperiod"* ]]; then
        echo $jperiod es incorrecto
        exit 0
    fi
else
    echo "uso: restart_jack.sh buffer_size"
    exit 0
fi

### Adecuación de Brutefir filter_length
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

### Lee audio/config
loudspeaker=$(grep ^loudspeaker $home/audio/config | grep -v ";" | cut -d" " -f3)
system_card=$(grep ^system_card $home/audio/config | grep -v ";" | cut -d" " -f3)
jack_options=$(grep ^jack_options $home/audio/config | grep -v ";" | cut -d" " -f3-)
brutefir_path=$(grep ^brutefir_path $home/audio/config | grep -v ";" | cut -d" " -f3)
load_ecasound=$(grep ^load_ecasound $home/audio/config | grep -v ";" | cut -d" " -f3)
ecasound_path=$(grep ^ecasound_path $home/audio/config | grep -v ";" | cut -d" " -f3)
ecasound_filters=$(grep ^ecasound_filters $home/audio/config | grep -v ";" | cut -d" " -f3)
ecsFile=$home/audio/"PEQx"$ecasound_filters"_defeat_"$fs".ecs"
echo ""
echo "--- Leyendo audio/config: ---"
echo "system_card:   " $system_card
echo "jack_options:  " $jack_options
echo "brutefir_path: " $brutefir_path
echo "loudspeaker:   " $loudspeaker
echo "load_ecasound: " $load_ecasound
if [[ $load_ecasound == "True" ]]; then
    echo "ecsFile:       " $ecsFile
fi
echo "-----------------------------"
echo ""

### Prepara un nuevo archivo 'brutefir_config' con un particionado adecuado
Bconfig=$home"/lspk/"$loudspeaker"/"$fs"/brutefir_config"
newBconfig=$Bconfig"."$bpsize"."$bnparts
cp $Bconfig $newBconfig
sed -i '/.*filter_length.*/c\'$bflength';' $newBconfig

### Remplaza el nuevo valor -pXXXX  en jack_options
# Quitamos espacios
jack_options=$(echo $jack_options | sed s/\ -/xxx-/g)
jack_options=$(echo $jack_options | sed s/\ //g)
jack_options=$(echo $jack_options | sed s/xxx-/\ -/g)
# Procesamos los parámetros en forma de array
readarray -td" " array <<< $jack_options
new_jack_options=""
for cosa in "${array[@]}"; do
    if [[ $cosa != *"-p"* ]]; then
        new_jack_options=$new_jack_options" "$cosa
    else
        new_jack_options=$new_jack_options" -p"$jperiod
    fi
done

### Detiene Jack-Brutefir y Ecasound
pkill -f -KILL jackd
pkill -f -KILL "bin/ecasound"
sleep 1

### Arranca JACK
cmd="jackd "$new_jack_options" -d"$system_card" -r"$fs
echo ""
echo "--- Esperando a  JACK:"
echo $cmd
$cmd &
# Esperamos hasta 10s a que Jack esté disponible
i=(0)
while (( $i <= 10 )); do
    tmp=$(jack_lsp)
    if [[ $tmp ]]; then
        break
    fi
    ((i++))
    sleep 1
done
if (( i >= 10 )); then
    echo ""
    echo "(!) ERROR arrancando JACK."
    echo ""
    exit 0
fi

### Arranca Brutefir con el nuevo archivo brutefir_config
echo ""
echo "--- Arrancando BRUTEFIR:"
echo $brutefir_path $newBconfig
$brutefir_path $newBconfig &
sleep 3

### Arranca Ecasound
if [[ $load_ecasound == "True" ]]; then
    cmd=$ecasound_path" -q --server -s:"$ecsFile
    echo ""
    echo "--- Arrancando ECASOUND:"
    echo $cmd
    $cmd &
    sleep 1
fi

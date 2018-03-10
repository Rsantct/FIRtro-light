#!/bin/bash

# v0.1BETA
# Cutre script que permite relanzar jack/brutefir/ecasound de FIRtro
# ajustando un nuevo --period XXXX en Jack y con filter_length acorde en Brutefir.
# (se creará un nuevo archivo brutefir_config.XXXX al efecto)
#
# v0.2bBETA
# admite cambio de Fs para ensayos...
# y se restaura el level de FIRtro para evitar sustos...
# y admite -P para jackd solo Playback
#
# v0.3BETA
# Se particiona Brutefir usando particiona_brutefir.py
# (se verifica que Brutefir partition size >= Jack buffer size)
#
# TO DO: esto empezó como un script sencillo en bash,
#        pero habría que reescribirlo en python
#

home="/home/firtro"

function ayuda () {
    echo
    echo "  Uso: restart_jack.sh -jp=XXX -bflen=XXX [-jn=X -bfmaxp=XX -r=Fs -jP]"
    echo
    echo "         -jp=XXX      Jack period"
    echo "         -jn=X        Jack numper of periods (default audio/config)"
    echo "         -jP          solo playback"
    echo
    echo "         -bflen=XXX   Brutefir filter length (default 32K)"
    echo "         -bfmaxp=XXX  Brutefir max partitions (default 16)"
    echo
    echo "       nota: sin espacios entre el signo ="
    echo
}

function lee_audio_config () { ### Lee audio/config
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
}

function array_contains () {
    # Retorna 0 si el array contiene el elemento buscado.
    # El primer elemento proporcionado al llamar la función es lo buscado,
    # el resto es donde se busca. Sí, lo se, es cutre.
    local result=-1
    local arr=($@)
    local buscado="${arr[0]}"
    for i in "${arr[@]:1}"; do
        if [[ $buscado == $i ]]; then
            local result=0
        fi
    done
    return $result
}

# Valores de buffer validos:
bvalid=(64 128 256 512 1024 2048 4096 8192 16384)
# Valores de fs válidos
fsvalid=(44100 48000 96000 192000)

# Valore por defecto
fs="44100"        # Fs por defecto
jP="no"           # Jack only Playback
BFFL="32768"      # Brutefir filter length
BFMP="16"         # Brutefir max partitions

# Leemos los valores solicitados
for opc in $@; do
    if [[ $opc == *"-h"* ]]; then
        ayuda
        exit 0
    fi
    if [[ $opc == *"-bflen="* ]]; then
        let BFFL=${opc/-bflen=/}
    fi
    if [[ $opc == *"-bfmaxp="* ]]; then
        let BFMP=${opc/-bfmaxp=/}
    fi
    if [[ $opc == "-jP" ]]; then
        jP="si"
    fi
    if [[ $opc == *"-jp="* ]]; then
        let jperiod=${opc/-jp=/}
        if [[ " ${bvalid[*]} " != *"$jperiod"* ]]; then
            echo $jperiod es incorrecto
            exit 0
        fi
    fi
    if [[ $opc == *"-jn="* ]]; then
        let jnperiods=${opc/-jn=/}
    fi
    if [[ $opc == *"-r="* ]]; then
        let tmp=${opc/-r=/}
        #if [[ " ${fsvalid[*]} " == $tmp ]]; then
        if array_contains $tmp "${fsvalid[@]}"; then
            fs=$tmp
        else
            echo $tmp es incorrecto
            exit 0
        fi
    fi
done
if [[ ! $1 ]]; then
    ayuda
    exit 0
fi

### Lee audio/config
lee_audio_config

### Particionado de Brutefir
echo "--- Calculando particionado de Brutefir"
cmd="python /home/firtro/bin_custom/particiona_brutefir.py \
             -jp=$jperiod -bflen=$BFFL -bfmaxp=$BFMP"
if [[ $jnperiods ]]; then
    cmd=$cmd" -jn="$jnperiods
fi
# Vemos la llamada al script auxiliar 'particiona_brutefir.py'
echo $cmd
tmp=$($cmd)
if [[ ! $tmp ]]; then
    echo
    echo "(i) ERROR: Brutefir partition size >= Jack buffer size"
    echo
    exit -1
fi

bpsize=$(echo $tmp | cut -d"," -f1)
bnparts=$(echo $tmp | cut -d"," -f2)
bfflength="filter_length:"$bpsize","$bnparts
echo $bfflength

### Prepara un nuevo archivo 'brutefir_config'
tmp=$(pgrep -fla brutefir)
for opc in ${fsvalid[@]}; do
    if [[ $tmp == *$opc* ]]; then
        fsOld=$opc
    else # por si acaso brutefir no estuviera funcionando
        fsOld=$fs
    fi
done
mkdir -p $home"/lspk/"$loudspeaker"/"$fs"/"
Bconfig=$home"/lspk/"$loudspeaker"/"$fsOld"/brutefir_config"
newBconfig=${Bconfig/$fsOld/$fs}"."$bpsize"."$bnparts
cp $Bconfig $newBconfig
sed -i '/.*filter_length.*/c\'$bfflength';' $newBconfig
sed -i '/.*sampling_rate:.*/c\sampling_rate:'$fs';' $newBconfig

### Remplaza el nuevo valor -pXXXX y/o -nX  en jack_options
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
readarray -td" " array <<< $new_jack_options
new_jack_options=""
for cosa in "${array[@]}"; do
    if [[ $cosa != *"-n"* ]]; then
        new_jack_options=$new_jack_options" "$cosa
    else
        new_jack_options=$new_jack_options" -n"$jnperiods
    fi
done


#######################################################################

### Detiene Jack-Brutefir y Ecasound
pkill -f -KILL jackd
pkill -f -KILL "bin/ecasound"
sleep 1

### Arranca JACK
cmd="jackd "$new_jack_options" -d"$system_card" -r"$fs
if [[ $jP == "si" ]] && [[ $new_jack_options != *"-P"* ]]; then
    cmd=$cmd" -P"
fi
echo ""
echo "--- Esperando a JACK:"
echo $cmd
$cmd &
# Esperamos hasta 5 s a que Jack esté disponible
i=(0)
while (( $i <= 5 )); do
    tmp=$(jack_lsp system)
    if [[ $tmp ]]; then
        break
    fi
    ((i++))
    sleep 1
done
if (( i >= 5 )); then
    echo
    echo "(!) ERROR arrancando JACK."
    echo
    exit -1
fi

### Arranca Brutefir con el nuevo archivo brutefir_config
echo ""
echo "--- Arrancando BRUTEFIR:"
echo $brutefir_path $newBconfig
$brutefir_path $newBconfig &
# Esperamos hasta 5s a que Brutefir esté disponible
i=(0)
while (( $i <= 5 )); do
    tmp=$(jack_lsp brutefir)
    if [[ $tmp ]]; then
        break
    fi
    ((i++))
    sleep 1
done
if (( i >= 5 )); then
    echo
    echo "(i) ERROR arrancando BRUTEFIR."
    echo
    exit -1
fi

### Arranca Ecasound
if [[ $load_ecasound == "True" ]]; then
    cmd=$ecasound_path" -q --server -s:"$ecsFile
    echo
    echo "--- Arrancando ECASOUND:"
    echo $cmd
    $cmd &
    sleep 1
    # Esperamos hasta 5s a que Ecasound esté disponible
    i=(0)
    while (( $i <= 5 )); do
        tmp=$(jack_lsp ecasound)
        if [[ $tmp ]]; then
            break
        fi
        ((i++))
        sleep 1
    done
    if (( i >= 5 )); then
        echo
        echo "(i) ERROR arrancando ECASOUND."
        echo
        exit -1
    fi
fi

echo
echo "--- (i) brutefir_config anterior:"
echo "    "$Bconfig
echo
echo "--- (i) brutefir_config nuevo:"
echo "    "$newBconfig
echo
if [[ $jP ]]; then
    echo "Jack Only Playback:  "true
else
    echo "Jack Only Playback:  "false
fi
echo "Jack buffer:         "$(( $jperiod * $jnperiods )) "("$jperiod" x "$jnperiods")"
echo "Brutefir part. size: "$bpsize" ("$bfflength" = "$(( $bpsize * $bnparts ))")"
echo "Fs:                  "$fs
echo "Done."

echo "Restaurando el volumen de FIRtro"
/home/firtro/bin/control level_add 0

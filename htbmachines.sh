#!/bin/bash

set -euo pipefail

# Colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
bell=$(printf '\a')

# Salida a peticion del usuario.
function ctrl_c(){
    echo -e "\n${redColour} [!] Saliendo...${endColour}\n"
    tput cnorm && exit 1
}
# Ctrl+C
trap ctrl_c INT

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"

# Confirma la proposicion.
function yes_or_no() {
  while true; do
    read -p "$*[y/n]: " yn
      case $yn in
        [Yy]*) return 0  ;;
        [Nn]*) ctrl_c ;;
      esac
  done
}

# Abre la web para mas informacion.
function abrirWebInfosecmachines(){
    echo -e "\n[+] Deseas ver los détalles de una maquina en la pagina web de busqueda https://infosecmachines.io/ ? ${bell}\n"
    yes_or_no
    if [ $? -eq 0 ]; then
        echo -e "\nAbriendo https://infosecmachines.io/\n"
        xdg-open "https://infosecmachines.io/" &
    fi
}

# -h Imprime el menu de ayuda.
function helpPanel(){
    printf "
           ${purpleColour} ━━━━━━━━┓
         ${yellowColour}┏━━━━━━━━┓ ${purpleColour}┋   
         ${yellowColour}┋        ┋ ${purpleColour}┋  
         ${yellowColour}┋        ┋ ${purpleColour}┋  ${purpleColour}HackTheBox machines${endColour} 
         ${yellowColour}┋        ┋    -------------------
         ${yellowColour}┗━━━━━━━━┛ 
         "
    echo -e "\n  ${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
    echo -e "      ${purpleColour}u)${endColour} Descargar o actualizar archivos nécésarios."
    echo -e "      ${purpleColour}m)${endColour} Buscar por un nombre de máquina."
    echo -e "      ${purpleColour}i)${endColour} Buscar por direccion ip."
    echo -e "      ${purpleColour}d)${endColour} Buscar por dificultad de una máquina. Fácil, Media, Difícil, Insane."
    echo -e "      ${purpleColour}o)${endColour} Buscar por systèma operativo."
    echo -e "      ${purpleColour}s)${endColour} Buscar por Skills."
    echo -e "      ${purpleColour}y)${endColour} Obtener link de la resolucion de la máquina en youtube."
    echo -e "      ${purpleColour}h)${endColour} Mostrar este panel de ayuda.\n"
}

# -u Comprueba, descarga actualizaciones.
function updateFiles(){
    tput civis
    if [ ! -f bundle.js ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
        curl -s $main_url > bundle.js
        js-beautify bundle.js | sponge bundle.js
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados.${endColour}\n"
    else
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando si hay actualizaciones.${endColour}"

        curl -s $main_url > bundle_temp.js
        js-beautify bundle_temp.js | sponge bundle_temp.js

        md5_temp_value="$(md5sum bundle_temp.js| awk '{print $1}')"
        md5_original_value="$(md5sum bundle.js| awk '{print $1}')"

        if [ "$md5_temp_value" == "$md5_original_value" ]; then
            echo -e "\n${yellowColour}[+]${endColour}${grayColour} No se han detectado actualizaciones, lo tienes todo al dia.${endColour}\n"
            rm bundle_temp.js
        else
            echo -e "\n${yellowColour}[+]${endColour}${grayColour} Se han encontrado actualizaciones disponibles.${endColour}"
            sleep 2
            cp bundle_temp.js bundle.js
            rm bundle_temp.js
            echo -e "\n${yellowColour}[+]${endColour}${grayColour} Actualizaciones terminadas.${endColour}\n"
        fi
    fi
    tput cnorm
}

# -m Busca las propriedades de la máquina con su nombre en argumento.
function searchMachine(){
    machineName="$1"
    resultado="$(cat bundle.js| awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
    
    if [ "$resultado" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propriedades de la máquina${endColour}${blueColour} $machineName${endColour}${grayColour} ${endColour}\n"
        content=""

        while IFS= read -r line
        do
            property=" \u21E8 ${yellowColour}$(echo "$line" | awk '{printf $1}' NF=':')${endColour}"
            value="$(echo "$line" | awk '{printf $2}' NF=':')"

            OPTION="${value}"
            case $OPTION in
            "${machineName}")
                content="${blueColour}$value${endColour}"
            ;;
            "Fácil")
                content="${greenColour}$value${endColour}"
            ;;
            "Media")
                content="${yellowColour}$value${endColour}"
            ;;
            "Difícil")
                content="${redColour}$value${endColour}"
            ;;
            "Insane")
                content="${turquoiseColour}$value${endColour}"
            ;;
            "Linux")
                content="${purpleColour}$value${endColour}"
            ;;
            "Windows")
                content="${greenColour}$value${endColour}"
            ;;
            *)
            content="${value}"
            ;;
            esac

            echo -e "${property} ${content}"

        done < <(printf '%s\n' "$resultado")

        echo
    else
        echo -e "\n${redColour}[!]${endColour}${grayColour} La máquina${endColour}${blueColour} $machineName${endColour}${grayColour} no existe.${endColour}\n"
        echo -e "$bell"
    fi
}

# -i Busca el nombre de la maquina por su ip.
function searchIP(){
    ip="$1"
    machine="$(cat bundle.js | grep "ip: \"${ip}\"" -B3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
    if [ "$machine" ]; then
        echo -e "\n${yellowColour}[+]${endColour} La IP es ${ip} "
        echo -e "    Máquina: ${blueColour}${machine}${endColour}\n"
    else
        echo -e "\n${redColour}[!]${endColour} La direccion IP ${redColour}${ip}${endColour} no existe. \n"
        echo -e "$bell"
    fi
}

# -y Obtener el enlace de Youtube.
function getYoutubeLink(){
    machineName="$1"
    resultado="$(cat bundle.js | awk "/name: \"${machineName}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^*//' | grep youtube | awk 'NF{print $NF}')"
    if [ "$resultado" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} El tutorial para la máquina${endColour}${blueColour} ${machineName}${endColour}${grayColour} esta en el siguiente enlace:${endColour}"
        echo -e "    ${blueColour}${resultado}${endColour}\n"
    else
        echo -e "\n${redColour}[!]${endColour} No hay vidéo disponible para la máquina${blueColour}${resultado}${endColour}. \n"
        echo -e "$bell"
    fi
}

# -d Buscar por dificultad de las maquinas.
function getMachinesDifficulty(){
    difficulty="$1"
    colorLevel="${endColour}"

    if [ "$difficulty" == "Facil" ]; then difficulty="Fácil"; fi      # Filtra los acentos
    if [ "$difficulty" == "Dificil" ]; then difficulty="Difícil"; fi  # ------------------
    if [ "$difficulty" == "Fácil" ] || [ "$difficulty" == "Media" ] || [ "$difficulty" == "Difícil" ] || [ "$difficulty" == "Insane" ]; then
        
        OPTION="$difficulty"
        case $OPTION in
        "Fácil")
            colorLevel="${greenColour}"
        ;;
        "Media")
            colorLevel="${yellowColour}"
        ;;
        "Difícil")
            colorLevel="${redColour}"
        ;;
        "Insane")
            colorLevel="${turquoiseColour}"
        ;;
        *)
        echo “Nivel indefinido”
        exit 1
        esac
        
        resultado="$(cat bundle.js | grep "dificultad: \"${difficulty}\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | sort | tr -d '"' | tr -d ',' | column)"
        echo -e "\n${colorLevel}${resultado}${endColour}\n"
    else
        echo -e "\n${redColour}[!]${endColour} No hay máquinas de esa dificultad. \n"
        echo -e "$bell"
    fi
}

# -o Buscar por sistema operativo.
function getMachineOS(){
    machineOS="$1"
    resultado="$(cat bundle.js | grep "so: \"${machineOS}\"" -B 5 | grep "name: " | awk '$NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    if [ "$resultado" ];then
        echo -e "\n${yellowColour}[+]${endColour} Mostrando las máquinas cuyo sistema operativo es ${machineOS}\n"
        if [ "${machineOS}" == "Linux" ];then
            echo -e "${greenColour}${resultado}${endColour}\n"
        else
            echo -e "${purpleColour}${resultado}${endColour}\n"
        fi
    else
        echo -e "[!] El systema operativo indicado no existe..."
    fi
}

# -d & -o
function getOSDifficultyMachines(){
    difficulty="$1"
    os="$2"
    checkResults="$(cat bundle.js | grep "so: \"${os}\"" -C 4 | grep "dificultad: \"${difficulty}\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    echo -e "\n${checkResults}\n"
    if [ -n "$checkResults" ]; then
        echo -e "\n[+] Listando maquinas de dificultad $difficulty que tengan systema operativo $os :\n"
        echo -e "${checkResults}"
    else
        echo -e "\n[!] Se ha indicado una dificultad o sistema operativo incorrectos.\n"
    fi
}

function getSkill(){
    skill=$1 
    # TODO: acabar esta funcionalidad !!!
    
}

# Vars, Indicadores, Chivatos (flag) -i es un integer.
declare -i parameter_counter=0
machineName=""
declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:ui:y:d:o:s:,h" arg; do
    case $arg in
        d) let parameter_counter+=5 ; chivato_difficulty=1 difficulty="$OPTARG";;
        h) ;; #helpPanel
        i) let parameter_counter+=3 ; ip="$OPTARG";;
        m) let parameter_counter+=1 ; machineName="$OPTARG";;
        o) let parameter_counter+=6 ; chivato_os=1 machineOS="$OPTARG";;
        s) let parameter_counter+=7 ; skill="$OPTARG";;
        u) let parameter_counter+=2;;
        y) let parameter_counter+=4 ; machineName="$OPTARG";;
    esac
done

# Si on a passé un paramettre avec -m
if [ $parameter_counter -eq 1 ]; then
    searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
    updateFiles
elif [ $parameter_counter -eq 3 ]; then
    searchIP $ip
elif [ $parameter_counter -eq 4 ]; then
    getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
    getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
    getMachineOS $machineOS
elif [ $parameter_counter -eq 7 ]; then
    getSkill $skill
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ] ; then
    getOSDifficultyMachines $difficulty $machineOS ; abrirWebInfosecmachines
else
    helpPanel
fi

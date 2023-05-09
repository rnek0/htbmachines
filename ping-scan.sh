#!/bin/bash

function ctrl_c(){
  echo -e " [-] Saliendo...\n"
  tput cnorm; exit 1
}
tput civis
trap ctrl_c INT

echo -e " Ping de red local : 192.168.1.0/24 "

function scan(){
  echo -ne " > $1 \r"
  sleep 0.1
}

for i in $(seq 1 254); do
#  scan $i 
  timeout 1 bash -c "ping -c 1 192.168.1.$i" &>/dev/null && scan $i && echo -e " [+] 192.168.1.$i \tup" &
done
wait

tput cnorm; exit 1

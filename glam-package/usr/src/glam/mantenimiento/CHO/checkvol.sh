#!/bin/bash

selected=0

if [ -z "$SUDO_USER" ]; then
    dialog --colors --title "\Z1ERROR" --msgbox "Este script debe ser ejecutado con sudo" 0 0
    clear
    return
fi

checar() {
    mkdir -p /var/glam/logs/chequeo
    local hora=$(date +'%d-%m-%H%M')
    local tmp=/var/glam/tmp/chequeoDEV"$1".tmp
    local log=/var/glam/logs/chequeo/chequeoDEV"$1"_"$hora".log
    fsck -y /dev/"$1" >>"$tmp" 2>&1
    if [[ $? -eq 0 ]]; then
        dialog --clear --title "Chequeo de volumenes al arranque(UNICO)" \
            --msgbox "El chequeo realizado con exito" 0 0
        echo /dev/"$1 chequeo exitoso" >>"$log"
    else
        dialog --clear --title "Chequeo de volumenes al arranque(UNICO)" \
            --msgbox "El dispositivo tiene errores" 0 0
        echo /dev/"$1 chequeo fallido" >>"$log"
    fi
    echo "" >>"$log"
    cat "$tmp" >>"$log"
    rm "$tmp"
}
# Conseguir los dispositivos de almacenamiento
lsblk --all -nr >/var/glam/tmp/lsblk.tmp

# buscar el dispositivo de almacenamiento que
# este montado en /
while read -r line; do
    if [[ $(echo "$line" | awk '{print $7}') == "/" ]]; then
        # guardar el nombre del dispositivo en la variable dispositivo
        raiz=$(echo "$line" | awk '{print $1}')
    fi
done </var/glam/tmp/lsblk.tmp
# si raiz es una particion, indicar el dispositivo sin
raiz=$(echo "$raiz" | sed 's/[0-9]*$//g')

# leer linea por linea (cada linea es un dispositivo)
# cada linea se guardara en un vector llamado devices
# el formato que se guardara sera el campo 1 4 y 6
# cada vez que se lee una linea se tiene que agregar dos elementos al vector
# el primer elemento es un contador empezado en 1
# el segundo elemento es el nombre del dispositivo
i=0
contador=1
while read -r line; do
    # si el nombre del dispositivo contiene el nombre de la raiz
    if [[ $(echo "$line" | awk '{print $1}') == *"$raiz"* ]]; then
        continue
    fi
    devices[i]=$(echo "$line" | awk '{print $1}')
    devices[i + 1]=$(echo "$line" | awk '{print $4,$6}')
    #tabular
    devices[i + 1]="$(printf '%-7s%-7s' ${devices[i + 1]})"
    i=$((i + 2))
    contador=$((contador + 1))
done </var/glam/tmp/lsblk.tmp
    
rm /var/glam/tmp/lsblk.tmp
#obtenemos el nombre del dispositivo
dispositivo=$(dialog --clear --title "Chequeo de volumenes al arranque(UNICO)" \
    --cancel-label "Cancelar" --ok-label "Select" \
    --menu "Seleccione una opción:" 0 0 0 "${devices[@]}" \
    --output-fd 1)
# si se cancela el dialogo salir
if [[ $? -eq 1 ]]; then
    clear
    return
fi

#si el dispositivo esta montado desmontarlo
if [[ $(mount | grep "$dispositivo") ]]; then
    umount /dev/"$dispositivo"
    checar "$dispositivo"
    mount /dev/"$dispositivo"
else
    checar "$dispositivo"
fi

clear

return

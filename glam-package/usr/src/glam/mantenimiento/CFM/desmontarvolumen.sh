#!/bin/bash

if [ -z "$SUDO_USER" ]; then
    dialog --colors --title "\Z1ERROR" --msgbox "Este script debe ser ejecutado con sudo" 0 0
    clear
    return
fi

# Conseguir los dispositivos de almacenamiento
lsblk -nr >/var/glam/tmp/lsblk.tmp

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

# eliminar el dispositivo raiz de la lista
sed -i "/$raiz/d" /var/glam/tmp/lsblk.tmp
# Se crea un arreglo con los nombres de los volumenes
i=0
part=()
while read -r line; do
    device=$(echo "$line" | awk '{print $1}')

    # si no es un block device continuar con el siguiente ciclo
    if [[ $(echo "$line" | awk '{print $7}') == "[SWAP]" ||  $(echo "$line" | awk '{print $6}') == "rom" ]]; then
        continue
    fi
    # saltar los volumenes que no esten montados
    if [[ $(echo "$line" | awk '{print $7}') == "" ]]; then
        continue
    fi

    part[i]=$(echo "$line" | awk '{print $1}')
    part[i + 1]=$(lsblk -d -n -o MOUNTPOINT /dev/$device)
    i=$((i + 2))
done < /var/glam/tmp/lsblk.tmp

rm /var/glam/tmp/lsblk.tmp

# si el vector esta vacio, mostrar mensaje y salir
if [[ ${#part[@]} -eq 0 ]]; then
    dialog --clear --title "Desmontar volumen" \
        --msgbox "No se encontraron dispositivos de almacenamiento" 0 0
    clear
    return
fi

selected=$(dialog --clear --title "Montar volumen" \
    --cancel-label "Return" --ok-label "Select" \
    --menu "Seleccione una particion:" 0 0 0 "${part[@]}" \
    --output-fd 1)

if [[ $? -ne 0 ]]; then
    clear
    return
fi

# conseguir el punto de montaje del volumen
punto=$(lsblk -n -o MOUNTPOINT /dev/$selected)

# desmontar el volumen si esta montado
umount /dev/$selected >/dev/null 2>&1

# eliminar el punto de montaje si existe
if [[ -d "$punto" ]]; then
    rm -r "$punto"
fi

dialog --clear --title "Desontar volumen" \
    --msgbox "Volumen desmontado con exito" 0 0

return

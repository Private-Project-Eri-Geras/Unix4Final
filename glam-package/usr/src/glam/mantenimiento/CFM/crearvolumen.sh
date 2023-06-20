#!/bin/bash

if [ -z "$SUDO_USER" ]; then
    dialog --colors --title "\Z1ERROR" --msgbox "Este script debe ser ejecutado con sudo" 0 0
    clear
    return
fi

# Se pone en un archivo temporal
(lsblk -d -n -o NAME) > /var/glam/tmp/volumenes.tmp
# Se crea un arreglo con los nombres de los volumenes
i=0
while read -r line; do
    part[i]=$(echo "$line" | awk '{print $1}')
    part[i + 1]=$(lsblk -d -n -o SIZE /dev/${part[$i]})
    i=$((i + 2))
done < /var/glam/tmp/volumenes.tmp

rm /var/glam/tmp/volumenes.tmp

selected=$(dialog --clear --title "Crear volumen" \
    --cancel-label "Return" --ok-label "Select" \
    --menu "Seleccione una particion:" 0 0 0 "${part[@]}" \
    --output-fd 1)

if [[ $? -ne 0 ]]; then
    clear
    return
fi

# si el disco esta en uso no se puede crear un volumen
if [[ $(lsblk -d -n -o RM /dev/${part[$((selected))]} | awk '{print $1}') == 0 ]]; then
    dialog --colors --title "\Z1ERROR" --msgbox "El disco esta en uso" 0 0
    clear
    return
fi

fdisk /dev/${part[$((selected * 2 - 1))]} <<EOF
n
p
1


w
EOF



return

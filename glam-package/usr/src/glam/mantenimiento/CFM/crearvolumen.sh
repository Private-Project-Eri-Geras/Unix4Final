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

# extraer la raiz y los volumenes montados
# de los volumenes disponibles
sed -i "/$raiz/d" /var/glam/tmp/volumenes.tmp

# eliminar todos las particiones que esten montadas
# o discos con particiones montadas
while read -r line; do
    if [[ $(echo "$line" | awk '{print $7}') =~ '/' ]]; then
        sed -i "/$(echo "$line" | awk '{print $1}')/d" /var/glam/tmp/volumenes.tmp
    fi
done < /var/glam/tmp/volumenes.tmp

# Se crea un arreglo con los nombres de los volumenes
i=0
while read -r line; do
    device=$(echo "$line" | awk '{print $1}')
    # si no es un block device continuar con el siguiente ciclo
    lsblk -d -n -o TYPE /dev/$device >/dev/null 2>&1
    if [[ $? != 0 ]]; then
        continue
    fi
    part[i]=$device
    part[i + 1]=$(lsblk -d -n -o SIZE /dev/$device)
    i=$((i + 2))
done < /var/glam/tmp/volumenes.tmp

selected=$(dialog --clear --title "Crear volumen" \
    --cancel-label "Return" --ok-label "Select" \
    --menu "Seleccione una particion:" 0 0 0 "${part[@]}" \
    --output-fd 1)

if [[ $? -ne 0 ]]; then
    clear
    return
fi



# Preguntar el tamaño del volumen
# no puede ser superoior al tamaño del disco seleccionado
# si se selecciono un disco con particiones
# el tamaño del volumen no puede ser superior al tamaño libre del disco
free=$(lsblk -d -n -o SIZE /dev/sdb)
# si el disco tiene particiones
if [[ $(lsblk -d -n -o TYPE /dev/sdb) == "disk" ]]; then
    # si el disco tiene particiones
    # se calcula el tamaño libre del disco
    while read -r line; do
        if [[ $(echo "$line" | awk '{print $7}') =~ '/' ]]; then
            free=$(echo "$free - $(echo "$line" | awk '{print $4}')")
        fi
    done < /var/glam/tmp/volumenes.tmp
fi

clear 
echo "Tamaño del disco: $free"
read -sn 1
rm /var/glam/tmp/volumenes.tmp
rm /var/glam/tmp/lsblk.tmp
fdisk /dev/${part[$((selected * 2 - 1))]} <<EOF
n
p
1


w
EOF



return

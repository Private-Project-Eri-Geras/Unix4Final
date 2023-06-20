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
sed -i "/$raiz/d" /var/glam/tmp/lsblk.tmp

# eliminar todos las particiones que esten montadas
# o discos con particiones montadas
while read -r line; do
    if [[ $(echo "$line" | awk '{print $7}') =~ '/' ]]; then
        sed -i "/$(echo "$line" | awk '{print $1}')/d" /var/glam/tmp/lsblk.tmp
    fi
done < /var/glam/tmp/lsblk.tmp

# Se crea un arreglo con los nombres de los volumenes
i=0
while read -r line; do
    device=$(echo "$line" | awk '{print $1}')
    # si no es un block device continuar con el siguiente ciclo
    lsblk -d -n -o TYPE /dev/$device >/dev/null 2>&1
    if [[ $? != 0 ||  $(echo "$line" | awk '{print $7}') == "[SWAP]" ||  $(echo "$line" | awk '{print $6}') == "rom" ]]; then
        continue
    fi
    part[i]=$device
    part[i + 1]=$(lsblk -d -n -o SIZE /dev/$device)
    i=$((i + 2))
done < /var/glam/tmp/lsblk.tmp

# si el vector esta vacio, mostrar mensaje y salir
if [[ ${#part[@]} -eq 0 ]]; then
    dialog --clear --title "Crear volume" \
        --msgbox "No se encontraron dispositivos de almacenamiento" 0 0
    clear
    return
fi

selected=$(dialog --clear --title "Crear volumen" \
    --cancel-label "Return" --ok-label "Select" \
    --menu "Seleccione una particion:" 0 0 0 "${part[@]}" \
    --output-fd 1)

if [[ $? -ne 0 ]]; then
    clear
    return
fi


dialog --clear --title "Crear volumen" \
    --yesno "Se va a crear una particion en el dispositivo $selected
    utilizando todo el espacio disponible.
    Continuar?" 0 0
if [[ $? -ne 0 ]]; then
    return
fi

rm /var/glam/tmp/lsblk.tmp
fdisk /dev/${part[$((selected * 2 - 1))]} <<EOF
n
p
1


w
EOF

dialog --clear --title "Crear volumen" \
    --msgbox "Volumen creado con exito" 0 0

return

#!/bin/bash

selected=0

# Conseguir los dispositivos de almacenamiento
lsblk --all -nr > /tmp/lsblk.txt

# buscar el dispositivo de almacenamiento que
# este montado en /
while read -r line; do
    if [[ $(echo "$line" | awk '{print $7}') == "/" ]]; then
        # guardar el nombre del dispositivo en la variable dispositivo
        raiz=$(echo "$line" | awk '{print $1}')
    fi
done < /tmp/lsblk.txt
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
    devices[i+1]=$(echo "$line" | awk '{print $4,$6}')
    #tabular 
    devices[i+1]="$(printf '%-7s%-7s' ${devices[i+1]})"
    i=$((i+2))
    contador=$((contador+1))
done < /tmp/lsblk.txt

#obtenemos el nombre del dispositivo
dispositivo=$(dialog --clear --title "Chequeo de volumenes al arranque(UNICO)" \
        --cancel-label "Cancelar" --ok-label "Select" \
        --menu "Seleccione una opción:" 0 0 0 "${devices[@]}" \
        --output-fd 1)

echo "$dispositivo"

#si el dispositivo esta montado desmontarlo
if [[ $(mount | grep "$dispositivo") ]]; then
    umount /dev/"$dispositivo"
    fsck -y /dev/"$dispositivo"
    if [[ $? -eq 0 ]]; then
        dialog --clear --title "Chequeo de volumenes al arranque(UNICO)" \
            --msgbox "El chequeo realizado con exito" 0 0
        echo "" >> mantenimiento/CHO/fsck_output.tmp
        echo /dev/"$dispositivo chequeo exitoso" >> mantenimiento/CHO/fsck_output.tmp
    else
        dialog --clear --title "Chequeo de volumenes al arranque(UNICO)" \
            --msgbox "El dispositivo tiene errores" 0 0
        echo "" >> mantenimiento/CHO/fsck_output.tmp
        echo /dev/"$dispositivo chequeo fallido" >> mantenimiento/CHO/fsck_output.tmp
    fi
    fsck -y /dev/"$dispositivo" >> mantenimiento/CHO/fsck_output.tmp 2>&1
    mount /dev/"$dispositivo"
else
    fsck -y /dev/"$dispositivo"
    fsck -y /dev/"$dispositivo"
    if [[ $? -eq 0 ]]; then
        dialog --clear --title "Chequeo de volumenes al arranque(UNICO)" \
            --msgbox "El chequeo realizado con exito" 0 0
        echo "" >> mantenimiento/CHO/fsck_output.tmp
        echo /dev/"$dispositivo chequeo exitoso" >> mantenimiento/CHO/fsck_output.tmp
    else
        dialog --clear --title "Chequeo de volumenes al arranque(UNICO)" \
            --msgbox "El dispositivo tiene errores" 0 0
        echo "" >> mantenimiento/CHO/fsck_output.tmp
        echo /dev/"$dispositivo chequeo fallido" >> mantenimiento/CHO/fsck_output.tmp
    fi
    fsck -y /dev/"$dispositivo" >> mantenimiento/CHO/fsck_output.tmp 2>&1
fi



clear

return
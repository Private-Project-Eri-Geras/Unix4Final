#!/bin/bash

options=(
    1 "Habilitar chequeos de volumen al arranque"
    2 "Deshabilitar chequeos de volumen al arranque"
)

selected=0

if [ -z "$SUDO_USER" ]; then
    dialog --colors --title "\Z1ERROR" --msgbox "Este script debe ser ejecutado con sudo" 0 0
    clear
    return
fi

backup_file="fstab_backup.txt"

if [ ! -s "$backup_file" ]; then
# Realizar la copia de seguridad
cat /etc/fstab > "$backup_file"
fi

clear

while true; do
    # Mostrar el menu y cambiar el valor de la variable $selected
    selected=$(dialog --clear --title "Chequeo de volumenes al arranque(GENERAL)" \
        --cancel-label "Return" --ok-label "Select" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

    if [[ $? -ne 0 ]]; then
        break
    fi

    case $selected in
    1)
        # Montar todos los dispositivos
        while IFS= read -r line
        do
        # Omitir líneas que comienzan con #
        if [[ $line =~ ^[^#] ]]; then
            # Buscar las líneas que comienzan con UUID o LABEL
            if [[ $line =~ ^(UUID|LABEL)= ]]; then
            # Extraer el dispositivo
            device=$(echo "$line" | awk '{print $1}')
            # Verificar si el dispositivo es el disco principal
                if [[ $device == $(df / | awk 'NR==2 {print $1}') ]]; then
                    echo "El dispositivo $device es el disco principal. No se realizarán cambios."
                else
                    echo "Desmontando $device"
                    umount "$device"  # Desmontar el sistema de archivos
                    # Modificar la línea para activar el chequeo al arranque (cambiar '0' a '1')
                    modified_line=$(echo "$line" | awk '{$NF="1"; print}')
                    echo "Modificando línea: $line"
                    echo "$modified_line"
                    # Reemplazar la línea original con la línea modificada en el archivo /etc/fstab
                    sed -i "s|$line|$modified_line|" /etc/fstab
                    echo "Montando $device"
                    mount "$device"  # Volver a montar el sistema de archivos
                fi
            fi
        fi
        done < /etc/fstab
        ;;
    2)
        while IFS= read -r line
        do
        # Omitir líneas que comienzan con #
        if [[ $line =~ ^[^#] ]]; then
            # Buscar las líneas que comienzan con UUID o LABEL
            if [[ $line =~ ^(UUID|LABEL)= ]]; then
            # Extraer el dispositivo
            device=$(echo "$line" | awk '{print $1}')
            # Verificar si el dispositivo es el disco principal
                if [[ $device == $(df / | awk 'NR==2 {print $1}') ]]; then
                    echo "El dispositivo $device es el disco principal. No se realizarán cambios."
                else
                    echo "Desmontando $device"
                    umount "$device"  # Desmontar el sistema de archivos
                    # Modificar la línea para activar el chequeo al arranque (cambiar '0' a '1')
                    modified_line=$(echo "$line" | awk '{$NF="0"; print}')
                    echo "Modificando línea: $line"
                    echo "$modified_line"
                    # Reemplazar la línea original con la línea modificada en el archivo /etc/fstab
                    sed -i "s|$line|$modified_line|" /etc/fstab
                    echo "Montando $device"
                    mount "$device"  # Volver a montar el sistema de archivos
                fi
            fi
        fi
        done < /etc/fstab
        ;;
    esac
    clear
done

clear

return
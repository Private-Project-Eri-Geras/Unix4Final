#!/bin/bash


options=(
    1 "Deshabilitar chequeo de volumen al arranque"
    2 "Habilitar chequeo de volumen al arranque"
selected=0

clear

#obtenemos el nombre del dispositivo
dispositivo=$(dialog --stdout --inputbox "Ingrese el nombre del dispositivo:" 0 0)

#Verificar si el dispositivo existe
if ! lsblk -o NAME | grep -wq "$dispositivo"; then
    dialog --msgbox "El dispositivo $dispositivo no existe." 0 0
    exit 1
fi

while true; do
    # Mostrar el menu y cambiar el valor de la variable $selected
    selected=$(dialog --clear --title "Chequeo de volumenes al arranque(UNICO)" \
        --cancel-label "Retunr" --ok-label "Select" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)
    if [[ $? -ne 0 ]]; then
        break
    fi
    
    #se hace un respaldo********************************************************

    
    case $selected in
    1)
        #Activamos el chequeo de volumen al arranque
        umount "/dev/$dispositivo"
        mount "/dev/$dispositivo"
        dialog --msgbox "Chequeo de volúmenes activado en el dispositivo $dispositivo." 0 0
    2)
        umount "/dev/$dispositivo"
        mount -o remount,ro "/dev/$dispositivo"
        dialog --msgbox "Chequeo de volúmenes desactivado en el dispositivo $dispositivo." 0 0
        ;;
    esac
    clear
done

clear

return
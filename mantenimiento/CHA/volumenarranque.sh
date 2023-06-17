    #!/bin/bash

# Define the options
options=(
    1 "Deshabilitar chequeos de volumen al arranque"
    2 "Habilitar chequeos de volumen al arranque"

selected=0

clear

while true; do
    # Mostrar el menu y cambiar el valor de la variable $selected
    selected=$(dialog --clear --title "Chequeo de volumenes al arranque(GENERAL)" \
        --cancel-label "Retunr" --ok-label "Select" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

    if [[ $? -ne 0 ]]; then
        break
    fi
    
    #se hace un respaldo********************************************************

    
    case $selected in
    1)
        # Desmontar todos los dispositivos
        umount -a
        # Volver a montar todos los dispositivos con el chequeo de volúmenes desactivado
        mount -a
        dialog --msgbox "Chequeo de volúmenes activado." 0 0
        ;;
    2)
        # Desmontar todos los dispositivos
        umount -a
        # Volver a montar todos los dispositivos con el chequeo de volúmenes desactivado
        mount -o remount,ro /
        dialog --msgbox "Chequeo de volúmenes desactivado." 0 0
        ;;
    esac
    clear
done

clear

return
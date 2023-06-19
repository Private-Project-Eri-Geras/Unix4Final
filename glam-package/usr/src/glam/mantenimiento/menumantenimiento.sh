#!/bin/bash

options=(
    1 "Habilitar/inhabilitar chequeos de volumen al arranque"
    2 "Arranque mantenimiento"
    3 "Arranque manual"
    4 "Chuequeo de volumenes"
    5 "Creacion, formato y montaje de volumenes"
)

selected=0

clear

while true; do
    # Mostrar el menu y cambiar el valor de la variable $selected
    selected=$(dialog --clear --title "MENU MANTENIMIENTO" \
        --cancel-label "Return" --ok-label "Select" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

    if [[ $? -ne 0 ]]; then
        break
    fi

    case $selected in
    1)
        (source "/usr/src/glam/mantenimiento/CHA/volumenarranque.sh") #
        ;;
    2)
        (source "/usr/src/glam/mantenimiento/RMT/mantreboot.sh") #
        ;;
    3)
        (source "/usr/src/glam/mantenimiento/RMA/manualreboot.sh") #
        ;;
    4)
        (source "/usr/src/glam/mantenimiento/CHO/checkvol.sh") #
        ;;
    5)
        (source "/usr/src/glam/mantenimiento/CFM/CFMVolum.sh") #
        ;;
    esac

    clear
done

clear

return

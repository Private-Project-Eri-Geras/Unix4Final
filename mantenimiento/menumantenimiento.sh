#!/bin/bash

# Define the options
options=(
    1 "Habilitar/inhabilitar chequeos de volumen al arranque"
    2 "Arranque mantenimiento"
    3 "Arranque manual"
    4 "Chuequeo de volumenes"
    5 "Creacion, formato y montaje de volumenes"
)

# Initialize the selected option
selected=0

# Clear the screen
clear

# Print the menu using dialog
while true; do
    # Mostrar el menu y cambiar el valor de la variable $selected
    selected=$(dialog --clear --title "MENU MANTENIMIENTO" \
        --cancel-label "Return" --ok-label "Select" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

    # Exit if the user presses cancel
    if [[ $? -ne 0 ]]; then
        break
    fi

    # Handle the selected option
    case $selected in
    1)
        (source "mantenimiento/CHA/volumenarranque.sh")#
        ;;
    2)
        (source "mantenimiento/RMT/mantreboot.sh")#
        ;;
    3)
        (source "mantenimiento/RMA/manualreboot.sh")#
        ;;
    4)
        (source "mantenimiento/CHO/checkvol.sh")#
        ;;
    5)
        (source "mantenimiento/CFM/CFMVolum.sh")#
        ;;
    esac

    # Clear the screen
    clear
done

# Exit the script
clear

return
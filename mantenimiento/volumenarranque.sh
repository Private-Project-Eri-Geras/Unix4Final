#!/bin/bash

# Define the options
options=(
    1 "Deshabilitar chequeos de volumen al arranque"
    2 "Habilitar chequeos de volumen al arranque"

# Initialize the selected option
selected=0

# Clear the screen
clear

# Print the menu using dialog
while true; do
    # Mostrar el menu y cambiar el valor de la variable $selected
    selected=$(dialog --clear --title "Chequeo de volumenes al arranque" \
        --cancel-label "Retunr" --ok-label "Select" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

    # Exit if the user presses cancel
    if [[ $? -ne 0 ]]; then
        break
    fi
    
    
    #se hace un respaldo********************************************************

    
    # Handle the selected option
    case $selected in
    1)
        # Desmontar todos los dispositivos
        sudo umount -a

        # Volver a montar todos los dispositivos con el chequeo de volúmenes desactivado
        sudo mount -a
        ;;
    2)
        # Desmontar todos los dispositivos
        sudo umount -a

        # Volver a montar todos los dispositivos con el chequeo de volúmenes desactivado
        sudo mount -o remount,ro /
        ;;

    # Clear the screen
    clear
done

# Exit the script
clear

return
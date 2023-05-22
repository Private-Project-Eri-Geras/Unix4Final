#!/bin/bash

# Define the options
options=(
    1 "Dar de alta masiva a usuarios por archivo"
    2 "Option 2"
    3 "Option 3"
    4 "Exit"
)

# Initialize the selected option
selected=0

# Clear the screen
clear

# Print the menu using dialog
while true; do
    # Show the menu and store the selected option in a variable
    selected=$(dialog --clear --title "MENU PRINCIPAL" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --cancel-label "Exit" \
        --output-fd 1)

    # Handle the selected option
    case $selected in
    1)
        source "subScripts/altaMasivaUsuarios.sh"
        ;;
    2)
        source "subScripts/opcion2.sh"
        ;;
    3)
        source "subScripts/opcion3.sh"
        ;;
    4)
        echo "Saliendo..."
        break
        ;;
    esac

    # Clear the screen
    clear
done

# Exit the script
clear
exit

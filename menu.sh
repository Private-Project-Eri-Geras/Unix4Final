#!/bin/bash

# Define the options
options=(
    1 "Administrar usuarios"
    2 "Tareas de mantenimiento"
    3 "Option 3"
)

# Initialize the selected option
selected=0

# Clear the screen
clear

# Print the menu using dialog
while true; do
    # Mostrar el menu y cambiar el valor de la variable $selected
    selected=$(dialog --clear --title "MENU PRINCIPAL" \
        --cancel-label "Exit" --ok-label "Select" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

    # Exit if the user presses cancel
    if [[ $? -ne 0 ]]; then
        break
    fi

    # Handle the selected option
    case $selected in
    1)
        (source "usuarios/menuUsuarios.sh")
        ;;
    2)
        (source "mantenimiento/manualreboot.sh")
        ;;
    3)s
        source "mantenimiento/opcion3.sh"
        ;;
    esac

    # Clear the screen
    clear
done

# Exit the script
clear
exit

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

    # Handle the selected option
    case $selected in
    1)
        # Desactivar el chequeo de volúmenes al arranque para todos los dispositivos
        while read -r uuid; do
            if [[ -n "$uuid" ]]; then
                # Utiliza sed para comentar la línea correspondiente al UUID en el archivo fstab
                sed -i "s/UUID=$uuid.*/#UUID=$uuid \/\t\text4\tdefaults\t1 1/" /etc/fstab
            fi
        done <<< "$uuids"
        echo "Chequeo de volúmenes al arranque desactivado."
        ;;
    2)
        # Habilitar el chequeo de volúmenes al arranque para todos los dispositivos (opción por defecto)
        while read -r uuid; do
            if [[ -n "$uuid" ]]; then
                # Utiliza sed para reemplazar la línea correspondiente al UUID en el archivo fstab
                sed -i "s/#UUID=$uuid.*/UUID=$uuid \/\t\text4\tdefaults\t1 1/" /etc/fstab
            fi
        done <<< "$uuids"
        echo "Chequeo de volúmenes al arranque habilitado."
        ;;

    # Clear the screen
    clear
done

# Exit the script
clear

return
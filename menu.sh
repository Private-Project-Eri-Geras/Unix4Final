#!/bin/bash

# Define the options
options=(
    "Option 1"
    "Option 2"
    "Option 3"
    "Exit"
)

# Initialize the selected option
selected=0

# Print the menu
while true; do
    # Clear the screen
    clear

    # Print the options
    for ((i = 0; i < ${#options[@]}; i++)); do
        msg="   ${options[$i]}"
        if [[ $i -eq $selected ]]; then
            echo -e "\e[32m$msg\e[0m"
        else
            echo "$msg"
        fi
    done

    # Obtener el número total de opciones
    total_options=${#options[@]}
    # Restar 1 para obtener el índice máximo válido
    max_index=$(($total_options - 1))

    # Obtener la entrada del usuario
    read -sn 1 key

    # Manejar la entrada del usuario
    case $key in
    "j") # flecha arriba
        if [[ $selected -gt 0 ]]; then
            selected=$((selected - 1))
        else
            selected=$max_index
        fi
        ;;
    "k") # flecha abajo
        if [[ $selected -lt $max_index ]]; then
            selected=$((selected + 1))
        else
            selected=0
        fi
        ;;
    "") # enter
        if [[ $selected -eq $max_index ]]; then
            echo "Saliendo..."
            break
        fi
        echo "Opcion seleccionada: ${options[$selected]}"
        echo "Presione enter para continuar"
        read -sn 1
        selected=0
        ;;
    esac
done

# Exit the script
exit

#!/bin/bash

#Define the options
opt=(
    1 "Respaldos carpetas"
    2 "Tiempo de sesión"
    3 "Sincronizar carpeta"
)

#Initialize the selected option
selected=0

#Clear the screen
clear

#Print the menu using dialog
    while true; 
    do
        #Mostrar le menu y cambiar el valor de la variable "$selected"
        selected=$(dialog --clear --title "Menu Sessions"\
        --cancel-label "Cancel" --ok-label "Select" \
        --menu "Seleccione una opción:" 0 0 0 "${opt[@]}" \
        --output-fd 1)

        #Exit if the user presses cancel
        if [[ $? -ne 0 ]]; then
            break
        fi
    done

#Exit the script
clear
exit
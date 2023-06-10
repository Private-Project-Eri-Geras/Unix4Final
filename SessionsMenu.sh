#!/bin/bash

#Define the options
opt=(
    1 "Inicio/Termino de sesión"
    2 "Tiempo de sesión" 
    3 "Respaldos carpetas"
    4 "Sincronizar carpeta"
)
#Initialize the selected option
selected=0

#Clear the screen
clear

#Print the menu using dialog
    while true; do
        #Mostrar le menu y cambiar el valor de la variable "$selected"
        selected=$(dialog --cursor-off-label --colors --clear --title "Menu Sessions"\
        --cancel-label "Cancelar" --ok-label "Seleccionar" \
        --menu "Seleccione una opción:" 0 0 0 "${opt[@]}" \
        --output-fd 1)
            # ancho, alto, alto del menu interno
        dialogExit=$?

        #Exit if the user presses cancel
        if [[ "dialogExit" -eq 1 ]]; then
            break
        fi

        #Si se selecciono una de las opciones:
        case $selected in
        1)
            (source "subScripts/sessionsInOut.sh")
            ;;
        2)
            (source "subScripts/tiempoSesionM.sh")
            ;;
        3)
            ;;
        4)
            ;;
        *)
            dialog --colors --title "\Z1ERROR" --msgbox "Opción inválida" 0 0
            ;;
        esac
        clear
    done

#Exit the script
clear
exit
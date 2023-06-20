#!/bin/bash
    #GLAM= GNU Logical Administrator Menus o Gerardo, Leonardo, Abraham, Mariana
    #Ruta de código menú:       ╚/usr/src/glam/tareasUsuarios/SessionsMenu.sh
    #Ruta de código subScripts: ╚/usr/src/glam/tareasUsuarios/subscripts/..
#Define the options
opt=(
    1 "Inicio/Termino de sesión"
    2 "Respaldos carpetas" 
    3 "Tiempo de sesión" 
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
            (source "/usr/src/glam/tareasUsuarios/subScripts/sessionsInOut.sh")
            ;;
        2)
            (source "/usr/src/glam/tareasUsuarios/subScripts/respaldoXsession/configRespaldo.sh")
            ;;
        3)
            (source "/usr/src/glam/tareasUsuarios/subScripts/tiempoSesion/tiempoSesionM.sh")
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
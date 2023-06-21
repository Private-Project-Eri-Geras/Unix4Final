#!/bin/bash
#Define the options

mostrar_ayuda(){
  echo "
    Menú de Ingreso de usuarios
    -Inicio/Termino de sesión
        Monitorea el inicio y termino 
        de sesión, esta información 
        se encuentra en 
        "/var/glam/backups/sesiones.txt"
    -Respaldos carpetas
        Permite configurar las carpetas 
        que se respaldarán al iniciar sesión
        el usuario seleccionado dentro del mismo.
    -Tiempo de sesión
        Permite configurar el tiempo de sesión
        de los usuarios. Es decir, solo le permite
        al usuario seleccionado iniciar sesión
        por el tiempo establecido.
    -Monitorear aplicaciones
        Permite monitorear las aplicaciones
        que se ejecutan en el sistema.
   
  " > "/tmp/ayudaInOut.txt"
  dialog --backtitle "MENU SESIONES USUARIOS" --title "AYUDA" \
        --exit-label "Ok" \
        --textbox /tmp/ayudaInOut.txt 0 0
    rm /tmp/ayudaInOut.txt
}

opt=(
    1 "Inicio/Termino de sesión"
    2 "Respaldos carpetas"
    3 "Tiempo de sesión"
    4 "Monitorear aplicaciones"
)
#Initialize the selected option
selected=0

#Clear the screen
clear

#Print the menu using dialog
while true; do
    #Mostrar le menu y cambiar el valor de la variable "$selected"
    selected=$(dialog --cursor-off-label --colors --clear --title "Menu Sessions" \
        --cancel-label "Cancelar" --ok-label "Seleccionar" \
        --help-button --help-label "Ayuda" \
        --menu "Seleccione una opción:" 0 0 0 "${opt[@]}" \
        --output-fd 1)
    # ancho, alto, alto del menu interno
    dialogExit=$?

    #Exit if the user presses cancel
    if [[ "dialogExit" -eq 1 ]]; then
        break
    fi

    #Si selecciona el help buton
    if [[ "dialogExit" -eq 2 ]]; then
        mostrar_ayuda
        continue
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
            (source "/usr/src/glam/tareasUsuarios/subScripts/monitoreo/monitoreo.sh")
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

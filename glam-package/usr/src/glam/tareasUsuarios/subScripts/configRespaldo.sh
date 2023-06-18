#!/bin/bash

opt=(
    1 "Ver carpetas respaldadas"
    2 "Configurar carpetas respaldadas" 
)
###############################################################
#FUNCIONES
configResp(){
    usr=$1  #Guarda el usuario seleccionado

    #Guarda la carpeta/archivo a respaldar al iniciar sesión el usuario
    origen=$(dialog --title "Selecciona un archivo o directorio a respaldar" \
        --cancel-label "Cancelar" \
        --help-button --help-label "Ayuda" \
        --stdout --cursor-off-label --fselect /home/ 14 70)
    opcion=$?

   
    if [[ "usuario" -eq 1 ]]; then  #Exit if the user presses cancel
        return
    fi

    #Guarda la ruta para guardar el respaldo
    destino=$(dialog --title "Selecciona un directorio para guardar el respaldo" \
        --cancel-label "Cancelar" \
        --help-button --help-label "Ayuda" \
        --stdout --cursor-off-label --dselect /home/ 14 70)
    opcion=$?

    if [[ "usuario" -eq 1 ]]; then  #Exit if the user presses cancel
        return
    fi

    echo -e "Ruta arch/dir a respaldar: $origen \n Ruta destino: $destino"
    sleep 20
    return
}


#subMenu verARch/configurar (Se meustra lista de usuarios)
verArchRespaldos() {
    
    return
}

menuUsrs() {
   # Obtener todos los usuarios registrados en el sistema (excluyendo los usuarios del sistema)
    usuarios=$(grep -E '^[^:]+:[^:]*:[0-9]{4}:[0-9]{4}' /etc/passwd | cut -d: -f1)

    # Verificar si no hay usuarios creados
    if [ -z "$usuarios" ]; then
    #echo "No se encontraron usuarios creados en el sistema."
    return
    fi

    # Convertir los usuarios en un arreglo
    usuarios_array=($usuarios)

    # Crear un arreglo de opciones para el menú
    opciones=()
    for usuario in "${usuarios_array[@]}"; do
        opciones+=("$usuario" "")
    done

    # Mostrar el menú y guardar la opción seleccionada
    usuario=$(dialog --cursor-off-label --colors --clear --title \
    "Configuración de tiempo en sesión" --cancel-label "Cancelar" \
    --ok-label "Seleccionar" --menu "Seleccione un usuario:" 0 0 0 "${opciones[@]}" 2>&1 >/dev/tty)

    #Exit if the user presses cancel
    if [[ "usuario" -eq 1 ]]; then
        return
    fi

    configResp "$usuario"
}

################################################################
#Print the menu using dialog
    while true; do
        #Mostrar le menu y cambiar el valor de la variable "$selected"
        selected=$(dialog --cursor-off-label --colors --clear --title "Respaldos al iniciar sesión"\
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
            verArchRespaldos
            ;;
        2)
           menuUsrs
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
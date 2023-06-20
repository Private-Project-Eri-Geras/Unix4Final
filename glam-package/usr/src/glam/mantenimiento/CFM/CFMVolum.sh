#!/bin/bash

#Define las opciones
options=(
    1 "Crear volumen"
    2 "Formatear volumen"
    3 "Montar volumen"
)

if [ -z "$SUDO_USER" ]; then
    dialog --colors --title "\Z1ERROR" --msgbox "Este script debe ser ejecutado con sudo" 0 0
    clear
    return
fi

selected=0

clear

    # Mostrar el menu y cambiar el valor de la variable $selected
selected=$(dialog --clear --title "MENU" \
        --cancel-label "Return" --ok-label "Select" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

if [[ $? -ne 0 ]]; then
    clear
    return
fi

case $selected in
1)
    (source "/usr/src/glam/mantenimiento/CFM/crearvolumen.sh") #
    ;;
2)
    (source "/usr/src/glam/mantenimiento/CFM/formatearvolumen.sh") #
    ;;
3)
    (source "/usr/src/glam/mantenimiento/CFM/montarvolumen.sh") #
    ;;
esac

clear

return
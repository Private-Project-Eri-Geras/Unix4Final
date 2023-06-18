#!/bin/bash

options=(
    1 "Administrar usuarios"
    2 "Tareas de mantenimiento"
    3 "Option 3"
)

selected=0

clear

while true; do
    # Mostrar el menu y cambiar el valor de la variable $selected
    selected=$(dialog --clear --title "MENU PRINCIPAL" \
        --cancel-label "Exit" --ok-label "Select" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

    if [[ $? -ne 0 ]]; then
        break
    fi

    case $selected in
    1)
        (source "usuarios/menuUsuarios.sh")
        ;;
    2)
        (source "mantenimiento/menumantenimiento.sh")
        ;;
    3)s
        source "mantenimiento/opcion3.sh"
        ;;
    esac

    clear
done

clear

#se remueve el archivo temporal fsck_output.tmp
rm mantenimiento/CHO/fsck_output.tmp

exit

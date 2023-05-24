#!/bin/bash

# Obtener el nombre de usuario actual
usuario_actual="$USER"

# Define las opciones del menú
options=(
    1 "Alta por archivo de texto"
    2 "Alta manual"
)

# Agrega opciones según los permisos de sudo
if [[ "$usuario_actual" != "root" ]]; then
    options+=(
        3 "\Z1\ZuBaja por archivo de texto\Zn"
        4 "\Z1\ZuBaja manual\Zn"
    )
else
    options+=(
        3 "Baja por archivo de texto"
        4 "Baja manual"
    )
fi

# Inicializa la opción seleccionada
option=0

# Limpia la pantalla
clear

# Imprime el menú usando dialog
while true; do
    # Muestra el menú y cambia el valor de la variable $option
    option=$(dialog --colors --clear --title "ADMINISTRACION DE USUARIOS" \
        --cancel-label "Cancel" --ok-label "Select" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

    # Retorna al menú principal si el usuario presiona cancelar
    if [[ $? -ne 0 ]]; then
        break
    fi

    # Maneja la opción seleccionada
    case $option in
    1)
        (source "usuarios/altas/masiva.sh")
        ;;
    2)
        source "subScripts/opcion2.sh"
        ;;
    3)
        if [[ "$usuario_actual" != "root" ]]; then
            dialog --title "FALTAN PERMISOS" --msgbox "No tienes permisos para realizar esta acción." 6 30 --clear
        else
            echo "Opción 3"
        fi
        ;;
    4)
        if [[ "$usuario_actual" != "root" ]]; then
            dialog --title "FALTAN PERMISOS" --msgbox "No tienes permisos para realizar esta acción." 6 30 --clear
        else
            echo "Opción 4"
        fi
        ;;
    esac

    # Limpia la pantalla
    clear
done

# Sale del script
clear

#!/usr/bin/env bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --clear --title "AYUDA" --msgbox "Aquí va tu contenido de ayuda" 0 0
}

# Verificar si el script se ejecuta con sudo
if [ -z "$SUDO_USER" ]; then
    dialog --colors --title  "\Z1ERROR" --msgbox "Este script debe ser ejecutado con sudo" 0 0
    clear
    # exit 1
fi

# Define las opciones del menú
options=(
    1 "Alta por archivo de texto"
    2 "Alta manual"
    3 "Baja por archivo de texto"
    4 "Baja manual"
)

# Limpia la pantalla
clear

# Imprime el menú usando dialog
while true; do
    # Muestra el menú y cambia el valor de la variable $option
    # --ok-label = 0
    # --cancel-label = 1
    # --help-button --help-label = 2
    # --extra-button --extra-label = 3
    # 
    option=$(dialog --cursor-off-label --colors --clear --title "ADMINISTRACION DE USUARIOS" \
        --cancel-label "Cancelar" --ok-label "Seleccionar" \
        --help-button --help-label "Ayuda" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

    dialog_exit_code=$?
    # Verificar si el usuario seleccionó el botón de ayuda
    if [[ "$dialog_exit_code" -eq 2 ]]; then
        mostrar_ayuda
        continue
    fi

    # Verificar si el usuario seleccionó cancelar
    if [[ "$dialog_exit_code" -eq 1 ]]; then
        break
    fi

    # Manejar la opción seleccionada
    case $option in
    1)
        (source "usuarios/altas/masiva.sh")
        ;;
    2)
        echo "Opción 2"
        echo "Presiona enter para continuar"
        read -sn 1
        ;;
    3)
        echo "Opción 3"
        echo "Presiona enter para continuar"
        read -sn 1
        ;;
    4)
        echo "Opción 4"
        echo "Presiona enter para continuar"
        read -sn 1
        ;;
    esac

    # Limpia la pantalla
    clear
done

# Sale del script
clear

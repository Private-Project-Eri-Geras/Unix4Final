#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    echo "Este menú contiene más opciones
    entre ellas:
    -Alta de usuarios por archivo de texto
        Se debe tener un archivo (csv) para
        poder dar de alta a los usuarios.
    -Alta de usuarios manual
        Se debe ingresar los datos del usuario
        para poder darlo de alta, de forma manual.
    -Baja de usuarios por archivo de texto
        Se debe tener un archivo (csv) para
        poder dar de baja a los usuarios.
    -Baja de usuarios manual
        Se debe ingresar el nombre del usuario
        para poder darlo de baja, de forma manual.
    -Cambio de contraseña por archivo de texto
        Se debe tener un archivo (csv) para
        poder cambiar la contraseña a los usuarios.
    -Cambio de contraseña manual
        Se debe ingresar el nombre del usuario
        para poder cambiar la contraseña, de forma manual." >/tmp/ayuda.txt
    dialog --backtitle "GESTIÓN DE USUARIOS" --title "AYUDA" \
        --exit-label "Ok" \
        --textbox /tmp/ayuda.txt 0 0 --scrollbar
    rm /tmp/ayuda.txt
}

# Define las opciones del menú
options=(
    1 "Alta por archivo de texto"
    2 "Alta manual"
    3 "Baja por archivo de texto"
    4 "Baja manual"
    5 "Cambio de contraseña por archivo de texto"
    6 "Cambio de contraseña manual"
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
        #TODO: /usr/src/glam/manejoUsuarios/usuarios/altas/masiva.sh
        (source "manejoUsuarios/usuarios/altas/masiva.sh")
        ;;
    2)
        #TODO: /usr/src/glam/usuarios/altas/manual.sh
        (source "manejoUsuarios/usuarios/altas/manual.sh")
        ;;
    3)
        #TODO: /usr/src/glam/usuarios/bajas/masiva.sh
        (source "manejoUsuarios/usuarios/bajas/masiva.sh")
        ;;
    4)
        #TODO: /usr/src/glam/usuarios/bajas/manual.sh
        (source "manejoUsuarios/usuarios/bajas/manual.sh")
        ;;
    5)
        #TODO: /usr/src/glam/usuarios/contraseñas/masiva.sh
        (source "manejoUsuarios/usuarios/contraseñas/masiva.sh")
        ;;
    6)
        #TODO: /usr/src/glam/usuarios/contraseñas/manual.sh
        (source "manejoUsuarios/usuarios/contraseñas/manual.sh")
        ;;
    *)
        dialog --colors --title "\Z1ERROR" --msgbox "Opción inválida" 0 0
        ;;
    esac

    # Limpia la pantalla
    clear
done

# Sale del script
clear

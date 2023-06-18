#!/bin/bash

# Verificar si el script se ejecuta con sudo
if [[ -z $SUDO_USER ]]; then
    tput smcup
    echo -e "\e[1;31mEste script debe ejecutarse con sudo.\e[0m"
    read -p "Presione enter para continuar..." -sn 1
    tput rmcup
    exit 1
fi

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    echo "Cada opción del menú realiza lo siguiente:
    -Manejo de usuarios:
        Permite dar de alta, baja y cambiar la
          contraseña de un usuario.
    -Programación de tareas:
        Permite programar tareas para que se
          ejecuten en un momento determinado.
        Borrar temporales de forma programada.
        Inhabilitar usuarios por un tiempo.
    -Mantenimiento y arranque:
        Permite habilitar e inhabilitar el
          chequedo de volumenes.
        Cambiar los modos de arranque.
        Checar volumenes.
        Creacion, formato y montaje de volumenes.
    -Tareas sobre usuarios:
        Permite monitorear los usuarios del sistema.
        Programar tareas en base a un inicio
          de sesion." >/var/glam/tmp/ayuda.txt
    dialog --backtitle "MENU PRINCIPAL" --title "AYUDA" \
        --exit-label "Ok" \
        --textbox /var/glam/tmp/ayuda.txt 0 0 --scrollbar
    rm /var/glam/tmp/ayuda.txt
}

menu_case() {
    option=$1
    case $option in
    1)
        (source /usr/src/glam/manejoUsuarios/menuUsuarios.sh)
        ;;
    2)
        clear
        echo "Programación de tareas"
        read -p "Presione enter para continuar..." -sn 1
        ;;
    3)
        clear
        echo "Mantenimiento y arranque"
        read -p "Presione enter para continuar..." -sn 1
        ;;
    4)
        clear
        echo "Tareas sobre usuarios"
        read -p "Presione enter para continuar..." -sn 1
        ;;
    esac
}

opciones_Menu=(
    1 "Manejo de usuarios"
    2 "Programación de tareas"
    3 "Mantenimiento y arranque"
    4 "Tareas sobre usuarios"
)

while true; do
    # Mostrar el menú y cambiar el valor de la variable $option
    option=$(dialog --cursor-off-label --colors --clear --title "MENU PRINCIPAL" \
        --cancel-label "Salir" --ok-label "Seleccionar" \
        --help-button --help-label "Ayuda" \
        --menu "Seleccione una opción:" 0 0 0 "${opciones_Menu[@]}" \
        --output-fd 1)
    menu_exit_code=$?
    case $menu_exit_code in
    2)
        mostrar_ayuda
        ;;
    1)
        clear
        exit 1
        ;;
    0)
        menu_case $option
        ;;
    esac
done

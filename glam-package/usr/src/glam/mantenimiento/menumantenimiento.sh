#!/bin/bash

options=(
    1 "Habilitar/inhabilitar chequeos de volumen al arranque"
    2 "Arranque mantenimiento"
    3 "Arranque manual"
    4 "Chequeo de volumenes"
    5 "Creacion, formato y montaje de volumenes"
)

mostrar_ayuda() {
    echo "Cada opción del menú realiza lo siguiente:
    -Manejo de usuarios:
        Permite dar de alta, baja y cambiar la
          contraseña de un usuario.
    -Habilitar/inhabilitar chequeos de volumen al arranque
        Permite cambiar los chequeos al arranque
            los cuales se ubican en fstab
    -Arranque mantenimiento
        Se reiniciara en modo mantenimiento
            la interfaz al reiniciar sera de texto
    -Arranque manual
        Se puede apagar o reiniciar la maquina
            hay cuatro modos disponibles
    -Chequeo de volumenes
        Podras checar los volumenes de todos los dispositivos
            que esten montados
    -Creacion, formato y montaje de volumenes
        Crear particiones para volumenes
        Formatear volumenes
        Montar volumenes." >/var/glam/tmp/ayuda.txt
    dialog --backtitle "MENU PRINCIPAL" --title "AYUDA" \
        --exit-label "Ok" \
        --textbox /var/glam/tmp/ayuda.txt 0 0 
}

selected=0

clear

while true; do
    # Mostrar el menu y cambiar el valor de la variable $selected
    selected=$(dialog --clear --title "MENU MANTENIMIENTO" \
        --cancel-label "Return" --ok-label "Select" \
        --help-button --help-label "Ayuda" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

    menu_exit_code=$?
    case $menu_exit_code in
    2)
        mostrar_ayuda
        ;;
    1) 
        clear
        return
        ;;
    0)
            case $selected in
            1)
                (source "/usr/src/glam/mantenimiento/CHA/volumenarranque.sh") #
                ;;
            2)
                (source "/usr/src/glam/mantenimiento/RMT/mantreboot.sh") #
                ;;
            3)
                (source "/usr/src/glam/mantenimiento/RMA/manualreboot.sh") #
                ;;
            4)
                (source "/usr/src/glam/mantenimiento/CHO/checkvol.sh") #
                ;;
            5)
                (source "/usr/src/glam/mantenimiento/CFM/CFMVolum.sh") #
                ;;
            
            esac
        ;;
    esac
    clear
done

clear

return

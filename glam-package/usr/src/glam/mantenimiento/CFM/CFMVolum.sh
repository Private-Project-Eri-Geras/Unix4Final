#!/bin/bash

#Define las opciones
options=(
    1 "Crear volumen"
    2 "Formatear volumen"
    3 "Montar volumen"
    4 "Desmontar volumen"
)

mostrar_ayuda() {
    echo "Cada opción del menú realiza lo siguiente:
    -Crear volumen
        Permite crear una particion en un disco
    -Formatear volumen
        Permite formatear un volumen
        Este puede ser en volumenes ya montados
    -Montar volumen
        Permite montar un volumen en un punto de montaje
    -Desmontar volumen
        Permite desmontar un volumen montado anteriormente

---------------------------------------------------------------
    La mayoria de las opciones requieren que
        El volumen no este montado
        No pertenezca a un volumen logico
        No sea un volumen de arranque
        No pertenezca a raiz
        No sea un volumen de swap
---------------------------------------------------------------" >/var/glam/tmp/ayuda.txt
    dialog --backtitle "MENU PRINCIPAL" --title "AYUDA" \
        --exit-label "Ok" \
        --textbox /var/glam/tmp/ayuda.txt 0 0 --scrollbar
    rm /var/glam/tmp/ayuda.txt
}

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
        --help-button --help-label "Ayuda" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

opselected=$?

if [[ $opselected == 1 ]]; then
    clear
    return
fi

if [[ $opselected == 2 ]]; then
    mostrar_ayuda
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
4)
    (source "/usr/src/glam/mantenimiento/CFM/desmontarvolumen.sh") #
    ;;
esac

clear

return
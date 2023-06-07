#!/bin/bash

# Verificar si el script se ejecuta con sudo
if [ -z "$SUDO_USER" ]; then
    dialog --colors --title "\Z1ERROR" --msgbox "Este script debe ser ejecutado con sudo" 0 0
    clear
    retrn 1
fi

options=(
    1 "Reiniciar en modo manual"
)

option=0

option=$(dialog --colors --clear --title "Arrancar en modo manual" \
        --cancel-label "Cancelar" --ok-label "Reiniciar" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)
#20
case $option in
    1)#rebootnow
        echo "hace reboot"
        read -sn 1 -t 2
        ;;
esac


clear

#!/bin/bash

# Verificar si el script se ejecuta con sudo
if [ -z "$SUDO_USER" ]; then
    dialog --colors --title "\Z1ERROR" --msgbox "Este script debe ser ejecutado con sudo" 0 0
    clear
    retrn 1
fi


dialog --colors --clear --title "Arrancar en modo manual" \
    --yes-label "Reinciar" --no-label "Cancelar" \
    --yesno "Deseas reiniciar el sistema?" 0 0 --output-fd 1

Opselect=$?

if [[ $Opselect -eq 0 ]]; then
        #rebootnow
        echo "hace reboot"
        read -sn 110 -t 2
fi

return

clear

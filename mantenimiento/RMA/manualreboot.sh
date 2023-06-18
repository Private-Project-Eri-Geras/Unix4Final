#!/bin/bash

options=(
    1 "Shutdown Halt"
    2 "Reboot Single-User"
    3 "Reboot Multi-user(no red/graphic)"
    4 "Reboot Multi-user(no graphic)"
    5 "Reboot multi-user(graphic)"
    6 "Reboot"
)

# Verificar si el script se ejecuta con sudo
if [ -z "$SUDO_USER" ]; then
    dialog --colors --title "\Z1ERROR" --msgbox "Este script debe ser ejecutado con sudo" 0 0
    clear
    return
fi

endTimer(){
    #Hacer una cuenta atras de 60 segundos
    for (( i=60; i>=0; i-- )); do
        tput cup 0 0
        #Letra Negrita y color  blanco con fondo azul
        echo -e "\033[1;31;44m El sistema se apagara en: $i s      \033[0m"
        sleep 1
    done
}



selected=$(dialog --clear --title "MENU PRINCIPAL" \
        --cancel-label "Return" --ok-label "Select" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

    if [[ $? -ne 0 ]]; then
        return
    fi

    case $selected in
    1)
        wall "El sistema se apagara en 1 minuto. Se perdera todo el trabajo no guardado."
        dialog --colors --title "REINICANDO" --backtitle ""-* \
                --infobox "Se apagara en 1 minuto.
                \Zb\Z1pulse cualquier tecla para cancelar" 0 0
        #Llamar la funcion en segundo plano
        endTimer &
        #Hacer un read -t 60 para cancelar el reinicio
        #si se pulsa cualquier tecla se cancela el reinicio
        read -sn 1 -t 60
        if [[ "$?" -eq 0 ]]; then
                #Matar el hilo de la cuenta atras
                kill $!
                dialog --colors --title "REINICIO CANCELADO" --msgbox "El reinicio ha sido cancelado" 0 0
                return 1
        else
        init 0
        fi
        ;;
    2)
        wall "El sistema se reiniciara en 1 minuto. Se perdera todo el trabajo no guardado."
        dialog --colors --title "REINICANDO" --backtitle ""-* \
                --infobox "Se reinicara en 1 minuto.
                \Zb\Z1pulse cualquier tecla para cancelar" 0 0
        #Llamar la funcion en segundo plano
        endTimer &
        #Hacer un read -t 60 para cancelar el reinicio
        #si se pulsa cualquier tecla se cancela el reinicio
        read -sn 1 -t 60
        if [[ "$?" -eq 0 ]]; then
                #Matar el hilo de la cuenta atras
                kill $!
                dialog --colors --title "REINICIO CANCELADO" --msgbox "El reinicio ha sido cancelado" 0 0
                return 1
        else
        init 1
        fi
        ;;
    3)
        wall "El sistema se reiniciara en 1 minuto. Se perdera todo el trabajo no guardado."
        dialog --colors --title "REINICANDO" --backtitle ""-* \
                --infobox "Se reinicara en 1 minuto.
                \Zb\Z1pulse cualquier tecla para cancelar" 0 0
        #Llamar la funcion en segundo plano
        endTimer &
        #Hacer un read -t 60 para cancelar el reinicio
        #si se pulsa cualquier tecla se cancela el reinicio
        read -sn 1 -t 60
        if [[ "$?" -eq 0 ]]; then
                #Matar el hilo de la cuenta atras
                kill $!
                dialog --colors --title "REINICIO CANCELADO" --msgbox "El reinicio ha sido cancelado" 0 0
                return 1
        else
        init 2
        fi
        ;;
    4)
        wall "El sistema se reiniciara en 1 minuto. Se perdera todo el trabajo no guardado."
        dialog --colors --title "REINICANDO" --backtitle ""-* \
                --infobox "Se reinicara en 1 minuto.
                \Zb\Z1pulse cualquier tecla para cancelar" 0 0
        #Llamar la funcion en segundo plano
        endTimer &
        #Hacer un read -t 60 para cancelar el reinicio
        #si se pulsa cualquier tecla se cancela el reinicio
        read -sn 1 -t 60
        if [[ "$?" -eq 0 ]]; then
                #Matar el hilo de la cuenta atras
                kill $!
                dialog --colors --title "REINICIO CANCELADO" --msgbox "El reinicio ha sido cancelado" 0 0
                return 1
        else
        init 3
        fi
        ;;
    5)
        wall "El sistema se reiniciara en 1 minuto. Se perdera todo el trabajo no guardado."
        dialog --colors --title "REINICANDO" --backtitle ""-* \
                --infobox "Se reinicara en 1 minuto.
                \Zb\Z1pulse cualquier tecla para cancelar" 0 0
        #Llamar la funcion en segundo plano
        endTimer &
        #Hacer un read -t 60 para cancelar el reinicio
        #si se pulsa cualquier tecla se cancela el reinicio
        read -sn 1 -t 60
        if [[ "$?" -eq 0 ]]; then
                #Matar el hilo de la cuenta atras
                kill $!
                dialog --colors --title "REINICIO CANCELADO" --msgbox "El reinicio ha sido cancelado" 0 0
                return 1
        else
        init 5
        fi
        ;;
    6)
        wall "El sistema se reiniciara en 1 minuto. Se perdera todo el trabajo no guardado."
        dialog --colors --title "REINICANDO" --backtitle ""-* \
                --infobox "Se reinicara en 1 minuto.
                \Zb\Z1pulse cualquier tecla para cancelar" 0 0
        #Llamar la funcion en segundo plano
        endTimer &
        #Hacer un read -t 60 para cancelar el reinicio
        #si se pulsa cualquier tecla se cancela el reinicio
        read -sn 1 -t 60
        if [[ "$?" -eq 0 ]]; then
                #Matar el hilo de la cuenta atras
                kill $!
                dialog --colors --title "REINICIO CANCELADO" --msgbox "El reinicio ha sido cancelado" 0 0
                return 1
        else
        init 6
        fi
        ;;
    esac

return

clear

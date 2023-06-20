#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox \
        "\n\
    Para navegar se pude usar tab o las flechas.\n\n\
    Es necesario usar la ruta absoluta del script.\n\n\
    Al presionar espacio se autocopleta la ruta del archivo seleccionado." 0 0
}

while true; do
    origen=$(dialog --title "Selecciona un archivo o directorio a respaldar" \
        --cancel-label "Cancelar" \
        --help-button --help-label "Ayuda" \
        --stdout --cursor-off-label --fselect /home/ 14 70)
    opcion=$?

    # Si el usuario presiona "Help" se sale del script
    if [ $opcion -eq 2 ]; then
        mostrar_ayuda

    # Si el usuario presiona "Cancel" se muestra la ayuda
    elif [ $opcion -eq 1 ]; then
        break

    # Si el usuario presiona "Slect"
    elif [ $opcion -eq 0 ]; then
        if [ -f "$origen" ]; then
            dialog --title "CONFIRMAR" --yesno "¿Deseas usar el archivo $origen?" 0 0
            opcion=$?
            if [ $opcion -eq 0 ]; then
                echo -n "$origen" >/tmp/origen.tmp
                head -$((numeroFinManual - 1)) /etc/crontab >/tmp/crontab
                cat /tmp/cron.tmp /tmp/origen.tmp >>/tmp/crontab
                echo "" >>/tmp/crontab
                tail -n +${numeroFinManual} /etc/crontab >>/tmp/crontab
                rm /etc/crontab
                mv /tmp/crontab /etc/crontab
                dialog --title "" --msgbox "La tarea se ha creado exitosamente." 0 0
                rm /tmp/cancelar.tmp
                rm /tmp/cron.tmp
                rm /tmp/dialogOutput.tmp
                rm /tmp/Doutput.tmp
                rm /tmp/output.tmp
                rm /tmp/origen.tmp
                clear
                break
            fi
        else
            if [ -z "$origen" ]; then
                dialog --title "ERROR" --msgbox "No se seleccionó nada a respaldar." 0 0
            elif [ ! -f "$origen" ]; then
                dialog --title "ERROR" --msgbox "El archivo seleccionado no existe." 0 0
            elif [ -d "$origen" ]; then
                dialog --title "ERROR" --msgbox "La ruta seleccionada es un directorio." 0 0
            fi
        fi
    fi

done

#!/bin/bash

while true; do
    destino=$(dialog --title "Selecciona un directorio para guardar el respaldo" \
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
        if [ -d "$destino" ]; then
            echo -n "$destino" > tmp/destino.tmp
            if grep -qFf tmp/origen.tmp tmp/destino.tmp; then
                dialog --title "ERROR" --msgbox "El directorio seleccionado se encuentra dentro del directorio a respaldar." 0 0
                rm tmp/destino.tmp
                continue
            fi
            dialog --title "CONFIRMAR" --yesno "¿Deseas usar el directorio $destino?" 0 0
            opcion=$?
            if [ $opcion -eq 0 ]; then
                clear
                break # Salir del ciclo while después de confirmar
            fi

        else
            if [ -z "$destino" ]; then
                dialog --title "ERROR" --msgbox "No se seleccionó ningún directorio." 0 0
            elif [ -f "$destino" ]; then
                dialog --title "ERROR" --msgbox "La ruta seleccionada es un archivo." 0 0
            elif [ ! -d "$destino" ]; then
                dialog --title "ERROR" --msgbox "La ruta seleccionada no es un directorio." 0 0
            fi
        fi
    fi
done

rm tmp/destino.tmp

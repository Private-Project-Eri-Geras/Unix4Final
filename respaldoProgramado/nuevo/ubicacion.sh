#!/usr/bin/env bash

while true; do
    origen=$(dialog --title "Selecciona un archivo" \
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
                #Se guarda la ruta en tmp/origen.txt
                echo "$origen" > tmp/origen.txt
                clear
                break # Salir del ciclo while después de confirmar
            fi

        elif [ -d "$origen" ]; then
            dialog --title "CONFIRMAR" --yesno "¿Deseas usar el directorio $origen?" 0 0
            opcion=$?
            if [ $opcion -eq 0 ]; then
                #Se guarda la ruta en tmp/origen.txt
                echo "$origen" > tmp/origen.txt
                clear
                break # Salir del ciclo while después de confirmar
            fi
        
        else
            if [ -z "$origen" ]; then
                dialog --title "ERROR" --msgbox "No se seleccionó ningún archivo." 0 0
            elif [ ! -f "$origen" ]; then
                dialog --title "ERROR" --msgbox "El archivo seleccionado no existe." 0 0
            elif [ ! -d "$origen" ]; then
                dialog --title "ERROR" --msgbox "El archivo seleccionado no es un directorio." 0 0
            fi
        fi
    fi

done
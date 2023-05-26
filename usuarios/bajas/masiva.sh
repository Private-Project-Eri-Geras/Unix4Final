#!/usr/bin/env bash
while true; do
    archivo_usuarios=$(dialog --title --cursor-off-label "Selecciona un archivo" \
        --stdout \
        --fselect /home/ 14 70)
    archivo_usuario_Output=$?
    # Si el usuario presiona "Cancel" se sale del script
    if [ $archivo_usuario_Output -eq 1 ]; then
        break
    fi
    if [ -f "$archivo_usuarios" ]; then
        dialog --title "CONFIRMAR" --yesno "¿Deseas usar el archivo $archivo_usuarios?" 0 0
        dialog_Output=$?
        if [ $dialog_Output -eq 0 ]; then
            # Si el usuario presiona "Yes" se ejecuta la función addUsers
            clear
            addUsers "$archivo_usuarios"
            break # Salir del ciclo while después de confirmar
        fi
    else
        break # Salir del ciclo while si no se selecciona un archivo
    fi
done
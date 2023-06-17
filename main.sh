#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox "aqui esta la ayuda" 0 0
}

# Limpia la pantalla
clear

# Verificar si el script se ejecuta con sudo
if [ -z "$SUDO_USER" ]; then
    dialog --colors --title "\Z1ERROR" --msgbox "Este script debe ser ejecutado con sudo" 0 0
    clear
    # exit 1
fi

# Define las opciones del menú
options=(
    1 "Programación de tareas manual"
    2 "Respaldo programado"
    3 "Borrado de temporales programado"
    4 "Inhabilitación de usuarios (por periodo de tiempo)"
)

# Verificar la estructura de crontab y crearla si no existe
lineaInicio=$(grep -c "# INICIO PROGRAMACION DE TAREAS" /etc/crontab)
lineaFin=$(grep -c "# FIN PROGRAMACION DE TAREAS" /etc/crontab)
numeroInicio=$(grep -n "# INICIO PROGRAMACION DE TAREAS" /etc/crontab | cut -d ':' -f 1)
numeroFin=$(grep -n "# FIN PROGRAMACION DE TAREAS" /etc/crontab | cut -d ':' -f 1)

if ((lineaInicio == 0 && lineaFin == 0)); then
    dialog --colors --title "\Z1ERROR" --msgbox "La estructura en crontab no existe, se creará una nueva" 0 0
    clear
    echo "# INICIO PROGRAMACION DE TAREAS" >>/etc/crontab
    echo "# FIN PROGRAMACION DE TAREAS" >>/etc/crontab
elif ((lineaInicio != 1 || lineaFin != 1)); then
    lineaInicio=$(grep -c "# INICIO PROGRAMACION DE TAREAS" /etc/crontab)
    lineaFin=$(grep -c "# FIN PROGRAMACION DE TAREAS" /etc/crontab)
    dialog --colors --title "\Z1ERROR" --msgbox "La estructura en crontab no es correcta, se perderá registro de todas las tareas programadas" 0 0
    clear
    grep -v "# INICIO PROGRAMACION DE TAREAS" /etc/crontab | grep -v "# FIN PROGRAMACION DE TAREAS" $1 >tmp/crontab
    echo "# INICIO PROGRAMACION DE TAREAS" >>tmp/crontab
    echo "# FIN PROGRAMACION DE TAREAS" >>tmp/crontab
    rm /etc/crontab
    mv tmp/crontab /etc/crontab
elif ((numeroInicio > numeroFin)); then
    dialog --colors --title "\Z1ERROR" --msgbox "La estructura en crontab está invertida, se perderá registro de todas las tareas programadas" 0 0
    clear
    grep -v "# INICIO PROGRAMACION DE TAREAS" /etc/crontab | grep -v "# FIN PROGRAMACION DE TAREAS" $1 >tmp/crontab
    echo "# INICIO PROGRAMACION DE TAREAS" >>tmp/crontab
    echo "# FIN PROGRAMACION DE TAREAS" >>tmp/crontab
    rm /etc/crontab
    mv tmp/crontab /etc/crontab
fi

# Imprime el menú usando dialog
while true; do
    # Muestra el menú y cambia el valor de la variable $option
    # --ok-label = 0
    # --cancel-label = 1
    # --help-button --help-label = 2
    # --extra-button --extra-label = 3
    option=$(dialog --cursor-off-label --colors --clear --title "PROGRAMACION DE TAREAS" \
        --cancel-label "Cancelar" --ok-label "Seleccionar" \
        --help-button --help-label "Ayuda" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

    dialog_exit_code=$?

    # Verificar si el usuario seleccionó el botón de ayuda
    if [[ "$dialog_exit_code" -eq 2 ]]; then
        mostrar_ayuda
        continue
    fi

    # Verificar si el usuario seleccionó cancelar
    if [[ "$dialog_exit_code" -eq 1 ]]; then
        break
    fi

    # Manejar la opción seleccionada
    case $option in
    1)
        # (source "")
        ;;
    2)
        (source "respaldoProgramado/menuRespaldo.sh")
        ;;
    3)
        # (source "")
        ;;
    4)
        # (source "")
        ;;
    *)
        dialog --colors --title "\Z1ERROR" --msgbox "Opción inválida" 0 0
        ;;
    esac

    # Limpia la pantalla
    clear
done

# Sale del script
clear

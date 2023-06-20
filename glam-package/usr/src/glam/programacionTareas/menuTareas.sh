#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --textbox \
    "\n\
    1.-Programación de tareas manual:\n\
    Permite programar tareas en un momento específico.\n\n\
    2.-Respaldo programado:\n\
    Permite programar un respaldo de un archivo o directorio de forma periódica.\n\n\
    3.-Borrado de temporales programado:\n\
    Permite programar el borrado de archivos temporales de forma periódica.\n\n\
    4.-Inhabilitación de usuarios (por periodo de tiempo):\n\
    Permite inhabilitar usuarios por un periodo de tiempo específico." 0 0 --scrollbar
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
    4 "Inhabilitación de usuarios"
)

# Verificar la estructura de crontab y crearla si no existe
lineaInicio=$(grep -c "# INICIO PROGRAMACION DE TAREAS" /etc/crontab)
lineaFin=$(grep -c "# FIN PROGRAMACION DE TAREAS" /etc/crontab)
lineaInicioManual=$(grep -c "# INICIO PROGRAMACION MANUAL" /etc/crontab)
lineaFinManual=$(grep -c "# FIN PROGRAMACION MANUAL" /etc/crontab)
lineaInicioTotal=$(grep -c "# INICIO TMP TOTAL" /etc/crontab | cut -d ':' -f 1)
lineaFinTotal=$(grep -c "# FIN TMP TOTAL" /etc/crontab | cut -d ':' -f 1)
lineaInicioSelectivo=$(grep -c "# INICIO TMP SELECTIVO" /etc/crontab | cut -d ':' -f 1)
lineaFinSelectivo=$(grep -c "# FIN TMP SELECTIVO" /etc/crontab | cut -d ':' -f 1)
numeroInicio=$(grep -n "# INICIO PROGRAMACION DE TAREAS" /etc/crontab | cut -d ':' -f 1)
numeroFin=$(grep -n "# FIN PROGRAMACION DE TAREAS" /etc/crontab | cut -d ':' -f 1)
numeroInicioManual=$(grep -n "# INICIO PROGRAMACION MANUAL" /etc/crontab | cut -d ':' -f 1)
numeroFinManual=$(grep -n "# FIN PROGRAMACION MANUAL" /etc/crontab | cut -d ':' -f 1)
numeroInicioTotal=$(grep -n "# INICIO TMP TOTAL" /etc/crontab | cut -d ':' -f 1)
numeroFinTotal=$(grep -n "# FIN TMP TOTAL" /etc/crontab | cut -d ':' -f 1)
numeroInicioSelectivo=$(grep -n "# INICIO TMP SELECTIVO" /etc/crontab | cut -d ':' -f 1)
numeroFinSelectivo=$(grep -n "# FIN TMP SELECTIVO" /etc/crontab | cut -d ':' -f 1)

if ((lineaInicio == 0 && lineaFin == 0 && lineaInicioManual == 0 && lineaFinManual == 0 && lineaInicioTotal == 0 && lineaFinTotal == 0 && lineaInicioSelectivo == 0 && lineaFinSelectivo == 0)); then
    dialog --colors --title "\Z1ERROR" --msgbox "La estructura en crontab no existe, se creará una nueva" 0 0
    clear
    echo "# INICIO PROGRAMACION DE TAREAS" >>/etc/crontab
    echo "# FIN PROGRAMACION DE TAREAS" >>/etc/crontab
    echo "# INICIO PROGRAMACION MANUAL" >>/etc/crontab
    echo "# FIN PROGRAMACION MANUAL" >>/etc/crontab
    echo "# INICIO TMP TOTAL" >>/etc/crontab
    echo "# FIN TMP TOTAL" >>/etc/crontab
    echo "# INICIO TMP SELECTIVO" >>/etc/crontab
    echo "# FIN TMP SELECTIVO" >>/etc/crontab
elif ((lineaInicio != 1 || lineaFin != 1 || lineaInicioManual != 1 || lineaFinManual != 1 || lineaInicioTotal != 1 || lineaFinTotal != 1 || lineaInicioSelectivo != 1 || lineaFinSelectivo != 1)); then
    lineaInicio=$(grep -c "# INICIO PROGRAMACION DE TAREAS" /etc/crontab)
    lineaFin=$(grep -c "# FIN PROGRAMACION DE TAREAS" /etc/crontab)
    lineaInicioManual=$(grep -c "# INICIO PROGRAMACION MANUAL" /etc/crontab)
    lineaFinManual=$(grep -c "# FIN PROGRAMACION MANUAL" /etc/crontab)
    lineaInicioTotal=$(grep -n "# INICIO TMP TOTAL" /etc/crontab | cut -d ':' -f 1)
    lineaFinTotal=$(grep -n "# FIN TMP TOTAL" /etc/crontab | cut -d ':' -f 1)
    lineaInicioSelectivo=$(grep -n "# INICIO TMP SELECTIVO" /etc/crontab | cut -d ':' -f 1)
    lineaFinSelectivo=$(grep -n "# FIN TMP SELECTIVO" /etc/crontab | cut -d ':' -f 1)
    numeroInicio=$(grep -n "# INICIO PROGRAMACION DE TAREAS" /etc/crontab | cut -d ':' -f 1)
    numeroFin=$(grep -n "# FIN PROGRAMACION DE TAREAS" /etc/crontab | cut -d ':' -f 1)
    numeroInicioManual=$(grep -n "# INICIO PROGRAMACION MANUAL" /etc/crontab | cut -d ':' -f 1)
    numeroFinManual=$(grep -n "# FIN PROGRAMACION MANUAL" /etc/crontab | cut -d ':' -f 1)
    numeroInicioTotal=$(grep -n "# INICIO TMP TOTAL" /etc/crontab | cut -d ':' -f 1)
    numeroFinTotal=$(grep -n "# FIN TMP TOTAL" /etc/crontab | cut -d ':' -f 1)
    numeroInicioSelectivo=$(grep -n "# INICIO TMP SELECTIVO" /etc/crontab | cut -d ':' -f 1)
    numeroFinSelectivo=$(grep -n "# FIN TMP SELECTIVO" /etc/crontab | cut -d ':' -f 1)
    
    dialog --colors --title "\Z1ERROR" --msgbox "La estructura en crontab no es correcta, se perderá registro de todas las tareas programadas" 0 0
    clear
    grep -v "# INICIO PROGRAMACION DE TAREAS" /etc/crontab | grep -v "# FIN PROGRAMACION DE TAREAS" | grep -v "# INICIO PROGRAMACION MANUAL" | grep -v "# FIN PROGRAMACION MANUAL" | grep -v "# INICIO TMP TOTAL" | grep -v "# FIN TMP TOTAL" | grep -v "# INICIO TMP SELECTIVO" | grep -v "# FIN TMP SELECTIVO" >/tmp/crontab
    echo "# INICIO PROGRAMACION DE TAREAS" >>/tmp/crontab
    echo "# FIN PROGRAMACION DE TAREAS" >>/tmp/crontab
    echo "# INICIO PROGRAMACION MANUAL" >>/tmp/crontab
    echo "# FIN PROGRAMACION MANUAL" >>/tmp/crontab
    echo "# INICIO TMP TOTAL" >>/tmp/crontab
    echo "# FIN TMP TOTAL" >>/tmp/crontab
    echo "# INICIO TMP SELECTIVO" >>/tmp/crontab
    echo "# FIN TMP SELECTIVO" >>/tmp/crontab
    rm /etc/crontab
    mv /tmp/crontab /etc/crontab
elif ((numeroInicio > numeroFin || numeroInicioManual > numeroFinManual || lineaInicioTotal > lineaFinTotal || lineaInicioSelectivo > lineaFinSelectivo)); then
    dialog --colors --title "\Z1ERROR" --msgbox "La estructura en crontab está invertida, se perderá registro de todas las tareas programadas" 0 0
    clear
    grep -v "# INICIO PROGRAMACION DE TAREAS" /etc/crontab | grep -v "# FIN PROGRAMACION DE TAREAS" | grep -v "# INICIO PROGRAMACION MANUAL" | grep -v "# FIN PROGRAMACION MANUAL" | grep -v "# INICIO TMP TOTAL" | grep -v "# FIN TMP TOTAL" | grep -v "# INICIO TMP SELECTIVO" | grep -v "# FIN TMP SELECTIVO" >/tmp/crontab
    echo "# INICIO PROGRAMACION DE TAREAS" >>/tmp/crontab
    echo "# FIN PROGRAMACION DE TAREAS" >>/tmp/crontab
    echo "# INICIO PROGRAMACION MANUAL" >>/tmp/crontab
    echo "# FIN PROGRAMACION MANUAL" >>/tmp/crontab
    echo "# INICIO TMP TOTAL" >>/tmp/crontab
    echo "# FIN TMP TOTAL" >>/tmp/crontab
    echo "# INICIO TMP SELECTIVO" >>/tmp/crontab
    echo "# FIN TMP SELECTIVO" >>/tmp/crontab
    rm /etc/crontab
    mv /tmp/crontab /etc/crontab
fi

# Imprime el menú usando dialog
while true; do
    # Muestra el menú y cambia el valor de la variable $option
    # --ok-label = 0
    # --cancel-label = 1
    # --help-button --help-label = 2
    # --extra-button --extra-label = 3
    option=$(dialog --cursor-off-label --colors --clear --title "PROGRAMACIÓN DE TAREAS" \
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
        (source /usr/src/glam/programacionTareas/programacionManual/menuProgramacion.sh)
        ;;
    2)
        (source /usr/src/glam/programacionTareas/respaldoProgramado/menuRespaldo.sh)
        ;;
    3)
        (source /usr/src/glam/programacionTareas/borradoTmpProgramado/menuBorrado.sh)
        ;;
    4)
        (source /usr/src/glam/programacionTareas/inhabilitacionUsuarios/menuInhabilitar.sh)
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

#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox \
    "\n\
    1.-Programar tarea:\n\
    Permite añadir un script a la lista de tareas programadas de forma periódica.\n\n\
    2.-Borrar tarea:\n\
    Permite borrar las tareas programadas.\n\n" 0 0
}

# Define las opciones del menú
options=(
    1 "Programar tarea"
    2 "Borrar tarea"
)

# Limpia la pantalla
clear

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
        (source /usr/src/glam/programacionTareas/programacionManual/programar/programarTarea.sh)
        ;;
    2)
        (source /usr/src/glam/programacionTareas/programacionManual/borrar/borrarTarea.sh)
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

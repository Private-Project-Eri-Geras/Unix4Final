#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox \
        "\n\
    Seleccione el usuario que desea habilitar.\n\n" 0 0
}

# Define las opciones del menú
options=(
    # INICIO OPTIONS
    # FIN OPTIONS
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
    option=$(dialog --cursor-off-label --colors --clear --title "HABILITACIÓN DE USUARIOS" \
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

    # Se obtiene el usuario seleccionado por su número de línea ordenado alfabéticamente
    usuario=$(grep "!" /etc/shadow | cut -d: -f1 | sort | awk -v i="$option" 'NR == i { printf "%s", $0 }')
    # Se habilita el usuario
    sudo usermod -U "$usuario"
    # Se muestra la ventana de confirmación
    dialog --title "HABILITACIÓN DE USUARIOS" --msgbox \
        "\n\
    El usuario $usuario ha sido habilitado.\n\n" 0 0

    break

    # Limpia la pantalla
    clear
done

# Sale del script
clear

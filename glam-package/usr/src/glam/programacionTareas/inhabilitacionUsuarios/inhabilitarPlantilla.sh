#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox \
    "\n\
    Seleccione el usuario que desea inhabilitar.\n\n" 0 0
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
    option=$(dialog --cursor-off-label --colors --clear --title "INHABILITACIÓN DE USUARIOS" \
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

    # Preguntar por el tiempo de inhabilitación y verificar que sea un número
    while true; do
        # Se muestra la ventana para ingresar el tiempo de inhabilitación
        tiempoInhabilitacion=$(dialog --stdout --title "Tiempo de inhabilitación" \
            --inputbox "Ingrese el tiempo de inhabilitación en minutos:" 0 0)

        # Se verifica que el usuario no haya cancelado la operación
        if [[ "$?" -eq 1 ]]; then
            break
        fi

        # Se verifica que el tiempo de inhabilitación sea un número
        if [[ "$tiempoInhabilitacion" =~ ^[0-9]+$ ]]; then
            # Se obtiene el usuario seleccionado por su número de línea ordenado alfabéticamente
            usuario=$(grep -v "!" /etc/shadow | cut -d: -f1 | sort | awk -v i="$option" 'NR == i { printf "%s", $0 }')
            # Se inhabilita el usuario
            usermod -L $usuario
            # Se usa at para programar la habilitación del usuario
            echo "usermod -U $usuario" | at now + $tiempoInhabilitacion minutes
            # Se muestra la ventana de confirmación
            dialog --title "INHABILITACIÓN DE USUARIOS" --msgbox \
                "\n\
            El usuario $usuario ha sido inhabilitado por $tiempoInhabilitacion minutos.\n\n" 0 0
            break
        else
            dialog --title "Error" --msgbox "El tiempo de inhabilitación debe ser un número." 0 0
        fi
    done
    # Limpia la pantalla
    clear

    break
done

# Sale del script
clear

#!/usr/bin/env bash

# Función para actualizar el diálogo
update_dialog() {
    # Comando para obtener el contenido actualizado
    content="$(cat /tmp/dialog_content)"

    tput cup 0 0

    # Obtener el tamaño de la terminal
    rows=$(tput lines)
    cols=$(tput cols)

    # Calcular la posición y el tamaño de la ventana del diálogo
    dialog_height=10
    dialog_width=$(((cols - 2) / 2))
    dialog_x=$(((cols / 2) - dialog_width)) # Centrar horizontalmente en la parte izquierda
    dialog_y=$(((rows - dialog_height) / 2))

    # Actualizar el diálogo
    dialog --no-clear --keep-window --title "INPUT" --begin "$dialog_y" "$dialog_x" --tailboxbg /tmp/dialog_content "$dialog_height" "$dialog_width" \
        --and-widget \
        --no-clear --keep-window --title "Contenido" --begin "$dialog_y" $(((cols / 2) + 1)) --tailboxbg /tmp/dialog_content "$dialog_height" "$dialog_width"
}

# Función para agregar contenido al archivo temporal
add_content() {
    while true; do
        IFS= read -rsn 1 input

        # Si se presiona la tecla "Enter", salir del bucle
        if [[ "$input" == $'\n' ]]; then
            break
        fi

        # Obtener el código de escape del carácter de retroceso
        backspace=$(tput kbs)

        # Si se presiona el carácter de retroceso, eliminar el último carácter
        if [[ "$input" == "$backspace" ]]; then
            content="${content%?}"
        else
            content+="$input"
        fi

        # Actualizar el contenido del archivo temporal
        echo "$content" >/tmp/dialog_content

        # Actualizar el diálogo en segundo plano
        update_dialog
    done
}

# Crear archivo temporal con contenido inicial
echo "Contenido inicial del diálogo" >/tmp/dialog_content

# Actualizar el diálogo por primera vez
update_dialog &

# Llamar a la función para agregar contenido al archivo temporal
add_content

# Eliminar el archivo temporal al finalizar
rm /tmp/dialog_content

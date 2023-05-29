#!/usr/bin/env bash

introText="Ingrese el nombre de usuario:"
content=""

touch /tmp/temp_passwd
touch /tmp/temp_temp
cut -d: -f1 </etc/passwd >/tmp/temp_passwd

starting_line=0
max_lines=$(($(wc -l </tmp/temp_passwd) - 1))

# Función para actualizar el diálogo
update_dialog() {

    tput cup 0 0

    # Obtener el tamaño de la terminal
    rows=$(tput lines)
    cols=$(tput cols)

    # Calcular la posición y el tamaño de la ventana del diálogo
    dialog_height=$((rows - 2))
    dialog_width=$(((cols - 2) / 2))
    dialog_x=$(((cols / 2) - dialog_width)) # Centrar horizontalmente en la parte izquierda
    dialog_y=$(((rows - dialog_height) / 2))

    # Calcular el número de líneas que caben en el diálogo
    dialog_header_lines=1 # Número de líneas de encabezado del diálogo
    dialog_footer_lines=1 # Número de líneas de pie del diálogo

    # Calcular el número de líneas que caben en el contenido del diálogo
    dialog_content_lines=$((dialog_height - dialog_header_lines - dialog_footer_lines))

    head -n $dialog_content_lines /tmp/users_content >/tmp/temp_temp
    cat /tmp/temp_temp >/tmp/users_content
    # Actualizar el diálogo
    dialog --no-clear --keep-window --title "Ingrese el nombre de usuario:" --begin "$dialog_y" "$dialog_x" --tailboxbg /tmp/dialog_content "$dialog_height" "$dialog_width" \
        --and-widget \
        --no-clear --keep-window --title "USUARIOS" --begin "$dialog_y" $(((cols / 2) + 1)) --tailboxbg /tmp/users_content "$dialog_height" "$dialog_width"
}

# Función para agregar contenido al archivo temporal
add_content() {
    while true; do
        IFS= read -sn 1 input

        # Si se presiona la tecla "Enter", salir del bucle
        if [[ "$input" == "" ]]; then
            return
        fi

        # Tecla especial
        # Leer las teclas de cursor (arriba y abajo)
        if [[ "$input" == $'\e' ]]; then
            read -sn 1
            read -sn 1 input
            if [[ "$input" == "A" ]]; then
                # Arriba
                if [[ $starting_line -gt 0 ]]; then
                    starting_line=$((starting_line - 1))
                fi
                tail -n +$((starting_line + 1)) /tmp/temp_passwd >/tmp/users_content
                update_dialog
            elif [[ "$input" == "B" ]]; then
                # Abajo
                if [[ $((($max_lines - $starting_line) + 1)) -ge $dialog_content_lines ]]; then

                    starting_line=$((starting_line + 1))
                fi
                tail -n +$((starting_line + 1)) /tmp/temp_passwd >/tmp/users_content
                update_dialog
            fi
            continue
        fi

        # Si se pulsa espacio se va a autocompletar content
        # con la primera coincidencia de nombre de usuario en
        # /etc/passwd/
        if [[ "$input" == " " ]]; then
            # Buscar la primera coincidencia que comience exactamente con el contenido de content
            max_match="$(grep -m 1 -E "^$content" /etc/passwd | cut -d: -f1)"

            # Si se encontró una coincidencia, actualizar content
            if [[ ! -z "$max_match" ]]; then
                content="$max_match"
            fi
        else
            # Si se presiona el carácter de retroceso, eliminar el último carácter
            if [[ "$input" == "$(tput kbs)" ]]; then
                content="${content%?}"
            else
                content+="$input"
            fi
        fi

        # Actualizar el contenido del archivo temporal
        echo "$content" >/tmp/dialog_content

        # Actualizar el user content con todas las coincidencias
        # que exclusivamente empiecen con lo que tenga $content
        # en el campo uno de passwd
        grep -E "^$content" /tmp/temp_passwd >/tmp/users_content
        max_lines=$(($(wc -l </tmp/temp_passwd) - 1))
        starting_line=0
        # Actualizar el diálogo en segundo plano
        update_dialog
    done
}

# Crear archivo temporal con contenido inicial
touch /tmp/dialog_content
touch /tmp/users_content
echo "" >/tmp/dialog_content
cut -d: -f1 </etc/passwd >/tmp/users_content

# Actualizar el diálogo por primera vez
update_dialog &

# Llamar a la función para agregar contenido al archivo temporal
add_content

# Eliminar el archivo temporal al finalizar
rm /tmp/dialog_content
rm /tmp/users_content
rm /tmp/temp_passwd
rm /tmp/temp_temp

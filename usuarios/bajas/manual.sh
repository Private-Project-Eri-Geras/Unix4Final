#!/usr/bin/env bash

introText="Ingrese el nombre de usuario:"
content=""

touch /tmp/temp_passwd
touch /tmp/temp_temp
cut -d: -f1 </etc/passwd >/tmp/temp_passwd

starting_line=1
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

    # Actualizar el contenido del archivo temporal
    echo -e "$content\n" >/tmp/dialog_content
    tempMessage="<Seleccionar> <Cancelar> <Ayuda>\n"

    # Imprimir símbolos ↑ (-) y ↓ (+) si corresponde
    if [[ $starting_line -gt 1 ]]; then
        tempMessage+=" <↑>(-)"
    else
        tempMessage+="       "
    fi

    if [[ $((($max_lines - $starting_line) + 3)) -gt $dialog_content_lines ]]; then
        tempMessage+=" <↓>(+)"
    fi
    echo -e "\n$tempMessage" >>/tmp/dialog_content
    tail -n +$starting_line /tmp/users_content >/tmp/temp_temp
    head -n $dialog_content_lines /tmp/temp_temp >/tmp/users_content
    # Actualizar el diálogo
    dialog --no-clear --no-hot-list --keep-window --title "Ingrese el nombre de usuario:" --begin "$dialog_y" "$dialog_x" --tailboxbg /tmp/dialog_content "$dialog_height" "$dialog_width" \
        --and-widget \
        --no-clear --keep-window --title "USUARIOS" --begin "$dialog_y" $(((cols / 2) + 1)) --tailboxbg /tmp/users_content "$dialog_height" "$dialog_width"
}

# Crear archivo temporal con contenido inicial
touch /tmp/dialog_content
touch /tmp/users_content
echo -e "$content\nDL $dialog_content_lines SL $starting_line ML $max_lines" >/tmp/dialog_content
cat /tmp/temp_passwd >/tmp/users_content
# Actualizar el diálogo por primera vez
update_dialog &

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
                if [[ $starting_line -gt 1 ]]; then
                    starting_line=$((starting_line - 1))
                fi
                cat /tmp/temp_passwd | grep -E "^$content" >/tmp/users_content
                update_dialog
            elif [[ "$input" == "B" ]]; then
                # Abajo
                if [[ $((($max_lines - $starting_line) + 2)) -ge $dialog_content_lines ]]; then
                    starting_line=$((starting_line + 1))
                fi
                cat /tmp/temp_passwd | grep -E "^$content" >/tmp/users_content
                update_dialog
            fi
            continue
        # Si se pulsa espacio se va a autocompletar content
        # con la primera coincidencia de nombre de usuario en
        # /etc/passwd/
        elif [[ "$input" == " " ]]; then
            # Buscar todas las coincidencias que comiencen exactamente con el contenido de content
            matches=($(grep -E "^$content" /tmp/temp_passwd | cut -d: -f1))

            # Si se encontraron coincidencias, actualizar content hasta el máximo prefijo común
            if [[ ${#matches[@]} -gt 0 ]]; then
                common_prefix="${matches[0]}"
                for match in "${matches[@]}"; do
                    prefix_length=$((${#common_prefix} < ${#match} ? ${#common_prefix} : ${#match}))
                    i=0
                    while [[ "$i" -lt "$prefix_length" ]]; do
                        if [[ "${common_prefix:$i:1}" != "${match:$i:1}" ]]; then
                            break
                        fi
                        i=$((i + 1))
                    done
                    common_prefix="${common_prefix:0:$i}"
                done
                content="$common_prefix"
            fi
        else
            # Si se presiona el carácter de retroceso, eliminar el último carácter
            if [[ "$input" == "$(tput kbs)" ]]; then
                content="${content%?}"
            else
                content+="$input"
            fi
        fi
        # Actualizar el user content con todas las coincidencias
        # que exclusivamente empiecen con lo que tenga $content
        grep -E "^$content" /tmp/temp_passwd >/tmp/users_content
        max_lines=$(($(wc -l </tmp/users_content) - 1))
        starting_line=1
        # Actualizar el diálogo en segundo plano
        update_dialog
    done
}

# Llamar a la función para agregar contenido al archivo temporal
add_content

# Eliminar el archivo temporal al finalizar
rm /tmp/dialog_content
rm /tmp/users_content
rm /tmp/temp_passwd
rm /tmp/temp_temp

# #!/usr/bin/env bash

# touch /tmp/usuarios_en_passwd.txt
# touch /tmp/usuario_seleccionado.txt
# cat /etc/passwd | cut -d: -f1 >/tmp/usuarios_en_passwd.txt
# usuarios=()
# inti=0
# #crear un vector de objetos int string
# # int es el numero de linea y string es el nombre de usuario, hacer un salto de linea por cada objeto
# # leer el archivo y por cada linea agregar un objeto al vector
# while read -r line; do
# i=$((i + 1))
# usuarios+=("$i" "$line")
# done </tmp/usuarios_en_passwd.txt
# for i in "${usuarios[@]}"; do
# echo "$i"
# done
# read -sn 1

# dialog --title "Baja de usuario" --menu "Seleccione el usuario a dar de baja" 15 10 0 "${usuarios[@]}" 2>/tmp/usuario_seleccionado.txt
# usuario=$(cat /tmp/usuario_seleccionado.txt)

# rm -f /tmp/usuarios_en_passwd.txt
# rm -f /tmp/usuario_seleccionado.txt

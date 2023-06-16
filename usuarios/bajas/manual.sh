#!/bin/bash

mostrar_ayuda() {
    echo 'Primero tienes que seleccionar un usuario
        de la lista de usuarios.
        Para seleccionarlo, puedes escribirlo.
        Si no lo conoces, puedes buscarlo apoyandote
        de las teclas cursor.
    Atajos de teclado:
        - 'Espacio' autocompletado (coinicidencia mas cercana)
        - 'Enter' seleccionar
        - 'Tab' moverse por los botones
    ' >/tmp/ayuda.txt
    dialog --backtitle "BAJA MANUAL" --title "AYUDA" \
        --exit-label "Ok" \
        --textbox /tmp/ayuda.txt 0 0 --scrollbar
    rm /tmp/ayuda.txt
}

introText="Ingrese el nombre de usuario:"
content=""

touch /tmp/temp_passwd
touch /tmp/temp_temp
cut -d: -f1 </etc/passwd >/tmp/temp_passwd

# Inicio de impresion del archivo en el panel de la derecha
starting_line=1
# lineas maximas que tiene passwd
max_lines=$(($(wc -l </tmp/temp_passwd) - 1))

# Selector de menu
# menu
tempMessage_Menu=("Seleccional" "Cancelar" "Ayuda")
# opcion seleccionada
tempMessage_iterator=0

delUser() {
    local user_name=$1

    # Verificar que el usuario exista
    if [[ $user_name == "" ]]; then
        dialog --title "ERROR" --msgbox "No se ha seleccionado un usuario" 10 40
        return
    # Verificar que el usuario sea valido
    # que exista en el sistema
    elif ! id -u "$user_name" >/dev/null 2>&1; then
        dialog --title "ERROR" --msgbox "El usuario no existe" 10 40
        return
    fi
    # Eliminar home
    dialog --title "Eliminar home" --yesno "¿Desea eliminar el directorio home del usuario?" 10 40
    if [[ $? -eq 0 ]]; then
        # Obtener la ruta del directorio home y eliminarlo
        home_dir=$(cut -d: -f6 < <(getent passwd "$user_name"))
        if [ -d "$home_dir" ]; then
            rm -rf "$home_dir"
        else
            dialog --title "ERROR" --msgbox "El directorio home no existe" 10 40
        fi
    fi
    # Eliminar usuario
    userdel "$user_name"
    # Verificar que el usuario se haya eliminado correctamente
    if [[ $? -eq 0 ]]; then
        dialog --title "ÉXITO" --msgbox "El usuario se ha eliminado correctamente" 10 40
    else
        dialog --title "ERROR" --msgbox "El usuario no se ha eliminado correctamente" 10 40
    fi
}

# Función para actualizar el diálogo
update_dialog() {
    # Obtener el tamaño de la terminal
    rows=$(tput lines)
    cols=$(tput cols)

    # Calcular la posición y el tamaño de la ventana del diálogo
    dialog_height=$((rows - 3))
    dialog_width=$(((cols - 4) / 2))
    dialog_x=$(((cols / 2) - dialog_width)) # Centrar horizontalmente en la parte izquierda
    dialog_y=$(((rows - dialog_height) / 2))
    # Calcular la posición y el tamaño de la ventana del dialogo izquierdo
    input_height=6
    input_width=$(((cols - 2) / 2))
    input_x=$(((cols / 2) - input_width)) # Centrar horizontalmente en la parte izquierda
    input_y=$(((rows - input_height) / 2))

    # Calcular el número de líneas que caben en el diálogo
    dialog_header_lines=2 # Número de líneas de encabezado del diálogo
    dialog_footer_lines=3 # Número de líneas de pie del diálogo

    # Calcular el número de líneas que caben en el contenido del diálogo
    dialog_content_lines=$((dialog_height - dialog_header_lines - dialog_footer_lines))
    tempMessage=""
    for ((i = 0; i < 3; i++)); do
        if [[ $i -eq $tempMessage_iterator ]]; then
            tempMessage+="\Zb<\Z4${tempMessage_Menu[$i]}\Z0>\Zn "
        else
            tempMessage+="<\Zb${tempMessage_Menu[$i]}\Zn>  "
        fi
    done

    # Actualizar el contenido del archivo temporal
    echo -e "\ZbIngresa el nombre de usuario:\ZB\n${content}┆\n" >/tmp/dialog_content
    echo "$tempMessage" >>/tmp/dialog_content

    #Formato de impresion de usuarios
    tail -n +$starting_line /tmp/users_content >/tmp/temp_temp
    # Imprimir símbolos ↑ (-) y ↓ (+) si corresponde
    if [[ $starting_line -gt 1 ]]; then
        echo " \Zb\Z1<↑>(-)\Zn" >/tmp/users_content
    else
        echo "     " >/tmp/users_content
    fi
    head -n $dialog_content_lines /tmp/temp_temp >>/tmp/users_content
    if [[ $((($max_lines - $starting_line) + 2)) -gt $dialog_content_lines ]]; then
        echo " \Zb\Z2<↓>(+)\Zn" >>/tmp/users_content
    fi
    # Actualizar el diálogo
    dialog --no-clear --no-hot-list --colors --title "USUARIO A ELIMINAR" --begin "$input_y" "$input_x" --infobox "$(cat /tmp/dialog_content)" "$input_height" "$input_width" \
        --and-widget \
        --no-hot-list --keep-window --colors --title "USUARIOS" --begin "$dialog_y" $(((cols / 2) + 1)) --infobox "$(cat /tmp/users_content)" "$dialog_height" "$dialog_width"
    tput smcup
    tput clear
    tput rmcup
}

# Función para agregar contenido al archivo temporal
add_content() {
    while true; do
        IFS= read -sn 1 input

        # Si se presiona la tecla "Enter", salir del bucle
        if [[ "$input" == "" ]]; then
            if [[ $tempMessage_iterator -eq 0 ]]; then
                delUser "$content"
                # Actualizar el contenido del archivo temporal /tmp/temp_passwd
                cut -d: -f1 </etc/passwd >/tmp/temp_passwd
                content=""
            elif [[ $tempMessage_iterator -eq 1 ]]; then
                return
            elif [[ $tempMessage_iterator -eq 2 ]]; then
                mostrar_ayuda
            fi
        fi
        # Si se pulso la tecla tabulador
        if [[ "$input" == $'\t' ]]; then
            if [[ $tempMessage_iterator -eq 2 ]]; then
                tempMessage_iterator=0
            else
                tempMessage_iterator=$((tempMessage_iterator + 1))
            fi
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
                if [[ $((($max_lines - $starting_line) + 1)) -ge $dialog_content_lines ]]; then
                    starting_line=$((starting_line + 1))
                fi
                cat /tmp/temp_passwd | grep -E "^$content" >/tmp/users_content
                update_dialog
            elif [[ "$input" == "C" ]]; then
                # Derecha
                if [[ $tempMessage_iterator -lt 2 ]]; then
                    tempMessage_iterator=$((tempMessage_iterator + 1))
                fi
                cat /tmp/temp_passwd | grep -E "^$content" >/tmp/users_content
                update_dialog
                continue
            elif [[ "$input" == "D" ]]; then
                # Izquierda
                if [[ $tempMessage_iterator -gt 0 ]]; then
                    tempMessage_iterator=$((tempMessage_iterator - 1))
                fi
                cat /tmp/temp_passwd | grep -E "^$content" >/tmp/users_content
                update_dialog
                continue
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
                # Tiene que ser cualquier caracter que sea alfanumérico
                # o los simbolos validos en un nombre -_!@+.
                if [[ "$input" =~ [[:alnum:]] || "$input" =~ [-_!@+.] ]]; then
                    content+="$input"
                fi
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

checkResize() {
    while true; do
        sleep 0.2
        local newCols=$(tput cols)
        local newRows=$(tput lines)
        if [[ $rows -ne $newRows ]]; then
            # Obtener content de dialog_content segunda linea
            dialog_content_lines=$(($(wc -l </tmp/dialog_content) - 3))
            # Obtener content de users_content segunda linea
            content=$(head -n 2 /tmp/dialog_content | tail -n 1)
            cat /tmp/temp_passwd | grep -E "^$content" >/tmp/users_content
            max_lines=$(($(wc -l </tmp/users_content) - 1))
            starting_line=1
            update_dialog
        fi
        if [[ $cols -ne $newCols ]]; then
            # Obtener content de dialog_content segunda linea
            dialog_content_lines=$(($(wc -l </tmp/dialog_content) - 3))
            # Obtener content de users_content segunda linea
            content=$(head -n 2 /tmp/dialog_content | tail -n 1)
            cat /tmp/temp_passwd | grep -E "^$content" >/tmp/users_content
            max_lines=$(($(wc -l </tmp/users_content) - 1))
            starting_line=1
            update_dialog
        fi
    done
}

# Crear archivo temporal con contenido inicial
touch /tmp/dialog_content
echo "" >/tmp/dialog_content
touch /tmp/users_content
cat /tmp/temp_passwd >/tmp/users_content

# Mandar a llamar el segundo plano el hilo que rescalara todo
checkResize &

# Llamar a la función para agregar contenido al archivo temporal
add_content

# Matar el hilo que rescalara todo
kill $!

# Eliminar el archivo temporal al finalizar
rm /tmp/dialog_content
rm /tmp/users_content
rm /tmp/temp_passwd
rm /tmp/temp_temp

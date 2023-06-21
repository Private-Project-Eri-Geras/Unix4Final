#!/bin/bash
mostrar_ayuda() {
    echo "Aquí se describe el formato del archivo .csv 
    para dar de alta usuarios de forma masiva:

    Username,Password,UID,GID,Shell,Grupos,DirectorioHome,ExpireDate,WarningDate
    Las líneas que empiezan con # serán ignoradas.

    -El único campo obligatorio es el nombre
        todos los demás pueden estar vacíos.
    -La contraseña debe cumplir con los
        requisitos típicos de Linux.
    -El UID y GID deben ser números enteros.
    -El shell debe ser una ruta válida a un
        shell.
    -Los grupos tiene que estar separados por
        espacios.
    -El directorio home debe ser una ruta
        válida.
        Si no se creara uno por defecto.
        Si se deja vacío, se creará uno por
            defecto.
    -ExpireDate debe ser una fecha en formato
        YYYY-MM-DD y valida.
        Si se deja por defecto, no expirará.
    -WarningDate debe ser una fecha en formato
        YYYY-MM-DD mayor a ExpireDate, también
        valida.
        Si se deja por defecto, no se asignará." >/var/glam/tmp/ayuda.txt
    dialog --backtitle "ALTA MANUAL" --title "AYUDA" \
        --exit-label "Ok" \
        --textbox /var/glam/tmp/ayuda.txt 0 0 
    rm /var/glam/tmp/ayuda.txt
}

checkDate() {
    local date="$1"
    #Formato YYYY-MM-DD
    if [[ "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        # Validar que la fecha sea válida
        if date -d "$date" >/dev/null 2>&1; then
            # Validar que la fecha sea mayor a la fecha actual
            if date -d "$date" +%s >/dev/null 2>&1; then
                echo 1
            else
                echo 0
            fi # Fin de fecha mayor a la actual
        else
            echo 0
        fi # Fin de la validación de la fecha
    else
        echo 0
    fi # Fin de la validación del formato
}

touch /var/glam/tmp/usuario.txt
while true; do
    # Formato:
    # name password uid gid shell groups home expDate expWarning
    dialog --title "ALTA MANUAL" \
        --cancel-label "Cancelar" \
        --help-button --help-label "Ayuda" \
        --form "Ingrese los datos del usuario" 15 47 9 \
        "Nombre de usuario" 1 1 "" 1 23 15 0 \
        "Contraseña" 2 1 "" 2 23 15 0 \
        "ID de usuario" 3 1 "" 3 23 15 0 \
        "ID de grupo" 4 1 "" 4 23 15 0 \
        "Shell" 5 1 "" 5 23 15 0 \
        "Grupos" 6 1 "" 6 23 15 0 \
        "Directorio home" 7 1 "" 7 23 15 0 \
        "Fecha de expiración" 8 1 "YYYY-MM-DD" 8 23 15 0 \
        "Días de advertencia" 9 1 "YYYY-MM-DD" 9 23 15 0 \
        2>/var/glam/tmp/usuario.txt
    form_status=$?
    #El usuario presionó "Cancelar"
    if [[ $form_status -eq 1 ]]; then
        return
    #El usuario presionó "Ayuda"
    elif [[ $form_status -eq 2 ]]; then
        mostrar_ayuda
        continue
    fi

    # El unico dato obligatorio es el nombre de usuario
    # Los demas son opcionales
    # nombre de usuario = linea 1
    name=$(head -1 /var/glam/tmp/usuario.txt)
    # contraseña = linea 2
    password=$(head -2 /var/glam/tmp/usuario.txt | tail -1)
    # id de usuario = linea 3
    uid=$(head -3 /var/glam/tmp/usuario.txt | tail -1)
    # id de grupo = linea 4
    gid=$(head -4 /var/glam/tmp/usuario.txt | tail -1)
    # shell = linea 5
    shell=$(head -5 /var/glam/tmp/usuario.txt | tail -1)
    # grupos = linea 6
    groups=$(head -6 /var/glam/tmp/usuario.txt | tail -1)
    # directorio home = linea 7
    home=$(head -7 /var/glam/tmp/usuario.txt | tail -1)
    # fecha de expiracion = linea 8
    expDate=$(head -8 /var/glam/tmp/usuario.txt | tail -1)
    # dias de advertencia = linea 9
    expWarning=$(head -9 /var/glam/tmp/usuario.txt | tail -1)

    # Verificar que el usuario no exista
    if id -u "$name" >/dev/null 2>&1; then
        dialog --title "ERROR" --msgbox "El usuario $name ya existe." 10 40
        return
    fi
    # Validar que el nombre solo tenga caracteres validos
    # solo letras mayusculas y minusculas, numeros y todos los caracteres especialese permitidos en Linux:
    # @ # _ ^ * % / . + : ; =
    if [[ ! $name =~ ^[a-zA-Z0-9_-]+$ ]]; then
        caracteres_invalidos=$(echo "$name" | grep -o '[^a-zA-Z0-9_-]')
        dialog --title "ERROR" --msgbox "Caracteres inválidos encontrados en el nombre de usuario: $caracteres_invalidos" 10 40
        return
    fi
    # El nombre tiene que empezar con una letra
    if [[ ! $name =~ ^[a-zA-Z] ]]; then
        dialog --title "ERROR" --msgbox "El nombre de usuario debe empezar con una letra." 10 40
        return
    fi

    command="useradd "
    # Verificar si se especificó una contraseña
    if [ -n "$password" ]; then
        # Validar que la contraseña solo tenga caracteres validos
        # solo letras mayusculas y minusculas, numeros y todos los caracteres especialese permitidos en Linux:
        # @ # _ ^ * % / . + : ; =
        if [[ ! $password =~ ^[a-zA-Z0-9@#_^\*%\/\.\+\:\;\=]+$ ]]; then
            caracteres_invalidos=$(echo "$password" | grep -o '[^a-zA-Z0-9@#_^\*%\/\.\+\:\;\=]')
            dialog --title "ERROR" --msgbox "Caracteres inválidos encontrados en la contraseña: $caracteres_invalidos" 10 40
        else
            # Establecer la contraseña
            encrypted_password=$(openssl passwd -1 -salt "salt_value" "$password")
            command+=" -p '$encrypted_password'"
        fi
    fi

    # Verificar si se especificó un UID
    if [ -n "$uid" ]; then
        # Verificar que el UID sea un valor numerico
        if [[ $uid =~ ^[0-9]+$ ]]; then
            # Verificar si el UID existe
            if grep -q "^$uid:" /etc/passwd; then
                # Mostrar un mensaje de error
                dialog --title "ERROR" --msgbox "El UID especificado $uid ya existe." 10 40
            else
                # Establecer el UID
                command+=" -u $uid"
            fi
        else
            # Mostrar un mensaje de error
            dialog --title "ERROR" --msgbox "El UID especificado $uid no es un valor numérico." 10 40
        fi
    fi

    # Verificar si se especificó un GID
    if [ -n "$gid" ]; then
        # Verificar que el GID sea un valor numerico
        if [[ $gid =~ ^[0-9]+$ ]]; then
            # Verificar si el grupo existe
            if grep -q "^$gid:" /etc/group; then
                # Establecer el GID
                command+=" -g $gid"
            else
                # Crear el grupo
                groupadd "$gid"
                # Establecer el GID
                command+=" -g $gid"
            fi
        else
            # Mostrar un mensaje de error
            dialog --title "ERROR" --msgbox "El GID especificado $gid no es un valor numérico." 10 40
        fi
    fi

    # Verificar si se especificó un shell
    if [ -n "$shell" ]; then
        # Verificar si el shell existe en el sistema
        if grep -q "^$shell$" /etc/shells; then
            # Establecer el shell
            command+=" -s $shell"
        else
            # Mostrar un mensaje de error
            dialog --title "ERROR" --msgbox "El shell especificado $shell no existe en el sistema." 10 40
        fi
    fi

    # Verificar que el separador de campos de los grupos sea un espacio en blanco
    # Verificar si se especificaron grupos
    # el formato de los grupos esta separado por espacios
    if [ -n "$groups" ]; then
        grupoCommand=" -G"
        IFS=' ' read -r -a grupos <<<"$groups"
        # Validar que los grupos existan
        for grupo in "${grupos[@]}"; do
            # Verificar si el grupo existe
            if getent group "$grupo" >/dev/null; then
                mensaje+=" Grupo: $grupo"
            else
                # Crear el grupo
                groupadd "$grupo"
                mensaje+=" Grupo creado: $grupo"
            fi
            # Agregar el usuario al grupo
            grupoCommand+=" $grupo,"
        done
        # Eliminar la coma al final de grupoCommand si existe
        grupoCommand=${grupoCommand%,}
        # Agregar los grupos al comando
        command+="$grupoCommand"
    fi

    # Si se especificó un directorio home, crearlo
    if [ -n "$home" ]; then
        # Verificar si la ruta home es una ruta sensible
        case "$home" in
        /etc/* | /root/* | /bin/* | /sbin/* | /lib/* | /lib64/* | /usr/bin/* | /usr/sbin/* | /usr/lib/* | /usr/lib64/* | /var/*)
            command+=" -m -d /home/$name"
            ;;
        *)
            command+=" -m -d $home"
            ;;
        esac
    else
        command+=" -m -d /home/$name"
    fi

    # Verificar si se especificó fecha de expiración
    # YYYY-MM-DD
    # si la variable n contiene YYYY-MM-DD se valida
    if [ "$expDate" != "YYYY-MM-DD" ]; then
        if [ -n "$expDate" ]; then
            validation=0
            validation=$(checkDate "$expDate")
            if [ "$validation" = "1" ]; then
                # Establecer la fecha de expiración
                command+=" -e $expDate"
                # Verificar si se especificó una fecha de warning
                # YYYY-MM-DD
                if [[ -n "$expWarning" && ! "$expWarning" =~ ^,+$ ]]; then
                    validation=0
                    validation=$(checkDate "$expWarning")
                    if [ "$validation" = "1" ]; then
                        # Verificar que la fecha de warning sea menor a la fecha de expiración
                        if [ "$expWarning" -gt "$expDate" ]; then
                            # Mostrar un mensaje de error
                            dialog --title "ERROR" --msgbox "La fecha de warning especificada $expWarning es mayor a la fecha de expiración $expDate." 10 40
                            return
                        else
                            # Establecer la fecha de warning
                            command+=" -W $expWarning"
                            mensaje+=" Fecha de warning: $expWarning"
                        fi
                    else
                        # Mostrar un mensaje de error
                        dialog --title "ERROR" --msgbox "La fecha de warning especificada $expWarning no es válida." 10 40
                        return
                    fi
                fi
            else
                # Mostrar un mensaje de error
                dialog --title "ERROR" --msgbox "La fecha de expiración especificada $expDate no es válida." 10 40
                return
            fi
        fi
    fi

    # Agregar usuario
    command+=" $name"
    # Invocar el comando utilizando eval
    eval "$command"
done

rm /var/glam/tmp/usuario.txt

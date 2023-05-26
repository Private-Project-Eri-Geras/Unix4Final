#!/usr/bin/env bash

addUsers() {
    # archivo de usuario
    archivo_usuarios=$1

    #obtenemos la fecha
    current_date=$(date +"%Y_%m_%d_%H_%M")

    # Obtener el nombre de usuario
    usuario_actual="$USER"

    # Crear el directorio de logs si no existe
    mkdir -p logs

    # Asignar la ruta del archivo de registro
    log_file="logs/altaMasiva_${current_date}.log"
    counter=1

    # Verificar que el archivo de registro no exista
    # si existe, agregar un contador al nombre del archivo
    # ejemplo altaMasiva_12_30(1).log
    while [ -f "$log_file" ]; do
        log_file="logs/altaMasiva_${current_date}_($counter).log"
        ((counter++))
    done

    # Crear el archivo de registro
    touch "$log_file"

    # Inicializar el contador de líneas procesadas
    lineas_procesadas=0

    # Hacer saber al usuario que se están creando los usuarios
    dialog --clear --title "ALTA MASIVA DE USUARIOS" --infobox "Creando usuarios, por favor espere..." 0 0

    # Leer el archivo y procesar los datos
    # el unico dato que se necesita es el nombre de usuario
    # el resto de los datos se pueden ignorar o son opcionales o estar vacios
    # formato del archivo:
    # nombre_usuario,contraseña,uid ,gid,shell ,grupos,crear_home,directorio_home,fecha_expiracion   ,advertencia_expiracion
    # String         String     int  int String String bool       bool            String YYYY-MM-DD   String YYYY-MM-DD
    while IFS=',' read -r name password uid gid shell groups createHome home expDate expWarning; do
        ((lineas_procesadas++))
        if [[ $name =~ ^# ]]; then
            # Si la línea comienza con #, se ignora
            continue
        fi
        # Verificar que los datos sean correctos
        if [ -z "$name" ]; then
            mensaje_error="ERROR: Falta nombre de usuario en $lineas_procesadas."
            echo "$mensaje_error" >>"$log_file"
            # Incrementar el contador de líneas
            continue
        fi
        # Verificar que el usuario no exista
        if id -u "$name" >/dev/null 2>&1; then
            mensaje_error="ERROR: El usuario $name de la línea $lineas_procesadas ya existe."
            echo "$mensaje_error" >>"$log_file"
            continue
        fi
        # Validar que el nombre solo tenga caracteres validos
        # solo letras mayusculas y minusculas, numeros y todos los caracteres especialese permitidos en Linux:
        # @ # _ ^ * % / . + : ; =
        if [[ ! $name =~ ^[a-zA-Z0-9@#_^\*%\/\.\+\:\;\=]+$ ]]; then
            mensaje_error="ERROR: El nombre de usuario $name de la línea $lineas_procesadas contiene caracteres no válidos."
            echo "$mensaje_error" >>"$log_file"
            continue
        fi
        mensaje="$lineas_procesadas .- $name"

        command="useradd "
        # Verificar si se especificó una contraseña
        if [ -n "$password" ]; then
            # Establecer la contraseña
            command+=" -p $(openssl passwd -crypt "$password")"
            mensaje+=" Contraseña: $password"
        fi

        # Verificar si se especificó un UID
        if [ -n "$uid" ]; then
            # Verificar que el UID sea un valor numerico
            if [[ $uid =~ ^[0-9]+$ ]]; then
                # Verificar si el UID existe
                if grep -q "^$uid:" /etc/passwd; then
                    # Mostrar un mensaje de error
                    mensaje_error="ERROR: El UID especificado $uid del usuario $name en la línea $lineas_procesadas ya existe."
                    echo "$mensaje_error" >>"$log_file"
                else
                    # Establecer el UID
                    command+=" -u $uid"
                    mensaje+=" UID: $uid"
                fi
            else
                # Mostrar un mensaje de error
                mensaje_error="ERROR: El UID especificado $uid del usuario $name en la línea $lineas_procesadas no es un valor numérico."
                echo "$mensaje_error" >>"$log_file"
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
                mensaje+=" GID: $gid"
            else
                # Mostrar un mensaje de error
                mensaje_error="ERROR: El GID especificado $gid del usuario $name en la línea $lineas_procesadas no es un valor numérico."
                echo "$mensaje_error" >>"$log_file"
            fi
        fi

        # Verificar si se especificó un shell
        if [ -n "$shell" ]; then
            # Verificar si el shell existe en el sistema
            if grep -q "^$shell$" /etc/shells; then
                # Establecer el shell
                command+=" -s $shell"
                mensaje+=" Shell: $shell"
            else
                # Mostrar un mensaje de error
                mensaje_error="ERROR: El shell especificado $shell del usuario $name en la línea $lineas_procesadas no existe."
                echo "$mensaje_error" >>"$log_file"
            fi
        fi

        # Verificar si se especificaron grupos
        # el formato de los grupos esta separado por espacios
        if [ -n "$groups" ]; then
            grupoCommand=" -G"
            # Leer el valor de groups y almacenarlo en un array
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
                grupoCommand+=" $grupo"
            done
            # Agregar los grupos al comando
            command+="$grupoCommand"
        fi

        # Verificar si se especificó la creación del directorio home
        # createHome no tiene que ser case sensitive
        # valores verdaderos: yes, y, true, t, 1, s, si, crear
        # valores falsos: no, n, false, f, 0, no, no crear, "" (vacío)
        createHome="${createHome,,}" # Convertir a minúsculas
        if [ "$createHome" = "yes" ] || [ "$createHome" = "y" ] || [ "$createHome" = "true" ] || [ "$createHome" = "t" ] || [ "$createHome" = "1" ] || [ "$createHome" = "s" ] || [ "$createHome" = "si" ] || [ "$createHome" = "crear" ]; then
            # Si se especificó un directorio home, crearlo
            if [ -n "$home" ]; then
                # Verificar si la ruta home es una ruta sensible
                case "$home" in
                /etc/* | /root/* | /bin/* | /sbin/* | /lib/* | /lib64/* | /usr/bin/* | /usr/sbin/* | /usr/lib/* | /usr/lib64/* | /var/*)
                    mensaje+=" Ruta home no válida creando default"
                    createDefaulHome
                    ;;
                *)
                    command+=" -m -d $home"
                    mensaje+=" Directorio home: $home"
                    ;;
                esac
            else
                mensaje+=" Creando home default"
                createDefaulHome
            fi
        fi

        # Verificar si se especificó fecha de expiración
        # YYYY-MM-DD
        if [ -n "$expDate" ]; then
            validation=0
            validation=$(checkDate "$expDate")
            if [ "$validation" = "1" ]; then
                # Establecer la fecha de expiración
                command+=" -e $expDate"
                mensaje+=" Fecha de expiración: $expDate"
                # Verificar si se especificó una fecha de warning
                # YYYY-MM-DD
                if [[ -n "$expWarning" && ! "$expWarning" =~ ^,+$ ]]; then
                    validation=0
                    validation=$(checkDate "$expWarning")
                    if [ "$validation" = "1" ]; then
                        # Verificar que la fecha de warning sea menor a la fecha de expiración
                        if [ "$expWarning" -gt "$expDate" ]; then
                            # Mostrar un mensaje de error
                            mensaje_error="ERROR: La fecha de warning especificada $expWarning del usuario $name en la línea $lineas_procesadas es mayor a la fecha de expiración $expDate."
                            echo "$mensaje_error" >>"$log_file"
                        else
                            # Establecer la fecha de warning
                            command+=" -W $expWarning"
                            mensaje+=" Fecha de warning: $expWarning"
                        fi
                    else
                        # Mostrar un mensaje de error
                        mensaje_error="ERROR: La fecha de warning especificada $expWarning del usuario $name en la línea $lineas_procesadas no es válida."
                        echo "$mensaje_error" >>"$log_file"
                    fi
                fi
            else
                # Mostrar un mensaje de error
                mensaje_error="ERROR: La fecha de expiración especificada $expDate del usuario $name en la línea $lineas_procesadas no es válida."
                echo "$mensaje_error" >>"$log_file"
            fi
        fi

        # Agregar usuario
        command+=" $name"
        # Invocar el comando utilizando eval
        eval "$command"

        mensaje+=" Fecha de creación: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "$mensaje" >>"$log_file"
        # ================================================
    done <"$archivo_usuarios" # Fin del ciclo while
    # ================================================

    dialog --colors --title "ALTA TERMINADA" --msgbox "Puedes ver el registro en el archivo \Z1$log_file\Zn" 0 0 --clear
}

createDefaulHome() {
    command+=" -m -d /home/$name"

    mensaje+=" Directorio home: /home/$name"
}

# Función para validar el formato de la fecha
# Formato YYYY-MM-DD
# retorna 1 si la fecha es válida
# retorna 0 si la fecha no es válida
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
while true; do
    archivo_usuarios=$(dialog --title "Selecciona un archivo" \
        --stdout --cursor-off-label --fselect /home/ 14 70)
    archivo_usuario_Output=$?
    # Si el usuario presiona "Cancel" se sale del script
    if [ $archivo_usuario_Output -eq 1 ]; then
        break
    fi
    if [ -f "$archivo_usuarios" ]; then
        dialog --title "CONFIRMAR" --yesno "¿Deseas usar el archivo $archivo_usuarios?" 0 0
        dialog_Output=$?
        if [ $dialog_Output -eq 0 ]; then
            # Si el usuario presiona "Yes" se ejecuta la función addUsers
            clear
            addUsers "$archivo_usuarios"
            break # Salir del ciclo while después de confirmar
        fi
    else
        break # Salir del ciclo while si no se selecciona un archivo
    fi
done

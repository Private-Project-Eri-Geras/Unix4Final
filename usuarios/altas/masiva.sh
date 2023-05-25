#!/usr/bin/env bash

addUsers() {
    # archivo de usuario
    archivo_usuarios=$1

    # Obtener el nombre de usuario
    usuario_actual="$USER"

    # Crear el directorio de logs si no existe
    mkdir -p logs

    # Asignar la ruta del archivo de registro
    log_file="logs/altaMasiva_$(date +%H)_$(date +%M).log"
    counter=1

    # Verificar que el archivo de registro no exista
    # si existe, agregar un contador al nombre del archivo
    # ejemplo altaMasiva_12_30(1).log
    while [ -f "$log_file" ]; do
        log_file="logs/altaMasiva_$(date +%H)_$(date +%M)_($counter).log"
        ((counter++))
    done

    # Crear el archivo de registro
    touch "$log_file"

    # Escribir el nombre de usuario en la primera línea del archivo de registro
    echo "Usuario: $usuario_actual" >>"$log_file"



    # Inicializar el contador de líneas procesadas
    lineas_procesadas=0
    
    # Hacer saber al usuario que se están creando los usuarios
    dialog --no-clear --title "ALTA MASIVA DE USUARIOS" --infobox "Creando usuarios, por favor espere..." 10 40
    
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
        mensaje="$lineas_procesadas .- $name"
        useradd "$name"
        # Esperar a que el usuario se haya creado correctamente
        # si no se creo, volverlo intentar un maximo de 3 veces
        # si no se pudo crear mandar mensaje de error
        counter=0
        while [ $? -ne 0 ]; do
            useradd "$name"
            ((counter++))
            sleep 1
            if [ $counter -gt 3 ]; then
                mensaje_error="ERROR: El usuario $name de la línea $lineas_procesadas no se pudo crear."
                echo "$mensaje_error" >>"$log_file"
                break
            fi
        done        
        # Usuario creado correctamente

        # Verificar si se especificó una contraseña
        if [ -n "$password" ]; then
            # Establecer la contraseña
            echo "$name:$password" | chpasswd
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
                    usermod -u "$uid" "$name"
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
                    usermod -g "$gid" "$name"
                else
                    # Crear el grupo
                    groupadd "$gid"
                    # Establecer el GID
                    usermod -g "$gid" "$name"
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
                usermod -s "$shell" "$name"
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
            # Leer el valor de groups y almacenarlo en un array
            IFS=' ' read -r -a grupos <<< "$groups"
            # Validar que los grupos existan
            for grupo in "${grupos[@]}"; do
                # Verificar si el grupo existe
                if grep -q "^$grupo:" /etc/group; then
                    # Agregar el usuario al grupo
                    usermod -a -G "$grupo" "$name"
                    mensaje+=" Grupo: $grupo"
                else
                    # Mostrar un mensaje de error
                    mensaje_error="ERROR: El grupo especificado $grupo del usuario $name en la línea $lineas_procesadas no existe."
                    echo "$mensaje_error" >>"$log_file"
                fi
            done
        fi

        # Verificar si se especificó la creación del directorio home
        # createHome no tiene que ser case sensitive
        # valores verdaderos: yes, y, true, t, 1, s, si, crear
        # valores falsos: no, n, false, f, 0, no, no crear, "" (vacío)
        createHome="${createHome,,}" # Convertir a minúsculas
        if [ "$createHome" = "yes" ] || [ "$createHome" = "y" ] || [ "$createHome" = "true" ] || [ "$createHome" = "t" ] || [ "$createHome" = "1" ] || [ "$createHome" = "s" ] || [ "$createHome" = "si" ] || [ "$createHome" = "crear" ]; then
            # Si se especifico un directorio home, crearlo
            if [ -n "$home" ]; then
                # Crear el directorio home
                mkdir -p "$home"
                # Establecer los permisos
                chmod 700 "$home"
                # Establecer el propietario
                chown "$name:$name" "$home"
                mensaje+=" Directorio home: $home"
            else
                # Crear el directorio home apartir de $"HOME"
                mkdir -p "$HOME/$name"
                # Establecer los permisos
                chmod 700 "$HOME/$name"
                # Establecer el propietario
                chown "$name:$name" "$HOME/$name"
                mensaje+=" Directorio home: $HOME/$name"
            fi
        fi

        # Verificar si se especificó fecha de expiración
        # YYYY-MM-DD
        if [ -n "$expDate" ]; then
            validation=0
            validation=$(checkDate "$expDate")
            if [ "$validation" = "1" ]; then
                # Establecer la fecha de expiración
                chage -E "$expDate" "$name"
                mensaje+=" Fecha de expiración: $expDate"
            else
                # Mostrar un mensaje de error
                mensaje_error="ERROR: La fecha de expiración especificada $expDate del usuario $name en la línea $lineas_procesadas no es válida."
                echo "$mensaje_error" >>"$log_file"
            fi
        fi

        # Verificar si se especificó una fecha de warning
        # YYYY-MM-DD
        if [[ -n "$expWarning" && ! "$expWarning" =~ ^,+$ ]]; then
            validation=0
            validation=$(checkDate "$expWarning")
            if [ "$validation" = "1" ]; then
                # Establecer la fecha de warning
                chage -W "$expWarning" "$name"
                mensaje+=" Fecha de warning: $expWarning"
            else
                # Mostrar un mensaje de error
                mensaje_error="ERROR: La fecha de warning especificada $expWarning del usuario $name en la línea $lineas_procesadas no es válida."
                echo "$mensaje_error" >>"$log_file"
            fi
        fi

        mensaje+=" Fecha de creación: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "$mensaje" >>"$log_file"
    # ================================================
    done <"$archivo_usuarios" # Fin del ciclo while
    # ================================================

    dialog --no-clear --colors --title "ALTA TERMINADA" --msgbox "Puedes ver el registro en el archivo \Z1$log_file\Zn" 0 0
}

# Función para validar el formato de la fecha
# Formato YYYY-MM-DD
# retorna 1 si la fecha es válida
# retorna 0 si la fecha no es válida
checkDate(){
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
    archivo_usuarios=$(dialog --no-clear --title "Selecciona un archivo" \
        --stdout \
        --fselect "$HOME"/ 14 70)
    archivo_usuario_Output=$?
    # Si el usuario presiona "Cancel" se sale del script
    if [ $archivo_usuario_Output -eq 1 ]; then
        break
    fi
    if [ -f "$archivo_usuarios" ]; then
        dialog --no-clear --title "CONFIRMAR" --yesno "¿Deseas usar el archivo $archivo_usuarios?" 0 0 
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

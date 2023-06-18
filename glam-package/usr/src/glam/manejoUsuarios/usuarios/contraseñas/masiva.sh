#!/bin/bash
mostrar_ayuda() {
    echo 'Aquí se describe el formato del archivo .csv 
    para cambiar la contraseñá a usuarios de forma masiva:
    Username,Password
    Las líneas que empiezan con # serán ignoradas.

    - Username: Nombre de usuario a cambiar la contraseña.
    - Password: Contraseña a asignar al usuario.
         La contraseña tiene que cumplir con los requisitos
            básicos de Linux.' >/var/glam/tmp/ayuda.txt
    dialog --backtitle "CAMBIO CONTRASEÑAS MASIVA" --title "AYUDA" \
        --exit-label "Ok" \
        --textbox /var/glam/tmp/ayuda.txt 0 0 --scrollbar
    rm /var/glam/tmp/ayuda.txt
}

changePasswd() {
    archivo_usuarios=$1

    # archivo de usuario
    archivo_usuarios=$1

    #obtenemos la fecha
    current_date=$(date +"%Y_%m_%d_%H_%M")

    # Obtener el nombre de usuario
    usuario_actual="$USER"

    # Asignar la ruta del archivo de registro
    log_file="/GLAM/logs/contrasena/contraseniaMasiva_${current_date}.log"
    # Crear el directorio de logs si no existe
    mkdir -p /GLAM/logs
    mkdir -p /GLAM/logs/contrasena
    counter=1

    # Verificar que el archivo de registro no exista
    # si existe, agregar un contador al nombre del archivo
    # ejemplo altaMasiva_12_30(1).log
    while [ -f "$log_file" ]; do
        log_file="logs/contraseniaMasiva_${current_date}_($counter).log"
        ((counter++))
    done

    # Crear el archivo de registro
    touch "$log_file"

    # Inicializar el contador de líneas procesadas
    lineas_procesadas=0

    # Hacer saber al usuario que se están creando los usuarios
    dialog --title "CAMBIO DE CONTRASEÑAS MASIVA DE USUARIOS" --infobox "Eliminando usuarios, por favor espere..." 10 40

    # Leer el archivo y procesar los datos
    # dato neceario nombre de usuario, el otro campo se puuede ignorar
    # formato del archivo:
    # nombre_usuario, delHome
    # usuario1,    si
    while IFS=',' read -r name passwd; do
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
        mensaje="$lineas_procesadas .-"
        # Verificar que el usuario exista
        if id -u "$name" >/dev/null 2>&1; then
            # Si el usuario existe, se le cambiara la contraseña
            # Verificar si se especificó una contraseña
            if [ -n "$password" ]; then
                # Validar que la contraseña solo tenga caracteres validos
                # solo letras mayusculas y minusculas, numeros y todos los caracteres especialese permitidos en Linux:
                # @ # _ ^ * % / . + : ; =
                if [[ ! $password =~ ^[a-zA-Z0-9@#_^\*%\/\.\+\:\;\=]+$ ]]; then
                    caracteres_invalidos=$(echo "$password" | grep -o '[^a-zA-Z0-9@#_^\*%\/\.\+\:\;\=]')
                    mensaje_error="ERROR: Caracteres inválidos encontrados en la contraseña: $caracteres_invalidos"
                    echo "$mensaje_error" >>"$log_file"
                else
                    # Cambiar la contraseña
                    echo "$password:$password" | passwd "$name" -q >/dev/null 2>&1
                    mensaje="$mensaje La contraseña del usuario $name ha sido cambiada"
                fi
            else
                mensaje="$mensaje La contraseña del usuario $name no ha sido cambiada"
            fi
        else
            mensaje="$mensaje El usuario $name de la linea $lineas_procesadas no existe"
        fi

        # Agregar el mensaje al archivo de registro
        echo "$mensaje" >>"$log_file"
        # ================================================
    done <"$archivo_usuarios" # Fin del ciclo while
    # ================================================
}

while true; do
    archivo_usuarios=$(dialog --title "Selecciona un archivo" \
        --cancel-label "Cancelar" \
        --help-button --help-label "Ayuda" \
        --stdout --cursor-off-label --fselect /home/ 14 70)
    archivo_usuario_Output=$?
    # Si el usuario presiona "Ayuda" se muestra la ayuda
    if [ $archivo_usuario_Output -eq 2 ]; then
        mostrar_ayuda
    # Si el usuario presiona "Cancel" se sale del script
    elif [ $archivo_usuario_Output -eq 1 ]; then
        break
        # Si el usuario presiona "Ok" se verifica que el archivo exista
    elif [ $archivo_usuario_Output -eq 0 ]; then
        if [ -f "$archivo_usuarios" ]; then
            dialog --title "CONFIRMAR" --yesno "¿Deseas usar el archivo $archivo_usuarios?" 0 0
            dialog_Output=$?
            if [ $dialog_Output -eq 0 ]; then
                # Si el usuario presiona "Yes" se ejecuta la función removeUsers
                clear
                changePasswd "$archivo_usuarios"
                break # Salir del ciclo while después de confirmar
            fi
        else
            if [ -z "$archivo_usuarios" ]; then
                dialog --title "ERROR" --msgbox "No se seleccionó ningún archivo." 0 0
            elif [ -d "$archivo_usuarios" ]; then
                dialog --title "ERROR" --msgbox "El archivo seleccionado es un directorio." 0 0
            elif [ ! -f "$archivo_usuarios" ]; then
                dialog --title "ERROR" --msgbox "El archivo seleccionado no existe." 0 0
            fi
        fi
    fi
done

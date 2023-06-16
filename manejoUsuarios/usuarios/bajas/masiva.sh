#!/bin/bash
mostrar_ayuda() {
    echo 'Aquí se describe el formato del archivo .csv 
    para dar de baja usuarios de forma masiva:

    Username,delHome
    Las líneas que empiezan con # serán ignoradas.

    - Username: Nombre de usuario a dar de baja.
    - delHome: Si se desea eliminar el directorio home del usuario.
        - Si se desea eliminar el directorio home
             escribir "Y y S s Si si Yes yes 1".
        - Si no se desea eliminar el directorio home
             escribir cualquier otra cosa o dejar vacío.
    ' >/var/glam/tmp/ayuda.txt
    dialog --backtitle "BAJA MASIVA" --title "AYUDA" \
        --exit-label "Ok" \
        --textbox /var/glam/tmp/ayuda.txt 0 0 --scrollbar
    rm /var/glam/tmp/ayuda.txt
}

removeUsers() {
    archivo_usuarios=$1

    # archivo de usuario
    archivo_usuarios=$1

    #obtenemos la fecha
    current_date=$(date +"%Y_%m_%d_%H_%M")

    # Obtener el nombre de usuario
    usuario_actual="$USER"

    # Asignar la ruta del archivo de registro
    log_file="/GLAM/logs/bajas/bajaMasiva_${current_date}.log"
    # Crear el directorio de logs si no existe
    mkdir -p /GLAM/logs
    mkdir -p /GLAM/logs/bajas
    counter=1

    # Verificar que el archivo de registro no exista
    # si existe, agregar un contador al nombre del archivo
    # ejemplo altaMasiva_12_30(1).log
    while [ -f "$log_file" ]; do
        log_file="logs/bajaMasiva_${current_date}_($counter).log"
        ((counter++))
    done

    # Crear el archivo de registro
    touch "$log_file"

    # Inicializar el contador de líneas procesadas
    lineas_procesadas=0

    # Hacer saber al usuario que se están creando los usuarios
    dialog --title "BAJA MASIVA DE USUARIOS" --infobox "Eliminando usuarios, por favor espere..." 10 40

    # Leer el archivo y procesar los datos
    # dato neceario nombre de usuario, el otro campo se puuede ignorar
    # formato del archivo:
    # nombre_usuario, delHome
    # usuario1,    si
    while IFS=',' read -r name delHome; do
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
            # Si el usuario existe, se eliminara, pero primero
            # se valida si se tiene que eliminar el directorio home
            # respuestas validas:
            # Y y S s Si si Yes yes 1 delete eliminar borrar
            # no es case sensitive
            delHome="${delHome,,}" # convertir a minusculas
            if [[ $delHome =~ ^(y|s|si|yes|1|delete|eliminar|borrar)$ ]]; then
                # Obtener la ruta del directorio home y eliminarlo
                home_dir=$(cut -d: -f6 < <(getent passwd "$name"))
                if [ -d "$home_dir" ]; then
                    rm -rf "$home_dir"
                    mensaje="$mensaje Se elimino el directorio home... "
                else
                    mensaje="$mensaje Warning <El directorio home no existe>"
                fi
            fi
            # Eliminar el usuario
            userdel "$name"
            mensaje="$mensaje Se elimino el usuario"
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
                removeUsers "$archivo_usuarios"
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

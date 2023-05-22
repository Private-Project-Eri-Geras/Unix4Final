#!/bin/bash

addUsers() {
    #!/bin/bash

    # Obtener el nombre de usuario
    usuario_actual="$USER"

    # Crear el archivo de registro
    log_file="logs/altaMasiva_$(date +%H)_$(date +%M).log"
    counter=1

    while [ -f "$log_file" ]; do
        log_file="logs/altaMasiva_$(date +%H)_$(date +%M)_($counter).log"
        ((counter++))
    done

    mkdir -p logs
    touch "$log_file"

    # Escribir el nombre de usuario en la primera línea del archivo de registro
    echo "Usuario: $usuario_actual" >>"$log_file"

    # archivo de usuario
    archivo_usuarios=$1

    # Contar el número total de líneas en el archivo
    total_lineas=$(wc -l <"$archivo_usuarios")

    # Inicializar el contador de líneas procesadas
    lineas_procesadas=0

    # Leer el archivo y procesar los datos
    while IFS=',' read -r nombre apellido correo; do
        ((lineas_procesadas++))
        # Verificar que los datos sean correctos
        if [ -z "$nombre" ] || [ -z "$apellido" ] || [ -z "$correo" ]; then
            mensaje_error="Los datos del usuario en la línea $lineas_procesadas no son correctos."
            echo "$mensaje_error" >>"$log_file"

            # Incrementar el contador de líneas
            continue
        fi
        # Lógica para crear el usuario
        # Puedes utilizar comandos como useradd, adduser, etc.
        # Por ejemplo:
        # useradd -m -s /bin/bash -c "Nombre Completo" nombre_usuario
        mensaje="Creando usuario $nombre $apellido $correo"
        echo "$mensaje" >>"$log_file"

        # Actualizar la barra de progreso
        porcentaje=$((lineas_procesadas * 100 / total_lineas))
        echo $porcentaje | dialog --title "DANDO DE ALTA" --no-shadow --gauge "Procesando usuarios: $lineas_procesadas de $total_lineas" 10 70 0
    done <"$archivo_usuarios"

    clear
    dialog --title "ALTA TERMINADA" --msgbox "Puedes ver el registro en el archivo $log_file" 6 30 --clear

}

while true; do
    archivo_usuarios=$(dialog --title "Selecciona un archivo" \
        --stdout \
        --fselect $HOME/ 14 70)

    if [ -f "$archivo_usuarios" ]; then
        dialog --title "CONFIRMAR" --yesno "¿Deseas usar el archif $archivo_usuarios?" 0 0 --clear
        dialo --title "ALTA MASIVA DE USUARIOS" --infobox "Creando usuarios..." 0 0 --clear
        addUsers "$archivo_usuarios"
        break # Salir del ciclo while después de confirmar
    else
        break # Salir del ciclo while si no se selecciona un archivo
    fi
done

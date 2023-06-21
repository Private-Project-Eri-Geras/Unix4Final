#!/bin/bash

mostrar_ayuda() {
    # pausar el PID del proceso resize
    kill -s STOP $PID_RESIZE
    echo 'Primero tienes que seleccionar un usuario
        de la lista de usuarios.
    Una ves seleccionado, si aceptas, se desplegara una
        ventana con las aplicaciones que esta corriendo
        el usuario seleccionado.
    Pulsa espacio para salir.' >/var/glam/tmp/ayuda.txt
    dialog --backtitle "BAJA MANUAL" --title "AYUDA" \
        --exit-label "Ok" \
        --textbox /var/glam/tmp/ayuda.txt 0 0
    rm /var/glam/tmp/ayuda.txt
    # reanudar el PID del proceso resize
    kill -s CONT $PID_RESIZE
}

ventana() {
    archivo="/var/glam/tmp/monitorAplicacionesOld.txt"
    touch "$archivo"
    cat "$archivo" >/var/glam/tmp/monitorAplicaciones.txt
    echo "\Zb<\Z4Salir \ZB(espacio)\Zb\Z0>\Zn" >>/var/glam/tmp/monitorAplicaciones.txt
    dialog --backtitle "Para salir precione <espacio>" --colors --title "APLICACIONES DE $1" \
        --infobox "$(cat /var/glam/tmp/monitorAplicaciones.txt)" 0 0
    rm /var/glam/tmp/monitorAplicaciones.txt
}

# Función para monitorear las aplicaciones de un usuario
monitorAplicaciones() {
    touch /var/glam/tmp/selected.txt
    local user_name=$(cat /var/glam/tmp/selected.txt)
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
    # Verificar que el usuario este en linea
    if ! who | grep -q "$user_name"; then
        dialog --title "ERROR" --msgbox "El usuario no esta en linea" 10 40
        return
    fi
    old="/var/glam/tmp/monitorAplicacionesOld.txt"
    new="/var/glam/tmp/monitorAplicacionesNew.txt"
    ps -u "$user_name" -o comm= | awk '!x[$0]++' >$old
    ps -u "$user_name" -o comm= | awk '!x[$0]++' >$new
    sleep 0.2
    ventana "$user_name" &
    while true; do
        IFS= read -rsn1 -t 0.5 key
        if [[ $key == " " ]]; then
            return
        else
            ps -u "$user_name" -o comm= | awk '!x[$0]++' >$new
            # si hay cambios en el archivo, actualizar
            if [[ $(cat $old) != $(cat $new) ]]; then
                # actualizar el archivo old con el nuevo valor
                cat $new >$old
                # matar en bruto el proceso de la ventana
                ventana "$user_name" &
            fi
        fi

    done
}

# obtener los usuarios que esten en linea
who | sort -k1,1 -u >/var/glam/tmp/temp_who.txt

# crear un vector con los usuarios
# campo 1: nombre de usuario
# campo 2: tty
i=0
usuarios=()
while read -r line; do
    usuarios[$i]=$(echo "$line" | awk '{print $1}')
    usuarios[$i + 1]=$(echo "$line" | awk '{print $2}')
    i=$((i + 2))
done </var/glam/tmp/temp_who.txt

while true; do
    #menú de seleccion de usuario
    selected=$(dialog --backtitle "Monitoreo" --title "SELECCIONA UN USUARIO" \
        --exit-label "Salir" --help-button --help-label "Ayuda" \
        --menu "Selecciona al usuario" 0 0 0 "${usuarios[@]}" \
        --output-fd 1)
    dialogoutput=$?
    # si se presiona el boton de ayuda
    if [[ $dialogoutput -eq 2 ]]; then
        mostrar_ayuda
        continue
    elif [[ $dialogoutput -eq 1 ]]; then
        break
    elif [[ $dialogoutput -eq 0 ]]; then
        echo $selected >/var/glam/tmp/selected.txt
        monitorAplicaciones $select
    fi
done

# Eliminar el archivo temporal al finalizar
rm /var/glam/tmp/selected.txt

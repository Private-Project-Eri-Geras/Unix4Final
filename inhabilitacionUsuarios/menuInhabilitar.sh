#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox \
    "\n\
    1.-Inhabilitar por lista:\n\
    Permite inhabilitar un usuario por un tiempo determinado.\n\n\
    2.-Inhabilitar por nombre:\n\
    Permite inhabilitar un usuario especificando su nombre.\n\n\
    3.-Habilitar:\n\
    Permite habilitar un usuario que ha sido inhabilitado.\n\n" 0 0
}

# Define las opciones del menú
options=(
    1 "Inhabilitar por lista"
    2 "Inhabilitar por nombre"
    3 "Habilitar"
)

# Limpia la pantalla
clear

# Imprime el menú usando dialog
while true; do
    # Muestra el menú y cambia el valor de la variable $option
    # --ok-label = 0
    # --cancel-label = 1
    # --help-button --help-label = 2
    # --extra-button --extra-label = 3
    option=$(dialog --cursor-off-label --colors --clear --title "INHABILITACIÓN DE USUARIOS" \
        --cancel-label "Cancelar" --ok-label "Seleccionar" \
        --help-button --help-label "Ayuda" \
        --menu "Seleccione una opción:" 0 0 0 "${options[@]}" \
        --output-fd 1)

    dialog_exit_code=$?

    # Verificar si el usuario seleccionó el botón de ayuda
    if [[ "$dialog_exit_code" -eq 2 ]]; then
        mostrar_ayuda
        continue
    fi

    # Verificar si el usuario seleccionó cancelar
    if [[ "$dialog_exit_code" -eq 1 ]]; then
        break
    fi

    # Manejar la opción seleccionada
    case $option in
    1)
        # Se cuenta el numero de usuarios
        numeroUsuarios=$(grep -v "!" /etc/shadow | wc -l)
        # Se crea un archivo con los usuarios 
        for ((i = 1; i <= $numeroUsuarios; i++)); do
            echo -n "$i " >>tmp/usuarios.tmp
            grep -v "!" /etc/shadow | cut -d: -f1 | sort | awk -v i="$i" 'NR == i { printf "\"%s\"\n", $0 }' >>tmp/usuarios.tmp
        done
        # Se crea el Custom
        scriptInicio=$(grep -n "# INICIO OPTIONS" inhabilitacionUsuarios/inhabilitarPlantilla.sh | cut -d ':' -f 1)
        scriptFin=$(grep -n "# FIN OPTIONS" inhabilitacionUsuarios/inhabilitarPlantilla.sh | cut -d ':' -f 1)
        head -$((scriptInicio-1)) inhabilitacionUsuarios/inhabilitarPlantilla.sh >tmp/inhabilitarCustom.sh
        cat tmp/usuarios.tmp >>tmp/inhabilitarCustom.sh
        tail -n +$((scriptFin+1)) inhabilitacionUsuarios/inhabilitarPlantilla.sh >>tmp/inhabilitarCustom.sh
        (source "tmp/inhabilitarCustom.sh")
        rm -f tmp/usuarios.tmp
        rm -f tmp/inhabilitarCustom.sh
        ;;
    2)
        (source "inhabilitacionUsuarios/inhabilitarNombre.sh")
        ;;
    3)
        (source "tmp/habilitarCustom.sh")
        ;;
    *)
        dialog --colors --title "\Z1ERROR" --msgbox "Opción inválida" 0 0
        ;;
    esac

    # Limpia la pantalla
    clear
done

# Sale del script
clear

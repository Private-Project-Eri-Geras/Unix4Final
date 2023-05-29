#!/usr/bin/env bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox "aqui esta la ayuda" 0 0
    #        --msgbox "\nALTA MASIVA\nAquí se describe el formato del archivo .csv para dar de alta usuarios de forma masiva:\n\nLas líneas que empiezan con # serán ignoradas.\n\nEl único campo obligatorio es el nombre; todos los demás pueden estar vacíos.\nLa contraseña puede ser cualquier valor.\n\nEl UID debe ser numérico y debe ser 100 o mayor. Lo mismo se aplica a la GID; si no se cumple esta condición, los usuarios no serán agregados.\n\nLos campos 'crear_home' y 'directorio_home' deben trabajarse juntos:\n\n- Si se desea crear un directorio home para el usuario, debe indicarse de forma afirmativa en el campo 'crear_home', usando los valores 'Y', 'S', 's', 'yes' o 'Yes'.\n\n- Para no crear un directorio home, simplemente no se debe ingresar ningún valor o nada relacionado con la confirmación.\n\nEn caso de no crear un directorio home, el campo 'directorio_home' será ignorado.\n\nSi se desea especificar un directorio home personalizado, se debe proporcionar la ruta absoluta. El directorio home puede o no existir previamente.\n\nLa fecha de expiración y el aviso de expiración deben estar en formato YYYY-MM-DD y deben ser fechas válidas. De lo contrario, no se asignarán.\n\nEl aviso de expiración representa la cantidad de tiempo previo a la expiración en la que se enviará una advertencia al usuario.\n" 0 0 0 \
}

# Verificar si el script se ejecuta con sudo
if [ -z "$SUDO_USER" ]; then
    dialog --colors --title "\Z1ERROR" --msgbox "Este script debe ser ejecutado con sudo" 0 0
    clear
    # exit 1
fi

# Define las opciones del menú
options=(
    1 "Alta por archivo de texto"
    2 "Alta manual"
    3 "Baja por archivo de texto"
    4 "Baja manual"
    5 "Cambio de contraseña por archivo de texto"
    6 "Cambio de contraseña manual"
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
    option=$(dialog --cursor-off-label --colors --clear --title "ADMINISTRACION DE USUARIOS" \
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
        (source "usuarios/altas/masiva.sh")
        ;;
    2)
        # TODO: alta manual
        echo "alta manual"
        echo "Presiona enter para continuar"
        read -sn 1
        ;;
    3)
        (source "usuarios/bajas/masiva.sh")
        ;;
    4)
        # TODO: baja manual
        (source "usuarios/bajas/manual.sh")
        ;;
    5)
        # TODO: cambio de contraseña por archivo de texto
        echo "cambio de contraseña por archivo de texto"
        echo "Presiona enter para continuar"
        read -sn 1
        ;;
    6)
        # TODO: cambio de contraseña manual
        echo "cambio de contraseña manual"
        echo "Presiona enter para continuar"
        read -sn 1
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

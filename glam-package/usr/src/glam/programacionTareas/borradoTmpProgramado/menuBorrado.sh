#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox \
        "\n\
    1.-Borrado total:\n\
    Permite borrar todo el contenido de la carpeta /tmp.\n\n\
    2.-Eliminar programación total:\n\
    Permite eliminar la programación de borrado total.\n\n\
    3.-Borrado selectivo:\n\
    Permite borrar archivos o directorios específicos de la carpeta /tmp.\n\n\
    4.-Eliminar programación selectivo:\n\
    Permite eliminar la programación de borrado selectivo.\n\n" 0 0
}

# Define las opciones del menú
options=(
    1 "\Z2\ZbProgramacion\Zn de borrado de temporales"
    2 "\Z1\ZbEliminar\Zn programaciones de temporales"
    3 "\Z2\ZbProgramacion\Zn selectiva de borrado de temporales"
    4 "\Z1\ZbEliminar\Zn programaciones de temporales selectivo"
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
    option=$(dialog --cursor-off-label --colors --clear --title "BORRADO TMP PROGRAMADO" \
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
        (source /usr/src/glam/programacionTareas/borradoTmpProgramado/borradoTotal.sh)
        ;;
    2)
        (source /usr/src/glam/programacionTareas/borradoTmpProgramado/borrar/eliminarTotal.sh)
        ;;
    3)
        (source /usr/src/glam/programacionTareas/borradoTmpProgramado/selectivo/borradoSelectivo.sh)
        ;;
    4)
        (source /usr/src/glam/programacionTareas/borradoTmpProgramado/borrarSelectivo/eliminarSelectivo.sh)
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

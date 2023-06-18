#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox \
        "\n\
    Use Espacio para seleccionar los respaldos y pulse OK cuando haya terminado" 0 0
}

# Limpia la pantalla
clear

# Imprime el menú usando dialog
while true; do
    OPTIONS=$(dialog --no-tags --separate-output --clear --title "Selección de Respaldos" \
        --checklist "Use Espacio para seleccionar los respaldos y pulse OK cuando haya terminado." 0 0 0 \
        # INICIO RESPALDOS
        # FIN RESPALDOS
        2>&1 >/dev/tty)
    echo $OPTIONS >tmp/oneline.tmp
    # tmp/oneline.tmp contiene los indices de los respaldos a borrar separados por espacios
    # Se crea un archivo llamado tmp/newline.tmp que contiene los indices de los respaldos a borrar separados por saltos de linea
    awk '{for (i=1; i<=NF; i++) print $i}' tmp/oneline.tmp >tmp/newline.tmp
    rm -f tmp/oneline.tmp

    break
    clear
done

# Sale del script
clear

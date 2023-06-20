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
    echo $OPTIONS >/tmp/oneline.tmp

    # /tmp/oneline.tmp contiene los indices de los respaldos a borrar separados por espacios
    # Se crea un archivo llamado /tmp/newline.tmp que contiene los indices de los respaldos a borrar separados por saltos de linea
    awk '{for (i=1; i<=NF; i++) print $i}' /tmp/oneline.tmp >/tmp/newline.tmp
    rm -f /tmp/oneline.tmp
    eliminaciones=$(cat /tmp/newline.tmp | wc -l)

    # Verifica si se seleccionaron respaldos
    if [ $eliminaciones -eq 0 ]; then
        clear
        rm -f /tmp/list.tmp
        exit 1
    fi

    # Pregrunta si se quiere eliminar los respaldos seleccionados
    dialog --title "Confirmación" --yesno "¿Está seguro que desea eliminar $eliminaciones respaldos?" 0 0
    if [ $? -eq 1 ]; then
        clear
        rm -f /tmp/newline.tmp
        rm -f /tmp/list.tmp
        exit 1
    fi

    for ((i = eliminaciones; i >= 1; i--)); do
        # Con sed se elimina la linea i de tmp/list.tmp
        sed -i "$(sed </tmp/newline.tmp -n ${i}p)d" /tmp/list.tmp
    done
    rm -f /tmp/newline.tmp

    # re escribir crontab
    head -$((numeroInicio)) /etc/crontab >/tmp/crontab
    cat /tmp/list.tmp >>/tmp/crontab
    tail -n +$((numeroFin)) /etc/crontab >>/tmp/crontab
    rm -f /tmp/list.tmp
    mv /tmp/crontab /etc/crontab
    break
    clear
done

# Sale del script
clear

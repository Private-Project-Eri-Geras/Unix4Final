#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox \
        "\n\
    Use Espacio para seleccionar las tareas y pulse OK cuando haya terminado" 0 0
}

# Limpia la pantalla
clear

# Imprime el menú usando dialog
while true; do
    OPTIONS=$(dialog --no-tags --separate-output --clear --title "Selección de Respaldos" \
            --checklist "Use Espacio para seleccionar las tareas y pulse OK cuando haya terminado." 0 0 0
        # INICIO TAREAS
        # FIN TAREAS
        2>&1 >/dev/tty)
    echo $OPTIONS >/tmp/oneline.tmp
    read -p "Presione enter para continuar"

    # /tmp/oneline.tmp contiene los indices de las tareas a borrar separados por espacios
    # Se crea un archivo llamado /tmp/newline.tmp que contiene los indices de las tareas a borrar separados por saltos de linea
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
    dialog --title "Confirmación" --yesno "¿Está seguro que desea eliminar $eliminaciones tareas?" 0 0
    if [ $? -eq 1 ]; then
        clear
        rm -f /tmp/newline.tmp
        rm -f /tmp/list.tmp
        exit 1
    fi

    for ((i=eliminaciones; i>=1; i--)); do
        # Con sed se elimina la linea i de tmp/list.tmp
        sed -i "$(sed </tmp/newline.tmp -n ${i}p)d" /tmp/list.tmp
    done
    read -p "Presione enter para continuar"
    rm -f /tmp/newline.tmp

    # re escribir crontab
    head -$((numeroInicio)) /etc/crontab >/tmp/crontab
    read -p "Presione enter para continuar"
    cat /tmp/list.tmp >>/tmp/crontab
    read -p "Presione enter para continuar"
    tail -n +$((numeroFin)) /etc/crontab >>/tmp/crontab
    read -p "Presione enter para continuar"
    read -p "Presione enter para continuar"
    read -p "Presione enter para continuar"
    read -p "Presione enter para continuar"
    read -p "Presione enter para continuar"
    rm -f /tmp/list.tmp
    mv /tmp/crontab /etc/crontab
    break
    clear
done

# Sale del script
clear

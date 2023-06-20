#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox \
        "\n\
    Use Espacio para seleccionar los scripts y pulse OK cuando haya terminado" 0 0
}

# Limpia la pantalla
clear

# Obtiene los indices de los respaldos
numeroInicio=$(grep -n "# INICIO PROGRAMACION MANUAL" /etc/crontab | cut -d ':' -f 1)
numeroFin=$(grep -n "# FIN PROGRAMACION MANUAL" /etc/crontab | cut -d ':' -f 1)
numeroTareas=$(($numeroFin - $numeroInicio - 1))
scriptInicio=$(grep -n "# INICIO TAREAS" /usr/src/glam/programacionTareas/programacionManual/borrar/borrarTareaPlantilla.sh | cut -d ':' -f 1)
scriptFin=$(grep -n "# FIN TAREAS" /usr/src/glam/programacionTareas/programacionManual/borrar/borrarTareaPlantilla.sh | cut -d ':' -f 1)

# Verifica si existen respaldos
if ((numeroTareas == 0)); then
    dialog --colors --title "\Z1ERROR" --msgbox "No existen tareas programadas" 0 0
    clear
    exit 1
fi

# Agregar los respaldos al script custom
head -$((scriptInicio-1)) /usr/src/glam/programacionTareas/programacionManual/borrar/borrarTareaPlantilla.sh >/tmp/borrarTareaCustom.sh
tail -n +$((numeroInicio+1)) /etc/crontab | head -$numeroTareas >>/tmp/list.tmp
#crear un archivo nuevo con el formato figuiente:
# 1 "/tmp/list.tmp linea 1" off \
# 2 "/tmp/list.tmp linea 2" off \
# 3 "/tmp/list.tmp linea 3" off \

for ((i=1; i<=$numeroTareas; i++)); do
    echo -n "$i " >>/tmp/lista.tmp
    awk -v i="$i" 'NR == i { printf "\"%s\"", $0 }' /tmp/list.tmp >> /tmp/lista.tmp
    echo -n " off \\" >>/tmp/lista.tmp
    echo "" >>/tmp/lista.tmp
done
cat /tmp/lista.tmp >>/tmp/borrarTareaCustom.sh
rm -f /tmp/lista.tmp
tail -n +$((scriptFin+1)) /usr/src/glam/programacionTareas/programacionManual/borrar/borrarTareaPlantilla.sh >>/tmp/borrarTareaCustom.sh
(source /tmp/borrarTareaCustom.sh)
rm -f /tmp/borrarTareaCustom.sh

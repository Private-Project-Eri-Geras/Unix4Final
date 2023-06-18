#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox \
        "\n\
    Use Espacio para seleccionar los respaldos y pulse OK cuando haya terminado" 0 0
}

# Limpia la pantalla
clear

# Obtiene los indices de los respaldos
numeroInicio=$(grep -n "# INICIO PROGRAMACION DE TAREAS" /etc/crontab | cut -d ':' -f 1)
numeroFin=$(grep -n "# FIN PROGRAMACION DE TAREAS" /etc/crontab | cut -d ':' -f 1)
numeroRespaldos=$(($numeroFin - $numeroInicio - 1))
scriptInicio=$(grep -n "# INICIO RESPALDOS" respaldoProgramado/borrar/borrarRespaldoPlantilla.sh | cut -d ':' -f 1)
scriptFin=$(grep -n "# FIN RESPALDOS" respaldoProgramado/borrar/borrarRespaldoPlantilla.sh | cut -d ':' -f 1)

# Verifica si existen respaldos
if ((numeroRespaldos == 0)); then
    dialog --colors --title "\Z1ERROR" --msgbox "No existen respaldos programados" 0 0
    clear
    exit 1
fi

# Agregar los respaldos al script custom
head -$((scriptInicio-1)) respaldoProgramado/borrar/borrarRespaldoPlantilla.sh >respaldoProgramado/borrar/borrarRespaldoCustom.sh
tail -n +$((numeroInicio+1)) /etc/crontab | head -$numeroRespaldos >>tmp/list.tmp
#crear un archivo nuevo con el formato figuiente:
# 1 "tmp/list.tmp linea 1" off \
# 2 "tmp/list.tmp linea 2" off \
# 3 "tmp/list.tmp linea 3" off \
for ((i=1; i<=$numeroRespaldos; i++)); do
    echo -n "$i " >>tmp/lista.tmp
    awk -v i="$i" 'NR == i { printf "\"%s\"", $0 }' tmp/list.tmp >> tmp/lista.tmp
    echo -n " off \\" >>tmp/lista.tmp
    echo "" >>tmp/lista.tmp
done
cat tmp/lista.tmp >>respaldoProgramado/borrar/borrarRespaldoCustom.sh
rm -f tmp/lista.tmp
tail -n +$((scriptFin+1)) respaldoProgramado/borrar/borrarRespaldoPlantilla.sh >>respaldoProgramado/borrar/borrarRespaldoCustom.sh
(source respaldoProgramado/borrar/borrarRespaldoCustom.sh)

#!/bin/bash

# Función para mostrar la ventana de ayuda
mostrar_ayuda() {
    dialog --title "Help" --msgbox \
        "\n\
    Use Espacio para seleccionar los respaldos y pulse OK cuando haya terminado" 0 0
}

# Limpia la pantallanumeroInicio
clear
ruta="/usr/src/glam/programacionTareas/borradoTmpProgramado/borrarSelectivo/eliminarSelectivoPlantilla.sh" # blame eri
# Obtiene los indices de los respaldos
numeroInicioSelectivo=$(grep -n "# INICIO TMP SELECTIVO" /etc/crontab | cut -d ':' -f 1)
numeroFinSelectivo=$(grep -n "# FIN TMP SELECTIVO" /etc/crontab | cut -d ':' -f 1)
numeroEliminaciones=$(($numeroFinSelectivo - $numeroInicioSelectivo - 1))
scriptInicio=$(grep -n "# INICIO TMP SELECTIVO" "$ruta" | cut -d ':' -f 1)
scriptFin=$(grep -n "# FIN TMP SELECTIVO" "$ruta" | cut -d ':' -f 1)

# Verifica si existen respaldos
if ((numeroEliminaciones == 0)); then
    dialog --colors --title "\Z1ERROR" --msgbox "No existen respaldos programados" 0 0
    clear
    exit 1
fi

# Agregar los respaldos al script custom
head -$((scriptInicio - 1)) "$ruta" >/tmp/eliminarTotalCustom.sh
tail -n +$((numeroInicioSelectivo + 1)) /etc/crontab | head -$numeroEliminaciones >>/tmp/list.tmp
#crear un archivo nuevo con el formato figuiente:
# 1 "/tmp/list.tmp linea 1" off \
# 2 "/tmp/list.tmp linea 2" off \
# 3 "/tmp/list.tmp linea 3" off \
for ((i = 1; i <= $numeroEliminaciones; i++)); do
    echo -n "$i " >>/tmp/lista.tmp
    awk -v i="$i" 'NR == i { printf "\"%s\"", $0 }' /tmp/list.tmp >>/tmp/lista.tmp
    echo -n " off \\" >>/tmp/lista.tmp
    echo "" >>/tmp/lista.tmp
done
cat /tmp/lista.tmp >>/tmp/eliminarTotalCustom.sh
rm -f /tmp/lista.tmp
tail -n +$((scriptFin + 1)) "$ruta" >>/tmp/eliminarTotalCustom.sh
(source /tmp/eliminarTotalCustom.sh)
rm -f /tmp/eliminarTotalCustom.sh

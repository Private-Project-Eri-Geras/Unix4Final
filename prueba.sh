#!/bin/bash

# Función que se ejecuta al presionar Enter
function accion_enter() {
    # Realiza la acción que deseas al presionar Enter
    echo "Presionaste Enter"
    exit 0  # Sale del script
}

# Muestra el cuadro de texto

dialog --title "Cuadro de Texto" --textbox archivo.txt 0 0 \
    --and-widget --ok-label "Enter" --textbox-cb "accion_enter"

# Limpia la pantalla después de cerrar el cuadro de texto
clear
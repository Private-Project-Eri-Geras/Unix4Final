#!/bin/bash

if [ -z "$SUDO_USER" ]; then
    dialog --colors --title "\Z1ERROR" --msgbox "Este script debe ser ejecutado con sudo" 0 0
    clear
    return
fi
echo "entro"
seleep 5
# Obtener los nombres de los discos disponibles
disk_list=$(lsblk -d -n -o NAME)

# Crear una matriz para almacenar los nombres de los discos
disks=()
while IFS= read -r disk; do
    disks+=("$disk")
done <<< "$disk_list"

# Mostrar el diálogo para que el usuario seleccione el disco
selected_disk=$(dialog --clear --title "Seleccionar disco" --menu "Seleccione el disco para crear una partición:" 0 0 0 "${disks[@]}" 2>&1 >/dev/tty)

# Verificar si se seleccionó un disco
if [[ -n "$selected_disk" ]]; then
    echo "El disco seleccionado es: $selected_disk"
    # Aquí puedes agregar el código para crear la partición en el disco seleccionado
else
    echo "No se seleccionó ningún disco."
fi
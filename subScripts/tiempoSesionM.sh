#!/bin/bash

# Obtener todos los usuarios registrados en el sistema (excluyendo los usuarios del sistema)
usuarios=$(grep -E '^[^:]+:[^:]*:[0-9]{4}:[0-9]{4}' /etc/passwd | cut -d: -f1)

# Verificar si no hay usuarios creados
if [ -z "$usuarios" ]; then
  echo "No se encontraron usuarios creados en el sistema."
  exit 1
fi

# Convertir los usuarios en un arreglo
usuarios_array=($usuarios)

# Crear un arreglo de opciones para el menú
opciones=()
for usuario in "${usuarios_array[@]}"; do
  opciones+=("$usuario" "")
done

#Consiguiendo el tiempo de sesión de cada usuario




# Mostrar el menú y guardar la opción seleccionada
opcion=$(dialog --title "Menú de Usuarios" --menu "Seleccione un usuario:" 0 0 0 "${opciones[@]}" 2>&1 >/dev/tty)

# Verificar la opción seleccionada y realizar la acción correspondiente
case $opcion in
  "${usuarios_array[0]}")
    echo "Seleccionaste el usuario ${usuarios_array[0]}"
    # Realiza la acción deseada para el primer usuario
    ;;
  "${usuarios_array[1]}")
    echo "Seleccionaste el usuario ${usuarios_array[1]}"
    # Realiza la acción deseada para el segundo usuario
    ;;
  # Agrega más casos para cada usuario adicional si es necesario
  *)
    echo "Opción inválida"
    ;;
esac
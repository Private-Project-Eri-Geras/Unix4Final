#!/bin/bash

password=$(dialog --insecure --passwordbox "Ingrese su contraseña:" 10 30 2>&1 >/dev/tty)

echo "La contraseña ingresada es: $password"
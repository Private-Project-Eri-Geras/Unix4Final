#!/bin/bash

# verificar que lo haya corrido con sudo
if [[ -z "$SUDO_USER" ]]; then
    echo "Por favor correr con sudo."
    exit 1
fi

#cambiar el propietario de los archivos
chown -R root:root glam-package

# cambiar los permisos de los archivos
chmod -R 755 glam-package

dpkg-deb --build glam-package

# regresar los permisos de los archivos
chmod -R 777 glam-package

dpkg -i glam-package.deb
glam
rm -rf glam-package.deb
dpkg -r glam

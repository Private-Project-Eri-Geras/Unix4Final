#!/bin/bash

#cambiar el propietario de los archivos
chown -R root:root glam-package

# cambiar los permisos de los archivos
chmod -R 755 glam-package

# copiar los archivos fuentes a la carpeta root
cp -r glam-package/usr/src/glam /usr/src/glam

# si existe /var/glam, eliminarlo
if [ -d "/var/glam" ]; then
    rm -rf /var/glam
fi

# copiar glam-package/var/glam a /var/glam
cp -r glam-package/var/glam /var/glam

# copiar el comando glam a /usr/bin y /usr/local/bin
cp glam-package/usr/bin/glam /usr/bin/glam
cp glam-package/usr/bin/glam /usr/local/bin/glam
cp glam-package/var/glam /var/glam/

# ejecutar el comando glam
glam

# eliminar todo lo creado en raiz menos los los temporales /var/glam
rm -rf /usr/src/glam
rm /usr/bin/glam
rm /usr/local/bin/glam

# mover los temporales de /var/glam a glam-package/var/
rm -rf glam-package/var/*
mv /var/glam glam-package/var/

# regresar los permisos de los archivos
chmod -R 777 glam-package

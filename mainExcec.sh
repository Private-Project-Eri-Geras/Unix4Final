#!/bin/bash

#cambiar el propietario de los archivos
chown -R root:root glam-package

# cambiar los permisos de los archivos
chmod -R 755 glam-package

# copiar los archivos fuentes a la carpeta root
cp -r glam-package/usr/src/glam /usr/src/glam

# crear las carpetas /var/glam
mkdir -p /var/glam
mkdir -p /var/glam/backup
mkdir -p /var/glam/logs
mkdir -p /var/glam/tmp

# eliminar todo lo que este dentro de /var/glam/backup , /var/glam/tmp y /var/glam/logs
if [ $(ls /var/glam/backup) ]; then
    rm -rf /var/glam/backup/*
fi
if [ $(ls /var/glam/logs) ]; then
    rm -rf /var/glam/logs/*
fi
if [ $(ls /var/glam/tmp) ]; then
    rm -rf /var/glam/tmp/*
fi

# copiar el comando glam a /usr/bin y /usr/local/bin
cp glam-package/usr/bin/glam /usr/bin/glam
cp glam-package/usr/bin/glam /usr/local/bin/glam

# ejecutar el comando glam
glam

# eliminar todo lo creado en raiz menos los los temporales /var/glam
rm -rf /usr/src/glam
rm /usr/bin/glam
rm /usr/local/bin/glam

# mover los temporales de /var/glam a glam-package/usr/var/glam
mv /var/glam glam-package/var

# regresar los permisos de los archivos
chmod -R 777 glam-package

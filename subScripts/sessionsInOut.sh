#!/bin/bash
#Ruta del archivo que guarda los inicios y terminos de sesion
new=/tmp/wwho1$$.txt
old=/tmp/wwho2$$.txt
diferencia=/tmp/diff$$.txt
#Guardando la lista de usuarios conectados
who>$old

#Detección de inicios y terminos de sesion
while test 1 == 1
do
  who>$new
  diff $old $new > $diferencia
  cat $diferencia | awk  '/>/ { print "in:   " $0 ; }' 
  cat $diferencia | awk  '/</ { print "out:  " $0 ; }'
  mv $new $old
  sleep 10
done


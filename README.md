> regresar permisos (la cagatis wey)  
> chmod -R 777 glam-package

> para explorar todo lo que esta dentro de el glam-package  
> find glam-package -type f -exec ls -l {} +  
  
> para explorar convertir todo con dos2unix  
> find glam-package -type f -exec dos2unix {} \\;
# Estructura del código:
archivos fuentes:  
╚`/usr/src/glam`  
  ╠`main.sh`  
  ╚`subMenu/`  
    ╠`manejoUsuarios/`  
    ║  ╠`scriptMenu.sh`  
    ║  ╚`subscripts/..`  
    ╠`programacionTareas/`  
    ║  ╠`scriptMenu.sh`  
    ║  ╚`subscripts/..`  
    ╠`mantenimiento/`  
    ║  ╠`menumantenimiento.sh`  
    ║  ╚`subscripts/..`  
    ╚`tareasUsuarios/`  
        ╠`scriptMenu.sh`  
        ╚`subscripts/..`  
 
---
Otros archivos:  
╚`/var/glam`  
  ╠`logs/`   
  ║  ╚`logs..`  
  ╠`backups/`    
  ║  ╚`mount/`   
  ╚`tmp/`  
  `por definir más`

---
comando:  
`/usr/bin/glam`  
el comando sera global, permitira llamar al main del archivo fuente  
`/usr/src/glam/main.sh`

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

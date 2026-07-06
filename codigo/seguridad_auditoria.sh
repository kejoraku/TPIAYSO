#!/bin/bash

# Script de configuración de seguridad y auditoría
# Uso: sudo bash seguridad_auditoria.sh

set -e

# Validar permisos de root
if [ "$EUID" -ne 0 ]; then
   echo "ERROR: Este script debe ejecutarse con sudo"
   echo "Uso: sudo bash $0"
   exit 1
fi

# Crear directorio y archivo protegido
mkdir -p /seguro
touch /seguro/datos.txt
chown root:root /seguro/datos.txt
chmod 600 /seguro/datos.txt

echo "Archivo protegido creado en /seguro/datos.txt"

echo "Configurando usuarios de prueba..."
for user in usuario1 usuario2; do
    if id "$user" >/dev/null 2>&1; then
        echo "Usuario $user ya existe"
    else
        useradd -m "$user"
        echo "$user:usuario123" | chpasswd
        echo "Usuario $user creado con contraseña: usuario123"
    fi
done

# Configura auditoría para el archivo protegido
auditctl -w /seguro/datos.txt -p rwxa -k acceso_datos

echo "Regla de auditoría aplicada para /seguro/datos.txt"

echo "Listado de reglas de auditoría actuales:"
auditctl -l

echo "
Para probar el acceso no autorizado, ejecute:
  sudo -u usuario1 cat /seguro/datos.txt
  sudo -u usuario2 echo 'Prueba' >> /seguro/datos.txt

Para revisar los registros de auditoría, ejecute:
  sudo ausearch -k acceso_datos
"

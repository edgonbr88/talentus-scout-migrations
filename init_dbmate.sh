#!/bin/sh
set -e

echo "========================================================"
echo "[dbmate] Iniciando sincronización de base de datos..."
echo "[dbmate] Target: $DATABASE_URL"
echo "========================================================"

# Esperar activamente a que PostgreSQL acepte conexiones
until dbmate --migrations-dir /db/migrations status > /dev/null 2>&1; do
  echo "[dbmate] Esperando a que PostgreSQL acepte conexiones..."
  sleep 1
done

echo "[dbmate] PostgreSQL está listo."

# Verificar si hay archivos .sql en el directorio
if ls /db/migrations/*.sql 1> /dev/null 2>&1; then
  echo "[dbmate] Aplicando migraciones pendientes..."
  dbmate --migrations-dir /db/migrations up
  echo "[dbmate] Migraciones aplicadas con éxito."
else
  echo "[dbmate] Directorio de migraciones listo. No hay archivos .sql aún."
fi

echo "========================================================"

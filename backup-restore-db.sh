#!/bin/bash
# SCRIPT PUBLICO

# Instalar mysql-client
# sudo apt-get install mysql-client

# Cargar variables desde el archivo .env
source .env

# Obtener la fecha y hora actual
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Nombre del archivo de respaldo
BACKUP_FILE="backup_$TIMESTAMP.sql"


# Generar respaldo de la primera base de datos
mysqldump -u $DB_ORIGIN_USER -p $DB_ORIGIN_PASSWORD -h $DB_ORIGIN_HOST -P $DB_ORIGIN_PORT $DB_ORIGIN_NAME > $BACKUP_FILE

# Verificar si el respaldo se hizo correctamente
if [ $? -eq 0 ]; then
    echo "Respaldo de $DB_ORIGIN_NAME exitoso"
    
    # Eliminar la base de datos dve02 de la segunda base de datos
    mysql -u $DB_DESTINATION_USER -p $DB_DESTINATION_PASSWORD -h $DB_DESTINATION_HOST -P $DB_DESTINATION_PORT -e "DROP DATABASE IF EXISTS $DB_DESTINATION_NAME" mysql

    mysql -u $DB_DESTINATION_USER -p $DB_DESTINATION_PASSWORD -h $DB_DESTINATION_HOST -P $DB_DESTINATION_PORT -e "CREATE DATABASE  $DB_DESTINATION_NAME" mysql
    
    # Restaurar el respaldo en la segunda base de datos
    mysql --u $DB_DESTINATION_USER -p $DB_DESTINATION_PASSWORD -h $DB_DESTINATION_HOST -P $DB_DESTINATION_PORT $DB_DESTINATION_NAME < $BACKUP_FILE
    
    echo "Respaldo restaurado en $DB_DESTINATION_NAME"
else
    echo "Error al hacer el respaldo de $DB_ORIGIN_NAME"
fi

# Limpiar el respaldo
rm $BACKUP_FILE

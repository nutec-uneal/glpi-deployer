#!/bin/bash

if [[ -z $LOG_FILE ]]; then
    echo  "[$(date)] [ERROR] - Log file not defined."
    exit 1
fi

if [[ -z $CONTAINER_NAME ]]; then
    echo "[$(date)] [ERROR] - Container name not defined." >> $LOG_FILE
    exit 1
fi


status=$(docker ps --filter "status=running" | grep $CONTAINER_NAME)

if [[ -z $status ]]; then
    echo "[$(date)] [ERROR] - Container not running." >> $LOG_FILE
    exit 1
fi

result=$(docker exec -it $CONTAINER_NAME php /var/www/html/front/cron.php)

if [[ -z $result ]]; then
    echo "[$(date)] [OK] - Successfully executed." >> $LOG_FILE
    exit 0
fi

echo "[$(date)] [ERROR] - Command execution error, $result" >> $LOG_FILE
exit 1
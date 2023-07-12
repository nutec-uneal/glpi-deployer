#!/bin/bash


if [[ -z $CONTAINER_NAME ]]; then
    echo "[$(date)] [ERROR] - Container name not defined." >&2
    
    exit 1
fi

status=$(docker ps --filter "status=running" | grep $CONTAINER_NAME)

if [[ -z $status ]]; then
    echo "[$(date)] [ERROR] - Container not running." >&2
    
    exit 1
fi

result=$(docker exec -it $CONTAINER_NAME php /var/www/html/front/cron.php)

if [[ ! -z $result ]]; then
    echo "[$(date)] [ERROR] - Command execution error, $result" >&2
    
    exit 1
fi

echo "[$(date)] [OK] - Successfully executed."

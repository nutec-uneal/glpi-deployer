#!/bin/bash


if [[ -z $CONTAINER_NAME ]]; then
    echo "[$(date)] [ERROR] - Container name not defined." >&2
    
    exit 1
fi

containers=($(docker ps --filter "status=running" 2> /dev/null | grep -Po "$CONTAINER_NAME\$" | tr "\n" " "))

if [[ ${#containers[@]} -le 0 ]]; then
    echo "[$(date)] [ERROR] - Container(s) not running. No match for '$CONTAINER_NAME'" >&2
    
    exit 1
fi

log_realtime=
failure_counter=0


exec_command() {
    result=$(docker exec -i $actual_container php /var/www/html/front/cron.php 2>&1)
    
    if [[ ! -z $result ]]; then
        ((failure_counter++))
        log_realtime+=$(echo "'Command execution error in $actual_container, $result',")
    fi
}


containers_array_size=${#containers[@]}

if [[ ! -z $FIRST_MODE_ON ]]; then
    actual_container=${containers[0]}
    containers_array_size=1
    exec_command
else
    for name in ${containers[@]}; do
        actual_container=$name
        exec_command
    done
fi

if [[ $containers_array_size -eq $failure_counter ]]; then
    echo "[$(date)] [ERROR] - [ $log_realtime ]" >&2
    
    exit 1
fi

echo "[$(date)] [OK] - Successfully executed. Details: [ $log_realtime ]"

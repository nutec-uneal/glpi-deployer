#!/bin/bash

# Container name, or regex.
export CONTAINER_NAME=glpitest-stack_app\.[A-Za-z0-9.]*

# FIRST_MODE_ON: if defined, run the command only on the first container found.
export FIRST_MODE_ON=

# Script exec
./glpi-job-docker.sh

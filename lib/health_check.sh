#!/bin/bash

PORTS=(8080 54321 5264)
HOST="127.0.0.1"
#SHUTDOWN_CMD="shutdown -h now"
SHUTDOWN_CMD="echo $(date); echo '!!! Shutting Down'"

# Function to check a single port
check_port() {
    local port=$1
    nc -z -w5 $HOST $port
    return $?
}

# Check all ports
for port in "${PORTS[@]}"; do
    if ! check_port $port; then
        echo "Port $port is closed or unreachable."
        echo "Shutting down the server..."
        $SHUTDOWN_CMD
        exit 1
    else
        echo "Port $port is open."
    fi
done
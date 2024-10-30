#!/bin/bash

check_port() {
    local port=$1
    nc -z -w5 127.0.0.1 $port
    return $?
}

if ! check_port $mtg_port; then
    echo "Port $mtg_port is closed or unreachable. Restarting mtg service..."
    systemctl restart mtg
fi

if ! check_port $xui_port || ! check_port $xray_port; then
    echo "One of the xui or xray ports is closed or unreachable. Restarting xui service..."
    systemctl restart x-ui
fi

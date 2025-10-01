#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting WireGuard VPN ---"

# Start the WireGuard interface wg0 using the provided surfshark.conf
# The `&` runs this in the background, but wg-quick manages the process.
wg-quick up wg0

echo "VPN interface is up. Waiting for connection to establish..."

# --- Health Check for VPN Connection ---
# We will try to curl an IP-checking service. If it fails or shows the wrong IP,
# we'll know the VPN isn't working. We'll try a few times.

SUCCESS=false
for i in {1..10}; do
    # Use a reliable IP echo service
    VPN_IP=$(curl -s --interface wg0 https://ipinfo.io/ip || echo "error")
    echo "Attempt $i: Current external IP through VPN is: $VPN_IP"

    if [[ "$VPN_IP" != "error" && -n "$VPN_IP" ]]; then
        echo "--- VPN connection successful! External IP: $VPN_IP ---"
        SUCCESS=true
        break
    fi
    sleep 3
done

if [ "$SUCCESS" = false ]; then
    echo "--- VPN connection failed after several attempts. Exiting. ---"
    wg-quick down wg0
    exit 1
fi

echo "--- Starting Nginx reverse proxy ---"
# Start Nginx in the foreground to keep the container running
# and to pipe logs to Docker's log collector.
nginx -g 'daemon off;'
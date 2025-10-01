# Use Ubuntu 24.04 LTS as the base image
FROM ubuntu:24.04

# Set non-interactive frontend for package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary packages
# - wireguard-tools: For the WireGuard VPN connection
# - nginx: The reverse proxy server
# - curl: For testing the VPN connection
# - net-tools: For network diagnostics
RUN apt-get update && apt-get install -y \
    wireguard-tools \
    nginx \
    curl \
    net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the Nginx configuration file into the container
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the WireGuard configuration file.
# This file should be placed in the project directory before building.
COPY surfshark.conf /etc/wireguard/wg0.conf

# Copy the startup script and make it executable
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose the port Nginx will listen on
EXPOSE 3000

# Set the entrypoint to our startup script
CMD ["/start.sh"]
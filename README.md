# Gemini VPN Proxy

This project provides a self-contained Docker container that acts as a reverse proxy for the Google Gemini website (`gemini.google.com`). It routes all traffic through a Surfshark VPN connection using WireGuard, allowing users in geographically restricted regions (like Hong Kong) to access the full Gemini experience without needing a client-side VPN.

The container is fully automated: on startup, it establishes the VPN connection and then launches an Nginx reverse proxy.

## Features

- **VPN Integration**: Automatically connects to Surfshark using WireGuard for high performance and reliability.
- **Reverse Proxy**: Uses Nginx to forward requests from a custom domain to the official Gemini website (`gemini.google.com`).
- **Fully Automated**: A startup script ensures the VPN is connected *before* the proxy starts, guaranteeing all traffic is routed correctly.
- **Dockerized**: Single, lightweight container based on Ubuntu 24.04. Easy to deploy and manage with Docker Compose.
- **Secure**: VPN credentials are not hardcoded and are managed via a configuration file that should not be committed to version control.

---
## Disclaimer

> This project is for educational and personal use only. It is not affiliated with, endorsed by, or sponsored by Google or Surfshark.
>
> Users are solely responsible for ensuring that their use of this software complies with the terms of service of both Google Gemini and Surfshark. The developers of this >project assume no liability for any misuse or for any violations of third-party terms of service.

---

## Prerequisites
- A server or machine with Docker and Docker Compose installed (for the recommended method).
- A domain name.
- An active Surfshark VPN subscription.

---

## Usage

There are two ways to run this project. The recommended method is using Docker, which handles all dependencies automatically.

### Recommended Method: Using Docker

This is the easiest and most reliable way to run the proxy.

#### Step 1: Get Project Files

Clone the repository to your server and navigate into the project directory.

```bash
git clone https://github.com/alexlam0206/gemini-vpn-proxy.git
cd gemini-vpn-proxy
```

#### Step 2: Obtain Surfshark WireGuard Configuration

1.  Log in to your Surfshark account.
2.  Navigate to **VPN -> Manual setup -> Router -> WireGuard**.
3.  **Choose a location**: Select a server in a supported region (e.g., a US server).
4.  **Generate a key pair**: If you don't have one, generate a new key pair.
5.  **Download the configuration file**.
6.  Rename the downloaded file to `surfshark.conf` and place it in the project directory.

> **Security Warning**: The `surfshark.conf` file contains your private key. **Do not commit this file to a public Git repository.** Add `surfshark.conf` to your `.gitignore` file immediately.

#### Step 3: Configure DNS (OPTIONAL)

Go to your domain registrar's DNS management panel for your domain. Create an **A record** for the subdomain `gemini` and point it to the public IP address of the server where you are running this Docker container.

- **Type**: `A`
- **Name/Host**: `gemini`
- **Value/Points to**: `YOUR_SERVER_IP_ADDRESS`

#### Step 4: Build and Run the Container

With all the files in place (including `surfshark.conf`), open a terminal in the project directory and run:

```bash
docker compose up --build -d
```

- `--build`: Builds the Docker image from the `Dockerfile`.
- `-d`: Runs the container in detached mode (in the background).

---

### Alternative Method: Manual Installation

If you do not wish to use Docker, you can run the scripts directly on your host machine. This is not recommended as you will have to manage all dependencies yourself.

**1. Install Dependencies:**

You will need to install `wireguard-tools`, `nginx`, and `curl`. The commands vary depending on your operating system. If you are using WSL (Windows Subsystem for Linux), use the command for your Linux distribution.

**For Debian/Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install wireguard-tools nginx curl
```

**For Fedora/CentOS:**
```bash
sudo dnf install wireguard-tools nginx curl
```

**For Arch Linux:**
```bash
sudo pacman -S wireguard-tools nginx curl
```

**2. Configure and Run:**

Once the dependencies are installed, you will need to:
1.  Place your `surfshark.conf` file at `/etc/wireguard/wg0.conf`.
2.  Configure Nginx by copying the provided `nginx.conf` to `/etc/nginx/nginx.conf`.
3.  Run the `start.sh` script with administrator privileges (`sudo`).

```bash
sudo ./start.sh
```

This manual setup is more complex and prone to errors. The Docker method is strongly recommended.

---

## Verification

#### 1. Check Container Logs

See the startup process and ensure the VPN connected successfully.

```bash
docker logs gemini-proxy
```

You should see output indicating a successful VPN connection, followed by Nginx starting.

#### 2. Verify the VPN IP

Execute a command inside the running container to check its public IP address.

```bash
docker exec gemini-proxy curl https://ipinfo.io/ip
```

The IP address returned **must** be the Surfshark server's IP, not your host server's IP.

#### 3. Test the Proxy

You can now access the Gemini website through your new proxy endpoint. 

You should see the Gemini website, fully functional, served through your VPN-enabled proxy.

---

## Project Structure

- **`Dockerfile`**: Defines the container image, installing WireGuard, Nginx, and other tools.
- **`docker-compose.yml`**: Manages the container's runtime configuration, including network capabilities and port mapping (`3000:3000`).
- **`nginx.conf`**: Configures Nginx to listen on port 3000 and reverse proxy requests to `gemini.google.com`.
- **`start.sh`**: The entrypoint script that orchestrates the startup sequence: connect VPN, then start Nginx.
- **`surfshark.conf`**: Your personal WireGuard configuration file (you must provide this).



# Quick Start

Get your homelab running in less than 10 minutes.

## Step 1: Verify Prerequisites

### Check Docker
```bash
docker --version
# Must show v20.10+

docker compose version
# Must show v2.0+
```

If not installed: https://docs.docker.com/get-docker/

### Check System
```bash
# List IPs
hostname -I

# Check disk space
df -h /
# Need at least 20GB free
```

## Step 2: Clone Project

```bash
git clone <repository-url>
cd homelab
```

## Step 3: Initial Configuration

### 3a. Create .env file
```bash
cp .env.example .env
```

### 3b. Edit .env
```bash
nano .env
```

Fill in:
```bash
# Timezone (Paris, London, etc)
TZ=Europe/Paris

# Your machine's IP (from hostname -I)
SERVER_IP=192.168.1.100

# Optional admin port
ADMIN_PORT=9000
```

## Step 4: Create Data Directories

```bash
# AdGuard Home
mkdir -p services/adguard/adguard/{work,conf}

# Home Assistant
mkdir -p services/homeassistant/config

# Jellyfin
mkdir -p services/jellyfin/{config,cache,media,fonts}
```

## Step 5: Start First Service (AdGuard Home)

```bash
# Copy service configuration
cp services/adguard/.env.example services/adguard/.env

# Start the service
docker compose -f services/adguard/docker-compose.yaml up -d
```

### Verify it works
```bash
# View logs
docker compose -f services/adguard/docker-compose.yaml logs -f

# Check running containers
docker ps
```

If you see `adguardhome` with status `Up`, it works!

## Step 6: Access Web Interface

AdGuard Home should be accessible at: `http://<SERVER_IP>:8081`

Replace `<SERVER_IP>` with your real IP (e.g., `http://192.168.1.100:8081`)

On the home page, click "Get started" and configure:
- Port 53 for DNS - leave default
- Admin password - set yours

## Step 7: Test DNS

```bash
# From your machine or another PC on the network
nslookup google.com <SERVER_IP>

# Or with dig
dig @<SERVER_IP> google.com
```

If it responds, it works!

## Step 8: Start Other Services (Optional)

### Home Assistant
```bash
cp services/homeassistant/.env.example services/homeassistant/.env
docker compose -f services/homeassistant/docker-compose.yaml up -d
# Access: http://<SERVER_IP>:8123
```

### Jellyfin
```bash
cp services/jellyfin/.env.example services/jellyfin/.env
docker compose -f services/jellyfin/docker-compose.yaml up -d
# Access: http://<SERVER_IP>:8096
```

## Step 9: Verify All Services

```bash
docker ps

# Or with stats (CPU, RAM, network)
docker stats
```

## Done!

Your homelab is running. Next steps:
- Read SERVICES.md to understand each service
- Read TROUBLESHOOTING.md if something fails
- Read SETUP.md for advanced configuration

## Common Issues

### "Port already in use"
Another service is using that port. Either:
1. Stop the other service
2. Change the port in .env.example

Check port usage:
```bash
sudo lsof -i -P -n | grep LISTEN
```

### "Permission denied with Docker"
Add your user to Docker group:
```bash
sudo usermod -aG docker $USER
# Restart your session (disconnect/reconnect)
```

### "docker compose: command not found"
Install Docker Compose: https://docs.docker.com/compose/install/

Need more help? See TROUBLESHOOTING.md

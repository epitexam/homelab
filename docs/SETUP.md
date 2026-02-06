# Complete Setup Guide

Detailed installation and advanced configuration.

## 1. System Requirements

### Recommended Hardware
- CPU: 2+ cores (4 recommended)
- RAM: 4GB (8GB+ recommended for all services)
- Disk: 20GB+ free (more for Jellyfin with movies)
- Network: Stable, preferably wired

### Supported OS
- Ubuntu 22.04 LTS (recommended)
- Ubuntu 24.04 LTS
- Debian 12
- MacOS with Docker Desktop
- Windows 11 with Docker Desktop

## 2. Install Docker

### Ubuntu/Debian
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Restart session
exit
# Reconnect via SSH or restart terminal

# Verify
docker --version
docker compose version
```

### MacOS
Download Docker Desktop: https://www.docker.com/products/docker-desktop

### Windows 11
Download Docker Desktop: https://www.docker.com/products/docker-desktop

## 3. Prepare Environment

### Create homelab directory
```bash
mkdir -p ~/homelab
cd ~/homelab
```

### Clone repository
```bash
git clone <url-of-repo> .
# The dot means "in current directory"
```

### Create .env file
```bash
cp .env.example .env
nano .env
```

Fill in:
```bash
TZ=Europe/Paris
SERVER_IP=192.168.1.100
ADMIN_PORT=9000
```

## 4. Prepare Volumes (Data Directories)

```bash
# Complete structure
mkdir -p services/adguard/adguard/{work,conf}
mkdir -p services/homeassistant/config
mkdir -p services/jellyfin/{config,cache,media,media2,fonts}

# Verify
ls -la services/*/
```

## 5. Start Services

### One by One (recommended for testing)

#### AdGuard Home
```bash
cp services/adguard/.env.example services/adguard/.env
docker compose -f services/adguard/docker-compose.yaml up -d
docker compose -f services/adguard/docker-compose.yaml logs -f
# Press Ctrl+C to exit logs
```

#### Home Assistant
```bash
cp services/homeassistant/.env.example services/homeassistant/.env
docker compose -f services/homeassistant/docker-compose.yaml up -d
docker compose -f services/homeassistant/docker-compose.yaml logs -f
```

#### Jellyfin
```bash
cp services/jellyfin/.env.example services/jellyfin/.env
docker compose -f services/jellyfin/docker-compose.yaml up -d
docker compose -f services/jellyfin/docker-compose.yaml logs -f
```

### All at Once (after testing)
```bash
# Copy configs
cp services/*/env.example services/*/.env

# Start all
docker compose -f services/adguard/docker-compose.yaml up -d
docker compose -f services/homeassistant/docker-compose.yaml up -d
docker compose -f services/jellyfin/docker-compose.yaml up -d

# Verify
docker ps
```

## 6. Verify Everything Works

```bash
# See all running containers
docker ps

# See resource usage (CPU, RAM, network)
docker stats

# View logs for specific service
docker compose -f services/adguard/docker-compose.yaml logs -f
```

Expected output: all 3 services with status "Up"

## 7. Access Web Interfaces

Replace 192.168.1.100 with your SERVER_IP:

- AdGuard Home: http://192.168.1.100:8081
- Home Assistant: http://192.168.1.100:8123
- Jellyfin: http://192.168.1.100:8096

## 8. Advanced Configuration

### Router-Level DNS Configuration

To use AdGuard for entire network:

1. Access router (usually 192.168.1.1 or 192.168.0.1)
2. Find DNS settings (Network -> DNS or DHCP -> DNS)
3. Set primary DNS to <SERVER_IP>
4. Restart router

### Data Persistence on Reboot

Docker automatically restarts containers with "restart: unless-stopped".

To ensure Docker starts on boot:
```bash
sudo systemctl enable docker
```

## 9. Backup Configuration

### Manual Backup
```bash
tar czf homelab-backup-$(date +%Y%m%d).tar.gz \
  services/adguard/adguard/ \
  services/homeassistant/config/ \
  services/jellyfin/config/
```

### Restore Backup
```bash
tar xzf homelab-backup-*.tar.gz
```

### Automatic Backup (cron)
```bash
crontab -e

# Add this line for daily backup at 2 AM
0 2 * * * tar czf /backups/homelab-$(date +\%Y\%m\%d).tar.gz ~/homelab/services/*/config ~/homelab/services/*/data
```

## 10. Update Images

### Manual Update
```bash
# Download latest images
docker compose -f services/adguard/docker-compose.yaml pull

# Restart service (uses new image)
docker compose -f services/adguard/docker-compose.yaml up -d
```

### Docker Version Update
```bash
# Ubuntu/Debian
sudo apt update
sudo apt upgrade

# Verify
docker --version
```

## 11. Troubleshooting

See TROUBLESHOOTING.md for detailed solutions to common issues.

## 12. Next Steps

- Read SERVICES.md to customize each service
- Read TROUBLESHOOTING.md for problem solving
- Set up automatic backups
- Add your own services

# Troubleshooting Guide

Solutions to common problems.

## Docker Issues

### "docker: command not found"
Docker is not installed.

Solution:
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Verify
docker --version
```

### "docker compose: command not found"
Docker Compose is not installed.

Solution:
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker compose version
```

### "Permission denied while trying to connect to Docker"
You don't have Docker permissions.

Solution:
```bash
sudo usermod -aG docker $USER

# Restart session (disconnect/reconnect)
exit
```

---

## Port Issues

### "Error: Address already in use"
Port is used by another application.

Check what's using it:
```bash
# See listening ports
sudo lsof -i -P -n | grep LISTEN

# Or with netstat
sudo netstat -tlnp | grep LISTEN
```

Solution 1: Stop other service
```bash
docker stop <container-id>
sudo systemctl stop <service>
```

Solution 2: Change port
Edit .env.example for the service:
```bash
# Before
SERVICE_PORT=8080

# After
SERVICE_PORT=8888  # Free port
```

Restart:
```bash
docker compose -f services/mon-service/docker-compose.yaml restart
```

View all ports used:
```bash
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

---

## Startup Issues

### Service won't start
Check logs:
```bash
docker compose -f services/my-service/docker-compose.yaml logs -f

# Wait and look for errors
```

### "Directory does not exist"
```
ERROR: bind mount source path /path/does/not/exist does not exist
```

Create missing directories:
```bash
# AdGuard example
mkdir -p services/adguard/adguard/{work,conf}

# Or for all services
mkdir -p services/*/config
mkdir -p services/*/data
```

### Container exits immediately
View logs to find why:
```bash
docker logs <container-id>
```

---

## Network Issues

### Cannot access http://<SERVER_IP>:8080

Check 1: Is container running?
```bash
docker ps | grep my-service
# Must show "Up"
```

Check 2: Is port forwarded?
```bash
# On Docker machine
curl http://localhost:8080
# Should show a page

# From another machine
curl http://<SERVER_IP>:8080
```

Check 3: Is firewall blocking?
```bash
# Allow port on Ubuntu
sudo ufw allow 8080
sudo ufw allow 8080/tcp

# Verify
sudo ufw status
```

Check 4: Correct IP?
```bash
# Get all IPs
hostname -I

# Use local IP (192.168.x.x or 10.0.x.x)
# NOT 127.0.0.1 (that's only local)
```

### AdGuard DNS not responding
```bash
# Test from same machine
nslookup google.com localhost

# Test from another machine
nslookup google.com <SERVER_IP>
```

AdGuard takes a few seconds to start. Wait 30 seconds.

---

## Disk Space

### "Disk quota exceeded" or full

Check usage:
```bash
# Total disk
df -h /

# Docker usage
du -sh ~/homelab/services/*/

# By service
du -sh ~/homelab/services/*/data
du -sh ~/homelab/services/*/config
du -sh ~/homelab/services/*/cache
```

Solutions:

1. Clean unused images:
   ```bash
   docker image prune -a
   ```

2. Clean stopped containers:
   ```bash
   docker container prune
   ```

3. Clean unused volumes:
   ```bash
   docker volume prune
   ```

4. Limit container size:
   ```yaml
   # In docker-compose.yaml
   services:
     my-service:
       deploy:
         resources:
           limits:
             memory: 2G
   ```

---

## Performance

### High CPU/RAM usage

Check real-time usage:
```bash
docker stats

# Or for specific service
docker stats my-service
```

Solutions:

1. Reduce logging:
   ```yaml
   # In docker-compose.yaml
   logging:
     driver: "json-file"
     options:
       max-size: "10m"
       max-file: "3"
   ```

2. Limit resources:
   ```yaml
   services:
     my-service:
       deploy:
         resources:
           limits:
             cpus: '2'
             memory: 2G
   ```

3. Disable transcoding (Jellyfin):
   ```
   Jellyfin -> Admin -> Playback -> Transcoding = Off
   ```

---

## Data Issues

### Lost data!

Before assuming data is lost:

```bash
ls -la services/my-service/
# You should see config/, data/, cache/, etc.

# Are they empty?
ls -la services/my-service/config/
```

### Restore from backup
```bash
# If you have backup
tar xzf my-service-backup-*.tar.gz -C services/my-service/

# Restart service
docker compose -f services/my-service/docker-compose.yaml restart
```

### Container writes as root (permissions)

Symptom:
```
Error: Permission denied when accessing /config
```

Solution (Jellyfin example):
```bash
# Get your user ID
id
# Example output: uid=1000(user) gid=1000(user)

# Edit .env
nano services/jellyfin/.env
# Set UID=1000 and GID=1000

# Restart
docker compose -f services/jellyfin/docker-compose.yaml restart

# Fix permissions
sudo chown -R 1000:1000 services/jellyfin/
```

---

## Logs and Debugging

### View service logs
```bash
# Live logs (Ctrl+C to exit)
docker compose -f services/my-service/docker-compose.yaml logs -f

# Last 50 lines
docker compose -f services/my-service/docker-compose.yaml logs --tail 50

# Specific container
docker logs <container-id>
```

### Run command in container
```bash
# Open shell
docker exec -it <container-id> /bin/bash

# Run single command
docker exec <container-id> curl http://localhost:8080
```

### Inspect container
```bash
docker inspect <container-id> | grep -i error
docker inspect <container-id> | grep -i ip
```

---

## Boot Startup

Containers with "restart: unless-stopped" auto-restart if machine reboots.

If not working:

```bash
# Enable Docker to start on boot
sudo systemctl enable docker
sudo systemctl start docker

# Verify
sudo systemctl status docker
```

---

## Updates

### Update service image
```bash
# Download latest version
docker compose -f services/my-service/docker-compose.yaml pull

# Restart (uses new image)
docker compose -f services/my-service/docker-compose.yaml up -d
```

### Update Docker
```bash
# Ubuntu/Debian
sudo apt update
sudo apt upgrade

# Verify
docker --version
```

---

## Service-Specific Issues

### AdGuard Home

**Port 53 conflict**
```
FATAL: DNS listening port cannot be used
```

```bash
# See what uses port 53
sudo lsof -i :53

# If systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved

# Restart AdGuard
docker restart adguardhome
```

### Home Assistant

**Port 8123 occupied**
```yaml
# In docker-compose.yaml
ports:
  - "8124:8123"  # Change to 8124, 8125, etc
```

### Jellyfin

**No thumbnails after 1 hour**
- Wait, Jellyfin is still scanning
- Or restart service

**Transcoding fails**
- CPU not powerful enough
- Disable transcoding: Admin -> Playback

---

## If Everything Fails

1. **Check logs first**:
   ```bash
   docker compose -f services/my-service/docker-compose.yaml logs -f
   ```

2. **Consult this guide**: Most answers are here

3. **Read service documentation**: On hub.docker.com/

4. **Google the exact error**: In quotes

5. **Rollback**: You have backups
   ```bash
   # Stop everything
   docker compose -f services/*/docker-compose.yaml down
   
   # Restore
   tar xzf homelab-backup-*.tar.gz
   
   # Restart
   docker compose -f services/*/docker-compose.yaml up -d
   ```

---

## Quick Reference

```bash
# View all running containers
docker ps

# View resource usage
docker stats

# View logs
docker compose -f services/mon-service/docker-compose.yaml logs -f

# Restart container
docker compose -f services/mon-service/docker-compose.yaml restart

# Stop container
docker compose -f services/mon-service/docker-compose.yaml down

# Execute command in container
docker exec <container-id> <command>

# Backup data
tar czf backup-$(date +%Y%m%d).tar.gz services/*/config

# Clean up
docker image prune -a
docker container prune
docker volume prune
```

# Services Guide

Description and configuration for each service.

## AdGuard Home (DNS + Ad Blocking)

DNS server with integrated ad blocking. Blocks ads on entire network.

### Access
- Web interface: http://<SERVER_IP>:8081
- DNS: port 53 (TCP and UDP)
- Initial setup: 3000

### Configuration

1. Start service:
```bash
cp services/adguard/.env.example services/adguard/.env
docker compose -f services/adguard/docker-compose.yaml up -d
```

2. Initial setup:
- Go to http://<SERVER_IP>:3000 (temporary port)
- Click "Get Started"
- Configure:
  - Admin interface port: 8081
  - DNS server port: 53 (leave default)
  - Username: admin (or your choice)
  - Password: choose strong password
- Click "Apply"

3. Normal access:
After setup, port 3000 closes. Access at: http://<SERVER_IP>:8081

### Environment Variables (.env)
```bash
SERVER_IP=192.168.1.100
TZ=Europe/Paris
```

### Persistent Data
```
services/adguard/adguard/
├── work/    - Cache, logs, history
└── conf/    - Configuration (AdGuardHome.yaml)
```

### Usage

#### Point DNS to AdGuard

**Option 1: Per machine (Linux/Mac)**
```bash
sudo nano /etc/resolv.conf
# Add: nameserver 192.168.1.100
```

**Option 2: Router level (affects all devices)**
1. Access router (192.168.1.1)
2. Settings -> DHCP -> DNS
3. DNS primary = <SERVER_IP>
4. Restart router

**Option 3: Per device (phone, etc)**
WiFi settings -> DNS -> Manual -> <SERVER_IP>

#### Add blocklists
1. Access http://<SERVER_IP>:8081
2. Filters -> Blocklists
3. Add blocklist URLs (examples available online)

### Troubleshooting
- **Port 53 error**: systemd-resolved using it
  ```bash
  sudo systemctl disable systemd-resolved
  sudo systemctl stop systemd-resolved
  ```
- **Interface not accessible**: Wait 30s after starting

---

## Home Assistant (Home Automation)

Platform to control smart devices (lights, thermostats, etc).

### Access
- Web interface: http://<SERVER_IP>:8123

### Configuration

1. Start service:
```bash
cp services/homeassistant/.env.example services/homeassistant/.env
docker compose -f services/homeassistant/docker-compose.yaml up -d
```

2. Initial setup:
- Go to http://<SERVER_IP>:8123
- Create account (username + password)
- Configure location (for automations)
- Done!

### Environment Variables (.env)
```bash
TZ=Europe/Paris
```

### Persistent Data
```
services/homeassistant/config/
├── configuration.yaml  - Main config
├── automations/        - Automations (optional)
└── secrets.yaml        - Secrets (optional)
```

### Usage

#### Add Device/Automation
1. Settings -> Devices & Services
2. Create Automation
3. Examples:
   - Turn lights on at 10 PM
   - Send notification if door opens

#### Popular Integrations
- MQTT: Generic home automation
- HASS.IO: Add-ons (Node-Red, Mosquitto, etc)
- REST API: Control via HTTP

#### Remote Access
Home Assistant includes Nabu Casa (optional, paid) for secure remote access.

### Troubleshooting
- **Very slow on startup**: First run takes 2-5 minutes
- **Port 8123 occupied**: Change in docker-compose.yaml

---

## Jellyfin (Media Server)

Stream movies, TV series, music.

### Access
- Web interface: http://<SERVER_IP>:8096
- Streaming: Everywhere on network (and internet if configured)

### Configuration

1. Start service:
```bash
cp services/jellyfin/.env.example services/jellyfin/.env
docker compose -f services/jellyfin/docker-compose.yaml up -d
```

2. Initial setup:
- Go to http://<SERVER_IP>:8096
- Create admin account (email + password)
- Configure library (see step 3)
- Done!

### Environment Variables (.env)
```bash
UID=1000                    # User ID (run: id -u)
GID=1000                    # Group ID (run: id -g)
JELLYFIN_PORT=8096
JELLYFIN_PUBLISHED_URL=     # Leave empty for local
```

### Persistent Data
```
services/jellyfin/
├── config/   - Configuration and database
├── cache/    - Image cache/thumbs
├── media/    - Movies/Series (you create folders)
├── media2/   - Second source (optional)
└── fonts/    - Custom fonts (optional)
```

### Add Media Library

**Approach 1: Local folders**
```bash
# Create content folders
mkdir -p services/jellyfin/media/{movies,tv,music}

# Add your files
cp -r /path/to/movies services/jellyfin/media/movies/
cp -r /path/to/series services/jellyfin/media/tv/
```

**Expected structure:**
```
media/
├── movies/
│   ├── Movie Title (2020)/
│   │   └── Movie Title.mkv
│   └── Another Movie (2021)/
│       └── Another Movie.mkv
└── tv/
    ├── Series Name/
    │   ├── Season 1/
    │   │   ├── Episode 01.mkv
    │   │   └── Episode 02.mkv
    │   └── Season 2/
    │       └── Episode 01.mkv
    └── Another Series/
        └── ...
```

**Approach 2: Network share (NFS/SMB)**
1. Configure network share on another server
2. Mount in Docker via docker-compose.yaml

#### Add Library to Jellyfin
1. Go to http://<SERVER_IP>:8096
2. Admin -> Libraries
3. Click "+"
4. Select type (Movies, TV, Music)
5. Add path: /media/movies (or /media2/movies, etc)
6. Save

Jellyfin scans automatically.

#### Share with Other Users
1. Admin -> Users
2. Create new user
3. Configure permissions (which libraries they see)
4. Share URL and credentials

#### Transcoding (Important)
Jellyfin can convert videos for device compatibility.

- **No transcoding**: Faster, but not all formats supported
- **With transcoding**: Works everywhere, needs CPU power

Configuration:
1. Admin -> Playback
2. Codec transcode settings
3. Quality = depends on your CPU

### Permissions

If you have permission issues:

```bash
# Give access to Docker user
sudo chown -R 1000:1000 services/jellyfin/

# Or strict permissions
chmod 755 services/jellyfin/{config,cache,media*}
```

### Troubleshooting
- **No thumbnails**: Wait few minutes after scan
- **Transcoding fails**: Codec not supported or not enough CPU
- **Permission denied**: See "Permissions" section above

---

## Add a New Service

Template to add your own service (Nextcloud, Vaultwarden, etc).

### Structure
```
services/my-service/
├── docker-compose.yaml
├── .env.example
└── [optional] config/   - Persistent data
```

### Template docker-compose.yaml

```yaml
name: my-service

services:
  my-service:
    image: my-image:tag  # From hub.docker.com/
    container_name: my-service
    restart: unless-stopped
    
    # Exposed ports
    ports:
      - "${SERVICE_PORT:-8080}:8080/tcp"
    
    # Persistent volumes
    volumes:
      - ./config:/app/config
      - ./data:/app/data
    
    # Environment variables
    environment:
      - TZ=${TZ}
      - SERVICE_VAR=${SERVICE_VAR}
    
    # (Optional) Health check
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Template .env.example

```bash
# services/my-service/.env.example
SERVICE_PORT=8080
SERVICE_VAR=my-value
```

### Steps to Add Service

1. Create directory:
   ```bash
   mkdir -p services/my-service
   ```

2. Create docker-compose.yaml from template above

3. Create .env.example with variables

4. Start:
   ```bash
   docker compose -f services/my-service/docker-compose.yaml up -d
   ```

5. Test:
   ```bash
   docker compose -f services/my-service/docker-compose.yaml logs -f
   docker ps | grep my-service
   ```

### Popular Services

**Nextcloud** (Cloud Storage)
- Image: nextcloud:apache
- Port: 80 (expose on 8080)

**Vaultwarden** (Password Manager)
- Image: vaultwarden/server:latest
- Port: 8000

**Node-Red** (Automations)
- Image: nodered/node-red:latest
- Port: 1880

**Portainer** (Docker Web UI)
- Image: portainer/portainer-ce:latest
- Ports: 8000, 9000

Most Docker images on https://hub.docker.com/ have examples.

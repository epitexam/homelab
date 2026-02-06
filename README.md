# Homelab

Docker Compose configuration for self-hosted services on a single machine.

## Quick Start (5 minutes)

```bash
# 1. Clone or navigate to repository
cd homelab

# 2. Create configuration file
cp .env.example .env

# 3. Edit with your values (SERVER_IP is important!)
nano .env

# 4. Start a service (example: AdGuard Home)
docker compose -f services/adguard/docker-compose.yaml up -d

# 5. Verify it is running
docker compose -f services/adguard/docker-compose.yaml logs -f
```

## Requirements

- Docker: v20.10+
- Docker Compose: v2.0+
- System: Linux (Ubuntu 22.04 recommended) or MacOS/Windows with Docker Desktop
- RAM: 4GB minimum, 8GB recommended
- Disk: 20GB free minimum

Install Docker: https://docs.docker.com/get-docker/

## Available Services

| Service | Port | Function | Status |
|---------|------|----------|--------|
| AdGuard Home | 8081 | DNS + Ad Blocking | Included |
| Home Assistant | 8123 | Home Automation | Included |
| Jellyfin | 8096 | Media Server | Included |

## Project Structure

```
homelab/
├── .env.example           # Copy to .env
├── .gitignore
├── README.md              # This file
├── CHANGELOG.md           # Version history
├── setup.sh               # Automatic setup script
│
├── docs/                  # Documentation
│   ├── QUICKSTART.md      # Quick start guide
│   ├── SETUP.md           # Detailed installation
│   ├── SERVICES.md        # Service descriptions
│   └── TROUBLESHOOTING.md # Common issues and solutions
│
└── services/              # Individual services
    ├── adguard/
    │   ├── docker-compose.yaml
    │   └── .env.example
    ├── homeassistant/
    │   ├── docker-compose.yaml
    │   └── .env.example
    └── jellyfin/
        ├── docker-compose.yaml
        └── .env.example
```

## Usage

### Start a service
```bash
docker compose -f services/adguard/docker-compose.yaml up -d
```

### View logs
```bash
docker compose -f services/adguard/docker-compose.yaml logs -f
```

### Stop a service
```bash
docker compose -f services/adguard/docker-compose.yaml down
```

### Restart a service
```bash
docker compose -f services/adguard/docker-compose.yaml restart
```

### View running containers
```bash
docker ps
```

## Configuration

### .env File

The .env file contains sensitive variables (IPs, ports, etc). NEVER commit it to Git.

Create from template:
```bash
cp .env.example .env
```

### Service Configuration

Each service has its own .env.example. Copy it to .env:

```bash
cp services/adguard/.env.example services/adguard/.env
```

## Security

- .env is in .gitignore (not committed)
- .env.example shows structure without sensitive values
- Persistent data (volumes) is gitignored
- Each service runs in isolated container

## Documentation

- QUICKSTART.md - Quick start guide
- SETUP.md - Detailed installation
- SERVICES.md - Service descriptions and "add new service" guide
- TROUBLESHOOTING.md - Common issues and solutions

## Common Questions

**How much disk space?**
5-10GB for all services. Depends on your data (Jellyfin = heavy).

**Can I add my own services?**
Yes! See docs/SERVICES.md -> "Add a new service"

**Does it work on Raspberry Pi?**
Yes, but slower. Test first.

**Security and internet exposure?**
Read docs/TROUBLESHOOTING.md -> "Security"

## License

MIT - Use freely

## Contributing

1. Fork repository
2. Create branch (git checkout -b feature/something)
3. Commit (git commit -m "Add something")
4. Push (git push origin feature/something)
5. Create Pull Request

Need help? Check docs/TROUBLESHOOTING.md first.

See also: CHANGELOG.md - Version history

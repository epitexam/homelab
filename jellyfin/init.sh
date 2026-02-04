#!/bin/bash

# Load variables from .env file (to get UID/GID)
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Set default UID/GID if not found in .env
USER_ID=${UID:-1000}
GROUP_ID=${GID:-1000}

echo "Configuring directories for Jellyfin (UID: $USER_ID, GID: $GROUP_ID)..."

# Create directories if they do not exist
mkdir -p ./config ./cache ./media ./media2 ./fonts

# Apply ownership and permissions
# sudo is used because some directories may already belong to root
sudo chown -R $USER_ID:$GROUP_ID ./config ./cache ./media ./media2 ./fonts
sudo chmod -R 775 ./config ./cache

echo "Directories are ready. You can now run: docker compose up -d"

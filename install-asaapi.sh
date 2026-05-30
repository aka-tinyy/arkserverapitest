#!/usr/bin/env bash
set -e

WIN64="/home/containeruser/serverfiles/ShooterGame/Binaries/Win64"

# 1. Ensure required packages are present quietly
apt-get update -qq && apt-get install -y --no-install-recommends curl unzip jq > /dev/null 2>&1

# 2. Fetch latest release details from GitHub API
RELEASE_DATA=$(curl -fsSL https://api.github.com/repos/ArkServerApi/AsaApi/releases/latest)
ASAAPI_RELEASE=$(echo "$RELEASE_DATA" | jq -r '.tag_name')
ASAAPI_ZIP_URL=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | endswith(".zip")) | .browser_download_url' | head -1)

# Fallback check if API lookup fails due to rate limits
if [ -z "$ASAAPI_RELEASE" ] || [ "$ASAAPI_RELEASE" = "null" ]; then
    echo "[AsaApi] WARNING: Failed to fetch latest version from GitHub API. Checking local installation..."
    if [ -f "$WIN64/AsaApiLoader.exe" ]; then
        echo "[AsaApi] AsaApiLoader.exe found, skipping update check to prevent crash."
        exit 0
    else
        echo "[AsaApi] ERROR: Critical files missing and API rate-limited. Cannot install."
        exit 1
    fi
fi

INSTALLED_VER=$(cat "$WIN64/.asaapi_version" 2>/dev/null || echo '')

# 3. Check if we need to install/update
if [ "$INSTALLED_VER" != "$ASAAPI_RELEASE" ] || [ ! -f "$WIN64/AsaApiLoader.exe" ]; then
    echo "[AsaApi] Installing version $ASAAPI_RELEASE..."
    
    # Ensure directory framework exists
    mkdir -p "$WIN64"

    # Download and unpack cleanly
    curl -fsSL -o /tmp/asaapi.zip "$ASAAPI_ZIP_URL"
    unzip -oq /tmp/asaapi.zip -d "$WIN64/"
    rm -f /tmp/asaapi.zip
    
    # Save exact version string
    echo "$ASAAPI_RELEASE" > "$WIN64/.asaapi_version"
    
    # Fix ownership explicitly for containeruser context
    chown -R containeruser:containeruser "$WIN64"
    chmod +x "$WIN64/AsaApiLoader.exe"
    
    echo "[AsaApi] Installation completed successfully."
else
    echo "[AsaApi] Up to date ($INSTALLED_VER). No action required."
fi

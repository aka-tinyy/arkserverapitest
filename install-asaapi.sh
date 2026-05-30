#!/bin/bash
WIN64=/home/containeruser/serverfiles/ShooterGame/Binaries/Win64
apt-get install -y --no-install-recommends curl unzip jq > /dev/null 2>&1
ASAAPI_RELEASE=$(curl -fsSL https://api.github.com/repos/ArkServerApi/AsaApi/releases/latest | jq -r '.tag_name')
ASAAPI_ZIP_URL=$(curl -fsSL https://api.github.com/repos/ArkServerApi/AsaApi/releases/latest | jq -r '.assets[] | select(.name | endswith(".zip")) | .browser_download_url' | head -1)
INSTALLED_VER=$(cat $WIN64/.asaapi_version 2>/dev/null || echo '')
if [ "$INSTALLED_VER" != "$ASAAPI_RELEASE" ] || [ ! -f "$WIN64/ArkApi/AsaApi.dll" ]; then
  echo "[AsaApi] Installing $ASAAPI_RELEASE..."
  curl -fsSL -o /tmp/asaapi.zip "$ASAAPI_ZIP_URL"
  unzip -o /tmp/asaapi.zip -d $WIN64/
  rm -f /tmp/asaapi.zip
  echo "[AsaApi] Downloading VersionLoader..."
  curl -fsSL -o /tmp/versionloader.zip "https://github.com/ArkServerApi/AsaApiLoader/releases/download/v1.0/VersionLoader.zip"
  unzip -o /tmp/versionloader.zip -d $WIN64/
  rm -f /tmp/versionloader.zip
  echo "$ASAAPI_RELEASE" > $WIN64/.asaapi_version
  chown -R containeruser:containeruser $WIN64/
  echo "[AsaApi] Done."
else
  echo "[AsaApi] Already up to date ($INSTALLED_VER)."
fi

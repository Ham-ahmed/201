#!/bin/sh

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Cleanup function
cleanup() {
    rm -f "$package" 2>/dev/null
    rm -rf /tmp/*.ipk /tmp/*.tar.gz ./CONTROL ./control ./postinst ./preinst ./prerm ./postrm 2>/dev/null
}

# Check root permissions
if [ "$(id -u)" -ne 0 ]; then
    echo "${RED}> Script must be run with root privileges${NC}"
    exit 1
fi

# Set trap for cleanup on exit
trap cleanup EXIT

# Initial cleanup
cleanup

# Configuration
plugin="All-plugins"
version="1.0"
url="https://gitlab.com/h-ahmed/Panel/-/raw/main/All-plugins/All-Plugins.tar.gz"
package="/var/volatile/tmp/$plugin-$version.tar.gz"

# Create target directory if it doesn't exist
mkdir -p "/var/volatile/tmp"

echo "> Downloading $plugin-$version package ..."
sleep 3

# Check internet connection and download package
if command -v wget >/dev/null 2>&1; then
    # Check if URL is accessible
    if ! wget --spider -q "$url"; then
        echo "${RED}> Failed to connect to internet or invalid URL${NC}"
        exit 1
    fi
    # Download package
    wget -q --no-check-certificate --timeout=10 --tries=3 -O "$package" "$url"
elif command -v curl >/dev/null 2>&1; then
    # Check if URL is accessible
    if ! curl -s --head "$url" | head -n 1 | grep "200 OK" >/dev/null; then
        echo "${RED}> Failed to connect to internet or invalid URL${NC}"
        exit 1
    fi
    # Download package
    curl -s -k --connect-timeout 10 --retry 3 -o "$package" "$url"
else
    echo "${RED}> Neither wget nor curl found${NC}"
    exit 1
fi

# Check if download was successful
if [ $? -ne 0 ] || [ ! -f "$package" ]; then
    echo "${RED}> Package download failed${NC}"
    exit 1
fi

# Extract package
tar -xzf "$package" -C /
extract=$?

if [ $extract -eq 0 ]; then
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                      ✅ INSTALLATION SUCCESSFUL                ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   ▶ Plugin: $plugin"
    echo -e "${BLUE}   ▶ Version: v7.8"
    echo -e "${YELLOW} ▶ Note: Device will restart automatically"
    echo -e "${CYAN}   ▶ Uploaded by: HAMDY_AHMED"
    echo -e "${WHITE}  ▶ Group link: https://www.facebook.com/share/g/18qCRuHz26/"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}⏳ Restarting Enigma2 in 3 seconds...${NC}"
    sleep 3
    # Safe Enigma2 restart
    if command -v init >/dev/null 2>&1; then
        init 4 && sleep 2 && init 3 &
    else
        killall enigma2
    fi
else
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}              ❌ INSTALLATION FAILED                           ${NC}"
    echo -e "${RED}         $plugin-$version package installation failed          ${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    exit 1
fi

exit 0
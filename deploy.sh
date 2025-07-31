#!/bin/bash

# SAIDTECH VPN Panel Quick Deployment Script
# One-liner installation for fresh VPS servers

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Repository URL (update this with your actual repository)
REPO_URL="https://github.com/your-username/saidtech-vpn-panel"
RAW_URL="https://raw.githubusercontent.com/your-username/saidtech-vpn-panel/main"

# Show banner
echo -e "${PURPLE}"
cat << 'EOF'
██████████████████████████████████████████████████████████████████████████████
              SAIDTECH VPN PANEL - QUICK DEPLOYMENT SCRIPT
██████████████████████████████████████████████████████████████████████████████
EOF
echo -e "${NC}"

echo -e "${CYAN}🚀 Quick VPS Deployment for SAIDTECH Premium Internet VPN${NC}"
echo -e "${WHITE}Author: JOSHUA SAID | Optimized for Safaricom Networks${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}❌ This script must be run as root!${NC}"
    echo -e "${YELLOW}Please run: ${WHITE}sudo bash $0${NC}"
    exit 1
fi

echo -e "${CYAN}📋 Pre-flight checks...${NC}"

# Check internet connectivity
if ! ping -c 1 google.com &> /dev/null; then
    echo -e "${RED}❌ No internet connection detected!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Internet connection: OK${NC}"

# Detect OS
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$NAME
    echo -e "${GREEN}✅ Operating System: $OS${NC}"
else
    echo -e "${RED}❌ Unable to detect operating system${NC}"
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo ""
echo -e "${CYAN}📥 Downloading SAIDTECH VPN Panel...${NC}"

# Download method 1: Try wget
if command -v wget >/dev/null 2>&1; then
    echo -e "${YELLOW}Using wget...${NC}"
    wget -q --show-progress "$RAW_URL/saidtech-vpn-panel.sh" -O saidtech-vpn-panel.sh
    wget -q --show-progress "$RAW_URL/install.sh" -O install.sh
    wget -q --show-progress "$RAW_URL/config.conf" -O config.conf
    
# Download method 2: Try curl
elif command -v curl >/dev/null 2>&1; then
    echo -e "${YELLOW}Using curl...${NC}"
    curl -L -# "$RAW_URL/saidtech-vpn-panel.sh" -o saidtech-vpn-panel.sh
    curl -L -# "$RAW_URL/install.sh" -o install.sh
    curl -L -# "$RAW_URL/config.conf" -o config.conf
    
else
    echo -e "${RED}❌ Neither wget nor curl found. Installing wget...${NC}"
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        apt-get update -qq && apt-get install -y wget
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
        yum install -y wget
    fi
    wget -q --show-progress "$RAW_URL/saidtech-vpn-panel.sh" -O saidtech-vpn-panel.sh
    wget -q --show-progress "$RAW_URL/install.sh" -O install.sh
    wget -q --show-progress "$RAW_URL/config.conf" -O config.conf
fi

echo -e "${GREEN}✅ Download completed!${NC}"

# Verify downloads
if [[ ! -f "saidtech-vpn-panel.sh" ]] || [[ ! -f "install.sh" ]]; then
    echo -e "${RED}❌ Download failed! Please check your internet connection.${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}🔧 Starting installation...${NC}"

# Make scripts executable
chmod +x saidtech-vpn-panel.sh install.sh

# Run installer
echo -e "${YELLOW}Running SAIDTECH VPN Panel installer...${NC}"
echo ""

# Run the installer
./install.sh

# Cleanup
echo ""
echo -e "${CYAN}🧹 Cleaning up temporary files...${NC}"
cd /
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""
echo -e "${PURPLE}══════════════════════════════════════════════════${NC}"
echo -e "${WHITE}🎉 SAIDTECH VPN Panel is now ready!${NC}"
echo -e "${PURPLE}══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo -e "${WHITE}1. Run: ${GREEN}saidtech-vpn${NC}"
echo -e "${WHITE}2. Configure your domain in Settings${NC}"
echo -e "${WHITE}3. Set up SSL certificates${NC}"
echo -e "${WHITE}4. Create your first VPN users${NC}"
echo ""
echo -e "${YELLOW}📞 Support:${NC}"
echo -e "${WHITE}• Telegram: ${CYAN}t.me/Joshuasaid${NC}"
echo -e "${WHITE}• Website: ${CYAN}saidtech.com${NC}"
echo ""
echo -e "${GRAY}© 2025 SAIDTECH VPN - ALL RIGHTS RESERVED${NC}"
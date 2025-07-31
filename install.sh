#!/bin/bash

# SAIDTECH VPN Panel Installer
# Quick installation script for SAIDTECH Premium Internet VPN Script 2025

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Script information
SCRIPT_NAME="SAIDTECH VPN Panel"
VERSION="4.2.1"
AUTHOR="JOSHUA SAID"

# Installation paths
INSTALL_DIR="/opt/saidtech-vpn"
CONFIG_DIR="/etc/saidtech-vpn"
BIN_PATH="/usr/local/bin/saidtech-vpn"

# Show banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    cat << 'EOF'
██████████████████████████████████████████████████████████████████████████████
                     SAIDTECH VPN PANEL INSTALLER v4.2.1
██████████████████████████████████████████████████████████████████████████████
EOF
    echo -e "${NC}"
    echo -e "${CYAN}Author: ${WHITE}$AUTHOR${NC}"
    echo -e "${CYAN}Compatible: ${WHITE}Ubuntu, Debian, CentOS, RHEL, Termux${NC}"
    echo -e "${CYAN}Optimized: ${WHITE}Safaricom Networks${NC}"
    echo ""
}

# Animated loading function
show_loading() {
    local message="$1"
    local duration="${2:-3}"
    local spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    
    echo -ne "${CYAN}$message${NC} "
    for ((i=0; i<duration*5; i++)); do
        printf "\r${CYAN}$message${NC} ${YELLOW}${spinner:$((i%10)):1}${NC}"
        sleep 0.2
    done
    printf "\r${GREEN}$message ✓${NC}\n"
}

# Check root privileges
check_root() {
    if [[ $EUID -ne 0 ]] && [[ "$USER" != "root" ]]; then
        echo -e "${YELLOW}Warning: Not running as root. Some features may require sudo.${NC}"
        echo -e "${CYAN}For best experience, run: ${WHITE}sudo $0${NC}"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Detect operating system
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [[ -f /etc/redhat-release ]]; then
        OS="CentOS"
        VER=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+')
    elif [[ "$PREFIX" == *"com.termux"* ]]; then
        OS="Termux"
        VER="Android"
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    echo -e "${CYAN}Detected OS: ${WHITE}$OS $VER${NC}"
}

# Install dependencies
install_dependencies() {
    show_loading "Installing dependencies" 2
    
    local deps=("curl" "wget" "openssl")
    
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        apt-get update -qq >/dev/null 2>&1
        apt-get install -y curl wget openssl uuid-runtime tar gzip >/dev/null 2>&1
        
        # Install ufw if not present
        if ! command -v ufw >/dev/null 2>&1; then
            apt-get install -y ufw >/dev/null 2>&1
        fi
        
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"RHEL"* ]]; then
        if command -v yum >/dev/null 2>&1; then
            yum install -y curl wget openssl util-linux tar gzip >/dev/null 2>&1
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y curl wget openssl util-linux tar gzip >/dev/null 2>&1
        fi
        
        # Install firewall-cmd if not present
        if ! command -v firewall-cmd >/dev/null 2>&1; then
            if command -v yum >/dev/null 2>&1; then
                yum install -y firewalld >/dev/null 2>&1
            elif command -v dnf >/dev/null 2>&1; then
                dnf install -y firewalld >/dev/null 2>&1
            fi
        fi
        
    elif [[ "$OS" == *"Termux"* ]]; then
        pkg update >/dev/null 2>&1
        pkg install -y curl wget openssl coreutils tar gzip >/dev/null 2>&1
        
    else
        echo -e "${YELLOW}Unknown OS. Please install manually: curl wget openssl${NC}"
    fi
}

# Configure firewall
configure_firewall() {
    show_loading "Configuring firewall for Safaricom ports" 2
    
    # Safaricom-optimized ports
    local safaricom_ports=("80" "443" "53" "8080" "3128" "109" "143" "447" "777")
    
    if command -v ufw >/dev/null 2>&1; then
        # Configure UFW
        for port in "${safaricom_ports[@]}"; do
            ufw allow "$port/tcp" >/dev/null 2>&1
            ufw allow "$port/udp" >/dev/null 2>&1
        done
        
        # UDP port range for UDPGW
        ufw allow 7100:7300/udp >/dev/null 2>&1
        
        # Enable UFW if not already enabled
        echo 'y' | ufw enable >/dev/null 2>&1
        
    elif command -v firewall-cmd >/dev/null 2>&1; then
        # Configure firewalld
        systemctl start firewalld >/dev/null 2>&1
        systemctl enable firewalld >/dev/null 2>&1
        
        for port in "${safaricom_ports[@]}"; do
            firewall-cmd --permanent --add-port="$port/tcp" >/dev/null 2>&1
            firewall-cmd --permanent --add-port="$port/udp" >/dev/null 2>&1
        done
        
        # UDP port range for UDPGW
        firewall-cmd --permanent --add-port="7100-7300/udp" >/dev/null 2>&1
        firewall-cmd --reload >/dev/null 2>&1
        
    else
        echo -e "${YELLOW}No firewall detected. Manual configuration may be required.${NC}"
    fi
}

# Create directories
create_directories() {
    show_loading "Creating directories" 1
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"/{users/{ssh-ws,ssh-cdn,ossh,ovpn-tcp,ovpn-udp,udp,slowdns,shadowsocks,trojan,vmess,vless},backups}
    
    # Set proper permissions
    chmod 755 "$INSTALL_DIR"
    chmod 700 "$CONFIG_DIR"
    chmod 700 "$CONFIG_DIR/users"
    chmod 700 "$CONFIG_DIR/backups"
}

# Install main script
install_script() {
    show_loading "Installing SAIDTECH VPN Panel" 2
    
    # Copy the main script
    if [[ -f "saidtech-vpn-panel.sh" ]]; then
        cp "saidtech-vpn-panel.sh" "$INSTALL_DIR/"
        chmod +x "$INSTALL_DIR/saidtech-vpn-panel.sh"
        
        # Create symlink for easy access
        ln -sf "$INSTALL_DIR/saidtech-vpn-panel.sh" "$BIN_PATH" 2>/dev/null || true
        
    else
        echo -e "${RED}Error: saidtech-vpn-panel.sh not found in current directory!${NC}"
        echo -e "${YELLOW}Please ensure the script file is in the same directory as the installer.${NC}"
        exit 1
    fi
}

# Create systemd service (optional)
create_service() {
    if command -v systemctl >/dev/null 2>&1 && [[ "$OS" != *"Termux"* ]]; then
        show_loading "Creating systemd service" 1
        
        cat > /etc/systemd/system/saidtech-vpn.service << EOF
[Unit]
Description=SAIDTECH VPN Panel
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/saidtech-vpn-panel.sh
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOF
        
        systemctl daemon-reload >/dev/null 2>&1
        systemctl enable saidtech-vpn >/dev/null 2>&1
    fi
}

# Configure environment
configure_environment() {
    show_loading "Configuring environment" 1
    
    # Create initial configuration
    cat > "$CONFIG_DIR/domain.conf" << EOF
# SAIDTECH VPN Panel Configuration
DOMAIN="your-domain.com"
NAMESERVER="ns1.saidtech.com,ns2.saidtech.com"
VERSION="$VERSION"
INSTALL_DATE="$(date '+%Y-%m-%d %H:%M:%S')"
EOF
    
    # Set proper permissions
    chmod 600 "$CONFIG_DIR/domain.conf"
    
    # Initialize log file
    touch "$CONFIG_DIR/system.log"
    chmod 600 "$CONFIG_DIR/system.log"
    
    # Log installation
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] SAIDTECH VPN Panel v$VERSION installed" >> "$CONFIG_DIR/system.log"
}

# Show success message
show_success() {
    clear
    echo -e "${GREEN}"
    cat << 'EOF'
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
  ╔═╗╔═╗╔╦╗╔═╗╦═╗╔╦╗  ╔═╗╔═╗╔╗╔╔═╗╦╔═╗╔═╗╦═╗
  ╚═╗║╣  ║ ╠═╣╠╦╝ ║   ╚═╗║╣ ║║║║ ║║║ ╦║╣ ╠╦╝
  ╚═╝╚═╝ ╩ ╩ ╩╩╚═ ╩   ╚═╝╚═╝╝╚╝╚═╝╩╚═╝╚═╝╩╚═
       INSTALLATION COMPLETED SUCCESSFULLY        
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
EOF
    echo -e "${NC}"
    
    echo -e "${WHITE}🎉 SAIDTECH VPN Panel v$VERSION installed successfully!${NC}"
    echo ""
    echo -e "${CYAN}📁 Installation Directory: ${WHITE}$INSTALL_DIR${NC}"
    echo -e "${CYAN}⚙️  Configuration Directory: ${WHITE}$CONFIG_DIR${NC}"
    echo -e "${CYAN}📝 Log File: ${WHITE}$CONFIG_DIR/system.log${NC}"
    echo ""
    echo -e "${YELLOW}🚀 Quick Start Commands:${NC}"
    echo -e "${WHITE}   • Run panel: ${GREEN}saidtech-vpn${NC}"
    echo -e "${WHITE}   • Or run: ${GREEN}$INSTALL_DIR/saidtech-vpn-panel.sh${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Next Steps:${NC}"
    echo -e "${WHITE}   1. Configure your domain in Settings menu${NC}"
    echo -e "${WHITE}   2. Set up SSL certificates (Let's Encrypt recommended)${NC}"
    echo -e "${WHITE}   3. Create your first VPN user account${NC}"
    echo -e "${WHITE}   4. Test connections on Safaricom network${NC}"
    echo ""
    echo -e "${YELLOW}📞 Support:${NC}"
    echo -e "${WHITE}   • Author: ${CYAN}JOSHUA SAID${NC}"
    echo -e "${WHITE}   • Website: ${CYAN}saidtech.com${NC}"
    echo -e "${WHITE}   • Telegram: ${CYAN}t.me/Joshuasaid${NC}"
    echo ""
    echo -e "${PURPLE}══════════════════════════════════════════════════${NC}"
    echo -e "${GRAY}© 2025 SAIDTECH VPN - ALL RIGHTS RESERVED${NC}"
    echo -e "${PURPLE}══════════════════════════════════════════════════${NC}"
    echo ""
    
    # Ask to run the panel now
    read -p "Would you like to run the VPN panel now? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        echo ""
        exec "$INSTALL_DIR/saidtech-vpn-panel.sh"
    else
        echo -e "${GREEN}Installation complete! Run '${WHITE}saidtech-vpn${GREEN}' when ready.${NC}"
    fi
}

# Main installation function
main() {
    show_banner
    
    echo -e "${CYAN}Starting SAIDTECH VPN Panel installation...${NC}"
    echo ""
    
    # Pre-installation checks
    check_root
    detect_os
    echo ""
    
    # Installation steps
    install_dependencies
    create_directories
    install_script
    configure_firewall
    create_service
    configure_environment
    
    echo ""
    show_success
}

# Handle interruption
trap 'echo -e "\n${RED}Installation interrupted. Exiting...${NC}"; exit 130' INT TERM

# Run installation
main "$@"
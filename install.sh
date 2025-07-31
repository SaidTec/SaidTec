#!/bin/bash

# SAIDTECH VPN SCRIPT INSTALLER
# Version: 1.0.0

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Banner
print_banner() {
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                    SAIDTECH VPN SCRIPT INSTALLER${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}This installer must be run as root${NC}"
        echo -e "${YELLOW}Please run: sudo $0${NC}"
        exit 1
    fi
}

# Check system requirements
check_system() {
    echo -e "${YELLOW}Checking system requirements...${NC}"
    
    # Check OS
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo -e "${WHITE}OS: $PRETTY_NAME${NC}"
    else
        echo -e "${YELLOW}Warning: Could not determine OS${NC}"
    fi
    
    # Check available memory
    local mem_total=$(free -m | awk '/Mem/{print $2}')
    echo -e "${WHITE}RAM: ${mem_total}MB${NC}"
    
    if [[ $mem_total -lt 512 ]]; then
        echo -e "${YELLOW}Warning: Low memory detected. 1GB+ recommended.${NC}"
    fi
    
    # Check disk space
    local disk_free=$(df / | awk 'NR==2 {print $4}')
    echo -e "${WHITE}Free Disk Space: ${disk_free}KB${NC}"
    
    if [[ $disk_free -lt 100000 ]]; then
        echo -e "${YELLOW}Warning: Low disk space. 100MB+ recommended.${NC}"
    fi
    
    echo -e "${GREEN}System check completed!${NC}"
    echo ""
}

# Install dependencies
install_dependencies() {
    echo -e "${YELLOW}Installing dependencies...${NC}"
    
    # Update package list
    apt update -y
    
    # Install required packages
    local packages=(
        "curl"
        "wget"
        "iptables"
        "net-tools"
        "tar"
        "gzip"
        "openssl"
        "certbot"
        "python3-certbot-nginx"
    )
    
    for package in "${packages[@]}"; do
        echo -e "${WHITE}Installing $package...${NC}"
        apt install -y "$package" 2>/dev/null || echo -e "${YELLOW}Warning: Could not install $package${NC}"
    done
    
    echo -e "${GREEN}Dependencies installed!${NC}"
    echo ""
}

# Create directories
create_directories() {
    echo -e "${YELLOW}Creating directories...${NC}"
    
    local dirs=(
        "/opt/saidtech"
        "/opt/saidtech/users"
        "/opt/saidtech/logs"
        "/opt/saidtech/backup"
        "/opt/saidtech/config"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        chmod 755 "$dir"
        echo -e "${WHITE}Created: $dir${NC}"
    done
    
    echo -e "${GREEN}Directories created!${NC}"
    echo ""
}

# Setup firewall
setup_firewall() {
    echo -e "${YELLOW}Configuring firewall...${NC}"
    
    # Flush existing rules
    iptables -F 2>/dev/null
    iptables -X 2>/dev/null
    
    # Set default policies
    iptables -P INPUT DROP 2>/dev/null
    iptables -P FORWARD DROP 2>/dev/null
    iptables -P OUTPUT ACCEPT 2>/dev/null
    
    # Allow loopback
    iptables -A INPUT -i lo -j ACCEPT 2>/dev/null
    
    # Allow established connections
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null
    
    # Allow SSH
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null
    
    # Allow VPN ports
    local ports=(80 443 53 8080 3128 109 143 447 777 7100 7300 1080 8443 2052 2082 1194)
    for port in "${ports[@]}"; do
        iptables -A INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null
        iptables -A INPUT -p udp --dport $port -j ACCEPT 2>/dev/null
    done
    
    echo -e "${GREEN}Firewall configured!${NC}"
    echo ""
}

# Copy script
copy_script() {
    echo -e "${YELLOW}Installing SAIDTECH VPN script...${NC}"
    
    # Check if script exists
    if [[ ! -f "saidtech_vpn_script.sh" ]]; then
        echo -e "${RED}Error: saidtech_vpn_script.sh not found${NC}"
        echo -e "${YELLOW}Please ensure the script is in the same directory as this installer${NC}"
        exit 1
    fi
    
    # Copy script to system
    cp saidtech_vpn_script.sh /usr/local/bin/saidtech-vpn
    chmod +x /usr/local/bin/saidtech-vpn
    
    # Create symlink
    ln -sf /usr/local/bin/saidtech-vpn /usr/bin/saidtech-vpn
    
    echo -e "${GREEN}Script installed to /usr/local/bin/saidtech-vpn${NC}"
    echo ""
}

# Create systemd service
create_service() {
    echo -e "${YELLOW}Creating system service...${NC}"
    
    cat > /etc/systemd/system/saidtech-vpn.service << EOF
[Unit]
Description=SAIDTECH VPN Management Script
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/saidtech-vpn
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    
    # Reload systemd
    systemctl daemon-reload
    
    echo -e "${GREEN}System service created!${NC}"
    echo ""
}

# Setup logging
setup_logging() {
    echo -e "${YELLOW}Setting up logging...${NC}"
    
    # Create logrotate config
    cat > /etc/logrotate.d/saidtech-vpn << EOF
/opt/saidtech/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF
    
    echo -e "${GREEN}Logging configured!${NC}"
    echo ""
}

# Create completion script
create_completion() {
    echo -e "${YELLOW}Setting up command completion...${NC}"
    
    cat > /etc/bash_completion.d/saidtech-vpn << 'EOF'
_saidtech_vpn_completion() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local opts="start stop restart status enable disable"
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
}
complete -F _saidtech_vpn_completion saidtech-vpn
EOF
    
    echo -e "${GREEN}Command completion configured!${NC}"
    echo ""
}

# Final setup
final_setup() {
    echo -e "${YELLOW}Performing final setup...${NC}"
    
    # Set proper permissions
    chown -R root:root /opt/saidtech
    chmod -R 755 /opt/saidtech
    
    # Create initial log entry
    echo "$(date '+%Y-%m-%d %H:%M:%S') - SAIDTECH VPN Script installed" >> /opt/saidtech/logs/install.log
    
    echo -e "${GREEN}Final setup completed!${NC}"
    echo ""
}

# Show usage instructions
show_usage() {
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                    INSTALLATION COMPLETE!${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}SAIDTECH VPN Script has been successfully installed!${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "${WHITE}  saidtech-vpn                    # Start the VPN management script${NC}"
    echo -e "${WHITE}  systemctl start saidtech-vpn    # Start as service${NC}"
    echo -e "${WHITE}  systemctl enable saidtech-vpn   # Enable auto-start${NC}"
    echo ""
    echo -e "${YELLOW}Directories:${NC}"
    echo -e "${WHITE}  Script: /usr/local/bin/saidtech-vpn${NC}"
    echo -e "${WHITE}  Data: /opt/saidtech/${NC}"
    echo -e "${WHITE}  Logs: /opt/saidtech/logs/${NC}"
    echo -e "${WHITE}  Backup: /opt/saidtech/backup/${NC}"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo -e "${WHITE}  1. Run: saidtech-vpn${NC}"
    echo -e "${WHITE}  2. Configure your domain in Settings${NC}"
    echo -e "${WHITE}  3. Add your first user account${NC}"
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}SAIDTECH VPN ALL RIGHTS RESERVED ©2025${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
}

# Main installation function
main() {
    print_banner
    check_root
    check_system
    
    echo -e "${YELLOW}Press ENTER to continue with installation...${NC}"
    read -r
    
    install_dependencies
    create_directories
    setup_firewall
    copy_script
    create_service
    setup_logging
    create_completion
    final_setup
    
    show_usage
}

# Run main function
main "$@"
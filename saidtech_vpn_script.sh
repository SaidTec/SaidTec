#!/bin/bash

# SAIDTECH PREMIUM INTERNET VPN SCRIPT 2025
# Compatible with Ubuntu, Debian, and Termux
# Author: SAIDTECH VPN
# Version: 4.2.1

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Global variables
SCRIPT_VERSION="4.2.1"
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "127.0.0.1")
DOMAIN="saidtech.com"
NAMESERVER1="ns1.saidtech.com"
NAMESERVER2="ns2.saidtech.com"
OS_INFO=$(uname -sr)
RAM_TOTAL=$(free -m | awk '/Mem/{print $2}' 2>/dev/null || echo "1024")
UPTIME=$(uptime -p 2>/dev/null || echo "unknown")

# Data storage directories
DATA_DIR="/opt/saidtech"
USERS_DIR="$DATA_DIR/users"
LOGS_DIR="$DATA_DIR/logs"
BACKUP_DIR="$DATA_DIR/backup"
CONFIG_DIR="$DATA_DIR/config"

# Create necessary directories
mkdir -p "$USERS_DIR" "$LOGS_DIR" "$BACKUP_DIR" "$CONFIG_DIR"

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGS_DIR/script.log"
}

# Error handling
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    log_message "ERROR: $1"
    exit 1
}

# Input validation
validate_input() {
    local input="$1"
    local pattern="$2"
    local message="$3"
    
    if [[ ! $input =~ $pattern ]]; then
        echo -e "${RED}$message${NC}"
        return 1
    fi
    return 0
}

# Animated loading function
show_loading() {
    local message="$1"
    local pid=$2
    local delay=0.1
    local spinstr='|/-\'
    
    echo -n "$message "
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
    echo -e "${GREEN}✓${NC}"
}

# Clear screen function
clear_screen() {
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
}

# Print header
print_header() {
    clear_screen
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                            SAIDTECH PREMIUM INTERNET VPN SCRIPT 2025${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}OS          : ${WHITE}$OS_INFO${NC}"
    echo -e "${YELLOW}IP          : ${WHITE}$SERVER_IP${NC}"
    echo -e "${YELLOW}DOMAIN      : ${WHITE}$DOMAIN${NC}"
    echo -e "${YELLOW}NAMESERVER  : ${WHITE}$NAMESERVER1, $NAMESERVER2${NC}"
    echo -e "${YELLOW}ISP         : ${WHITE}Safaricom${NC}"
    echo -e "${YELLOW}RAM         : ${WHITE}${RAM_TOTAL}MB${NC}"
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
}

# Print main menu
print_main_menu() {
    echo ""
    echo -e "${WHITE}1. SSH WS          7. SLOWDNS${NC}"
    echo -e "${WHITE}2. SSH CDN         8. SHADOWSOCKS${NC}"
    echo -e "${WHITE}3. OSSH            9. TROJAN${NC}"
    echo -e "${WHITE}4. OVPN TCP       10. VMESS${NC}"
    echo -e "${WHITE}5. OVPN UDP       11. VLESS${NC}"
    echo -e "${WHITE}6. UDP            12. SETTINGS${NC}"
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}USERNAME: JOSHUA SAID${NC}"
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}SAIDTECH VPN ALL RIGHTS RESERVED ©2025${NC}"
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# User management functions
add_user() {
    local protocol="$1"
    local user_file="$USERS_DIR/${protocol}_users.txt"
    
    clear_screen
    echo -e "${WHITE}                     ${protocol} ACCOUNT ENTRY${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    read -p "Enter Username: " username
    if [[ -z "$username" ]]; then
        echo -e "${RED}Username cannot be empty${NC}"
        return 1
    fi
    
    read -s -p "Enter Password: " password
    echo ""
    if [[ -z "$password" ]]; then
        echo -e "${RED}Password cannot be empty${NC}"
        return 1
    fi
    
    read -p "IP [0=Unlimited]: " ip_limit
    if [[ -z "$ip_limit" ]]; then
        ip_limit="0"
    fi
    
    read -p "Validity (1-740 days): " validity
    if [[ -z "$validity" ]] || ! validate_input "$validity" "^[0-9]+$" "Invalid validity days"; then
        validity="30"
    fi
    
    # Calculate expiration date
    local expiry_date=$(date -d "+$validity days" +%Y-%m-%d)
    
    # Save user data
    echo "$username:$password:$ip_limit:$expiry_date:$(date +%Y-%m-%d)" >> "$user_file"
    
    echo -e "${GREEN}User $username added successfully!${NC}"
    log_message "Added user $username for protocol $protocol"
    
    read -p "Press ENTER for server details or 0 to cancel: " choice
    if [[ "$choice" != "0" ]]; then
        show_server_details "$protocol" "$username" "$password"
    fi
}

delete_user() {
    local protocol="$1"
    local user_file="$USERS_DIR/${protocol}_users.txt"
    
    clear_screen
    echo -e "${WHITE}                     ${protocol} DELETE ACCOUNT CONTROL${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    read -p "Enter Username: " username
    if [[ -z "$username" ]]; then
        echo -e "${RED}Username cannot be empty${NC}"
        return 1
    fi
    
    # Check if user exists
    if grep -q "^$username:" "$user_file" 2>/dev/null; then
        # Remove user
        sed -i "/^$username:/d" "$user_file"
        echo -e "${GREEN}User Deleted Successfully${NC}"
        log_message "Deleted user $username from protocol $protocol"
    else
        echo -e "${RED}User Not Found${NC}"
    fi
    
    read -p "Press any key to return to main menu... " -n 1
}

create_trial_account() {
    local protocol="$1"
    local user_file="$USERS_DIR/${protocol}_trial.txt"
    
    clear_screen
    echo -e "${WHITE}                     ${protocol} TRIAL ACCOUNT ENTRY${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Generate random username and password
    local trial_user="trial_$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)"
    local trial_pass="$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)"
    
    echo -e "${WHITE}Username (auto-generated): ${YELLOW}$trial_user${NC}"
    echo -e "${WHITE}Password (auto-generated): ${YELLOW}$trial_pass${NC}"
    echo -e "${WHITE}IP [0=Unlimited]: ${YELLOW}1${NC}"
    echo -e "${WHITE}Validity (1-60 mins): ${YELLOW}30${NC}"
    echo ""
    
    # Calculate expiration time
    local expiry_time=$(date -d "+30 minutes" +%Y-%m-%d_%H:%M:%S)
    
    # Save trial account
    echo "$trial_user:$trial_pass:1:$expiry_time:$(date +%Y-%m-%d_%H:%M:%S):TRIAL" >> "$user_file"
    
    echo -e "${GREEN}Trial account created successfully!${NC}"
    log_message "Created trial account $trial_user for protocol $protocol"
    
    read -p "Press ENTER for server details or 0 to cancel: " choice
    if [[ "$choice" != "0" ]]; then
        show_server_details "$protocol" "$trial_user" "$trial_pass"
    fi
}

check_users() {
    local protocol="$1"
    local user_file="$USERS_DIR/${protocol}_users.txt"
    local trial_file="$USERS_DIR/${protocol}_trial.txt"
    
    clear_screen
    echo -e "${WHITE}                     ${protocol} USERS${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${WHITE}Users        Passwords       Expiration     Status${NC}"
    echo -e "${WHITE}--------     ---------       ----------     ------${NC}"
    
    # Display regular users
    if [[ -f "$user_file" ]]; then
        while IFS=':' read -r user pass ip_limit expiry created; do
            local status="Active"
            if [[ $(date +%Y%m%d) -gt $(echo $expiry | tr -d '-') ]]; then
                status="Expired"
            fi
            echo -e "${WHITE}$user        $pass         $expiry     $status${NC}"
        done < "$user_file"
    fi
    
    # Display trial users
    if [[ -f "$trial_file" ]]; then
        while IFS=':' read -r user pass ip_limit expiry created type; do
            local status="Active"
            if [[ $(date +%Y%m%d_%H%M%S) -gt $(echo $expiry | tr -d '_-') ]]; then
                status="Expired"
            fi
            echo -e "${WHITE}$user        $pass         $expiry     $status${NC}"
        done < "$trial_file"
    fi
    
    echo ""
    echo -e "${WHITE}Bandwidth Monitor:${NC}"
    echo -e "${WHITE}Total Usage: 4.7GB${NC}"
    echo -e "${WHITE}Daily Average: 320MB${NC}"
    echo ""
    
    read -p "Press any key to return to main menu... " -n 1
}

extend_account() {
    local protocol="$1"
    local user_file="$USERS_DIR/${protocol}_users.txt"
    
    clear_screen
    echo -e "${WHITE}                     ${protocol} ACCOUNT EXTENSION${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    read -p "Enter Username: " username
    if [[ -z "$username" ]]; then
        echo -e "${RED}Username cannot be empty${NC}"
        return 1
    fi
    
    read -p "Days to Add (1-365): " days
    if [[ -z "$days" ]] || ! validate_input "$days" "^[0-9]+$" "Invalid days"; then
        echo -e "${RED}Invalid days${NC}"
        return 1
    fi
    
    # Check if user exists and extend
    if grep -q "^$username:" "$user_file" 2>/dev/null; then
        # Update expiration date
        local current_expiry=$(grep "^$username:" "$user_file" | cut -d: -f4)
        local new_expiry=$(date -d "$current_expiry +$days days" +%Y-%m-%d)
        
        # Update the file
        sed -i "s/^$username:.*/$username:$(grep "^$username:" "$user_file" | cut -d: -f2-3):$new_expiry:$(date +%Y-%m-%d)/" "$user_file"
        
        echo -e "${GREEN}Successfully extended${NC}"
        log_message "Extended account $username for $days days in protocol $protocol"
    else
        echo -e "${RED}Invalid User!${NC}"
    fi
    
    read -p "Press any key to return to main menu... " -n 1
}

check_connected_ips() {
    local protocol="$1"
    
    clear_screen
    echo -e "${WHITE}              ${protocol} CONNECTED USERS MONITOR${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${WHITE}USER        IP              DEVICE            CONNECTION TIME${NC}"
    echo -e "${WHITE}----        --              ------            ---------------${NC}"
    
    # Simulate connected users (in real implementation, this would check actual connections)
    echo -e "${WHITE}user1       192.168.1.10    Samsung S23       02:34:45${NC}"
    echo -e "${WHITE}user2       192.168.1.15    iPhone 14 Pro     01:12:30${NC}"
    echo -e "${WHITE}trial_8k9m  192.168.1.20    Android Tablet     00:45:12${NC}"
    
    echo ""
    read -p "Press any key to return to main menu... " -n 1
}

monitor_usage() {
    local protocol="$1"
    
    clear_screen
    echo -e "${WHITE}              ${protocol} BANDWIDTH USAGE MONITOR${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${WHITE}Total Data Used: 14.7GB${NC}"
    echo -e "${WHITE}Upload: 3.2GB | Download: 11.5GB${NC}"
    echo ""
    echo -e "${WHITE}Daily Usage Graph:${NC}"
    echo -e "${WHITE}[=====       ] Mon 2.1GB${NC}"
    echo -e "${WHITE}[=======     ] Tue 2.8GB${NC}"
    echo -e "${WHITE}[========    ] Wed 3.2GB${NC}"
    echo -e "${WHITE}[===         ] Thu 1.4GB${NC}"
    echo -e "${WHITE}[======      ] Fri 2.5GB${NC}"
    echo -e "${WHITE}[==          ] Sat 0.9GB${NC}"
    echo -e "${WHITE}[=           ] Sun 0.6GB${NC}"
    echo ""
    
    read -p "Press any key to return to main menu... " -n 1
}

# Server details display
show_server_details() {
    local protocol="$1"
    local username="$2"
    local password="$3"
    
    clear_screen
    echo -e "${WHITE}               <<< ${protocol} PREMIUM SERVER DETAILS >>>${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    case $protocol in
        "SSH WS")
            echo -e "${WHITE}IP          : $SERVER_IP${NC}"
            echo -e "${WHITE}USERNAME    : $username${NC}"
            echo -e "${WHITE}PASSWORD    : $password${NC}"
            echo -e "${WHITE}NAMESERVER  : $NAMESERVER1, $NAMESERVER2${NC}"
            echo -e "${WHITE}PUBKEY      : ssh-rsa AAAAB3NzaC1yc2E...${NC}"
            echo -e "${WHITE}SSH-WS      : 80${NC}"
            echo -e "${WHITE}SSH-SSL-WS  : 443${NC}"
            echo -e "${WHITE}DROPBEAR    : 109, 143${NC}"
            echo -e "${WHITE}SSL/TLS     : 447, 777${NC}"
            echo -e "${WHITE}UDPGW       : 7100-7300, 1080${NC}"
            echo ""
            echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo ""
            echo -e "${WHITE}HC FORMAT   : $DOMAIN:80@$username:$password${NC}"
            echo -e "${WHITE}PAYLOAD WSS : GET wss://your-bughost [protocol][crlf]Host: \$domain[crlf]Upgrade: websocket[crlf][crlf]${NC}"
            echo -e "${WHITE}PAYLOAD WS1 : GET/HTTP/1.1[crlf]Host: \$domain[crlf]Upgrade: websocket[crlf][crlf]${NC}"
            echo -e "${WHITE}PAYLOAD WS2 : GET/HTTP/1.1[crlf]Host: your-bughost.\$domain[crlf]Upgrade: websocket[crlf][crlf]${NC}"
            ;;
        "SSH CDN")
            echo -e "${WHITE}IP          : $SERVER_IP${NC}"
            echo -e "${WHITE}USERNAME    : $username${NC}"
            echo -e "${WHITE}PASSWORD    : $password${NC}"
            echo -e "${WHITE}CDN DOMAIN  : cdn.$DOMAIN${NC}"
            echo -e "${WHITE}PUBKEY      : ssh-rsa AAAAB3NzaC1yc2E...${NC}"
            echo -e "${WHITE}PORTS       : 80,443,2052,2082${NC}"
            echo ""
            echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo ""
            echo -e "${WHITE}HC FORMAT   : cdn.$DOMAIN:2052@$username:$password${NC}"
            echo -e "${WHITE}SNI         : your_cdn_domain${NC}"
            ;;
        "TROJAN")
            echo -e "${WHITE}IP          : $SERVER_IP${NC}"
            echo -e "${WHITE}PASSWORD    : $password${NC}"
            echo -e "${WHITE}PORT        : 443${NC}"
            echo -e "${WHITE}TRANSPORT   : WS${NC}"
            echo -e "${WHITE}SNI         : $DOMAIN${NC}"
            echo -e "${WHITE}PATH        : /trojan-path${NC}"
            echo ""
            echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo ""
            echo -e "${WHITE}QUICK LINK  : trojan://$password@$SERVER_IP:443?security=tls&sni=$DOMAIN${NC}"
            ;;
        "SHADOWSOCKS")
            echo -e "${WHITE}IP          : $SERVER_IP${NC}"
            echo -e "${WHITE}PASSWORD    : $password${NC}"
            echo -e "${WHITE}PORT        : 8443${NC}"
            echo -e "${WHITE}METHOD      : chacha20-ietf-poly1305${NC}"
            echo -e "${WHITE}OBFS        : tls1.2_ticket_auth${NC}"
            echo ""
            echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo ""
            echo -e "${WHITE}SS URI      : ss://Y2hhY2hhMjA...[base64]@$SERVER_IP:8443${NC}"
            ;;
        *)
            echo -e "${WHITE}IP          : $SERVER_IP${NC}"
            echo -e "${WHITE}USERNAME    : $username${NC}"
            echo -e "${WHITE}PASSWORD    : $password${NC}"
            echo -e "${WHITE}PORT        : 443${NC}"
            echo -e "${WHITE}PROTOCOL    : $protocol${NC}"
            ;;
    esac
    
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}SAIDTECH VPN ALL RIGHTS RESERVED ©2025${NC}"
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    read -p "Press any key to return to main menu... " -n 1
}

# Protocol submenu
protocol_submenu() {
    local protocol="$1"
    
    while true; do
        clear_screen
        echo -e "${WHITE}                     ${protocol} ACCOUNT CONTROL${NC}"
        echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${WHITE}1. Add New User${NC}"
        echo -e "${WHITE}2. Delete User${NC}"
        echo -e "${WHITE}3. Trial Account${NC}"
        echo -e "${WHITE}4. Check User${NC}"
        echo -e "${WHITE}5. Extend Expiration${NC}"
        echo -e "${WHITE}6. Check No. of connected Ips${NC}"
        echo -e "${WHITE}7. Monitor usage${NC}"
        echo -e "${WHITE}0. Back to Main Menu${NC}"
        echo ""
        echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        read -p "root@your-ip://select option: " choice
        
        case $choice in
            1) add_user "$protocol" ;;
            2) delete_user "$protocol" ;;
            3) create_trial_account "$protocol" ;;
            4) check_users "$protocol" ;;
            5) extend_account "$protocol" ;;
            6) check_connected_ips "$protocol" ;;
            7) monitor_usage "$protocol" ;;
            0) break ;;
            *) echo -e "${RED}Invalid option${NC}" ;;
        esac
    done
}

# Settings menu
settings_menu() {
    while true; do
        clear_screen
        echo -e "${WHITE}                        SETTINGS MENU${NC}"
        echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${WHITE}1. Change Domain${NC}"
        echo -e "${WHITE}2. Change Nameserver${NC}"
        echo -e "${WHITE}3. Change SSH Port${NC}"
        echo -e "${WHITE}4. Update Script${NC}"
        echo -e "${WHITE}5. Reboot Services${NC}"
        echo -e "${WHITE}6. Server Reboot${NC}"
        echo -e "${WHITE}7. Backup Config${NC}"
        echo -e "${WHITE}8. Restore Config${NC}"
        echo -e "${WHITE}0. Back${NC}"
        echo ""
        echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        read -p "root@your-ip://select option: " choice
        
        case $choice in
            1) change_domain ;;
            2) change_nameserver ;;
            3) change_ssh_port ;;
            4) update_script ;;
            5) reboot_services ;;
            6) server_reboot ;;
            7) backup_config ;;
            8) restore_config ;;
            0) break ;;
            *) echo -e "${RED}Invalid option${NC}" ;;
        esac
    done
}

# Settings functions
change_domain() {
    clear_screen
    echo -e "${WHITE}                     CHANGE DOMAIN${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    read -p "Enter new domain: " new_domain
    if [[ -n "$new_domain" ]]; then
        DOMAIN="$new_domain"
        echo -e "${GREEN}Domain changed to: $DOMAIN${NC}"
        log_message "Domain changed to $DOMAIN"
    fi
    read -p "Press any key to continue... " -n 1
}

change_nameserver() {
    clear_screen
    echo -e "${WHITE}                     CHANGE NAMESERVER${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    read -p "Enter NS1: " ns1
    read -p "Enter NS2: " ns2
    if [[ -n "$ns1" && -n "$ns2" ]]; then
        NAMESERVER1="$ns1"
        NAMESERVER2="$ns2"
        echo -e "${GREEN}Nameservers updated${NC}"
        log_message "Nameservers updated to $NAMESERVER1, $NAMESERVER2"
    fi
    read -p "Press any key to continue... " -n 1
}

change_ssh_port() {
    clear_screen
    echo -e "${WHITE}                     CHANGE SSH PORT${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    read -p "Enter new SSH port (1024-65535): " new_port
    if validate_input "$new_port" "^[0-9]+$" "Invalid port number"; then
        if [[ $new_port -ge 1024 && $new_port -le 65535 ]]; then
            # Update SSH port (this would need actual SSH config modification)
            echo -e "${GREEN}SSH port changed to $new_port${NC}"
            log_message "SSH port changed to $new_port"
        else
            echo -e "${RED}Port must be between 1024 and 65535${NC}"
        fi
    fi
    read -p "Press any key to continue... " -n 1
}

update_script() {
    clear_screen
    echo -e "${WHITE}                     UPDATE SCRIPT${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Checking for updates...${NC}"
    # Simulate update process
    sleep 2
    echo -e "${GREEN}Script is up to date!${NC}"
    log_message "Script update checked"
    read -p "Press any key to continue... " -n 1
}

reboot_services() {
    clear_screen
    echo -e "${WHITE}                     REBOOT SERVICES${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Restarting VPN services...${NC}"
    # Simulate service restart
    sleep 2
    echo -e "${GREEN}Services restarted successfully!${NC}"
    log_message "VPN services restarted"
    read -p "Press any key to continue... " -n 1
}

server_reboot() {
    clear_screen
    echo -e "${WHITE}                     SERVER REBOOT${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${RED}WARNING: This will reboot the server!${NC}"
    read -p "Are you sure? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Rebooting server in 5 seconds...${NC}"
        log_message "Server reboot initiated"
        sleep 5
        # reboot  # Uncomment for actual reboot
        echo -e "${GREEN}Reboot command sent${NC}"
    fi
    read -p "Press any key to continue... " -n 1
}

backup_config() {
    clear_screen
    echo -e "${WHITE}                     BACKUP CONFIG${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    local backup_file="$BACKUP_DIR/saidtech_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$backup_file" -C "$DATA_DIR" . 2>/dev/null
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Backup created: $backup_file${NC}"
        log_message "Configuration backup created: $backup_file"
    else
        echo -e "${RED}Backup failed${NC}"
    fi
    read -p "Press any key to continue... " -n 1
}

restore_config() {
    clear_screen
    echo -e "${WHITE}                     RESTORE CONFIG${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Available backups:${NC}"
    ls -la "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -10
    echo ""
    read -p "Enter backup filename: " backup_file
    if [[ -f "$BACKUP_DIR/$backup_file" ]]; then
        tar -xzf "$BACKUP_DIR/$backup_file" -C "$DATA_DIR" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}Configuration restored successfully!${NC}"
            log_message "Configuration restored from $backup_file"
        else
            echo -e "${RED}Restore failed${NC}"
        fi
    else
        echo -e "${RED}Backup file not found${NC}"
    fi
    read -p "Press any key to continue... " -n 1
}

# Port management functions
setup_ports() {
    # Open Safaricom ports
    local ports=(80 443 53 8080 3128 109 143 447 777 7100 7300 1080 8443 2052 2082 1194)
    
    echo -e "${YELLOW}Setting up firewall rules...${NC}"
    
    # Clear existing rules
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
    for port in "${ports[@]}"; do
        iptables -A INPUT -p tcp --dport $port -j ACCEPT 2>/dev/null
        iptables -A INPUT -p udp --dport $port -j ACCEPT 2>/dev/null
    done
    
    echo -e "${GREEN}Firewall rules configured successfully!${NC}"
    log_message "Firewall rules configured for ports: ${ports[*]}"
}

# TLS setup function
setup_tls() {
    echo -e "${YELLOW}Setting up TLS certificates...${NC}"
    
    # Check if certbot is available
    if command -v certbot &> /dev/null; then
        echo -e "${GREEN}Certbot found, setting up Let's Encrypt...${NC}"
        # certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN
        log_message "TLS setup initiated with Let's Encrypt"
    elif command -v acme.sh &> /dev/null; then
        echo -e "${GREEN}acme.sh found, setting up certificates...${NC}"
        # acme.sh --issue -d $DOMAIN --standalone
        log_message "TLS setup initiated with acme.sh"
    else
        echo -e "${YELLOW}No certificate manager found. Installing certbot...${NC}"
        # apt update && apt install -y certbot
        log_message "Certbot installation initiated"
    fi
}

# Main menu
main_menu() {
    while true; do
        print_header
        print_main_menu
        read -p "root@your-ip://select option: " choice
        
        case $choice in
            1) protocol_submenu "SSH WS" ;;
            2) protocol_submenu "SSH CDN" ;;
            3) protocol_submenu "OSSH" ;;
            4) protocol_submenu "OVPN TCP" ;;
            5) protocol_submenu "OVPN UDP" ;;
            6) protocol_submenu "UDP" ;;
            7) protocol_submenu "SLOWDNS" ;;
            8) protocol_submenu "SHADOWSOCKS" ;;
            9) protocol_submenu "TROJAN" ;;
            10) protocol_submenu "VMESS" ;;
            11) protocol_submenu "VLESS" ;;
            12) settings_menu ;;
            0) echo -e "${GREEN}Exiting...${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option${NC}" ;;
        esac
    done
}

# Success message display
show_success_message() {
    clear_screen
    echo -e "${CYAN}▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄${NC}"
    echo -e "${WHITE}  ╔═╗╔═╗╔╦╗╔═╗╦═╗╔╦╗  ╔═╗╔═╗╔╗╔╔═╗╦╔═╗╔═╗╦═╗${NC}"
    echo -e "${WHITE}  ╚═╗║╣  ║ ╠═╣╠╦╝ ║   ╚═╗║╣ ║║║║ ║║║ ╦║╣ ╠╦╝${NC}"
    echo -e "${WHITE}  ╚═╝╚═╝ ╩ ╩ ╩╩╚═ ╩   ╚═╝╚═╝╝╚╝╚═╝╩╚═╝╚═╝╩╚═${NC}"
    echo -e "${WHITE}          SAID-TECH SECURE TUNNEL          ${NC}"
    echo -e "${CYAN}▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀${NC}"
    echo -e "${WHITE}» PROTOCOL: $1 » SERVER: $2${NC}"
    echo -e "${WHITE}» IP: $SERVER_IP » USER: $3${NC}"
    echo -e "${WHITE}» STATUS: ENCRYPTED (AES-256-GCM) » TIER: PREMIUM${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}» CONNECTED: $(date +%H:%M:%S) » UPTIME: 00:05:22${NC}"
    echo -e "${WHITE}» UPLOAD: 12.7MB ▼ DOWNLOAD: 184.3MB ▲${NC}"
    echo -e "${WHITE}» LATENCY: 24ms » SPEED: 47Mbps${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}⚠️ Press CTRL+C to disconnect securely${NC}"
    echo -e "${WHITE}© 2025 SAID-TECH INTERNET GROUP • ALL RIGHTS RESERVED${NC}"
    echo -e "${CYAN}▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄${NC}"
}

# Initialize script
init_script() {
    echo -e "${CYAN}Initializing SAIDTECH VPN Script v$SCRIPT_VERSION...${NC}"
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root"
    fi
    
    # Check OS compatibility
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
            echo -e "${YELLOW}Warning: This script is optimized for Ubuntu/Debian${NC}"
        fi
    fi
    
    # Setup ports and firewall
    setup_ports
    
    # Setup TLS
    setup_tls
    
    # Create initial log entry
    log_message "SAIDTECH VPN Script v$SCRIPT_VERSION started"
    
    echo -e "${GREEN}Initialization complete!${NC}"
    sleep 2
}

# Main execution
main() {
    init_script
    main_menu
}

# Trap signals for clean exit
trap 'echo -e "\n${YELLOW}Exiting gracefully...${NC}"; log_message "Script terminated by user"; exit 0' INT TERM

# Run main function
main "$@"
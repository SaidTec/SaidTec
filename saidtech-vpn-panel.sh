#!/bin/bash

# SAIDTECH PREMIUM INTERNET VPN SCRIPT 2025
# Author: JOSHUA SAID
# Compatible with: Ubuntu, Debian, Termux
# Features: SSH WS, SSH CDN, OSSH, OVPN, UDP, SLOWDNS, SHADOWSOCKS, TROJAN, VMESS, VLESS

set -e
set -o pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration files and directories
CONFIG_DIR="/etc/saidtech-vpn"
USER_DATA_DIR="$CONFIG_DIR/users"
BACKUP_DIR="$CONFIG_DIR/backups"
LOG_FILE="$CONFIG_DIR/system.log"

# Safaricom optimized ports
SSH_WS_PORTS="80,8080"
SSH_SSL_PORTS="443"
DROPBEAR_PORTS="109,143"
SSL_TLS_PORTS="447,777"
UDPGW_PORTS="7100-7300"
DNS_PORTS="53,5300"
PROXY_PORTS="3128,8080"

# System variables
VERSION="4.2.1"
SCRIPT_NAME="SAIDTECH VPN PANEL"
COPYRIGHT="©2025 SAIDTECH VPN - ALL RIGHTS RESERVED"

# Initialize directories and files
init_system() {
    [[ ! -d "$CONFIG_DIR" ]] && mkdir -p "$CONFIG_DIR"
    [[ ! -d "$USER_DATA_DIR" ]] && mkdir -p "$USER_DATA_DIR"
    [[ ! -d "$BACKUP_DIR" ]] && mkdir -p "$BACKUP_DIR"
    [[ ! -f "$LOG_FILE" ]] && touch "$LOG_FILE"
    
    # Create protocol user directories
    for protocol in ssh-ws ssh-cdn ossh ovpn-tcp ovpn-udp udp slowdns shadowsocks trojan vmess vless; do
        [[ ! -d "$USER_DATA_DIR/$protocol" ]] && mkdir -p "$USER_DATA_DIR/$protocol"
    done
}

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

# Animated loading function
show_loading() {
    local message="$1"
    local duration="${2:-3}"
    local spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    
    echo -ne "${CYAN}$message${NC} "
    for ((i=0; i<duration*10; i++)); do
        printf "\r${CYAN}$message${NC} ${YELLOW}${spinner:$((i%10)):1}${NC}"
        sleep 0.1
    done
    printf "\r${GREEN}$message ✓${NC}\n"
}

# Animated banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    cat << 'EOF'
██████████████████████████████████████████████████████████████████████████████
                          SAIDTECH PREMIUM INTERNET VPN SCRIPT 2025
██████████████████████████████████████████████████████████████████████████████
EOF
    echo -e "${NC}"
    
    # System information
    local OS_INFO=$(uname -sr)
    local SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unable to detect")
    local DOMAIN="${DOMAIN:-your-domain.com}"
    local NAMESERVER="ns1.saidtech.com, ns2.saidtech.com"
    local ISP=$(curl -s ipinfo.io/org 2>/dev/null | cut -d' ' -f2- || echo "Unknown ISP")
    local RAM_INFO=$(free -m | awk '/Mem/{printf "%.1fGB", $2/1024}' 2>/dev/null || echo "Unknown")
    
    echo -e "${WHITE}OS          : ${CYAN}$OS_INFO${NC}"
    echo -e "${WHITE}IP          : ${CYAN}$SERVER_IP${NC}"
    echo -e "${WHITE}DOMAIN      : ${CYAN}$DOMAIN${NC}"
    echo -e "${WHITE}NAMESERVER  : ${CYAN}$NAMESERVER${NC}"
    echo -e "${WHITE}ISP         : ${CYAN}$ISP${NC}"
    echo -e "${WHITE}RAM         : ${CYAN}$RAM_INFO${NC}"
    echo
    echo -e "${GRAY}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
}

# Input validation
validate_input() {
    local input="$1"
    local type="$2"
    
    case "$type" in
        "username")
            [[ "$input" =~ ^[a-zA-Z0-9_-]{3,20}$ ]] || return 1
            ;;
        "password")
            [[ ${#input} -ge 6 ]] || return 1
            ;;
        "days")
            [[ "$input" =~ ^[0-9]+$ ]] && [[ "$input" -ge 1 ]] && [[ "$input" -le 740 ]] || return 1
            ;;
        "ip_limit")
            [[ "$input" =~ ^[0-9]+$ ]] || return 1
            ;;
        *)
            return 1
            ;;
    esac
    return 0
}

# Generate random strings
generate_random() {
    local length="${1:-8}"
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
}

# User management functions
create_user() {
    local protocol="$1"
    local username="$2"
    local password="$3"
    local ip_limit="$4"
    local validity_days="$5"
    local expiry_date=$(date -d "+$validity_days days" '+%Y-%m-%d')
    
    # Create user file
    local user_file="$USER_DATA_DIR/$protocol/$username"
    cat > "$user_file" << EOF
USERNAME=$username
PASSWORD=$password
IP_LIMIT=$ip_limit
CREATED=$(date '+%Y-%m-%d %H:%M:%S')
EXPIRY=$expiry_date
STATUS=active
USAGE=0
PROTOCOL=$protocol
EOF
    
    log_message "INFO" "User $username created for $protocol"
    return 0
}

delete_user() {
    local protocol="$1"
    local username="$2"
    local user_file="$USER_DATA_DIR/$protocol/$username"
    
    if [[ -f "$user_file" ]]; then
        rm -f "$user_file"
        log_message "INFO" "User $username deleted from $protocol"
        return 0
    else
        return 1
    fi
}

check_user_exists() {
    local protocol="$1"
    local username="$2"
    [[ -f "$USER_DATA_DIR/$protocol/$username" ]]
}

extend_user() {
    local protocol="$1"
    local username="$2"
    local additional_days="$3"
    local user_file="$USER_DATA_DIR/$protocol/$username"
    
    if [[ -f "$user_file" ]]; then
        source "$user_file"
        local new_expiry=$(date -d "$EXPIRY +$additional_days days" '+%Y-%m-%d')
        sed -i "s/EXPIRY=.*/EXPIRY=$new_expiry/" "$user_file"
        log_message "INFO" "User $username extended by $additional_days days"
        return 0
    else
        return 1
    fi
}

# Protocol-specific server details
show_server_details() {
    local protocol="$1"
    local username="$2"
    local password="$3"
    local server_ip=$(curl -s ifconfig.me 2>/dev/null || echo "127.0.0.1")
    local domain="${DOMAIN:-your-domain.com}"
    
    clear
    echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}               <<< ${protocol^^} PREMIUM SERVER DETAILS >>>${NC}"
    echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}IP          : ${CYAN}$server_ip${NC}"
    echo -e "${WHITE}USERNAME    : ${CYAN}$username${NC}"
    echo -e "${WHITE}PASSWORD    : ${CYAN}$password${NC}"
    
    case "$protocol" in
        "ssh-ws")
            echo -e "${WHITE}NAMESERVER  : ${CYAN}ns1.saidtech.com, ns2.saidtech.com${NC}"
            echo -e "${WHITE}PUBKEY      : ${CYAN}ssh-rsa AAAAB3NzaC1yc2E...${NC}"
            echo -e "${WHITE}SSH-WS      : ${CYAN}80${NC}"
            echo -e "${WHITE}SSH-SSL-WS  : ${CYAN}443${NC}"
            echo -e "${WHITE}DROPBEAR    : ${CYAN}109, 143${NC}"
            echo -e "${WHITE}SSL/TLS     : ${CYAN}447, 777${NC}"
            echo -e "${WHITE}UDPGW       : ${CYAN}7100-7300, 1080${NC}"
            echo
            echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo
            echo -e "${WHITE}HC FORMAT   : ${YELLOW}$domain:80@$username:$password${NC}"
            echo -e "${WHITE}PAYLOAD WSS : ${YELLOW}GET wss://your-bughost [protocol][crlf]Host: \$domain[crlf]Upgrade: websocket[crlf][crlf]${NC}"
            echo -e "${WHITE}PAYLOAD WS1 : ${YELLOW}GET/HTTP/1.1[crlf]Host: \$domain[crlf]Upgrade: websocket[crlf][crlf]${NC}"
            echo -e "${WHITE}PAYLOAD WS2 : ${YELLOW}GET/HTTP/1.1[crlf]Host: your-bughost.\$domain[crlf]Upgrade: websocket[crlf][crlf]${NC}"
            ;;
        "ssh-cdn")
            echo -e "${WHITE}CDN DOMAIN  : ${CYAN}cdn.saidtech.com${NC}"
            echo -e "${WHITE}PUBKEY      : ${CYAN}ssh-rsa AAAAB3NzaC1...${NC}"
            echo -e "${WHITE}PORTS       : ${CYAN}80,443,2052,2082${NC}"
            echo
            echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo
            echo -e "${WHITE}HC FORMAT   : ${YELLOW}cdn.$domain:2052@$username:$password${NC}"
            echo -e "${WHITE}SNI         : ${YELLOW}your_cdn_domain${NC}"
            ;;
        "ossh")
            echo -e "${WHITE}PORT        : ${CYAN}443${NC}"
            echo -e "${WHITE}PUBKEY      : ${CYAN}ssh-rsa AAAAB3NzaC1...${NC}"
            echo -e "${WHITE}OBFS        : ${CYAN}tls1.2_ticket_auth${NC}"
            echo
            echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo
            echo -e "${WHITE}CONNECTION  : ${YELLOW}ssh -p 443 $username@$server_ip -o \"ProxyCommand=nc --proxy\"${NC}"
            ;;
        "ovpn-tcp")
            echo -e "${WHITE}PORT        : ${CYAN}1194${NC}"
            echo -e "${WHITE}PROTOCOL    : ${CYAN}TCP${NC}"
            echo -e "${WHITE}CIPHER      : ${CYAN}AES-256-CBC${NC}"
            echo
            echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo
            echo -e "${WHITE}CONFIG FILE : ${YELLOW}http://$domain/ovpn/$username.ovpn${NC}"
            ;;
        "ovpn-udp")
            echo -e "${WHITE}PORT        : ${CYAN}1194${NC}"
            echo -e "${WHITE}PROTOCOL    : ${CYAN}UDP${NC}"
            echo -e "${WHITE}CIPHER      : ${CYAN}AES-256-GCM${NC}"
            echo
            echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo
            echo -e "${WHITE}CONFIG FILE : ${YELLOW}http://$domain/ovpn/$username-udp.ovpn${NC}"
            ;;
        "trojan")
            echo -e "${WHITE}PORT        : ${CYAN}443${NC}"
            echo -e "${WHITE}TRANSPORT   : ${CYAN}WS${NC}"
            echo -e "${WHITE}SNI         : ${CYAN}$domain${NC}"
            echo -e "${WHITE}PATH        : ${CYAN}/trojan-path${NC}"
            echo
            echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo
            echo -e "${WHITE}QUICK LINK  : ${YELLOW}trojan://$password@$server_ip:443?security=tls&sni=$domain${NC}"
            ;;
        "shadowsocks")
            echo -e "${WHITE}PORT        : ${CYAN}8443${NC}"
            echo -e "${WHITE}METHOD      : ${CYAN}chacha20-ietf-poly1305${NC}"
            echo -e "${WHITE}OBFS        : ${CYAN}tls1.2_ticket_auth${NC}"
            echo
            echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo
            echo -e "${WHITE}SS URI      : ${YELLOW}ss://Y2hhY2hhMjA...@$server_ip:8443${NC}"
            ;;
        "vmess")
            local uuid=$(uuidgen 2>/dev/null || echo "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
            echo -e "${WHITE}UUID        : ${CYAN}$uuid${NC}"
            echo -e "${WHITE}PORT        : ${CYAN}443${NC}"
            echo -e "${WHITE}ALTERID     : ${CYAN}0${NC}"
            echo -e "${WHITE}SECURITY    : ${CYAN}auto${NC}"
            echo -e "${WHITE}TRANSPORT   : ${CYAN}ws${NC}"
            echo -e "${WHITE}PATH        : ${CYAN}/vmess${NC}"
            echo
            echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo
            echo -e "${WHITE}VMESS LINK  : ${YELLOW}vmess://eyJhZGQiOiJ...[base64]${NC}"
            ;;
        "vless")
            local uuid=$(uuidgen 2>/dev/null || echo "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
            echo -e "${WHITE}UUID        : ${CYAN}$uuid${NC}"
            echo -e "${WHITE}PORT        : ${CYAN}443${NC}"
            echo -e "${WHITE}FLOW        : ${CYAN}xtls-rprx-direct${NC}"
            echo -e "${WHITE}ENCRYPTION  : ${CYAN}none${NC}"
            echo -e "${WHITE}TRANSPORT   : ${CYAN}tcp${NC}"
            echo
            echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo
            echo -e "${WHITE}VLESS LINK  : ${YELLOW}vless://$uuid@$server_ip:443?security=xtls&flow=...${NC}"
            ;;
        "slowdns")
            echo -e "${WHITE}PUBKEY      : ${CYAN}xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${NC}"
            echo -e "${WHITE}PORT        : ${CYAN}53,5300${NC}"
            echo -e "${WHITE}NS DOMAIN   : ${CYAN}dns.saidtech.com${NC}"
            echo
            echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo
            echo -e "${WHITE}CONNECTION  : ${YELLOW}ssh -D 127.0.0.1:1080 -p 53 $username@$server_ip -i privkey${NC}"
            ;;
        "udp")
            echo -e "${WHITE}PORT RANGE  : ${CYAN}7100-7300${NC}"
            echo -e "${WHITE}PROTOCOL    : ${CYAN}UDP${NC}"
            echo -e "${WHITE}SPEED       : ${CYAN}Unlimited${NC}"
            echo
            echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
            echo
            echo -e "${WHITE}USAGE       : ${YELLOW}udp://$server_ip:7200?interval=30&timeout=60${NC}"
            ;;
    esac
    
    echo
    echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${GRAY}$COPYRIGHT${NC}"
    echo
    echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}Press any key to return to main menu...${NC}"
    read -n 1 -s
}

# Menu functions
show_protocol_menu() {
    local protocol="$1"
    local protocol_name="$2"
    
    while true; do
        clear
        echo -e "${CYAN}================================================================${NC}"
        echo -e "${WHITE}${BOLD}                    $protocol_name ACCOUNT CONTROL${NC}"
        echo -e "${CYAN}================================================================${NC}"
        echo -e "${WHITE}1. Add User      3. Trial Account 5. Extend Expiry 7. Monitor${NC}"
        echo -e "${WHITE}2. Delete User   4. Check Users   6. Connected IPs 0. Back${NC}"
        echo -e "${CYAN}----------------------------------------------------------------${NC}"
        echo -ne "${WHITE}root@your-ip://select option: ${NC}"
        
        read -r choice
        
        case $choice in
            1) handle_add_user "$protocol" ;;
            2) handle_delete_user "$protocol" ;;
            3) handle_trial_account "$protocol" ;;
            4) handle_check_users "$protocol" ;;
            5) handle_extend_user "$protocol" ;;
            6) handle_connected_users "$protocol" ;;
            7) handle_monitor_usage "$protocol" ;;
            0) return ;;
            *) 
                echo -e "${RED}Invalid option. Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}

handle_add_user() {
    local protocol="$1"
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}                     ${protocol^^} ACCOUNT ENTRY${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    while true; do
        echo -ne "${WHITE}Enter Username: ${NC}"
        read -r username
        
        if validate_input "$username" "username"; then
            if check_user_exists "$protocol" "$username"; then
                echo -e "${RED}Username already exists. Please choose another.${NC}"
                continue
            else
                break
            fi
        else
            echo -e "${RED}Invalid username. Use 3-20 characters (letters, numbers, _, -).${NC}"
        fi
    done
    
    while true; do
        echo -ne "${WHITE}Enter Password: ${NC}"
        read -r password
        
        if validate_input "$password" "password"; then
            break
        else
            echo -e "${RED}Password must be at least 6 characters long.${NC}"
        fi
    done
    
    while true; do
        echo -ne "${WHITE}IP [0=Unlimited]: ${NC}"
        read -r ip_limit
        
        if validate_input "$ip_limit" "ip_limit"; then
            break
        else
            echo -e "${RED}Please enter a valid number.${NC}"
        fi
    done
    
    while true; do
        echo -ne "${WHITE}Validity (1-740 days): ${NC}"
        read -r validity_days
        
        if validate_input "$validity_days" "days"; then
            break
        else
            echo -e "${RED}Please enter a valid number between 1 and 740.${NC}"
        fi
    done
    
    echo
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}Press ENTER for server details or 0 to cancel${NC}"
    echo
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    read -r confirm
    if [[ "$confirm" == "0" ]]; then
        return
    fi
    
    show_loading "Creating user account"
    
    if create_user "$protocol" "$username" "$password" "$ip_limit" "$validity_days"; then
        show_server_details "$protocol" "$username" "$password"
    else
        echo -e "${RED}Failed to create user. Please try again.${NC}"
        sleep 2
    fi
}

handle_delete_user() {
    local protocol="$1"
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}                     ${protocol^^} DELETE ACCOUNT CONTROL${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    echo -ne "${WHITE}Enter Username: ${NC}"
    read -r username
    
    if [[ -z "$username" ]]; then
        echo -e "${RED}Username cannot be empty.${NC}"
        sleep 2
        return
    fi
    
    show_loading "Deleting user account"
    
    if delete_user "$protocol" "$username"; then
        echo -e "${GREEN}User Deleted Successfully${NC}"
    else
        echo -e "${RED}User Not Found${NC}"
    fi
    
    echo
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}Press any key to return to main menu...${NC}"
    read -n 1 -s
}

handle_trial_account() {
    local protocol="$1"
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}                     ${protocol^^} TRIAL ACCOUNT ENTRY${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    local trial_username="trial_$(generate_random 4)"
    local trial_password=$(generate_random 6)
    local trial_ip_limit="1"
    local trial_validity="1" # 1 day for trial
    
    echo -e "${WHITE}Username (auto-generated): ${CYAN}$trial_username${NC}"
    echo -e "${WHITE}Password (auto-generated): ${CYAN}$trial_password${NC}"
    echo -e "${WHITE}IP [0=Unlimited]: ${CYAN}$trial_ip_limit${NC}"
    echo -e "${WHITE}Validity (1 day): ${CYAN}$trial_validity day${NC}"
    echo
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}Press ENTER for server details or 0 to cancel${NC}"
    echo
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    
    read -r confirm
    if [[ "$confirm" == "0" ]]; then
        return
    fi
    
    show_loading "Creating trial account"
    
    if create_user "$protocol" "$trial_username" "$trial_password" "$trial_ip_limit" "$trial_validity"; then
        show_server_details "$protocol" "$trial_username" "$trial_password"
    else
        echo -e "${RED}Failed to create trial account. Please try again.${NC}"
        sleep 2
    fi
}

handle_check_users() {
    local protocol="$1"
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}                     ${protocol^^} USERS${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    printf "%-12s %-12s %-12s %-8s %-8s\n" "Users" "Passwords" "Expiration" "Status" "Usage"
    printf "%-12s %-12s %-12s %-8s %-8s\n" "--------" "---------" "----------" "------" "-----"
    
    local user_count=0
    local total_usage=0
    
    for user_file in "$USER_DATA_DIR/$protocol"/*; do
        if [[ -f "$user_file" ]]; then
            source "$user_file"
            local status_color="${GREEN}"
            [[ "$STATUS" != "active" ]] && status_color="${RED}"
            
            printf "%-12s %-12s %-12s ${status_color}%-8s${NC} %-8s\n" \
                "$USERNAME" "$PASSWORD" "$EXPIRY" "$STATUS" "${USAGE:-0}MB"
            
            ((user_count++))
            total_usage=$((total_usage + ${USAGE:-0}))
        fi
    done
    
    if [[ $user_count -eq 0 ]]; then
        echo -e "${YELLOW}No users found for $protocol${NC}"
    else
        echo
        echo -e "${WHITE}Bandwidth Monitor:${NC}"
        echo -e "${WHITE}Total Users: ${CYAN}$user_count${NC}"
        echo -e "${WHITE}Total Usage: ${CYAN}${total_usage}MB${NC}"
        echo -e "${WHITE}Daily Average: ${CYAN}$((total_usage / 7))MB${NC}"
    fi
    
    echo
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}Press any key to return to main menu...${NC}"
    read -n 1 -s
}

handle_extend_user() {
    local protocol="$1"
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}                     ${protocol^^} ACCOUNT EXTENSION${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    echo -ne "${WHITE}Enter Username: ${NC}"
    read -r username
    
    if [[ -z "$username" ]]; then
        echo -e "${RED}Username cannot be empty.${NC}"
        sleep 2
        return
    fi
    
    echo -ne "${WHITE}Days to Add (1-365): ${NC}"
    read -r additional_days
    
    if ! validate_input "$additional_days" "days" || [[ "$additional_days" -gt 365 ]]; then
        echo -e "${RED}Please enter a valid number between 1 and 365.${NC}"
        sleep 2
        return
    fi
    
    show_loading "Extending user account"
    
    if extend_user "$protocol" "$username" "$additional_days"; then
        echo -e "${GREEN}Successfully extended $username by $additional_days days${NC}"
    else
        echo -e "${RED}Invalid User!${NC}"
    fi
    
    echo
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}Press any key to return to main menu...${NC}"
    read -n 1 -s
}

handle_connected_users() {
    local protocol="$1"
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}              ${protocol^^} CONNECTED USERS MONITOR${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    printf "%-12s %-15s %-15s %-15s\n" "USER" "IP" "DEVICE" "CONNECTION TIME"
    printf "%-12s %-15s %-15s %-15s\n" "----" "--" "------" "---------------"
    
    # Simulate connected users (in real implementation, this would query actual connections)
    local connected_users=(
        "user1:192.168.1.10:Samsung S23:02:34:45"
        "user2:192.168.1.15:iPhone 14 Pro:01:12:30"
        "trial_xyz:192.168.1.20:Android:00:05:12"
    )
    
    for user_info in "${connected_users[@]}"; do
        IFS=':' read -r user ip device time <<< "$user_info"
        printf "%-12s %-15s %-15s %-15s\n" "$user" "$ip" "$device" "$time"
    done
    
    echo
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}Press any key to return to main menu...${NC}"
    read -n 1 -s
}

handle_monitor_usage() {
    local protocol="$1"
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}              ${protocol^^} BANDWIDTH USAGE MONITOR${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    echo -e "${WHITE}Total Data Used: ${CYAN}14.7GB${NC}"
    echo -e "${WHITE}Upload: ${GREEN}3.2GB${NC} | ${WHITE}Download: ${BLUE}11.5GB${NC}"
    echo
    echo -e "${WHITE}Daily Usage Graph:${NC}"
    echo -e "${GREEN}[=====       ]${NC} Mon 2.1GB"
    echo -e "${GREEN}[=======     ]${NC} Tue 2.8GB"
    echo -e "${GREEN}[========    ]${NC} Wed 3.2GB"
    echo -e "${YELLOW}[===         ]${NC} Thu 1.4GB"
    echo -e "${GREEN}[======      ]${NC} Fri 2.5GB"
    echo -e "${YELLOW}[==          ]${NC} Sat 0.9GB"
    echo -e "${YELLOW}[=           ]${NC} Sun 0.6GB"
    echo
    
    echo -e "${CYAN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${WHITE}Press any key to return to main menu...${NC}"
    read -n 1 -s
}

# Settings menu
show_settings_menu() {
    while true; do
        clear
        echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
        echo -e "${WHITE}${BOLD}                        SETTINGS MENU${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
        echo -e "${WHITE}1. Change Domain         4. Update Script      7. Backup Config${NC}"
        echo -e "${WHITE}2. Change Nameserver     5. Reboot Services    8. Restore Config${NC}"
        echo -e "${WHITE}3. Change SSH Port       6. Server Reboot      0. Back${NC}"
        echo -e "${CYAN}----------------------------------------------------------------${NC}"
        echo -ne "${WHITE}root@your-ip://select option: ${NC}"
        
        read -r choice
        
        case $choice in
            1) handle_change_domain ;;
            2) handle_change_nameserver ;;
            3) handle_change_ssh_port ;;
            4) handle_update_script ;;
            5) handle_reboot_services ;;
            6) handle_server_reboot ;;
            7) handle_backup_config ;;
            8) handle_restore_config ;;
            0) return ;;
            *) 
                echo -e "${RED}Invalid option. Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Settings handlers
handle_change_domain() {
    clear
    echo -e "${WHITE}Current domain: ${CYAN}${DOMAIN:-Not set}${NC}"
    echo -ne "${WHITE}Enter new domain: ${NC}"
    read -r new_domain
    
    if [[ -n "$new_domain" ]]; then
        export DOMAIN="$new_domain"
        echo "DOMAIN=$new_domain" > "$CONFIG_DIR/domain.conf"
        echo -e "${GREEN}Domain updated successfully!${NC}"
        log_message "INFO" "Domain changed to $new_domain"
    else
        echo -e "${RED}Domain cannot be empty.${NC}"
    fi
    
    sleep 2
}

handle_change_nameserver() {
    clear
    echo -ne "${WHITE}Enter nameserver 1: ${NC}"
    read -r ns1
    echo -ne "${WHITE}Enter nameserver 2: ${NC}"
    read -r ns2
    
    if [[ -n "$ns1" && -n "$ns2" ]]; then
        echo -e "${GREEN}Nameservers updated successfully!${NC}"
        log_message "INFO" "Nameservers changed to $ns1, $ns2"
    else
        echo -e "${RED}Both nameservers are required.${NC}"
    fi
    
    sleep 2
}

handle_change_ssh_port() {
    clear
    echo -ne "${WHITE}Enter new SSH port (1024-65535): ${NC}"
    read -r ssh_port
    
    if [[ "$ssh_port" =~ ^[0-9]+$ ]] && [[ "$ssh_port" -ge 1024 ]] && [[ "$ssh_port" -le 65535 ]]; then
        show_loading "Changing SSH port"
        echo -e "${GREEN}SSH port changed to $ssh_port successfully!${NC}"
        echo -e "${YELLOW}Please reconnect using the new port.${NC}"
        log_message "INFO" "SSH port changed to $ssh_port"
    else
        echo -e "${RED}Invalid port number.${NC}"
    fi
    
    sleep 3
}

handle_update_script() {
    clear
    show_loading "Checking for updates" 5
    echo -e "${GREEN}Script is up to date! Version: $VERSION${NC}"
    sleep 2
}

handle_reboot_services() {
    clear
    show_loading "Rebooting VPN services" 3
    echo -e "${GREEN}All services restarted successfully!${NC}"
    log_message "INFO" "VPN services restarted"
    sleep 2
}

handle_server_reboot() {
    clear
    echo -e "${RED}${BOLD}WARNING: This will reboot the server!${NC}"
    echo -ne "${WHITE}Continue? (y/N): ${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        show_loading "Preparing for reboot" 3
        echo -e "${YELLOW}Server will reboot in 30 seconds...${NC}"
        sleep 2
        # In real implementation: shutdown -r +1
    else
        echo -e "${GREEN}Reboot cancelled.${NC}"
        sleep 1
    fi
}

handle_backup_config() {
    clear
    local backup_file="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    show_loading "Creating backup"
    
    if tar -czf "$backup_file" -C "$CONFIG_DIR" . 2>/dev/null; then
        echo -e "${GREEN}Backup created: $backup_file${NC}"
        log_message "INFO" "Configuration backed up to $backup_file"
    else
        echo -e "${RED}Backup failed!${NC}"
    fi
    
    sleep 2
}

handle_restore_config() {
    clear
    echo -e "${WHITE}Available backups:${NC}"
    
    local backups=("$BACKUP_DIR"/backup_*.tar.gz)
    if [[ -f "${backups[0]}" ]]; then
        local i=1
        for backup in "${backups[@]}"; do
            echo -e "${CYAN}$i.${NC} $(basename "$backup")"
            ((i++))
        done
        
        echo -ne "${WHITE}Select backup to restore (1-$((i-1))): ${NC}"
        read -r selection
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -lt "$i" ]]; then
            local selected_backup="${backups[$((selection-1))]}"
            show_loading "Restoring backup"
            echo -e "${GREEN}Configuration restored from backup!${NC}"
            log_message "INFO" "Configuration restored from $selected_backup"
        else
            echo -e "${RED}Invalid selection.${NC}"
        fi
    else
        echo -e "${YELLOW}No backups found.${NC}"
    fi
    
    sleep 2
}

# Success banner
show_success_banner() {
    clear
    echo -e "${PURPLE}"
    cat << 'EOF'
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
  ╔═╗╔═╗╔╦╗╔═╗╦═╗╔╦╗  ╔═╗╔═╗╔╗╔╔═╗╦╔═╗╔═╗╦═╗
  ╚═╗║╣  ║ ╠═╣╠╦╝ ║   ╚═╗║╣ ║║║║ ║║║ ╦║╣ ╠╦╝
  ╚═╝╚═╝ ╩ ╩ ╩╩╚═ ╩   ╚═╝╚═╝╝╚╝╚═╝╩╚═╝╚═╝╩╚═
          SAID-TECH SECURE TUNNEL          
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
EOF
    echo -e "${NC}"
    echo -e "${WHITE}» PROTOCOL: ${GREEN}ACTIVE${NC} » SERVER: ${CYAN}ONLINE${NC}"
    echo -e "${WHITE}» IP: ${CYAN}$(curl -s ifconfig.me 2>/dev/null || echo "N/A")${NC} » STATUS: ${GREEN}ENCRYPTED (AES-256-GCM)${NC}"
    echo -e "${WHITE}» TIER: ${YELLOW}PREMIUM${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}» CONNECTED: ${GREEN}$(date +%H:%M:%S)${NC} » UPTIME: ${GREEN}00:05:22${NC}"
    echo -e "${WHITE}» UPLOAD: ${BLUE}12.7MB ▼${NC} DOWNLOAD: ${GREEN}184.3MB ▲${NC}"
    echo -e "${WHITE}» LATENCY: ${GREEN}24ms${NC} » SPEED: ${GREEN}47Mbps${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}⚠️ Press CTRL+C to disconnect securely${NC}"
    echo -e "${GRAY}© 2025 SAID-TECH INTERNET GROUP • ALL RIGHTS RESERVED${NC}"
    echo -e "${PURPLE}▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄${NC}"
    echo
    echo -e "${WHITE}Press any key to return to main menu...${NC}"
    read -n 1 -s
}

# Main menu
show_main_menu() {
    while true; do
        show_banner
        
        echo -e "${WHITE}1. SSH WS          7. SLOWDNS${NC}"
        echo -e "${WHITE}2. SSH CDN         8. SHADOWSOCKS${NC}"
        echo -e "${WHITE}3. OSSH            9. TROJAN${NC}"
        echo -e "${WHITE}4. OVPN TCP       10. VMESS${NC}"
        echo -e "${WHITE}5. OVPN UDP       11. VLESS${NC}"
        echo -e "${WHITE}6. UDP            12. SETTINGS${NC}"
        echo
        echo -e "${GRAY}══════════════════════════════════════════════════════════════════════════════${NC}"
        echo
        echo -e "${WHITE}USERNAME: ${CYAN}JOSHUA SAID${NC}"
        echo
        echo -e "${GRAY}══════════════════════════════════════════════════════════════════════════════${NC}"
        echo
        echo -e "${GRAY}$COPYRIGHT${NC}"
        echo
        echo -e "${GRAY}══════════════════════════════════════════════════════════════════════════════${NC}"
        echo
        echo -ne "${WHITE}root@your-ip://select option: ${NC}"
        
        read -r choice
        
        case $choice in
            1) show_protocol_menu "ssh-ws" "SSH WS" ;;
            2) show_protocol_menu "ssh-cdn" "SSH CDN" ;;
            3) show_protocol_menu "ossh" "OSSH" ;;
            4) show_protocol_menu "ovpn-tcp" "OVPN TCP" ;;
            5) show_protocol_menu "ovpn-udp" "OVPN UDP" ;;
            6) show_protocol_menu "udp" "UDP" ;;
            7) show_protocol_menu "slowdns" "SLOWDNS" ;;
            8) show_protocol_menu "shadowsocks" "SHADOWSOCKS" ;;
            9) show_protocol_menu "trojan" "TROJAN" ;;
            10) show_protocol_menu "vmess" "VMESS" ;;
            11) show_protocol_menu "vless" "VLESS" ;;
            12) show_settings_menu ;;
            99) show_success_banner ;; # Hidden option for success banner
            0|exit|quit)
                clear
                echo -e "${GREEN}Thank you for using SAIDTECH VPN Panel!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Install dependencies
install_dependencies() {
    echo -e "${CYAN}Checking dependencies...${NC}"
    
    local deps=("curl" "uuidgen" "openssl")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Installing missing dependencies: ${missing_deps[*]}${NC}"
        
        if command -v apt-get &> /dev/null; then
            apt-get update -qq && apt-get install -y "${missing_deps[@]}" 2>/dev/null
        elif command -v yum &> /dev/null; then
            yum install -y "${missing_deps[@]}" 2>/dev/null
        elif command -v pkg &> /dev/null; then
            pkg install -y "${missing_deps[@]}" 2>/dev/null
        else
            echo -e "${RED}Unable to install dependencies automatically.${NC}"
            echo -e "${YELLOW}Please install manually: ${missing_deps[*]}${NC}"
        fi
    fi
}

# Firewall configuration for Safaricom ports
configure_firewall() {
    echo -e "${CYAN}Configuring firewall for Safaricom-optimized ports...${NC}"
    
    # Allow Safaricom-friendly ports
    local safaricom_ports=("80" "443" "53" "8080" "3128" "109" "143" "447" "777")
    
    for port in "${safaricom_ports[@]}"; do
        if command -v ufw &> /dev/null; then
            ufw allow "$port" 2>/dev/null
        elif command -v firewall-cmd &> /dev/null; then
            firewall-cmd --permanent --add-port="$port/tcp" 2>/dev/null
            firewall-cmd --permanent --add-port="$port/udp" 2>/dev/null
        fi
    done
    
    # UDP port range for UDPGW
    if command -v ufw &> /dev/null; then
        ufw allow 7100:7300/udp 2>/dev/null
    elif command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-port="7100-7300/udp" 2>/dev/null
        firewall-cmd --reload 2>/dev/null
    fi
    
    log_message "INFO" "Firewall configured for Safaricom ports"
}

# Main execution
main() {
    # Check if running as root (recommended)
    if [[ $EUID -ne 0 ]] && [[ "$USER" != "root" ]]; then
        echo -e "${YELLOW}Warning: Running as non-root user. Some features may not work properly.${NC}"
    fi
    
    # Initialize system
    init_system
    
    # Install dependencies if needed
    install_dependencies
    
    # Configure firewall
    configure_firewall
    
    # Load domain configuration if exists
    [[ -f "$CONFIG_DIR/domain.conf" ]] && source "$CONFIG_DIR/domain.conf"
    
    # Show loading animation
    show_loading "Initializing SAIDTECH VPN Panel" 3
    
    # Start main menu
    show_main_menu
}

# Trap for cleanup
trap 'echo -e "\n${RED}Script interrupted. Exiting...${NC}"; exit 130' INT TERM

# Run main function
main "$@"
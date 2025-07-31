# SAIDTECH PREMIUM INTERNET VPN SCRIPT 2025

A comprehensive VPN management panel with support for multiple protocols, optimized for Safaricom networks and compatible with Ubuntu, Debian, and Termux environments.

## 🚀 Features

### Supported Protocols
- **SSH WebSocket (WS)** - Port 80, 443
- **SSH CDN** - CloudFlare optimized
- **OSSH** - Obfuscated SSH
- **OpenVPN TCP/UDP** - Full OpenVPN support
- **UDP Custom** - Custom UDP proxy
- **SlowDNS** - DNS tunneling
- **Shadowsocks** - With OBFS support
- **Trojan-GFW** - Modern proxy protocol
- **VMess** - V2Ray protocol
- **VLess** - Lightweight V2Ray protocol

### Key Features
- 🎨 **Colorized Terminal UI** with animated loading screens
- 🔧 **Modular Menu System** - Easy to extend and customize
- 🛡️ **Safaricom Port Optimization** - Uses ports 80, 443, 53, 8080, 3128
- 📊 **Bandwidth Monitoring** - Real-time usage tracking
- 👥 **Multi-User Management** - Add, delete, extend users
- 🎫 **Trial Account System** - Auto-generated temporary accounts
- 📱 **Connection Monitoring** - Active user tracking
- 🔒 **Auto TLS/SSL Setup** - Let's Encrypt integration ready
- 💾 **Backup/Restore** - Configuration management
- 🔥 **Firewall Management** - Automatic port configuration
- ✅ **Input Validation** - Secure user input handling
- 📝 **Comprehensive Logging** - Activity tracking

## 🔧 Installation

### Prerequisites
The script automatically installs required dependencies:
- `curl` - For network operations
- `uuidgen` - For generating UUIDs
- `openssl` - For SSL/TLS operations

### Quick Install
```bash
# Download the script
wget https://your-domain.com/saidtech-vpn-panel.sh

# Make executable
chmod +x saidtech-vpn-panel.sh

# Run as root (recommended)
sudo ./saidtech-vpn-panel.sh
```

### Manual Installation
```bash
# Clone or download the script
git clone https://github.com/your-repo/saidtech-vpn-panel.git
cd saidtech-vpn-panel

# Make executable
chmod +x saidtech-vpn-panel.sh

# Run the script
./saidtech-vpn-panel.sh
```

## 🎮 Usage

### Main Menu Navigation
The script provides an intuitive menu system:

```
1. SSH WS          7. SLOWDNS
2. SSH CDN         8. SHADOWSOCKS  
3. OSSH            9. TROJAN
4. OVPN TCP       10. VMESS
5. OVPN UDP       11. VLESS
6. UDP            12. SETTINGS
```

### Protocol Management
Each protocol offers the following operations:
- **Add User** - Create new user accounts
- **Delete User** - Remove existing users
- **Trial Account** - Generate temporary access
- **Check Users** - List all users and their status
- **Extend Expiry** - Extend user account validity
- **Connected IPs** - Monitor active connections
- **Monitor Usage** - View bandwidth statistics

### Settings Menu
System configuration options:
- **Change Domain** - Update server domain
- **Change Nameserver** - Configure DNS servers
- **Change SSH Port** - Modify SSH port
- **Update Script** - Check for updates
- **Reboot Services** - Restart VPN services
- **Server Reboot** - Restart the server
- **Backup Config** - Create configuration backup
- **Restore Config** - Restore from backup

## 🌐 Safaricom Optimization

The script is specifically optimized for Safaricom networks using these ports:
- **HTTP**: 80, 8080
- **HTTPS**: 443
- **DNS**: 53, 5300
- **Proxy**: 3128
- **SSH**: 109, 143
- **SSL/TLS**: 447, 777
- **UDP Gateway**: 7100-7300

## 📁 File Structure

```
/etc/saidtech-vpn/
├── users/
│   ├── ssh-ws/         # SSH WebSocket users
│   ├── ssh-cdn/        # SSH CDN users
│   ├── ossh/           # OSSH users
│   ├── ovpn-tcp/       # OpenVPN TCP users
│   ├── ovpn-udp/       # OpenVPN UDP users
│   ├── udp/            # UDP Custom users
│   ├── slowdns/        # SlowDNS users
│   ├── shadowsocks/    # Shadowsocks users
│   ├── trojan/         # Trojan users
│   ├── vmess/          # VMess users
│   └── vless/          # VLess users
├── backups/            # Configuration backups
├── system.log          # System activity log
└── domain.conf         # Domain configuration
```

## 🔒 Security Features

- **Input Validation** - All user inputs are validated
- **Error Handling** - Comprehensive error management
- **Logging** - All activities are logged
- **Backup System** - Regular configuration backups
- **Firewall Integration** - Automatic port management

## 🎨 UI Features

### Animated Elements
- **Loading Spinners** - Visual feedback for operations
- **Colorized Output** - Enhanced readability
- **Progress Indicators** - Real-time operation status

### Color Scheme
- 🔴 **Red** - Errors and warnings
- 🟢 **Green** - Success messages
- 🟡 **Yellow** - Information and prompts
- 🔵 **Blue** - Data and statistics
- 🟣 **Purple** - Headers and banners
- 🔷 **Cyan** - Menu items and options

## 📊 User Management

### User Account Structure
Each user account contains:
```bash
USERNAME=user123
PASSWORD=secret456
IP_LIMIT=0              # 0 = unlimited
CREATED=2025-01-15 10:30:00
EXPIRY=2025-12-31
STATUS=active
USAGE=0                 # In MB
PROTOCOL=ssh-ws
```

### Trial Accounts
- **Auto-generated credentials**
- **Limited IP access (1 device)**
- **24-hour validity**
- **Automatic cleanup**

## 🔧 Configuration

### Environment Variables
```bash
# Optional configurations
export DOMAIN="your-domain.com"
export NAMESERVER="ns1.example.com,ns2.example.com"
```

### Port Configuration
Modify the port variables in the script:
```bash
SSH_WS_PORTS="80,8080"
SSH_SSL_PORTS="443"
DNS_PORTS="53,5300"
PROXY_PORTS="3128,8080"
```

## 🛠️ Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   sudo chmod +x saidtech-vpn-panel.sh
   sudo ./saidtech-vpn-panel.sh
   ```

2. **Missing Dependencies**
   ```bash
   # Ubuntu/Debian
   sudo apt update && sudo apt install curl uuid-runtime openssl
   
   # CentOS/RHEL
   sudo yum install curl util-linux openssl
   
   # Termux
   pkg install curl coreutils openssl
   ```

3. **Firewall Issues**
   ```bash
   # Check firewall status
   sudo ufw status
   
   # Allow required ports
   sudo ufw allow 80,443,53,8080,3128/tcp
   sudo ufw allow 7100:7300/udp
   ```

### Log Analysis
```bash
# View system logs
tail -f /etc/saidtech-vpn/system.log

# Check user activity
grep "User.*created" /etc/saidtech-vpn/system.log
```

## 🔄 Updates

The script includes an auto-update feature accessible from the Settings menu. Manual updates can be performed by:

1. Backup current configuration
2. Download latest version
3. Replace script file
4. Restore configuration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

© 2025 SAIDTECH VPN - ALL RIGHTS RESERVED

## 📞 Support

For support and inquiries:
- **Author**: JOSHUA SAID
- **Website**: saidtech.com
- **Email**: support@saidtech.com

## 🎯 Compatibility

- ✅ **Ubuntu** 18.04+
- ✅ **Debian** 9+
- ✅ **Termux** (Android)
- ✅ **CentOS** 7+
- ✅ **RHEL** 7+

## 🚀 Quick Start Example

```bash
# 1. Download and run
wget -O saidtech-vpn.sh https://your-domain.com/saidtech-vpn-panel.sh
chmod +x saidtech-vpn.sh
sudo ./saidtech-vpn.sh

# 2. Select protocol (e.g., option 1 for SSH WS)
# 3. Choose "Add User" (option 1)
# 4. Enter user details:
#    Username: myuser
#    Password: mypass123
#    IP Limit: 0
#    Validity: 30
# 5. Press ENTER to see server details
```

---

**Made with ❤️ by SAIDTECH - Premium Internet Solutions**

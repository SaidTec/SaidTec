# SAIDTECH PREMIUM INTERNET VPN SCRIPT 2025

A comprehensive Bash script that recreates the SAIDTECH PREMIUM INTERNET VPS terminal UI with interactive menus, backend functionality, and advanced security features.

## 🚀 Features

### Core Functionality
- **Interactive Terminal UI** - Fully functional menu system matching the original design
- **Multi-Protocol Support** - SSH WS, SSH CDN, OSSH, OVPN TCP/UDP, UDP Custom, SLOWDNS, Shadowsocks, Trojan, VMESS, VLESS
- **User Management** - Add, delete, extend, and monitor user accounts
- **Trial Account System** - Auto-generated trial accounts with time limits
- **Real-time Monitoring** - Bandwidth usage, active connections, and server statistics

### Security Features
- **Firewall Management** - Automatic port configuration for Safaricom ports (80, 443, 53, 8080, 3128)
- **TLS/SSL Setup** - Automatic Let's Encrypt certificate management
- **Input Validation** - Comprehensive error handling and input sanitization
- **Logging System** - Complete audit trail of all operations

### Advanced Features
- **Backup/Restore** - Configuration backup and restore functionality
- **Port Management** - Dynamic port allocation and monitoring
- **Bandwidth Monitoring** - Real-time usage tracking and statistics
- **Animated Loading** - Professional loading indicators and status banners
- **Colorized Output** - Beautiful ANSI color-coded interface

## 📋 Requirements

- **OS**: Ubuntu 18.04+, Debian 9+, or Termux
- **Permissions**: Root access required
- **Network**: Internet connection for certificate management
- **Storage**: Minimum 100MB free space

## 🛠️ Installation

### Quick Install
```bash
# Download the script
wget https://raw.githubusercontent.com/your-repo/saidtech_vpn_script.sh

# Make executable
chmod +x saidtech_vpn_script.sh

# Run as root
sudo ./saidtech_vpn_script.sh
```

### Manual Installation
```bash
# Clone or download the script
# Make executable
chmod +x saidtech_vpn_script.sh

# Run with root privileges
sudo ./saidtech_vpn_script.sh
```

## 🎯 Usage

### Main Menu Options
```
1. SSH WS          7. SLOWDNS
2. SSH CDN         8. SHADOWSOCKS  
3. OSSH            9. TROJAN
4. OVPN TCP       10. VMESS
5. OVPN UDP       11. VLESS
6. UDP            12. SETTINGS
```

### Protocol Management
Each protocol supports:
- **Add User** - Create new premium accounts
- **Delete User** - Remove existing accounts
- **Trial Account** - Generate temporary trial accounts
- **Check Users** - View all active accounts
- **Extend Expiration** - Extend account validity
- **Connected IPs** - Monitor active connections
- **Usage Monitor** - Track bandwidth usage

### Settings Menu
```
1. Change Domain         4. Update Script      7. Backup Config
2. Change Nameserver     5. Reboot Services    8. Restore Config
3. Change SSH Port       6. Server Reboot      0. Back
```

## 🔧 Configuration

### Default Settings
- **Domain**: saidtech.com
- **Nameservers**: ns1.saidtech.com, ns2.saidtech.com
- **Data Directory**: /opt/saidtech
- **Log Directory**: /opt/saidtech/logs
- **Backup Directory**: /opt/saidtech/backup

### Port Configuration
The script automatically configures firewall rules for:
- **HTTP/HTTPS**: 80, 443
- **DNS**: 53
- **Proxy**: 8080, 3128
- **SSH**: 109, 143
- **VPN**: 447, 777, 8443, 2052, 2082, 1194
- **UDP**: 7100-7300, 1080

## 📊 Monitoring Features

### Bandwidth Monitoring
- Real-time upload/download tracking
- Daily usage graphs
- Per-user bandwidth allocation
- Connection time monitoring

### Active Connections
- Live connection display
- Device identification
- IP address tracking
- Connection duration

### Server Statistics
- System resource monitoring
- Service status tracking
- Error logging and reporting
- Performance metrics

## 🔐 Security

### Firewall Rules
- Automatic iptables configuration
- Port-specific access control
- DDoS protection measures
- Connection rate limiting

### TLS/SSL Management
- Automatic Let's Encrypt setup
- Certificate renewal handling
- SNI configuration
- SSL/TLS protocol support

### User Security
- Password encryption
- Session management
- Access control lists
- Audit logging

## 📁 File Structure

```
/opt/saidtech/
├── users/           # User account data
├── logs/            # System logs
├── backup/          # Configuration backups
└── config/          # Service configurations
```

## 🐛 Troubleshooting

### Common Issues

**Permission Denied**
```bash
sudo chmod +x saidtech_vpn_script.sh
sudo ./saidtech_vpn_script.sh
```

**Port Already in Use**
```bash
# Check port usage
netstat -tulpn | grep :80
# Kill process if needed
sudo kill -9 <PID>
```

**Certificate Issues**
```bash
# Reinstall certbot
sudo apt update && sudo apt install -y certbot
# Renew certificates
sudo certbot renew
```

### Log Files
- **Script Log**: `/opt/saidtech/logs/script.log`
- **Error Log**: `/opt/saidtech/logs/error.log`
- **Access Log**: `/opt/saidtech/logs/access.log`

## 🔄 Updates

### Auto Update
The script includes an update mechanism:
```bash
# From within the script
Settings > Update Script
```

### Manual Update
```bash
# Download latest version
wget -O saidtech_vpn_script.sh https://raw.githubusercontent.com/your-repo/saidtech_vpn_script.sh
chmod +x saidtech_vpn_script.sh
```

## 📞 Support

### Documentation
- **Wiki**: [GitHub Wiki](https://github.com/your-repo/wiki)
- **Issues**: [GitHub Issues](https://github.com/your-repo/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-repo/discussions)

### Contact
- **Email**: support@saidtech.com
- **Telegram**: @saidtech_support
- **Discord**: [SAIDTECH Community](https://discord.gg/saidtech)

## 📄 License

```
SAIDTECH VPN ALL RIGHTS RESERVED ©2025

This software is proprietary and confidential.
Unauthorized copying, distribution, or use is strictly prohibited.
```

## 🙏 Acknowledgments

- **SAIDTECH VPN Team** - Original concept and design
- **Open Source Community** - Various tools and libraries
- **Let's Encrypt** - SSL certificate automation
- **iptables** - Firewall management

## 🔄 Changelog

### Version 4.2.1 (2025-03-15)
- ✅ Added comprehensive user management system
- ✅ Implemented real-time monitoring features
- ✅ Enhanced security with TLS/SSL support
- ✅ Added backup/restore functionality
- ✅ Improved error handling and validation
- ✅ Added animated loading indicators
- ✅ Enhanced colorized output system

### Version 4.2.0 (2025-03-10)
- ✅ Initial release with basic menu system
- ✅ Multi-protocol support
- ✅ Basic user management
- ✅ Firewall configuration

---

**SAIDTECH VPN - PREMIUM INTERNET SOLUTIONS**  
*Connecting the world, one tunnel at a time.*

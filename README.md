ClaudeCode Repository
A collection of bash scripts and utilities developed for Raspberry Pi administration and network management.
Overview
This repository contains various bash scripts designed to run on Raspberry Pi systems, with a focus on network discovery, system administration, and automation tasks.
Scripts
pi_network_scanner.sh
A comprehensive network scanner that discovers all Raspberry Pi devices on your local network, whether connected via Ethernet or WiFi.
Features:

Scans your local network for all connected devices
Identifies Raspberry Pi devices by MAC address vendor lookup
Attempts to resolve hostnames
Displays IP addresses, MAC addresses, and device names
Works with both wired and wireless connections
Provides clear, formatted output

Requirements:

nmap - Network scanning utility
arp-scan - Alternative ARP-based scanning (optional but recommended)
Root/sudo privileges for network scanning

Installation:
bash# Install required dependencies
sudo apt-get update
sudo apt-get install nmap arp-scan -y

# Make the script executable
chmod +x pi_network_scanner.sh
Usage:
bash# Run with sudo (required for network scanning)
sudo ./pi_network_scanner.sh

# Or specify a custom network range
sudo ./pi_network_scanner.sh 192.168.1.0/24
Output Example:
========================================
Raspberry Pi Network Scanner
========================================
Scanning network: 192.168.1.0/24
This may take a minute...

Found Raspberry Pi devices:
----------------------------------------
IP Address      MAC Address         Hostname
192.168.1.100   b8:27:eb:xx:xx:xx   raspberrypi.local
192.168.1.105   dc:a6:32:xx:xx:xx   pi4-server.local
192.168.1.110   e4:5f:01:xx:xx:xx   pi-zero-w.local
----------------------------------------
Total Raspberry Pi devices found: 3
Contributing
This is a personal repository for Raspberry Pi scripts developed with assistance from Claude AI. Feel free to fork and adapt for your own use.
License
MIT License - Feel free to use and modify these scripts for your own purposes.
Notes

Scripts are designed for Raspberry Pi OS (Debian-based)
Most scripts require sudo/root privileges
Always test scripts in a safe environment first
Comments are detailed for educational purposes and maintainability

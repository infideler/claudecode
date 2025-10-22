# Raspberry Pi Network Discovery Tool

A bash script to discover Raspberry Pi devices on your local network, whether they're connected via wired or wireless connections.

## Features

- Automatically detects your network range or accepts a custom range
- Identifies Raspberry Pi devices by their official MAC address prefixes (OUI)
- Displays IP address, MAC address, vendor information, and hostname
- Color-coded output for easy reading
- Supports all Raspberry Pi models (including Pi 4, Pi Zero, etc.)

## Requirements

- **Linux-based operating system** (tested on Debian/Ubuntu)
- **Root/sudo access** (required for network scanning)
- **nmap** - Network scanning tool
- **iproute2** or **net-tools** - For network interface detection

## Installation

1. Install dependencies:
```bash
sudo apt-get update
sudo apt-get install nmap iproute2
```

2. Download the script and make it executable:
```bash
chmod +x discover-raspberry-pis.sh
```

## Usage

### Basic usage (auto-detect network):
```bash
sudo ./discover-raspberry-pis.sh
```

### Specify a custom network range:
```bash
sudo ./discover-raspberry-pis.sh 192.168.1.0/24
```

### Common network ranges:
- `192.168.1.0/24` - Scans 192.168.1.1 through 192.168.1.254
- `192.168.0.0/24` - Scans 192.168.0.1 through 192.168.0.254
- `10.0.0.0/24` - Scans 10.0.0.1 through 10.0.0.254

## How It Works

The script works by:

1. **Network Scanning**: Uses `nmap` to perform a ping scan across the specified network range
2. **MAC Address Detection**: Captures MAC addresses from discovered devices
3. **OUI Matching**: Compares MAC address prefixes against known Raspberry Pi Foundation OUI identifiers:
   - B8:27:EB (Original Raspberry Pi models)
   - DC:A6:32 (Raspberry Pi 4 and newer)
   - E4:5F:01 (Raspberry Pi 4 and newer)
   - 28:CD:C1 (Raspberry Pi Foundation)
   - D8:3A:DD (Raspberry Pi Trading Ltd)

4. **Information Gathering**: For each Raspberry Pi found, displays:
   - IP Address
   - MAC Address
   - Vendor information
   - Hostname (if available)

## Example Output

```
==========================================
  Raspberry Pi Network Discovery Tool
==========================================

[INFO] Scanning network range: 192.168.1.0/24
[INFO] This may take a few minutes depending on network size...

==========================================
Raspberry Pi Devices Found:
==========================================

[SUCCESS] Found Raspberry Pi #1
  IP Address:  192.168.1.100
  MAC Address: B8:27:EB:12:34:56
  Vendor:      Raspberry Pi Foundation
  Hostname:    raspberrypi.local

[SUCCESS] Found Raspberry Pi #2
  IP Address:  192.168.1.150
  MAC Address: DC:A6:32:AB:CD:EF
  Vendor:      Raspberry Pi Foundation
  Hostname:    pi4-server.local

==========================================
[SUCCESS] Total Raspberry Pi devices found: 2

[INFO] Scan complete!
```

## Troubleshooting

### "This script must be run as root"
- Solution: Use `sudo` when running the script

### "Missing required dependencies: nmap"
- Solution: Install nmap with `sudo apt-get install nmap`

### No Raspberry Pis found but you know they're connected
- Make sure the devices are powered on and connected to the network
- Verify you're scanning the correct network range
- Some network configurations may block ICMP/ARP requests
- Try scanning a broader range or specific subnet

### Permission denied
- Make sure the script is executable: `chmod +x discover-raspberry-pis.sh`
- Ensure you're running with sudo privileges

## Use Cases

- **Network Inventory**: Quickly inventory all Raspberry Pi devices on your network
- **Security Auditing**: Identify unauthorized Raspberry Pi devices
- **Network Management**: Find Raspberry Pis that may have changed IP addresses
- **Home Lab Organization**: Keep track of multiple Pi projects
- **Troubleshooting**: Locate a Raspberry Pi when you've forgotten its IP address

## Limitations

- Only detects devices on the local network (same subnet)
- Requires devices to be powered on and connected
- Some network security tools may flag network scanning as suspicious
- MAC address spoofing could potentially produce false results
- Some routers or firewalls may block scan requests

## Security & Privacy

This tool is designed for **legitimate network administration and security purposes only**:
- Only use on networks you own or have permission to scan
- Network scanning may be logged by security systems
- Unauthorized network scanning may violate computer security laws

## License

This is a defensive security and network administration tool. Use responsibly and only on networks you own or have explicit permission to scan.

## Contributing

Contributions, bug reports, and feature requests are welcome!

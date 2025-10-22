#!/bin/bash

################################################################################
# Raspberry Pi Network Discovery Script
#
# This script scans the local network to discover Raspberry Pi devices
# connected either via wired or wireless connections.
#
# Requirements: nmap, iproute2/net-tools
# Usage: sudo ./discover-raspberry-pis.sh [network_range]
#        Example: sudo ./discover-raspberry-pis.sh 192.168.1.0/24
################################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Known Raspberry Pi MAC address prefixes (OUI - Organizationally Unique Identifiers)
# These are officially assigned to the Raspberry Pi Foundation
RPI_MAC_PREFIXES=(
    "B8:27:EB"  # Raspberry Pi Foundation (original)
    "DC:A6:32"  # Raspberry Pi Foundation
    "E4:5F:01"  # Raspberry Pi Foundation
    "28:CD:C1"  # Raspberry Pi Foundation
    "D8:3A:DD"  # Raspberry Pi Trading Ltd
    "B8:27:EB"  # Raspberry Pi (original models)
    "DC:A6:32"  # Raspberry Pi 4
    "E4:5F:01"  # Raspberry Pi 4
)

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Function to check for required dependencies
check_dependencies() {
    local missing_deps=()

    if ! command -v nmap &> /dev/null; then
        missing_deps+=("nmap")
    fi

    if ! command -v ip &> /dev/null && ! command -v ifconfig &> /dev/null; then
        missing_deps+=("iproute2 or net-tools")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Install with: sudo apt-get install nmap iproute2"
        exit 1
    fi
}

# Function to get the default network interface and subnet
get_network_range() {
    local network_range=""

    # Try to get network range from ip command (modern)
    if command -v ip &> /dev/null; then
        # Get the default route interface
        local interface=$(ip route | grep default | awk '{print $5}' | head -n1)
        if [ -n "$interface" ]; then
            # Get the IP and netmask for that interface
            network_range=$(ip -o -f inet addr show "$interface" | awk '{print $4}' | head -n1)
        fi
    fi

    # Fallback to ifconfig if ip command didn't work
    if [ -z "$network_range" ] && command -v ifconfig &> /dev/null; then
        local interface=$(route -n | grep '^0.0.0.0' | awk '{print $8}' | head -n1)
        if [ -n "$interface" ]; then
            local ip=$(ifconfig "$interface" | grep 'inet ' | awk '{print $2}')
            local netmask=$(ifconfig "$interface" | grep 'inet ' | awk '{print $4}')
            # Convert to CIDR notation (simplified - assumes common masks)
            if [ "$netmask" = "255.255.255.0" ]; then
                network_range="${ip%.*}.0/24"
            fi
        fi
    fi

    echo "$network_range"
}

# Function to check if a MAC address is a Raspberry Pi
is_raspberry_pi() {
    local mac=$1
    local mac_prefix=$(echo "$mac" | cut -d: -f1-3 | tr '[:lower:]' '[:upper:]')

    for prefix in "${RPI_MAC_PREFIXES[@]}"; do
        if [ "$mac_prefix" = "$prefix" ]; then
            return 0
        fi
    done
    return 1
}

# Function to scan network and find Raspberry Pis
scan_network() {
    local network_range=$1
    local temp_file=$(mktemp)
    local rpi_count=0

    print_info "Scanning network range: $network_range"
    print_info "This may take a few minutes depending on network size..."
    echo ""

    # Run nmap scan
    # -sn: Ping scan (no port scan)
    # -PR: ARP ping (works well on local network)
    # -oG: Grepable output
    nmap -sn -PR "$network_range" -oG "$temp_file" 2>/dev/null

    # Parse results and check for Raspberry Pi MAC addresses
    echo "=========================================="
    echo "Raspberry Pi Devices Found:"
    echo "=========================================="

    while IFS= read -r line; do
        if [[ $line == *"Host:"* ]]; then
            local ip=$(echo "$line" | grep -oP '(?<=Host: )[0-9.]+')
            local mac=$(echo "$line" | grep -oP '(?<=MAC Address: )[0-9A-F:]+')
            local vendor=$(echo "$line" | grep -oP '(?<=MAC Address: [0-9A-F:]+ \().*(?=\))')

            if [ -n "$mac" ] && is_raspberry_pi "$mac"; then
                ((rpi_count++))
                echo ""
                print_success "Found Raspberry Pi #$rpi_count"
                echo "  IP Address:  $ip"
                echo "  MAC Address: $mac"
                if [ -n "$vendor" ]; then
                    echo "  Vendor:      $vendor"
                fi

                # Try to get hostname
                local hostname=$(nmap -sn "$ip" 2>/dev/null | grep -i "host" | grep -v "Host is up" | awk '{print $NF}' | tr -d '()')
                if [ -n "$hostname" ] && [ "$hostname" != "$ip" ]; then
                    echo "  Hostname:    $hostname"
                fi
            fi
        fi
    done < "$temp_file"

    echo ""
    echo "=========================================="

    if [ $rpi_count -eq 0 ]; then
        print_warning "No Raspberry Pi devices found on network $network_range"
    else
        print_success "Total Raspberry Pi devices found: $rpi_count"
    fi

    # Cleanup
    rm -f "$temp_file"
}

# Main execution
main() {
    echo ""
    echo "=========================================="
    echo "  Raspberry Pi Network Discovery Tool"
    echo "=========================================="
    echo ""

    # Check prerequisites
    check_root
    check_dependencies

    # Determine network range to scan
    local network_range="$1"

    if [ -z "$network_range" ]; then
        print_info "No network range specified, auto-detecting..."
        network_range=$(get_network_range)

        if [ -z "$network_range" ]; then
            print_error "Could not auto-detect network range"
            print_info "Usage: sudo $0 [network_range]"
            print_info "Example: sudo $0 192.168.1.0/24"
            exit 1
        fi

        print_info "Auto-detected network range: $network_range"
    fi

    # Perform the scan
    scan_network "$network_range"

    echo ""
    print_info "Scan complete!"
    echo ""
}

# Run main function
main "$@"

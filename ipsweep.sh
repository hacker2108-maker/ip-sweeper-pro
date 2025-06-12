#!/bin/bash

###########################################################
#                      IP SWEEPER PRO                     #
#                   The Ultimate Network Scanner          #
#                                                         #
# Author: NetworkNinja                                    #
# Version: 2.0                                            #
# License: MIT                                            #
# GitHub: https://github.com/networkninja/ip-sweeper-pro  #
#                                                         #
# A powerful IP address scanning tool that helps you      #
# discover active hosts on your network quickly and       #
# efficiently.                                            #
###########################################################

# Color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner display
display_banner() {
    echo -e "${PURPLE}"
    echo "  ___ ____   ____  _      _____ ____  ______   ___  _____ "
    echo " |_ _|  _ \ / ___|| |    | ____|  _ \|  _ \ \ / / ||___ / "
    echo "  | || |_) | |  _ | |    |  _| | |_) | |_) \ V /| |  |_ \ "
    echo "  | ||  __/| |_| || |___ | |___|  __/|  __/ | | | |___| | "
    echo " |___|_|    \____||_____||_____|_|   |_|    |_| |_||____/ "
    echo -e "${NC}"
    echo -e "${CYAN}                     IP SWEEPER PRO v2.0${NC}"
    echo -e "${YELLOW}-----------------------------------------------------${NC}"
    echo -e "${BLUE}A comprehensive network scanning tool for professionals${NC}"
    echo -e "${YELLOW}-----------------------------------------------------${NC}"
    echo ""
}

# Help menu
show_help() {
    echo -e "${GREEN}Usage: $0 [OPTIONS]${NC}"
    echo ""
    echo "Options:"
    echo "  -h, --help            Show this help message"
    echo "  -n, --network NETWORK  Specify network (e.g., 192.168.1.0/24)"
    echo "  -r, --range START END  Specify IP range (e.g., 192.168.1.1 192.168.1.254)"
    echo "  -p, --ports PORTS      Specify ports to scan (comma separated)"
    echo "  -t, --timeout SECONDS  Set timeout in seconds (default: 1)"
    echo "  -c, --count COUNT      Set ping count (default: 1)"
    echo "  -o, --output FILE      Save results to file"
    echo "  -v, --verbose          Show detailed output"
    echo "  -f, --fast             Fast mode (no port scanning)"
    echo ""
    echo "Examples:"
    echo "  $0 -n 192.168.1.0/24"
    echo "  $0 -r 192.168.1.1 192.168.1.254 -p 22,80,443"
    echo "  $0 -n 10.0.0.0/24 -o scan_results.txt"
    echo ""
}

# Check if dependencies are installed
check_dependencies() {
    local missing=0
    local tools=("ping" "nc" "ipcalc")
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo -e "${RED}Error: $tool is not installed.${NC}"
            missing=1
        fi
    done
    
    if [ "$missing" -eq 1 ]; then
        echo -e "${YELLOW}Please install missing dependencies before running this script.${NC}"
        exit 1
    fi
}

# Validate IP address
validate_ip() {
    local ip=$1
    local stat=1
    
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && \
           ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    
    return $stat
}

# Validate CIDR notation
validate_cidr() {
    local cidr=$1
    if [[ $cidr =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        local network=$(echo $cidr | cut -d'/' -f1)
        local mask=$(echo $cidr | cut -d'/' -f2)
        if validate_ip $network && [ $mask -ge 0 ] && [ $mask -le 32 ]; then
            return 0
        fi
    fi
    return 1
}

# Calculate network range from CIDR
calculate_range_from_cidr() {
    local cidr=$1
    local network_info
    
    if command -v ipcalc &> /dev/null; then
        network_info=$(ipcalc -n -b -m -p $cidr)
        NETWORK=$(echo "$network_info" | grep "Network:" | awk '{print $2}')
        BROADCAST=$(echo "$network_info" | grep "Broadcast:" | awk '{print $2}')
        NETMASK=$(echo "$network_info" | grep "Netmask:" | awk '{print $2}')
        PREFIX=$(echo "$network_info" | grep "Prefix:" | awk '{print $2}')
        
        # Extract start and end IP
        IFS='/' read -r ip prefix <<< "$NETWORK"
        IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
        start_ip="$i1.$i2.$i3.$((i4 + 1))"
        
        IFS='.' read -r i1 i2 i3 i4 <<< "$BROADCAST"
        end_ip="$i1.$i2.$i3.$((i4 - 1))"
        
        echo -e "${BLUE}Network: $NETWORK${NC}"
        echo -e "${BLUE}Netmask: $NETMASK${NC}"
        echo -e "${BLUE}Broadcast: $BROADCAST${NC}"
        echo -e "${GREEN}Scanning range: $start_ip - $end_ip${NC}"
    else
        echo -e "${RED}Error: ipcalc is required for CIDR notation support.${NC}"
        exit 1
    fi
}

# Ping sweep
ping_sweep() {
    local start_ip=$1
    local end_ip=$2
    local count=$3
    local timeout=$4
    
    echo -e "${YELLOW}Starting ping sweep...${NC}"
    echo -e "${CYAN}Scanning IP range: $start_ip - $end_ip${NC}"
    echo -e "${CYAN}Ping count: $count, Timeout: ${timeout}s${NC}"
    echo ""
    
    # Extract network prefix
    IFS='.' read -r i1 i2 i3 i4 <<< "$start_ip"
    network_prefix="$i1.$i2.$i3."
    
    # Convert IPs to integers for iteration
    IFS='.' read -r a1 a2 a3 a4 <<< "$start_ip"
    IFS='.' read -r b1 b2 b3 b4 <<< "$end_ip"
    
    start=$((a1 * 256**3 + a2 * 256**2 + a3 * 256 + a4))
    end=$((b1 * 256**3 + b2 * 256**2 + b3 * 256 + b4))
    
    active_hosts=0
    total_hosts=$((end - start + 1))
    current_host=0
    
    # Create a temporary file for results
    temp_file=$(mktemp)
    
    # Loop through IP range
    for (( ip_int=start; ip_int<=end; ip_int++ )); do
        # Convert integer back to IP
        ip="$(( (ip_int >> 24) % 256 )).$(( (ip_int >> 16) % 256 )).$(( (ip_int >> 8) % 256 )).$(( ip_int % 256 ))"
        
        current_host=$((current_host + 1))
        progress=$((current_host * 100 / total_hosts))
        
        echo -ne "${BLUE}Scanning: $ip (${progress}%)${NC}\r"
        
        # Ping the IP
        if ping -c "$count" -W "$timeout" "$ip" &> /dev/null; then
            echo -e "${GREEN}Active host found: $ip${NC}"
            echo "$ip" >> "$temp_file"
            active_hosts=$((active_hosts + 1))
        fi
        
        # Verbose mode shows all attempts
        if [ "$VERBOSE" = true ]; then
            echo -e "${CYAN}Testing $ip...${NC}"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}Ping sweep completed. Found $active_hosts active hosts.${NC}"
    
    # Store active IPs in array
    mapfile -t ACTIVE_IPS < "$temp_file"
    rm "$temp_file"
}

# Port scanner
scan_ports() {
    local ip=$1
    local ports=$2
    local timeout=$3
    
    echo -e "${PURPLE}Scanning ports on $ip...${NC}"
    
    IFS=',' read -ra PORT_LIST <<< "$ports"
    
    open_ports=()
    for port in "${PORT_LIST[@]}"; do
        # Remove any whitespace
        port=$(echo "$port" | xargs)
        
        if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]; then
            if nc -z -w "$timeout" "$ip" "$port" &> /dev/null; then
                echo -e "${GREEN}Port $port is open${NC}"
                open_ports+=("$port")
            else
                if [ "$VERBOSE" = true ]; then
                    echo -e "${RED}Port $port is closed${NC}"
                fi
            fi
        else
            echo -e "${RED}Invalid port number: $port${NC}"
        fi
    done
    
    if [ "${#open_ports[@]}" -gt 0 ]; then
        echo "$ip: ${open_ports[*]}" >> "$OUTPUT_FILE"
    fi
}

# Main function
main() {
    display_banner
    check_dependencies
    
    # Default values
    NETWORK=""
    START_IP=""
    END_IP=""
    PORTS="22,80,443"
    TIMEOUT=1
    COUNT=1
    OUTPUT_FILE=""
    VERBOSE=false
    FAST_MODE=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -n|--network)
                NETWORK="$2"
                if ! validate_cidr "$NETWORK"; then
                    echo -e "${RED}Error: Invalid CIDR notation.${NC}"
                    exit 1
                fi
                calculate_range_from_cidr "$NETWORK"
                shift 2
                ;;
            -r|--range)
                START_IP="$2"
                END_IP="$3"
                if ! validate_ip "$START_IP" || ! validate_ip "$END_IP"; then
                    echo -e "${RED}Error: Invalid IP address in range.${NC}"
                    exit 1
                fi
                shift 3
                ;;
            -p|--ports)
                PORTS="$2"
                shift 2
                ;;
            -t|--timeout)
                TIMEOUT="$2"
                if ! [[ "$TIMEOUT" =~ ^[0-9]+$ ]]; then
                    echo -e "${RED}Error: Timeout must be a number.${NC}"
                    exit 1
                fi
                shift 2
                ;;
            -c|--count)
                COUNT="$2"
                if ! [[ "$COUNT" =~ ^[0-9]+$ ]]; then
                    echo -e "${RED}Error: Count must be a number.${NC}"
                    exit 1
                fi
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                touch "$OUTPUT_FILE" 2>/dev/null || {
                    echo -e "${RED}Error: Cannot write to output file.${NC}"
                    exit 1
                }
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -f|--fast)
                FAST_MODE=true
                shift
                ;;
            *)
                echo -e "${RED}Error: Unknown option $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validate we have either network or range
    if [ -z "$NETWORK" ] && [ -z "$START_IP" ]; then
        echo -e "${RED}Error: You must specify either a network or IP range.${NC}"
        show_help
        exit 1
    fi
    
    # Perform ping sweep
    ping_sweep "$start_ip" "$end_ip" "$COUNT" "$TIMEOUT"
    
    # Perform port scanning if not in fast mode
    if [ "$FAST_MODE" = false ] && [ "${#ACTIVE_IPS[@]}" -gt 0 ]; then
        echo -e "${YELLOW}Starting port scanning...${NC}"
        
        for ip in "${ACTIVE_IPS[@]}"; do
            scan_ports "$ip" "$PORTS" "$TIMEOUT"
        done
        
        echo -e "${YELLOW}Port scanning completed.${NC}"
    fi
    
    # Save results if output file specified
    if [ -n "$OUTPUT_FILE" ]; then
        echo -e "${GREEN}Results saved to $OUTPUT_FILE${NC}"
    fi
    
    echo -e "${CYAN}Scan completed successfully.${NC}"
}

# Run main function
main "$@"

exit 0
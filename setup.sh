#!/bin/bash

# IP Sweeper Pro Setup Script
# This script installs all required dependencies for the IP Sweeper Pro tool

# Color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner display
display_banner() {
    echo -e "${BLUE}"
    echo "  ___ ____   ____  _      _____ ____  ______   ___  _____ "
    echo " |_ _|  _ \ / ___|| |    | ____|  _ \|  _ \ \ / / ||___ / "
    echo "  | || |_) | |  _ | |    |  _| | |_) | |_) \ V /| |  |_ \ "
    echo "  | ||  __/| |_| || |___ | |___|  __/|  __/ | | | |___| | "
    echo " |___|_|    \____||_____||_____|_|   |_|    |_| |_||____/ "
    echo -e "${NC}"
    echo -e "${YELLOW}IP Sweeper Pro Dependency Installer${NC}"
    echo -e "${YELLOW}-----------------------------------${NC}"
    echo ""
}

# Check if script is run as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}Error: This script must be run as root.${NC}"
        echo -e "${YELLOW}Try running with sudo: sudo ./setup.sh${NC}"
        exit 1
    fi
}

# Detect package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        PACKAGE_MANAGER="apt-get"
        INSTALL_CMD="apt-get install -y"
    elif command -v yum &> /dev/null; then
        PACKAGE_MANAGER="yum"
        INSTALL_CMD="yum install -y"
    elif command -v dnf &> /dev/null; then
        PACKAGE_MANAGER="dnf"
        INSTALL_CMD="dnf install -y"
    elif command -v pacman &> /dev/null; then
        PACKAGE_MANAGER="pacman"
        INSTALL_CMD="pacman -S --noconfirm"
    elif command -v zypper &> /dev/null; then
        PACKAGE_MANAGER="zypper"
        INSTALL_CMD="zypper install -y"
    else
        echo -e "${RED}Error: Could not detect package manager.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Detected package manager: ${PACKAGE_MANAGER}${NC}"
}

# Update package lists
update_packages() {
    echo -e "${YELLOW}Updating package lists...${NC}"
    if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
        apt-get update
    elif [ "$PACKAGE_MANAGER" = "yum" ] || [ "$PACKAGE_MANAGER" = "dnf" ]; then
        $PACKAGE_MANAGER makecache
    elif [ "$PACKAGE_MANAGER" = "pacman" ]; then
        pacman -Sy
    fi
    echo -e "${GREEN}Package lists updated.${NC}"
}

# Install core dependencies
install_core_dependencies() {
    local packages=("iputils-ping" "netcat-openbsd" "ipcalc")
    
    # Adjust package names for different distros
    if [ "$PACKAGE_MANAGER" = "yum" ] || [ "$PACKAGE_MANAGER" = "dnf" ]; then
        packages=("iputils" "nmap-ncat" "ipcalc")
    elif [ "$PACKAGE_MANAGER" = "pacman" ]; then
        packages=("iputils" "gnu-netcat" "ipcalc")
    fi
    
    echo -e "${YELLOW}Installing core dependencies...${NC}"
    for pkg in "${packages[@]}"; do
        echo -e "${BLUE}Installing $pkg...${NC}"
        if ! $INSTALL_CMD "$pkg"; then
            echo -e "${RED}Failed to install $pkg${NC}"
            exit 1
        fi
    done
    echo -e "${GREEN}Core dependencies installed.${NC}"
}

# Install optional dependencies
install_optional_dependencies() {
    local optional_packages=("nmap" "tcpdump" "net-tools")
    
    echo -e "${YELLOW}Installing optional dependencies...${NC}"
    for pkg in "${optional_packages[@]}"; do
        echo -e "${BLUE}Installing $pkg (optional)...${NC}"
        $INSTALL_CMD "$pkg" || echo -e "${YELLOW}Warning: Failed to install optional package $pkg${NC}"
    done
    echo -e "${GREEN}Optional dependencies installed.${NC}"
}

# Verify installations
verify_installations() {
    echo -e "${YELLOW}Verifying installations...${NC}"
    
    local tools=("ping" "nc" "ipcalc")
    local missing=0
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo -e "${RED}Error: $tool is not installed.${NC}"
            missing=1
        else
            echo -e "${GREEN}$tool is installed.${NC}"
        fi
    done
    
    if [ "$missing" -eq 1 ]; then
        echo -e "${RED}Some dependencies failed to install.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}All required tools are installed.${NC}"
}

# Main function
main() {
    display_banner
    check_root
    detect_package_manager
    update_packages
    install_core_dependencies
    install_optional_dependencies
    verify_installations
    
    echo -e "${GREEN}\nIP Sweeper Pro dependencies successfully installed!${NC}"
    echo -e "${YELLOW}You can now run the IP Sweeper Pro tool.${NC}"
    echo -e "${BLUE}Example: ./ipsweep.sh -n 192.168.1.0/24${NC}"
}

# Run main function
main

exit 0
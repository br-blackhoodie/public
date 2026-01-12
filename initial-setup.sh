#!/bin/bash
#
# AKE Platform - Initial Node Setup
# This script prepares a node for AKE deployment by:
# - Installing and configuring SSH server
# - Creating the 'ake' user with sudo privileges
# - Configuring firewall rules
#
# Run this script on each node BEFORE running 'ake install'
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "AKE Platform - Initial Node Setup"
echo "================================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo "Please run: sudo $0"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}Error: Cannot detect operating system${NC}"
    exit 1
fi

echo -e "${GREEN}Detected OS: $PRETTY_NAME${NC}"
echo ""

# Step 1: Install OpenSSH Server
echo "Step 1: Installing OpenSSH Server..."
case "$OS" in
    ubuntu|debian)
        apt-get update -qq
        DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server
        ;;
    centos|rhel|rocky|almalinux)
        yum install -y openssh-server
        ;;
    fedora)
        dnf install -y openssh-server
        ;;
    *)
        echo -e "${RED}Error: Unsupported OS: $OS${NC}"
        exit 1
        ;;
esac
echo -e "${GREEN}✓ OpenSSH Server installed${NC}"
echo ""

# Step 2: Create 'ake' user
echo "Step 2: Creating 'ake' user..."
if id "ake" &>/dev/null; then
    echo -e "${YELLOW}User 'ake' already exists, updating password...${NC}"
    echo "ake:ake" | chpasswd
else
    useradd -m -s /bin/bash ake
    echo "ake:ake" | chpasswd
    echo -e "${GREEN}✓ User 'ake' created with password 'ake'${NC}"
fi
echo ""

# Step 3: Configure sudo for 'ake' user
echo "Step 3: Configuring sudo privileges..."
if [ ! -f /etc/sudoers.d/ake ]; then
    echo "ake ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ake
    chmod 0440 /etc/sudoers.d/ake
    echo -e "${GREEN}✓ Sudo configured for 'ake' user${NC}"
else
    echo -e "${YELLOW}Sudo already configured for 'ake'${NC}"
fi
echo ""

# Step 4: Configure SSH
echo "Step 4: Configuring SSH..."
# Ensure SSH is enabled and started
systemctl enable sshd 2>/dev/null || systemctl enable ssh 2>/dev/null
systemctl start sshd 2>/dev/null || systemctl start ssh 2>/dev/null

# Allow password authentication (required for Ansible)
sed -i 's/^#*PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Restart SSH to apply changes
systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null
echo -e "${GREEN}✓ SSH configured and running${NC}"
echo ""

# Step 5: Configure firewall (if present)
echo "Step 5: Configuring firewall..."
if command -v ufw &> /dev/null; then
    # Ubuntu/Debian UFW
    ufw allow 22/tcp >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ UFW firewall configured${NC}"
elif command -v firewall-cmd &> /dev/null; then
    # RHEL/CentOS firewalld
    firewall-cmd --permanent --add-service=ssh >/dev/null 2>&1 || true
    firewall-cmd --reload >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ Firewalld configured${NC}"
else
    echo -e "${YELLOW}No firewall detected, skipping...${NC}"
fi
echo ""

# Summary
echo "================================================"
echo -e "${GREEN}Setup completed successfully!${NC}"
echo "================================================"
echo ""
echo "Node is now ready for AKE deployment:"
echo "  - SSH server running on port 22"
echo "  - User: ake"
echo "  - Password: ake"
echo "  - Sudo: enabled (no password required)"
echo ""
echo -e "${YELLOW}IMPORTANT: Change the 'ake' user password in production!${NC}"
echo "Run: passwd ake"
echo ""
echo "You can now run 'ake install' from your control machine."
echo ""

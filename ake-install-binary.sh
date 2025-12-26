#!/bin/bash
#
# AKE Platform Installer - Binary Installation Script
# One-command installation: curl -fsSL <url> | sudo -E bash
# BlackHoodie Corporation
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="${INSTALL_DIR:-/opt/ake}"
BINARY_URL="${BINARY_URL:-https://github.com/br-blackhoodie/public/releases/latest/download/ake}"
ANSIBLE_REPO="https://gitlab.com/devsecops-ntsec/platform/platform-control.git"
ANSIBLE_PATH="08 - Platforms & Orchestration/rke2"

# Banner
cat << 'BANNER'
    ___    __ __ ______
   /   |  / //_// ____/
  / /| | / ,<  / __/
 / ___ |/ /| |/ /___
/_/  |_/_/ |_/_____/

AKE Platform Installer v2.0.0
Agnostic Kubernetes Everywhere
BlackHoodie Corporation
BANNER

echo
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Installing AKE Platform Installer${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ This script must be run as root (use sudo)${NC}"
   exit 1
fi

# Check OS
if ! grep -qE "(Ubuntu|Debian)" /etc/os-release 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Warning: This installer is tested on Ubuntu/Debian${NC}"
fi

echo -e "${GREEN}→${NC} Creating installation directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download binary
echo -e "${GREEN}→${NC} Downloading AKE installer binary..."
curl -fsSL "$BINARY_URL" -o "$INSTALL_DIR/ake-installer"
chmod +x "$INSTALL_DIR/ake-installer"

# Create symlink
echo -e "${GREEN}→${NC} Creating /usr/local/bin/ake symlink..."
ln -sf "$INSTALL_DIR/ake-installer" /usr/local/bin/ake

# Install Ansible if not present
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${GREEN}→${NC} Installing Ansible..."
    apt update -qq
    apt install -y ansible sshpass python3-pip >/dev/null 2>&1
    echo -e "${GREEN}✓${NC} Ansible installed"
else
    echo -e "${GREEN}✓${NC} Ansible already installed"
fi

# Clone Ansible repository if subscription key provided
if [ -n "$AKE_SUBSCRIPTION_KEY" ]; then
    echo -e "${GREEN}→${NC} Setting up Ansible playbooks..."
    mkdir -p "$INSTALL_DIR/ansible"

    # This would clone the repo using the subscription key
    # For now, just create the structure
    echo -e "${YELLOW}⚠️  Subscription-based sync will be configured on first run${NC}"
fi

# Create .env file if keys provided
if [ -n "$AKE_AI_API_KEY" ] || [ -n "$AKE_SUBSCRIPTION_KEY" ]; then
    echo -e "${GREEN}→${NC} Saving environment configuration..."
    cat > "$INSTALL_DIR/.env" << EOF
# AKE Platform Installer Configuration
# Generated on $(date)

EOF

    if [ -n "$AKE_AI_API_KEY" ]; then
        echo "export AKE_AI_API_KEY=\"$AKE_AI_API_KEY\"" >> "$INSTALL_DIR/.env"
    fi

    if [ -n "$AKE_SUBSCRIPTION_KEY" ]; then
        echo "export AKE_SUBSCRIPTION_KEY=\"$AKE_SUBSCRIPTION_KEY\"" >> "$INSTALL_DIR/.env"
    fi

    chmod 600 "$INSTALL_DIR/.env"
    echo -e "${GREEN}✓${NC} Configuration saved to $INSTALL_DIR/.env"
fi

echo
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo
echo -e "Binary installed at: ${BLUE}/usr/local/bin/ake${NC}"
echo

# Show configuration status
if [ -z "$AKE_AI_API_KEY" ]; then
    echo -e "${YELLOW}⚠️  AKE AI API Key not configured${NC}"
    echo
    echo "To configure your API key:"
    echo -e "  ${BLUE}echo 'export AKE_AI_API_KEY=\"sk-ant-...\"' >> $INSTALL_DIR/.env${NC}"
    echo
fi

if [ -z "$AKE_SUBSCRIPTION_KEY" ]; then
    echo -e "${YELLOW}ℹ️  AKE Subscription Key not configured (optional)${NC}"
    echo
    echo "For platform sync, configure your subscription key:"
    echo -e "  ${BLUE}echo 'export AKE_SUBSCRIPTION_KEY=\"ake-sub-...\"' >> $INSTALL_DIR/.env${NC}"
    echo
    echo "Contact BlackHoodie Corporation to obtain credentials."
    echo
fi

echo "To start the installer:"
echo -e "  ${GREEN}source $INSTALL_DIR/.env && ake${NC}"
echo
echo "Or with inline configuration:"
echo -e "  ${GREEN}AKE_AI_API_KEY='sk-ant-...' ake${NC}"
echo

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo

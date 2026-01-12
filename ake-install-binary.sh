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
BINARY_URL="${BINARY_URL:-https://api.github.com/repos/br-blackhoodie/public/contents/ake-installer}"

# Banner
cat << 'BANNER'
    ___    __ __ ______
   /   |  / //_// ____/
  / /| | / ,<  / __/
 / ___ |/ /| |/ /___
/_/  |_/_/ |_/_____/

AKE Platform Installer v3.6.0
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

# Download binary (using GitHub API to avoid CDN cache)
echo -e "${GREEN}→${NC} Downloading AKE installer binary..."
curl -fsSL -H "Accept: application/vnd.github.v3.raw" "$BINARY_URL" -o "$INSTALL_DIR/ake-installer"
chmod +x "$INSTALL_DIR/ake-installer"

# Create symlink
echo -e "${GREEN}→${NC} Creating /usr/local/bin/ake symlink..."
ln -sf "$INSTALL_DIR/ake-installer" /usr/local/bin/ake

# Install automation tools if not present
if ! command -v ansible-playbook &> /dev/null || ! command -v sshpass &> /dev/null; then
    echo -e "${GREEN}→${NC} Installing automation tools..."
    apt update -qq
    apt install -y ansible sshpass python3-pip >/dev/null 2>&1
    echo -e "${GREEN}✓${NC} Automation tools installed"
else
    echo -e "${GREEN}✓${NC} Automation tools already installed"
fi

# Save subscription key if provided
if [ -n "$AKE_SUBSCRIPTION_KEY" ]; then
    echo -e "${GREEN}→${NC} Saving subscription key..."
    cat > "$INSTALL_DIR/.env" << EOF
# AKE Platform Installer Configuration
# Generated on $(date)

export AKE_SUBSCRIPTION_KEY="$AKE_SUBSCRIPTION_KEY"
EOF
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

# Show next steps
if [ -z "$AKE_SUBSCRIPTION_KEY" ]; then
    echo -e "${YELLOW}ℹ️  Subscription key not configured${NC}"
    echo
    echo "To configure your subscription key:"
    echo -e "  ${BLUE}export AKE_SUBSCRIPTION_KEY=\"ake-sub-...\"${NC}"
    echo
    echo "Contact BlackHoodie Corporation to obtain credentials."
    echo
fi

echo "Next steps:"
echo -e "  1. Create config file: ${BLUE}vi /opt/ake/config.yaml${NC}"
echo -e "  2. Run installer: ${GREEN}ake install --config /opt/ake/config.yaml${NC}"
echo
echo -e "For help: ${BLUE}ake help${NC}"
echo

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo

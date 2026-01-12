# AKE Platform Installer

Automated installer for the AKE Platform.

## Installation

### One-command installation

```bash
curl -fsSL https://raw.githubusercontent.com/br-blackhoodie/public/main/ake-install-binary.sh | sudo -E bash
```

### With inline configuration

```bash
curl -fsSL https://raw.githubusercontent.com/br-blackhoodie/public/main/ake-install-binary.sh | \
  AKE_AI_API_KEY="sk-ant-..." \
  AKE_SUBSCRIPTION_KEY="ake-sub-..." \
  sudo -E bash
```

## System Requirements

### Control Machine (where you run AKE)

- **Operating System**: Linux (Ubuntu 20.04+, Debian 11+, RHEL 8+)
- **Privileges**: Root/sudo access
- **Credentials**: Contact BlackHoodie Corporation to obtain access keys

### Target Nodes (where Kubernetes will be deployed)

**IMPORTANT: Each target node must have SSH access configured before running `ake install`**

**Node Requirements:**
- Ubuntu 20.04+, Debian 11+, or RHEL 8+
- Minimum: 4 CPU cores, 8GB RAM, 100GB disk
- SSH server running and accessible
- User `ake` with password `ake` and sudo privileges (no password)

### Preparing Target Nodes

Run this command on **each target node** to configure SSH and create the `ake` user:

```bash
curl -fsSL https://raw.githubusercontent.com/br-blackhoodie/public/main/initial-setup.sh | sudo bash
```

Or download and run manually:

```bash
curl -O https://raw.githubusercontent.com/br-blackhoodie/public/main/initial-setup.sh
chmod +x initial-setup.sh
sudo ./initial-setup.sh
```

**What this script does:**
- Installs and configures SSH server
- Creates user `ake` with password `ake`
- Grants sudo privileges to `ake` user
- Configures firewall rules

**IMPORTANT:** Change the `ake` user password in production environments!

## How to Use

### 1. Install AKE

```bash
curl -fsSL https://raw.githubusercontent.com/br-blackhoodie/public/main/ake-install-binary.sh | sudo -E bash
```

The installer will be placed in `/usr/local/bin/ake`.

### 2. Configure your keys

```bash
# AKE AI API Key (for AI assistant)
echo 'export AKE_AI_API_KEY="sk-ant-..."' >> /opt/ake/.env

# AKE Platform Subscription Key (provided by BlackHoodie)
echo 'export AKE_SUBSCRIPTION_KEY="ake-sub-..."' >> /opt/ake/.env
```

### 3. Run the installer

```bash
source /opt/ake/.env
ake
```

Or inline:

```bash
AKE_AI_API_KEY="sk-ant-..." AKE_SUBSCRIPTION_KEY="ake-sub-..." ake
```

## Commands

```bash
ake install    # Interactive installation
ake apply      # Apply configuration
ake version    # Check version
```

## Configuration

### Environment variables

```bash
# Required
export AKE_AI_API_KEY="sk-ant-..."             # AKE AI API

# Optional
export AKE_SUBSCRIPTION_KEY="ake-sub-..."      # AKE Subscription
export INSTALL_DIR="/custom/path"              # Custom directory
```

## Credentials

Contact BlackHoodie Corporation to obtain:
- **AKE AI API Key** - Access key for AI assistant
- **AKE Subscription Key** - Platform subscription key

**Email**: contato@blackhoodie.com.br
**Website**: https://blackhoodie.com.br

## Support

For technical support or questions:

- **Email**: suporte@blackhoodie.com.br
- **GitHub Issues**: https://github.com/br-blackhoodie/public/issues

## License

Property of BlackHoodie Corporation

---

**Developed by BlackHoodie Corporation**

# AKE Platform Installer

Automated installer for the AKE Platform - Kubernetes deployment with GitOps.

## Quick Start

### 1. Prepare all target nodes

Run on **each server** (bootstrap, servers, and workers):

```bash
curl -fsSL https://raw.githubusercontent.com/br-blackhoodie/public/main/initial-setup.sh | sudo bash
```

### 2. Install AKE on bootstrap node

Run on the **bootstrap node only**:

```bash
curl -fsSL https://raw.githubusercontent.com/br-blackhoodie/public/main/ake-install-binary.sh | sudo -E bash
```

### 3. Create configuration file

Create `/opt/ake/config.yaml`:

```yaml
client_name: myproject

bootstrap:
  hostname: bootstrap01
  ip: 192.168.1.10

servers:
  - hostname: server01
    ip: 192.168.1.11
  - hostname: server02
    ip: 192.168.1.12

agents:
  - hostname: worker01
    ip: 192.168.1.20
  - hostname: worker02
    ip: 192.168.1.21

network:
  interface: eth0
  cluster_cidr: 10.42.0.0/16
  service_cidr: 10.43.0.0/16
  loadbalancer_pool: ""  # Empty for cloud/public IPs
```

### 4. Configure subscription key and run

```bash
export AKE_SUBSCRIPTION_KEY="ake-sub-..."
ake install --config /opt/ake/config.yaml
```

---

## Configuration File Reference

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `client_name` | Yes | - | Project/cluster name (lowercase) |
| `bootstrap.hostname` | No | bootstrap01 | Bootstrap node hostname |
| `bootstrap.ip` | Yes | - | Bootstrap node IP address |
| `servers` | No | [] | Additional control plane nodes |
| `agents` | No | [] | Worker nodes |
| `network.interface` | No | eth0 | Network interface |
| `network.cluster_cidr` | No | 10.42.0.0/16 | Pod network CIDR |
| `network.service_cidr` | No | 10.43.0.0/16 | Service network CIDR |
| `network.loadbalancer_pool` | No | "" | LoadBalancer IP pool (empty for cloud) |

---

## System Requirements

### All Nodes

- **OS**: Ubuntu 20.04+, Debian 11+, or RHEL 8+
- **Minimum**: 4 CPU cores, 8GB RAM, 100GB disk
- **User**: `ake` with password `ake` and passwordless sudo
- **SSH**: Accessible from bootstrap node

---

## Commands

| Command | Description |
|---------|-------------|
| `ake install --config FILE` | Install cluster from config file |
| `ake apply` | Re-apply existing configuration |
| `ake help` | Show help and example config |
| `ake version` | Show version |

---

## Example Configurations

### Minimal (single node)

```yaml
client_name: dev
bootstrap:
  ip: 192.168.1.10
```

### HA Cluster (3 control plane)

```yaml
client_name: production
bootstrap:
  hostname: master1
  ip: 10.0.0.10
servers:
  - hostname: master2
    ip: 10.0.0.11
  - hostname: master3
    ip: 10.0.0.12
network:
  interface: ens192
```

### Full Cluster with Workers

```yaml
client_name: enterprise
bootstrap:
  hostname: cp1
  ip: 10.0.0.10
servers:
  - hostname: cp2
    ip: 10.0.0.11
  - hostname: cp3
    ip: 10.0.0.12
agents:
  - hostname: worker1
    ip: 10.0.0.20
  - hostname: worker2
    ip: 10.0.0.21
  - hostname: worker3
    ip: 10.0.0.22
network:
  interface: eth0
  loadbalancer_pool: "10.0.0.240/29"
```

---

## Support

Contact BlackHoodie Corporation:
- **Email**: contato@blackhoodie.com.br
- **Website**: https://blackhoodie.com.br

---

## License

Property of BlackHoodie Corporation

# Network overview

This document describes the physical and logical layout of my home network.
The network is designed to be simple but segmented with IoT devices isolated from the main LAN

---

# Hardware

The network consists of the following core devices:
| Device | Purpose |
| Unifi Dream Router | Router, Firewall and network controller |
| Unifi 16 port switch | Core Switching for  wired devices |
| Unifi 4 prot switch | Provides additional switching for wired devices + one of the AP's |
| 3x Unifi WAPs | Provides connectivity for wireless devices |
| Proxmox cluster (PVE1-PVE3) | Virtualisation environment |
| NAS | Network storage and backups for local PC's as well as the Proxmox cluster |
| NVR | Video recording for security cameras |

---

# Network segmentation

The network uses VLANs to isolate less trusted devices as well as seperate out cameras
| Network | Purpose | Subnet
| Main LAN | Primary home network | 192.168.1.0/24 |
| NVR/ Cameras | Security Cameras and NVR | 192.168.2.0/24 |
| IoT | IoT and smart home devices | 192.168.1.0/24 |

---

# Wireless Networks

Access points broadcast two main SSIDs:

| SSID | Network |
| Korn | Main LAN |
| Korn smarthome | IoT VLAN |

Devices connect to the appropriate network based on trust level. Korn smarthome also only broadcasts on 2.4GHz to maintain availability for some IoT devices.

# Core infrastructure 

The proxmox cluster provides the main computer resources in the network

Nodes: 

- PVE1
- PVE2
- PVE3

---

# Design goals:

- simplicity
- security through segmentation
- easy expansion for homelab infrastructure
- reliable wireless coverage

---

# Future improvement

Potential future improvements include:

- Additional VLANs for lab expermiments
- Dedicated monitoring network
- Improved network documentation and automation

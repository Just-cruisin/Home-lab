# Lab 12 - Cisco Packet Tracer - Wireless Networking

## Wireless Fundamentals

### 802.11 Standards
| Standard | Frequency | Max Speed |
|---|---|---|
| 802.11b | 2.4 GHz | 11 Mbps |
| 802.11g | 2.4 GHz | 54 Mbps |
| 802.11a | 5 GHz | 54 Mbps |
| 802.11n | 2.4 / 5 GHz | 600 Mbps+ |
| 802.11ac | 5 GHz only | 3.5 Gbps+ |
| 802.11ax | 2.4 / 5 GHz | 9.6 Gbps+ |

### AP Modes
- **Autonomous AP** — self-contained, handles channel selection, roaming decisions, and config locally
- **Lightweight AP (LAP)** — relies on a Wireless LAN Controller (WLC) for all intelligence, AP handles RF only

### Security Standards
| Mode | Also called | Authentication |
|---|---|---|
| WPA2-Personal | WPA2-PSK | Shared password for everyone |
| WPA2-Enterprise | WPA2-802.1X | Individual credentials via RADIUS server |

- WPA2 uses AES encryption
- WPA3-Personal replaces PSK with SAE (Simultaneous Authentication of Equals) — protects against offline dictionary attacks
- WPA3-Enterprise adds 192-bit encryption

### 2.4GHz Channel Planning
Channels in 2.4GHz are 5MHz apart but each channel is 22MHz wide — adjacent channels overlap and cause interference.
Only three non-overlapping channels exist: **1, 6, 11**
Always assign neighbouring APs to different non-overlapping channels to minimise interference.

---

## Topology

```
Tablet PC0 (VLAN 10) )))
                          AP1 (ch6) --access VLAN10-- SW1 --trunk-- R1
                                                       |
                                                      PC0 (wired)
                                                       |
Tablet PC1 (VLAN 20) )))
                          AP2 (ch11) --access VLAN20-- SW1
```

### Device Summary
| Device | Role | Connection |
|---|---|---|
| R1 | Router, DHCP server | Gi0/0 trunk to SW1 Fa0/24 |
| SW1 | Layer 2 switch | Trunk to R1, access ports to APs |
| AP1 | SSID HomeNetwork, ch6 | SW1 Fa0/2 (access VLAN 10) |
| AP2 | SSID GuestNetwork, ch11 | SW1 Fa0/3 (access VLAN 20) |
| Tablet PC0 | Main wireless client | Associated to AP1 |
| Tablet PC1 | Guest wireless client | Associated to AP2 |
| PC0 | Wired client | SW1 Fa0/1 |

---

## Part 1 - Basic Wireless Setup

### AP Configuration (GUI - Config tab - Port 1)
```
SSID: HomeNetwork
Channel: 6
Authentication: WPA2-PSK
PSK Pass Phrase: Cisco12345
Encryption: AES
```

### Router Configuration
```
interface Gi0/0
 ip address 192.168.1.1 255.255.255.0
 no shutdown

ip dhcp pool WIRELESS
 network 192.168.1.0 255.255.255.0
 default-router 192.168.1.1

ip dhcp excluded-address 192.168.1.1 192.168.1.10
```

### Key Learnings - Basic Wireless
- AP handles Layer 2 association — tablet connects wirelessly to AP
- Router provides DHCP — AP does not run its own DHCP server in a real network
- Centralised DHCP avoids conflicts and survives individual AP failure

---

## Part 2 - Multiple SSIDs with VLANs and Guest Isolation

### Objective
Separate main and guest wireless traffic using VLANs, with ACL-based guest isolation
preventing guest devices from reaching the main network.

### VLAN Plan
| VLAN | Name | Subnet | SSID |
|---|---|---|---|
| 10 | MAIN | 192.168.10.0/24 | HomeNetwork |
| 20 | GUEST | 192.168.20.0/24 | GuestNetwork |

### Switch Configuration
```
vlan 10
 name MAIN
vlan 20
 name GUEST

! Trunk to router
interface Fa0/24
 switchport mode trunk

! AP1 - main network
interface Fa0/2
 switchport mode access
 switchport access vlan 10

! AP2 - guest network
interface Fa0/3
 switchport mode access
 switchport access vlan 20
```

Note: AP-PT in Packet Tracer does not support VLAN tagging per SSID.
In production, the AP-to-switch link would be a trunk and each SSID would
be mapped to a VLAN using `dot11 ssid <name> / vlan <id>` on a real Cisco AP.

### Router Configuration
```
! Remove old interface IP and DHCP pool
no ip dhcp pool WIRELESS

! Subinterfaces for router-on-a-stick
interface Gi0/0.10
 encapsulation dot1Q 10
 ip address 192.168.10.1 255.255.255.0

interface Gi0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.1 255.255.255.0

! DHCP pools per VLAN
ip dhcp pool MAIN
 network 192.168.10.0 255.255.255.0
 default-router 192.168.10.1

ip dhcp pool GUEST
 network 192.168.20.0 255.255.255.0
 default-router 192.168.20.1

ip dhcp excluded-address 192.168.10.1 192.168.10.10
ip dhcp excluded-address 192.168.20.1 192.168.20.10
```

### Guest Isolation ACL
```
! Block guest from reaching main network, permit everything else
ip access-list extended GUEST_ISOLATION
 deny ip 192.168.20.0 0.0.0.255 192.168.10.0 0.0.0.255
 permit ip any any

! Apply inbound on guest subinterface
interface Gi0/0.20
 ip access-group GUEST_ISOLATION in
```

### Verification
```
! Check DHCP leases
R1# show ip dhcp binding

! Check subinterfaces
R1# show ip interface brief

! Check ACL hits
R1# show ip access-lists
```

### Key Learnings
- VLANs separate traffic at Layer 2 — guest and main clients are in different broadcast domains
- ACLs enforce security at Layer 3 — without ACL, router forwards between VLANs freely
- Guest isolation ACL applied inbound on guest subinterface blocks traffic before routing decision
- Channel planning: use channels 1, 6, 11 on 2.4GHz to avoid co-channel interference
- In production: AP-to-switch link is a trunk, each SSID tagged to a VLAN on the AP itself
- Linux equivalent: `hostapd` for AP functionality, `iptables` for guest isolation

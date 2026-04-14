# Capstone Lab - Multi-Site Enterprise Network

## Overview
A complete multi-site enterprise network connecting two geographically separate
offices over a simulated internet. Each site has VLANs, wireless, security, and
NAT. Sites are connected via a GRE tunnel with OSPF dynamic routing.

## Features Implemented
- VLANs with router-on-a-stick at each site
- WPA2-PSK wireless with guest SSID
- Guest network isolation via ACL
- Port security on access ports
- DHCP snooping and Dynamic ARP Inspection
- NAT/PAT for internet access at both sites
- GRE tunnel between sites over simulated internet
- OSPF dynamic routing over GRE tunnel
- Centralised web server simulating internet resource

---

## Topology

```
                    SITE A (HQ)                          SITE B (Branch)

VLAN 10 Mgmt (192.168.20.0/24)              VLAN 10 Mgmt (192.168.50.0/24)
VLAN 20 Staff (192.168.10.0/24)             VLAN 20 Staff (192.168.40.0/24)
VLAN 30 Guest (192.168.30.0/24)             VLAN 30 Guest (192.168.60.0/24)
         |                                            |
   [SW-A 2960]                                  [SW-B 2960]
         |                                            |
   [R-A 2911]                                   [R-B 2911]
   203.0.113.2/30                             203.0.113.6/30
         |                                            |
         +-------------- [ISP Router] ----------------+
                         203.0.113.1/30  203.0.113.5/30
                               |
                         [Web Server]
                         203.0.113.10

GRE Tunnel: R-A Tunnel0 (10.10.10.1/30) <-----> R-B Tunnel0 (10.10.10.2/30)
OSPF runs over tunnel — each site advertises its internal subnets
```

---

## IP Addressing

### Site A
| Device | Interface | IP Address |
|---|---|---|
| R-A | Gi0/0.10 (MGMT) | 192.168.20.1/24 |
| R-A | Gi0/0.20 (STAFF) | 192.168.10.1/24 |
| R-A | Gi0/0.30 (GUEST) | 192.168.30.1/24 |
| R-A | Gi0/1 (WAN) | 203.0.113.2/30 |
| R-A | Tunnel0 | 10.10.10.1/30 |
| SW-A | VLAN 1 | 192.168.20.2/24 |

### Site B
| Device | Interface | IP Address |
|---|---|---|
| R-B | Gi0/0.10 (MGMT) | 192.168.50.1/24 |
| R-B | Gi0/0.20 (STAFF) | 192.168.40.1/24 |
| R-B | Gi0/0.30 (GUEST) | 192.168.60.1/24 |
| R-B | Gi0/1 (WAN) | 203.0.113.6/30 |
| R-B | Tunnel0 | 10.10.10.2/30 |
| SW-B | VLAN 1 | 192.168.50.2/24 |

### Internet
| Device | Interface | IP Address |
|---|---|---|
| ISP | Gi0/0 | 203.0.113.1/30 |
| ISP | Gi0/1 | 203.0.113.5/30 |
| ISP | Gi0/2 | 203.0.113.9/30 |
| Web Server | Fa0 | 203.0.113.10/30 |

---

## Configuration

### Switch (SW-A and SW-B — identical structure)

VLANs
```
vlan 10
 name MANAGEMENT
vlan 20
 name STAFF
vlan 30
 name GUEST
```

Access ports and trunk
```
interface Fa0/1
 switchport mode access
 switchport access vlan 20

interface Fa0/2
 switchport mode access
 switchport access vlan 10

interface Fa0/3
 switchport mode access
 switchport access vlan 30

interface Fa0/24
 switchport mode trunk
```

Port security on staff and management ports
```
interface range Fa0/1 - 2
 switchport port-security
 switchport port-security maximum 1
 switchport port-security violation shutdown
 switchport port-security mac-address sticky
```

DHCP snooping and DAI (adjust VLAN numbers for Site B)
```
ip dhcp snooping
ip dhcp snooping vlan 10,20,30
no ip dhcp snooping information option

ip arp inspection vlan 10,20,30

interface Fa0/24
 ip dhcp snooping trust
 ip arp inspection trust
```

---

### Router A (R-A)

Subinterfaces for router-on-a-stick
```
interface Gi0/0
 no shutdown

interface Gi0/0.10
 encapsulation dot1Q 10
 ip address 192.168.20.1 255.255.255.0
 ip nat inside

interface Gi0/0.20
 encapsulation dot1Q 20
 ip address 192.168.10.1 255.255.255.0
 ip nat inside

interface Gi0/0.30
 encapsulation dot1Q 30
 ip address 192.168.30.1 255.255.255.0
 ip nat inside

interface Gi0/1
 ip address 203.0.113.2 255.255.255.252
 ip nat outside
 no shutdown
```

DHCP pools
```
ip dhcp excluded-address 192.168.10.1 192.168.10.10
ip dhcp excluded-address 192.168.20.1 192.168.20.10
ip dhcp excluded-address 192.168.30.1 192.168.30.10

ip dhcp pool STAFF
 network 192.168.10.0 255.255.255.0
 default-router 192.168.10.1

ip dhcp pool MANAGEMENT
 network 192.168.20.0 255.255.255.0
 default-router 192.168.20.1

ip dhcp pool GUEST
 network 192.168.30.0 255.255.255.0
 default-router 192.168.30.1
```

NAT/PAT
```
access-list 1 permit 192.168.10.0 0.0.0.255
access-list 1 permit 192.168.20.0 0.0.0.255
access-list 1 permit 192.168.30.0 0.0.0.255

ip nat inside source list 1 interface GigabitEthernet0/1 overload
```

Default route to ISP
```
ip route 0.0.0.0 0.0.0.0 203.0.113.1
```

Guest isolation ACL
```
ip access-list extended GUEST_ISOLATION
 deny ip 192.168.30.0 0.0.0.255 192.168.10.0 0.0.0.255
 deny ip 192.168.30.0 0.0.0.255 192.168.20.0 0.0.0.255
 permit ip any any

interface Gi0/0.30
 ip access-group GUEST_ISOLATION in
```

GRE tunnel
```
interface Tunnel0
 ip address 10.10.10.1 255.255.255.252
 tunnel source GigabitEthernet0/1
 tunnel destination 203.0.113.6
 no shutdown
```

OSPF
```
router ospf 1
 network 192.168.10.0 0.0.0.255 area 0
 network 192.168.20.0 0.0.0.255 area 0
 network 192.168.30.0 0.0.0.255 area 0
 network 10.10.10.0 0.0.0.3 area 0
```

---

### Router B (R-B)

Subinterfaces
```
interface Gi0/0
 no shutdown

interface Gi0/0.10
 encapsulation dot1Q 10
 ip address 192.168.50.1 255.255.255.0
 ip nat inside

interface Gi0/0.20
 encapsulation dot1Q 20
 ip address 192.168.40.1 255.255.255.0
 ip nat inside

interface Gi0/0.30
 encapsulation dot1Q 30
 ip address 192.168.60.1 255.255.255.0
 ip nat inside

interface Gi0/1
 ip address 203.0.113.6 255.255.255.252
 ip nat outside
 no shutdown
```

DHCP pools
```
ip dhcp excluded-address 192.168.40.1 192.168.40.10
ip dhcp excluded-address 192.168.50.1 192.168.50.10
ip dhcp excluded-address 192.168.60.1 192.168.60.10

ip dhcp pool STAFF
 network 192.168.40.0 255.255.255.0
 default-router 192.168.40.1

ip dhcp pool MANAGEMENT
 network 192.168.50.0 255.255.255.0
 default-router 192.168.50.1

ip dhcp pool GUEST
 network 192.168.60.0 255.255.255.0
 default-router 192.168.60.1
```

NAT/PAT
```
access-list 1 permit 192.168.40.0 0.0.0.255
access-list 1 permit 192.168.50.0 0.0.0.255
access-list 1 permit 192.168.60.0 0.0.0.255

ip nat inside source list 1 interface GigabitEthernet0/1 overload
```

Default route to ISP
```
ip route 0.0.0.0 0.0.0.0 203.0.113.5
```

Guest isolation ACL
```
ip access-list extended GUEST_ISOLATION
 deny ip 192.168.60.0 0.0.0.255 192.168.40.0 0.0.0.255
 deny ip 192.168.60.0 0.0.0.255 192.168.50.0 0.0.0.255
 permit ip any any

interface Gi0/0.30
 ip access-group GUEST_ISOLATION in
```

GRE tunnel
```
interface Tunnel0
 ip address 10.10.10.2 255.255.255.252
 tunnel source GigabitEthernet0/1
 tunnel destination 203.0.113.2
 no shutdown
```

OSPF
```
router ospf 1
 network 192.168.40.0 0.0.0.255 area 0
 network 192.168.50.0 0.0.0.255 area 0
 network 192.168.60.0 0.0.0.255 area 0
 network 10.10.10.0 0.0.0.3 area 0
```

---

### ISP Router
```
interface Gi0/0
 ip address 203.0.113.1 255.255.255.252
 no shutdown

interface Gi0/1
 ip address 203.0.113.5 255.255.255.252
 no shutdown

interface Gi0/2
 ip address 203.0.113.9 255.255.255.252
 no shutdown
```

---

## Verification

Site A internal connectivity
```
show ip interface brief
show vlan brief
show ip dhcp binding
show port-security interface Fa0/1
show ip dhcp snooping binding
show ip arp inspection
```

NAT verification
```
show ip nat translations
show ip nat statistics
```

Tunnel and routing verification
```
show interfaces Tunnel0
show ip ospf neighbor
show ip route ospf
```

---

## Connectivity Test Results
| Test | Expected | Result |
|---|---|---|
| Staff-A → Staff-B | Success — via GRE tunnel | ✅ |
| Staff-A → Web Server | Success — via NAT | ✅ |
| Staff-B → Web Server | Success — via NAT | ✅ |
| Guest-A → Staff-A | Fail — guest isolation ACL | ✅ |

---

## Key Learnings
- NAT inside must be applied to subinterfaces not the physical interface when using router-on-a-stick
- GRE tunnel creates a virtual point-to-point link — OSPF runs over it as if directly connected
- OSPF advertises internal subnets across the tunnel — no static routes needed per subnet
- Guest isolation requires ACL at Layer 3 — VLANs alone only separate at Layer 2
- DHCP snooping and DAI work together — DAI uses the snooping binding table to validate ARP
- In production: GRE tunnel would be protected with IPSec encryption (IOS: `tunnel protection ipsec profile`)
- Port security sticky MAC saves to running config — use `write memory` to persist across reloads
- Linux equivalent: GRE tunnel with `ip tunnel add`, OSPF with FRRouting, NAT with `iptables MASQUERADE`

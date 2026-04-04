# Lab 10 - Cisco Packet Tracer - NAT/PAT and IPv6

## NAT/PAT - Network Address Translation

### Problem it solves
Private IPs (192.168.x.x) are not routable on the internet. NAT translates
private IPs to a public IP before sending traffic out. PAT (overload) allows
multiple private IPs to share a single public IP using different port numbers.

### Topology
PC1 (192.168.10.10) 
SW1 -- R1 (NAT) -- R2 -- PC3 (8.8.8.10)
PC2 (192.168.10.11) /
private            public internet
### Configuration
Step 1 - Define inside and outside interfaces
R1(config)# interface Gi0/0
R1(config-if)# ip nat inside
R1(config-if)# exit
R1(config)# interface Gi0/1
R1(config-if)# ip nat outside
R1(config-if)# exit
Step 2 - ACL defining which traffic to NAT
R1(config)# access-list 1 permit 192.168.10.0 0.0.0.255
Step 3 - PAT using WAN interface IP
R1(config)# ip nat inside source list 1 interface Gi0/1 overload
Step 4 - Default route to ISP
R1(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.2
### Verification
View active NAT translations
R1# show ip nat translations
View NAT statistics
R1# show ip nat statistics

### Reading NAT Translation Table
| Field | Meaning |
|---|---|
| Inside local | Private IP of internal host |
| Inside global | Public IP after translation (R1's WAN IP) |
| Outside local | Destination as seen from inside |
| Outside global | Destination's real public IP |

### Key Learnings
- `overload` keyword enables PAT - many private IPs share one public IP
- Each connection gets a unique port number to track replies
- Default route `0.0.0.0 0.0.0.0` sends unknown destinations to ISP
- Without NAT, replies to private IPs get dropped on the internet
- Linux equivalent: `iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o eth0 -j MASQUERADE`

---

## IPv6

### Key Differences from IPv4
| Concept | IPv4 | IPv6 |
|---|---|---|
| Address length | 32-bit | 128-bit |
| Notation | Decimal dotted | Hex colon |
| Subnet mask | 255.255.255.0 | /64 prefix length |
| Private addresses | 192.168.x.x | Not needed - globally unique |
| Loopback | 127.0.0.1 | ::1 |
| Default route | 0.0.0.0/0 | ::/0 |
| Link local | N/A | FE80::/10 - auto generated |
| Enable routing | on by default | ipv6 unicast-routing required |

### Address Types
- **Global Unicast** - public routable, starts with 2001:
- **Link Local** - local segment only, starts with FE80::, auto generated from MAC
- **Loopback** - ::1

### Shortening IPv6 Addresses
- Leading zeros in a group can be removed: `0db8` → `db8`
- Consecutive all-zero groups replaced with `::` (once only)
- `2001:0db8:0000:0001:0000:0000:0000:0001` → `2001:db8:0:1::1`

### Configuration (Dual Stack)
Enable IPv6 routing (not on by default)
R1(config)# ipv6 unicast-routing
Add IPv6 address alongside existing IPv4 (dual stack)
R1(config)# interface Gi0/0
R1(config-if)# ipv6 address 2001:db8:0:10::1/64
R1(config-if)# exit
R1(config)# interface Gi0/1
R1(config-if)# ipv6 address 2001:db8:0:1::1/64
R1(config-if)# exit
Static default route
R1(config)# ipv6 route ::/0 2001:db8:0:1::2
Static route to remote subnet
R2(config)# ipv6 route 2001:db8:0:10::/64 2001:db8:0:1::1

### Verification
View IPv6 addresses on all interfaces
R1# show ipv6 interface brief
View IPv6 routing table
R1# show ipv6 route
Ping over IPv6
R1# ping ipv6 2001:db8:0:8::10

### Key Learnings
- Each interface gets a link local (FE80::) automatically plus any configured global addresses
- Link local addresses are generated from MAC address
- /64 is the standard prefix length for LAN segments
- Dual stack means running IPv4 and IPv6 simultaneously on same interfaces
- No NAT needed in IPv6 - every device gets a globally routable address
- Packet Tracer: enter address and prefix length in separate fields on PCs

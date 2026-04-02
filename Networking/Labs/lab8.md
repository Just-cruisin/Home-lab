# Lab 8 - Cisco Packet Tracer - ACLs and DHCP

## ACLs - Access Control Lists

### Standard ACL (source IP only)
- Numbered 1-99
- Place close to DESTINATION (can only filter source, would block too much near source)
```
# Block PC3 (192.168.30.10) from reaching VLAN 10
R1(config)# access-list 10 deny 192.168.30.10 0.0.0.0
R1(config)# access-list 10 permit any

# Apply outbound on VLAN 10 subinterface
R1(config)# interface Gi0/0.10
R1(config-subif)# ip access-group 10 out
R1(config-subif)# exit

# Verify
R1# show access-lists
R1# show ip interface Gi0/0.10
```

### Extended ACL (source, destination, protocol, port)
- Numbered 100-199
- Place close to SOURCE (can filter on destination so no risk of blocking too much)
```
# Allow ICMP from VLAN 30 to VLAN 10, block everything else
R1(config)# access-list 110 permit icmp 192.168.30.0 0.0.0.255 192.168.10.0 0.0.0.255
R1(config)# access-list 110 deny ip 192.168.30.0 0.0.0.255 192.168.10.0 0.0.0.255
R1(config)# access-list 110 permit ip any any

# Apply inbound on R1 Gi0/1 (traffic arriving from R2)
R1(config)# interface Gi0/1
R1(config-if)# ip access-group 110 in
R1(config-if)# exit
```

### Key Rules
- ACLs processed top-down, first match wins
- Implicit deny all at end of every ACL
- Always add permit ip any any unless you want to block everything else
- show access-lists shows match counts per rule - essential for troubleshooting

## DHCP on Cisco Router
```
# Exclude addresses from pool (gateway, static devices)
R1(config)# ip dhcp excluded-address 192.168.10.1 192.168.10.99
R1(config)# ip dhcp excluded-address 192.168.10.201 192.168.10.254

# Create pool
R1(config)# ip dhcp pool VLAN10
R1(dhcp-config)# network 192.168.10.0 255.255.255.0
R1(dhcp-config)# default-router 192.168.10.1
R1(dhcp-config)# dns-server 8.8.8.8
R1(dhcp-config)# exit

# Verify
R1# show ip dhcp binding
R1# show ip dhcp pool
R1# show ip dhcp conflict
```

### Key Learnings
- Cisco DHCP controls range via excluded-address, not explicit start/end
- show ip dhcp binding shows MAC to IP mappings
- DHCP conflict table shows duplicate IP attempts

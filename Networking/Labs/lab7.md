# Lab 7 - Cisco Packet Tracer - VLANs, Static Routing and OSPF

## Topology
2x Cisco 2960 switches (SW1, SW2)
2x Cisco 2911 routers (R1, R2)
4x PCs

PC1 (VLAN10) -- SW1 -- R1 -- R2 -- SW2 -- PC3 (VLAN30)
PC2 (VLAN20) --/    10.0.0.x/30   \-- PC4 (VLAN40)

## Switch Configuration (SW1)
```
Switch> enable
Switch# configure terminal
Switch(config)# hostname SW1

# Create VLANs
SW1(config)# vlan 10
SW1(config-vlan)# name CLIENTS_A
SW1(config-vlan)# exit
SW1(config)# vlan 20
SW1(config-vlan)# name CLIENTS_B
SW1(config-vlan)# exit

# Assign access ports
SW1(config)# interface Fa0/1
SW1(config-if)# switchport mode access
SW1(config-if)# switchport access vlan 10
SW1(config-if)# exit
SW1(config)# interface Fa0/2
SW1(config-if)# switchport mode access
SW1(config-if)# switchport access vlan 20
SW1(config-if)# exit

# Set trunk port toward router
SW1(config)# interface Fa0/24
SW1(config-if)# switchport mode trunk
SW1(config-if)# switchport trunk allowed vlan 10,20
SW1(config-if)# exit

# Verify
SW1(config)# do show vlan brief
SW1(config)# do show interfaces trunk
```

## Router on a Stick (R1)
```
R1(config)# interface Gi0/0
R1(config-if)# no shutdown
R1(config-if)# exit

R1(config)# interface Gi0/0.10
R1(config-subif)# encapsulation dot1Q 10
R1(config-subif)# ip address 192.168.10.1 255.255.255.0
R1(config-subif)# exit

R1(config)# interface Gi0/0.20
R1(config-subif)# encapsulation dot1Q 20
R1(config-subif)# ip address 192.168.20.1 255.255.255.0
R1(config-subif)# exit

# Verify
R1(config)# do show ip interface brief
```

## Static Routing
Point-to-point link between routers uses /30 subnet - only 2 usable IPs, perfect for router links.
```
# R1 WAN interface
R1(config)# interface Gi0/1
R1(config-if)# ip address 10.0.0.1 255.255.255.252
R1(config-if)# no shutdown
R1(config-if)# exit

# R2 WAN interface
R2(config)# interface Gi0/1
R2(config-if)# ip address 10.0.0.2 255.255.255.252
R2(config-if)# no shutdown
R2(config-if)# exit

# Static routes on R1
R1(config)# ip route 192.168.30.0 255.255.255.0 10.0.0.2
R1(config)# ip route 192.168.40.0 255.255.255.0 10.0.0.2

# Static routes on R2
R2(config)# ip route 192.168.10.0 255.255.255.0 10.0.0.1
R2(config)# ip route 192.168.20.0 255.255.255.0 10.0.0.1

# Verify
R1# show ip route
```

## OSPF
Static routing doesn't scale - OSPF automatically discovers neighbours and recalculates routes if a link goes down.
```
# Remove static routes first
R1(config)# no ip route 192.168.30.0 255.255.255.0 10.0.0.2
R1(config)# no ip route 192.168.40.0 255.255.255.0 10.0.0.2
R2(config)# no ip route 192.168.10.0 255.255.255.0 10.0.0.1
R2(config)# no ip route 192.168.20.0 255.255.255.0 10.0.0.1

# Enable OSPF on R1
R1(config)# router ospf 1
R1(config-router)# router-id 1.1.1.1
R1(config-router)# network 192.168.10.0 0.0.0.255 area 0
R1(config-router)# network 192.168.20.0 0.0.0.255 area 0
R1(config-router)# network 10.0.0.0 0.0.0.3 area 0
R1(config-router)# exit

# Enable OSPF on R2
R2(config)# router ospf 1
R2(config-router)# router-id 2.2.2.2
R2(config-router)# network 192.168.30.0 0.0.0.255 area 0
R2(config-router)# network 192.168.40.0 0.0.0.255 area 0
R2(config-router)# network 10.0.0.0 0.0.0.3 area 0
R2(config-router)# exit

# Verify - look for O entries in routing table
R1# show ip route
R1# show ip ospf neighbor
```

## Key Learnings
- Wildcard masks are inverse of subnet mask (0.0.0.255 = /24)
- OSPF router-id should be set manually for clarity
- Area mismatch causes OSPF adjacency to fail - both ends must match
- OSPF routes show as O in routing table with [110/cost]
- Shutting down a link causes OSPF to reconverge automatically
- Always write memory after configuration changes

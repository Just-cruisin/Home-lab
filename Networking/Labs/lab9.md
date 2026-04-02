# Lab 9 - Cisco Packet Tracer - HSRP and STP

## HSRP - Hot Standby Router Protocol

### Problem it solves
If the gateway router goes down, all clients lose connectivity. HSRP creates
a virtual IP shared between two routers - if the active router fails, the
standby takes over automatically with no client reconfiguration needed.

### Topology
PC1 ----\
         SW1 ---- R1 (priority 110, active)
PC2 ----/    \--- R2 (priority 90, standby)

Virtual IP: 192.168.10.254 (what clients use as gateway)

### Configuration
```
# R1 - Active router (higher priority wins)
R1(config)# interface Gi0/0
R1(config-if)# ip address 192.168.10.1 255.255.255.0
R1(config-if)# no shutdown
R1(config-if)# standby 1 ip 192.168.10.254
R1(config-if)# standby 1 priority 110
R1(config-if)# standby 1 preempt
R1(config-if)# exit

# R2 - Standby router (lower priority)
R2(config)# interface Gi0/0
R2(config-if)# ip address 192.168.10.2 255.255.255.0
R2(config-if)# no shutdown
R2(config-if)# standby 1 ip 192.168.10.254
R2(config-if)# standby 1 priority 90
R2(config-if)# standby 1 preempt
R2(config-if)# exit

# Verify
R1# show standby brief
```

### DHCP with HSRP
Use virtual IP as default-router so clients still work after failover:
```
R1(config)# ip dhcp pool LAN
R1(dhcp-config)# default-router 192.168.10.254
```

### Key Concepts
- Virtual IP is what clients use as gateway - never changes
- Higher priority = preferred active router
- Preempt = higher priority router reclaims active role after recovery
- Hello timer: 3 seconds, Hold timer: 10 seconds
- Failover is near-instant - standby monitors active via hello messages

### Failover Test
```
# Simulate failure
R1(config)# interface Gi0/0
R1(config-if)# shutdown

# R2 becomes active automatically
R2# show standby brief

# Bring R1 back - preempt reclaims active role
R1(config-if)# no shutdown
```

## STP - Spanning Tree Protocol

### Problem it solves
Redundant switch links cause broadcast storms - frames loop endlessly.
STP blocks redundant links while keeping them available as backup.

### Topology
```
       SW1 (root bridge)
      /    \
    SW2 --- SW3
    |         |
   PC1       PC2
```

### Port States
- Blocking (BLK) - not forwarding, listening for BPDUs
- Listening (LIS) - transitioning, not forwarding
- Learning (LRN) - learning MACs, not forwarding  
- Forwarding (FWD) - normal operation

### Port Roles
- Root port - best path toward root bridge
- Designated port - best port on each segment
- Alternate/Blocked - redundant port, blocked to prevent loops

### Root Bridge Election
Switch with lowest priority wins. If tied, lowest MAC address wins.
Default priority is 32768.

### Commands
```
# View STP topology
SW1# show spanning-tree

# Make SW1 root bridge
SW1(config)# spanning-tree vlan 1 root primary
# Sets priority to 24576 automatically

# Or manually set priority (must be multiple of 4096)
SW1(config)# spanning-tree vlan 1 priority 4096

# Simulate link failure to test convergence
SW1(config)# interface Fa0/23
SW1(config-if)# shutdown
```

### Key Learnings
- STP runs automatically on Cisco switches by default
- Root bridge has all designated ports (all forwarding)
- Blocked port transitions BLK → LIS → LRN → FWD (30 seconds default)
- Changing root bridge moves the blocked port to maintain loop-free topology
- show spanning-tree shows port roles, states and root bridge election result

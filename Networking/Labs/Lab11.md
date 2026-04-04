# Lab 11 - Cisco Packet Tracer - EtherChannel (LACP)

## EtherChannel - Link Aggregation

### Problem it solves
When two switches are connected with multiple cables, STP blocks all but one
link to prevent loops. This wastes bandwidth and leaves redundancy unused.
EtherChannel bundles multiple physical links into one logical interface so STP
sees a single link - no blocking, full bandwidth, and built-in failover.

### Topology
SW1 Fa0/1 -- SW2 Fa0/1
SW1 Fa0/2 -- SW2 Fa0/2
         |
    Port-channel1 (logical bundle)

### Before EtherChannel (STP behaviour)
SW1 was root bridge - both ports Designated/FWD
SW2 Fa0/1 - Root port (forwarding) - lower port number wins tiebreaker
SW2 Fa0/2 - Alternate port (blocking) - same cost, higher port number loses
Result: one link blocked, half the bandwidth wasted

### Configuration
Step 1 - Configure LACP EtherChannel on SW1
SW1(config)# interface range Fa0/1 - 2
SW1(config-if-range)# channel-group 1 mode active

Step 2 - Configure LACP EtherChannel on SW2
SW2(config)# interface range Fa0/1 - 2
SW2(config-if-range)# channel-group 1 mode active

Note: `mode active` = LACP (802.3ad open standard) - actively sends LACP packets
Both sides set to active is valid. Alternative: one side active, one passive.

### Verification
View EtherChannel bundle status
SW1# show etherchannel summary

View STP after bundling
SW1# show spanning-tree

### Reading EtherChannel Summary Output
| Flag | Meaning |
|---|---|
| S | Layer 2 |
| U | In use |
| P | Port in port-channel |
| D | Down |
| I | Stand-alone |
| H | Hot-standby (LACP only) |

Example healthy output:
Group  Port-channel  Protocol  Ports
1      Po1(SU)       LACP      Fa0/1(P) Fa0/2(P)

### After EtherChannel (STP behaviour)
- Po1 appears as single logical interface - Fa0/1 and Fa0/2 no longer listed
- STP cost dropped from 19 → 12 (higher bandwidth = lower cost)
- No ports blocked - STP sees only one link, no loop possible

### Failover Test
Shut one physical link
SW1(config)# interface Fa0/1
SW1(config-if)# shutdown

show etherchannel summary output:
Po1(SU)   LACP   Fa0/1(D) Fa0/2(P)

- Po1 stays SU (up and in use) - bundle survives losing one link
- No STP reconvergence required - traffic continues on remaining link
- Bring link back: `no shutdown` → Fa0/1 rejoins as (P) automatically

### Key Learnings
- EtherChannel bundles physical links into one logical interface (Port-channel)
- LACP (802.3ad) is the open standard - Cisco also has PAgP (proprietary)
- `mode active` sends LACP negotiation packets, `mode passive` only responds
- STP sees one logical link - no blocking, lower cost due to combined bandwidth
- Failover is seamless - no reconvergence unlike physical link redundancy
- Linux equivalent: bonding with `mode=802.3ad` (LACP) in `/etc/network/interfaces`

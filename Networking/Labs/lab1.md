# Lab 1
## Setup
* Using testing VM as router, add 2 bridges to it (vmbr1, vmbr2)
* Set up 2 debian containers, client1 and client2, 192.168.10.10, 192.168.20.10, using vmbr1 and vmbr2 respectively
* Subnet A 192.168.10.0/24, Subnet B 192.168.20.0/24

## Task 1 - Firewall and traffic control.
* Blocked traffic between subnets: sudo iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.0/24 -j DROP
* Re-allowed traffic: sudo iptables -F
* Allow only ping: sudo iptables -A FORWARD -p icmp -j ACCEPT,sudo iptables -A FORWARD -j DROP

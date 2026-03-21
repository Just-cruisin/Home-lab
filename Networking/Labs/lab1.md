# Lab 1
## Setup
* Using testing VM as router, add 2 bridges to it (vmbr1, vmbr2)
* Set up 2 debian containers, client1 and client2, 192.168.10.10, 192.168.20.10, using vmbr1 and vmbr2 respectively
* Subnet A 192.168.10.0/24, Subnet B 192.168.20.0/24

## Task 1 - Firewall and traffic control.
* Blocked traffic between subnets: sudo iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.0/24 -j DROP
* Re-allowed traffic: sudo iptables -F
* Allow only ping: sudo iptables -A FORWARD -p icmp -j ACCEPT,sudo iptables -A FORWARD -j DROP

## Task 2 - VLANs + Router on a stick
* Removed the vmbr2 from router and client 2
* Made bridges VLAN aware
* Created VLAN 10 and 20 and added to all devices
  *sudo ip link add link ens19 name ens19.10 type vlan id 10
  * sudo ip link add link ens19 name ens19.20 type vlan id 20
  * sudo ip link set ens19.10 up
  * sudo ip link set ens19.20 up
  * sudo ip addr add 192.168.10.1/24 dev ens19.10
  * sudo ip addr add 192.168.20.1/24 dev ens19.20
* Able to ping between clients and to the router VM

### Problems
* Router VM kept losing IP address after reboot, assigned it static via /etc/network/interfaces

## Task 3 - Set up DHCP per VLAN
* Install dnsmasq on router vm
* Set up config file
* Removed static IP's from clients
  * ip addr flush dev client1
  * dhclient client1
* Watched the logs for DHCP requests and full DORA handshake
* Finally switched clients back to static by assigning IP addresses to each MAC address in the config file

## Task 4 - Set up DNS on the router VM
* Installed bind9 and bind9utils on the router VM
* Configure options
  * Only allow queries from the two subnet and localhost
  * turn recursion off, so nothing is forwarded externally
  * Disable IPv6
  * Set to listen on both VLAN interfaces and localhost
  * Declare zones for each VLAN
  * Forward zone file with Name server entries
  * Reverse zone files
  * Update dnsmasq config file to advertise router as DNS server for each VLAN
* Test forward and reverse lookups successfully

 

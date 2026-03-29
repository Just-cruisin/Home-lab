# Lab 6
## Kubernetes with k3s

### Setup
* Single node k3s cluster on a dedicated Debian 12 VM (pve1)
* 4GB RAM, 2 cores, 20GB disk
* VM on home LAN (192.168.1.46) with static routes to lab VLANs

### Concepts learned
| Manual setup | Kubernetes equivalent |
|---|---|
| Flask app on client1/client3 | Pod |
| HAProxy load balancing | Service |
| Ansible template | ConfigMap |
| nftables rules | NetworkPolicy |
| nginx reverse proxy | Ingress |

### Manifests (~/k3s-manifests/labapp/)
* **configmap.yaml** - Flask app code stored as a ConfigMap
* **deployment.yaml** - 2 replicas of the Flask app
* **service.yaml** - ClusterIP service exposing port 80
* **ingress.yaml** - Traefik ingress routing app.k3s.lan to the service

### Networking notes
* k3s VM on 192.168.1.x (home LAN) not VLAN 10
* Required static routes on k3s VM to reach lab VLANs via router:
```bash
sudo ip route add 192.168.10.0/24 via 192.168.1.39
sudo ip route add 192.168.20.0/24 via 192.168.1.39
```
* Required static routes on UniFi Dream Router for return traffic
* client2 nftables updated to allow 192.168.1.0/24 for PostgreSQL

### Key commands
```bash
# View pods
sudo kubectl get pods -n labapp

# View services
sudo kubectl get service -n labapp

# View ingress
sudo kubectl get ingress -n labapp

# Scale deployment
sudo kubectl scale deployment labapp -n labapp --replicas=4

# View logs
sudo kubectl logs -n labapp -l app=labapp

# Delete a pod (Kubernetes will recreate it automatically)
sudo kubectl delete pod <pod-name> -n labapp
```

### Self healing demo
* Deleting a pod with `kubectl delete pod` causes Kubernetes to
  immediately spawn a replacement - demonstrating self healing

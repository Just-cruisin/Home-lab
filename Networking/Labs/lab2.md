# Lab 2
## Task 1 - nginx reverse proxy
* Installed nginx on all 3 machines
* Gave each client a distinct webpage, tested with curl
* Remove the initial nginx config on the router
* Created a virtual host for each client

Client 1 :
server {
    listen 80;
    server_name client1.lab.local;

    location / {
        proxy_pass http://192.168.10.50;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

Client 2:
server {
    listen 80;
    server_name client2.lab.local;

    location / {
        proxy_pass http://192.168.20.50;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

## Task 2- TLS termination
* Create ssl directory
* Generate certificates for both clients
Client 1:
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/client1.key \
  -out /etc/nginx/ssl/client1.crt \
  -subj "/CN=client1.lab.local/O=Lab/C=AU"

Client 2:
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/client2.key \
  -out /etc/nginx/ssl/client2.crt \
  -subj "/CN=client2.lab.local/O=Lab/C=AU"

* Had to update the virtual hosts for both clients
e.g. Client 1:
// Redirect HTTP to HTTPS
server {
    listen 80;
    server_name client1.lab.local;
    return 301 https://$host$request_uri;
}

// HTTPS with TLS termination
server {
    listen 443 ssl;
    server_name client1.lab.local;

    ssl_certificate /etc/nginx/ssl/client1.crt;
    ssl_certificate_key /etc/nginx/ssl/client1.key;

    location / {
        proxy_pass http://192.168.10.50;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
* DNS stopped working properly, client1.lab.local was resolving to backend instead of proxy. Had to update the forward zones on the router
Change the A records so client1 and client2 point to the router:
```
$TTL 86400
@   IN  SOA     router.lab.local. admin.lab.local. (
                    2026032302  ; Serial - increment this every change
                    3600
                    1800
                    604800
                    86400 )

@       IN  NS      router.lab.local.

router  IN  A       192.168.10.1
client1 IN  A       192.168.10.1
client2 IN  A       192.168.20.1
```

## Task 3 - HAProxy load balancing
* Cloned client2, changed hostname to client3 and added the static reservation for it in dnsmasq (...10.51, VLAN 10)
* Gave client 3 a different webpage
* Install haproxy on the router
Config:
global
    log /dev/log local0
    maxconn 2000
    daemon

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5s
    timeout client  30s
    timeout server  30s

// Frontend - what HAProxy listens on
frontend web_frontend
    bind *:8080
    default_backend web_backends

// Backend - the pool of servers to balance across
backend web_backends
    balance roundrobin
    option httpchk GET /
    server client1 192.168.10.50:80 check
    server client3 192.168.10.51:80 check

// Stats page - very useful for seeing what's happening
listen stats
    bind *:9000
    stats enable
    stats uri /stats
    stats refresh 5s
* Put HAProxy on port 8080 to avoid conflict with nginx
* Tested by using url on a client to the router, go responses from client 1 and 3
* Checked out the stats page on port 9000 of the router
* Stopped nginx on client 1 and used curl again from client 2 to see traffic route to client 3

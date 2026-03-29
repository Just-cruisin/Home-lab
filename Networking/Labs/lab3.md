# Lab 3
## Task 1 - Prometheus + Grafana Monitoring

### node_exporter
* Installed prometheus-node-exporter on router, client1, client2, client3
* Exposes metrics on port 9100 on each node
* Verified with `curl http://<ip>:9100/metrics`

### Prometheus
* Installed on the router
* Configured to scrape all 4 nodes via /etc/prometheus/prometheus.yml
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'router'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'clients'
    static_configs:
      - targets:
          - '192.168.10.50:9100'
          - '192.168.10.51:9100'
          - '192.168.20.50:9100'
```

* Verified all targets healthy via `curl http://localhost:9090/api/v1/targets`

### Grafana
* Added Grafana apt repo and installed on router
* Accessible at http://192.168.1.39:3000
* Added Prometheus as data source (http://localhost:9090)
* Imported Node Exporter Full dashboard (ID: 1860)
* Dashboard shows CPU, memory, network throughput, disk I/O across all nodes

### Notes
* Clients are LXC containers - CAP_SYS_TIME not available so chrony
  cannot adjust clock inside containers
* node_exporter installed via HTTP transfer (python3 -m http.server)
  due to DNS issues on clients at the time

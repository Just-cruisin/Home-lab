import requests

def query_prometheus(metric):
    response = requests.get('http://localhost:9090/api/v1/query', params={'query':metric})
    data = response.json()
    if data['status'] != 'success':
        print(f"Query failed: {data}")
        return []
    return response.json()['data']['result']

def get_node_metrics():
    metric_names = {
        'node_memory_MemAvailable_bytes': 'memory_gb',
        'node_filesystem_avail_bytes': 'disk_gb',
        '100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])*100))': 'cpu_percent'
    }
    metrics=['node_memory_MemAvailable_bytes', 'node_filesystem_avail_bytes', '100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])*100))']
    nodes = {}
    for metric in metrics:
        results=query_prometheus(metric)
        for item in results:
            instance=item['metric']['instance']
            value=item['value'][1]
            if 'filesystem' in metric:
                if item['metric'].get('mountpoint') != '/':
                    continue
            if instance not in nodes:
                nodes[instance]={}
            nodes[instance][metric_names[metric]] = value 
    return nodes

if __name__ == '__main__':
    metrics = get_node_metrics()
    for instance, values in metrics.items():
        print(f"\n{instance}")
        for metric, value in values.items():
            if 'cpu' in metric and 'bytes' not in metric:
                value = round(float(value),2)
            if 'gb' in metric:
                value = round(int(value) / (1024**3),2)
            print(f" {metric}: {value}")
            

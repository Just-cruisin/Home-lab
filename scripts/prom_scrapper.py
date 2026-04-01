import requests

def query_prometheus(metric):
    response = requests.get('http://localhost:9090/api/v1/query', params={'query':metric})
    return response.json()['data']['result']

def get_node_metrics():
    metrics=['node_memory_MemAvailable_bytes', 'node_filesystem_avail_bytes', 'node_cpu_seconds_total']
    nodes = {}
    for metric in metrics:
        results=query_prometheus(metric)
        for item in results:
            instance=item['metric']['instance']
            value=item['value'][1]
            nodes [instance] = value 
    return nodes

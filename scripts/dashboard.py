import os
from flask import Flask, render_template
from disk_usage import get_disk_usage
from service_status import get_service_status
from network_monitor import get_network_status
from prom_scrapper import get_node_metrics

base_dir = os.path.dirname(os.path.abspath(__file__))
print(os.path.join(base_dir, '..', 'flask_templates'))
app = Flask(__name__,template_folder=os.path.join(base_dir, '..', 'flask_templates'))

@app.route('/')http://testing.lan:909/
def index():
    service_statuses = get_service_status(["ssh","cron","tailscaled"])
    disk_percentage,status = get_disk_usage()
    network_statuses = get_network_status()
    node_metrics = get_node_metrics
    return render_template('index.html', disk_percentage=disk_percentage, status=status,service_statuses=service_statuses,network_statuses=network_statuses,node_metrics=node_metrics)


if __name__ == '__main__':
        app.run(debug=True, host='0.0.0.0')





import os
from flask import Flask, render_template
from disk_usage import get_disk_usage
from service_status import get_service_status

base_dir = os.path.dirname(os.path.abspath(__file__))
print(os.path.join(base_dir, '..', 'flask_templates'))
app = Flask(__name__,template_folder=os.path.join(base_dir, '..', 'flask_templates'))

@app.route('/')
def index():
    service_statuses = get_service_status(["ssh","cron","tailscaled"])
    disk_percentage,status = get_disk_usage()
    return render_template('index.html', disk_percentage=disk_percentage, status=status,service_statuses=service_statuses)


if __name__ == '__main__':
        app.run(debug=True, host='0.0.0.0')





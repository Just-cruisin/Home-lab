# Lab 5
## Ansible Automation

### Project Structure
```
lab-ansible/
├── ansible.cfg
├── inventory/
│   ├── hosts.ini
│   └── group_vars/
│       └── all.yml
├── roles/
│   ├── common/
│   │   └── tasks/main.yml
│   ├── webserver/
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   └── templates/app.py.j2
│   └── database/
│       ├── tasks/main.yml
│       └── handlers/main.yml
└── playbooks/
    └── site.yml
```

### What the playbook automates
* **common role** - runs on all nodes:
  - apt cache update
  - Install common packages (curl, wget, net-tools, dnsutils, htop)
  - Set timezone
  - Configure /etc/hosts with lab entries
  - Configure DNS resolver

* **webserver role** - runs on client1 + client3:
  - Install Python, Flask, psycopg2
  - Deploy Flask app from Jinja2 template
  - Configure and enable systemd service
  - Handler restarts app when template changes

* **database role** - runs on client2:
  - Install PostgreSQL
  - Create database and user
  - Grant privileges
  - Configure remote access
  - Update pg_hba.conf

### Key learnings
* Idempotency - running playbook multiple times produces zero changes
  if state is already correct
* `become_method: su` required instead of sudo (containers have no sudo)
* group_vars must sit alongside inventory file to be auto-discovered
* Handlers only fire when a task reports `changed`
* Templates use Jinja2 variables ({{ db_host }}) populated from group_vars

### Running the playbook
```bash
cd ~/lab-ansible
ansible-playbook playbooks/site.yml
```

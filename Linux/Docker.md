# Docker Notes

## Commands

| Command                     | Description                                                     |
| --------------------------- | --------------------------------------------------------------- |
| `docker run`                | Pull (if needed) and start a container                          |
| `docker run -d`             | Run container in detached (background) mode                     |
| `docker run -it`            | Run container interactively with a terminal                     |
| `docker run --rm`           | Automatically remove container when it exits                    |
| `docker stop <name/id>`     | Stop a running container                                        |
| `docker images`             | Show downloaded images                                          |
| `docker ps`                 | Show running containers (`-a` flag shows all including stopped) |
| `docker rm <name/id>`       | Remove a stopped container                                      |
| `docker rmi <name/id>`      | Remove an image                                                 |
| `docker exec -it <name> sh` | Open a shell inside a running container                         |
| `docker logs <name>`        | View container logs                                             |
| `docker stats`              | Live resource usage for all containers                          |
| `docker inspect <name>`     | Detailed info about a container or image                        |
| `docker compose up -d`      | Start all services defined in docker-compose.yml                |
| `docker compose down`       | Stop and remove all services and networks                       |

---

## Dockerfile

A Dockerfile defines how to build a custom image. Each instruction creates a **layer**.

### What goes in a Dockerfile

- The base image to start from
- Commands to install dependencies
- Copying your app files in
- The command to run the app

### Example

```dockerfile
FROM debian:bookworm-slim
RUN apt update && apt upgrade -y && apt install -y python3
COPY app.py /app/app.py
CMD ["python3", "/app/app.py"]
```

### Key instructions

|Instruction|Purpose|
|---|---|
|`FROM`|Base image to build on top of|
|`RUN`|Execute a command during build|
|`COPY`|Copy files from host into the image|
|`CMD`|Default command to run when container starts|

### Building an image

```bash
docker build -t myapp .
# -t specifies the image name/tag
# . tells Docker to look for a Dockerfile in the current directory
```

### Layer caching

- Each `RUN` instruction creates a new layer
- Docker caches layers and reuses them if nothing has changed
- If a layer changes, all layers below it are rebuilt
- **Rule:** Put things that change rarely at the top, things that change frequently at the bottom
- e.g. `apt install` before `COPY app.py` — so changing app code doesn't invalidate the package install cache

---

## Docker Compose

Defines and manages multi-container stacks in a single YAML file.

### Example

```yaml
services:
  web:
    image: nginx
    ports:
      - "8888:80"
    volumes:
      - ./html:/usr/share/nginx/html
  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD: example123
```

### Using build instead of image

If you have a Dockerfile, use `build: .` instead of `image:` to build a custom image:

```yaml
services:
  web:
    build: .
    ports:
      - "8888:80"
```

Rebuild after changes:

```bash
docker compose up -d --build
```

### Key commands

```bash
docker compose up -d       # Start stack in background
docker compose down        # Stop and remove containers and networks
docker compose up -d --build  # Rebuild images and restart
```

---

## Networking

### How it works

- Docker creates a virtual bridge (`docker0`) on the host with its own IP and subnet
- The host acts as the gateway
- Each container gets an IP from this subnet

```bash
ip addr show docker0
# Shows: inet 172.17.0.1/16 — Docker's bridge IP and subnet
```

### Network drivers

```bash
docker network ls
```

|Driver|Description|
|---|---|
|`bridge`|Default. Containers connect via Docker's virtual bridge. Isolated from host network.|
|`host`|Container shares the host's network stack directly — no isolation|
|`none`|No network connection at all — completely isolated|

### Default bridge vs custom networks

- On the **default bridge**, containers can reach each other by IP but **not by name**
- On a **custom network**, Docker provides DNS so containers can reach each other by name
- This is why Docker Compose creates its own network automatically — so services can use names like `db` or `web`
- A container on an isolated network (or `none`) is unreachable from other containers — useful for security

### Creating a custom network

```bash
docker network create --subnet 172.20.0.0/16 test-network

# Run containers on it
docker run -d --name container1 --network test-network nginx
docker run -d --name container2 --network test-network nginx

# Exec in and ping by name
docker exec -it container2 sh
ping container1

# Cleanup
docker stop container1 container2
docker rm container1 container2
docker network rm test-network
```

### Network aliases — giving containers a shared name

Useful for **load balancing** — multiple containers share one alias, traffic round-robins between them.

Also useful for **blue-green deployments** — run a new version alongside the old one under the same alias, gradually shifting traffic with no downtime.

```bash
docker network create alias-test

# Run 2 containers with the same alias
docker run -d --name web1 --network alias-test --network-alias webservers nginx
docker run -d --name web2 --network alias-test --network-alias webservers nginx

# Test from a third container
docker run -it --network alias-test --rm alpine sh
nslookup webservers 127.0.0.11
# Returns both IPs, alternating order on each query — that's round-robin DNS

# Cleanup
docker stop web1 web2
docker rm web1 web2
docker network rm alias-test
```

### Connecting a container to multiple networks

Used to create segmented architectures — e.g. a proxy sitting between a frontend and backend network, similar to HAProxy between VLANs.

- `webapp` on `frontend-net` only
- `database` on `backend-net` only
- `proxy` on both — can reach either side

```bash
docker network create frontend-net
docker network create backend-net

docker run -d --name webapp --network frontend-net nginx
docker run -d --name database --network backend-net nginx
docker run -d --name proxy --network frontend-net nginx

# Connect proxy to second network
docker network connect backend-net proxy

# Verify
docker inspect proxy | grep -A20 Networks
```

> Note: Docker networks cannot be connected directly to each other — a container in the middle is always required.

---

## Volumes

### Named volumes vs bind mounts

||Named Volume|Bind Mount|
|---|---|---|
|Location|Managed by Docker at `/var/lib/docker/volumes/`|You specify the exact host path|
|Portability|High — Docker recreates it on any host|Low — path must exist on the host|
|Management|Can back up, migrate, inspect via Docker|Just a regular host directory|
|Best for|Persistent data (databases)|Direct host access (config files, web content)|

### Named volume commands

```bash
docker volume create mydata
docker volume ls
docker volume inspect mydata
docker volume rm mydata
```

### Using a named volume

```bash
# Mount volume at /data inside container
docker run -it --rm -v mydata:/data alpine sh

# Create a file
echo "hello from docker volume" > /data/testfile.txt
exit

# Start a brand new container — file is still there
docker run -it --rm -v mydata:/data alpine sh
cat /data/testfile.txt
```

### Real use case — PostgreSQL with persistent storage

```bash
docker run -d \
  --name postgres-test \
  -e POSTGRES_PASSWORD=example123 \
  -v pgdata:/var/lib/postgresql \
  postgres
```

Data survives container deletion and image updates — critical for any database container.

---

## Resource Limits

Without limits, a single container can consume all host resources and starve everything else. Memory leaks are a common real-world cause.

### Setting limits at runtime

```bash
docker run -d \
  --name limited \
  --memory 512m \
  --cpus 1 \
  nginx
```

### Verify limits

```bash
docker inspect limited | grep -E "Memory|NanoCpus"
# Memory: 536870912     (= 512MB)
# NanoCpus: 1000000000  (= 1 CPU core)
# MemorySwap: 1073741824 (= 1GB — defaults to 2x memory limit)
```

### Live monitoring

```bash
docker stats              # All containers
docker stats limited      # Specific container
# Shows: CPU %, MEM USAGE / LIMIT, MEM %, NET I/O, BLOCK I/O
```

### Setting limits in Docker Compose

```yaml
services:
  web:
    image: nginx
    deploy:
      resources:
        limits:
          memory: 512m
          cpus: '1'
        reservations:
          memory: 256m
          cpus: '0.5'
```

- **limits** — hard ceiling the container can never exceed
- **reservations** — guaranteed minimum always available to the container

## Environment Variables and Secrets

Hardcoding credentials in a Compose file is a security risk — especially if the file ends up in a public repo.

### Bad practice
```yaml
environment:
  POSTGRES_PASSWORD: supersecret123
```

### Good practice — .env file
Store secrets in a `.env` file in the same directory as `docker-compose.yml`:
POSTGRES_PASSWORD=supersecret123

Reference it in the Compose file:
```yaml
environment:
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
```

Docker Compose automatically reads `.env` — no extra configuration needed.

### Critical — add .env to .gitignore
.env

Verify it was passed correctly:
```bash
docker exec -it <container> env | grep POSTGRES
```

---

## .dockerignore

When you run `docker build`, Docker sends everything in the current directory to the daemon as the build context. Without a `.dockerignore`, large or sensitive files get included unnecessarily.

### What to exclude

.env .venv/ pycache/ *.pyc .git/ *.md
### Why it matters
- `.env` — credentials must never end up in an image
- `.venv/` / `node_modules/` — can be hundreds of MB, bloats build context
- `.git/` — entire Git history has no place in an image
- `*.md` — documentation not needed at runtime

### Verifying it works
Watch the `transferring context` line in build output — a small number means only the necessary files were sent:
=> transferring context: 27B

Syntax is identical to `.gitignore`.

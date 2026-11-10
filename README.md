# Infra Monitoring Project

A lightweight infrastructure monitoring project using Bash, Docker Compose, Nginx, and GitHub Actions.

The project provides HTTP API availability checks, access log analysis, and a containerized API service behind an Nginx reverse proxy.

## Tech Stack

- **Bash** — API monitoring and log analysis
- **Docker Compose** — container orchestration
- **Nginx** — reverse proxy
- **GitHub Actions** — continuous integration
- **Wireshark** — network traffic analysis

## Project Structure

```text
infra-monitoring-project/
├── .github/
│   └── workflows/
│       └── ci.yml
├── nginx/
│   └── default.conf
├── .gitignore
├── README.md
├── analyze_logs.sh
├── check_api.sh
└── docker-compose.yml
```

## Getting Started

### Requirements

- Bash
- curl
- Docker Engine
- Docker Compose
- Git

### Running the Services

```bash
docker compose up -d
```

Check container status:

```bash
docker compose ps
```

Test the API:

```bash
curl http://localhost:80
```

Response:

```text
Monitoring Service Active
```

Stop the services:

```bash
docker compose down
```

## API Monitoring

The `check_api.sh` script checks the availability of an HTTP endpoint.

### Usage

```bash
./check_api.sh <URL>
```

Example:

```bash
./check_api.sh https://httpbin.org/status/200
```

The script returns:

- `0` — API is available (HTTP 200).
- `1` — API is unavailable or the request failed.

HTTP requests are performed using `curl` with connection and request timeouts.

## Log Analysis

The `analyze_logs.sh` script generates a sample access log containing 360 requests and analyzes HTTP traffic statistics.

### Usage

```bash
./analyze_logs.sh
```

To analyze an existing log file:

```bash
./analyze_logs.sh /path/to/access.log
```

### Metrics

- Total number of requests
- Top 3 client IP addresses
- Number of HTTP 4xx responses
- Number of HTTP 5xx responses

Log processing uses `grep`, `awk`, `sort`, `uniq`, and regular expressions.

## Docker Architecture

The application consists of two services:

| Service | Image | Port | Description |
|---|---|---|---|
| api | hashicorp/http-echo:1.0 | 8080 (internal) | HTTP echo server |
| proxy | nginx:alpine | 80 (public) | Nginx reverse proxy |

Both services communicate through an isolated Docker bridge network.

The Nginx proxy forwards incoming HTTP requests to `api:8080`.

## CI/CD

GitHub Actions automatically runs the CI workflow when a pull request targeting `main` is created or updated.

The pipeline performs:

1. Bash syntax validation using `bash -n`.
2. API availability testing with HTTP 200.
3. Error handling verification with HTTP 404.
4. Log generation and validation.

Workflow configuration: `.github/workflows/ci.yml`.

## Deployment via SSH

### Generate an SSH Key

```bash
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/infra_monitoring_ed25519
```

### Copy the Public Key

```bash
ssh-copy-id -i ~/.ssh/infra_monitoring_ed25519.pub user@server
```

Verify the server's SSH host fingerprint before accepting a new connection.

### Create a Project Archive

```bash
git archive --format=tar.gz -o infra-monitoring.tar.gz HEAD
```

### Transfer the Archive

```bash
scp -i ~/.ssh/infra_monitoring_ed25519 infra-monitoring.tar.gz user@server:/tmp/
```

### Deploy on the Remote Server

```bash
ssh -i ~/.ssh/infra_monitoring_ed25519 user@server
```

```bash
mkdir -p ~/infra-monitoring
tar -xzf /tmp/infra-monitoring.tar.gz -C ~/infra-monitoring
cd ~/infra-monitoring
docker compose up -d
```

The remote server must have Docker Engine and Docker Compose installed.

SSH private keys and other sensitive data must not be committed to the repository.
# MLOps Exam: Advanced Deployment with Nginx

Nginx acts as an API gateway in front of a sentiment-recognition model served by FastAPI. It provides HTTPS, basic authentication, rate limiting, load balancing and A/B routing, and the stack is monitored with Prometheus and Grafana.

## Architecture

```
Client --HTTPS--> Nginx (443) --+--> api-v1 (3 replicas, round-robin)   default traffic
                  |             +--> api-v2 (1 instance, debug)          header X-Experiment-Group: debug
                  |
                  +-- :8080/nginx_status (internal only) --> nginx_exporter --> Prometheus --> Grafana
```

| Service | Role |
|---|---|
| `nginx` | Single entry point: TLS termination, HTTP to HTTPS redirect, basic auth, rate limiting, load balancing, A/B routing |
| `api-v1` | Standard API, 3 replicas. Returns `prediction value` |
| `api-v2` | Debug API. Also returns `prediction_proba_dict` |
| `nginx_exporter` | Reads the internal Nginx status page and exposes it as Prometheus metrics |
| `prometheus` | Scrapes the exporter every 3 seconds |
| `grafana` | Dashboards on top of Prometheus |

## How each requirement is implemented

1. **Reverse proxy:** only Nginx publishes ports (80 and 443). The APIs are reachable only inside the Docker network.
2. **Load balancing:** `api-v1` runs with `deploy.replicas: 3`. Docker DNS returns all replica addresses for the name `api-v1`, and Nginx distributes requests round-robin.
3. **HTTPS:** a self-signed certificate (`deployments/nginx/certs/`, valid for `localhost` and `127.0.0.1`) is used on port 443. Port 80 answers with a 301 redirect to HTTPS.
4. **Access control:** `/predict` requires basic auth (`deployments/nginx/.htpasswd`).
5. **Rate limiting:** `limit_req_zone` allows 10 requests per second per IP on `/predict`, with a
# 🚀 PostHub.work - Kompletní Produkční Infrastruktura

**Verze:** 1.0  
**Datum:** 16. prosince 2024  
**Autor:** Claude AI + Martin (CEO Praut s.r.o.)  
**Web:** https://posthub.work

---

## 📋 Obsah

1. [Přehled Architektury](#přehled-architektury)
2. [Server a Síťová Konfigurace](#server-a-síťová-konfigurace)
3. [Docker Services](#docker-services)
4. [Nginx Konfigurace](#nginx-konfigurace)
5. [Backend (Django)](#backend-django)
6. [Frontend (Angular)](#frontend-angular)
7. [Databáze a Cache](#databáze-a-cache)
8. [Celery Workers](#celery-workers)
9. [CI/CD Pipeline](#cicd-pipeline)
10. [Environment Variables](#environment-variables)
11. [SSL a Bezpečnost](#ssl-a-bezpečnost)
12. [Monitoring a Health Checks](#monitoring-a-health-checks)
13. [Časté Problémy a Řešení](#časté-problémy-a-řešení)

---

## 🏗️ Přehled Architektury

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              INTERNET                                        │
│                                  │                                           │
│                                  ▼                                           │
│                     ┌─────────────────────────┐                             │
│                     │   posthub.work (DNS)    │                             │
│                     │     72.62.92.89         │                             │
│                     └───────────┬─────────────┘                             │
│                                 │                                           │
│                                 ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                    HOST NGINX (Port 80/443)                         │   │
│   │              /etc/nginx/sites-available/posthub                     │   │
│   │                                                                     │   │
│   │    /api/* ──────────────► 127.0.0.1:8000 (Django API)              │   │
│   │    /*     ──────────────► 127.0.0.1:4200 (Angular Frontend)        │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                 │                                           │
│                                 ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                    DOCKER NETWORK                                   │   │
│   │               posthubveriv_posthub_network                          │   │
│   │                                                                     │   │
│   │  ┌───────────────┐  ┌───────────────┐  ┌───────────────────────┐   │   │
│   │  │  PostgreSQL   │  │    Redis      │  │   Django API          │   │   │
│   │  │  (pgvector)   │  │   (7-alpine)  │  │   (Gunicorn)          │   │   │
│   │  │  Port: 5432   │  │   Port: 6379  │  │   Port: 8000          │   │   │
│   │  │  93 tables    │  │   256MB max   │  │   4 workers           │   │   │
│   │  └───────────────┘  └───────────────┘  └───────────────────────┘   │   │
│   │                                                                     │   │
│   │  ┌───────────────┐  ┌───────────────┐  ┌───────────────────────┐   │   │
│   │  │ Celery Worker │  │ Celery AI     │  │   Celery Beat         │   │   │
│   │  │ default,quick │  │ ai_jobs       │  │   DatabaseScheduler   │   │   │
│   │  │ concurrency=4 │  │ concurrency=2 │  │                       │   │   │
│   │  └───────────────┘  └───────────────┘  └───────────────────────┘   │   │
│   │                                                                     │   │
│   │  ┌───────────────┐  ┌───────────────┐  ┌───────────────────────┐   │   │
│   │  │   Frontend    │  │    Flower     │  │      Certbot          │   │   │
│   │  │   (Nginx)     │  │   Port: 5555  │  │   SSL renewal         │   │   │
│   │  │   Port: 80    │  │               │  │   every 12h           │   │   │
│   │  └───────────────┘  └───────────────┘  └───────────────────────┘   │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Klíčové Komponenty

| Komponenta | Technologie | Účel |
|------------|-------------|------|
| **API** | Django 5.x + Gunicorn | REST API, autentizace, business logika |
| **Frontend** | Angular 19 + Nginx | SPA, UI |
| **Database** | PostgreSQL 16 + pgvector | Relační data + vektorové embeddings |
| **Cache/Broker** | Redis 7 | Cache, Celery message broker |
| **Task Queue** | Celery | Asynchronní úlohy, AI jobs |
| **Reverse Proxy** | Nginx (host) | SSL termination, routing |

---

## 🖥️ Server a Síťová Konfigurace

### Server Details

| Parametr | Hodnota |
|----------|---------|
| **Hostname** | srv1199790 |
| **IP Address** | 72.62.92.89 |
| **Location** | /opt/PostHubVerIV |
| **OS** | Ubuntu (předpoklad) |
| **Docker Version** | Docker Compose v2 |

### Domain Configuration

| Domain | Směrování |
|--------|-----------|
| posthub.work | → 72.62.92.89 |
| www.posthub.work | → 72.62.92.89 |

### Port Mapping

```
EXTERNAL PORTS (Host)
├── 80    → Host Nginx (HTTP → HTTPS redirect)
├── 443   → Host Nginx (HTTPS - SSL termination)
└── 5555  → Flower (Celery monitoring)

INTERNAL PORTS (Docker → Host localhost)
├── 127.0.0.1:8000 → posthub_api_prod (Django)
└── 127.0.0.1:4200 → posthub_frontend_prod (Angular/Nginx)

DOCKER INTERNAL (Container-to-Container)
├── postgres:5432   → PostgreSQL
├── redis:6379      → Redis
├── api:8000        → Django API
└── frontend:80     → Angular App
```

### Docker Networks

```bash
# Aktivní síť pro PostHub
posthubveriv_posthub_network   bridge    local

# Stará nepoužívaná síť (může být odstraněna)
posthub_network                bridge    local
```

---

## 🐳 Docker Services

### Aktuální Stav Kontejnerů

```
NAME                            STATUS                      PORTS
posthub_api_prod                Up (healthy)                127.0.0.1:8000->8000/tcp
posthub_frontend_prod           Up (unhealthy*)             127.0.0.1:4200->80/tcp
posthub_postgres_prod           Up (healthy)                5432/tcp
posthub_redis_prod              Up (healthy)                6379/tcp
posthub_celery_worker_prod      Up (unhealthy*)             8000/tcp
posthub_celery_worker_ai_prod   Up (unhealthy*)             8000/tcp
posthub_celery_beat_prod        Up (unhealthy*)             8000/tcp
posthub_certbot                 Up                          80/tcp, 443/tcp
posthub_flower                  Up                          0.0.0.0:5555->5555/tcp
```

> **⚠️ Poznámka k "unhealthy":** Celery workers a frontend mají špatně nakonfigurované healthchecky (kontrolují HTTP port 8000, který celery nemá). Služby **fungují správně** - jde pouze o healthcheck konfiguraci.

### Resource Limits

| Service | Memory | CPU |
|---------|--------|-----|
| PostgreSQL | 1G | 1.0 |
| Redis | 512M | 0.5 |
| API | 512M | 0.5 |
| Celery Worker | 512M | 0.5 |
| Celery AI Worker | 1G | 1.0 |
| Celery Beat | 256M | 0.25 |
| Frontend | 128M | 0.25 |

### Docker Disk Usage

```
TYPE            TOTAL     ACTIVE    SIZE       RECLAIMABLE
Images          11        10        14.73GB    14.73GB (99%)
Containers      10        9         1.082GB    36.86kB (0%)
Local Volumes   5         3         414.4MB    339.5MB (81%)
Build Cache     100       0         11.3GB     9.849GB
```

---

## 🌐 Nginx Konfigurace

### Host Nginx (/etc/nginx/sites-available/posthub)

Tento nginx běží na hostiteli a routuje požadavky do Docker kontejnerů:

```nginx
server {
    listen 80;
    server_name posthub.work;

    # Frontend (Angular SPA)
    location / {
        proxy_pass http://127.0.0.1:4200;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_cache_bypass $http_upgrade;
    }

    # API (Django)
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Docker Nginx (nginx/nginx.prod.conf)

Pokročilá konfigurace v Docker kontejneru (aktuálně nepoužívána, port konflikt):

**Klíčové Features:**
- SSL/TLS termination (TLS 1.2, 1.3)
- HSTS headers
- Gzip compression
- Rate limiting:
  - API: 10 req/s
  - Auth endpoints: 5 req/min
- Security headers (X-Frame-Options, CSP, etc.)
- Upstream load balancing (least_conn)
- Let's Encrypt integration

---

## 🐍 Backend (Django)

### Dockerfile Multi-stage Build

```dockerfile
# Stage 1: BASE - Common dependencies
FROM python:3.12-slim as base
# Install build-essential, libpq-dev, curl

# Stage 2: BUILDER - Build wheels
FROM base as builder
# pip wheel production requirements

# Stage 3: PRODUCTION - Minimal image
FROM python:3.12-slim as production
# Install only runtime deps (libpq5, curl)
# Copy wheels and install
# Create non-root user (appuser:1000)
# Collect static files with dummy env vars
# Run as appuser
# Gunicorn: 4 workers, 2 threads
```

### Gunicorn Configuration

```bash
gunicorn config.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 4 \
    --threads 2
```

### Django Settings (Production)

**Povinné Environment Variables:**
```python
SECRET_KEY = env('SECRET_KEY')
ALLOWED_HOSTS = env.list('ALLOWED_HOSTS')
CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS')
STRIPE_LIVE_PUBLIC_KEY = env('STRIPE_PUBLIC_KEY')
STRIPE_LIVE_SECRET_KEY = env('STRIPE_SECRET_KEY')
SENTRY_DSN = env('SENTRY_DSN', default='')

# Redis Cache
CACHES = {
    'default': {
        'LOCATION': env('REDIS_CACHE_URL'),  # redis://redis:6379/1
    }
}
```

### Database Schema

- **Tabulek:** 93
- **Engine:** PostgreSQL 16 with pgvector extension
- **Connection:** `postgres://posthub:***@postgres:5432/posthub`

### Static Files Collection

Build-time collectstatic s dummy hodnotami:

```dockerfile
RUN SECRET_KEY=build-only-key \
    DATABASE_URL=postgres://localhost/dummy \
    REDIS_CACHE_URL=redis://localhost:6379/0 \
    STRIPE_PUBLIC_KEY=pk_test_dummy \
    STRIPE_SECRET_KEY=sk_test_dummy \
    ALLOWED_HOSTS=localhost \
    CORS_ALLOWED_ORIGINS=http://localhost \
    python manage.py collectstatic --noinput
```

---

## 🅰️ Frontend (Angular)

### Technologie

| Stack | Verze |
|-------|-------|
| Angular | 19.x |
| Node.js | 20 |
| Angular CLI | 17 |
| Web Server | Nginx 1.25-alpine |

### Dockerfile Multi-stage Build

```dockerfile
# Stage 1: BUILDER - Build Angular
FROM node:20-alpine as builder
RUN npm install -g @angular/cli@17
RUN npm ci --prefer-offline
RUN ng build --configuration=production

# Stage 2: PRODUCTION - Serve with Nginx
FROM nginx:1.25-alpine as production
COPY --from=builder /app/dist/posthub/browser /usr/share/nginx/html
COPY docker-entrypoint.sh /docker-entrypoint.sh
```

### Runtime Environment Substitution

Frontend podporuje runtime env substitution pro:
- `STRIPE_PUBLIC_KEY`
- `SENTRY_DSN`
- `VERSION`

---

## 🗄️ Databáze a Cache

### PostgreSQL

| Parametr | Hodnota |
|----------|---------|
| **Image** | pgvector/pgvector:pg16 |
| **Container** | posthub_postgres_prod |
| **User** | posthub |
| **Database** | posthub |
| **Port** | 5432 (internal) |
| **Volume** | postgres_data |
| **Extensions** | pgvector (pro AI embeddings) |

**Healthcheck:**
```yaml
test: ["CMD-SHELL", "pg_isready -U posthub -d posthub"]
interval: 10s
timeout: 5s
retries: 5
```

### Redis

| Parametr | Hodnota |
|----------|---------|
| **Image** | redis:7-alpine |
| **Container** | posthub_redis_prod |
| **Port** | 6379 (internal) |
| **Max Memory** | 256MB |
| **Eviction Policy** | allkeys-lru |
| **Persistence** | AOF (appendonly yes) |
| **Volume** | redis_data |

**Použití:**
- `redis://redis:6379/0` - Celery Broker
- `redis://redis:6379/1` - Django Cache

---

## ⚙️ Celery Workers

### Worker Queues

| Worker | Queues | Concurrency | Memory |
|--------|--------|-------------|--------|
| **celery-worker** | default, quick, scheduled | 4 | 512M |
| **celery-worker-ai** | ai_jobs, ai_priority | 2 | 1G |
| **celery-beat** | - (scheduler) | - | 256M |

### Commands

```bash
# Default worker
celery -A config worker -l INFO -Q default,quick,scheduled --concurrency=4

# AI worker
celery -A config worker -l INFO -Q ai_jobs,ai_priority --concurrency=2

# Beat scheduler
celery -A config beat -l INFO --scheduler django_celery_beat.schedulers:DatabaseScheduler
```

### Flower Monitoring

- **URL:** http://72.62.92.89:5555
- **Container:** posthub_flower
- **Port:** 5555

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

**Trigger:** Push to `main` or `develop`, PR to `main`

```yaml
Jobs:
  1. test-backend     # Python tests, linting, coverage
  2. test-frontend    # Angular tests, linting, build
  3. security-scan    # Trivy vulnerability scanner
  4. build            # Docker images → GHCR
  5. deploy           # SSH → VPS deployment
  6. rollback         # Manual rollback (workflow_dispatch)
```

### Backend Tests

```yaml
services:
  - postgres (pgvector/pgvector:pg16)
  - redis (redis:7-alpine)

steps:
  - flake8 linting (max-line-length=120)
  - isort import sorting
  - pytest with coverage
```

### Deploy Process

```bash
# 1. SSH to VPS
ssh $VPS_HOST

# 2. Pull latest code
cd /opt/PostHubVerIV
git pull origin main

# 3. Login to GHCR
docker login ghcr.io -u $GITHUB_ACTOR

# 4. Pull new images
docker compose -f docker-compose.prod.yml pull

# 5. Run migrations
docker compose -f docker-compose.prod.yml run --rm api python manage.py migrate --noinput

# 6. Restart services
docker compose -f docker-compose.prod.yml up -d --force-recreate

# 7. Cleanup
docker image prune -f

# 8. Health check
curl -f http://localhost:8000/healthz/
```

### GitHub Secrets Required

```
VPS_HOST          # Server IP/hostname
VPS_USER          # SSH username
SSH_PRIVATE_KEY   # SSH key for deployment
GITHUB_TOKEN      # Auto-provided by GitHub
```

---

## 🔐 Environment Variables

### Kompletní Seznam (.env.production)

```bash
# ===========================================
# DJANGO CORE
# ===========================================
DEBUG=False
SECRET_KEY=<64-char-random-string>
ALLOWED_HOSTS=127.0.0.1,localhost,posthub.work,www.posthub.work,72.62.92.89
CORS_ALLOWED_ORIGINS=https://posthub.work,https://www.posthub.work
CSRF_TRUSTED_ORIGINS=https://posthub.work,https://www.posthub.work
FRONTEND_URL=https://posthub.work
LOG_LEVEL=INFO

# ===========================================
# DATABASE
# ===========================================
POSTGRES_USER=posthub
POSTGRES_PASSWORD=<strong-password>
POSTGRES_DB=posthub
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
DATABASE_URL=postgres://posthub:<password>@postgres:5432/posthub

# ===========================================
# REDIS
# ===========================================
REDIS_URL=redis://redis:6379/0
REDIS_CACHE_URL=redis://redis:6379/1

# ===========================================
# CELERY
# ===========================================
CELERY_BROKER_URL=redis://redis:6379/0
CELERY_RESULT_BACKEND=redis://redis:6379/0
CELERY_TASK_ALWAYS_EAGER=False
CELERY_TASK_TRACK_STARTED=True

# ===========================================
# JWT AUTHENTICATION
# ===========================================
JWT_ACCESS_TOKEN_LIFETIME_MINUTES=60
JWT_REFRESH_TOKEN_LIFETIME_DAYS=7
JWT_SIGNING_KEY=<random-signing-key>

# ===========================================
# STRIPE PAYMENTS
# ===========================================
STRIPE_PUBLIC_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
DJSTRIPE_WEBHOOK_VALIDATION=verify_signature

# Price IDs
STRIPE_PRICE_BASIC=price_...
STRIPE_PRICE_PRO=price_...
STRIPE_PRICE_ENTERPRISE=price_...
STRIPE_PRICE_BASIC_YEARLY=price_...
STRIPE_PRICE_PRO_YEARLY=price_...
STRIPE_PRICE_ENTERPRISE_YEARLY=price_...

# Add-on Price IDs
STRIPE_PRICE_ADDON_REGENERATING=price_...
STRIPE_PRICE_ADDON_STORAGE=price_...
STRIPE_PRICE_ADDON_MARKETER=price_...
STRIPE_PRICE_ADDON_PLATFORMA=price_...
STRIPE_PRICE_ADDON_VISUAL=price_...
STRIPE_PRICE_ADDON_LANGUAGE=price_...
STRIPE_PRICE_ADDON_PERSONA=price_...
STRIPE_PRICE_ADDON_SUPERVISOR=price_...

# ===========================================
# AI API KEYS
# ===========================================
GEMINI_API_KEY=AIza...        # Google AI
PERPLEXITY_API_KEY=pplx-...   # Company research
NANOBANA_API_KEY=AIza...      # Image generation
VEO_API_KEY=AIza...           # Video generation

# ===========================================
# MONITORING (Optional)
# ===========================================
SENTRY_DSN=                   # Error tracking
```

---

## 🔒 SSL a Bezpečnost

### SSL Status

| Komponenta | Stav |
|------------|------|
| **Host Nginx** | ⚠️ HTTP only (port 80) |
| **Docker Nginx** | ✅ SSL configured (neběží) |
| **Certbot** | ✅ Běží, ale /certbot/conf prázdné |

### Doporučené Kroky pro SSL

1. **Vygenerovat certifikát:**
```bash
docker compose -f docker-compose.prod.yml run --rm certbot certonly \
    --webroot -w /var/www/certbot \
    -d posthub.work -d www.posthub.work \
    --email admin@posthub.work \
    --agree-tos
```

2. **Nakonfigurovat host nginx pro HTTPS** nebo
3. **Spustit Docker nginx místo host nginx**

### Security Headers (v Docker Nginx)

```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload";
add_header X-Frame-Options "SAMEORIGIN";
add_header X-Content-Type-Options "nosniff";
add_header X-XSS-Protection "1; mode=block";
add_header Referrer-Policy "strict-origin-when-cross-origin";
add_header Content-Security-Policy "default-src 'self'; ...";
```

### Rate Limiting

| Endpoint | Limit |
|----------|-------|
| `/api/*` | 10 req/s (burst 20) |
| `/api/v1/auth/login/` | 5 req/min (burst 5) |
| `/api/v1/auth/register/` | 5 req/min (burst 5) |
| `/api/v1/billing/webhook/` | Bez limitu |

---

## 📊 Monitoring a Health Checks

### Health Endpoints

| Service | Endpoint | Expected |
|---------|----------|----------|
| **API** | `http://localhost:8000/healthz/` | 200 OK (301 redirect) |
| **Frontend** | `http://localhost:4200/health` | 200 "healthy" |
| **PostgreSQL** | `pg_isready` | exit 0 |
| **Redis** | `redis-cli ping` | PONG |

### Flower Dashboard

**URL:** http://72.62.92.89:5555

Monitoruje:
- Aktivní workers
- Task queue délka
- Task success/failure rate
- Worker resource usage

### Užitečné Diagnostické Příkazy

```bash
# Stav všech kontejnerů
docker compose -f docker-compose.prod.yml ps

# Logy konkrétní služby
docker compose -f docker-compose.prod.yml logs --tail=100 api
docker compose -f docker-compose.prod.yml logs --tail=100 celery-worker

# Test API
docker exec posthub_api_prod curl -s http://localhost:8000/healthz/

# Test DB
docker exec posthub_postgres_prod psql -U posthub -d posthub -c "SELECT 1"

# Test Redis
docker exec posthub_redis_prod redis-cli ping

# Disk usage
docker system df
```

---

## 🔧 Časté Problémy a Řešení

### 1. Port Already in Use (80/443)

**Problém:** Docker nginx nemůže nastartovat, port obsazen host nginx.

**Řešení:** Použít host nginx pro routing (aktuální setup), nebo zastavit host nginx:
```bash
systemctl stop nginx
docker compose -f docker-compose.prod.yml up -d nginx
```

### 2. Database Password Mismatch

**Problém:** `FATAL: password authentication failed for user "posthub"`

**Řešení:**
```bash
# Zkontrolovat heslo v env
grep DATABASE_URL .env.production

# Změnit heslo v PostgreSQL
docker exec posthub_postgres_prod psql -U posthub -d posthub \
    -c "ALTER USER posthub WITH PASSWORD 'new_password';"

# Restart služeb
docker compose -f docker-compose.prod.yml restart api celery-worker celery-beat
```

### 3. Static Files Missing (collectstatic)

**Problém:** Django collectstatic fails during Docker build.

**Řešení:** Přidat všechny required env vars jako dummy hodnoty:
```dockerfile
RUN SECRET_KEY=build-only-key \
    DATABASE_URL=postgres://localhost/dummy \
    REDIS_CACHE_URL=redis://localhost:6379/0 \
    STRIPE_PUBLIC_KEY=pk_test_dummy \
    STRIPE_SECRET_KEY=sk_test_dummy \
    ALLOWED_HOSTS=localhost \
    CORS_ALLOWED_ORIGINS=http://localhost \
    python manage.py collectstatic --noinput
```

### 4. ALLOWED_HOSTS Error (400 Bad Request)

**Problém:** `Invalid HTTP_HOST header`

**Řešení:**
```bash
# Přidat host do ALLOWED_HOSTS
ALLOWED_HOSTS=127.0.0.1,localhost,posthub.work,www.posthub.work,72.62.92.89

# Restart API
docker compose -f docker-compose.prod.yml restart api
```

### 5. Celery Workers "unhealthy"

**Problém:** Celery workers hlásí unhealthy stav.

**Vysvětlení:** Healthcheck kontroluje HTTP port 8000, ale Celery nemá HTTP server. Služby **fungují správně**.

**Řešení (volitelné):** Změnit healthcheck na:
```yaml
healthcheck:
  test: ["CMD", "celery", "-A", "config", "inspect", "ping"]
  interval: 30s
  timeout: 10s
  retries: 3
```

### 6. Frontend Restarting (exit 137)

**Problém:** Frontend container neustále restartuje.

**Příčina:** Běží v dev mode (`ng serve`) místo production (nginx).

**Řešení:** Přebuildit frontend:
```bash
docker compose -f docker-compose.prod.yml build --no-cache frontend
docker compose -f docker-compose.prod.yml up -d --force-recreate frontend
```

---

## 📝 Git Historie (Poslední Commity)

```
82da830 Add port mappings for host nginx proxy (8000, 4200)
8af3431 Fix Docker build: add all required env vars for collectstatic
113f7d9 Change deploy from Kubernetes to SSH + docker-compose
c1af06a Fix Docker build: add all required dummy env vars for collectstatic
c2f0a16 Fix Docker build: add dummy env vars for collectstatic
c38f674 Fix Docker build: set DJANGO_SETTINGS_MODULE for production
6443ac2 Fix Dockerfile: copy base.txt for production stage
461bd9f Regenerate package-lock.json for Angular 19 upgrade
73cdb4a Fix ngrx peer dependency: upgrade @ngrx/signals 17 to 19
20d96e6 Fix security vulnerabilities: upgrade Angular 17 to 19
```

**Repository:** git@github.com:EmperorKunDis/PostHubVerIV.git

---

## 📞 Kontakt

**Společnost:** Praut s.r.o.  
**CEO:** Martin  
**Web:** https://posthub.work  
**Produkt:** PostHub - AI-powered social media automation

---

*Dokumentace vygenerována: 16. prosince 2024*

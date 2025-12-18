# 08_INFRASTRUCTURE.md - Kompletní Infrastruktura

**Dokument:** Infrastructure & DevOps pro PostHub.work  
**Verze:** 1.0.0  
**Self-Contained:** ✅ Všechny informace o infrastruktuře

---

> ## ⚠️ DŮLEŽITÉ UPOZORNĚNÍ
> 
> **Sekce 1-6** tohoto dokumentu popisují **PLÁNOVANOU/IDEÁLNÍ** produkční architekturu s Kubernetes.  
> **Sekce 7** popisuje **SKUTEČNÝ AKTUÁLNÍ STAV** - VPS s docker-compose.  
> 
> **Shoda dokumentace s realitou: ~15-20%**
> 
> - ✅ **Development setup (sekce 2)** = PLATÍ
> - ⚠️ **Production setup (sekce 3-6)** = CÍLOVÝ STAV (neplatí)
> - ✅ **Reality check (sekce 7)** = SOUČASNOST

---

## 📋 OBSAH

1. [Architecture Overview](#1-architecture-overview) *(Plánovaný stav - K8s)*
2. [Docker Development](#2-docker-development) *(Platí - Dev environment)*
3. [Kubernetes Production](#3-kubernetes-production) *(Plánovaný stav - K8s)*
4. [CI/CD Pipeline](#4-cicd-pipeline) *(Plánovaný stav - K8s)*
5. [Monitoring](#5-monitoring) *(Plánovaný stav - Prometheus/Grafana)*
6. [Backup & Recovery](#6-backup--recovery) *(Plánovaný stav - K8s CronJob)*
7. [**Aktuální Produkční Stav**](#7-aktuální-produkční-stav-reality-check) ⚠️ **← SOUČASNÁ REALITA**

---

## 1. ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────────────────────────────────┐
│                        KUBERNETES CLUSTER                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │  Ingress │  │   API    │  │  Celery  │  │  Celery  │        │
│  │  Nginx   │──│  Django  │  │  Worker  │  │   Beat   │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
│       │              │              │              │             │
│       │              ▼              ▼              │             │
│       │        ┌──────────┐  ┌──────────┐         │             │
│       │        │  Redis   │  │ PostgreSQL│         │             │
│       │        │  Cluster │  │  Primary │         │             │
│       │        └──────────┘  └──────────┘         │             │
│       │                            │                             │
│       │                      ┌──────────┐                       │
│       │                      │ PostgreSQL│                       │
│       │                      │  Replica │                       │
│       │                      └──────────┘                       │
├───────┴─────────────────────────────────────────────────────────┤
│                     EXTERNAL SERVICES                            │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐        │
│  │ Gemini │ │Perplx. │ │Nanobana│ │  Veo   │ │ Stripe │        │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

### Resource Requirements

| Service | CPU | Memory | Replicas |
|---------|-----|--------|----------|
| API (Django) | 500m-2000m | 512Mi-2Gi | 2-10 |
| Celery Worker | 500m-2000m | 1Gi-4Gi | 2-20 |
| Celery Beat | 100m | 256Mi | 1 |
| Redis | 500m | 1Gi | 3 (cluster) |
| PostgreSQL | 1000m-4000m | 4Gi-16Gi | 1+1 replica |

---

## 2. DOCKER DEVELOPMENT

### docker-compose.yml

```yaml
# docker-compose.yml
version: '3.9'

services:
  # PostgreSQL Database
  db:
    image: pgvector/pgvector:pg16
    container_name: posthub_db
    environment:
      POSTGRES_DB: posthub
      POSTGRES_USER: posthub
      POSTGRES_PASSWORD: posthub_dev_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U posthub"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis
  redis:
    image: redis:7-alpine
    container_name: posthub_redis
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Django API
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: posthub_api
    command: >
      sh -c "python manage.py migrate &&
             python manage.py runserver 0.0.0.0:8000"
    volumes:
      - ./backend:/app
      - static_volume:/app/staticfiles
      - media_volume:/app/media
    ports:
      - "8000:8000"
    environment:
      - DEBUG=True
      - DATABASE_URL=postgres://posthub:posthub_dev_password@db:5432/posthub
      - REDIS_URL=redis://redis:6379/0
      - CELERY_BROKER_URL=redis://redis:6379/0
      - DJANGO_SETTINGS_MODULE=config.settings.development
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy

  # Celery Worker
  celery_worker:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: posthub_celery_worker
    command: celery -A config worker -l INFO -Q default,high_priority,low_priority
    volumes:
      - ./backend:/app
    environment:
      - DATABASE_URL=postgres://posthub:posthub_dev_password@db:5432/posthub
      - REDIS_URL=redis://redis:6379/0
      - CELERY_BROKER_URL=redis://redis:6379/0
      - DJANGO_SETTINGS_MODULE=config.settings.development
    depends_on:
      - api
      - redis

  # Celery Beat
  celery_beat:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: posthub_celery_beat
    command: celery -A config beat -l INFO --scheduler django_celery_beat.schedulers:DatabaseScheduler
    volumes:
      - ./backend:/app
    environment:
      - DATABASE_URL=postgres://posthub:posthub_dev_password@db:5432/posthub
      - REDIS_URL=redis://redis:6379/0
      - CELERY_BROKER_URL=redis://redis:6379/0
      - DJANGO_SETTINGS_MODULE=config.settings.development
    depends_on:
      - api
      - redis

  # Angular Frontend
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    container_name: posthub_frontend
    command: npm start -- --host 0.0.0.0
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "4200:4200"
    environment:
      - NODE_ENV=development

  # Flower (Celery monitoring)
  flower:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: posthub_flower
    command: celery -A config flower --port=5555
    ports:
      - "5555:5555"
    environment:
      - CELERY_BROKER_URL=redis://redis:6379/0
    depends_on:
      - redis
      - celery_worker

volumes:
  postgres_data:
  redis_data:
  static_volume:
  media_volume:
```

### Backend Dockerfile

```dockerfile
# backend/Dockerfile
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements/base.txt requirements/base.txt
COPY requirements/production.txt requirements/production.txt
RUN pip install --no-cache-dir -r requirements/production.txt

# Copy application
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

# Create non-root user
RUN adduser --disabled-password --gecos '' appuser
USER appuser

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "config.wsgi:application"]
```

### Frontend Dockerfile

```dockerfile
# frontend/Dockerfile.dev
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 4200

CMD ["npm", "start"]
```

### Production Frontend Dockerfile

```dockerfile
# frontend/Dockerfile
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build -- --configuration production

FROM nginx:alpine
COPY --from=builder /app/dist/posthub/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## 3. KUBERNETES PRODUCTION

### Namespace

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: posthub
  labels:
    name: posthub
```

### ConfigMap

```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: posthub-config
  namespace: posthub
data:
  DJANGO_SETTINGS_MODULE: "config.settings.production"
  ALLOWED_HOSTS: "api.posthub.work,posthub.work"
  CORS_ALLOWED_ORIGINS: "https://posthub.work"
  REDIS_URL: "redis://redis-master:6379/0"
```

### Secrets

```yaml
# k8s/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: posthub-secrets
  namespace: posthub
type: Opaque
stringData:
  DATABASE_URL: "postgres://user:pass@postgres:5432/posthub"
  SECRET_KEY: "your-production-secret-key"
  STRIPE_SECRET_KEY: "sk_live_..."
  GEMINI_API_KEY: "your-gemini-key"
  PERPLEXITY_API_KEY: "your-perplexity-key"
  NANOBANA_API_KEY: "your-nanobana-key"
```

### API Deployment

```yaml
# k8s/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: posthub-api
  namespace: posthub
spec:
  replicas: 3
  selector:
    matchLabels:
      app: posthub-api
  template:
    metadata:
      labels:
        app: posthub-api
    spec:
      containers:
        - name: api
          image: posthub/api:latest
          ports:
            - containerPort: 8000
          envFrom:
            - configMapRef:
                name: posthub-config
            - secretRef:
                name: posthub-secrets
          resources:
            requests:
              cpu: "500m"
              memory: "512Mi"
            limits:
              cpu: "2000m"
              memory: "2Gi"
          readinessProbe:
            httpGet:
              path: /api/v1/health/
              port: 8000
            initialDelaySeconds: 10
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /api/v1/health/
              port: 8000
            initialDelaySeconds: 30
            periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: posthub-api
  namespace: posthub
spec:
  selector:
    app: posthub-api
  ports:
    - port: 80
      targetPort: 8000
  type: ClusterIP
```

### Celery Worker Deployment

```yaml
# k8s/celery-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: posthub-celery-worker
  namespace: posthub
spec:
  replicas: 3
  selector:
    matchLabels:
      app: posthub-celery-worker
  template:
    metadata:
      labels:
        app: posthub-celery-worker
    spec:
      containers:
        - name: worker
          image: posthub/api:latest
          command: ["celery", "-A", "config", "worker", "-l", "INFO", "-Q", "default,high_priority"]
          envFrom:
            - configMapRef:
                name: posthub-config
            - secretRef:
                name: posthub-secrets
          resources:
            requests:
              cpu: "500m"
              memory: "1Gi"
            limits:
              cpu: "2000m"
              memory: "4Gi"
```

### HorizontalPodAutoscaler

```yaml
# k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: posthub-api-hpa
  namespace: posthub
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: posthub-api
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: posthub-celery-hpa
  namespace: posthub
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: posthub-celery-worker
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

### Ingress

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: posthub-ingress
  namespace: posthub
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  tls:
    - hosts:
        - posthub.work
        - api.posthub.work
      secretName: posthub-tls
  rules:
    - host: posthub.work
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: posthub-frontend
                port:
                  number: 80
    - host: api.posthub.work
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: posthub-api
                port:
                  number: 80
```

---

## 4. CI/CD PIPELINE

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

env:
  REGISTRY: ghcr.io
  API_IMAGE: ghcr.io/${{ github.repository }}/api
  FRONTEND_IMAGE: ghcr.io/${{ github.repository }}/frontend

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: pgvector/pgvector:pg16
        env:
          POSTGRES_PASSWORD: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: pip install -r backend/requirements/test.txt
      - run: pytest backend/ --cov=apps

  build-api:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: ${{ env.API_IMAGE }}:${{ github.sha }},${{ env.API_IMAGE }}:latest

  build-frontend:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v5
        with:
          context: ./frontend
          push: true
          tags: ${{ env.FRONTEND_IMAGE }}:${{ github.sha }},${{ env.FRONTEND_IMAGE }}:latest

  deploy:
    needs: [build-api, build-frontend]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: azure/k8s-set-context@v3
        with:
          kubeconfig: ${{ secrets.KUBE_CONFIG }}
      - run: |
          kubectl set image deployment/posthub-api api=${{ env.API_IMAGE }}:${{ github.sha }} -n posthub
          kubectl set image deployment/posthub-celery-worker worker=${{ env.API_IMAGE }}:${{ github.sha }} -n posthub
          kubectl set image deployment/posthub-frontend frontend=${{ env.FRONTEND_IMAGE }}:${{ github.sha }} -n posthub
          kubectl rollout status deployment/posthub-api -n posthub
```

---

## 5. MONITORING

### Prometheus ServiceMonitor

```yaml
# k8s/monitoring/servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: posthub-api
  namespace: posthub
spec:
  selector:
    matchLabels:
      app: posthub-api
  endpoints:
    - port: http
      path: /metrics
      interval: 30s
```

### Django Prometheus

```python
# requirements/base.txt
django-prometheus>=2.3.0

# config/settings/base.py
INSTALLED_APPS = [
    ...
    'django_prometheus',
]

MIDDLEWARE = [
    'django_prometheus.middleware.PrometheusBeforeMiddleware',
    ...
    'django_prometheus.middleware.PrometheusAfterMiddleware',
]

# config/urls.py
urlpatterns = [
    path('', include('django_prometheus.urls')),
    ...
]
```

### Grafana Dashboard (JSON)

```json
{
  "title": "PostHub API",
  "panels": [
    {
      "title": "Request Rate",
      "targets": [
        {
          "expr": "rate(django_http_requests_total_by_method_total[5m])"
        }
      ]
    },
    {
      "title": "Response Time P95",
      "targets": [
        {
          "expr": "histogram_quantile(0.95, rate(django_http_requests_latency_seconds_by_view_method_bucket[5m]))"
        }
      ]
    },
    {
      "title": "Celery Tasks",
      "targets": [
        {
          "expr": "rate(celery_tasks_total[5m])"
        }
      ]
    }
  ]
}
```

### Alerting Rules

```yaml
# k8s/monitoring/alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: posthub-alerts
  namespace: posthub
spec:
  groups:
    - name: posthub
      rules:
        - alert: HighErrorRate
          expr: rate(django_http_responses_total_by_status_total{status=~"5.."}[5m]) > 0.1
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "High error rate detected"
        
        - alert: CeleryQueueBacklog
          expr: celery_queue_length > 1000
          for: 10m
          labels:
            severity: warning
          annotations:
            summary: "Celery queue backlog"
        
        - alert: HighMemoryUsage
          expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.9
          for: 5m
          labels:
            severity: warning
```

---

## 6. BACKUP & RECOVERY

### PostgreSQL Backup CronJob

```yaml
# k8s/backup/postgres-backup.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
  namespace: posthub
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: backup
              image: postgres:16
              command:
                - /bin/sh
                - -c
                - |
                  FILENAME=posthub_$(date +%Y%m%d_%H%M%S).sql.gz
                  pg_dump $DATABASE_URL | gzip > /backup/$FILENAME
                  # Upload to S3
                  aws s3 cp /backup/$FILENAME s3://posthub-backups/postgres/
              envFrom:
                - secretRef:
                    name: posthub-secrets
              volumeMounts:
                - name: backup
                  mountPath: /backup
          volumes:
            - name: backup
              emptyDir: {}
          restartPolicy: OnFailure
```

### Restore Script

```bash
#!/bin/bash
# scripts/restore-db.sh

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: ./restore-db.sh <backup_file>"
    exit 1
fi

# Download from S3
aws s3 cp s3://posthub-backups/postgres/$BACKUP_FILE /tmp/

# Restore
gunzip -c /tmp/$BACKUP_FILE | psql $DATABASE_URL

echo "Restore completed"
```

---

## 7. AKTUÁLNÍ PRODUKČNÍ STAV (REALITY CHECK)

> **⚠️ DŮLEŽITÉ:** Sekce 1-6 v tomto dokumentu popisují **PLÁNOVANOU/IDEÁLNÍ** architekturu s Kubernetes.  
> **Tato sekce (7) popisuje SKUTEČNÝ aktuální stav** produkčního deploymentu k prosinci 2024.

---

### 7.1 Overview - Co je jinak

```
┌─────────────────────────────────────────────────────────────────┐
│                    SKUTEČNÝ PRODUKČNÍ VPS                        │
│                     Server: 72.62.92.89                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │  Caddy   │  │   API    │  │  Celery  │  │  Celery  │        │
│  │  Proxy   │──│  Django  │  │  Worker  │  │   Beat   │        │
│  │  + TLS   │  │ Gunicorn │  │ (default)│  │ Database │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
│       │              │              │              │             │
│       │              │        ┌──────────┐         │             │
│       │              │        │  Celery  │         │             │
│       │              │        │  Worker  │         │             │
│       │              │        │   (AI)   │         │             │
│       │              │        └──────────┘         │             │
│       │              ▼              ▼              │             │
│       │        ┌──────────┐  ┌──────────┐         │             │
│       │        │  Redis   │  │PostgreSQL│         │             │
│       │        │  Single  │  │ Single   │         │             │
│       │        └──────────┘  └──────────┘         │             │
│       │                                                          │
│       │        ┌──────────┐                                     │
│       └────────│  Flower  │                                     │
│                │   :5555  │                                     │
│                └──────────┘                                     │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────┐                                                   │
│  │ Frontend │                                                   │
│  │ Angular  │                                                   │
│  │  Nginx   │                                                   │
│  └──────────┘                                                   │
├─────────────────────────────────────────────────────────────────┤
│                     EXTERNAL SERVICES                            │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐        │
│  │ Gemini │ │Perplx. │ │Nanobana│ │  Veo   │ │ Stripe │        │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

---

### 7.2 Produkční Deployment - docker-compose.prod.yml

**Aktuální stav:** VPS s Docker Compose (9 kontejnerů)

```yaml
# docker-compose.prod.yml (SKUTEČNÝ SOUBOR)
version: '3.9'

services:
  # API - Django + Gunicorn
  posthub_api_prod:
    image: posthub/api:latest
    container_name: posthub_api_prod
    command: gunicorn --bind 0.0.0.0:8000 --workers 4 config.wsgi:application
    env_file: .env.production
    depends_on:
      - posthub_postgres_prod
      - posthub_redis_prod
    networks:
      - posthub_network

  # Frontend - Angular + Nginx
  posthub_frontend_prod:
    image: posthub/frontend:latest
    container_name: posthub_frontend_prod
    networks:
      - posthub_network

  # PostgreSQL 16 + pgvector
  posthub_postgres_prod:
    image: pgvector/pgvector:pg16
    container_name: posthub_postgres_prod
    env_file: .env.production
    volumes:
      - postgres_prod_data:/var/lib/postgresql/data
    networks:
      - posthub_network

  # Redis
  posthub_redis_prod:
    image: redis:latest
    container_name: posthub_redis_prod
    command: redis-server --appendonly yes
    volumes:
      - redis_prod_data:/data
    networks:
      - posthub_network

  # Celery Worker - Default Queues
  posthub_celery_worker:
    image: posthub/api:latest
    container_name: posthub_celery_worker
    command: celery -A config worker -l INFO -Q default,quick,scheduled --concurrency=4
    env_file: .env.production
    depends_on:
      - posthub_postgres_prod
      - posthub_redis_prod
    networks:
      - posthub_network

  # Celery Worker - AI Dedicated
  posthub_celery_worker_ai:
    image: posthub/api:latest
    container_name: posthub_celery_worker_ai
    command: celery -A config worker -l INFO -Q ai_jobs,ai_priority --concurrency=2
    env_file: .env.production
    depends_on:
      - posthub_postgres_prod
      - posthub_redis_prod
    networks:
      - posthub_network

  # Celery Beat
  posthub_celery_beat:
    image: posthub/api:latest
    container_name: posthub_celery_beat
    command: celery -A config beat -l INFO --scheduler django_celery_beat.schedulers:DatabaseScheduler
    env_file: .env.production
    depends_on:
      - posthub_postgres_prod
      - posthub_redis_prod
    networks:
      - posthub_network

  # Flower - Monitoring
  posthub_flower:
    image: posthub/api:latest
    container_name: posthub_flower
    command: celery -A config flower --port=5555
    env_file: .env.production
    ports:
      - "5555:5555"
    depends_on:
      - posthub_redis_prod
    networks:
      - posthub_network

  # Caddy - Reverse Proxy + HTTPS
  posthub_caddy:
    image: caddy:latest
    container_name: posthub_caddy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    depends_on:
      - posthub_api_prod
      - posthub_frontend_prod
    networks:
      - posthub_network

volumes:
  postgres_prod_data:
  redis_prod_data:
  caddy_data:
  caddy_config:

networks:
  posthub_network:
    driver: bridge
```

---

### 7.3 Skutečná Resource Alokace

| Service | Instances | CPU/Memory | Notes |
|---------|-----------|------------|-------|
| **API (Django)** | 1 | 4 workers | Žádné autoscaling |
| **Celery Worker (default)** | 1 | concurrency=4 | Queues: default, quick, scheduled |
| **Celery Worker (AI)** | 1 | concurrency=2 | Queues: ai_jobs, ai_priority |
| **Celery Beat** | 1 | - | DatabaseScheduler |
| **Redis** | 1 | - | Single instance (ne cluster) |
| **PostgreSQL** | 1 | - | Single instance (ne replica) |
| **Flower** | 1 | Port 5555 | Jediný monitoring |
| **Caddy** | 1 | - | Automatic HTTPS |
| **Frontend** | 1 | - | Static Nginx |

---

### 7.4 Kritické Rozdíly: Plán vs Realita

#### 🔴 DEPLOYMENT MODEL

| Oblast | Dokument (Plán) | Realita |
|--------|-----------------|---------|
| **Platforma** | Kubernetes Cluster | **VPS + Docker-Compose** |
| **Server** | K8s nodes (nespecifikováno) | **72.62.92.89** |
| **Orchestrace** | K8s Deployments, Services, HPA | **docker-compose.prod.yml** |
| **Autoscaling** | HPA (2-10 replicas) | **ŽÁDNÉ - statické kontejnery** |
| **Load Balancing** | K8s Ingress (nginx) | **Caddy reverse proxy** |
| **TLS** | cert-manager + Let's Encrypt | **Caddy automatic HTTPS** |

#### 🟡 CELERY QUEUES

| Dokument (Plán) | Realita | Status |
|-----------------|---------|--------|
| `default` | ✅ `default` | ✅ OK |
| `high_priority` | ❌ **`quick`** | ⚠️ JINÝ NÁZEV |
| `low_priority` | ❌ **`scheduled`** | ⚠️ JINÝ NÁZEV |
| - | ✅ **`ai_jobs`** | ➕ NOVÁ FRONTA |
| - | ✅ **`ai_priority`** | ➕ NOVÁ FRONTA |

**Skutečná konfigurace:**
- **Worker 1:** `-Q default,quick,scheduled --concurrency=4`
- **Worker 2:** `-Q ai_jobs,ai_priority --concurrency=2` (dedicated AI worker)

#### 🟢 CO PLATÍ (Development)

| Oblast | Dokument | Realita | Status |
|--------|----------|---------|--------|
| Docker Compose pro dev | ✅ | ✅ | ✅ OK |
| pgvector/pgvector:pg16 | ✅ | ✅ | ✅ OK |
| redis:7-alpine | ✅ | redis:latest | ⚠️ Minor |
| Celery Worker | ✅ | ✅ | ✅ OK |
| Celery Beat | ✅ | ✅ | ✅ OK |
| Flower Port 5555 | ✅ | ✅ | ✅ OK |

#### 🔴 CO NEPLATÍ (Production)

| Oblast | Dokument | Realita | Status |
|--------|----------|---------|--------|
| **Kubernetes** | ✅ Veškeré K8s YAML | ❌ NEPOUŽÍVÁ SE | ❌ NEPLATÍ |
| K8s Namespace `posthub` | ✅ | ❌ | ❌ NEPLATÍ |
| K8s ConfigMap | ✅ | ❌ `.env.production` soubor | ❌ NEPLATÍ |
| K8s Secrets | ✅ | ❌ `.env.production` soubor | ❌ NEPLATÍ |
| K8s Deployments | ✅ | ❌ docker-compose services | ❌ NEPLATÍ |
| K8s Services | ✅ | ❌ Docker networks | ❌ NEPLATÍ |
| K8s HPA autoscaling | ✅ | ❌ NEEXISTUJE | ❌ NEPLATÍ |
| K8s Ingress | ✅ | ❌ Caddy | ❌ NEPLATÍ |
| **Monitoring** | | | |
| Prometheus | ✅ `django-prometheus` | ❌ NEINSTALOVÁNO | ❌ NEPLATÍ |
| Grafana | ✅ | ❌ NEEXISTUJE | ❌ NEPLATÍ |
| ServiceMonitor | ✅ | ❌ | ❌ NEPLATÍ |
| PrometheusRule alerts | ✅ | ❌ | ❌ NEPLATÍ |
| **Databáze** | | | |
| PostgreSQL Replica | ✅ 1+1 | ❌ Pouze 1 instance | ❌ NEPLATÍ |
| Redis Cluster | ✅ 3 nodes | ❌ Pouze 1 instance | ❌ NEPLATÍ |
| **Backup** | | | |
| S3 backups | ✅ | ❌ Nevím | ❌ NEPLATÍ |
| K8s CronJob | ✅ | ❌ | ❌ NEPLATÍ |

---

### 7.5 Současný Monitoring Setup

#### ✅ CO FUNGUJE

**Flower Dashboard**
- URL: `http://72.62.92.89:5555`
- Zobrazuje:
  - Active tasks
  - Task history
  - Worker status
  - Queue lengths
  - Task success/failure rates

#### ❌ CO CHYBÍ

- **Prometheus** - není nainstalován
- **Grafana** - neexistuje
- **django-prometheus** - není v requirements
- **Alerting** - žádné automatické alerty
- **Metrics export** - žádné /metrics endpoint
- **Log aggregation** - standardní Docker logs pouze

---

### 7.6 Současný CI/CD Setup

**Status:** ❓ Neznámý / Pravděpodobně manuální deployment

**Co víme:**
- GitHub Actions workflow v dokumentu popisuje K8s deployment
- Skutečný deployment proces není zdokumentován
- Pravděpodobně manuální pull + docker-compose restart

**Co by mělo být (ale není ověřeno):**
```bash
# Pravděpodobný deployment proces:
ssh user@72.62.92.89
cd /path/to/posthub
git pull origin main
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

---

### 7.7 Současný Backup Setup

**Status:** ❓ Neznámý

**Co víme:**
- K8s CronJob v dokumentu neplatí
- Není známo, zda existuje jakýkoli backup mechanismus
- PostgreSQL data jsou v Docker volume `postgres_prod_data`
- Redis data jsou v Docker volume `redis_prod_data`

**Co by mělo existovat (ale není ověřeno):**
- Pravidelné PostgreSQL pg_dump
- Upload na S3 nebo jiné úložiště
- Retention policy
- Tested restore procedure

---

### 7.8 Caddyfile Configuration

**Aktuální reverse proxy + HTTPS setup:**

```caddy
# Caddyfile
posthub.work {
    reverse_proxy posthub_frontend_prod:80
}

api.posthub.work {
    reverse_proxy posthub_api_prod:8000
}
```

**Features:**
- ✅ Automatic HTTPS (Let's Encrypt)
- ✅ Automatic certificate renewal
- ✅ HTTP → HTTPS redirect
- ✅ HTTP/2 support
- ❌ Rate limiting (není konfigurováno)
- ❌ Advanced caching (není konfigurováno)

---

### 7.9 Environment Variables (.env.production)

**Skutečná konfigurace:**

```bash
# .env.production (SKUTEČNÝ SOUBOR)

# Django
DJANGO_SETTINGS_MODULE=config.settings.production
SECRET_KEY=<production-secret>
DEBUG=False
ALLOWED_HOSTS=api.posthub.work,posthub.work

# Database
DATABASE_URL=postgres://posthub:password@posthub_postgres_prod:5432/posthub

# Redis & Celery
REDIS_URL=redis://posthub_redis_prod:6379/0
CELERY_BROKER_URL=redis://posthub_redis_prod:6379/0

# CORS
CORS_ALLOWED_ORIGINS=https://posthub.work

# External APIs
GEMINI_API_KEY=<key>
PERPLEXITY_API_KEY=<key>
NANOBANA_API_KEY=<key>
STRIPE_SECRET_KEY=<key>
```

**Rozdíly vs K8s ConfigMap/Secrets:**
- ❌ Žádná ConfigMap - vše v `.env.production`
- ❌ Žádné K8s Secrets
- ⚠️ Secrets jsou commitnuté v repu nebo na serveru ručně

---

### 7.10 Migration Path: VPS → Kubernetes

**Když nadejde čas migrovat na K8s:**

#### Fáze 1: Příprava
1. ✅ K8s YAML soubory už jsou připraveny (sekce 3)
2. ⚠️ Aktualizovat queue names v K8s manifests
3. ⚠️ Nastavit skutečné resource limits (ne defaultní)
4. ⚠️ Přidat AI worker deployment

#### Fáze 2: Database Migration
1. Backup současné PostgreSQL DB
2. Restore do K8s PostgreSQL pod
3. Verify data integrity
4. Setup PostgreSQL replica

#### Fáze 3: Cutover
1. Update DNS: api.posthub.work → K8s Ingress IP
2. Monitor Flower + Prometheus
3. Rollback plan ready

#### Fáze 4: Post-Migration
1. Decommission VPS
2. Setup S3 backups
3. Configure Grafana dashboards
4. Setup PagerDuty alerts

---

### 7.11 Known Issues & Technical Debt

#### 🔴 Critical
- **No autoscaling** - statické repliky
- **No database replica** - single point of failure
- **No automated backups** - data loss risk
- **No Prometheus/Grafana** - limited observability

#### 🟡 Medium
- **Queue names mismatch** - documentation vs reality
- **No CI/CD automation** - manual deployment
- **No Redis cluster** - single point of failure
- **No rate limiting** - DDoS vulnerability

#### 🟢 Low
- **Redis version mismatch** - redis:latest vs redis:7-alpine
- **No structured logging** - standard Docker logs
- **No APM** - no Sentry/DataDog integration

---

### 7.12 Quick Commands - Produkční Server

**SSH Access:**
```bash
ssh user@72.62.92.89
```

**Service Management:**
```bash
# Restart všech služeb
docker-compose -f docker-compose.prod.yml restart

# Restart pouze API
docker-compose -f docker-compose.prod.yml restart posthub_api_prod

# Logs
docker-compose -f docker-compose.prod.yml logs -f posthub_api_prod
docker-compose -f docker-compose.prod.yml logs -f posthub_celery_worker
docker-compose -f docker-compose.prod.yml logs -f posthub_celery_worker_ai

# Shell access
docker exec -it posthub_api_prod python manage.py shell
docker exec -it posthub_postgres_prod psql -U posthub

# Database backup (manual)
docker exec posthub_postgres_prod pg_dump -U posthub posthub > backup_$(date +%Y%m%d).sql
```

**Monitoring:**
```bash
# Flower dashboard
http://72.62.92.89:5555

# Container stats
docker stats

# Disk usage
docker system df
```

**Health Checks:**
```bash
# API health
curl https://api.posthub.work/health/

# Redis
docker exec posthub_redis_prod redis-cli ping

# PostgreSQL
docker exec posthub_postgres_prod pg_isready -U posthub

# Celery workers
docker exec posthub_api_prod celery -A config inspect active
```

---

### 7.13 Porovnání: Plánovaná vs Současná Architektura

| Aspekt | Plánovaná (K8s) | Současná (VPS) | Priorita Migrace |
|--------|-----------------|----------------|------------------|
| **Deployment** | Kubernetes | Docker Compose | 🔴 High |
| **Autoscaling** | HPA 2-10 replicas | Statické | 🔴 High |
| **Load Balancing** | K8s Ingress | Caddy | 🟡 Medium |
| **Database HA** | Primary + Replica | Single instance | 🔴 High |
| **Redis HA** | 3-node cluster | Single instance | 🟡 Medium |
| **Monitoring** | Prometheus + Grafana | Pouze Flower | 🔴 High |
| **Backups** | Automated S3 | Manual/Unknown | 🔴 High |
| **CI/CD** | GitHub Actions → K8s | Manual | 🟡 Medium |
| **Secrets** | K8s Secrets | .env file | 🟡 Medium |
| **TLS** | cert-manager | Caddy auto | 🟢 Low (funguje) |

**Celková shoda dokumentace s realitou: ~15-20%**

---

### 7.14 Action Items

#### Immediate (týdny)
- [ ] Zdokumentovat skutečný CI/CD proces
- [ ] Implementovat automated backups
- [ ] Setup Prometheus + basic metrics
- [ ] Verify .env.production není v Git

#### Short-term (měsíce)
- [ ] Setup Grafana dashboards
- [ ] Implement basic alerting
- [ ] Setup Redis persistence verification
- [ ] Document restore procedures

#### Long-term (6+ měsíců)
- [ ] Migrace na Kubernetes
- [ ] Setup database replica
- [ ] Implement Redis cluster
- [ ] Full CI/CD automation

---

**📊 ZÁVĚR:**

Dokument 08_INFRASTRUCTURE.md popisuje **PLÁNOVANOU** produkční architekturu s Kubernetes.  
**Skutečná produkce běží** na jednoduchém VPS s docker-compose.  

**Sekce 1-6** = Cílový stav / Roadmap  
**Sekce 7** = Současný stav / Reality check

---

## 📌 QUICK REFERENCE

### Development Commands

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f api
docker-compose logs -f celery_worker

# Rebuild
docker-compose build --no-cache

# Shell access
docker-compose exec api python manage.py shell
docker-compose exec db psql -U posthub

# Run migrations
docker-compose exec api python manage.py migrate
```

### Kubernetes Commands

```bash
# Deploy
kubectl apply -f k8s/ -n posthub

# Check status
kubectl get pods -n posthub
kubectl get hpa -n posthub

# Logs
kubectl logs -f deployment/posthub-api -n posthub
kubectl logs -f deployment/posthub-celery-worker -n posthub

# Scale
kubectl scale deployment posthub-api --replicas=5 -n posthub

# Rollback
kubectl rollout undo deployment/posthub-api -n posthub
```

---

*Tento dokument je SELF-CONTAINED.*

# 03_ASYNC_CELERY_REDIS.md - Kompletní Asynchronní Zpracování

**Dokument:** Celery & Redis pro PostHub.work  
**Verze:** 1.0.0  
**Status:** Production-Ready  
**Self-Contained:** ✅ Tento dokument obsahuje VŠECHNY informace o async zpracování

---

## 📋 OBSAH

1. [Přehled](#1-přehled)
2. [Celery Configuration](#2-celery-configuration)
3. [Queue Architecture](#3-queue-architecture)
4. [Task Patterns](#4-task-patterns)
5. [Long-Running AI Tasks](#5-long-running-ai-tasks)
6. [State Management](#6-state-management)
7. [Retry & Error Handling](#7-retry--error-handling)
8. [Celery Beat Scheduling](#8-celery-beat-scheduling)
9. [Monitoring](#9-monitoring)
10. [Redis Caching](#10-redis-caching)
11. [Production Deployment](#11-production-deployment)
12. [Troubleshooting](#12-troubleshooting)

---

## 1. PŘEHLED

### Proč Celery + Redis?

PostHub.work potřebuje asynchronní zpracování pro:

1. **AI Generování** - Trvá 30-120 sekund (text, obrázky, video)
2. **Web Scraping** - Perplexity API volání
3. **Email Notifikace** - Nečekat na SMTP
4. **Scheduled Tasks** - Měsíční generování obsahu
5. **Background Jobs** - Export, analytics, cleanup

### Architektura

```
┌─────────────────────────────────────────────────────────────────────┐
│                         ASYNC ARCHITECTURE                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐           │
│  │   Django    │     │    Redis    │     │   Celery    │           │
│  │   API       │────►│   Broker    │────►│   Workers   │           │
│  └─────────────┘     └─────────────┘     └─────────────┘           │
│         │                   │                   │                   │
│         │                   │                   │                   │
│         ▼                   ▼                   ▼                   │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐           │
│  │  Create     │     │   Cache     │     │   Execute   │           │
│  │  Job        │     │   Results   │     │   Task      │           │
│  └─────────────┘     └─────────────┘     └─────────────┘           │
│                                                                      │
│  QUEUES:                                                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐  │
│  │   default   │ │    quick    │ │   ai_jobs   │ │  scheduled  │  │
│  │  General    │ │   <5 sec    │ │  30-120 sec │ │   Cron      │  │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. CELERY CONFIGURATION

### Základní konfigurace

```python
# config/celery.py
import os
from celery import Celery
from celery.signals import setup_logging

# Nastav Django settings
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.dev')

# Vytvoř Celery aplikaci
app = Celery('posthub')

# Načti konfiguraci z Django settings (prefix CELERY_)
app.config_from_object('django.conf:settings', namespace='CELERY')

# Auto-discover tasks ve všech Django apps
app.autodiscover_tasks()


@setup_logging.connect
def config_loggers(*args, **kwargs):
    """Použij Django logging pro Celery."""
    from logging.config import dictConfig
    from django.conf import settings
    dictConfig(settings.LOGGING)


@app.task(bind=True, ignore_result=True)
def debug_task(self):
    """Debug task pro testování."""
    print(f'Request: {self.request!r}')
```

### Django Settings

```python
# config/settings/base.py

# =============================================================================
# CELERY CONFIGURATION
# =============================================================================

# Broker (Redis)
CELERY_BROKER_URL = env('REDIS_URL', default='redis://localhost:6379/0')

# Results Backend (Redis)
CELERY_RESULT_BACKEND = env('REDIS_URL', default='redis://localhost:6379/1')

# Serialization
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TIMEZONE = 'UTC'

# Task Execution
CELERY_TASK_TRACK_STARTED = True
CELERY_TASK_TIME_LIMIT = 30 * 60  # 30 minut hard limit
CELERY_TASK_SOFT_TIME_LIMIT = 25 * 60  # 25 minut soft limit
CELERY_RESULT_EXPIRES = 60 * 60 * 24  # 24 hodin

# Worker Configuration
CELERY_WORKER_PREFETCH_MULTIPLIER = 1  # Fair distribution
CELERY_WORKER_MAX_TASKS_PER_CHILD = 1000  # Restart worker po 1000 tasks (memory leaks)
CELERY_WORKER_SEND_TASK_EVENTS = True  # Pro monitoring

# Broker Transport Options (KRITICKÉ pro Redis)
CELERY_BROKER_TRANSPORT_OPTIONS = {
    'visibility_timeout': 7200,  # 2 hodiny - MUSÍ být > než nejdelší task!
    'socket_keepalive': True,
    'health_check_interval': 60,
    'retry_on_timeout': True,
}

# Task Result Options
CELERY_RESULT_BACKEND_TRANSPORT_OPTIONS = {
    'retry_policy': {
        'timeout': 5.0,
    }
}

# Celery Beat (Scheduler)
CELERY_BEAT_SCHEDULER = 'django_celery_beat.schedulers:DatabaseScheduler'

# Task Routes (Queue Assignment)
CELERY_TASK_ROUTES = {
    # Quick tasks (< 5 sekund)
    'apps.*.tasks.send_*': {'queue': 'quick'},
    'apps.*.tasks.notify_*': {'queue': 'quick'},
    'apps.billing.tasks.*': {'queue': 'quick'},
    
    # AI jobs (30-120 sekund)
    'apps.ai_gateway.tasks.*': {'queue': 'ai_jobs'},
    'apps.content.tasks.generate_*': {'queue': 'ai_jobs'},
    'apps.personas.tasks.generate_*': {'queue': 'ai_jobs'},
    'apps.content.tasks.regenerate_*': {'queue': 'ai_jobs'},
    
    # Priority AI jobs (ULTIMATE tier)
    'apps.ai_gateway.tasks.*_priority': {'queue': 'ai_priority'},
    
    # Default
    '*': {'queue': 'default'},
}

# Task Queues Definition
from kombu import Queue

CELERY_TASK_QUEUES = (
    Queue('default', routing_key='default'),
    Queue('quick', routing_key='quick.*'),
    Queue('ai_jobs', routing_key='ai.*'),
    Queue('ai_priority', routing_key='ai.priority.*'),
    Queue('scheduled', routing_key='scheduled.*'),
)

# Default Queue
CELERY_TASK_DEFAULT_QUEUE = 'default'
CELERY_TASK_DEFAULT_ROUTING_KEY = 'default'
```

### Init File

```python
# config/__init__.py
from .celery import app as celery_app

__all__ = ('celery_app',)
```

---

## 3. QUEUE ARCHITECTURE

### Queue Definitions

| Queue | Purpose | Concurrency | Timeout | Prefetch |
|-------|---------|-------------|---------|----------|
| `default` | General tasks | 4 | 5 min | 4 |
| `quick` | Fast tasks (< 5s) | 8 | 30 sec | 8 |
| `ai_jobs` | AI generation | 2 | 5 min | 1 |
| `ai_priority` | Priority AI (ULTIMATE) | 2 | 5 min | 1 |
| `scheduled` | Cron jobs | 2 | 10 min | 1 |

### Worker Commands

```bash
# Development - všechny queues v jednom workeru
celery -A config worker -l INFO -Q default,quick,ai_jobs,scheduled

# Production - oddělené workery
# Quick worker (high concurrency)
celery -A config worker -l INFO -Q quick --concurrency=8 --hostname=quick@%h

# Default worker
celery -A config worker -l INFO -Q default --concurrency=4 --hostname=default@%h

# AI worker (low concurrency, long timeout)
celery -A config worker -l INFO -Q ai_jobs --concurrency=2 --hostname=ai@%h \
    --soft-time-limit=300 --time-limit=360

# Priority AI worker
celery -A config worker -l INFO -Q ai_priority --concurrency=2 --hostname=ai_prio@%h \
    --soft-time-limit=300 --time-limit=360

# Scheduled worker (Celery Beat)
celery -A config beat -l INFO --scheduler django_celery_beat.schedulers:DatabaseScheduler
```

### Prioritization Flow

```
                                   ┌─────────────────────┐
                                   │   Incoming Task     │
                                   └──────────┬──────────┘
                                              │
                              ┌───────────────┼───────────────┐
                              │               │               │
                              ▼               ▼               ▼
                   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
                   │  Quick Task  │ │  AI Task     │ │  Other Task  │
                   │  (email,     │ │  (generate)  │ │  (export,    │
                   │   webhook)   │ │              │ │   cleanup)   │
                   └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
                          │                │                │
                          ▼                ▼                ▼
                   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
                   │    quick     │ │  ai_jobs or  │ │   default    │
                   │    queue     │ │  ai_priority │ │    queue     │
                   └──────────────┘ └──────────────┘ └──────────────┘
                          │                │                │
                          │      ┌─────────┴─────────┐     │
                          │      │                   │     │
                          │      ▼                   ▼     │
                          │ ┌─────────┐       ┌─────────┐ │
                          │ │ULTIMATE │       │ BASIC/  │ │
                          │ │ tier    │       │  PRO    │ │
                          │ └────┬────┘       └────┬────┘ │
                          │      │                 │      │
                          │      ▼                 ▼      │
                          │ ┌─────────┐       ┌─────────┐ │
                          │ │ai_prio  │       │ai_jobs  │ │
                          │ │(first)  │       │(later)  │ │
                          │ └─────────┘       └─────────┘ │
                          │                               │
                          └───────────────────────────────┘
```

---

## 4. TASK PATTERNS

### Basic Task Pattern

```python
# apps/content/tasks.py
from celery import shared_task
import structlog

logger = structlog.get_logger(__name__)


@shared_task
def simple_task(data: dict) -> dict:
    """
    Jednoduchý task bez speciálních požadavků.
    """
    logger.info("simple_task_started", data=data)
    
    result = process_data(data)
    
    logger.info("simple_task_completed", result=result)
    return result
```

### Task with Bind (Access to self)

```python
@shared_task(bind=True)
def task_with_progress(self, items: list) -> dict:
    """
    Task který reportuje progress.
    """
    total = len(items)
    results = []
    
    for i, item in enumerate(items):
        # Update progress
        self.update_state(
            state='PROGRESS',
            meta={
                'current': i + 1,
                'total': total,
                'percent': int((i + 1) / total * 100),
            }
        )
        
        result = process_item(item)
        results.append(result)
    
    return {'results': results, 'total': total}
```

### Task with Retry

```python
@shared_task(
    bind=True,
    autoretry_for=(ConnectionError, TimeoutError),
    retry_backoff=True,
    retry_backoff_max=600,
    retry_jitter=True,
    max_retries=3,
)
def task_with_retry(self, url: str) -> dict:
    """
    Task s automatickým retry při chybách.
    """
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        return {'status': 'success', 'data': response.json()}
    except requests.RequestException as exc:
        logger.warning("task_failed", url=url, error=str(exc), retry=self.request.retries)
        raise
```

### Task with Manual Retry

```python
@shared_task(bind=True, max_retries=3)
def task_with_manual_retry(self, job_id: str):
    """
    Task s manuálním retry a custom logikou.
    """
    try:
        result = call_external_api(job_id)
        return result
    except RateLimitError as exc:
        # Retry za 60 sekund při rate limitu
        raise self.retry(exc=exc, countdown=60)
    except TemporaryError as exc:
        # Exponential backoff
        raise self.retry(exc=exc, countdown=2 ** self.request.retries * 10)
    except PermanentError as exc:
        # Neprovádět retry
        logger.error("permanent_error", job_id=job_id, error=str(exc))
        raise
```

---

## 5. LONG-RUNNING AI TASKS

### AI Task Base Pattern

```python
# apps/ai_gateway/tasks.py
from celery import shared_task
from celery.exceptions import SoftTimeLimitExceeded
from django.db import transaction
import structlog

from apps.ai_gateway.models import GenerationJob
from apps.ai_gateway.services import AIGateway
from apps.core.exceptions import AIServiceError

logger = structlog.get_logger(__name__)


@shared_task(
    bind=True,
    acks_late=True,              # Acknowledge PO dokončení
    reject_on_worker_lost=True,  # Requeue pokud worker spadne
    soft_time_limit=110,         # Soft limit - vyvolá exception
    time_limit=120,              # Hard limit - zabije process
    autoretry_for=(ConnectionError, TimeoutError),
    retry_backoff=True,
    retry_backoff_max=300,
    max_retries=3,
)
def generate_content_task(self, job_id: str) -> dict:
    """
    Hlavní task pro AI generování obsahu.
    
    Lifecycle:
    1. Načti job z DB
    2. Update status na GENERATING
    3. Zavolej AI službu
    4. Ulož výsledek
    5. Update status na COMPLETED/FAILED
    """
    logger.info("generate_content_started", job_id=job_id, task_id=self.request.id)
    
    # 1. Načti job
    try:
        job = GenerationJob.objects.select_related('organization', 'prompt_template').get(id=job_id)
    except GenerationJob.DoesNotExist:
        logger.error("job_not_found", job_id=job_id)
        return {'status': 'error', 'error': 'Job not found'}
    
    # 2. Update status
    job.status = 'generating'
    job.task_id = self.request.id
    job.started_at = timezone.now()
    job.save(update_fields=['status', 'task_id', 'started_at'])
    
    # Report progress
    self.update_state(state='PROGRESS', meta={'step': 'initializing', 'progress': 10})
    
    try:
        # 3. Zavolej AI službu
        ai_gateway = AIGateway()
        
        self.update_state(state='PROGRESS', meta={'step': 'generating', 'progress': 30})
        
        result = ai_gateway.generate(
            prompt_template=job.prompt_template,
            variables=job.input_variables,
            organization=job.organization,
        )
        
        self.update_state(state='PROGRESS', meta={'step': 'processing', 'progress': 80})
        
        # 4. Ulož výsledek
        with transaction.atomic():
            job.result_data = result
            job.status = 'completed'
            job.completed_at = timezone.now()
            job.save()
            
            # Trigger post-processing
            transaction.on_commit(
                lambda: process_generation_result.delay(job.id)
            )
        
        self.update_state(state='PROGRESS', meta={'step': 'completed', 'progress': 100})
        
        logger.info("generate_content_completed", job_id=job_id)
        return {'status': 'completed', 'job_id': job_id}
        
    except SoftTimeLimitExceeded:
        # Soft timeout - máme čas na cleanup
        logger.warning("generate_content_timeout", job_id=job_id)
        job.status = 'timeout'
        job.error_message = 'Generation timed out'
        job.save(update_fields=['status', 'error_message'])
        return {'status': 'timeout', 'job_id': job_id}
        
    except AIServiceError as exc:
        # AI služba selhala
        logger.error("ai_service_error", job_id=job_id, error=str(exc))
        job.status = 'failed'
        job.error_message = str(exc)
        job.save(update_fields=['status', 'error_message'])
        raise  # Trigger retry
        
    except Exception as exc:
        # Neočekávaná chyba
        logger.exception("generate_content_error", job_id=job_id)
        job.status = 'failed'
        job.error_message = str(exc)
        job.save(update_fields=['status', 'error_message'])
        raise
```

### Chained Tasks Pattern

```python
from celery import chain, group, chord

def generate_monthly_content(organization_id: str, year: int, month: int):
    """
    Orchestruje generování obsahu na celý měsíc.
    """
    # 1. Vygeneruj témata
    # 2. Po schválení vygeneruj blogposty paralelně
    # 3. Po dokončení všech vygeneruj social posty
    
    workflow = chain(
        # Step 1: Generate topics
        generate_topics_task.s(organization_id, year, month),
        
        # Step 2: Wait for approval (manual step, triggered separately)
        
        # Step 3: Generate blogposts in parallel (after approval)
        # This would be triggered by topic_approve service
    )
    
    return workflow.apply_async()


def generate_all_blogposts_for_calendar(calendar_id: str):
    """
    Generuje všechny blogposty pro kalendář paralelně.
    """
    calendar = ContentCalendar.objects.get(id=calendar_id)
    approved_topics = calendar.topics.filter(status='approved')
    
    # Group - paralelní execution
    job = group(
        generate_blogpost_task.s(topic.id) 
        for topic in approved_topics
    )
    
    # Chord - po dokončení všech spusť finalizaci
    workflow = chord(job)(finalize_calendar_task.s(calendar_id))
    
    return workflow


@shared_task
def finalize_calendar_task(results: list, calendar_id: str):
    """
    Finalizuje kalendář po dokončení všech blogpostů.
    """
    calendar = ContentCalendar.objects.get(id=calendar_id)
    
    successful = sum(1 for r in results if r.get('status') == 'completed')
    failed = sum(1 for r in results if r.get('status') == 'failed')
    
    calendar.blogposts_completed = successful
    calendar.blogposts_failed = failed
    calendar.status = 'completed' if failed == 0 else 'partial'
    calendar.save()
    
    # Notifikuj uživatele
    notify_calendar_completed.delay(calendar_id, successful, failed)
    
    return {'calendar_id': calendar_id, 'successful': successful, 'failed': failed}
```

### Priority Queue Selection

```python
# apps/content/services.py
from django.db import transaction


def schedule_content_generation(job: GenerationJob) -> str:
    """
    Naplánuje generování obsahu do správné fronty podle subscription tier.
    """
    # Vyber frontu podle tier
    if job.organization.subscription_tier == 'ULTIMATE':
        queue = 'ai_priority'
    else:
        queue = 'ai_jobs'
    
    # Spusť task po uložení do DB
    transaction.on_commit(
        lambda: generate_content_task.apply_async(
            args=[str(job.id)],
            queue=queue,
        )
    )
    
    return queue
```

---

## 6. STATE MANAGEMENT

### Job Status Model

```python
# apps/ai_gateway/models.py
from django.db import models
from apps.core.models import TenantBaseModel


class GenerationJob(TenantBaseModel):
    """
    Model pro sledování AI generation jobů.
    """
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('queued', 'Queued'),
        ('generating', 'Generating'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
        ('timeout', 'Timeout'),
        ('cancelled', 'Cancelled'),
    ]
    
    JOB_TYPE_CHOICES = [
        ('personas', 'Persona Generation'),
        ('topics', 'Topic Generation'),
        ('blogpost', 'Blogpost Generation'),
        ('social_post', 'Social Post Generation'),
        ('image', 'Image Generation'),
        ('video', 'Video Generation'),
    ]
    
    # Type & Status
    job_type = models.CharField(max_length=50, choices=JOB_TYPE_CHOICES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    
    # Celery tracking
    task_id = models.CharField(max_length=255, null=True, blank=True)
    
    # Input
    prompt_template = models.ForeignKey(
        'PromptTemplate',
        on_delete=models.SET_NULL,
        null=True
    )
    input_variables = models.JSONField(default=dict)
    
    # Output
    result_data = models.JSONField(null=True, blank=True)
    raw_response = models.TextField(null=True, blank=True)
    
    # Timing
    queued_at = models.DateTimeField(null=True, blank=True)
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    # Metrics
    input_tokens = models.IntegerField(null=True, blank=True)
    output_tokens = models.IntegerField(null=True, blank=True)
    estimated_cost = models.DecimalField(max_digits=10, decimal_places=6, null=True)
    
    # Error tracking
    error_message = models.TextField(null=True, blank=True)
    retry_count = models.IntegerField(default=0)
    max_retries = models.IntegerField(default=3)
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['organization', 'status']),
            models.Index(fields=['task_id']),
            models.Index(fields=['created_at']),
        ]
```

### Status API Endpoint

```python
# apps/ai_gateway/apis.py
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from django.http import StreamingHttpResponse
from celery.result import AsyncResult


class GenerationJobViewSet(viewsets.ModelViewSet):
    """
    API pro správu generation jobů.
    """
    
    @action(detail=True, methods=['get'])
    def status(self, request, pk=None):
        """
        Získá aktuální status jobu včetně progress.
        """
        job = self.get_object()
        
        response_data = {
            'id': str(job.id),
            'status': job.status,
            'job_type': job.job_type,
            'created_at': job.created_at.isoformat(),
        }
        
        # Pokud job běží, získej progress z Celery
        if job.status == 'generating' and job.task_id:
            result = AsyncResult(job.task_id)
            
            if result.state == 'PROGRESS':
                response_data['progress'] = result.info
            elif result.state == 'SUCCESS':
                response_data['status'] = 'completed'
            elif result.state == 'FAILURE':
                response_data['status'] = 'failed'
                response_data['error'] = str(result.result)
        
        if job.completed_at:
            response_data['completed_at'] = job.completed_at.isoformat()
            response_data['duration_seconds'] = (
                job.completed_at - job.started_at
            ).total_seconds()
        
        return Response(response_data)
    
    @action(detail=True, methods=['get'])
    def status_stream(self, request, pk=None):
        """
        SSE endpoint pro real-time status updates.
        """
        job = self.get_object()
        
        def event_stream():
            import time
            
            while True:
                job.refresh_from_db()
                
                data = {
                    'status': job.status,
                    'progress': None,
                }
                
                if job.task_id:
                    result = AsyncResult(job.task_id)
                    if result.state == 'PROGRESS':
                        data['progress'] = result.info
                
                yield f"data: {json.dumps(data)}\n\n"
                
                if job.status in ['completed', 'failed', 'timeout', 'cancelled']:
                    break
                
                time.sleep(2)  # Poll interval
        
        response = StreamingHttpResponse(
            event_stream(),
            content_type='text/event-stream'
        )
        response['Cache-Control'] = 'no-cache'
        response['X-Accel-Buffering'] = 'no'
        return response
    
    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        """
        Zruší běžící job.
        """
        job = self.get_object()
        
        if job.status not in ['pending', 'queued', 'generating']:
            return Response(
                {'error': 'Cannot cancel job with status: ' + job.status},
                status=400
            )
        
        # Revoke Celery task
        if job.task_id:
            from config.celery import app
            app.control.revoke(job.task_id, terminate=True)
        
        job.status = 'cancelled'
        job.save(update_fields=['status'])
        
        return Response({'status': 'cancelled'})
```

---

## 7. RETRY & ERROR HANDLING

### Retry Strategies

```python
# apps/ai_gateway/tasks.py

# Strategy 1: Automatic Retry with Exponential Backoff
@shared_task(
    bind=True,
    autoretry_for=(ConnectionError, TimeoutError, RateLimitError),
    retry_backoff=True,        # Exponential backoff
    retry_backoff_max=600,     # Max 10 minut mezi pokusy
    retry_jitter=True,         # Náhodný offset (prevence thundering herd)
    max_retries=5,
)
def task_with_auto_retry(self, data):
    ...


# Strategy 2: Custom Retry Logic
@shared_task(bind=True, max_retries=5)
def task_with_custom_retry(self, job_id: str):
    try:
        result = call_ai_api(job_id)
        return result
    except RateLimitError as exc:
        # Rate limit - čekej déle
        countdown = 60 * (self.request.retries + 1)  # 60s, 120s, 180s...
        raise self.retry(exc=exc, countdown=countdown)
    except QuotaExceededError as exc:
        # Quota exceeded - neprovádět retry
        logger.error("quota_exceeded", job_id=job_id)
        mark_job_failed(job_id, "API quota exceeded")
        return {'status': 'failed', 'reason': 'quota_exceeded'}
    except TemporaryError as exc:
        # Temporary error - exponential backoff
        countdown = min(2 ** self.request.retries * 10, 600)
        raise self.retry(exc=exc, countdown=countdown)


# Strategy 3: Dead Letter Queue (DLQ)
@shared_task(
    bind=True,
    max_retries=3,
    on_failure=handle_task_failure,
)
def task_with_dlq(self, data):
    ...


def handle_task_failure(self, exc, task_id, args, kwargs, einfo):
    """
    Handler volaný po vyčerpání všech retry pokusů.
    """
    logger.error(
        "task_permanently_failed",
        task_id=task_id,
        args=args,
        error=str(exc),
    )
    
    # Ulož do DLQ tabulky pro manuální review
    FailedTask.objects.create(
        task_id=task_id,
        task_name=self.name,
        args=json.dumps(args),
        kwargs=json.dumps(kwargs),
        exception=str(exc),
        traceback=str(einfo),
    )
    
    # Notifikuj admina
    notify_admin_task_failed.delay(task_id, str(exc))
```

### Error Classification

```python
# apps/ai_gateway/exceptions.py

class AIError(Exception):
    """Base class pro AI chyby."""
    pass


class RetryableAIError(AIError):
    """Chyby které lze řešit retry."""
    pass


class NonRetryableAIError(AIError):
    """Chyby které nelze řešit retry."""
    pass


class RateLimitError(RetryableAIError):
    """AI provider rate limit."""
    pass


class TemporaryError(RetryableAIError):
    """Dočasná chyba (server overload, etc.)."""
    pass


class QuotaExceededError(NonRetryableAIError):
    """Překročena kvóta."""
    pass


class InvalidPromptError(NonRetryableAIError):
    """Nevalidní prompt."""
    pass


class ContentPolicyError(NonRetryableAIError):
    """Obsah porušuje content policy."""
    pass
```

---

## 8. CELERY BEAT SCHEDULING

### Periodic Tasks Setup

```python
# apps/content/tasks.py
from celery import shared_task
from celery.schedules import crontab


@shared_task
def generate_monthly_topics():
    """
    Generuje témata pro další měsíc.
    Spouští se 7 dní před koncem měsíce.
    """
    from datetime import date
    from dateutil.relativedelta import relativedelta
    
    today = date.today()
    next_month = today + relativedelta(months=1)
    
    # Najdi organizace s aktivní subscription
    organizations = Organization.objects.filter(
        subscription__status='active'
    ).select_related('subscription')
    
    for org in organizations:
        # Vytvoř job pro každou organizaci
        job = GenerationJob.objects.create(
            organization=org,
            job_type='topics',
            input_variables={
                'year': next_month.year,
                'month': next_month.month,
            }
        )
        generate_topics_task.delay(str(job.id))
    
    return {'organizations_processed': len(organizations)}


@shared_task
def cleanup_old_jobs():
    """
    Maže staré completed/failed joby.
    """
    from datetime import timedelta
    
    cutoff = timezone.now() - timedelta(days=30)
    
    deleted, _ = GenerationJob.objects.filter(
        status__in=['completed', 'failed', 'cancelled'],
        created_at__lt=cutoff,
    ).delete()
    
    return {'deleted_jobs': deleted}


@shared_task
def aggregate_daily_analytics():
    """
    Agreguje denní analytics.
    """
    from datetime import date, timedelta
    
    yesterday = date.today() - timedelta(days=1)
    
    # Agregace pro každou organizaci
    for org in Organization.objects.filter(subscription__status='active'):
        aggregate_org_analytics(org.id, yesterday)
    
    return {'date': str(yesterday)}
```

### Beat Schedule Configuration

```python
# config/settings/base.py

CELERY_BEAT_SCHEDULE = {
    # Generování témat - 7 dní před koncem měsíce v 9:00 UTC
    'generate-monthly-topics': {
        'task': 'apps.content.tasks.generate_monthly_topics',
        'schedule': crontab(
            day_of_month='24-28',  # Pokryje měsíce s 28-31 dny
            hour=9,
            minute=0,
        ),
    },
    
    # Cleanup starých jobů - každý den v 3:00 UTC
    'cleanup-old-jobs': {
        'task': 'apps.ai_gateway.tasks.cleanup_old_jobs',
        'schedule': crontab(hour=3, minute=0),
    },
    
    # Agregace analytics - každý den v 1:00 UTC
    'aggregate-daily-analytics': {
        'task': 'apps.analytics.tasks.aggregate_daily_analytics',
        'schedule': crontab(hour=1, minute=0),
    },
    
    # Health check - každých 5 minut
    'celery-health-check': {
        'task': 'apps.core.tasks.celery_health_check',
        'schedule': crontab(minute='*/5'),
    },
    
    # Stripe sync - každou hodinu
    'sync-stripe-subscriptions': {
        'task': 'apps.billing.tasks.sync_stripe_subscriptions',
        'schedule': crontab(minute=0),
    },
}
```

### Dynamic Scheduling (Django Admin)

```python
# apps/content/admin.py
from django_celery_beat.models import PeriodicTask, CrontabSchedule


def create_custom_schedule(organization, day, hour):
    """
    Vytvoří custom schedule pro organizaci.
    """
    schedule, _ = CrontabSchedule.objects.get_or_create(
        day_of_month=day,
        hour=hour,
        minute=0,
    )
    
    PeriodicTask.objects.update_or_create(
        name=f'org-{organization.id}-monthly-generation',
        defaults={
            'crontab': schedule,
            'task': 'apps.content.tasks.generate_org_monthly_content',
            'args': json.dumps([str(organization.id)]),
            'enabled': True,
        }
    )
```

---

## 9. MONITORING

### Flower Dashboard

```bash
# Spuštění Flower
celery -A config flower --port=5555

# S autentizací
celery -A config flower --port=5555 --basic_auth=admin:password
```

### Prometheus Metrics

```python
# apps/core/tasks.py
from prometheus_client import Counter, Histogram, Gauge

# Metriky
TASK_COUNTER = Counter(
    'celery_tasks_total',
    'Total Celery tasks',
    ['task_name', 'status']
)

TASK_DURATION = Histogram(
    'celery_task_duration_seconds',
    'Task duration in seconds',
    ['task_name'],
    buckets=[1, 5, 10, 30, 60, 120, 300, 600]
)

QUEUE_LENGTH = Gauge(
    'celery_queue_length',
    'Number of tasks in queue',
    ['queue_name']
)


# Task signals
from celery.signals import task_prerun, task_postrun, task_failure

@task_prerun.connect
def task_prerun_handler(task_id, task, *args, **kwargs):
    """Před spuštěním tasku."""
    task.start_time = time.time()


@task_postrun.connect
def task_postrun_handler(task_id, task, *args, retval=None, state=None, **kwargs):
    """Po dokončení tasku."""
    duration = time.time() - getattr(task, 'start_time', time.time())
    
    TASK_COUNTER.labels(task_name=task.name, status='success').inc()
    TASK_DURATION.labels(task_name=task.name).observe(duration)


@task_failure.connect
def task_failure_handler(task_id, exception, *args, **kwargs):
    """Při selhání tasku."""
    TASK_COUNTER.labels(task_name=kwargs.get('sender').name, status='failure').inc()


# Periodic task pro queue metrics
@shared_task
def update_queue_metrics():
    """Aktualizuje metriky délek front."""
    from config.celery import app
    
    inspect = app.control.inspect()
    
    for queue_name in ['default', 'quick', 'ai_jobs', 'ai_priority']:
        # Toto je zjednodušené - v produkci použij redis-cli
        length = get_queue_length(queue_name)
        QUEUE_LENGTH.labels(queue_name=queue_name).set(length)
```

### Sentry Integration

```python
# config/settings/prod.py
import sentry_sdk
from sentry_sdk.integrations.celery import CeleryIntegration

sentry_sdk.init(
    dsn=env('SENTRY_DSN'),
    integrations=[
        CeleryIntegration(
            monitor_beat_tasks=True,
            propagate_traces=True,
        ),
    ],
    traces_sample_rate=0.1,
    environment='production',
)
```

---

## 10. REDIS CACHING

### Cache Configuration

```python
# config/settings/base.py

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': env('REDIS_URL', default='redis://localhost:6379/2'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            'SOCKET_CONNECT_TIMEOUT': 5,
            'SOCKET_TIMEOUT': 5,
            'RETRY_ON_TIMEOUT': True,
            'CONNECTION_POOL_KWARGS': {
                'max_connections': 50,
            },
        },
        'KEY_PREFIX': 'posthub',
    },
    'sessions': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': env('REDIS_URL', default='redis://localhost:6379/3'),
        'KEY_PREFIX': 'session',
    }
}

# Session backend
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
SESSION_CACHE_ALIAS = 'sessions'
```

### Cache Patterns

```python
# apps/core/cache.py
from django.core.cache import cache
from functools import wraps
import hashlib
import json


def cache_result(timeout=300, key_prefix=''):
    """
    Decorator pro cachování výsledků funkce.
    """
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Vytvoř cache key
            key_parts = [key_prefix, func.__name__]
            key_parts.extend(str(arg) for arg in args)
            key_parts.extend(f"{k}:{v}" for k, v in sorted(kwargs.items()))
            
            cache_key = hashlib.md5(
                ':'.join(key_parts).encode()
            ).hexdigest()
            
            # Zkus načíst z cache
            result = cache.get(cache_key)
            if result is not None:
                return result
            
            # Spočítej a ulož
            result = func(*args, **kwargs)
            cache.set(cache_key, result, timeout)
            
            return result
        return wrapper
    return decorator


# Použití
@cache_result(timeout=600, key_prefix='org_stats')
def get_organization_stats(organization_id: str) -> dict:
    """Získá statistiky organizace (cachováno 10 minut)."""
    ...


# Manuální cache operace
class OrganizationCache:
    """Cache helper pro organizace."""
    
    PREFIX = 'org'
    DEFAULT_TIMEOUT = 300  # 5 minut
    
    @classmethod
    def _key(cls, org_id: str, suffix: str = '') -> str:
        return f"{cls.PREFIX}:{org_id}:{suffix}" if suffix else f"{cls.PREFIX}:{org_id}"
    
    @classmethod
    def get_settings(cls, org_id: str) -> dict | None:
        return cache.get(cls._key(org_id, 'settings'))
    
    @classmethod
    def set_settings(cls, org_id: str, settings: dict, timeout: int = None):
        cache.set(
            cls._key(org_id, 'settings'),
            settings,
            timeout or cls.DEFAULT_TIMEOUT
        )
    
    @classmethod
    def invalidate(cls, org_id: str):
        """Invaliduje všechny cache pro organizaci."""
        pattern = cls._key(org_id, '*')
        cache.delete_pattern(pattern)
    
    @classmethod
    def get_or_set(cls, org_id: str, key: str, getter_func, timeout: int = None):
        """Get or compute and set."""
        cache_key = cls._key(org_id, key)
        result = cache.get(cache_key)
        
        if result is None:
            result = getter_func()
            cache.set(cache_key, result, timeout or cls.DEFAULT_TIMEOUT)
        
        return result
```

### AI Response Caching

```python
# apps/ai_gateway/cache.py
from redisvl.extensions.cache.llm import SemanticCache
import hashlib


class AIResponseCache:
    """
    Semantic cache pro AI odpovědi.
    Používá vector similarity pro matching podobných promptů.
    """
    
    def __init__(self, redis_url: str, threshold: float = 0.1):
        self.cache = SemanticCache(
            name="ai_cache",
            redis_url=redis_url,
            distance_threshold=threshold,
            ttl=3600,  # 1 hodina
        )
    
    def get(self, prompt: str, model: str) -> str | None:
        """Získá cached odpověď pro podobný prompt."""
        results = self.cache.check(prompt=f"{model}:{prompt}")
        if results:
            return results[0]['response']
        return None
    
    def set(self, prompt: str, model: str, response: str):
        """Uloží odpověď do cache."""
        self.cache.store(
            prompt=f"{model}:{prompt}",
            response=response,
        )
    
    def get_exact(self, prompt: str, model: str) -> str | None:
        """Získá přesně matchující odpověď (hash-based)."""
        key = hashlib.sha256(f"{model}:{prompt}".encode()).hexdigest()
        return cache.get(f"ai_exact:{key}")
    
    def set_exact(self, prompt: str, model: str, response: str, timeout: int = 3600):
        """Uloží přesnou odpověď."""
        key = hashlib.sha256(f"{model}:{prompt}".encode()).hexdigest()
        cache.set(f"ai_exact:{key}", response, timeout)
```

---

## 11. PRODUCTION DEPLOYMENT

### Kubernetes Deployment

```yaml
# k8s/celery-worker.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: celery-worker-default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: celery-worker
      queue: default
  template:
    metadata:
      labels:
        app: celery-worker
        queue: default
    spec:
      containers:
        - name: celery
          image: posthub/backend:latest
          command: ["celery", "-A", "config", "worker", "-l", "INFO", "-Q", "default"]
          env:
            - name: DJANGO_SETTINGS_MODULE
              value: config.settings.prod
          envFrom:
            - secretRef:
                name: posthub-secrets
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            exec:
              command:
                - celery
                - -A
                - config
                - inspect
                - ping
            initialDelaySeconds: 30
            periodSeconds: 30
---
# AI Worker (different resources)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: celery-worker-ai
spec:
  replicas: 2
  selector:
    matchLabels:
      app: celery-worker
      queue: ai
  template:
    spec:
      containers:
        - name: celery
          image: posthub/backend:latest
          command: 
            - celery
            - -A
            - config
            - worker
            - -l
            - INFO
            - -Q
            - ai_jobs,ai_priority
            - --concurrency=2
            - --soft-time-limit=300
            - --time-limit=360
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "1Gi"
              cpu: "1000m"
```

### KEDA Autoscaling

```yaml
# k8s/keda-scaledobject.yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: celery-worker-ai-scaler
spec:
  scaleTargetRef:
    name: celery-worker-ai
  pollingInterval: 10
  cooldownPeriod: 300
  minReplicaCount: 1
  maxReplicaCount: 20
  triggers:
    - type: redis
      metadata:
        address: redis:6379
        listName: ai_jobs
        listLength: "5"  # Scale when > 5 tasks per replica
    - type: redis
      metadata:
        address: redis:6379
        listName: ai_priority
        listLength: "2"  # Priority queue scales faster
```

### Celery Beat Deployment

```yaml
# k8s/celery-beat.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: celery-beat
spec:
  replicas: 1  # VŽDY POUZE 1!
  strategy:
    type: Recreate  # Zabrání dvojitému běhu
  selector:
    matchLabels:
      app: celery-beat
  template:
    spec:
      containers:
        - name: celery-beat
          image: posthub/backend:latest
          command:
            - celery
            - -A
            - config
            - beat
            - -l
            - INFO
            - --scheduler
            - django_celery_beat.schedulers:DatabaseScheduler
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "200m"
```

---

## 12. TROUBLESHOOTING

### Common Issues

#### 1. Task Visibility Timeout

**Problém:** Tasky se spouští vícekrát nebo mizí.

```python
# Řešení: Nastav visibility_timeout > než nejdelší task
CELERY_BROKER_TRANSPORT_OPTIONS = {
    'visibility_timeout': 7200,  # 2 hodiny
}
```

#### 2. Memory Leaks

**Problém:** Worker spotřebovává stále více paměti.

```bash
# Řešení: Omez počet tasků na worker process
celery -A config worker --max-tasks-per-child=1000
```

#### 3. Task Stuck in PENDING

**Problém:** Task zůstává ve stavu PENDING.

```python
# Debugging
from celery.result import AsyncResult

result = AsyncResult('task-id')
print(f"State: {result.state}")
print(f"Info: {result.info}")
print(f"Result: {result.result}")

# Kontrola fronty
from config.celery import app
inspect = app.control.inspect()
print(inspect.active())
print(inspect.reserved())
print(inspect.scheduled())
```

#### 4. Connection Errors

**Problém:** Spojení s Redis selhává.

```python
# Řešení: Nastav retry a keepalive
CELERY_BROKER_TRANSPORT_OPTIONS = {
    'socket_keepalive': True,
    'health_check_interval': 60,
    'retry_on_timeout': True,
}
```

### Debugging Commands

```bash
# Kontrola stavu workerů
celery -A config status

# Inspekce aktivních tasků
celery -A config inspect active

# Inspekce rezervovaných tasků
celery -A config inspect reserved

# Purge všech tasků ve frontě (OPATRNĚ!)
celery -A config purge

# Revoke konkrétního tasku
celery -A config control revoke <task-id> --terminate

# Restart všech workerů
celery -A config control shutdown
```

### Health Check Task

```python
@shared_task
def celery_health_check():
    """
    Health check task pro monitoring.
    Spouští se každých 5 minut.
    """
    return {
        'status': 'healthy',
        'timestamp': timezone.now().isoformat(),
    }
```

---

## 📌 QUICK REFERENCE

### Důležité příkazy

```bash
# Spuštění workeru
celery -A config worker -l INFO

# Spuštění beat scheduleru
celery -A config beat -l INFO

# Spuštění Flower
celery -A config flower --port=5555

# Kontrola stavu
celery -A config status
celery -A config inspect active

# Debugging
celery -A config inspect ping
celery -A config inspect stats
```

### Task Decorator Reference

```python
@shared_task(
    bind=True,                    # Access to self
    acks_late=True,               # Acknowledge after completion
    reject_on_worker_lost=True,   # Requeue on worker death
    soft_time_limit=110,          # Soft timeout (raises exception)
    time_limit=120,               # Hard timeout (kills process)
    max_retries=3,                # Maximum retry attempts
    autoretry_for=(Exception,),   # Auto-retry for exceptions
    retry_backoff=True,           # Exponential backoff
    retry_backoff_max=600,        # Max backoff time
    retry_jitter=True,            # Random jitter
    rate_limit='10/m',            # Rate limiting
    ignore_result=False,          # Store result
)
def my_task(self, arg1, arg2):
    ...
```

---

*Tento dokument je SELF-CONTAINED - obsahuje všechny informace o asynchronním zpracování.*

# Agent 3 - Realtime

## Zodpovednost

Server-Sent Events (SSE), In-app notifications, Job progress updates, Client state sync

---

## Tech Stack

| Technologie | Pouziti |
|-------------|---------|
| Django StreamingHttpResponse | SSE streams |
| Redis Pub/Sub | Real-time messaging |
| aiohttp | Async HTTP (optional) |

**POZOR:** Pouzivame SSE, NE WebSockets! SSE je jednodussi a staci pro nas use case.

---

## SSE vs WebSocket

| Aspekt | SSE | WebSocket |
|--------|-----|-----------|
| Smer | Server → Client only | Bidirectional |
| Protokol | HTTP/1.1+ | Custom (ws://) |
| Reconnect | Automatic | Manual |
| Proxy support | Excellent | Problematic |
| Complexity | Low | High |
| PostHub use case | AI job progress | Not needed |

---

## Use Cases

### 1. AI Job Progress (`/api/v1/ai/jobs/{id}/stream/`)

Real-time progress updates during AI generation:

```
data: {"progress": 0, "message": "Starting..."}

data: {"progress": 25, "message": "Analyzing company DNA..."}

data: {"progress": 50, "message": "Generating personas..."}

data: {"progress": 75, "message": "Finalizing output..."}

data: {"progress": 100, "message": "Complete", "status": "completed"}
```

### 2. Notifications Stream (`/api/v1/notifications/stream/`)

Real-time notifications for user:

```
data: {"type": "approval_required", "title": "New content ready", "message": "BlogPost needs approval"}

data: {"type": "generation_complete", "title": "Personas ready", "jobId": "uuid"}

data: {"type": "payment_failed", "title": "Payment issue", "urgent": true}
```

---

## Notification Types

```python
class NotificationType(str, Enum):
    # Content workflow
    APPROVAL_REQUIRED = "approval_required"
    CONTENT_READY = "content_ready"
    CONTENT_APPROVED = "content_approved"
    CONTENT_REJECTED = "content_rejected"
    CONTENT_PUBLISHED = "content_published"

    # AI jobs
    GENERATION_STARTED = "generation_started"
    GENERATION_COMPLETE = "generation_complete"
    GENERATION_FAILED = "generation_failed"

    # Billing
    PAYMENT_RECEIVED = "payment_received"
    PAYMENT_FAILED = "payment_failed"
    SUBSCRIPTION_EXPIRING = "subscription_expiring"
    TRIAL_EXPIRING = "trial_expiring"

    # System
    SYSTEM_ANNOUNCEMENT = "system_announcement"
    MENTION = "mention"
```

---

## SSE Implementation Pattern

### Django View

```python
from django.http import StreamingHttpResponse
import json
import time

def job_progress_stream(request, job_id):
    """SSE endpoint for job progress."""

    def event_stream():
        job = AIJob.objects.get(id=job_id)

        while job.status in [JobStatus.PENDING, JobStatus.PROCESSING]:
            # Refresh from DB
            job.refresh_from_db()

            # Send progress event
            data = {
                "progress": job.progress,
                "message": job.progress_message,
                "status": job.status
            }
            yield f"data: {json.dumps(data)}\n\n"

            if job.status in [JobStatus.COMPLETED, JobStatus.FAILED, JobStatus.CANCELLED]:
                break

            time.sleep(1)  # Poll interval

        # Final event
        yield f"data: {json.dumps({'status': job.status, 'progress': 100})}\n\n"

    response = StreamingHttpResponse(
        event_stream(),
        content_type='text/event-stream'
    )
    response['Cache-Control'] = 'no-cache'
    response['X-Accel-Buffering'] = 'no'  # Disable nginx buffering
    return response
```

### Redis Pub/Sub (Alternative)

```python
import redis

redis_client = redis.Redis(host='redis', port=6379, db=2)

def publish_progress(job_id: str, progress: int, message: str):
    """Publish progress to Redis channel."""
    redis_client.publish(
        f"job:{job_id}",
        json.dumps({"progress": progress, "message": message})
    )

def event_stream_redis(job_id: str):
    """SSE using Redis pub/sub."""
    pubsub = redis_client.pubsub()
    pubsub.subscribe(f"job:{job_id}")

    for message in pubsub.listen():
        if message['type'] == 'message':
            yield f"data: {message['data'].decode()}\n\n"
```

---

## Frontend Integration

### Angular SSE Service

```typescript
@Injectable({ providedIn: 'root' })
export class SseService {

  connectToJobProgress(jobId: string): Observable<JobProgress> {
    return new Observable(observer => {
      const eventSource = new EventSource(`/api/v1/ai/jobs/${jobId}/stream/`);

      eventSource.onmessage = (event) => {
        const data = JSON.parse(event.data);
        observer.next(data);

        if (data.status === 'completed' || data.status === 'failed') {
          eventSource.close();
          observer.complete();
        }
      };

      eventSource.onerror = (error) => {
        observer.error(error);
        eventSource.close();
      };

      return () => eventSource.close();
    });
  }

  connectToNotifications(): Observable<Notification> {
    return new Observable(observer => {
      const eventSource = new EventSource('/api/v1/notifications/stream/');

      eventSource.onmessage = (event) => {
        observer.next(JSON.parse(event.data));
      };

      // Auto-reconnect on error
      eventSource.onerror = () => {
        setTimeout(() => this.connectToNotifications(), 5000);
      };

      return () => eventSource.close();
    });
  }
}
```

---

## Notification Model

```python
class Notification(TenantAwareModel):
    id = models.UUIDField(primary_key=True)
    user = models.ForeignKey(User)
    notification_type = models.CharField(choices=NotificationType.choices)
    title = models.CharField(max_length=255)
    message = models.TextField()

    # Related entity
    content_type = models.ForeignKey(ContentType, null=True)
    object_id = models.UUIDField(null=True)
    content_object = GenericForeignKey()

    # Status
    read = models.BooleanField(default=False)
    read_at = models.DateTimeField(null=True)

    # Metadata
    action_url = models.CharField(max_length=255, blank=True)
    urgent = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
```

---

## API Endpoints

```
SSE Streams:
  GET /api/v1/ai/jobs/{id}/stream/    → Job progress SSE
  GET /api/v1/notifications/stream/   → User notifications SSE

REST APIs:
  GET  /api/v1/notifications/         → List notifications
  POST /api/v1/notifications/{id}/read/ → Mark as read
  POST /api/v1/notifications/read-all/  → Mark all as read
  GET  /api/v1/notifications/unread-count/ → Unread count
```

---

## Scheduled Notifications (Celery Beat)

```python
# apps/notifications/tasks.py

@shared_task(queue='quick')
def send_approval_reminder():
    """Send reminders for pending approvals (3+ days)."""
    pending = Content.objects.filter(
        status=ContentStatus.PENDING_APPROVAL,
        updated_at__lt=timezone.now() - timedelta(days=3)
    )
    for content in pending:
        Notification.objects.create(
            user=content.company.organization.owner,
            notification_type=NotificationType.APPROVAL_REQUIRED,
            title="Pending approval",
            message=f"Content '{content.title}' is waiting for 3+ days"
        )

@shared_task(queue='quick')
def send_trial_expiry_warning():
    """Warn users about expiring trial (3 days, 1 day)."""
    # ...

# Celery Beat schedule
CELERY_BEAT_SCHEDULE = {
    'approval-reminder-daily': {
        'task': 'apps.notifications.tasks.send_approval_reminder',
        'schedule': crontab(hour=9, minute=0),  # 9 AM daily
    },
    'trial-expiry-check': {
        'task': 'apps.notifications.tasks.send_trial_expiry_warning',
        'schedule': crontab(hour=10, minute=0),
    },
}
```

---

## CheckAgent Requirements

### ZAKAZANO
- WebSocket (pouzit SSE!)
- Polling bez SSE fallback
- Missing reconnect logic

### POVINNE
- SSE endpoint pro job progress
- Notification model s read tracking
- Redis pub/sub pro scaling
- Frontend SSE service
- Celery Beat scheduled tasks

---

## Documentation Reference

- `files/03_ASYNC_CELERY_REDIS.md` - Celery/Redis config
- `files/CONTEXT_ENGINEERING_v2.md` - User stories (notifications)

---

## Current Task

**TASK-010:** SSE pro job status (next priority)

---

## Status

READY - Waiting for assignment

---

**|**

## CheckAgent Verification

No verification yet - task not started.

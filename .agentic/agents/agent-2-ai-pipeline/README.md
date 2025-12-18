# Agent 2 - AI Pipeline

## Zodpovednost

AI Gateway integrace, Provider management, Prompt templates, Response processing, Celery tasks pro AI generation

---

## Tech Stack

| Technologie | Pouziti |
|-------------|---------|
| Celery | Async task processing |
| Redis | Message broker (redis://redis:6379/0) |
| LiteLLM | Unified AI gateway (planned) |

---

## AI Providers

### Implemented

| Provider | Model | Pouziti | Key |
|----------|-------|---------|-----|
| **Gemini** | gemini-1.5-pro | Text generation | GEMINI_API_KEY |
| **Perplexity** | llama-3.1-sonar-large-128k-online | Company research (DNA) | PERPLEXITY_API_KEY |

### Planned (Phase 3)

| Provider | Pouziti | Key |
|----------|---------|-----|
| **Nanobana** | Image generation (Imagen) | NANOBANA_API_KEY |
| **Veo 3** | Video generation | VEO_API_KEY |

---

## Content Generation Pipeline

```
Company Search (Google API)
    ↓
DNA Scraping (Perplexity)
    ↓ 30+ data points
Generate Personas (Gemini)
    ↓ 6 personas → select 3-6
Topic Approval (Supervisor)
    ↓
Generate BlogPost (Gemini)
    ↓ 4-10 stran A4
BlogPost Approval (Supervisor)
    ↓
Transform to SocialPosts (Gemini)
    ↓ Per-platform optimization
Generate Images (Nanobana) [PRO+]
    ↓
Generate Video (Veo 3) [ULTIMATE]
    ↓
Schedule & Publish
```

---

## Celery Queue Configuration

| Queue | Priority | Timeout | Pouziti |
|-------|----------|---------|---------|
| `quick` | 10 | 30s | Emails, webhooks, notifications |
| `default` | 5 | 120s | General processing |
| `ai_jobs` | 3 | 300s | AI generation |
| `ai_priority` | 8 | 300s | Priority AI (paid tiers) |
| `scheduled` | 5 | 120s | Beat periodic tasks |

### Worker Configuration

```bash
# Default worker (concurrency=4)
celery -A config worker -l INFO -Q default,quick,scheduled --concurrency=4

# AI worker (concurrency=2, more memory)
celery -A config worker -l INFO -Q ai_jobs,ai_priority --concurrency=2
```

---

## JobType Enum

```python
class JobType(str, Enum):
    # Prefix: GENERATE_*
    GENERATE_DNA = "generate_dna"           # Perplexity
    GENERATE_PERSONAS = "generate_personas" # Gemini
    GENERATE_TOPICS = "generate_topics"     # Gemini
    GENERATE_BLOGPOST = "generate_blogpost" # Gemini
    GENERATE_SOCIAL = "generate_social"     # Gemini
    GENERATE_IMAGE = "generate_image"       # Nanobana (future)
    GENERATE_VIDEO = "generate_video"       # Veo 3 (future)
```

**POZOR:** JobType pouziva prefix `GENERATE_*`, NE `SCRAPE_*` nebo `CREATE_*`!

---

## AIJob Model

```python
class AIJob(TenantAwareModel):
    id = models.UUIDField(primary_key=True)
    job_type = models.CharField(choices=JobType.choices)
    status = models.CharField(choices=JobStatus.choices)  # PENDING, PROCESSING, COMPLETED, FAILED, CANCELLED
    company = models.ForeignKey(Company)
    persona = models.ForeignKey(Persona, null=True)
    topic = models.ForeignKey(Topic, null=True)

    # Progress tracking
    progress = models.IntegerField(default=0)  # 0-100
    progress_message = models.TextField(blank=True)

    # Results
    result_data = models.JSONField(null=True)
    error_message = models.TextField(blank=True)

    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    started_at = models.DateTimeField(null=True)
    completed_at = models.DateTimeField(null=True)
```

---

## Implemented Services (`apps/ai_gateway/services.py` - 564 lines)

```python
def scrape_company_dna(company: Company) -> dict:
    """Use Perplexity to research company."""
    # Returns 30+ data points

def generate_personas(company: Company) -> list[dict]:
    """Generate 6 personas for company."""
    # Uses Company DNA as context

def generate_topics(company: Company, persona: Persona, month: int) -> list[dict]:
    """Generate monthly topics for persona."""

def generate_blogpost(topic: Topic) -> dict:
    """Generate 4-10 page blog post from topic."""

def generate_social_posts(blog_post: BlogPost, platforms: list[str]) -> list[dict]:
    """Transform blog post to platform-specific social posts."""
```

---

## Implemented Tasks (`apps/ai_gateway/tasks.py` - 598 lines)

```python
@shared_task(bind=True, queue='ai_jobs', max_retries=3)
def scrape_company_dna_task(self, job_id: str):
    """Celery task for DNA scraping."""

@shared_task(bind=True, queue='ai_jobs', max_retries=3)
def generate_personas_task(self, job_id: str):
    """Celery task for persona generation."""

@shared_task(bind=True, queue='ai_jobs', max_retries=3)
def generate_topics_task(self, job_id: str):
    """Celery task for topic generation."""

@shared_task(bind=True, queue='ai_jobs', max_retries=3)
def generate_blogpost_task(self, job_id: str):
    """Celery task for blog post generation."""

@shared_task(bind=True, queue='ai_jobs', max_retries=3)
def generate_social_posts_task(self, job_id: str):
    """Celery task for social post generation."""

@shared_task(bind=True, queue='quick')
def cancel_job_task(self, job_id: str):
    """Cancel a running job."""
```

---

## API Endpoints (`/api/v1/ai/`)

```
POST /companies/{id}/scrape-dna/      → Start DNA scraping job
POST /companies/{id}/generate-personas/ → Start persona generation
POST /companies/{id}/generate-topics/   → Start topic generation
POST /companies/{id}/generate-blogpost/ → Start blog post generation
POST /companies/{id}/generate-social/   → Start social post generation

GET  /jobs/{id}/                      → Get job status/result
POST /jobs/{id}/cancel/               → Cancel running job
GET  /jobs/{id}/stream/               → SSE stream for progress (Agent 3)

GET  /companies/{id}/jobs/            → List jobs for company
GET  /companies/{id}/jobs/stats/      → Job statistics
```

---

## Provider Implementation

### BaseProvider (`apps/ai_gateway/providers/base.py`)

```python
class AIProviderError(Exception): pass
class AIRateLimitError(AIProviderError): pass
class AITimeoutError(AIProviderError): pass

class BaseProvider(ABC):
    @abstractmethod
    async def generate(self, prompt: str, **kwargs) -> str:
        """Generate text response."""

    @abstractmethod
    async def generate_json(self, prompt: str, schema: dict) -> dict:
        """Generate structured JSON response."""

    def extract_json(self, text: str) -> dict:
        """Extract JSON from response (handles markdown code blocks)."""
```

### GeminiProvider (`apps/ai_gateway/providers/gemini.py` - 151 lines)

```python
class GeminiProvider(BaseProvider):
    def __init__(self, api_key: str, model: str = "gemini-1.5-pro"):
        self.client = genai.GenerativeModel(model)

    async def generate(self, prompt: str, temperature: float = 0.7, max_tokens: int = 4096):
        # Text generation

    async def generate_json(self, prompt: str, schema: dict):
        # Structured JSON generation
```

### PerplexityProvider (`apps/ai_gateway/providers/perplexity.py` - 196 lines)

```python
class PerplexityProvider(BaseProvider):
    def __init__(self, api_key: str, model: str = "llama-3.1-sonar-large-128k-online"):
        self.client = openai.OpenAI(api_key=api_key, base_url="https://api.perplexity.ai")

    async def research(self, query: str) -> dict:
        """Web-enabled research for company DNA."""
```

---

## Error Handling Pattern

```python
@shared_task(bind=True, queue='ai_jobs', max_retries=3)
def generate_content_task(self, job_id: str):
    job = AIJob.objects.get(id=job_id)
    job.status = JobStatus.PROCESSING
    job.started_at = timezone.now()
    job.save()

    try:
        result = ai_service.generate(...)
        job.result_data = result
        job.status = JobStatus.COMPLETED
        job.progress = 100
    except AIRateLimitError as e:
        # Retry with exponential backoff
        raise self.retry(exc=e, countdown=60 * (2 ** self.request.retries))
    except AITimeoutError as e:
        raise self.retry(exc=e, countdown=30)
    except Exception as e:
        job.status = JobStatus.FAILED
        job.error_message = str(e)
        logger.exception(f"Job {job_id} failed")
    finally:
        job.completed_at = timezone.now()
        job.save()
```

---

## KRITICKE: NIKDY nevolat AI synchronne!

```python
# SPATNE - blokuje HTTP request
def create_topic(request):
    result = gemini.generate(prompt)  # ❌ 30-120s blocking!
    return Response(result)

# SPRAVNE - async pres Celery
def create_topic(request):
    job = AIJob.objects.create(job_type=JobType.GENERATE_TOPICS, ...)
    generate_topics_task.delay(job.id)  # ✅ Non-blocking
    return Response({"jobId": job.id})
```

---

## Completed Tasks

### TASK-006: AI Provider Implementations
**Status:** COMPLETED (text generation)
**Date:** 2025-12-18

**Implemented:**
- GeminiProvider (text generation)
- PerplexityProvider (company research)
- 5 AI services
- 6 Celery tasks
- 9 API endpoints

**Not Implemented (future):**
- NanobanaProvider (images)
- VeoProvider (video)
- LiteLLM unified gateway

---

## Documentation Reference

- `files/03_ASYNC_CELERY_REDIS.md` - Celery configuration
- `files/06_AI_INTEGRATIONS.md` - AI provider details
- `files/11_ENUMS_TYPES.md` - JobType enum

---

## Current Task

**COMPLETED** - Text-based AI pipeline is production-ready

---

**|**

## CheckAgent Verification

### Status: PASS (core functionality)

### Kontrolovane oblasti
| Check | Status |
|-------|--------|
| Mock Data | PASS |
| Dummy Variables | PASS |
| TODO Komentare | PASS |
| Kompletni implementace | PASS (text) |
| Error handling | PASS |
| Input validation | PASS |
| Type safety | PASS |
| Security | PASS |
| Performance | PASS |
| Tests | DEFERRED |

### Poznamky
- Text generation pipeline fully operational
- Image/Video generation are enhancement features for future phases
- SSE progress streaming delegated to Agent 3

### Datum kontroly
2025-12-18

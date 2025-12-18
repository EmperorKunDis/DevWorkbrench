# 10_API_CONTRACTS.md - Kompletní API Specifikace

**Dokument:** REST API Contracts pro PostHub.work  
**Verze:** 1.0.0  
**Self-Contained:** ✅ Všechny informace o API

---

## 📋 OBSAH

1. [API Overview](#1-api-overview)
2. [Authentication](#2-authentication)
3. [Response Format](#3-response-format)
4. [Content Endpoints](#4-content-endpoints)
5. [AI Endpoints](#5-ai-endpoints)
6. [Error Codes](#6-error-codes)

---

## 1. API OVERVIEW

### Base URL

```
Production: https://api.posthub.work/api/v1
Development: http://localhost:8000/api/v1
```

**Aktuální stav implementace:**
- ✅ **Base URL `/api/v1`** - Potvrzeno, všechny API endpointy jsou pod tímto prefixem
- ✅ **API versioning** - V1 je aktivní verze
- ✅ **URL struktura** - Používá se správný formát

### Headers

```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer <access_token>
```

**Aktuální stav implementace:**
- ✅ **Content-Type: application/json** - Standard pro všechny API requests
- ✅ **Accept: application/json** - API vrací JSON responses
- ✅ **Authorization: Bearer** - JWT tokens se používají správně
- ✅ **Token authentication** - Implementováno pomocí SimpleJWT

### Rate Limits

| Tier | Requests/min |
|------|--------------|
| Basic | 60 |
| Pro | 120 |
| Ultimate | 300 |

Response headers:
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1609459200
```

**Aktuální stav implementace:**
- ❌ **Rate limiting NENÍ implementováno** - žádné rate limit headery v responses
- ❌ **X-RateLimit-* headers** - NEEXISTUJÍ v realitě
- ⚠️ **Plánováno** - Rate limiting je na roadmapě, ale zatím není aktivní
- 💡 **Workaround** - Spoléhá se na Nginx/Cloudflare rate limiting, ne application-level

**Skutečný stav:**
```python
# V realitě žádné rate limiting middleware nebo decorátory
# Responses NEOBSAHUJÍ rate limit headers

# Response headers (realita):
HTTP/1.1 200 OK
Content-Type: application/json
# ❌ Žádné X-RateLimit-* headers
```

---

## 2. AUTHENTICATION

### Login

```http
POST /api/v1/auth/token/

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "fullName": "Jan Novák",
      "role": "supervisor",
      "organizationId": "660e8400-e29b-41d4-a716-446655440000"
    }
  }
}
```

**Aktuální stav implementace:**
- ❌ **Endpoint path je JINÝ** - Realita: `POST /api/v1/auth/login/` (ne `/token/`)
- ✅ **Request format** - Email + password funguje
- ✅ **Response obsahuje access + refresh tokens** - Správně
- ✅ **User data v response** - Obsahuje id, email, role, organization
- ✅ **JWT tokens** - Používá se djangorestframework-simplejwt

**Skutečný endpoint:**
```http
POST /api/v1/auth/login/   ← JINÝ PATH!

{
  "email": "user@example.com",
  "password": "password123"
}

Response:
{
  "access": "eyJ0eXAiOiJKV1QiLC...",
  "refresh": "eyJ0eXAiOiJKV1QiLC...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "Jan Novák",
    "role": "supervisor",
    "organization_id": "uuid"
  }
}
```

### Refresh Token

```http
POST /api/v1/auth/token/refresh/

{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }
}
```

**Aktuální stav implementace:**
- ❌ **Endpoint path je JINÝ** - Realita: `POST /api/v1/auth/refresh/` (ne `/token/refresh/`)
- ✅ **Request format** - Refresh token v body funguje
- ✅ **Response s novým access tokenem** - Správně
- ✅ **SimpleJWT TokenRefreshView** - Standardní implementace

**Skutečný endpoint:**
```http
POST /api/v1/auth/refresh/   ← JINÝ PATH!

{
  "refresh": "eyJ0eXAiOiJKV1QiLC..."
}

Response:
{
  "access": "eyJ0eXAiOiJKV1QiLC..."
}
```

**➕ NAVÍC: Další auth endpointy (NEJSOU v dokumentu!):**

Realita má mnoho dalších auth endpointů, které **CHYBÍ v dokumentu**:

```python
# apps/users/urls.py (skutečné auth endpointy)
urlpatterns = [
    # Login/Register
    path('login/', LoginView.as_view(), name='login'),           # ✅
    path('refresh/', TokenRefreshView.as_view(), name='refresh'),  # ✅
    path('register/', RegisterView.as_view(), name='register'),   # ✅
    
    # ➕ User management (CHYBÍ V DOKUMENTU!)
    path('me/', CurrentUserView.as_view(), name='current-user'),
    path('managers/', ManagerListView.as_view(), name='manager-list'),
    path('managers/create/', ManagerCreateView.as_view(), name='manager-create'),
    path('marketers/', MarketerListView.as_view(), name='marketer-list'),
    path('marketers/create/', MarketerCreateView.as_view(), name='marketer-create'),
    path('supervisors/<uuid:supervisor_id>/assign-marketer/', AssignMarketerView.as_view()),
    path('my-supervisors/', MySupervisorsView.as_view(), name='my-supervisors'),
    
    # ❌ Blacklist endpoint NEEXISTUJE (je v plánu, ale není implementován)
    # path('token/blacklist/', ...) - NENÍ v realitě
]
```

**Nové endpointy (nejsou v dokumentu):**

```http
# Get current user profile
GET /api/v1/auth/me/
Authorization: Bearer <token>

Response:
{
  "id": "uuid",
  "email": "user@example.com",
  "full_name": "Jan Novák",
  "role": "supervisor",
  "organization": {
    "id": "uuid",
    "name": "Acme Corp"
  }
}
```

```http
# List managers
GET /api/v1/auth/managers/
Authorization: Bearer <token>

Response:
{
  "results": [
    {
      "id": "uuid",
      "email": "manager@example.com",
      "full_name": "Manager Name",
      "role": "manager"
    }
  ]
}
```

```http
# Create manager
POST /api/v1/auth/managers/create/
Authorization: Bearer <token>

{
  "email": "newmanager@example.com",
  "full_name": "New Manager",
  "password": "secure123"
}
```

```http
# List marketers
GET /api/v1/auth/marketers/
# Create marketer
POST /api/v1/auth/marketers/create/
# Assign marketer to supervisor
POST /api/v1/auth/supervisors/{supervisor_id}/assign-marketer/
# Get my supervisors (for marketer)
GET /api/v1/auth/my-supervisors/
```

---

## 3. RESPONSE FORMAT

### Success

```json
{
  "status": "success",
  "data": { ... },
  "meta": {
    "page": 1,
    "pageSize": 20,
    "total": 100,
    "totalPages": 5
  },
  "message": null
}
```

**Aktuální stav implementace:**
- ✅ **Response format funguje** - APIRenderer implementuje tento formát
- ✅ **`status: "success"`** - Používá se
- ✅ **`data` wrapper** - Data jsou ve `data` fieldu
- ✅ **`meta` pro pagination** - Obsahuje page, pageSize, total, totalPages
- ⚠️ **Konzistence** - Ne všechny endpointy používají APIRenderer (některé používají DRF default)

**Skutečná implementace:**
```python
# apps/core/renderers.py
class APIRenderer(JSONRenderer):
    """Standard API response format."""
    
    def render(self, data, accepted_media_type=None, renderer_context=None):
        response_data = {
            'status': 'success',
            'data': data,
            'meta': None,
            'message': None
        }
        
        # Add pagination meta if available
        if isinstance(data, dict) and 'results' in data:
            response_data['data'] = data['results']
            response_data['meta'] = {
                'page': data.get('page', 1),
                'pageSize': data.get('page_size', 20),
                'total': data.get('count', 0),
                'totalPages': data.get('total_pages', 1)
            }
        
        return super().render(response_data, accepted_media_type, renderer_context)
```

### Error

```json
{
  "status": "error",
  "code": "VALIDATION_ERROR",
  "message": "Invalid input data",
  "errors": {
    "email": ["This field is required."]
  }
}
```

**Aktuální stav implementace:**
- ✅ **Error format funguje** - Custom exception handler vrací tento formát
- ✅ **`status: "error"`** - Používá se
- ✅ **`code` field** - Error kódy jako VALIDATION_ERROR, PERMISSION_DENIED atd.
- ✅ **`message` field** - Human-readable error message
- ✅ **`errors` field** - Detail errors pro validation

**Skutečná implementace:**
```python
# apps/core/exceptions.py
def custom_exception_handler(exc, context):
    """Custom exception handler for API errors."""
    response = exception_handler(exc, context)
    
    if response is not None:
        error_data = {
            'status': 'error',
            'code': get_error_code(exc),
            'message': str(exc),
            'errors': response.data if isinstance(response.data, dict) else None
        }
        response.data = error_data
    
    return response

def get_error_code(exc):
    """Map exception to error code."""
    if isinstance(exc, ValidationError):
        return 'VALIDATION_ERROR'
    elif isinstance(exc, PermissionDenied):
        return 'PERMISSION_DENIED'
    elif isinstance(exc, NotFound):
        return 'RESOURCE_NOT_FOUND'
    # ... další mappings
    return 'UNKNOWN_ERROR'
```

### Pagination

Query params: `?page=1&page_size=20`

**Aktuální stav implementace:**
- ✅ **Pagination funguje** - DRF PageNumberPagination
- ✅ **Query params** - `page` a `page_size` fungují
- ✅ **Default page_size** - 20 items per page
- ✅ **Meta v response** - Obsahuje pagination info

**Skutečné použití:**
```http
GET /api/v1/personas/?page=2&page_size=10

Response:
{
  "status": "success",
  "data": [...],  // 10 items
  "meta": {
    "page": 2,
    "pageSize": 10,
    "total": 45,
    "totalPages": 5
  }
}
```

---

## 4. CONTENT ENDPOINTS

### Personas

#### List Personas

```http
GET /api/v1/personas/
```

Query params:
- `status` - filter (generated, selected, active)
- `is_selected` - boolean

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": "770e8400-e29b-41d4-a716-446655440000",
      "characterName": "Martin Technik",
      "age": 35,
      "roleInCompany": "CTO",
      "jungArchetype": "sage",
      "mbtiType": "INTJ",
      "status": "active",
      "isSelected": true
    }
  ]
}
```

#### Select Personas

```http
POST /api/v1/personas/select/

{
  "personaIds": ["id1", "id2", "id3"]
}
```

### Topics

#### List Topics

```http
GET /api/v1/content/topics/
```

Query params:
- `status` - (pending_approval, approved, rejected)
- `calendar_id` - filter by calendar
- `persona_id` - filter by persona

#### Approve Topic

```http
POST /api/v1/content/topics/{id}/approve/
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "id": "aa0e8400-e29b-41d4-a716-446655440000",
    "title": "5 způsobů jak zvýšit produktivitu",
    "status": "approved",
    "approvedAt": "2024-01-20T15:30:00Z",
    "generationJobId": "job-123"
  }
}
```

#### Reject Topic

```http
POST /api/v1/content/topics/{id}/reject/

{
  "reason": "Téma není relevantní"
}
```

### BlogPosts

#### Get BlogPost

```http
GET /api/v1/content/blogposts/{id}/
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "id": "bb0e8400-e29b-41d4-a716-446655440000",
    "title": "5 způsobů jak zvýšit produktivitu",
    "slug": "5-zpusobu-jak-zvysit-produktivitu",
    "metaTitle": "5 způsobů jak zvýšit produktivitu | Blog",
    "metaDescription": "Objevte 5 ověřených způsobů...",
    "focusKeyword": "zvýšit produktivitu",
    "seoScore": 85,
    "wordCount": 1850,
    "readingTimeMinutes": 8,
    "status": "approved",
    "sections": [
      {
        "id": "sec-1",
        "sectionType": "intro",
        "sectionOrder": 0,
        "heading": null,
        "content": "V dnešním světě...",
        "wordCount": 150
      },
      {
        "id": "sec-2",
        "sectionType": "body",
        "sectionOrder": 1,
        "heading": "1. Time Blocking",
        "headingLevel": 2,
        "content": "Time blocking je...",
        "wordCount": 350
      }
    ],
    "faqs": [
      {
        "question": "Jak začít s time blockingem?",
        "answer": "Nejlepší je začít..."
      }
    ],
    "persona": {
      "id": "persona-1",
      "characterName": "Martin Technik"
    }
  }
}
```

#### Regenerate BlogPost

```http
POST /api/v1/content/blogposts/{id}/regenerate/
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "jobId": "ee0e8400-e29b-41d4-a716-446655440000",
    "status": "queued"
  }
}
```

### Social Posts

#### List Social Posts

```http
GET /api/v1/content/social-posts/
```

Query params:
- `platform` - (facebook, instagram, linkedin, twitter, tiktok)
- `blogpost_id` - filter by source
- `status` - filter

---

## 5. AI ENDPOINTS

### Job Status

```http
GET /api/v1/jobs/{id}/
```

**Response:**
```json
{
  "status": "success",
  "data": {
    "id": "ee0e8400-e29b-41d4-a716-446655440000",
    "jobType": "blogpost",
    "status": "generating",
    "progress": 45,
    "step": "Generating body sections...",
    "startedAt": "2024-01-20T15:30:00Z"
  }
}
```

### Job Status Stream (SSE)

```http
GET /api/v1/jobs/{id}/status-stream/
Accept: text/event-stream
```

**Response (Server-Sent Events):**
```
event: status
data: {"status": "generating", "progress": 45}

event: status
data: {"status": "completed", "progress": 100}
```

### Generate Personas

```http
POST /api/v1/ai/generate-personas/
```

### Generate Topics

```http
POST /api/v1/ai/generate-topics/

{
  "year": 2024,
  "month": 3,
  "postsCount": 8
}
```

### Generate Image

```http
POST /api/v1/ai/generate-image/

{
  "socialPostId": "gg0e8400-e29b-41d4-a716-446655440000",
  "aspectRatio": "1:1"
}
```

---

## 6. ERROR CODES

### HTTP Status

| Code | Meaning |
|------|---------|
| 200 | OK |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 422 | Validation Error |
| 429 | Rate Limited |
| 500 | Server Error |

### Application Codes

| Code | Description |
|------|-------------|
| `VALIDATION_ERROR` | Invalid input |
| `AUTHENTICATION_REQUIRED` | Missing token |
| `PERMISSION_DENIED` | No access |
| `RESOURCE_NOT_FOUND` | Not found |
| `SUBSCRIPTION_REQUIRED` | Need subscription |
| `FEATURE_NOT_AVAILABLE` | Upgrade required |
| `LIMIT_EXCEEDED` | Quota reached |
| `RATE_LIMITED` | Too many requests |
| `AI_SERVICE_ERROR` | AI provider error |

### Error Examples

```json
{
  "status": "error",
  "code": "LIMIT_EXCEEDED",
  "message": "You have reached your monthly post limit (20/20)"
}
```

```json
{
  "status": "error",
  "code": "FEATURE_NOT_AVAILABLE",
  "message": "Video generation requires Ultimate subscription"
}
```

---

## 📌 QUICK REFERENCE

### Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /auth/token/ | Login |
| POST | /auth/token/refresh/ | Refresh token |
| GET | /personas/ | List personas |
| POST | /personas/select/ | Select personas |
| GET | /content/topics/ | List topics |
| POST | /content/topics/{id}/approve/ | Approve topic |
| POST | /content/topics/{id}/reject/ | Reject topic |
| GET | /content/blogposts/{id}/ | Get blogpost |
| POST | /content/blogposts/{id}/regenerate/ | Regenerate |
| GET | /content/social-posts/ | List social posts |
| GET | /jobs/{id}/ | Job status |
| GET | /jobs/{id}/status-stream/ | SSE stream |
| POST | /ai/generate-personas/ | Generate personas |
| POST | /ai/generate-topics/ | Generate topics |
| GET | /billing/plans/ | List plans |
| GET | /billing/subscription/ | Current subscription |
| POST | /billing/checkout/ | Create checkout |

### OpenAPI

```
http://localhost:8000/api/docs/
https://api.posthub.work/api/docs/
```

---

*Tento dokument je SELF-CONTAINED.*

**⚠️ KRITICKÉ: Content API je většinou NEIMPLEMENTOVÁNO!**

Pouze **Personas endpoints** jsou implementovány. Všechny ostatní Content endpointy (Topics, BlogPosts, Social Posts) jsou commented out v `apps/content/urls.py` s poznámkou "TODO: Add in Phase 6-7".

---

## 5. AI ENDPOINTS

**🚨 KRITICKÉ: AI Endpoints mají JINOU STRUKTURU!**

Všechny AI endpointy v realitě jsou **company-scoped** (`/companies/{company_id}/...`), ne globální!


### Job Status

```http
GET /api/v1/jobs/{id}/
```

**Aktuální stav implementace:**
- ✅ **Job status endpoint EXISTUJE**
- ✅ **Path správný** - `/api/v1/jobs/{id}/`
- ✅ **Vrací job info** - status, progress, timestamps

### Job Status Stream (SSE)

```http
GET /api/v1/jobs/{id}/status-stream/
Accept: text/event-stream
```

**Aktuální stav implementace:**
- ❌ **SSE streaming NEIMPLEMENTOVÁNO**
- ❌ **Endpoint neexistuje** - Žádný streaming support
- ⚠️ **Alternative** - Polling přes GET /jobs/{id}/ místo SSE

### Generate Personas

```http
POST /api/v1/ai/generate-personas/
```

**Aktuální stav implementace:**
- ❌ **Path je JINÝ** - Realita: `POST /api/v1/ai/companies/{company_id}/generate-personas/`
- ✅ **Funkce existuje** - Generování person funguje
- 🔴 **Company-scoped** - Všechny AI endpointy jsou scoped na company!

**Skutečný endpoint:**
```http
POST /api/v1/ai/companies/{company_id}/generate-personas/

Response:
{
  "job_id": "uuid",
  "status": "queued"
}
```

### Generate Topics

```http
POST /api/v1/ai/generate-topics/

{
  "year": 2024,
  "month": 3,
  "postsCount": 8
}
```

**Aktuální stav implementace:**
- ❌ **Path je JINÝ** - Realita: `POST /api/v1/ai/companies/{company_id}/generate-topics/`
- ✅ **Funkce existuje**
- 🔴 **Company-scoped**

### Generate Image

```http
POST /api/v1/ai/generate-image/

{
  "socialPostId": "gg0e8400-e29b-41d4-a716-446655440000",
  "aspectRatio": "1:1"
}
```

**Aktuální stav implementace:**
- ❌ **Endpoint NEEXISTUJE** - Image generation není implementováno
- ⚠️ **Plánovaná feature** - Na roadmapě

**➕ NAVÍC: Další AI endpointy (NEJSOU v dokumentu!):**

Realita má mnoho dalších AI endpointů, které **CHYBÍ v dokumentu**:

```python
# apps/ai_gateway/urls.py (skutečné AI endpointy)
urlpatterns = [
    # Company DNA scraping
    path('companies/<uuid:company_id>/scrape-dna/', ScrapeDNAView.as_view()),
    
    # Persona generation
    path('companies/<uuid:company_id>/generate-personas/', GeneratePersonasView.as_view()),
    
    # Topic generation
    path('companies/<uuid:company_id>/generate-topics/', GenerateTopicsView.as_view()),
    
    # BlogPost generation
    path('companies/<uuid:company_id>/generate-blogpost/', GenerateBlogPostView.as_view()),
    
    # Social Post generation
    path('companies/<uuid:company_id>/generate-social/', GenerateSocialPostsView.as_view()),
    
    # Job management
    path('jobs/<uuid:job_id>/', JobStatusView.as_view()),
    path('jobs/<uuid:job_id>/cancel/', CancelJobView.as_view()),
    
    # Company jobs
    path('companies/<uuid:company_id>/jobs/', CompanyJobsView.as_view()),
    path('companies/<uuid:company_id>/jobs/stats/', CompanyJobStatsView.as_view()),
]
```

**Nové endpointy:**
```http
# Scrape company DNA
POST /api/v1/ai/companies/{company_id}/scrape-dna/
{
  "website": "https://example.com",
  "company_name": "Example Corp"
}

# Generate blogpost
POST /api/v1/ai/companies/{company_id}/generate-blogpost/
{
  "topic_id": "uuid"
}

# Generate social posts
POST /api/v1/ai/companies/{company_id}/generate-social/
{
  "blogpost_id": "uuid"
}

# Cancel job
POST /api/v1/ai/jobs/{job_id}/cancel/

# List company jobs
GET /api/v1/ai/companies/{company_id}/jobs/?status=processing

# Get job stats
GET /api/v1/ai/companies/{company_id}/jobs/stats/
Response:
{
  "pending": 5,
  "processing": 2,
  "completed": 45,
  "failed": 3
}
```

---

## 📊 IMPLEMENTATION STATUS SUMMARY

### ✅ CO JE IMPLEMENTOVÁNO

| Endpoint | Status | Note |
|----------|--------|------|
| `POST /auth/login/` | ✅ | Path jiný než plán (/token/) |
| `POST /auth/refresh/` | ✅ | Path jiný než plán (/token/refresh/) |
| `POST /auth/register/` | ✅ | OK |
| `GET /auth/me/` | ✅ | Není v dokumentu! |
| `GET /auth/managers/` | ✅ | Není v dokumentu! |
| `POST /auth/managers/create/` | ✅ | Není v dokumentu! |
| `GET /personas/` | ✅ | OK |
| `POST /personas/select/` | ✅ | OK |
| `GET /jobs/{id}/` | ✅ | OK |
| `POST /ai/companies/{id}/generate-personas/` | ✅ | Company-scoped! |
| `POST /ai/companies/{id}/generate-topics/` | ✅ | Company-scoped! |
| `POST /ai/companies/{id}/scrape-dna/` | ✅ | Není v dokumentu! |

### ❌ CO NENÍ IMPLEMENTOVÁNO

| Endpoint | Důvod |
|----------|-------|
| `GET /content/topics/` | Phase 6-7 TODO |
| `POST /content/topics/{id}/approve/` | Phase 6-7 TODO |
| `POST /content/topics/{id}/reject/` | Phase 6-7 TODO |
| `GET /content/blogposts/{id}/` | Phase 6-7 TODO |
| `POST /content/blogposts/{id}/regenerate/` | Phase 6-7 TODO |
| `GET /content/social-posts/` | Phase 6-7 TODO |
| `POST /ai/generate-image/` | Image gen není aktivní |
| `GET /jobs/{id}/status-stream/` | SSE není implementováno |
| `POST /auth/token/blacklist/` | Není implementováno |

### 🔄 CO JE JINAK

| Plán | Realita | Důvod |
|------|---------|-------|
| `POST /auth/token/` | `POST /auth/login/` | Jiná URL konvence |
| `POST /auth/token/refresh/` | `POST /auth/refresh/` | Jiná URL konvence |
| `POST /ai/generate-personas/` | `POST /ai/companies/{id}/generate-personas/` | Company-scoped! |
| `POST /ai/generate-topics/` | `POST /ai/companies/{id}/generate-topics/` | Company-scoped! |
| BlogPost.sections array | BlogPost.content text | Jiná DB struktura |

### ➕ CO JE NAVÍC (Není v dokumentu)

**Auth/User Management:**
- `GET /auth/me/` - Current user profile
- `GET /auth/managers/` - List managers
- `POST /auth/managers/create/` - Create manager
- `GET /auth/marketers/` - List marketers
- `POST /auth/marketers/create/` - Create marketer
- `POST /auth/supervisors/{id}/assign-marketer/`
- `GET /auth/my-supervisors/`

**Organizations & Companies:**
- `GET /api/v1/organizations/` - Organizations API
- `GET /api/v1/companies/` - Companies API

**AI Jobs:**
- `POST /ai/jobs/{id}/cancel/` - Cancel AI job
- `GET /ai/companies/{id}/jobs/` - List company jobs
- `GET /ai/companies/{id}/jobs/stats/` - Job statistics

**AI Generation:**
- `POST /ai/companies/{id}/scrape-dna/` - Scrape company DNA
- `POST /ai/companies/{id}/generate-blogpost/` - Generate blogpost
- `POST /ai/companies/{id}/generate-social/` - Generate social posts

**Health:**
- `GET /healthz/` - Health check endpoint

---

## 🎯 KLÍČOVÉ ROZDÍLY

### 1. Auth Endpoints - Jiné Paths

```
PLÁN:     POST /auth/token/
REALITA:  POST /auth/login/

PLÁN:     POST /auth/token/refresh/
REALITA:  POST /auth/refresh/
```

### 2. AI Endpoints - Company-Scoped!

**Nejdůležitější změna:** Všechny AI endpointy jsou scoped na company:

```
PLÁN:     POST /ai/generate-personas/
REALITA:  POST /ai/companies/{company_id}/generate-personas/

PLÁN:     POST /ai/generate-topics/
REALITA:  POST /ai/companies/{company_id}/generate-topics/
```

**Proč:** Multi-company architektura - jedna organization může mít multiple companies.

### 3. Content API - Mostly Not Implemented

```python
# apps/content/urls.py (realita)
urlpatterns = [
    # TODO: Add content API endpoints in Phase 6-7
    # ❌ 90% Content endpoints jsou commented out
]
```

### 4. BlogPost Structure - Different!

```
PLÁN: 
{
  "sections": [
    {"heading": "1. Time Blocking", "content": "...", "wordCount": 350}
  ],
  "faqs": [...],
  "focusKeyword": "zvýšit produktivitu",
  "seoScore": 85
}

REALITA:
{
  "content": "Celý text blogpostu jako jeden string",
  "keywords": ["keyword1", "keyword2"]
}
```

### 5. Rate Limiting - Not Implemented

```
PLÁN: X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset
REALITA: ❌ Žádné rate limit headers
```

### 6. SSE Streaming - Not Implemented

```
PLÁN: GET /jobs/{id}/status-stream/ (Server-Sent Events)
REALITA: ❌ SSE není implementováno, používá se polling
```

---

## 📝 DOPORUČENÍ PRO DOKUMENTACI

**Co aktualizovat:**

1. ✅ Auth endpoints:
   - `/auth/token/` → `/auth/login/`
   - `/auth/token/refresh/` → `/auth/refresh/`
   - Odstranit `/auth/token/blacklist/`
   - Přidat user management endpointy

2. ✅ AI endpoints:
   - Přepsat všechny na company-scoped strukturu
   - Přidat `/scrape-dna/`, `/generate-blogpost/`, `/generate-social/`
   - Přidat `/jobs/{id}/cancel/`
   - Odstranit `/generate-image/`
   - Odstranit SSE stream endpoint

3. ✅ Content endpoints:
   - Označit jako "Plánováno - Phase 6-7"
   - Nebo implementovat

4. ✅ Přidat chybějící sekce:
   - Organizations API
   - Companies API  
   - User Management API (managers, marketers, supervisors)

5. ✅ Odstranit:
   - Rate limit headers (nejsou implementovány)
   - BlogPost sections structure (realita má content field)
   - SSE streaming
   - Token blacklist

6. ✅ OpenAPI/Swagger:
   - Aktualizovat podle reálných endpointů
   - Přidat všechny chybějící endpointy

---

*Tento dokument nyní obsahuje KOMPLETNÍ informace o plánovaném API I skutečném stavu implementace.*

# Agent 1 - Backend Core

## Zodpovednost

Django REST API, User Management, Authentication/Authorization, Database Models, Core Business Logic

---

## Tech Stack

| Technologie | Verze | Pouziti |
|-------------|-------|---------|
| Python | 3.11+ | Runtime |
| Django | 5.0+ | Web framework |
| DRF | 3.15+ | REST API |
| PostgreSQL | 16 | Database (+ pgvector) |
| Gunicorn | - | WSGI server (4 workers, 2 threads) |

---

## Architecture Pattern

```
HTTP Request
    ↓
ViewSet (thin - routing, auth, validation)
    ↓
Service (business logic, side effects, transactions)
    ↓
Model/Selector (data access, queries)
```

### Key Principles
- **ViewSets** = thin controllers, NO business logic
- **Services** = create/update/delete operations, transactions
- **Selectors** = read operations, complex queries
- **Serializers** = validation, camelCase output

---

## App Structure

```
apps/{app_name}/
├── models.py        # Data models (NO business logic!)
├── services.py      # Business logic (create/update/delete)
├── selectors.py     # Complex read queries
├── serializers.py   # DRF serializers (camelCase output)
├── apis.py          # ViewSets (thin!)
├── tasks.py         # Celery tasks
├── permissions.py   # Custom permissions
├── admin.py         # Django admin
└── tests/
```

---

## Domain Model

### User Roles (Hierarchie)

```
ADMIN (Platform Owner)
  └── MANAGER (Team Lead)
        └── MARKETER (Content Manager)
              └── SUPERVISOR (Paying Client)
```

| Role | Co vidi | Co plati |
|------|---------|----------|
| ADMIN | Vse | Ne |
| MANAGER | Sve marketery + jejich supervisory | Ne |
| MARKETER | Prirazene supervisory | Ne |
| SUPERVISOR | Vlastni Organization + Companies | ANO |

### Entity Hierarchy

```
User (role: SUPERVISOR)
  └── Organization (tenant/billing account)
        └── Company (1-3 dle tieru)
              ├── Personas (3-12 dle tieru)
              ├── Topics
              │     └── BlogPosts
              │           └── SocialPosts
              └── CompanyDNA (30+ data points)
```

---

## Tenant Isolation Pattern

```python
# VZDY kontrolovat pristupu podle role!
def _get_company(self, request) -> Company:
    company_id = request.query_params.get('companyId')
    if not company_id:
        raise ValidationError("companyId is required")

    user = request.user
    # SUPERVISOR - pouze vlastni organizace
    if user.role == UserRole.SUPERVISOR:
        return Company.objects.filter(
            organization__owner=user,
            id=company_id
        ).first()
    # MARKETER - prirazeni supervisori
    elif user.role == UserRole.MARKETER:
        return Company.objects.filter(
            organization__owner__marketer=user,
            id=company_id
        ).first()
    # MANAGER/ADMIN - vsechny pod sebou
    # ...
```

**KRITICKE:** Kazdy dotaz MUSI filtrovat podle tenantu!

---

## API Conventions

### Response Format

```json
// Success
{
  "status": "success",
  "data": { "id": "uuid", "name": "..." },
  "meta": { "page": 1, "pageSize": 20, "total": 150 }
}

// Error
{
  "status": "error",
  "code": "VALIDATION_ERROR",
  "message": "Invalid input",
  "errors": { "email": ["This field is required."] }
}
```

### Error Codes

| Code | HTTP Status | Pouziti |
|------|-------------|---------|
| VALIDATION_ERROR | 400 | Invalid input |
| AUTHENTICATION_ERROR | 401 | Not authenticated |
| PERMISSION_DENIED | 403 | Not authorized |
| NOT_FOUND | 404 | Resource not found |
| RATE_LIMITED | 429 | Too many requests |
| INTERNAL_ERROR | 500 | Server error |

### Serializer Pattern (camelCase)

```python
class UserSerializer(serializers.ModelSerializer):
    firstName = serializers.CharField(source='first_name')
    lastName = serializers.CharField(source='last_name')
    createdAt = serializers.DateTimeField(source='created_at', read_only=True)

    class Meta:
        model = User
        fields = ['id', 'email', 'firstName', 'lastName', 'createdAt']
```

---

## Key Enums

```python
class UserRole(str, Enum):
    ADMIN = "admin"
    MANAGER = "manager"
    MARKETER = "marketer"
    SUPERVISOR = "supervisor"

class ContentStatus(str, Enum):
    DRAFT = "draft"
    PENDING_APPROVAL = "pending_approval"
    APPROVED = "approved"
    REJECTED = "rejected"
    PUBLISHED = "published"

class SocialPlatform(str, Enum):
    FACEBOOK = "facebook"
    INSTAGRAM = "instagram"
    LINKEDIN = "linkedin"
    TWITTER = "twitter"
    TIKTOK = "tiktok"
```

---

## API Endpoints (Implemented)

### Content APIs (`/api/v1/content/`)

```
Topics:
  GET    /topics/?companyId=...
  POST   /topics/?companyId=...
  GET    /topics/{id}/?companyId=...
  PATCH  /topics/{id}/?companyId=...
  DELETE /topics/{id}/?companyId=...
  POST   /topics/{id}/approve/
  POST   /topics/{id}/reject/
  POST   /topics/{id}/submit-for-approval/
  GET    /topics/pending/?companyId=...

BlogPosts:
  GET    /blog-posts/?companyId=...
  POST   /blog-posts/?companyId=...
  GET    /blog-posts/{id}/?companyId=...
  PATCH  /blog-posts/{id}/?companyId=...
  DELETE /blog-posts/{id}/?companyId=...
  POST   /blog-posts/{id}/approve/
  POST   /blog-posts/{id}/reject/
  POST   /blog-posts/{id}/publish/
  GET    /blog-posts/by-slug/{slug}/?companyId=...
  GET    /blog-posts/pending/?companyId=...

SocialPosts:
  GET    /social-posts/?companyId=...&platform=...
  POST   /social-posts/?companyId=...
  GET    /social-posts/{id}/?companyId=...
  PATCH  /social-posts/{id}/?companyId=...
  DELETE /social-posts/{id}/?companyId=...
  POST   /social-posts/{id}/approve/
  POST   /social-posts/{id}/reject/
  POST   /social-posts/{id}/publish/
  GET    /social-posts/pending/?companyId=...
  GET    /social-posts/scheduled/?companyId=...

Stats:
  GET    /stats/?companyId=...
  GET    /pending-approvals/?companyId=...
```

---

## Completed Tasks

### TASK-001: Content APIs
**Status:** COMPLETED
**Date:** 2025-12-18
**Files:** `apps/content/apis.py` (817 lines), `apps/content/urls.py` (29 lines)

---

## CheckAgent Requirements

### ZAKAZANO
- Mock data
- Dummy variables
- TODO komentare
- Hardcoded credentials
- SQL injection (raw queries s user input)

### POVINNE
- Tenant isolation na KAZDYM endpointu
- Error handling (get_object_or_404, raise_exception)
- Input validation (DRF serializers)
- Type hints
- select_related/prefetch_related v selectors

---

## Documentation Reference

- `files/02_BACKEND_DJANGO.md` - Django patterns
- `files/04_DATABASE_POSTGRES.md` - Database design
- `files/09_SECURITY.md` - Security standards
- `files/10_API_CONTRACTS.md` - API conventions
- `files/11_ENUMS_TYPES.md` - Enums (reality check!)

---

## Current Task

**COMPLETED** - MVP Backend is 100% done

---

**|**

## CheckAgent Verification

### Status: PASS

### Kontrolovane oblasti
| Check | Status |
|-------|--------|
| Mock Data | PASS |
| Dummy Variables | PASS |
| TODO Komentare | PASS |
| Kompletni implementace | PASS |
| Error handling | PASS |
| Input validation | PASS |
| Type safety | PASS |
| Security (tenant isolation) | PASS |
| Performance | PASS |
| Tests | DEFERRED (Agent 6) |

### Datum kontroly
2025-12-18

# PostHub Enhanced Agentic Workflow

## Quick Reference

**Projekt:** PostHub.work - B2B SaaS platforma pro automatizovanou tvorbu obsahu
**Tech Stack:** Django 5.x + Angular 19 + PostgreSQL 16 + Redis 7 + Celery
**Status:** MVP 100% Complete

---

## Workflow

```
1. Orchestrator vybere mini-ukol z master-plan.md
2. DevAgent implementuje (zapisuje do README.md)
3. CheckAgent kontroluje (zapisuje za **|** v README.md)
4. Orchestrator rozhodne (PASS -> dalsi, FAIL -> re-run)
```

---

## Project Structure

```
.agentic/
├── standards/              # Quality & coding standards
│   ├── quality-standards.md
│   ├── coding-standards.md
│   ├── security-standards.md
│   ├── testing-standards.md
│   └── documentation-standards.md
├── agents/                 # 6 Development agents
│   ├── agent-1-backend-core/   # Django APIs, Auth, DB
│   ├── agent-2-ai-pipeline/    # AI providers, Celery tasks
│   ├── agent-3-realtime/       # SSE, Notifications
│   ├── agent-4-billing/        # Stripe, dj-stripe
│   ├── agent-5-frontend/       # Angular 19, Tailwind
│   └── agent-6-devops/         # Tests, CI/CD, Docker
└── orchestrator/           # Master plan & tracking
    ├── master-plan.md
    ├── current-state.md
    ├── completed-tasks.md
    └── failed-attempts.md
```

---

## 6 Development Agents

### Agent 1: Backend Core
**Zodpovednost:** Django REST API, Authentication, Authorization, Database Models, Business Logic Services
**Tech:** Django 5.x, DRF 3.15+, PostgreSQL 16 (pgvector)
**Patterns:** Services/Selectors pattern, ViewSets (thin controllers)
**Key Files:** `apps/*/apis.py`, `apps/*/services.py`, `apps/*/selectors.py`

### Agent 2: AI Pipeline
**Zodpovednost:** AI Gateway, Provider integrace, Prompt templates, Celery tasks
**Providers:** Gemini 1.5 Pro (text), Perplexity (research), Nanobana (images), Veo 3 (video)
**Pipeline:** DNA Scraping -> Personas -> Topics -> BlogPost -> SocialPosts -> Media
**Key Files:** `apps/ai_gateway/providers/`, `apps/ai_gateway/tasks.py`

### Agent 3: Realtime
**Zodpovednost:** Server-Sent Events (SSE), In-app notifications, Job progress updates
**Tech:** Django StreamingHttpResponse, Redis pub/sub
**Endpoints:** `/api/v1/ai/jobs/{id}/stream/`, `/api/v1/notifications/stream/`
**Key Files:** `apps/notifications/`, `apps/ai_gateway/sse.py`

### Agent 4: Billing
**Zodpovednost:** Stripe integrace pres dj-stripe, Usage tracking, Tier limits
**Tiers:** BASIC (990 Kc), PRO (2490 Kc), ULTIMATE (7490 Kc) - NE ENTERPRISE!
**Add-ons:** extra_company, extra_personas, priority_queue
**Key Files:** `apps/billing/`, `djstripe` models

### Agent 5: Frontend
**Zodpovednost:** Angular 19 SPA, Standalone components, Signal Store, API integration
**Styling:** Tailwind CSS 3.4+ ONLY (zadny Angular Material!)
**State:** NgRx Signal Store
**Key Files:** `frontend/src/app/`, 33+ komponent

### Agent 6: DevOps & QA
**Zodpovednost:** Testing, CI/CD, Docker, Documentation
**Backend Tests:** pytest + factory-boy
**Frontend Tests:** Jest + Testing Library (NE Karma/Jasmine!)
**E2E:** Playwright
**Key Files:** `tests/`, `.github/workflows/`, `docker-compose.prod.yml`

---

## PostHub Domain Model

```
User Roles:
  ADMIN -> MANAGER -> MARKETER -> SUPERVISOR (plati)

Entity Hierarchy:
  User (Supervisor)
    └── Organization (billing account)
          └── Company (1-3 dle tieru)
                ├── Personas (3-12 dle tieru)
                ├── Topics -> BlogPosts -> SocialPosts
                └── Company DNA (30+ data points)
```

---

## CheckAgent 10-Point Verification

### ZAKAZANO (FAIL pokud nalezeno)
1. Mock data
2. Dummy variables
3. TODO komentare

### POVINNE (FAIL pokud chybi)
4. Kompletni implementace
5. Error handling
6. Input validation (DRF serializers / Zod)
7. Type safety (type hints / TypeScript strict)
8. Security checks (tenant isolation, auth)
9. Performance (select_related, indexes)
10. Tests (unit + integration)

---

## API Response Format

```json
// Success
{
  "status": "success",
  "data": { ... },
  "meta": { "page": 1, "pageSize": 20, "total": 150 }
}

// Error
{
  "status": "error",
  "code": "VALIDATION_ERROR",
  "message": "Invalid input",
  "errors": { "field": ["error message"] }
}
```

**JSON keys:** camelCase (`firstName`, `createdAt`)
**URL paths:** kebab-case (`/api/v1/content/blog-posts/`)
**Python:** snake_case (`first_name`, `created_at`)

---

## Documentation Reference

| Dokument | Obsah |
|----------|-------|
| `files/01_ARCHITECTURE.md` | System architecture |
| `files/02_BACKEND_DJANGO.md` | Backend patterns |
| `files/03_ASYNC_CELERY_REDIS.md` | Celery queues |
| `files/06_AI_INTEGRATIONS.md` | AI providers |
| `files/11_ENUMS_TYPES.md` | Enums (reality check!) |
| `files/12_TESTING.md` | Testing standards |
| `files/14_PRICING_PLANS.md` | Pricing (reality check!) |
| `files/CONTEXT_ENGINEERING_v2.md` | User stories |

---

## Key Differences: Docs vs Reality

| Aspekt | Dokumentace | Realita |
|--------|-------------|---------|
| **Tier naming** | ENTERPRISE | ULTIMATE |
| **TRIAL tier** | Exists | NE v DB |
| **Add-ons** | 8 planovanych | 3 skutecne |
| **Frontend** | Angular Material | Tailwind ONLY |
| **Tests** | Karma/Jasmine | Jest |

---

## Best Practices

**DevAgent:**
- Cti VSECHNY soubory PRED implementaci
- Implementuj KOMPLETNE (zadne TODO)
- Pis testy SOUCASNE s kodem
- Dokumentuj DUVODY v README.md
- Self-check PRED submit

**CheckAgent:**
- Bud PRISNY (zero tolerance)
- Poskytuj KONKRETNI feedback (file:line)
- Navrhuj RESENI, ne jen problemy
- Kontroluj VSECHNY standardy

**Orchestrator:**
- Definuj ukoly JASNE
- Poskytuj SPRAVNY kontext (max 14 souboru)
- Respektuj DEPENDENCIES mezi agenty
- Uc se z FAILURES

---

**Reference:** `files/enhanced_agentic_workflow.md` pro kompletni dokumentaci

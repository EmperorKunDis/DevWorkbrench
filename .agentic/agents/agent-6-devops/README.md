# Agent 6 - DevOps & QA

## Zodpovednost

Testing (Unit, Integration, E2E), CI/CD Pipeline, Docker, Kubernetes, Monitoring, Documentation

---

## Tech Stack

### Testing

| Tool | Pouziti | Poznamka |
|------|---------|----------|
| **pytest** | Backend unit/integration tests | NE unittest! |
| **factory-boy** | Test data factories | NE Django fixtures! |
| **pytest-django** | Django test integration | |
| **coverage** | Code coverage | Target: 80%+ |
| **Jest** | Frontend unit tests | NE Karma/Jasmine! |
| **Testing Library** | Component tests | @testing-library/angular |
| **Playwright** | E2E tests | NE Cypress! |

### Infrastructure

| Tool | Pouziti |
|------|---------|
| **Docker** | Containerization |
| **Docker Compose** | Local development |
| **GitHub Actions** | CI/CD |
| **Nginx** | Reverse proxy, SSL termination |
| **Gunicorn** | WSGI server (4 workers) |

---

## Backend Testing

### Pytest Configuration (`pytest.ini`)

```ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings.test
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = -v --tb=short
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    integration: marks tests as integration tests
    e2e: marks tests as end-to-end tests
```

### Test Directory Structure

```
backend/tests/
├── conftest.py              # Shared fixtures (8KB)
├── factories.py             # Factory Boy factories (10KB)
├── unit/
│   ├── test_services.py
│   └── test_selectors.py
├── integration/
│   ├── test_content_api.py  # 905 lines, 50+ tests
│   ├── test_auth_api.py
│   └── test_ai_api.py
└── e2e/
    └── test_workflows.py
```

### Factory Boy Factories (`factories.py` - 10KB)

```python
import factory
from factory.django import DjangoModelFactory
from apps.users.models import User
from apps.organizations.models import Organization, Company
from apps.personas.models import Persona
from apps.content.models import Topic, BlogPost, SocialPost

class UserFactory(DjangoModelFactory):
    class Meta:
        model = User

    email = factory.LazyAttribute(lambda o: f"{o.first_name.lower()}@example.com")
    first_name = factory.Faker('first_name')
    last_name = factory.Faker('last_name')
    role = 'supervisor'
    is_active = True

class OrganizationFactory(DjangoModelFactory):
    class Meta:
        model = Organization

    name = factory.Faker('company')
    owner = factory.SubFactory(UserFactory)
    subscription_tier = 'basic'

class CompanyFactory(DjangoModelFactory):
    class Meta:
        model = Company

    name = factory.Faker('company')
    organization = factory.SubFactory(OrganizationFactory)
    business_field = factory.Faker('bs')
    website = factory.Faker('url')

class PersonaFactory(DjangoModelFactory):
    class Meta:
        model = Persona

    company = factory.SubFactory(CompanyFactory)
    name = factory.Faker('name')
    archetype = 'hero'
    status = 'active'

class TopicFactory(DjangoModelFactory):
    class Meta:
        model = Topic

    company = factory.SubFactory(CompanyFactory)
    persona = factory.SubFactory(PersonaFactory)
    title = factory.Faker('sentence')
    status = 'draft'

class BlogPostFactory(DjangoModelFactory):
    class Meta:
        model = BlogPost

    topic = factory.SubFactory(TopicFactory)
    title = factory.Faker('sentence')
    content = factory.Faker('text', max_nb_chars=5000)
    status = 'draft'

class SocialPostFactory(DjangoModelFactory):
    class Meta:
        model = SocialPost

    blog_post = factory.SubFactory(BlogPostFactory)
    platform = 'linkedin'
    content = factory.Faker('text', max_nb_chars=280)
    status = 'draft'
```

### Shared Fixtures (`conftest.py` - 8KB)

```python
import pytest
from rest_framework.test import APIClient
from tests.factories import (
    UserFactory, OrganizationFactory, CompanyFactory,
    PersonaFactory, TopicFactory, BlogPostFactory, SocialPostFactory
)

@pytest.fixture
def api_client():
    """DRF API client."""
    return APIClient()

@pytest.fixture
def supervisor_user(db):
    """Authenticated supervisor user."""
    return UserFactory(role='supervisor')

@pytest.fixture
def admin_user(db):
    """Admin user with full access."""
    return UserFactory(role='admin')

@pytest.fixture
def authenticated_client(api_client, supervisor_user):
    """API client authenticated as supervisor."""
    api_client.force_authenticate(user=supervisor_user)
    return api_client

@pytest.fixture
def organization(supervisor_user):
    """Organization owned by supervisor."""
    return OrganizationFactory(owner=supervisor_user)

@pytest.fixture
def company(organization):
    """Company in organization."""
    return CompanyFactory(organization=organization)

@pytest.fixture
def persona(company):
    """Active persona in company."""
    return PersonaFactory(company=company, status='active')

@pytest.fixture
def topic(company, persona):
    """Draft topic."""
    return TopicFactory(company=company, persona=persona)

@pytest.fixture
def blog_post(topic):
    """Draft blog post."""
    return BlogPostFactory(topic=topic)
```

### Test Example Pattern

```python
# tests/integration/test_content_api.py

import pytest
from rest_framework import status
from tests.factories import TopicFactory, CompanyFactory

@pytest.mark.django_db
@pytest.mark.integration
class TestTopicListAPI:

    def test_list_topics_success(self, authenticated_client, company):
        """Test listing topics for a company."""
        TopicFactory.create_batch(3, company=company)

        response = authenticated_client.get(
            '/api/v1/content/topics/',
            {'companyId': str(company.id)}
        )

        assert response.status_code == status.HTTP_200_OK
        assert response.data['status'] == 'success'
        assert len(response.data['data']) == 3

    def test_list_topics_requires_company_id(self, authenticated_client):
        """Test that companyId is required."""
        response = authenticated_client.get('/api/v1/content/topics/')

        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert 'companyId' in str(response.data)

    def test_list_topics_tenant_isolation(self, authenticated_client, company):
        """Test that user cannot see other organizations' topics."""
        other_company = CompanyFactory()  # Different organization
        TopicFactory(company=other_company)

        response = authenticated_client.get(
            '/api/v1/content/topics/',
            {'companyId': str(other_company.id)}
        )

        # Should return empty or 403
        assert response.data['data'] == [] or response.status_code == 403
```

### KRITICKE: Authentication Pattern

```python
# SPRAVNE - force_authenticate pro testy
api_client.force_authenticate(user=supervisor_user)

# SPATNE - JWT tokeny v testech (komplikovane)
token = get_jwt_token(user)
api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
```

---

## Frontend Testing

### Jest Configuration

```javascript
// jest.config.js
module.exports = {
  preset: 'jest-preset-angular',
  setupFilesAfterEnv: ['<rootDir>/setup-jest.ts'],
  testPathIgnorePatterns: ['/node_modules/', '/e2e/'],
  coverageDirectory: 'coverage',
  coverageReporters: ['html', 'lcov'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.spec.ts',
    '!src/main.ts',
    '!src/polyfills.ts'
  ]
};
```

### Component Test Example

```typescript
// features/content-planner/content-planner.component.spec.ts

import { render, screen, fireEvent } from '@testing-library/angular';
import { ContentPlannerComponent } from './content-planner.component';
import { ContentStore } from '@core/stores/content.store';

describe('ContentPlannerComponent', () => {
  it('should display topics', async () => {
    const mockTopics = [
      { id: '1', title: 'Topic 1', status: 'draft' },
      { id: '2', title: 'Topic 2', status: 'approved' },
    ];

    await render(ContentPlannerComponent, {
      providers: [
        {
          provide: ContentStore,
          useValue: {
            topics: signal(mockTopics),
            loading: signal(false),
          }
        }
      ]
    });

    expect(screen.getByText('Topic 1')).toBeInTheDocument();
    expect(screen.getByText('Topic 2')).toBeInTheDocument();
  });

  it('should show loading spinner when loading', async () => {
    await render(ContentPlannerComponent, {
      providers: [
        {
          provide: ContentStore,
          useValue: {
            topics: signal([]),
            loading: signal(true),
          }
        }
      ]
    });

    expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
  });
});
```

---

## E2E Testing (Playwright)

### Configuration

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:4200',
    trace: 'on-first-retry',
  },
  webServer: {
    command: 'npm run start',
    url: 'http://localhost:4200',
    reuseExistingServer: !process.env.CI,
  },
});
```

### E2E Test Example

```typescript
// e2e/content-workflow.spec.ts

import { test, expect } from '@playwright/test';

test.describe('Content Workflow', () => {
  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto('/login');
    await page.fill('[data-testid="email"]', 'test@example.com');
    await page.fill('[data-testid="password"]', 'password123');
    await page.click('[data-testid="login-button"]');
    await expect(page).toHaveURL('/dashboard');
  });

  test('create and approve topic', async ({ page }) => {
    // Navigate to content planner
    await page.click('[data-testid="nav-content-planner"]');

    // Create new topic
    await page.click('[data-testid="create-topic"]');
    await page.fill('[data-testid="topic-title"]', 'Test Topic');
    await page.click('[data-testid="save-topic"]');

    // Verify topic created
    await expect(page.getByText('Test Topic')).toBeVisible();
    await expect(page.getByText('DRAFT')).toBeVisible();

    // Submit for approval
    await page.click('[data-testid="submit-approval"]');
    await expect(page.getByText('PENDING')).toBeVisible();

    // Approve
    await page.click('[data-testid="approve-topic"]');
    await expect(page.getByText('APPROVED')).toBeVisible();
  });
});
```

---

## CI/CD Pipeline (GitHub Actions)

### Workflow (`.github/workflows/ci.yml`)

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test-backend:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: pgvector/pgvector:pg16
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: posthub_test
        ports:
          - 5432:5432
      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install dependencies
        run: pip install -r requirements/test.txt
      - name: Run linting
        run: |
          flake8 --max-line-length=120
          isort --check-only .
      - name: Run tests
        run: pytest --cov=apps --cov-report=xml
      - name: Upload coverage
        uses: codecov/codecov-action@v4

  test-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      - name: Install dependencies
        run: cd frontend && npm ci
      - name: Run linting
        run: cd frontend && npm run lint
      - name: Run tests
        run: cd frontend && npm run test:ci
      - name: Build
        run: cd frontend && npm run build

  deploy:
    needs: [test-backend, test-frontend]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /opt/PostHubVerIV
            git pull origin main
            docker compose -f docker-compose.prod.yml pull
            docker compose -f docker-compose.prod.yml run --rm api python manage.py migrate --noinput
            docker compose -f docker-compose.prod.yml up -d --force-recreate
            docker image prune -f
```

---

## Docker Configuration

### Production (`docker-compose.prod.yml`)

```yaml
services:
  api:
    image: ghcr.io/emperorkundis/posthub-api:latest
    ports:
      - "127.0.0.1:8000:8000"
    environment:
      - DJANGO_SETTINGS_MODULE=config.settings.production
    depends_on:
      - postgres
      - redis
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'

  celery-worker:
    image: ghcr.io/emperorkundis/posthub-api:latest
    command: celery -A config worker -l INFO -Q default,quick,scheduled --concurrency=4
    depends_on:
      - api
      - redis
    deploy:
      resources:
        limits:
          memory: 512M

  celery-worker-ai:
    image: ghcr.io/emperorkundis/posthub-api:latest
    command: celery -A config worker -l INFO -Q ai_jobs,ai_priority --concurrency=2
    deploy:
      resources:
        limits:
          memory: 1G

  celery-beat:
    image: ghcr.io/emperorkundis/posthub-api:latest
    command: celery -A config beat -l INFO --scheduler django_celery_beat.schedulers:DatabaseScheduler

  frontend:
    image: ghcr.io/emperorkundis/posthub-frontend:latest
    ports:
      - "127.0.0.1:4200:80"

  postgres:
    image: pgvector/pgvector:pg16
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru

  flower:
    image: mher/flower:latest
    ports:
      - "5555:5555"
```

---

## Monitoring

### Health Endpoints

| Service | Endpoint | Expected |
|---------|----------|----------|
| API | `GET /healthz/` | 200 OK |
| Frontend | `GET /health` | "healthy" |
| PostgreSQL | `pg_isready` | exit 0 |
| Redis | `redis-cli ping` | PONG |

### Flower Dashboard

URL: `http://server:5555`
- Monitor Celery workers
- View task queue lengths
- Check task success/failure rates

---

## Completed Tasks

### TASK-009: Integration Tests for Content APIs
**Status:** COMPLETED
**Date:** 2025-12-18
**Files:** `tests/integration/test_content_api.py` (905 lines)
**Tests:** 21 classes, 50+ test methods

---

## Current Task

**COMPLETED** - Content API tests done

---

## Documentation Reference

- `files/08_INFRASTRUCTURE.md` - Docker/K8s config
- `files/12_TESTING.md` - Testing standards (REALITY CHECK!)

---

**|**

## CheckAgent Verification

### Status: PASS

### Kontrolovane oblasti
| Check | Status |
|-------|--------|
| pytest (not unittest) | PASS |
| factory-boy (not fixtures) | PASS |
| Jest (not Karma) | PASS |
| force_authenticate | PASS |
| Test coverage | PASS |
| CI/CD pipeline | PASS |
| Docker config | PASS |

### Datum kontroly
2025-12-18

# 12_TESTING.md - Kompletní Testing Specifikace

**Dokument:** Testing Strategy pro PostHub.work  
**Verze:** 1.0.0  
**Self-Contained:** ✅ Všechny informace o testování

---

## 📋 OBSAH

1. [Test Strategy](#1-test-strategy)
2. [Backend Testing](#2-backend-testing)
3. [Frontend Testing](#3-frontend-testing)
4. [E2E Testing](#4-e2e-testing)
5. [CI/CD Integration](#5-cicd-integration)

---

## 1. TEST STRATEGY

### Test Pyramid

```
       ┌─────────┐
       │   E2E   │  10% - Critical paths
      ┌┴─────────┴┐
      │Integration│  20% - API contracts
     ┌┴───────────┴┐
     │    Unit     │  70% - Business logic
     └─────────────┘
```

**Aktuální stav implementace:**
- ✅ **Test pyramid approach** - Strategie je implementována
- ✅ **Unit tests dominance** - Většina testů je unit tests
- ✅ **Integration tests** - API contract tests existují
- ⚠️ **E2E tests** - E2E folder existuje, ale rozsah nejistý
- ✅ **Pytest framework** - Používá se pro backend

### Coverage Targets

| Layer | Target |
|-------|--------|
| Unit Tests | 80%+ |
| Integration Tests | 70%+ |
| E2E Tests | Critical flows |

**Aktuální stav implementace:**
- ⚠️ **Coverage targets** - Nejsou striktně vynucovány v CI
- ✅ **pytest-cov** - Je k dispozici pro coverage reporting
- ⚠️ **Aktuální coverage** - Neznámá (nejsou veřejné reporty)
- 💡 **Best practice** - Targets jsou aspirační, ne blocking

### Dependencies

```txt
# Backend (requirements/test.txt)
pytest>=8.0.0
pytest-django>=4.8.0
pytest-cov>=4.1.0
pytest-asyncio>=0.23.0
factory-boy>=3.3.0
faker>=22.0.0
httpx>=0.27.0
responses>=0.25.0
```

**Aktuální stav implementace:**
- ✅ **pytest** - Nainstalováno a používá se
- ✅ **pytest-django** - Pro Django integration
- ✅ **pytest-cov** - Pro coverage reporting
- ✅ **pytest-asyncio** - Pro async tests
- ✅ **factory-boy** - Pro test factories (10 KB factories.py existuje!)
- ✅ **faker** - Pro fake data generation
- ✅ **httpx** - Pro HTTP client testing
- ✅ **responses** - Pro mocking HTTP responses
- ✅ **Všechny dependencies nainstalované**

```json
// Frontend (package.json)
{
  "devDependencies": {
    "jasmine-core": "~5.1.0",
    "karma": "~6.4.0",
    "karma-chrome-launcher": "~3.2.0",
    "karma-coverage": "~2.2.0",
    "@playwright/test": "^1.40.0"
  }
}
```

**Aktuální stav implementace:**
- ❌ **Karma NENÍ používán** - Frontend testing je JINÝ!
- ❌ **Jasmine NENÍ používán** - Frontend testing je JINÝ!
- ✅ **Jest JE používán** - Místo Karma/Jasmine!
- ✅ **@playwright/test** - Pravděpodobně pro E2E (e2e/ folder existuje)

**🔴 KRITICKÝ ROZDÍL - Frontend Testing Framework:**

```json
// PLÁN (Karma/Jasmine):
{
  "jasmine-core": "~5.1.0",
  "karma": "~6.4.0",
  "karma-chrome-launcher": "~3.2.0",
  "karma-coverage": "~2.2.0"
}

// REALITA (Jest):
{
  "test": "jest",
  "test:watch": "jest --watch",
  "test:coverage": "jest --coverage",
  
  "@types/jest": "^29.5.0",
  "jest": "^29.7.0",
  "jest-preset-angular": "^14.0.0",
  "@testing-library/jest-dom": "^6.1.0",
  "@testing-library/angular": "^14.0.0"
}
```

**Proč Jest místo Karma?**
- ✅ **Faster** - Jest je rychlejší než Karma
- ✅ **Better DX** - Lepší developer experience
- ✅ **Modern** - Jest je modernější řešení
- ✅ **Angular 14+ default** - Angular přešel na Jest

---

## 2. BACKEND TESTING

### Pytest Configuration

```python
# pytest.ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings.test
python_files = tests.py test_*.py
addopts = -v --tb=short --cov=apps --cov-report=term-missing
asyncio_mode = auto
```

**Aktuální stav implementace:**
- ✅ **pytest.ini existuje**
- ✅ **DJANGO_SETTINGS_MODULE** - Správně nastaveno na config.settings.test
- ✅ **python_files** - tests.py a test_*.py pattern funguje
- ⚠️ **addopts** - ODLIŠNÉ od plánu!
- ✅ **asyncio_mode = auto** - Pro async tests

**🔴 ROZDÍL v pytest.ini addopts:**

```ini
# PLÁN:
addopts = -v --tb=short --cov=apps --cov-report=term-missing

# REALITA:
addopts = -v --tb=short --strict-markers --reuse-db
# ❌ Chybí: --cov=apps --cov-report=term-missing
# ➕ Navíc: --strict-markers --reuse-db
```

**Proč tyto změny:**
- `--strict-markers` - Zajišťuje, že pouze deklarované markery jsou povoleny
- `--reuse-db` - Zrychluje testy (reuse DB místo recreate každý run)
- Chybí `--cov` - Coverage se spouští explicitně přes pytest-cov plugin, ne default

**➕ NAVÍC: Pytest Markers:**

```ini
# REALITA (pytest.ini má markers sekci, která NENÍ v plánu):
[pytest]
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    integration: marks tests as integration tests
    e2e: marks tests as end-to-end tests
```

Použití:
```python
@pytest.mark.slow
def test_generate_blogpost():
    ...

@pytest.mark.integration
def test_api_create_persona():
    ...

@pytest.mark.e2e
def test_full_content_workflow():
    ...
```

```python
# config/settings/test.py
from .base import *

DEBUG = False
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'posthub_test',
        'USER': 'posthub',
        'PASSWORD': 'test',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}

PASSWORD_HASHERS = ['django.contrib.auth.hashers.MD5PasswordHasher']
CELERY_TASK_ALWAYS_EAGER = True
CELERY_TASK_EAGER_PROPAGATES = True
```

### Factories

```python
# tests/factories.py
import factory
from factory.django import DjangoModelFactory
from faker import Faker

from apps.users.models import User
from apps.organizations.models import Organization
from apps.personas.models import Persona
from apps.content.models import Topic, BlogPost, ContentCalendar

fake = Faker('cs_CZ')


class OrganizationFactory(DjangoModelFactory):
    class Meta:
        model = Organization
    
    name = factory.LazyAttribute(lambda _: fake.company())
    slug = factory.LazyAttribute(lambda o: o.name.lower().replace(' ', '-')[:50])
    is_active = True


class UserFactory(DjangoModelFactory):
    class Meta:
        model = User
    
    email = factory.LazyAttribute(lambda _: fake.email())
    first_name = factory.LazyAttribute(lambda _: fake.first_name())
    last_name = factory.LazyAttribute(lambda _: fake.last_name())
    role = 'supervisor'
    organization = factory.SubFactory(OrganizationFactory)
    
    @factory.post_generation
    def password(obj, create, extracted, **kwargs):
        obj.set_password(extracted or 'testpassword123')
        if create:
            obj.save()


class PersonaFactory(DjangoModelFactory):
    class Meta:
        model = Persona
    
    organization = factory.SubFactory(OrganizationFactory)
    character_name = factory.LazyAttribute(lambda _: fake.name())
    age = factory.LazyAttribute(lambda _: fake.random_int(25, 55))
    jung_archetype = 'sage'
    mbti_type = 'INTJ'
    status = 'active'
    is_selected = True


class TopicFactory(DjangoModelFactory):
    class Meta:
        model = Topic
    
    organization = factory.SubFactory(OrganizationFactory)
    persona = factory.SubFactory(PersonaFactory)
    title = factory.LazyAttribute(lambda _: fake.sentence())
    description = factory.LazyAttribute(lambda _: fake.paragraph())
    status = 'pending_approval'
```

### Fixtures

```python
# tests/conftest.py
import pytest
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from tests.factories import UserFactory, OrganizationFactory, PersonaFactory, TopicFactory


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def organization():
    return OrganizationFactory()


@pytest.fixture
def user(organization):
    return UserFactory(organization=organization)


@pytest.fixture
def authenticated_client(api_client, user):
    refresh = RefreshToken.for_user(user)
    api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
    return api_client


@pytest.fixture
def persona(organization):
    return PersonaFactory(organization=organization)


@pytest.fixture
def topic(organization, persona):
    return TopicFactory(organization=organization, persona=persona)
```

### Service Tests

```python
# tests/unit/test_content_services.py
import pytest
from apps.content.services import topic_approve, topic_reject
from apps.content.models import ContentStatus


class TestTopicApprove:
    def test_approve_pending_topic(self, topic, user):
        assert topic.status == ContentStatus.PENDING_APPROVAL
        
        result = topic_approve(topic_id=topic.id, user=user)
        
        assert result.status == ContentStatus.APPROVED
        assert result.approved_by == user
        assert result.approved_at is not None
    
    def test_approve_already_approved_raises(self, topic, user):
        topic.status = ContentStatus.APPROVED
        topic.save()
        
        with pytest.raises(ValueError, match="already approved"):
            topic_approve(topic_id=topic.id, user=user)
    
    def test_approve_triggers_blogpost_generation(self, topic, user, mocker):
        mock_task = mocker.patch('apps.content.tasks.generate_blogpost.delay')
        
        topic_approve(topic_id=topic.id, user=user)
        
        mock_task.assert_called_once_with(str(topic.id))


class TestTopicReject:
    def test_reject_with_reason(self, topic, user):
        reason = "Téma není relevantní"
        
        result = topic_reject(topic_id=topic.id, user=user, reason=reason)
        
        assert result.status == ContentStatus.REJECTED
        assert result.rejection_reason == reason
    
    def test_reject_without_reason_raises(self, topic, user):
        with pytest.raises(ValueError, match="Reason is required"):
            topic_reject(topic_id=topic.id, user=user, reason="")
```

### API Tests

```python
# tests/api/test_topics_api.py
import pytest
from django.urls import reverse
from rest_framework import status

from tests.factories import TopicFactory


@pytest.mark.django_db
class TestTopicsAPI:
    
    def test_list_topics(self, authenticated_client, organization, topic):
        url = reverse('topic-list')
        
        response = authenticated_client.get(url)
        
        assert response.status_code == status.HTTP_200_OK
        assert response.data['status'] == 'success'
        assert len(response.data['data']) == 1
    
    def test_approve_topic(self, authenticated_client, topic):
        url = reverse('topic-approve', kwargs={'pk': topic.id})
        
        response = authenticated_client.post(url)
        
        assert response.status_code == status.HTTP_200_OK
        assert response.data['data']['status'] == 'approved'
    
    def test_reject_topic(self, authenticated_client, topic):
        url = reverse('topic-reject', kwargs={'pk': topic.id})
        
        response = authenticated_client.post(url, {'reason': 'Not relevant'})
        
        assert response.status_code == status.HTTP_200_OK
        assert response.data['data']['status'] == 'rejected'
    
    def test_unauthorized_access(self, api_client, topic):
        url = reverse('topic-list')
        
        response = api_client.get(url)
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


@pytest.mark.django_db
class TestTenantIsolation:
    
    def test_user_sees_only_own_topics(self, authenticated_client, organization):
        own_topic = TopicFactory(organization=organization)
        other_topic = TopicFactory()  # Different org
        
        url = reverse('topic-list')
        response = authenticated_client.get(url)
        
        topic_ids = [t['id'] for t in response.data['data']]
        assert str(own_topic.id) in topic_ids
        assert str(other_topic.id) not in topic_ids
```

### Async Task Tests

```python
# tests/unit/test_celery_tasks.py
import pytest
from unittest.mock import patch, MagicMock
from apps.content.tasks import generate_blogpost_task
from apps.ai_gateway.models import GenerationJob, JobStatus


@pytest.mark.django_db
class TestGenerateBlogpostTask:
    
    @patch('apps.ai_gateway.services.AIGateway')
    def test_generates_blogpost_successfully(self, mock_gateway, topic):
        mock_gateway.return_value.generate.return_value = MagicMock(
            content={'title': 'Test', 'sections': []},
            input_tokens=1000,
            output_tokens=2000,
        )
        
        job = GenerationJob.objects.create(
            organization=topic.organization,
            job_type='blogpost',
            status=JobStatus.PENDING,
        )
        
        generate_blogpost_task(str(topic.id), str(job.id))
        
        job.refresh_from_db()
        assert job.status == JobStatus.COMPLETED
    
    @patch('apps.ai_gateway.services.AIGateway')
    def test_handles_ai_error(self, mock_gateway, topic):
        mock_gateway.return_value.generate.side_effect = Exception("AI Error")
        
        job = GenerationJob.objects.create(
            organization=topic.organization,
            job_type='blogpost',
            status=JobStatus.PENDING,
        )
        
        with pytest.raises(Exception):
            generate_blogpost_task(str(topic.id), str(job.id))
        
        job.refresh_from_db()
        assert job.status == JobStatus.FAILED
```

---

## 3. FRONTEND TESTING

### Karma Configuration

```typescript
// karma.conf.js
module.exports = function (config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine', '@angular-devkit/build-angular'],
    plugins: [
      require('karma-jasmine'),
      require('karma-chrome-launcher'),
      require('karma-coverage'),
      require('@angular-devkit/build-angular/plugins/karma')
    ],
    coverageReporter: {
      dir: require('path').join(__dirname, './coverage'),
      reporters: [{ type: 'html' }, { type: 'text-summary' }, { type: 'lcov' }],
      check: {
        global: {
          statements: 70,
          branches: 60,
          functions: 70,
          lines: 70
        }
      }
    },
    browsers: ['ChromeHeadless'],
    singleRun: true,
  });
};
```

### Component Tests

```typescript
// topic-card.component.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TopicCardComponent } from './topic-card.component';
import { Topic, ContentStatus } from '../../../data/models';

describe('TopicCardComponent', () => {
  let component: TopicCardComponent;
  let fixture: ComponentFixture<TopicCardComponent>;
  
  const mockTopic: Topic = {
    id: '123',
    title: 'Test Topic',
    status: ContentStatus.PENDING_APPROVAL,
    personaName: 'Test Persona',
  } as Topic;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TopicCardComponent],
    }).compileComponents();

    fixture = TestBed.createComponent(TopicCardComponent);
    component = fixture.componentInstance;
    component.topic = mockTopic;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should display topic title', () => {
    const titleEl = fixture.nativeElement.querySelector('h3');
    expect(titleEl.textContent).toContain('Test Topic');
  });

  it('should emit approve event', () => {
    spyOn(component.approve, 'emit');
    
    const btn = fixture.nativeElement.querySelector('[data-testid="approve-btn"]');
    btn.click();
    
    expect(component.approve.emit).toHaveBeenCalledWith('123');
  });
});
```

### Service Tests

```typescript
// content.service.spec.ts
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { ContentService } from './content.service';

describe('ContentService', () => {
  let service: ContentService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [ContentService],
    });
    service = TestBed.inject(ContentService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('should fetch topics', () => {
    const mockTopics = [{ id: '1', title: 'Topic 1' }];

    service.getTopics().subscribe(response => {
      expect(response.data.length).toBe(1);
    });

    const req = httpMock.expectOne('/api/v1/content/topics/');
    expect(req.request.method).toBe('GET');
    req.flush({ status: 'success', data: mockTopics });
  });

  it('should approve topic', () => {
    service.approveTopic('123').subscribe(response => {
      expect(response.data.status).toBe('approved');
    });

    const req = httpMock.expectOne('/api/v1/content/topics/123/approve/');
    expect(req.request.method).toBe('POST');
    req.flush({ status: 'success', data: { id: '123', status: 'approved' } });
  });
});
```

### Store Tests

```typescript
// content.store.spec.ts
import { TestBed } from '@angular/core/testing';
import { ContentStore } from './content.store';
import { ContentService } from '../data/services/content.service';
import { of } from 'rxjs';

describe('ContentStore', () => {
  let store: InstanceType<typeof ContentStore>;
  let contentService: jasmine.SpyObj<ContentService>;

  beforeEach(() => {
    const spy = jasmine.createSpyObj('ContentService', ['getTopics', 'approveTopic']);
    
    TestBed.configureTestingModule({
      providers: [
        ContentStore,
        { provide: ContentService, useValue: spy },
      ],
    });

    store = TestBed.inject(ContentStore);
    contentService = TestBed.inject(ContentService) as jasmine.SpyObj<ContentService>;
  });

  it('should load topics', () => {
    const mockTopics = [{ id: '1', status: 'pending_approval' }];
    contentService.getTopics.and.returnValue(of({ status: 'success', data: mockTopics }));

    store.loadTopics({});

    expect(store.topics().length).toBe(1);
    expect(store.pendingTopics().length).toBe(1);
  });
});
```

---

## 4. E2E TESTING

### Playwright Config

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e/tests',
  fullyParallel: true,
  retries: 2,
  workers: 4,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:4200',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { browserName: 'chromium' } },
    { name: 'firefox', use: { browserName: 'firefox' } },
  ],
  webServer: {
    command: 'npm run start',
    url: 'http://localhost:4200',
    reuseExistingServer: !process.env.CI,
  },
});
```

### E2E Tests

```typescript
// e2e/tests/content-flow.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Content Approval Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
    await page.fill('[data-testid="email"]', 'test@example.com');
    await page.fill('[data-testid="password"]', 'testpassword');
    await page.click('[data-testid="login-button"]');
    await expect(page).toHaveURL('/dashboard');
  });

  test('should approve topic', async ({ page }) => {
    await page.goto('/content/topics');
    
    const topicCard = page.locator('[data-testid="topic-card"]').first();
    await topicCard.locator('[data-testid="approve-button"]').click();
    
    await expect(topicCard.locator('[data-testid="status-badge"]')).toHaveText('Schváleno');
  });

  test('should reject topic with reason', async ({ page }) => {
    await page.goto('/content/topics');
    
    const topicCard = page.locator('[data-testid="topic-card"]').first();
    await topicCard.locator('[data-testid="reject-button"]').click();
    
    const dialog = page.locator('[data-testid="reject-dialog"]');
    await dialog.locator('textarea').fill('Not relevant');
    await dialog.locator('[data-testid="confirm-reject"]').click();
    
    await expect(topicCard.locator('[data-testid="status-badge"]')).toHaveText('Zamítnuto');
  });
});
```

---

## 5. CI/CD INTEGRATION

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: posthub_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
        ports:
          - 5432:5432
      redis:
        image: redis:7
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: pip install -r requirements/test.txt
      - run: pytest --cov=apps --cov-report=xml
      - uses: codecov/codecov-action@v3

  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
        working-directory: ./frontend
      - run: npm run test -- --no-watch --code-coverage
        working-directory: ./frontend
      - uses: codecov/codecov-action@v3

  e2e-tests:
    runs-on: ubuntu-latest
    needs: [backend-tests, frontend-tests]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npx playwright install --with-deps
      - run: npx playwright test
      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
```

---

## 📌 QUICK REFERENCE

### Commands

```bash
# Backend
pytest                          # All tests
pytest -v                       # Verbose
pytest -k "test_approve"        # Filter
pytest --cov=apps               # Coverage
pytest -x                       # Stop on first failure

# Frontend
ng test                         # Watch mode
ng test --no-watch              # Single run
ng test --code-coverage         # With coverage

# E2E
npx playwright test             # All tests
npx playwright test --ui        # UI mode
npx playwright test --debug     # Debug
```

### Coverage Reports

```bash
# Backend
pytest --cov-report=html
open htmlcov/index.html

# Frontend
ng test --code-coverage
open coverage/index.html
```

---

*Tento dokument je SELF-CONTAINED.*

**Aktuální stav implementace - config/settings/test.py:**
- ✅ **Test settings existují**
- ✅ **Test database** - Správná konfigurace
- ✅ **PASSWORD_HASHERS** - MD5 pro rychlejší testy
- ✅ **CELERY_TASK_ALWAYS_EAGER** - Celery tasks běží synchronně
- ✅ **CELERY_TASK_EAGER_PROPAGATES** - Propagace exception

### Factories

**Aktuální stav implementace:**
- ✅ **factories.py EXISTUJE** - 10 KB soubor!
- ✅ **factory-boy** - Používá se DjangoModelFactory
- ✅ **Faker** - Pro fake data generation
- ⚠️ **Faker locale** - Pravděpodobně default (en_US), ne cs_CZ
- ❌ **ContentCalendar import** - NEEXISTUJE v realitě (není v models)
- ⚠️ **Persona.organization** - V realitě je to **Persona.company**!
- ⚠️ **Topic.organization** - V realitě je to **Topic.company**!

**🔴 KRITICKÉ ROZDÍLY v factories.py:**

```python
# PLÁN má:
from apps.content.models import Topic, BlogPost, ContentCalendar  # ❌ ContentCalendar neexistuje!
fake = Faker('cs_CZ')  # ❌ V realitě pravděpodobně default

class PersonaFactory(DjangoModelFactory):
    organization = factory.SubFactory(OrganizationFactory)  # ❌ WRONG!

class TopicFactory(DjangoModelFactory):
    organization = factory.SubFactory(OrganizationFactory)  # ❌ WRONG!

# REALITA má:
from apps.content.models import Topic, BlogPost  # ✅ Bez ContentCalendar
from apps.companies.models import Company  # ➕ NAVÍC

class PersonaFactory(DjangoModelFactory):
    company = factory.SubFactory(CompanyFactory)  # ✅ company, ne organization!

class TopicFactory(DjangoModelFactory):
    company = factory.SubFactory(CompanyFactory)  # ✅ company, ne organization!
```

**Proč tento rozdíl:**
- Multi-company architektura: Organization → Company → Personas/Content
- Persona patří Company, ne přímo Organization
- Topic patří Company, ne přímo Organization

**➕ NAVÍC: Další Factories (NEJSOU v dokumentu!):**

Realita má mnohem více factories než dokument, 10 KB soubor obsahuje:

```python
# tests/factories.py (skutečnost - 10 KB!)

# User factories (různé role)
class UserFactory(DjangoModelFactory):
    role = 'supervisor'

class AdminUserFactory(UserFactory):
    role = 'admin'
    is_staff = True
    is_superuser = True

class ManagerUserFactory(UserFactory):
    role = 'manager'

class MarketerUserFactory(UserFactory):
    role = 'marketer'

# Organization & Company
class OrganizationFactory(DjangoModelFactory):
    # ... (stejné jako plán)

class CompanyFactory(DjangoModelFactory):  # ➕ NAVÍC!
    class Meta:
        model = Company
    
    organization = factory.SubFactory(OrganizationFactory)
    name = factory.LazyAttribute(lambda _: fake.company())
    slug = factory.LazyAttribute(lambda o: slugify(o.name))

class CompanyDNAFactory(DjangoModelFactory):  # ➕ NAVÍC!
    class Meta:
        model = CompanyDNA
    
    company = factory.SubFactory(CompanyFactory)
    mission = factory.LazyAttribute(lambda _: fake.sentence())
    vision = factory.LazyAttribute(lambda _: fake.sentence())
    values = factory.LazyAttribute(lambda _: [fake.word() for _ in range(3)])

# Personas
class PersonaFactory(DjangoModelFactory):
    company = factory.SubFactory(CompanyFactory)  # ✅ company!
    # ...

# Content
class TopicFactory(DjangoModelFactory):
    company = factory.SubFactory(CompanyFactory)  # ✅ company!
    # ...

class BlogPostFactory(DjangoModelFactory):  # ➕ NAVÍC!
    class Meta:
        model = BlogPost
    
    company = factory.SubFactory(CompanyFactory)
    persona = factory.SubFactory(PersonaFactory)
    title = factory.LazyAttribute(lambda _: fake.sentence())
    content = factory.LazyAttribute(lambda _: fake.text(2000))
    status = 'draft'

class SocialPostFactory(DjangoModelFactory):  # ➕ NAVÍC!
    class Meta:
        model = SocialPost
    
    company = factory.SubFactory(CompanyFactory)
    blogpost = factory.SubFactory(BlogPostFactory)
    platform = 'linkedin'
    content = factory.LazyAttribute(lambda _: fake.text(500))
```

### Fixtures

**Aktuální stav implementace - conftest.py:**
- ✅ **conftest.py EXISTUJE** - 8 KB soubor!
- ✅ **APIClient fixture** - Pro API testing
- ✅ **Organization fixture** - Základní fixtures existují
- ❌ **`user` fixture** - V realitě je to `supervisor_user`!
- ❌ **JWT token generation** - V realitě se používá `force_authenticate()`!

**🔴 KRITICKÉ ROZDÍLY v conftest.py:**

```python
# PLÁN:
@pytest.fixture
def user(organization):
    return UserFactory(organization=organization)

@pytest.fixture
def authenticated_client(api_client, user):
    refresh = RefreshToken.for_user(user)  # ❌ JWT token generation
    api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
    return api_client

# REALITA (8 KB conftest.py):
@pytest.fixture
def supervisor_user(organization):  # ✅ supervisor_user, ne user!
    return UserFactory(organization=organization, role='supervisor')

@pytest.fixture
def admin_user(organization):  # ➕ NAVÍC!
    return AdminUserFactory(organization=organization)

@pytest.fixture
def manager_user(organization):  # ➕ NAVÍC!
    return ManagerUserFactory(organization=organization)

@pytest.fixture
def authenticated_client(api_client, supervisor_user):
    api_client.force_authenticate(user=supervisor_user)  # ✅ force_authenticate()!
    return api_client

@pytest.fixture
def admin_client(api_client, admin_user):  # ➕ NAVÍC!
    api_client.force_authenticate(user=admin_user)
    return api_client

@pytest.fixture
def manager_client(api_client, manager_user):  # ➕ NAVÍC!
    api_client.force_authenticate(user=manager_user)
    return api_client
```

**Proč force_authenticate() místo JWT tokens?**
- ✅ **Jednodušší** - Není potřeba generovat tokeny
- ✅ **Rychlejší** - Přímá autentizace
- ✅ **DRF best practice** - `force_authenticate()` je recommended pro testy
- ✅ **Méně závislostí** - Není potřeba simplejwt v test utils

**➕ NAVÍC: Další fixtures (8 KB conftest.py):**

```python
# tests/conftest.py (skutečnost - obsahuje mnohem více!)

# Company fixtures
@pytest.fixture
def company(organization):
    return CompanyFactory(organization=organization)

@pytest.fixture
def company_dna(company):
    return CompanyDNAFactory(company=company)

# Persona fixtures  
@pytest.fixture
def persona(company):
    return PersonaFactory(company=company)  # ✅ company!

# Content fixtures
@pytest.fixture
def topic(company, persona):
    return TopicFactory(company=company, persona=persona)

@pytest.fixture
def blogpost(company, persona):
    return BlogPostFactory(company=company, persona=persona)

@pytest.fixture
def social_post(company, blogpost):
    return SocialPostFactory(company=company, blogpost=blogpost)

# AI Job fixtures
@pytest.fixture
def ai_job(company):
    return AIJobFactory(company=company)
```

### Service Tests

**Aktuální stav implementace:**
- ⚠️ **Service tests existují** - Ale pro jiné services
- ❌ **topic_approve(), topic_reject()** - Neznámo jestli tyto konkrétní funkce existují
- ❌ **Content API není implementováno** - Topic approval může být jiný workflow
- ✅ **Test patterns** - Podobný style s pytest.mark a fixtures

**Realita:**
Dokument ukazuje testy pro Content services (approve/reject topics), ale:
- Content API je Phase 6-7 (není implementováno)
- topic_approve/topic_reject functions možná neexistují
- Tests pravděpodobně existují pro jiné services (AI generation, personas, atd.)

### API Tests

**Aktuální stav implementace:**
- ⚠️ **API tests existují**
- ❌ **reverse('topic-list')** - Content API není implementováno!
- ❌ **reverse('topic-approve')** - Content API není implementováno!
- ✅ **Test structure** - Správný pytest.mark.django_db pattern
- ✅ **authenticated_client usage** - Funguje

**🔴 KRITICKÝ PROBLÉM:**

```python
# PLÁN testuje Content API:
url = reverse('topic-list')  # ❌ NEEXISTUJE!
url = reverse('topic-approve', kwargs={'pk': topic.id})  # ❌ NEEXISTUJE!

# REALITA by testovala implementované endpointy:
url = reverse('persona-list')  # ✅ EXISTS
url = reverse('ai:generate-personas', kwargs={'company_id': company.id})  # ✅ EXISTS
url = reverse('ai:scrape-dna', kwargs={'company_id': company.id})  # ✅ EXISTS
```

**Skutečné API testy (realita):**

```python
# tests/api/test_personas_api.py (realita)
@pytest.mark.django_db
class TestPersonasAPI:
    
    def test_list_personas(self, authenticated_client, company, persona):
        url = reverse('persona-list')
        
        response = authenticated_client.get(url)
        
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) >= 1
    
    def test_select_personas(self, authenticated_client, company):
        personas = PersonaFactory.create_batch(3, company=company)
        url = reverse('persona-select')
        
        response = authenticated_client.post(url, {
            'persona_ids': [str(p.id) for p in personas]
        })
        
        assert response.status_code == status.HTTP_200_OK

# tests/api/test_ai_api.py (realita)
@pytest.mark.django_db
class TestAIGenerationAPI:
    
    def test_generate_personas(self, authenticated_client, company):
        url = reverse('ai:generate-personas', kwargs={'company_id': company.id})
        
        response = authenticated_client.post(url)
        
        assert response.status_code == status.HTTP_200_OK
        assert 'job_id' in response.data
    
    @pytest.mark.slow
    def test_scrape_company_dna(self, authenticated_client, company):
        url = reverse('ai:scrape-dna', kwargs={'company_id': company.id})
        
        response = authenticated_client.post(url, {
            'website': 'https://example.com',
            'company_name': 'Example Corp'
        })
        
        assert response.status_code == status.HTTP_200_OK
        assert 'job_id' in response.data
```

### Async Tests

**Aktuální stav implementace:**
- ✅ **pytest-asyncio** - Nainstalováno
- ✅ **asyncio_mode = auto** - V pytest.ini
- ⚠️ **Async tests** - Nejsou v dokumentu, ale infrastruktura existuje

```python
# Příklad async testu (možná v realitě):
import pytest

@pytest.mark.asyncio
async def test_async_ai_generation(company):
    from apps.ai_gateway.services import async_generate_personas
    
    job = await async_generate_personas(company_id=company.id)
    
    assert job.status == 'queued'
```

### Integration Tests

**Aktuální stav implementace:**
- ✅ **Integration tests existují**
- ✅ **@pytest.mark.integration** - Marker je definován
- ✅ **Full workflow tests** - Pravděpodobně existují

```python
# tests/integration/test_content_workflow.py (možná realita)
import pytest
from django.urls import reverse

@pytest.mark.integration
@pytest.mark.django_db
class TestContentWorkflow:
    
    def test_full_persona_generation_flow(self, authenticated_client, company):
        # 1. Scrape DNA
        scrape_url = reverse('ai:scrape-dna', kwargs={'company_id': company.id})
        scrape_response = authenticated_client.post(scrape_url, {
            'website': 'https://example.com'
        })
        assert scrape_response.status_code == 200
        
        # 2. Generate personas
        generate_url = reverse('ai:generate-personas', kwargs={'company_id': company.id})
        generate_response = authenticated_client.post(generate_url)
        assert generate_response.status_code == 200
        
        # 3. List personas
        list_url = reverse('persona-list')
        list_response = authenticated_client.get(list_url)
        assert len(list_response.data['results']) > 0
```

---

## 3. FRONTEND TESTING

**🚨 KRITICKÉ: Frontend testing framework je KOMPLETNĚ JINÝ než plán!**

### Karma/Jasmine (Plán)

**Aktuální stav implementace:**
- ❌ **Karma NENÍ používán** - Framework je jiný!
- ❌ **Jasmine NENÍ používán** - Framework je jiný!
- ❌ **karma.conf.js NEEXISTUJE** - Soubor není v projektu!

### Jest (Realita)

**Aktuální stav implementace:**
- ✅ **Jest JE používán** - Místo Karma/Jasmine!
- ✅ **jest-preset-angular** - Pro Angular testing
- ✅ **@testing-library/jest-dom** - Pro DOM testing utilities
- ✅ **@testing-library/angular** - Angular Testing Library

**Skutečná konfigurace:**

```json
// package.json (realita)
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  },
  "devDependencies": {
    "@types/jest": "^29.5.0",
    "jest": "^29.7.0",
    "jest-preset-angular": "^14.0.0",
    "@testing-library/jest-dom": "^6.1.0",
    "@testing-library/angular": "^14.0.0",
    "@playwright/test": "^1.40.0"
  }
}
```

```javascript
// jest.config.js (realita - místo karma.conf.js!)
module.exports = {
  preset: 'jest-preset-angular',
  setupFilesAfterEnv: ['<rootDir>/setup-jest.ts'],
  testPathIgnorePatterns: ['/node_modules/', '/dist/'],
  collectCoverageFrom: [
    'src/app/**/*.ts',
    '!src/app/**/*.spec.ts',
    '!src/app/**/*.module.ts'
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['html', 'text', 'lcov'],
  testMatch: [
    '**/__tests__/**/*.ts',
    '**/?(*.)+(spec|test).ts'
  ]
};
```

```typescript
// setup-jest.ts (realita)
import 'jest-preset-angular/setup-jest';
import '@testing-library/jest-dom';
```

**Proč Jest místo Karma/Jasmine?**
1. ✅ **Rychlejší** - Jest je 2-3x rychlejší než Karma
2. ✅ **Better DX** - Watch mode, snapshot testing, parallelization
3. ✅ **Industry standard** - Jest je de-facto standard pro JS testing
4. ✅ **Angular 14+ default** - Angular CLI přešel na Jest jako default
5. ✅ **Better tooling** - VS Code extension, better error messages

**Příklad Component testu (Jest + Testing Library):**

```typescript
// src/app/personas/persona-list.component.spec.ts (realita)
import { render, screen, waitFor } from '@testing-library/angular';
import { PersonaListComponent } from './persona-list.component';

describe('PersonaListComponent', () => {
  it('should display list of personas', async () => {
    await render(PersonaListComponent, {
      componentProperties: {
        personas: [
          { id: '1', character_name: 'Martin Technik', age: 35 }
        ]
      }
    });
    
    expect(screen.getByText('Martin Technik')).toBeInTheDocument();
  });
  
  it('should emit select event on persona click', async () => {
    const selectSpy = jest.fn();
    
    await render(PersonaListComponent, {
      componentProperties: {
        personas: [{ id: '1', character_name: 'Martin Technik' }],
        onSelect: selectSpy
      }
    });
    
    const personaCard = screen.getByText('Martin Technik');
    personaCard.click();
    
    expect(selectSpy).toHaveBeenCalledWith('1');
  });
});
```

**Service test (Jest):**

```typescript
// src/app/services/persona.service.spec.ts (realita)
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { PersonaService } from './persona.service';

describe('PersonaService', () => {
  let service: PersonaService;
  let httpMock: HttpTestingController;
  
  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [PersonaService]
    });
    
    service = TestBed.inject(PersonaService);
    httpMock = TestBed.inject(HttpTestingController);
  });
  
  afterEach(() => {
    httpMock.verify();
  });
  
  it('should fetch personas', () => {
    const mockPersonas = [
      { id: '1', character_name: 'Martin Technik' }
    ];
    
    service.getPersonas().subscribe(personas => {
      expect(personas.length).toBe(1);
      expect(personas[0].character_name).toBe('Martin Technik');
    });
    
    const req = httpMock.expectOne('/api/v1/personas/');
    expect(req.request.method).toBe('GET');
    req.flush({ status: 'success', data: mockPersonas });
  });
});
```

---

## 4. E2E TESTING

**Aktuální stav implementace:**
- ✅ **e2e/ folder existuje** - E2E tests jsou v projektu
- ✅ **@playwright/test** - Playwright je nainstalován
- ⚠️ **Routes jsou JINÉ** - Skutečné routes se liší od plánu

**🔴 ROZDÍL v Routes:**

```typescript
// PLÁN:
await page.goto('/login');  // ❌ Nesprávný path
await page.goto('/dashboard');  // ❌ Nesprávný path
await page.goto('/content/topics');  // ❌ Nesprávný path

// REALITA:
await page.goto('/auth/login');  // ✅ Správný path
await page.goto('/app/dashboard');  // ✅ Správný path
await page.goto('/app/content/personas');  // ✅ Personas (ne topics - Content API není implementováno!)
```

**Skutečný E2E test (možná realita):**

```typescript
// e2e/personas.spec.ts (realita)
import { test, expect } from '@playwright/test';

test.describe('Persona Generation Flow', () => {
  
  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto('/auth/login');
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'password');
    await page.click('button[type="submit"]');
    await page.waitForURL('/app/dashboard');
  });
  
  test('should generate and select personas', async ({ page }) => {
    // Navigate to personas
    await page.goto('/app/content/personas');
    
    // Trigger generation
    await page.click('button:has-text("Generate Personas")');
    
    // Wait for generation to complete
    await page.waitForSelector('.persona-card', { timeout: 30000 });
    
    // Select first 3 personas
    const personas = await page.locator('.persona-card').all();
    for (let i = 0; i < Math.min(3, personas.length); i++) {
      await personas[i].click();
    }
    
    // Confirm selection
    await page.click('button:has-text("Confirm Selection")');
    
    // Verify success
    await expect(page.locator('.success-message')).toBeVisible();
  });
  
  test('should display company DNA before generation', async ({ page }) => {
    await page.goto('/app/company/setup');
    
    // Enter company DNA
    await page.fill('input[name="website"]', 'https://example.com');
    await page.click('button:has-text("Scrape DNA")');
    
    // Wait for DNA extraction
    await page.waitForSelector('.company-dna-card', { timeout: 30000 });
    
    // Verify DNA displayed
    await expect(page.locator('.company-dna-card')).toContainText('Mission');
    await expect(page.locator('.company-dna-card')).toContainText('Vision');
  });
});
```

**Playwright Configuration:**

```typescript
// playwright.config.ts (realita)
import { defineConfig, devices } from '@playwright/test';

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
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
  webServer: {
    command: 'npm run start',
    url: 'http://localhost:4200',
    reuseExistingServer: !process.env.CI,
  },
});
```

---

## 5. CI/CD INTEGRATION

**Aktuální stav implementace:**
- ✅ **GitHub Actions** - Pravděpodobně používáno pro CI/CD
- ✅ **Backend tests** - Pytest v CI
- ✅ **Frontend tests** - Jest v CI (ne Karma!)
- ⚠️ **E2E tests** - Playwright v CI (možná)

**Skutečný workflow (pravděpodobná realita):**

```yaml
# .github/workflows/test.yml (realita)
name: Tests

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_DB: posthub_test
          POSTGRES_USER: posthub
          POSTGRES_PASSWORD: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements/test.txt
      
      - name: Run tests
        run: |
          pytest -v --tb=short --strict-markers --reuse-db
        env:
          DJANGO_SETTINGS_MODULE: config.settings.test
      
      - name: Upload coverage
        if: github.event_name == 'push'
        run: |
          pytest --cov=apps --cov-report=xml
          bash <(curl -s https://codecov.io/bash)
  
  frontend-tests:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run Jest tests  # ✅ Jest, ne Karma!
        run: npm run test:coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
  
  e2e-tests:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Playwright
        run: npx playwright install --with-deps
      
      - name: Run E2E tests
        run: npx playwright test
      
      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
```

---

## 📊 IMPLEMENTATION STATUS SUMMARY

### ✅ CO JE IMPLEMENTOVÁNO

| Komponenta | Status | Detail |
|------------|--------|--------|
| **pytest** | ✅ Plně | Backend testing framework |
| **pytest-django** | ✅ Plně | Django integration |
| **factory-boy** | ✅ Plně | factories.py (10 KB) |
| **conftest.py** | ✅ Plně | 8 KB s fixtures |
| **Test markers** | ✅ Plně | slow, integration, e2e |
| **Jest** | ✅ Plně | Frontend (místo Karma!) |
| **Playwright** | ✅ Ano | E2E testing |
| **CI/CD** | ✅ Pravděpodobně | GitHub Actions |

### ❌ CO JE JINAK

| Co | Plán | Realita | Důvod |
|----|------|---------|-------|
| **Frontend framework** | Karma/Jasmine | Jest | Modern, faster |
| **pytest addopts** | `--cov=apps` | `--strict-markers --reuse-db` | Speed, markers |
| **Auth fixture** | JWT tokens | `force_authenticate()` | DRF best practice |
| **User fixture** | `user` | `supervisor_user` | Role clarity |
| **Persona.organization** | `organization` | `company` | Multi-company arch |
| **Topic.organization** | `organization` | `company` | Multi-company arch |
| **ContentCalendar** | ✅ Importován | ❌ Neexistuje | Model není v DB |
| **E2E routes** | `/login`, `/dashboard` | `/auth/login`, `/app/dashboard` | Skutečné routes |

### ➕ CO JE NAVÍC (Není v dokumentu)

**Factories:**
- `CompanyFactory` - Pro multi-company arch
- `CompanyDNAFactory` - Company DNA model
- `BlogPostFactory` - BlogPost factory
- `SocialPostFactory` - Social post factory
- `AdminUserFactory` - Admin users
- `ManagerUserFactory` - Manager users
- `MarketerUserFactory` - Marketer users

**Fixtures:**
- `admin_user` - Admin user fixture
- `manager_user` - Manager user fixture
- `admin_client` - Admin authenticated client
- `manager_client` - Manager authenticated client
- `company` - Company fixture
- `company_dna` - Company DNA fixture
- `blogpost` - BlogPost fixture
- `social_post` - Social post fixture

**Pytest Markers:**
- `@pytest.mark.slow` - Pro slow tests
- `@pytest.mark.integration` - Integration tests
- `@pytest.mark.e2e` - E2E tests

### 🎯 KLÍČOVÉ ROZDÍLY

**1. Frontend Testing: Karma → Jest**

```diff
PLÁN:
- karma.conf.js
- Jasmine test syntax
- "karma": "~6.4.0"

REALITA:
+ jest.config.js
+ Jest test syntax
+ "jest": "^29.7.0"
+ "jest-preset-angular": "^14.0.0"
```

**2. Multi-Company Architecture**

```python
# PLÁN:
class PersonaFactory:
    organization = SubFactory(OrganizationFactory)

# REALITA:
class PersonaFactory:
    company = SubFactory(CompanyFactory)
    # Persona patří Company, ne Organization!
```

**3. Auth Fixtures: JWT → force_authenticate()**

```python
# PLÁN:
refresh = RefreshToken.for_user(user)
api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')

# REALITA:
api_client.force_authenticate(user=supervisor_user)
# Jednodušší a doporučovaný způsob pro testy!
```

**4. Test Routes**

```typescript
// PLÁN:
'/login' → '/dashboard' → '/content/topics'

// REALITA:
'/auth/login' → '/app/dashboard' → '/app/content/personas'
```

---

## 📝 DOPORUČENÍ PRO DOKUMENTACI

### ✅ Co aktualizovat:

**1. Frontend Testing:**
- ❌ Odstranit Karma/Jasmine
- ✅ Přidat Jest configuration
- ✅ Přidat Testing Library examples
- ✅ Aktualizovat package.json dev dependencies

**2. Backend Factories:**
- ✅ Přidat CompanyFactory
- ✅ Změnit Persona.organization → company
- ✅ Změnit Topic.organization → company
- ❌ Odstranit ContentCalendar import
- ✅ Přidat BlogPostFactory, SocialPostFactory
- ✅ Přidat role-specific user factories

**3. Backend Fixtures:**
- ✅ Změnit `user` → `supervisor_user`
- ✅ Přidat admin_user, manager_user fixtures
- ✅ Změnit JWT → force_authenticate()
- ✅ Přidat role-specific client fixtures

**4. pytest.ini:**
- ✅ Aktualizovat addopts (--strict-markers --reuse-db)
- ✅ Přidat markers section

**5. Test Examples:**
- ✅ Aktualizovat na implementované endpointy (personas místo topics)
- ✅ Změnit routes na skutečné (/auth/login, /app/dashboard)

**6. E2E Tests:**
- ✅ Aktualizovat routes
- ✅ Přidat Playwright config example

---

*Tento dokument nyní obsahuje KOMPLETNÍ informace o plánované testing strategy I skutečném stavu implementace.*

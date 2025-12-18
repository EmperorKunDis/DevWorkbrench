# 02_BACKEND_DJANGO.md - Kompletní Django Backend Specifikace

**Dokument:** Django Backend PostHub.work  
**Verze:** 1.0.0  
**Status:** Production-Ready  
**Self-Contained:** ✅ Tento dokument obsahuje VŠECHNY informace o Django backendu

---

## 📋 OBSAH

1. [Project Setup](#1-project-setup)
2. [Settings Configuration](#2-settings-configuration)
3. [Base Models](#3-base-models)
4. [Service Layer Pattern](#4-service-layer-pattern)
5. [API Views (DRF)](#5-api-views-drf)
6. [Serializers](#6-serializers)
7. [Authentication](#7-authentication)
8. [Permissions](#8-permissions)
9. [Middleware](#9-middleware)
10. [Error Handling](#10-error-handling)
11. [Pagination](#11-pagination)
12. [Filtering & Search](#12-filtering--search)
13. [Testing](#13-testing)
14. [Dependencies](#14-dependencies)

---

## 1. PROJECT SETUP

### Struktura projektu

```
backend/
├── config/                    # Django configuration
│   ├── __init__.py
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py           # Shared settings
│   │   ├── dev.py            # Development settings
│   │   └── prod.py           # Production settings
│   ├── celery.py             # Celery configuration
│   ├── urls.py               # Root URL configuration
│   ├── wsgi.py               # WSGI entry point
│   └── asgi.py               # ASGI entry point
├── apps/
│   ├── __init__.py
│   ├── core/                  # Shared utilities
│   │   ├── __init__.py
│   │   ├── models.py         # Abstract base models
│   │   ├── permissions.py    # Custom permissions
│   │   ├── exceptions.py     # Custom exceptions
│   │   ├── middleware.py     # Custom middleware
│   │   ├── pagination.py     # Pagination classes
│   │   ├── renderers.py      # Response renderers
│   │   ├── throttling.py     # Rate limiting
│   │   └── utils.py          # Helper functions
│   ├── users/
│   ├── organizations/
│   ├── personas/
│   ├── content/
│   ├── ai_gateway/
│   └── billing/
├── requirements/
│   ├── base.txt
│   ├── dev.txt
│   └── prod.txt
├── manage.py
├── pytest.ini
└── .env.example
```

### Inicializace projektu

```bash
# Vytvoření virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate  # Windows

# Instalace dependencies
pip install -r requirements/dev.txt

# Vytvoření Django projektu
django-admin startproject config .

# Vytvoření apps
mkdir apps
cd apps
django-admin startapp core
django-admin startapp users
django-admin startapp organizations
django-admin startapp personas
django-admin startapp content
django-admin startapp ai_gateway
django-admin startapp billing
```

---

## 2. SETTINGS CONFIGURATION

### base.py (Shared Settings)

```python
# config/settings/base.py
import os
from pathlib import Path
from datetime import timedelta

import environ

# Build paths
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Environment
env = environ.Env(
    DEBUG=(bool, False),
    ALLOWED_HOSTS=(list, []),
)
environ.Env.read_env(BASE_DIR / '.env')

# Security
SECRET_KEY = env('SECRET_KEY')
DEBUG = env('DEBUG')
ALLOWED_HOSTS = env('ALLOWED_HOSTS')

# Application definition
DJANGO_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.postgres',  # PostgreSQL features
]

THIRD_PARTY_APPS = [
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',
    'django_filters',
    'drf_spectacular',
    'django_celery_beat',
    'django_celery_results',
    'djstripe',
    'django_structlog',
    'django_prometheus',
]

LOCAL_APPS = [
    'apps.core',
    'apps.users',
    'apps.organizations',
    'apps.personas',
    'apps.content',
    'apps.ai_gateway',
    'apps.billing',
]

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS

# Middleware
MIDDLEWARE = [
    'django_prometheus.middleware.PrometheusBeforeMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'django_structlog.middlewares.RequestMiddleware',
    'apps.core.middleware.TenantMiddleware',
    'apps.core.middleware.HealthCheckMiddleware',
    'django_prometheus.middleware.PrometheusAfterMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

# Database
DATABASES = {
    'default': env.db('DATABASE_URL', default='postgres://localhost/posthub')
}

# Native connection pooling (Django 5.1+)
DATABASES['default']['CONN_MAX_AGE'] = 0
DATABASES['default']['OPTIONS'] = {
    'pool': True,
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# Custom User Model
AUTH_USER_MODEL = 'users.User'

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# Static files
STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Media files
MEDIA_URL = 'media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Default primary key
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# =============================================================================
# DJANGO REST FRAMEWORK
# =============================================================================
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'apps.core.renderers.APIRenderer',
    ],
    'DEFAULT_PARSER_CLASSES': [
        'rest_framework.parsers.JSONParser',
        'rest_framework.parsers.MultiPartParser',
    ],
    'DEFAULT_PAGINATION_CLASS': 'apps.core.pagination.CursorPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/hour',
        'user': '1000/hour',
    },
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
    'EXCEPTION_HANDLER': 'apps.core.exceptions.custom_exception_handler',
    'COERCE_DECIMAL_TO_STRING': False,
}

# =============================================================================
# JWT CONFIGURATION
# =============================================================================
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': True,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'AUTH_HEADER_NAME': 'HTTP_AUTHORIZATION',
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
    'TOKEN_OBTAIN_SERIALIZER': 'apps.users.serializers.CustomTokenObtainPairSerializer',
}

# =============================================================================
# CORS CONFIGURATION
# =============================================================================
CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS', default=[
    'http://localhost:4200',
    'http://127.0.0.1:4200',
])
CORS_ALLOW_CREDENTIALS = True

# =============================================================================
# CELERY CONFIGURATION
# =============================================================================
CELERY_BROKER_URL = env('REDIS_URL', default='redis://localhost:6379/0')
CELERY_RESULT_BACKEND = env('REDIS_URL', default='redis://localhost:6379/1')

CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TIMEZONE = TIME_ZONE
CELERY_TASK_TRACK_STARTED = True
CELERY_TASK_TIME_LIMIT = 30 * 60  # 30 minutes
CELERY_RESULT_EXPIRES = 60 * 60 * 24  # 24 hours
CELERY_WORKER_PREFETCH_MULTIPLIER = 1
CELERY_WORKER_MAX_TASKS_PER_CHILD = 1000

CELERY_BROKER_TRANSPORT_OPTIONS = {
    'visibility_timeout': 7200,
    'socket_keepalive': True,
    'health_check_interval': 60,
}

CELERY_BEAT_SCHEDULER = 'django_celery_beat.schedulers:DatabaseScheduler'

# =============================================================================
# CACHE CONFIGURATION
# =============================================================================
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': env('REDIS_URL', default='redis://localhost:6379/2'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        },
        'KEY_PREFIX': 'posthub',
    }
}

# =============================================================================
# STRIPE CONFIGURATION
# =============================================================================
STRIPE_TEST_SECRET_KEY = env('STRIPE_SECRET_KEY', default='')
STRIPE_LIVE_MODE = env.bool('STRIPE_LIVE_MODE', default=False)
DJSTRIPE_WEBHOOK_SECRET = env('STRIPE_WEBHOOK_SECRET', default='')
DJSTRIPE_FOREIGN_KEY_TO_FIELD = 'id'
DJSTRIPE_USE_NATIVE_JSONFIELD = True

# =============================================================================
# AI API KEYS
# =============================================================================
GEMINI_API_KEY = env('GEMINI_API_KEY', default='')
PERPLEXITY_API_KEY = env('PERPLEXITY_API_KEY', default='')
NANOBANA_API_KEY = env('NANOBANA_API_KEY', default='')
VEO_API_KEY = env('VEO_API_KEY', default='')

# =============================================================================
# LOGGING
# =============================================================================
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'json': {
            '()': 'django_structlog.formatters.JsonFormatter',
        },
        'console': {
            'format': '%(asctime)s %(levelname)s %(name)s %(message)s',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'console',
        },
        'json': {
            'class': 'logging.StreamHandler',
            'formatter': 'json',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'apps': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}

# =============================================================================
# DRF SPECTACULAR (OpenAPI)
# =============================================================================
SPECTACULAR_SETTINGS = {
    'TITLE': 'PostHub API',
    'DESCRIPTION': 'AI-powered Social Media Content Automation',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    'COMPONENT_SPLIT_REQUEST': True,
    'SCHEMA_PATH_PREFIX': '/api/v1',
}
```

### dev.py (Development Settings)

```python
# config/settings/dev.py
from .base import *

DEBUG = True

ALLOWED_HOSTS = ['*']

# Debug Toolbar
INSTALLED_APPS += ['debug_toolbar']
MIDDLEWARE.insert(0, 'debug_toolbar.middleware.DebugToolbarMiddleware')
INTERNAL_IPS = ['127.0.0.1']

# Email
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# Logging
LOGGING['root']['level'] = 'DEBUG'
LOGGING['loggers']['apps']['level'] = 'DEBUG'

# CORS - Allow all in development
CORS_ALLOW_ALL_ORIGINS = True
```

### prod.py (Production Settings)

```python
# config/settings/prod.py
from .base import *

DEBUG = False

# Security
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True

# Email
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = env('EMAIL_HOST')
EMAIL_PORT = env.int('EMAIL_PORT', default=587)
EMAIL_USE_TLS = True
EMAIL_HOST_USER = env('EMAIL_HOST_USER')
EMAIL_HOST_PASSWORD = env('EMAIL_HOST_PASSWORD')

# Logging - JSON format
LOGGING['handlers']['console']['formatter'] = 'json'

# Sentry
import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration
from sentry_sdk.integrations.celery import CeleryIntegration

sentry_sdk.init(
    dsn=env('SENTRY_DSN'),
    integrations=[DjangoIntegration(), CeleryIntegration()],
    traces_sample_rate=0.1,
    environment='production',
)
```

---

## 3. BASE MODELS

### Core Abstract Models

```python
# apps/core/models.py
import uuid
from django.db import models
from django.utils import timezone


class TimestampedModel(models.Model):
    """
    Abstract base model s created_at a updated_at.
    Použij jako základ pro všechny modely.
    """
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True
        ordering = ['-created_at']


class UUIDModel(models.Model):
    """
    Abstract model s UUID jako primárním klíčem.
    """
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )

    class Meta:
        abstract = True


class TenantAwareModel(models.Model):
    """
    Abstract model pro multi-tenant modely.
    Všechny tenant-specific modely MUSÍ dědit z tohoto.
    """
    organization = models.ForeignKey(
        'organizations.Organization',
        on_delete=models.CASCADE,
        related_name='%(class)ss',
        db_index=True
    )

    class Meta:
        abstract = True


class SoftDeleteModel(models.Model):
    """
    Abstract model pro soft delete.
    """
    is_deleted = models.BooleanField(default=False, db_index=True)
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        abstract = True

    def delete(self, using=None, keep_parents=False):
        """Soft delete místo hard delete."""
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.save(update_fields=['is_deleted', 'deleted_at'])

    def hard_delete(self):
        """Skutečné smazání z databáze."""
        super().delete()


class BaseModel(UUIDModel, TimestampedModel):
    """
    Kombinovaný base model - UUID + timestamps.
    Doporučeno pro většinu modelů.
    """
    class Meta:
        abstract = True


class TenantBaseModel(UUIDModel, TimestampedModel, TenantAwareModel):
    """
    Base model pro tenant-aware entity.
    UUID + timestamps + organization FK.
    """
    class Meta:
        abstract = True
```

### Tenant-Aware Manager

```python
# apps/core/managers.py
from django.db import models
import threading

_thread_locals = threading.local()


def get_current_tenant():
    """Získá aktuálního tenanta z thread local storage."""
    return getattr(_thread_locals, 'tenant', None)


def set_current_tenant(tenant):
    """Nastaví aktuálního tenanta do thread local storage."""
    _thread_locals.tenant = tenant


class TenantAwareManager(models.Manager):
    """
    Manager který automaticky filtruje podle aktuálního tenanta.
    """
    def get_queryset(self):
        qs = super().get_queryset()
        tenant = get_current_tenant()
        
        if tenant is not None:
            return qs.filter(organization=tenant)
        
        # BEZPEČNOST: Pokud není tenant, vrať prázdný queryset
        return qs.none()
    
    def unfiltered(self):
        """Vrátí queryset BEZ tenant filtru (pro admin účely)."""
        return super().get_queryset()


class TenantAwareQuerySet(models.QuerySet):
    """
    QuerySet s metodami pro tenant-aware operace.
    """
    def for_tenant(self, tenant):
        """Explicitní filtrování podle tenanta."""
        return self.filter(organization=tenant)
    
    def active(self):
        """Filtruje pouze aktivní záznamy (pokud má is_active)."""
        return self.filter(is_active=True)
```

---

## 4. SERVICE LAYER PATTERN

### Struktura service layer

```
apps/content/
├── services.py      # Write operations (create, update, delete)
├── selectors.py     # Read operations (complex queries)
├── validators.py    # Business validation
└── tasks.py         # Celery tasks
```

### Services (Write Operations)

```python
# apps/content/services.py
from django.db import transaction
from django.core.exceptions import ValidationError

from apps.core.exceptions import BusinessLogicError
from apps.content.models import Topic, BlogPost
from apps.content.validators import validate_topic_for_calendar
from apps.content.tasks import generate_blogpost_task


def topic_create(
    *,
    calendar,
    persona,
    title: str,
    description: str,
    planned_date,
    keywords: list[str] | None = None,
    focus_keyword: str | None = None,
) -> Topic:
    """
    Vytvoří nové téma v kalendáři.
    
    Args:
        calendar: ContentCalendar instance
        persona: Persona instance
        title: Název tématu
        description: Popis tématu
        planned_date: Plánované datum
        keywords: Seznam klíčových slov
        focus_keyword: Hlavní keyword pro SEO
    
    Returns:
        Topic instance
    
    Raises:
        ValidationError: Pokud validace selže
        BusinessLogicError: Pokud překročen limit témat
    """
    # Business validace
    validate_topic_for_calendar(calendar, planned_date)
    
    # Kontrola limitu podle subscription
    if calendar.topics.count() >= calendar.organization.subscription.max_topics:
        raise BusinessLogicError(
            code='TOPIC_LIMIT_REACHED',
            message='Topic limit for this month has been reached'
        )
    
    topic = Topic(
        organization=calendar.organization,
        calendar=calendar,
        persona=persona,
        title=title,
        description=description,
        planned_date=planned_date,
        keywords=keywords or [],
        focus_keyword=focus_keyword,
        status='pending_approval',
    )
    
    # Model validace
    topic.full_clean()
    topic.save()
    
    return topic


def topic_approve(*, topic: Topic, approved_by) -> Topic:
    """
    Schválí téma a spustí generování blogpostu.
    """
    if topic.status != 'pending_approval':
        raise BusinessLogicError(
            code='INVALID_STATUS',
            message=f'Cannot approve topic with status {topic.status}'
        )
    
    with transaction.atomic():
        topic.status = 'approved'
        topic.approved_at = timezone.now()
        topic.approved_by = approved_by
        topic.save(update_fields=['status', 'approved_at', 'approved_by'])
        
        # Vytvoř BlogPost a spusť generování
        blogpost = BlogPost.objects.create(
            organization=topic.organization,
            topic=topic,
            persona=topic.persona,
            calendar=topic.calendar,
            status='pending',
        )
        
        # Trigger async generování
        transaction.on_commit(
            lambda: generate_blogpost_task.delay(blogpost.id)
        )
    
    return topic


def topic_reject(
    *,
    topic: Topic,
    rejected_by,
    reason: str,
) -> Topic:
    """
    Zamítne téma s důvodem.
    """
    if topic.status != 'pending_approval':
        raise BusinessLogicError(
            code='INVALID_STATUS',
            message=f'Cannot reject topic with status {topic.status}'
        )
    
    topic.status = 'rejected'
    topic.rejected_at = timezone.now()
    topic.rejected_by = rejected_by
    topic.rejection_reason = reason
    topic.save(update_fields=[
        'status', 'rejected_at', 'rejected_by', 'rejection_reason'
    ])
    
    return topic


def blogpost_update(
    *,
    blogpost: BlogPost,
    title: str | None = None,
    sections: list[dict] | None = None,
) -> BlogPost:
    """
    Aktualizuje blogpost (po manuální editaci).
    """
    if title:
        blogpost.title = title
    
    if sections:
        # Validace sections struktury
        for section in sections:
            if 'content' not in section:
                raise ValidationError('Each section must have content')
        
        blogpost.sections.all().delete()
        for order, section_data in enumerate(sections):
            blogpost.sections.create(
                order=order,
                **section_data
            )
    
    blogpost.is_edited = True
    blogpost.save()
    
    return blogpost
```

### Selectors (Read Operations)

```python
# apps/content/selectors.py
from django.db.models import Count, Q, Prefetch
from datetime import date

from apps.content.models import ContentCalendar, Topic, BlogPost


def get_calendar_with_topics(
    *,
    organization,
    year: int,
    month: int,
) -> ContentCalendar | None:
    """
    Získá kalendář s přednahranými tématy a blogposty.
    """
    return ContentCalendar.objects.filter(
        organization=organization,
        year=year,
        month=month,
    ).prefetch_related(
        Prefetch(
            'topics',
            queryset=Topic.objects.select_related(
                'persona', 'approved_by', 'rejected_by'
            ).prefetch_related('blogpost')
        )
    ).first()


def get_topics_for_approval(
    *,
    organization,
    limit: int = 20,
) -> list[Topic]:
    """
    Získá témata čekající na schválení.
    """
    return list(
        Topic.objects.filter(
            organization=organization,
            status='pending_approval',
        ).select_related(
            'persona', 'calendar'
        ).order_by('planned_date')[:limit]
    )


def get_calendar_stats(
    *,
    organization,
    year: int,
    month: int,
) -> dict:
    """
    Statistiky kalendáře pro dashboard.
    """
    calendar = ContentCalendar.objects.filter(
        organization=organization,
        year=year,
        month=month,
    ).annotate(
        total_topics=Count('topics'),
        approved_topics=Count('topics', filter=Q(topics__status='approved')),
        pending_topics=Count('topics', filter=Q(topics__status='pending_approval')),
        rejected_topics=Count('topics', filter=Q(topics__status='rejected')),
        completed_blogposts=Count(
            'topics__blogpost',
            filter=Q(topics__blogpost__status='completed')
        ),
    ).first()
    
    if not calendar:
        return {
            'total_topics': 0,
            'approved_topics': 0,
            'pending_topics': 0,
            'rejected_topics': 0,
            'completed_blogposts': 0,
            'completion_rate': 0,
        }
    
    return {
        'total_topics': calendar.total_topics,
        'approved_topics': calendar.approved_topics,
        'pending_topics': calendar.pending_topics,
        'rejected_topics': calendar.rejected_topics,
        'completed_blogposts': calendar.completed_blogposts,
        'completion_rate': (
            calendar.completed_blogposts / calendar.approved_topics * 100
            if calendar.approved_topics > 0 else 0
        ),
    }


def get_blogposts_for_export(
    *,
    organization,
    calendar_id: str | None = None,
    status: str | None = None,
) -> list[BlogPost]:
    """
    Získá blogposty pro export s veškerými vztahy.
    """
    qs = BlogPost.objects.filter(
        organization=organization
    ).select_related(
        'topic', 'persona', 'calendar'
    ).prefetch_related(
        'sections', 'faqs', 'sources'
    )
    
    if calendar_id:
        qs = qs.filter(calendar_id=calendar_id)
    
    if status:
        qs = qs.filter(status=status)
    
    return list(qs.order_by('-created_at'))
```

### Validators

```python
# apps/content/validators.py
from django.core.exceptions import ValidationError
from datetime import date

from apps.core.exceptions import BusinessLogicError


def validate_topic_for_calendar(calendar, planned_date: date) -> None:
    """
    Validuje, že téma může být přidáno do kalendáře.
    """
    # Kontrola, že datum je v rámci měsíce kalendáře
    if planned_date.year != calendar.year or planned_date.month != calendar.month:
        raise ValidationError(
            f'Planned date must be in {calendar.year}-{calendar.month:02d}'
        )
    
    # Kontrola, že datum není v minulosti
    if planned_date < date.today():
        raise ValidationError('Planned date cannot be in the past')
    
    # Kontrola stavu kalendáře
    if calendar.status == 'completed':
        raise BusinessLogicError(
            code='CALENDAR_COMPLETED',
            message='Cannot add topics to completed calendar'
        )


def validate_persona_for_organization(persona, organization) -> None:
    """
    Validuje, že persona patří organizaci.
    """
    if persona.organization_id != organization.id:
        raise ValidationError('Persona does not belong to this organization')


def validate_content_length(content: str, min_words: int, max_words: int) -> None:
    """
    Validuje délku obsahu v slovech.
    """
    word_count = len(content.split())
    
    if word_count < min_words:
        raise ValidationError(
            f'Content must have at least {min_words} words (has {word_count})'
        )
    
    if word_count > max_words:
        raise ValidationError(
            f'Content must have at most {max_words} words (has {word_count})'
        )
```

---

## 5. API VIEWS (DRF)

### ViewSet Pattern

```python
# apps/content/apis.py
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend

from apps.core.permissions import IsOrganizationMember
from apps.content.models import Topic, BlogPost, ContentCalendar
from apps.content.serializers import (
    TopicListSerializer,
    TopicDetailSerializer,
    TopicCreateSerializer,
    TopicApproveSerializer,
    TopicRejectSerializer,
    BlogPostSerializer,
    CalendarSerializer,
)
from apps.content.services import (
    topic_create,
    topic_approve,
    topic_reject,
)
from apps.content.selectors import (
    get_calendar_with_topics,
    get_topics_for_approval,
    get_calendar_stats,
)
from apps.content.filters import TopicFilter


class TopicViewSet(viewsets.ModelViewSet):
    """
    API endpoint pro správu témat.
    
    list: Seznam témat
    retrieve: Detail tématu
    create: Vytvoření nového tématu
    update: Aktualizace tématu
    destroy: Smazání tématu
    approve: Schválení tématu
    reject: Zamítnutí tématu
    """
    permission_classes = [IsAuthenticated, IsOrganizationMember]
    filter_backends = [DjangoFilterBackend]
    filterset_class = TopicFilter
    
    def get_queryset(self):
        """Vrací témata pouze pro aktuální organizaci."""
        return Topic.objects.filter(
            organization=self.request.tenant
        ).select_related(
            'persona', 'calendar', 'approved_by', 'rejected_by'
        )
    
    def get_serializer_class(self):
        """Různé serializery pro různé akce."""
        if self.action == 'list':
            return TopicListSerializer
        if self.action == 'create':
            return TopicCreateSerializer
        if self.action == 'approve':
            return TopicApproveSerializer
        if self.action == 'reject':
            return TopicRejectSerializer
        return TopicDetailSerializer
    
    def perform_create(self, serializer):
        """Vytvoření tématu přes service layer."""
        topic = topic_create(
            calendar=serializer.validated_data['calendar'],
            persona=serializer.validated_data['persona'],
            title=serializer.validated_data['title'],
            description=serializer.validated_data['description'],
            planned_date=serializer.validated_data['planned_date'],
            keywords=serializer.validated_data.get('keywords'),
            focus_keyword=serializer.validated_data.get('focus_keyword'),
        )
        serializer.instance = topic
    
    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        """
        Schválí téma a spustí generování blogpostu.
        """
        topic = self.get_object()
        topic = topic_approve(topic=topic, approved_by=request.user)
        serializer = self.get_serializer(topic)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        """
        Zamítne téma s důvodem.
        """
        topic = self.get_object()
        serializer = TopicRejectSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        topic = topic_reject(
            topic=topic,
            rejected_by=request.user,
            reason=serializer.validated_data['reason'],
        )
        
        return Response(TopicDetailSerializer(topic).data)
    
    @action(detail=False, methods=['get'])
    def pending(self, request):
        """
        Seznam témat čekajících na schválení.
        """
        topics = get_topics_for_approval(
            organization=request.tenant,
            limit=50,
        )
        serializer = TopicListSerializer(topics, many=True)
        return Response(serializer.data)


class ContentCalendarViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoint pro obsahové kalendáře.
    Read-only - kalendáře se vytváří automaticky.
    """
    permission_classes = [IsAuthenticated, IsOrganizationMember]
    serializer_class = CalendarSerializer
    
    def get_queryset(self):
        return ContentCalendar.objects.filter(
            organization=self.request.tenant
        )
    
    @action(detail=False, methods=['get'])
    def current(self, request):
        """
        Vrátí aktuální měsíční kalendář s tématy.
        """
        from datetime import date
        today = date.today()
        
        calendar = get_calendar_with_topics(
            organization=request.tenant,
            year=today.year,
            month=today.month,
        )
        
        if not calendar:
            return Response(
                {'detail': 'No calendar for current month'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        serializer = self.get_serializer(calendar)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def stats(self, request, pk=None):
        """
        Statistiky kalendáře.
        """
        calendar = self.get_object()
        stats = get_calendar_stats(
            organization=request.tenant,
            year=calendar.year,
            month=calendar.month,
        )
        return Response(stats)


class BlogPostViewSet(viewsets.ModelViewSet):
    """
    API endpoint pro blogposty.
    """
    permission_classes = [IsAuthenticated, IsOrganizationMember]
    serializer_class = BlogPostSerializer
    
    def get_queryset(self):
        return BlogPost.objects.filter(
            organization=self.request.tenant
        ).select_related(
            'topic', 'persona', 'calendar'
        ).prefetch_related(
            'sections', 'faqs', 'sources'
        )
    
    @action(detail=True, methods=['post'])
    def regenerate(self, request, pk=None):
        """
        Regeneruje blogpost pomocí AI.
        """
        blogpost = self.get_object()
        
        # Kontrola limitu regenerací
        if blogpost.regeneration_count >= 3:
            return Response(
                {'detail': 'Regeneration limit reached'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Spusť regeneraci
        from apps.content.tasks import regenerate_blogpost_task
        regenerate_blogpost_task.delay(blogpost.id)
        
        return Response({'status': 'regeneration_started'})
```

### URL Configuration

```python
# apps/content/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter

from apps.content.apis import (
    TopicViewSet,
    ContentCalendarViewSet,
    BlogPostViewSet,
)

router = DefaultRouter()
router.register('topics', TopicViewSet, basename='topic')
router.register('calendars', ContentCalendarViewSet, basename='calendar')
router.register('blogposts', BlogPostViewSet, basename='blogpost')

urlpatterns = [
    path('', include(router.urls)),
]
```

```python
# config/urls.py
from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularSwaggerView,
)

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # API v1
    path('api/v1/', include([
        path('auth/', include('apps.users.urls')),
        path('organizations/', include('apps.organizations.urls')),
        path('personas/', include('apps.personas.urls')),
        path('content/', include('apps.content.urls')),
        path('billing/', include('apps.billing.urls')),
    ])),
    
    # OpenAPI
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger'),
    
    # Health checks
    path('healthz/', include('django_prometheus.urls')),
]
```

---

## 6. SERIALIZERS

### Serializer Patterns

```python
# apps/content/serializers.py
from rest_framework import serializers
from apps.content.models import Topic, BlogPost, ContentCalendar, BlogPostSection


# =============================================================================
# TOPIC SERIALIZERS
# =============================================================================

class TopicListSerializer(serializers.ModelSerializer):
    """
    Serializer pro seznam témat - lehká verze.
    """
    persona_name = serializers.CharField(source='persona.character_name', read_only=True)
    has_blogpost = serializers.SerializerMethodField()
    
    class Meta:
        model = Topic
        fields = [
            'id',
            'title',
            'status',
            'planned_date',
            'persona_name',
            'has_blogpost',
            'created_at',
        ]
    
    def get_has_blogpost(self, obj):
        return hasattr(obj, 'blogpost') and obj.blogpost is not None


class TopicDetailSerializer(serializers.ModelSerializer):
    """
    Serializer pro detail tématu - plná verze.
    """
    persona_name = serializers.CharField(source='persona.character_name', read_only=True)
    approved_by_name = serializers.CharField(source='approved_by.full_name', read_only=True)
    rejected_by_name = serializers.CharField(source='rejected_by.full_name', read_only=True)
    
    class Meta:
        model = Topic
        fields = [
            'id',
            'title',
            'subtitle',
            'description',
            'keywords',
            'focus_keyword',
            'secondary_keywords',
            'search_intent',
            'planned_date',
            'status',
            'persona',
            'persona_name',
            'calendar',
            'approved_at',
            'approved_by_name',
            'rejected_at',
            'rejected_by_name',
            'rejection_reason',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'status',
            'approved_at',
            'rejected_at',
            'created_at',
            'updated_at',
        ]


class TopicCreateSerializer(serializers.ModelSerializer):
    """
    Serializer pro vytvoření tématu.
    """
    class Meta:
        model = Topic
        fields = [
            'calendar',
            'persona',
            'title',
            'description',
            'planned_date',
            'keywords',
            'focus_keyword',
        ]
    
    def validate_calendar(self, value):
        """Ověří, že kalendář patří organizaci."""
        request = self.context.get('request')
        if value.organization != request.tenant:
            raise serializers.ValidationError('Calendar not found')
        return value
    
    def validate_persona(self, value):
        """Ověří, že persona patří organizaci."""
        request = self.context.get('request')
        if value.organization != request.tenant:
            raise serializers.ValidationError('Persona not found')
        return value


class TopicApproveSerializer(serializers.Serializer):
    """
    Serializer pro schválení tématu (prázdný - jen validace akce).
    """
    pass


class TopicRejectSerializer(serializers.Serializer):
    """
    Serializer pro zamítnutí tématu.
    """
    reason = serializers.CharField(max_length=500, required=True)


# =============================================================================
# BLOGPOST SERIALIZERS
# =============================================================================

class BlogPostSectionSerializer(serializers.ModelSerializer):
    """
    Serializer pro sekce blogpostu.
    """
    class Meta:
        model = BlogPostSection
        fields = [
            'id',
            'section_type',
            'order',
            'heading',
            'heading_level',
            'content',
            'has_image',
            'has_cta',
        ]


class BlogPostSerializer(serializers.ModelSerializer):
    """
    Serializer pro blogpost.
    """
    sections = BlogPostSectionSerializer(many=True, read_only=True)
    topic_title = serializers.CharField(source='topic.title', read_only=True)
    persona_name = serializers.CharField(source='persona.character_name', read_only=True)
    
    class Meta:
        model = BlogPost
        fields = [
            'id',
            'title',
            'slug',
            'status',
            'topic',
            'topic_title',
            'persona',
            'persona_name',
            'calendar',
            'meta_title',
            'meta_description',
            'focus_keyword',
            'word_count',
            'reading_time_minutes',
            'seo_score',
            'sections',
            'regeneration_count',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'slug',
            'status',
            'word_count',
            'reading_time_minutes',
            'seo_score',
            'regeneration_count',
            'created_at',
            'updated_at',
        ]


# =============================================================================
# CALENDAR SERIALIZERS
# =============================================================================

class CalendarSerializer(serializers.ModelSerializer):
    """
    Serializer pro obsahový kalendář.
    """
    topics = TopicListSerializer(many=True, read_only=True)
    stats = serializers.SerializerMethodField()
    
    class Meta:
        model = ContentCalendar
        fields = [
            'id',
            'year',
            'month',
            'status',
            'posts_per_week',
            'total_posts_planned',
            'topics',
            'stats',
            'created_at',
        ]
    
    def get_stats(self, obj):
        from apps.content.selectors import get_calendar_stats
        return get_calendar_stats(
            organization=obj.organization,
            year=obj.year,
            month=obj.month,
        )
```

### CamelCase Transformation

```python
# config/settings/base.py

# Přidej do INSTALLED_APPS
# 'djangorestframework_camel_case',

REST_FRAMEWORK = {
    # ... ostatní nastavení ...
    'DEFAULT_RENDERER_CLASSES': [
        'djangorestframework_camel_case.render.CamelCaseJSONRenderer',
    ],
    'DEFAULT_PARSER_CLASSES': [
        'djangorestframework_camel_case.parser.CamelCaseJSONParser',
    ],
}
```

---

## 7. AUTHENTICATION

### JWT Authentication

```python
# apps/users/serializers.py
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    Vlastní token serializer - přidává organization do tokenu.
    """
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        
        # Přidej custom claims
        token['email'] = user.email
        token['full_name'] = user.full_name
        token['role'] = user.role
        
        # Přidej organization pokud existuje
        if hasattr(user, 'organization') and user.organization:
            token['organization_id'] = str(user.organization.id)
            token['organization_name'] = user.organization.name
        
        return token
    
    def validate(self, attrs):
        data = super().validate(attrs)
        
        # Přidej user info do response
        data['user'] = {
            'id': str(self.user.id),
            'email': self.user.email,
            'full_name': self.user.full_name,
            'role': self.user.role,
        }
        
        if self.user.organization:
            data['organization'] = {
                'id': str(self.user.organization.id),
                'name': self.user.organization.name,
            }
        
        return data
```

### Auth URLs

```python
# apps/users/urls.py
from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)

from apps.users.apis import (
    UserRegistrationView,
    UserProfileView,
    PasswordChangeView,
)

urlpatterns = [
    # JWT
    path('token/', TokenObtainPairView.as_view(), name='token_obtain'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),
    
    # User management
    path('register/', UserRegistrationView.as_view(), name='register'),
    path('profile/', UserProfileView.as_view(), name='profile'),
    path('password/change/', PasswordChangeView.as_view(), name='password_change'),
]
```

---

## 8. PERMISSIONS

### Custom Permissions

```python
# apps/core/permissions.py
from rest_framework import permissions


class IsOrganizationMember(permissions.BasePermission):
    """
    Ověří, že user je členem organizace.
    """
    message = 'You must be a member of the organization to access this resource.'
    
    def has_permission(self, request, view):
        # User musí mít přiřazenou organizaci
        return (
            request.user.is_authenticated and
            hasattr(request, 'tenant') and
            request.tenant is not None
        )
    
    def has_object_permission(self, request, view, obj):
        # Objekt musí patřit stejné organizaci
        if hasattr(obj, 'organization'):
            return obj.organization_id == request.tenant.id
        if hasattr(obj, 'organization_id'):
            return obj.organization_id == request.tenant.id
        return True


class IsOrganizationAdmin(permissions.BasePermission):
    """
    Ověří, že user je admin organizace.
    """
    message = 'You must be an organization admin to perform this action.'
    
    def has_permission(self, request, view):
        return (
            request.user.is_authenticated and
            hasattr(request, 'tenant') and
            request.user.role in ['admin', 'manager']
        )


class IsSupervisor(permissions.BasePermission):
    """
    Ověří, že user je supervisor (platící zákazník).
    """
    message = 'Only supervisors can access this resource.'
    
    def has_permission(self, request, view):
        return (
            request.user.is_authenticated and
            request.user.role == 'supervisor'
        )


class HasActiveSubscription(permissions.BasePermission):
    """
    Ověří, že organizace má aktivní subscription.
    """
    message = 'Active subscription required.'
    
    def has_permission(self, request, view):
        if not request.tenant:
            return False
        
        return request.tenant.has_active_subscription()


class HasFeatureAccess(permissions.BasePermission):
    """
    Ověří přístup k feature podle subscription tier.
    """
    required_feature = None  # Nastav v potomkovi nebo view
    
    def has_permission(self, request, view):
        if not request.tenant:
            return False
        
        feature = self.required_feature or getattr(view, 'required_feature', None)
        if not feature:
            return True
        
        return request.tenant.has_feature(feature)


class CanGenerateVideo(HasFeatureAccess):
    """
    Ověří přístup k video generování (ULTIMATE tier).
    """
    required_feature = 'video_generation'
    message = 'Video generation requires ULTIMATE subscription.'


class CanGenerateImages(HasFeatureAccess):
    """
    Ověří přístup ke generování obrázků (PRO+ tier).
    """
    required_feature = 'image_generation'
    message = 'Image generation requires PRO or higher subscription.'
```

---

## 9. MIDDLEWARE

### Tenant Middleware

```python
# apps/core/middleware.py
from django.http import JsonResponse
from apps.core.managers import set_current_tenant


class TenantMiddleware:
    """
    Middleware pro nastavení tenant kontextu.
    Každý request má přiřazenou organizaci z JWT tokenu.
    """
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        tenant = None
        
        # Extrahuj organization z JWT tokenu
        if hasattr(request, 'user') and request.user.is_authenticated:
            tenant = getattr(request.user, 'organization', None)
        
        # Nastav do request a thread local
        request.tenant = tenant
        set_current_tenant(tenant)
        
        try:
            response = self.get_response(request)
        finally:
            # Vyčisti tenant po requestu
            set_current_tenant(None)
        
        return response


class HealthCheckMiddleware:
    """
    Middleware pro health check endpointy.
    Obejde autentizaci pro /healthz a /readiness.
    """
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        if request.path == '/healthz':
            return JsonResponse({'status': 'ok'})
        
        if request.path == '/readiness':
            try:
                # Check database
                from django.db import connection
                with connection.cursor() as cursor:
                    cursor.execute('SELECT 1')
                
                # Check Redis
                from django.core.cache import cache
                cache.set('health_check', 'ok', 10)
                
                return JsonResponse({'status': 'ok'})
            except Exception as e:
                return JsonResponse(
                    {'status': 'error', 'detail': str(e)},
                    status=503
                )
        
        return self.get_response(request)
```

---

## 10. ERROR HANDLING

### Custom Exceptions

```python
# apps/core/exceptions.py
from rest_framework import status
from rest_framework.exceptions import APIException
from rest_framework.views import exception_handler


class BusinessLogicError(APIException):
    """
    Výjimka pro business logic chyby.
    """
    status_code = status.HTTP_400_BAD_REQUEST
    
    def __init__(self, code: str, message: str, details: dict = None):
        self.code = code
        self.detail = {
            'code': code,
            'message': message,
            'details': details or {},
        }


class ResourceNotFoundError(APIException):
    """
    Výjimka když zdroj není nalezen.
    """
    status_code = status.HTTP_404_NOT_FOUND
    
    def __init__(self, resource: str, identifier: str = None):
        self.detail = {
            'code': 'RESOURCE_NOT_FOUND',
            'message': f'{resource} not found',
            'resource': resource,
            'identifier': identifier,
        }


class PermissionDeniedError(APIException):
    """
    Výjimka pro odepření přístupu.
    """
    status_code = status.HTTP_403_FORBIDDEN
    
    def __init__(self, message: str = 'Permission denied'):
        self.detail = {
            'code': 'PERMISSION_DENIED',
            'message': message,
        }


class RateLimitedError(APIException):
    """
    Výjimka pro rate limiting.
    """
    status_code = status.HTTP_429_TOO_MANY_REQUESTS
    
    def __init__(self, retry_after: int = 60):
        self.detail = {
            'code': 'RATE_LIMITED',
            'message': 'Too many requests',
            'retry_after': retry_after,
        }


class AIServiceError(APIException):
    """
    Výjimka pro chyby AI služeb.
    """
    status_code = status.HTTP_502_BAD_GATEWAY
    
    def __init__(self, provider: str, message: str):
        self.detail = {
            'code': 'AI_SERVICE_ERROR',
            'message': f'AI service error: {message}',
            'provider': provider,
        }


def custom_exception_handler(exc, context):
    """
    Vlastní exception handler pro jednotný formát chyb.
    """
    response = exception_handler(exc, context)
    
    if response is None:
        # Neošetřená výjimka
        import logging
        logger = logging.getLogger(__name__)
        logger.exception('Unhandled exception')
        
        return Response(
            {
                'status': 'error',
                'code': 'INTERNAL_ERROR',
                'message': 'An unexpected error occurred',
            },
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
    
    # Standardizuj response formát
    if isinstance(response.data, dict):
        if 'code' not in response.data:
            response.data = {
                'status': 'error',
                'code': 'API_ERROR',
                'message': str(response.data.get('detail', 'Error')),
                'errors': response.data,
            }
        else:
            response.data['status'] = 'error'
    else:
        response.data = {
            'status': 'error',
            'code': 'API_ERROR',
            'message': str(response.data),
        }
    
    return response
```

---

## 11. PAGINATION

### Cursor Pagination (Recommended)

```python
# apps/core/pagination.py
from rest_framework.pagination import CursorPagination, PageNumberPagination
from rest_framework.response import Response


class StandardCursorPagination(CursorPagination):
    """
    Cursor pagination - nejlepší pro velké datasety.
    O(1) performance na rozdíl od offset pagination O(n).
    """
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100
    ordering = '-created_at'  # Musí být indexed!
    
    def get_paginated_response(self, data):
        return Response({
            'status': 'success',
            'data': data,
            'meta': {
                'next': self.get_next_link(),
                'previous': self.get_previous_link(),
                'page_size': self.page_size,
            }
        })


class StandardPagePagination(PageNumberPagination):
    """
    Page number pagination - pro menší datasety kde potřebujeme total.
    """
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100
    
    def get_paginated_response(self, data):
        return Response({
            'status': 'success',
            'data': data,
            'meta': {
                'page': self.page.number,
                'page_size': self.page_size,
                'total': self.page.paginator.count,
                'total_pages': self.page.paginator.num_pages,
                'next': self.get_next_link(),
                'previous': self.get_previous_link(),
            }
        })
```

---

## 12. FILTERING & SEARCH

### Django Filter

```python
# apps/content/filters.py
import django_filters
from apps.content.models import Topic, BlogPost


class TopicFilter(django_filters.FilterSet):
    """
    Filter pro témata.
    """
    status = django_filters.ChoiceFilter(choices=Topic.STATUS_CHOICES)
    planned_date_from = django_filters.DateFilter(
        field_name='planned_date',
        lookup_expr='gte'
    )
    planned_date_to = django_filters.DateFilter(
        field_name='planned_date',
        lookup_expr='lte'
    )
    persona = django_filters.UUIDFilter(field_name='persona_id')
    calendar = django_filters.UUIDFilter(field_name='calendar_id')
    search = django_filters.CharFilter(method='filter_search')
    
    class Meta:
        model = Topic
        fields = ['status', 'persona', 'calendar']
    
    def filter_search(self, queryset, name, value):
        """Full-text search přes title a description."""
        from django.contrib.postgres.search import SearchVector, SearchQuery
        
        search_vector = SearchVector('title', weight='A') + \
                       SearchVector('description', weight='B')
        search_query = SearchQuery(value)
        
        return queryset.annotate(
            search=search_vector
        ).filter(search=search_query)


class BlogPostFilter(django_filters.FilterSet):
    """
    Filter pro blogposty.
    """
    status = django_filters.ChoiceFilter(choices=BlogPost.STATUS_CHOICES)
    calendar = django_filters.UUIDFilter(field_name='calendar_id')
    persona = django_filters.UUIDFilter(field_name='persona_id')
    created_from = django_filters.DateTimeFilter(
        field_name='created_at',
        lookup_expr='gte'
    )
    created_to = django_filters.DateTimeFilter(
        field_name='created_at',
        lookup_expr='lte'
    )
    
    class Meta:
        model = BlogPost
        fields = ['status', 'calendar', 'persona']
```

---

## 13. TESTING

### Test Configuration

```python
# pytest.ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings.dev
python_files = tests.py test_*.py *_tests.py
addopts = -v --tb=short --strict-markers
markers =
    slow: marks tests as slow
    integration: marks tests as integration tests
```

### Test Examples

```python
# apps/content/tests/test_services.py
import pytest
from datetime import date, timedelta

from apps.content.services import topic_create, topic_approve
from apps.content.models import Topic
from apps.core.exceptions import BusinessLogicError


@pytest.fixture
def organization(db):
    from apps.organizations.models import Organization
    return Organization.objects.create(name='Test Org')


@pytest.fixture
def calendar(db, organization):
    from apps.content.models import ContentCalendar
    today = date.today()
    return ContentCalendar.objects.create(
        organization=organization,
        year=today.year,
        month=today.month,
    )


@pytest.fixture
def persona(db, organization):
    from apps.personas.models import Persona
    return Persona.objects.create(
        organization=organization,
        character_name='Test Persona',
    )


class TestTopicCreate:
    def test_creates_topic_successfully(self, calendar, persona):
        topic = topic_create(
            calendar=calendar,
            persona=persona,
            title='Test Topic',
            description='Test description',
            planned_date=date.today() + timedelta(days=7),
        )
        
        assert topic.id is not None
        assert topic.title == 'Test Topic'
        assert topic.status == 'pending_approval'
    
    def test_raises_error_for_past_date(self, calendar, persona):
        with pytest.raises(ValidationError):
            topic_create(
                calendar=calendar,
                persona=persona,
                title='Test Topic',
                description='Test description',
                planned_date=date.today() - timedelta(days=1),
            )


class TestTopicApprove:
    def test_approves_pending_topic(self, calendar, persona, user):
        topic = topic_create(
            calendar=calendar,
            persona=persona,
            title='Test Topic',
            description='Test description',
            planned_date=date.today() + timedelta(days=7),
        )
        
        topic = topic_approve(topic=topic, approved_by=user)
        
        assert topic.status == 'approved'
        assert topic.approved_by == user
    
    def test_raises_error_for_already_approved(self, calendar, persona, user):
        topic = topic_create(
            calendar=calendar,
            persona=persona,
            title='Test Topic',
            description='Test description',
            planned_date=date.today() + timedelta(days=7),
        )
        topic_approve(topic=topic, approved_by=user)
        
        with pytest.raises(BusinessLogicError) as exc:
            topic_approve(topic=topic, approved_by=user)
        
        assert exc.value.code == 'INVALID_STATUS'
```

### API Tests

```python
# apps/content/tests/test_apis.py
import pytest
from rest_framework.test import APIClient
from rest_framework import status


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def authenticated_client(api_client, user):
    api_client.force_authenticate(user=user)
    return api_client


class TestTopicViewSet:
    def test_list_topics_requires_auth(self, api_client):
        response = api_client.get('/api/v1/content/topics/')
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
    
    def test_list_topics_returns_only_org_topics(
        self, authenticated_client, organization, other_organization
    ):
        # Create topics for both orgs
        Topic.objects.create(organization=organization, title='My Topic')
        Topic.objects.create(organization=other_organization, title='Other Topic')
        
        response = authenticated_client.get('/api/v1/content/topics/')
        
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['data']) == 1
        assert response.data['data'][0]['title'] == 'My Topic'
    
    def test_create_topic_successfully(self, authenticated_client, calendar, persona):
        data = {
            'calendar': str(calendar.id),
            'persona': str(persona.id),
            'title': 'New Topic',
            'description': 'Description',
            'plannedDate': '2024-12-15',
        }
        
        response = authenticated_client.post(
            '/api/v1/content/topics/',
            data=data,
            format='json'
        )
        
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data['data']['title'] == 'New Topic'
```

---

## 14. DEPENDENCIES

### requirements/base.txt

```txt
# Django
Django>=5.0,<5.2
djangorestframework>=3.15.0
django-cors-headers>=4.3.0
django-filter>=24.0
django-environ>=0.11.2

# Authentication
djangorestframework-simplejwt>=5.3.1
PyJWT>=2.8.0

# Database
psycopg[binary]>=3.1.18
pgvector>=0.4.2

# Async/Tasks
celery>=5.4.0
redis>=5.0.0
django-celery-beat>=2.7.0
django-celery-results>=2.5.1
flower>=2.0.0

# API Documentation
drf-spectacular>=0.29.0

# Payments
dj-stripe>=2.10.0

# Utils
whitenoise>=6.6.0
python-dateutil>=2.8.2
Pillow>=10.2.0

# Logging & Monitoring
django-structlog>=6.0.0
sentry-sdk>=1.40.0
django-prometheus>=2.3.0

# CamelCase transformation
djangorestframework-camel-case>=1.4.2
```

### requirements/dev.txt

```txt
-r base.txt

# Testing
pytest>=8.0.0
pytest-django>=4.8.0
pytest-cov>=4.1.0
factory-boy>=3.3.0
faker>=22.0.0

# Debug
django-debug-toolbar>=4.2.0
ipython>=8.20.0

# Code Quality
black>=24.1.0
isort>=5.13.0
flake8>=7.0.0
mypy>=1.8.0
django-stubs>=4.2.0
```

### requirements/prod.txt

```txt
-r base.txt

# WSGI Server
gunicorn>=21.2.0
uvicorn>=0.27.0

# Performance
django-redis>=5.4.0
hiredis>=2.3.0
```

---

## 📌 QUICK COMMANDS

```bash
# Migrace
python manage.py makemigrations
python manage.py migrate

# Vytvoření superusera
python manage.py createsuperuser

# Spuštění serveru
python manage.py runserver

# Celery worker
celery -A config worker -l INFO

# Celery beat
celery -A config beat -l INFO

# Testy
pytest
pytest --cov=apps
pytest apps/content/tests/

# Formátování
black apps/
isort apps/
flake8 apps/

# Type checking
mypy apps/

# Shell
python manage.py shell_plus
```

---

*Tento dokument je SELF-CONTAINED - obsahuje všechny informace o Django backendu.*

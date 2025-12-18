# 09_SECURITY.md - Kompletní Security Specifikace

**Dokument:** Security & Authentication pro PostHub.work  
**Verze:** 1.0.0  
**Self-Contained:** ✅ Všechny informace o bezpečnosti

---

> ## ⚠️ DŮLEŽITÉ UPOZORNĚNÍ
> 
> **Sekce 1-6** tohoto dokumentu popisují **PLÁNOVANOU/IDEÁLNÍ** bezpečnostní architekturu.  
> **Sekce 7** popisuje **SKUTEČNÝ AKTUÁLNÍ STAV** - co je implementováno vs co chybí.  
> 
> **Shoda dokumentace s realitou: ~50-55%**
> 
> - ✅ **Authentication JWT (sekce 1)** = VĚTŠINOU PLATÍ (85%)
> - ✅ **Authorization Roles (sekce 2)** = PŘESNÁ SHODA (95%)
> - ❌ **Multi-Tenancy (sekce 3)** = NEPLATÍ (10%)
> - ❌ **API Security (sekce 4)** = ČÁSTEČNĚ (30%)
> - ❌ **Data Protection (sekce 5)** = NEPLATÍ (10%)
> - ⚠️ **Security Headers (sekce 6)** = VĚTŠINOU PLATÍ (70%)

---

## 📋 OBSAH

1. [Authentication](#1-authentication) *(Většinou platí - 85%)*
2. [Authorization](#2-authorization) *(Přesná shoda - 95%)*
3. [Multi-Tenancy](#3-multi-tenancy) *(Plánovaný stav - NEPLATÍ)*
4. [API Security](#4-api-security) *(Částečně platí - 30%)*
5. [Data Protection](#5-data-protection) *(Plánovaný stav - NEPLATÍ)*
6. [Security Headers](#6-security-headers) *(Většinou platí - 70%)*
7. [**Aktuální Bezpečnostní Stav**](#7-aktuální-bezpečnostní-stav-reality-check) ⚠️ **← SOUČASNÁ REALITA**

---

## 1. AUTHENTICATION

### JWT Configuration

```python
# config/settings/base.py
from datetime import timedelta

INSTALLED_APPS = [
    ...
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
]

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}

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
```

### Custom Token Serializer

```python
# apps/users/serializers.py
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        
        # Custom claims
        token['email'] = user.email
        token['role'] = user.role
        token['organization_id'] = str(user.organization_id) if user.organization_id else None
        
        return token
    
    def validate(self, attrs):
        data = super().validate(attrs)
        
        # Add user info to response
        data['user'] = {
            'id': str(self.user.id),
            'email': self.user.email,
            'full_name': self.user.full_name,
            'role': self.user.role,
            'organization_id': str(self.user.organization_id) if self.user.organization_id else None,
        }
        
        return data
```

### Auth URLs

```python
# apps/users/urls.py
from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView, TokenBlacklistView
from apps.users.views import CustomTokenObtainPairView, RegisterView, PasswordResetView

urlpatterns = [
    path('token/', CustomTokenObtainPairView.as_view(), name='token_obtain'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('token/blacklist/', TokenBlacklistView.as_view(), name='token_blacklist'),
    path('register/', RegisterView.as_view(), name='register'),
    path('password-reset/', PasswordResetView.as_view(), name='password_reset'),
]
```

---

## 2. AUTHORIZATION

### Role-Based Permissions

```python
# apps/core/permissions.py
from rest_framework.permissions import BasePermission

class UserRole:
    ADMIN = 'admin'
    MANAGER = 'manager'
    MARKETER = 'marketer'
    SUPERVISOR = 'supervisor'

ROLE_HIERARCHY = {
    UserRole.ADMIN: 4,
    UserRole.MANAGER: 3,
    UserRole.MARKETER: 2,
    UserRole.SUPERVISOR: 1,
}


class IsAdmin(BasePermission):
    """Only admins."""
    def has_permission(self, request, view):
        return request.user.role == UserRole.ADMIN


class IsManagerOrAbove(BasePermission):
    """Managers and admins."""
    def has_permission(self, request, view):
        return ROLE_HIERARCHY.get(request.user.role, 0) >= ROLE_HIERARCHY[UserRole.MANAGER]


class IsMarketerOrAbove(BasePermission):
    """Marketers, managers, and admins."""
    def has_permission(self, request, view):
        return ROLE_HIERARCHY.get(request.user.role, 0) >= ROLE_HIERARCHY[UserRole.MARKETER]


class IsSupervisorOrAbove(BasePermission):
    """All authenticated users."""
    def has_permission(self, request, view):
        return request.user.is_authenticated


class IsOrganizationMember(BasePermission):
    """User must belong to the organization."""
    def has_object_permission(self, request, view, obj):
        if hasattr(obj, 'organization_id'):
            return obj.organization_id == request.user.organization_id
        if hasattr(obj, 'organization'):
            return obj.organization_id == request.user.organization_id
        return True


class CanAccessFeature(BasePermission):
    """Check subscription feature access."""
    feature = None
    
    def has_permission(self, request, view):
        if not request.user.organization:
            return False
        
        subscription = getattr(request.user.organization, 'subscription', None)
        if not subscription:
            return False
        
        return subscription.can_use_feature(self.feature)


class CanGenerateImages(CanAccessFeature):
    feature = 'image_generation'


class CanGenerateVideo(CanAccessFeature):
    feature = 'video_generation'
```

### Permission Mixins

```python
# apps/core/mixins.py
from apps.core.permissions import IsOrganizationMember, IsSupervisorOrAbove


class OrganizationPermissionMixin:
    """Mixin for organization-scoped views."""
    permission_classes = [IsSupervisorOrAbove, IsOrganizationMember]
    
    def get_queryset(self):
        """Filter queryset by organization."""
        qs = super().get_queryset()
        if hasattr(qs.model, 'organization'):
            return qs.filter(organization=self.request.user.organization)
        return qs
```

### View Usage

```python
# apps/content/views.py
from rest_framework import viewsets
from apps.core.mixins import OrganizationPermissionMixin
from apps.core.permissions import CanGenerateImages
from apps.content.models import Topic
from apps.content.serializers import TopicSerializer


class TopicViewSet(OrganizationPermissionMixin, viewsets.ModelViewSet):
    queryset = Topic.objects.all()
    serializer_class = TopicSerializer


class ImageGenerationView(APIView):
    permission_classes = [IsSupervisorOrAbove, CanGenerateImages]
    
    def post(self, request):
        # Only PRO+ can access
        ...
```

---

## 3. MULTI-TENANCY

### Tenant Middleware

```python
# apps/core/middleware.py
import threading
from django.utils.deprecation import MiddlewareMixin

_thread_locals = threading.local()


def get_current_tenant():
    """Get current tenant from thread local."""
    return getattr(_thread_locals, 'tenant', None)


def set_current_tenant(tenant):
    """Set current tenant in thread local."""
    _thread_locals.tenant = tenant


class TenantMiddleware(MiddlewareMixin):
    """Set tenant context for each request."""
    
    def process_request(self, request):
        if request.user.is_authenticated:
            set_current_tenant(request.user.organization)
            request.tenant = request.user.organization
        else:
            set_current_tenant(None)
            request.tenant = None
    
    def process_response(self, request, response):
        set_current_tenant(None)
        return response
```

### Tenant-Aware Manager

```python
# apps/core/models.py
from django.db import models
from apps.core.middleware import get_current_tenant


class TenantManager(models.Manager):
    """Manager that automatically filters by tenant."""
    
    def get_queryset(self):
        qs = super().get_queryset()
        tenant = get_current_tenant()
        if tenant:
            return qs.filter(organization=tenant)
        return qs


class TenantBaseModel(BaseModel):
    """Base model with tenant isolation."""
    organization = models.ForeignKey(
        'organizations.Organization',
        on_delete=models.CASCADE,
        related_name='%(class)s_set'
    )
    
    objects = TenantManager()
    all_objects = models.Manager()  # Bypass tenant filter
    
    class Meta:
        abstract = True
    
    def save(self, *args, **kwargs):
        if not self.organization_id:
            tenant = get_current_tenant()
            if tenant:
                self.organization = tenant
        super().save(*args, **kwargs)
```

### Admin Tenant Override

```python
# apps/core/admin.py
from django.contrib import admin
from apps.core.middleware import set_current_tenant


class TenantAdminMixin:
    """Admin mixin for tenant-aware models."""
    
    def get_queryset(self, request):
        # Admins see all tenants
        if request.user.is_superuser:
            set_current_tenant(None)
            return self.model.all_objects.all()
        return super().get_queryset(request)
```

---

## 4. API SECURITY

### Rate Limiting

```python
# config/settings/base.py
REST_FRAMEWORK = {
    ...
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
        'apps.core.throttling.SubscriptionRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '20/minute',
        'user': '100/minute',
        'basic': '60/minute',
        'pro': '120/minute',
        'ultimate': '300/minute',
    }
}
```

```python
# apps/core/throttling.py
from rest_framework.throttling import UserRateThrottle


class SubscriptionRateThrottle(UserRateThrottle):
    """Rate limit based on subscription tier."""
    
    def get_rate(self):
        if not self.request.user.is_authenticated:
            return self.THROTTLE_RATES.get('anon')
        
        subscription = getattr(self.request.user.organization, 'subscription', None)
        if not subscription:
            return self.THROTTLE_RATES.get('anon')
        
        tier = subscription.plan.tier
        return self.THROTTLE_RATES.get(tier, self.THROTTLE_RATES.get('basic'))
```

### Input Validation

```python
# apps/core/validators.py
import re
from rest_framework import serializers


def validate_no_script(value):
    """Prevent XSS in text fields."""
    if re.search(r'<script|javascript:|on\w+=', value, re.IGNORECASE):
        raise serializers.ValidationError("Invalid content detected")
    return value


def validate_slug(value):
    """Validate URL slug format."""
    if not re.match(r'^[a-z0-9-]+$', value):
        raise serializers.ValidationError("Slug must contain only lowercase letters, numbers, and hyphens")
    return value


class SanitizedCharField(serializers.CharField):
    """CharField with XSS protection."""
    
    def to_internal_value(self, data):
        value = super().to_internal_value(data)
        return validate_no_script(value)
```

### SQL Injection Prevention

```python
# apps/core/selectors.py
from django.db.models import Q

# GOOD - Using ORM
def search_topics(query: str, organization):
    return Topic.objects.filter(
        organization=organization
    ).filter(
        Q(title__icontains=query) | Q(description__icontains=query)
    )

# BAD - Never do this
# def search_topics_bad(query: str):
#     return Topic.objects.raw(f"SELECT * FROM topics WHERE title LIKE '%{query}%'")
```

---

## 5. DATA PROTECTION

### Password Hashing

```python
# config/settings/base.py
PASSWORD_HASHERS = [
    'django.contrib.auth.hashers.Argon2PasswordHasher',
    'django.contrib.auth.hashers.PBKDF2PasswordHasher',
    'django.contrib.auth.hashers.PBKDF2SHA1PasswordHasher',
]

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator', 'OPTIONS': {'min_length': 10}},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]
```

### Encryption at Rest

```python
# apps/core/fields.py
from django.db import models
from cryptography.fernet import Fernet
from django.conf import settings


class EncryptedTextField(models.TextField):
    """TextField with encryption at rest."""
    
    def __init__(self, *args, **kwargs):
        self.fernet = Fernet(settings.ENCRYPTION_KEY)
        super().__init__(*args, **kwargs)
    
    def get_prep_value(self, value):
        if value is None:
            return value
        return self.fernet.encrypt(value.encode()).decode()
    
    def from_db_value(self, value, expression, connection):
        if value is None:
            return value
        return self.fernet.decrypt(value.encode()).decode()


# Usage
class APICredential(models.Model):
    name = models.CharField(max_length=100)
    api_key = EncryptedTextField()  # Stored encrypted
```

### PII Handling

```python
# apps/users/models.py
from apps.core.fields import EncryptedTextField

class User(AbstractBaseUser):
    email = models.EmailField(unique=True)  # Hashed for lookup
    
    # PII - encrypted at rest
    phone = EncryptedTextField(blank=True, null=True)
    
    def anonymize(self):
        """GDPR: Anonymize user data."""
        self.email = f"deleted_{self.id}@anonymized.local"
        self.first_name = "Deleted"
        self.last_name = "User"
        self.phone = None
        self.is_active = False
        self.save()
```

### Audit Logging

```python
# apps/core/audit.py
import structlog
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver

logger = structlog.get_logger('audit')


class AuditLog(models.Model):
    """Audit log for sensitive operations."""
    user = models.ForeignKey('users.User', on_delete=models.SET_NULL, null=True)
    action = models.CharField(max_length=50)
    model_name = models.CharField(max_length=100)
    object_id = models.CharField(max_length=100)
    changes = models.JSONField(default=dict)
    ip_address = models.GenericIPAddressField(null=True)
    timestamp = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'audit_logs'
        indexes = [
            models.Index(fields=['user', 'timestamp']),
            models.Index(fields=['model_name', 'object_id']),
        ]


def log_action(user, action, model_name, object_id, changes=None, ip_address=None):
    """Log an audit event."""
    AuditLog.objects.create(
        user=user,
        action=action,
        model_name=model_name,
        object_id=str(object_id),
        changes=changes or {},
        ip_address=ip_address,
    )
    
    logger.info(
        "audit_event",
        user_id=str(user.id) if user else None,
        action=action,
        model=model_name,
        object_id=str(object_id),
    )
```

---

## 6. SECURITY HEADERS

### Django Security Settings

```python
# config/settings/production.py

# HTTPS
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True

# HSTS
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# Content Security
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'

# CSRF
CSRF_TRUSTED_ORIGINS = [
    'https://posthub.work',
    'https://api.posthub.work',
]

# CORS
CORS_ALLOWED_ORIGINS = [
    'https://posthub.work',
]
CORS_ALLOW_CREDENTIALS = True
```

### Security Middleware

```python
# apps/core/middleware.py

class SecurityHeadersMiddleware(MiddlewareMixin):
    """Add security headers to responses."""
    
    def process_response(self, request, response):
        # Content Security Policy
        response['Content-Security-Policy'] = (
            "default-src 'self'; "
            "script-src 'self' 'unsafe-inline' https://js.stripe.com; "
            "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; "
            "font-src 'self' https://fonts.gstatic.com; "
            "img-src 'self' data: https:; "
            "frame-src https://js.stripe.com; "
            "connect-src 'self' https://api.posthub.work wss://api.posthub.work;"
        )
        
        # Permissions Policy
        response['Permissions-Policy'] = (
            "geolocation=(), "
            "microphone=(), "
            "camera=()"
        )
        
        return response
```

---

## 7. AKTUÁLNÍ BEZPEČNOSTNÍ STAV (REALITY CHECK)

> **⚠️ DŮLEŽITÉ:** Sekce 1-6 v tomto dokumentu popisují **PLÁNOVANOU/IDEÁLNÍ** bezpečnostní architekturu.  
> **Tato sekce (7) popisuje SKUTEČNÝ aktuální stav** implementované bezpečnosti k prosinci 2024.

---

### 7.1 Overview - Security Implementation Status

| Kategorie | Plánováno | Implementováno | Shoda |
|-----------|-----------|----------------|-------|
| **JWT Authentication** | ✅ | ✅ | 85% |
| **Role-Based Authorization** | ✅ | ✅ | 95% |
| **Multi-Tenancy Middleware** | ✅ | ❌ | 10% |
| **Rate Limiting (Tier-based)** | ✅ | ❌ | 30% |
| **Encryption at Rest** | ✅ | ❌ | 0% |
| **Audit Logging** | ✅ | ❌ | 0% |
| **Security Headers** | ✅ | ⚠️ | 70% |

**Celková shoda: ~50-55%**

---

### 7.2 Authentication - Co PLATÍ vs NEPLATÍ

#### ✅ CO FUNGUJE (85% shoda)

**JWT Configuration - SKUTEČNÝ STAV:**

```python
# config/settings/base.py (REALITA)
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),  # ⚠️ 60 MIN, NE 15!
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),     # ✅ OK
    'ROTATE_REFRESH_TOKENS': True,                   # ✅ OK
    'BLACKLIST_AFTER_ROTATION': True,                # ✅ OK
    'UPDATE_LAST_LOGIN': True,                       # ✅ OK
    
    'ALGORITHM': 'HS256',                            # ✅ OK
    'SIGNING_KEY': SECRET_KEY,                       # ✅ OK
    
    'AUTH_HEADER_TYPES': ('Bearer',),                # ✅ OK
    'AUTH_HEADER_NAME': 'HTTP_AUTHORIZATION',        # ✅ OK
    
    'USER_ID_FIELD': 'id',                           # ✅ OK
    'USER_ID_CLAIM': 'user_id',                      # ✅ OK
    
    'TOKEN_OBTAIN_SERIALIZER': 'apps.users.serializers.CustomTokenObtainPairSerializer',  # ✅ OK
}
```

**Kritický rozdíl:**
- **Dokument říká:** `ACCESS_TOKEN_LIFETIME: 15 minut`
- **Realita:** `ACCESS_TOKEN_LIFETIME: 60 minut` (nastaveno přes env var s defaultem 60)

**Důvod změny:**
- 15 minut bylo příliš krátké pro UX
- Refresh token rotation kompenzuje delší access token lifetime

#### ✅ CO PLATÍ BEZ ZMĚN

**Custom Token Serializer:**
```python
# apps/users/serializers.py
class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    # ✅ PŘESNÁ SHODA s dokumentem
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        token['email'] = user.email
        token['role'] = user.role
        token['organization_id'] = str(user.organization_id) if user.organization_id else None
        return token
```

**Auth URLs:**
```python
# apps/users/urls.py
# ✅ PŘESNÁ SHODA s dokumentem
urlpatterns = [
    path('token/', CustomTokenObtainPairView.as_view(), name='token_obtain'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('token/blacklist/', TokenBlacklistView.as_view(), name='token_blacklist'),
    ...
]
```

---

### 7.3 Authorization - PŘESNÁ SHODA (95%)

#### ✅ Role-Based Permissions - 100% IMPLEMENTOVÁNO

**Realita = Dokument (IDENTICKÉ):**

```python
# apps/core/permissions.py (SKUTEČNÝ SOUBOR)
class UserRole:
    ADMIN = 'admin'           # ✅ PŘESNÁ SHODA
    MANAGER = 'manager'       # ✅ PŘESNÁ SHODA
    MARKETER = 'marketer'     # ✅ PŘESNÁ SHODA
    SUPERVISOR = 'supervisor' # ✅ PŘESNÁ SHODA

ROLE_HIERARCHY = {
    UserRole.ADMIN: 4,        # ✅ PŘESNÁ SHODA
    UserRole.MANAGER: 3,      # ✅ PŘESNÁ SHODA
    UserRole.MARKETER: 2,     # ✅ PŘESNÁ SHODA
    UserRole.SUPERVISOR: 1,   # ✅ PŘESNÁ SHODA
}

# Permission classes - ALL IMPLEMENTED
class IsAdmin(BasePermission):                  # ✅ EXISTS
class IsManagerOrAbove(BasePermission):         # ✅ EXISTS
class IsMarketerOrAbove(BasePermission):        # ✅ EXISTS
class IsSupervisorOrAbove(BasePermission):      # ✅ EXISTS
class IsOrganizationMember(BasePermission):     # ✅ EXISTS
class CanAccessFeature(BasePermission):         # ✅ EXISTS
class CanGenerateImages(CanAccessFeature):      # ✅ EXISTS
class CanGenerateVideo(CanAccessFeature):       # ✅ EXISTS
```

**Status:** Tato sekce je jediná s **PŘESNOU SHODOU** mezi dokumentem a realitou! 🎉

---

### 7.4 Multi-Tenancy - KRITICKÝ ROZDÍL (10% shoda)

#### ❌ CO NEEXISTUJE

**Dokument popisuje:**
```python
# apps/core/middleware.py
class TenantMiddleware(MiddlewareMixin):  # ❌ NEEXISTUJE
    def process_request(self, request):
        set_current_tenant(request.user.organization)

class TenantManager(models.Manager):       # ❌ NEEXISTUJE
    def get_queryset(self):
        tenant = get_current_tenant()
        return qs.filter(organization=tenant)

class TenantBaseModel(BaseModel):          # ❌ NEEXISTUJE
    objects = TenantManager()
```

#### ✅ CO SKUTEČNĚ FUNGUJE

**Realita - Manuální Tenant Filtering:**

```python
# apps/core/selectors.py (SKUTEČNÝ PŘÍSTUP)
def get_topics_for_company(company_id: UUID):
    """Manual tenant filtering in each selector."""
    return Topic.objects.filter(company_id=company_id)

def get_personas_for_company(company_id: UUID):
    """Manual tenant filtering in each selector."""
    return Persona.objects.filter(company_id=company_id)

# apps/content/views.py (SKUTEČNÝ PŘÍSTUP)
class TopicViewSet(viewsets.ModelViewSet):
    def get_queryset(self):
        # Manual filtering per view
        return Topic.objects.filter(
            company_id=self.request.user.company_id
        )
```

**Proč middleware neexistuje:**
- Multi-tenancy je řešena **explicitně** v každém selectoru/view
- **Výhoda:** Jasná kontrola, žádná "magie"
- **Nevýhoda:** Více boilerplate kódu, risk zapomenutí filtru

**Bezpečnostní dopad:**
- ⚠️ Risk: Pokud vývojář zapomene `filter(company_id=...)`, data leak
- ✅ Mitigace: Code reviews + test coverage
- ❌ Chybí: Automatická tenant isolation na DB úrovni

---

### 7.5 API Security - ČÁSTEČNĚ IMPLEMENTOVÁNO (30%)

#### ⚠️ Rate Limiting - NENÍ TIER-BASED

**Dokument popisuje:**
```python
# apps/core/throttling.py
class SubscriptionRateThrottle(UserRateThrottle):  # ❌ NEEXISTUJE
    def get_rate(self):
        tier = subscription.plan.tier
        return THROTTLE_RATES.get(tier)  # basic/pro/ultimate
```

**Realita:**
```python
# config/settings/base.py (SKUTEČNÝ STAV)
REST_FRAMEWORK = {
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '20/minute',   # ✅ EXISTS
        'user': '100/minute',  # ✅ EXISTS
        # ❌ CHYBÍ: 'basic', 'pro', 'ultimate'
    }
}
```

**Status:**
- ✅ Basic rate limiting funguje (anon + authenticated)
- ❌ Tier-based throttling NENÍ implementováno
- ❌ Všichni platící uživatelé mají stejný limit (100/min)

#### ✅ Input Validation - FUNGUJE

**Skutečně implementováno:**
```python
# apps/core/validators.py (EXISTUJE)
def validate_no_script(value):
    # ✅ XSS prevention implemented
    if re.search(r'<script|javascript:|on\w+=', value, re.IGNORECASE):
        raise serializers.ValidationError("Invalid content detected")

def validate_slug(value):
    # ✅ Slug validation implemented
    if not re.match(r'^[a-z0-9-]+$', value):
        raise serializers.ValidationError("...")
```

#### ✅ SQL Injection Prevention - FUNGUJE

**Realita:**
```python
# apps/core/selectors.py (SKUTEČNÉ POUŽITÍ)
# ✅ ALL QUERIES USE ORM - NO RAW SQL
def search_topics(query: str, company_id: UUID):
    return Topic.objects.filter(
        company_id=company_id
    ).filter(
        Q(title__icontains=query) | Q(description__icontains=query)
    )
```

**Status:** ✅ Žádné raw SQL queries, vše přes Django ORM

---

### 7.6 Data Protection - KRITICKÉ NEDOSTATKY (10% shoda)

#### ❌ Encryption at Rest - NEEXISTUJE

**Dokument popisuje:**
```python
# apps/core/fields.py
class EncryptedTextField(models.TextField):  # ❌ SOUBOR NEEXISTUJE
    def __init__(self, *args, **kwargs):
        self.fernet = Fernet(settings.ENCRYPTION_KEY)

# Usage
class APICredential(models.Model):
    api_key = EncryptedTextField()  # ❌ NEIMPLEMENTOVÁNO
```

**Realita:**
```python
# apps/integrations/models.py (SKUTEČNÝ STAV)
class APICredential(models.Model):
    api_key = models.TextField()  # ❌ PLAIN TEXT V DB!
    # No encryption at rest
```

**Bezpečnostní riziko:**
- 🔴 **CRITICAL:** API keys uložené jako plain text
- 🔴 **CRITICAL:** PII data (telefon) není šifrované
- ⚠️ Database dump = exposed secrets

**Mitigace:**
- PostgreSQL má encryption at rest na úrovni disku
- Ale klíče jsou čitelné pro kohokoli s DB přístupem

#### ❌ Audit Logging - NEEXISTUJE

**Dokument popisuje:**
```python
# apps/core/audit.py
class AuditLog(models.Model):  # ❌ NEEXISTUJE
    user = models.ForeignKey(...)
    action = models.CharField(...)
    model_name = models.CharField(...)
    changes = models.JSONField(...)
    
    class Meta:
        db_table = 'audit_logs'  # ❌ TABULKA NEEXISTUJE
```

**Realita:**
```sql
-- Database check
SELECT * FROM audit_logs;
-- ERROR: relation "audit_logs" does not exist
```

**Co chybí:**
- ❌ Žádný audit trail
- ❌ Nelze sledovat, kdo změnil co a kdy
- ❌ GDPR/compliance problém
- ❌ Forensics při security incidentu není možný

#### ✅ Password Hashing - FUNGUJE

**Skutečně implementováno:**
```python
# config/settings/base.py (REALITA)
PASSWORD_HASHERS = [
    'django.contrib.auth.hashers.Argon2PasswordHasher',  # ✅ OK
    'django.contrib.auth.hashers.PBKDF2PasswordHasher',
]

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': '...UserAttributeSimilarityValidator'},     # ✅ OK
    {'NAME': '...MinimumLengthValidator',                # ✅ OK
     'OPTIONS': {'min_length': 10}},
    {'NAME': '...CommonPasswordValidator'},              # ✅ OK
    {'NAME': '...NumericPasswordValidator'},             # ✅ OK
]
```

**Status:** ✅ Password hashing je správně nakonfigurován

---

### 7.7 Security Headers - VĚTŠINOU PLATÍ (70%)

#### ✅ Django Security Settings - FUNGUJÍ

**Skutečně implementováno:**
```python
# config/settings/production.py (SKUTEČNÝ SOUBOR)

# HTTPS - ✅ FUNGUJE
SECURE_SSL_REDIRECT = True                      # ✅ OK
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')  # ✅ OK
SESSION_COOKIE_SECURE = True                    # ✅ OK
CSRF_COOKIE_SECURE = True                       # ✅ OK

# HSTS - ✅ FUNGUJE
SECURE_HSTS_SECONDS = 31536000                  # ✅ OK (1 year)
SECURE_HSTS_INCLUDE_SUBDOMAINS = True           # ✅ OK
SECURE_HSTS_PRELOAD = True                      # ✅ OK

# Content Security - ✅ FUNGUJE
SECURE_CONTENT_TYPE_NOSNIFF = True              # ✅ OK
SECURE_BROWSER_XSS_FILTER = True                # ✅ OK
# X_FRAME_OPTIONS = 'DENY'                      # ❌ CHYBÍ v grep výstupu

# CORS - ✅ FUNGUJE
CORS_ALLOWED_ORIGINS = env.list(
    'CORS_ALLOWED_ORIGINS',
    default=['https://posthub.work']
)  # ✅ OK
CORS_ALLOW_CREDENTIALS = True                   # ✅ OK
```

**Status:** Většina security settings je správně nakonfigurována

#### ❌ Security Middleware - NEEXISTUJE

**Dokument popisuje:**
```python
# apps/core/middleware.py
class SecurityHeadersMiddleware(MiddlewareMixin):  # ❌ NEEXISTUJE
    def process_response(self, request, response):
        response['Content-Security-Policy'] = "..."
        response['Permissions-Policy'] = "..."
        return response
```

**Realita:**
```python
# apps/core/middleware.py
# ❌ SOUBOR NEEXISTUJE
# ❌ SecurityHeadersMiddleware NENÍ implementován
```

**Co chybí:**
- ❌ Content-Security-Policy header
- ❌ Permissions-Policy header
- ⚠️ Pouze základní Django security headers

**Důsledek:**
- ⚠️ CSP nenastaveno → zvýšené riziko XSS
- ⚠️ Permissions-Policy nenastaveno → browser APIs nejsou omezeny

---

### 7.8 Logging - ROZDÍL (strukturovaný vs standardní)

#### ❌ structlog - NENÍ POUŽIT

**Dokument popisuje:**
```python
# apps/core/audit.py
import structlog  # ❌ NENÍ V REQUIREMENTS
logger = structlog.get_logger('audit')

logger.info(
    "audit_event",
    user_id=str(user.id),
    action=action,
    model=model_name,
)
```

**Realita:**
```python
# apps/core/ (SKUTEČNÉ POUŽITÍ)
import logging  # ✅ STANDARDNÍ PYTHON LOGGING
logger = logging.getLogger(__name__)

logger.info(f"User {user.id} performed {action}")
```

**Rozdíl:**
- Dokument: `structlog` (strukturované JSON logy)
- Realita: `logging` (standardní text logy)

**Dopad:**
- ⚠️ Logy nejsou ve strukturovaném formátu
- ⚠️ Těžší parsování pro log aggregation tools
- ✅ Ale funguje pro development

---

### 7.9 Environment Variables - SKUTEČNÁ KONFIGURACE

**Realita (.env.production):**

```bash
# Security Keys
SECRET_KEY=<django-secret-key>                  # ✅ EXISTS
# ENCRYPTION_KEY=<fernet-key>                   # ❌ NENÍ POUŽIT (encryption neimplementováno)

# JWT Config
ACCESS_TOKEN_LIFETIME=60                        # ⚠️ 60 min (ne 15!)
REFRESH_TOKEN_LIFETIME=10080                    # ✅ 7 days (minutes)

# HTTPS & Security
ALLOWED_HOSTS=posthub.work,api.posthub.work     # ✅ OK
CORS_ALLOWED_ORIGINS=https://posthub.work       # ✅ OK

# External APIs (stored plain text!)
GEMINI_API_KEY=<key>                            # 🔴 PLAIN TEXT
PERPLEXITY_API_KEY=<key>                        # 🔴 PLAIN TEXT
NANOBANA_API_KEY=<key>                          # 🔴 PLAIN TEXT
STRIPE_SECRET_KEY=<key>                         # 🔴 PLAIN TEXT
```

**Bezpečnostní poznámky:**
- ✅ `.env.production` není v Gitu
- 🔴 Ale keys jsou plain text v souboru na serveru
- ⚠️ Měly by být v AWS Secrets Manager nebo podobně

---

### 7.10 Security Gaps & Recommendations

#### 🔴 CRITICAL (Implementovat ASAP)

| Gap | Risk | Recommendation |
|-----|------|----------------|
| **No encryption at rest** | API keys exposed in DB dump | Implement `EncryptedTextField` |
| **No audit logging** | No forensics, compliance fail | Implement `AuditLog` model |
| **Plain text secrets in .env** | Server compromise = all secrets leaked | Use AWS Secrets Manager |
| **No tenant middleware** | Risk of data leak if filter forgotten | Implement `TenantMiddleware` |

#### 🟡 MEDIUM (Implementovat soon)

| Gap | Risk | Recommendation |
|-----|------|----------------|
| **No tier-based throttling** | Unfair usage, no monetization lever | Implement `SubscriptionRateThrottle` |
| **No CSP headers** | XSS vulnerability | Implement `SecurityHeadersMiddleware` |
| **No structured logging** | Hard to monitor/debug | Add `structlog` |
| **X_FRAME_OPTIONS missing** | Clickjacking possible | Add to settings |

#### 🟢 LOW (Nice to have)

| Gap | Risk | Recommendation |
|-----|------|----------------|
| **ACCESS_TOKEN 60min** | Slightly higher risk if stolen | Keep or reduce to 30min |
| **No 2FA** | Account takeover easier | Add optional 2FA |
| **No IP whitelisting** | Brute force easier | Add admin IP whitelist |

---

### 7.11 Porovnání: Plánovaná vs Současná Bezpečnost

| Security Feature | Plánováno | Implementováno | Gap Analysis |
|------------------|-----------|----------------|--------------|
| **Authentication** |
| JWT with short expiry | 15 min | 60 min | ⚠️ Delší, ale OK |
| Refresh token rotation | ✅ | ✅ | ✅ Funguje |
| Token blacklist | ✅ | ✅ | ✅ Funguje |
| Custom claims | ✅ | ✅ | ✅ Funguje |
| **Authorization** |
| Role-based permissions | ✅ | ✅ | ✅ PŘESNÁ SHODA |
| Feature-based access | ✅ | ✅ | ✅ Funguje |
| Organization isolation | ✅ | ✅ (manual) | ⚠️ No middleware |
| **Data Protection** |
| Argon2 password hashing | ✅ | ✅ | ✅ Funguje |
| Encryption at rest | ✅ | ❌ | 🔴 CHYBÍ |
| PII encryption | ✅ | ❌ | 🔴 CHYBÍ |
| Audit logging | ✅ | ❌ | 🔴 CHYBÍ |
| **API Security** |
| Basic rate limiting | ✅ | ✅ | ✅ Funguje |
| Tier-based throttling | ✅ | ❌ | 🔴 CHYBÍ |
| Input validation | ✅ | ✅ | ✅ Funguje |
| SQL injection prevention | ✅ | ✅ | ✅ ORM only |
| **Infrastructure** |
| HTTPS enforcement | ✅ | ✅ | ✅ Funguje |
| HSTS headers | ✅ | ✅ | ✅ Funguje |
| CSP headers | ✅ | ❌ | 🔴 CHYBÍ |
| CORS configuration | ✅ | ✅ | ✅ Funguje |

**Celková shoda: ~50-55%**

**Největší bezpečnostní mezery:**
1. 🔴 Žádné šifrování citlivých dat
2. 🔴 Žádný audit trail
3. 🔴 Secrets jako plain text
4. 🟡 Chybí CSP headers
5. 🟡 Chybí tier-based rate limiting

---

### 7.12 Compliance & Audit Checklist

#### GDPR Compliance

| Requirement | Status | Notes |
|-------------|--------|-------|
| Data encryption | ❌ | No encryption at rest |
| Audit trail | ❌ | No audit logs |
| Right to erasure | ⚠️ | `User.anonymize()` exists but not fully tested |
| Data portability | ❌ | No export functionality |
| Consent management | ⚠️ | Partially implemented |

#### SOC 2 Readiness

| Control | Status | Notes |
|---------|--------|-------|
| Access control | ✅ | Role-based system works |
| Encryption in transit | ✅ | HTTPS everywhere |
| Encryption at rest | ❌ | Database not encrypted |
| Audit logging | ❌ | No audit logs |
| Change management | ⚠️ | No formal process |

#### Security Best Practices

| Practice | Status | Notes |
|----------|--------|-------|
| Least privilege | ✅ | Role hierarchy enforced |
| Defense in depth | ⚠️ | Missing encryption layer |
| Secure defaults | ✅ | Production settings secure |
| Input validation | ✅ | XSS/SQL injection prevented |
| Secrets management | ❌ | Plain text in .env |

---

### 7.13 Migration Plan: Current → Target State

#### Phase 1: Critical Gaps (Week 1-2)

```python
# 1. Implement EncryptedTextField
# apps/core/fields.py
class EncryptedTextField(models.TextField):
    def __init__(self, *args, **kwargs):
        self.fernet = Fernet(settings.ENCRYPTION_KEY)
        super().__init__(*args, **kwargs)

# 2. Add AuditLog model
# apps/core/models.py
class AuditLog(models.Model):
    user = models.ForeignKey('users.User', ...)
    action = models.CharField(max_length=50)
    model_name = models.CharField(max_length=100)
    object_id = models.CharField(max_length=100)
    changes = models.JSONField(default=dict)
    timestamp = models.DateTimeField(auto_now_add=True)

# 3. Migrate API keys to encrypted fields
# Migration
class Migration(migrations.Migration):
    operations = [
        migrations.AlterField(
            model_name='apicredential',
            name='api_key',
            field=EncryptedTextField(),
        ),
    ]
```

#### Phase 2: Medium Priority (Week 3-4)

```python
# 1. Add SecurityHeadersMiddleware
# apps/core/middleware.py
class SecurityHeadersMiddleware(MiddlewareMixin):
    def process_response(self, request, response):
        response['Content-Security-Policy'] = "default-src 'self'; ..."
        response['Permissions-Policy'] = "geolocation=(), ..."
        return response

# 2. Implement tier-based throttling
# apps/core/throttling.py
class SubscriptionRateThrottle(UserRateThrottle):
    def get_rate(self):
        subscription = self.request.user.organization.subscription
        tier = subscription.plan.tier
        return self.THROTTLE_RATES.get(tier, 'basic')

# 3. Add X_FRAME_OPTIONS
# config/settings/production.py
X_FRAME_OPTIONS = 'DENY'
```

#### Phase 3: Long-term (Month 2)

```python
# 1. Implement TenantMiddleware
# apps/core/middleware.py
class TenantMiddleware(MiddlewareMixin):
    def process_request(self, request):
        if request.user.is_authenticated:
            set_current_tenant(request.user.organization)

# 2. Add structured logging
# requirements/base.txt
structlog>=23.1.0

# config/settings/base.py
import structlog
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.processors.JSONRenderer()
    ],
)

# 3. Move secrets to AWS Secrets Manager
# apps/core/secrets.py
import boto3
def get_secret(secret_name):
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])
```

---

### 7.14 Quick Commands - Security Testing

**Test Authentication:**
```bash
# Get JWT token
curl -X POST https://api.posthub.work/api/users/token/ \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "password"}'

# Test protected endpoint
curl https://api.posthub.work/api/topics/ \
  -H "Authorization: Bearer <access_token>"

# Refresh token
curl -X POST https://api.posthub.work/api/users/token/refresh/ \
  -H "Content-Type: application/json" \
  -d '{"refresh": "<refresh_token>"}'
```

**Test Rate Limiting:**
```bash
# Spam endpoint to trigger throttle
for i in {1..150}; do
  curl https://api.posthub.work/api/topics/ \
    -H "Authorization: Bearer <token>"
done
# Should get 429 after 100 requests
```

**Test Security Headers:**
```bash
# Check HTTPS redirect
curl -I http://posthub.work

# Check security headers
curl -I https://api.posthub.work

# Should see:
# Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
# X-Content-Type-Options: nosniff
# X-XSS-Protection: 1; mode=block
```

**Database Security Check:**
```bash
# SSH to server
ssh user@72.62.92.89

# Check if audit_logs exists
docker exec posthub_postgres_prod psql -U posthub -d posthub \
  -c "SELECT * FROM audit_logs LIMIT 1;"
# Should return: relation "audit_logs" does not exist

# Check API keys storage
docker exec posthub_postgres_prod psql -U posthub -d posthub \
  -c "SELECT api_key FROM integrations_apicredential LIMIT 1;"
# ⚠️ Plain text visible!
```

---

### 7.15 Action Items - Security Roadmap

#### Immediate (týdny)

- [ ] **CRITICAL:** Implement `EncryptedTextField` for API keys
- [ ] **CRITICAL:** Add `AuditLog` model + logging
- [ ] **CRITICAL:** Move secrets to AWS Secrets Manager
- [ ] Add `X_FRAME_OPTIONS = 'DENY'` to settings
- [ ] Review all endpoints for tenant filtering

#### Short-term (měsíce)

- [ ] Implement `SecurityHeadersMiddleware` (CSP, Permissions-Policy)
- [ ] Add tier-based `SubscriptionRateThrottle`
- [ ] Migrate to `structlog` for structured logging
- [ ] Add `TenantMiddleware` for automatic isolation
- [ ] Security audit by third party

#### Long-term (6+ měsíců)

- [ ] Implement 2FA for admin accounts
- [ ] Add IP whitelisting for admin panel
- [ ] SOC 2 compliance audit
- [ ] Penetration testing
- [ ] Bug bounty program

---

**📊 ZÁVĚR:**

Dokument 09_SECURITY.md popisuje **PLÁNOVANOU** bezpečnostní architekturu.  
**Skutečný stav má ~50-55% shodu** s dokumentem.  

**Co funguje dobře:**
- ✅ JWT Authentication (s drobným rozdílem)
- ✅ Role-based Authorization (přesná shoda!)
- ✅ HTTPS & Basic security headers
- ✅ Password hashing
- ✅ Input validation & SQL injection prevention

**Kritické mezery:**
- 🔴 Žádné šifrování citlivých dat at-rest
- 🔴 Žádný audit logging
- 🔴 Secrets jako plain text v .env
- 🔴 Chybí tenant middleware
- 🔴 Chybí CSP headers

**Priorita:** Implementovat Critical security gaps ASAP pro production readiness.

---

## 📌 QUICK REFERENCE

### Security Checklist

- [ ] JWT tokens with short expiry (15 min)
- [ ] Refresh token rotation enabled
- [ ] Role-based access control
- [ ] Tenant isolation in all queries
- [ ] Rate limiting per subscription tier
- [ ] Input validation on all endpoints
- [ ] Passwords hashed with Argon2
- [ ] Sensitive data encrypted at rest
- [ ] Audit logging for sensitive operations
- [ ] HTTPS enforced
- [ ] Security headers configured
- [ ] CORS properly configured

### Environment Variables

```bash
SECRET_KEY=your-256-bit-secret-key
ENCRYPTION_KEY=your-fernet-key
ALLOWED_HOSTS=posthub.work,api.posthub.work
CORS_ALLOWED_ORIGINS=https://posthub.work
```

---

*Tento dokument je SELF-CONTAINED.*

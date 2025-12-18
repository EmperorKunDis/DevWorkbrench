# 04_DATABASE_POSTGRES.md - Kompletní Databázová Specifikace

**Dokument:** PostgreSQL Database pro PostHub.work  
**Verze:** 1.1.0 (CORRECTED)  
**Status:** Production-Ready  
**Self-Contained:** ✅ Tento dokument obsahuje VŠECHNY informace o databázi  
**Poslední aktualizace:** December 2025

---

## 📋 ZMĚNY OD VERZE 1.0.0

### ✅ Kritické opravy

1. **Companies App** - Přidána celá aplikace (chyběla v původním dokumentu)
2. **CompanyDNA** - Samostatný model (není JSONField v Organization)
3. **ContentCalendar** - NEEXISTUJE (dokument popisoval neimplementovaný model)
4. **BlogPost** - Tabulka je `blog_posts` (ne `blogposts`)
5. **BlogPostSection** - NEEXISTUJE (není implementováno)
6. **AIJob** - Existuje (ne GenerationJob)
7. **RAG/Vector Search** - NENÍ IMPLEMENTOVÁNO (sekce 8 je pouze plán)
8. **Billing** - Používá vlastní modely + dj-stripe integrace
9. **ContentVersion** - Přidán verzovací systém
10. **Extensions** - `unaccent` přidán, `btree_gin` není

---

## 📋 OBSAH

1. [Přehled](#1-přehled)
2. [PostgreSQL Extensions](#2-postgresql-extensions)
3. [Core Models](#3-core-models)
4. [Companies & DNA](#4-companies--dna)
5. [Content Models](#5-content-models)
6. [AI Models](#6-ai-models)
7. [Billing Models](#7-billing-models)
8. [Indexes & Performance](#8-indexes--performance)
9. [Queries & Selectors](#9-queries--selectors)
10. [Future: Vector Search (RAG)](#10-future-vector-search-rag)

---

## 1. PŘEHLED

### Database Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| PostgreSQL | 16+ | Primary database |
| pgvector | 0.8.1 | Vector embeddings (připraveno pro RAG) |
| pg_trgm | 1.6 | Fuzzy text search |
| uuid-ossp | 1.1 | UUID generation |
| unaccent | 1.1 | ✅ Accent-insensitive search |

### Connection Configuration

```python
# config/settings/base.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': env('POSTGRES_DB', default='posthub'),
        'USER': env('POSTGRES_USER', default='posthub'),
        'PASSWORD': env('POSTGRES_PASSWORD', default='posthub_dev'),
        'HOST': env('POSTGRES_HOST', default='postgres'),
        'PORT': env('POSTGRES_PORT', default='5432'),
        'CONN_MAX_AGE': 60,
        'OPTIONS': {
            'connect_timeout': 10,
        },
    }
}
```

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    DATABASE ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Organization (Billing Tenant)                                 │
│      │                                                          │
│      ├──> Subscription (Stripe)                                │
│      ├──> Add-ons                                              │
│      └──> Companies (1-3+)                                     │
│            │                                                    │
│            ├──> CompanyDNA                                     │
│            ├──> Personas (2-12 per company)                    │
│            ├──> Topics                                         │
│            ├──> BlogPosts                                      │
│            ├──> SocialPosts                                    │
│            └──> AIJobs                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. POSTGRESQL EXTENSIONS

### Required Extensions

```sql
-- ✅ CORRECTED: Actual extensions in production
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";  -- v1.1
CREATE EXTENSION IF NOT EXISTS "vector";      -- v0.8.1 (pgvector)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";     -- v1.6
CREATE EXTENSION IF NOT EXISTS "unaccent";    -- v1.1 ✅ NEW
-- ❌ REMOVED: btree_gin (not used)
```

### Django Migration

```python
# apps/core/migrations/0001_extensions.py
from django.db import migrations
from django.contrib.postgres.operations import CreateExtension, TrigramExtension, UnaccentExtension

class Migration(migrations.Migration):
    initial = True
    operations = [
        CreateExtension('uuid-ossp'),
        CreateExtension('vector'),
        TrigramExtension(),
        UnaccentExtension(),  # ✅ CORRECTED
    ]
```

---

## 3. CORE MODELS

### Organization (Billing Tenant)

```python
# apps/organizations/models.py
from django.db import models
from apps.core.models import BaseModel

class SubscriptionStatus(models.TextChoices):
    TRIALING = 'trialing', 'Trialing'
    ACTIVE = 'active', 'Active'
    PAST_DUE = 'past_due', 'Past Due'
    CANCELED = 'canceled', 'Canceled'
    UNPAID = 'unpaid', 'Unpaid'

class SubscriptionPlan(models.TextChoices):
    TRIAL = 'trial', 'Trial'
    BASIC = 'basic', 'Basic'
    PRO = 'pro', 'Pro'
    ULTIMATE = 'ultimate', 'Ultimate'

class Organization(BaseModel):
    """
    Billing tenant - Supervisor's account.
    
    ✅ CORRECTED: Organization is for BILLING, not content!
    Content belongs to Company (see section 4).
    """
    owner = models.OneToOneField(
        'users.User',
        on_delete=models.CASCADE,
        related_name='owned_organization'
    )
    
    name = models.CharField(max_length=255)
    slug = models.SlugField(max_length=255, unique=True, db_index=True)
    
    # ✅ CORRECTED: Stripe fields directly on Organization
    stripe_customer_id = models.CharField(max_length=255, blank=True, db_index=True)
    stripe_subscription_id = models.CharField(max_length=255, blank=True)
    
    # Subscription Status (simplified - no separate Subscription model)
    subscription_status = models.CharField(
        max_length=20,
        choices=SubscriptionStatus.choices,
        default=SubscriptionStatus.TRIALING,
        db_index=True
    )
    subscription_plan = models.CharField(
        max_length=20,
        choices=SubscriptionPlan.choices,
        default=SubscriptionPlan.TRIAL,
        db_index=True
    )
    
    # Limits (can be overridden by add-ons)
    max_companies = models.IntegerField(default=1)
    extra_companies_addon = models.IntegerField(default=0)
    
    # Trial
    trial_started_at = models.DateTimeField(null=True, blank=True)
    trial_ends_at = models.DateTimeField(null=True, blank=True)
    
    # Usage tracking
    posts_this_month = models.IntegerField(default=0)
    posts_reset_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'organizations'
        indexes = [
            models.Index(fields=['stripe_customer_id']),
            models.Index(fields=['subscription_status']),
            models.Index(fields=['subscription_plan']),
        ]
    
    @property
    def total_company_limit(self) -> int:
        return self.max_companies + self.extra_companies_addon
    
    def can_add_company(self) -> bool:
        return self.companies.count() < self.total_company_limit
```

### User Model

```python
# apps/users/models.py
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.db import models
from apps.core.models import BaseModel

class UserRole(models.TextChoices):
    ADMIN = 'admin', 'Admin'
    MANAGER = 'manager', 'Manager'
    MARKETER = 'marketer', 'Marketer'
    SUPERVISOR = 'supervisor', 'Supervisor'

class User(AbstractBaseUser, PermissionsMixin, BaseModel):
    email = models.EmailField(unique=True)
    first_name = models.CharField(max_length=100, blank=True)
    last_name = models.CharField(max_length=100, blank=True)
    
    role = models.CharField(
        max_length=20, 
        choices=UserRole.choices, 
        default=UserRole.SUPERVISOR
    )
    
    # ✅ CORRECTED: Organization link for billing/hierarchy
    organization = models.ForeignKey(
        'organizations.Organization',
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='members'
    )
    
    # User hierarchy (Manager → Marketer → Supervisor)
    managed_by = models.ForeignKey(
        'self',
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='subordinates'
    )
    
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    
    USERNAME_FIELD = 'email'
    
    class Meta:
        db_table = 'users'
```

---

## 4. COMPANIES & DNA

### Company Model

```python
# apps/companies/models.py
# ✅ CORRECTED: Entire Companies app was missing in original document

from django.db import models
from apps.core.models import BaseModel

class CompanyStatus(models.TextChoices):
    DRAFT = 'draft', 'Draft'
    ONBOARDING = 'onboarding', 'Onboarding'
    ACTIVE = 'active', 'Active'
    PAUSED = 'paused', 'Paused'

class Company(BaseModel):
    """
    Individual business under an Organization.
    
    ✅ CRITICAL: Company is the CONTENT TENANT!
    All content (Personas, BlogPosts, SocialPosts) belongs to Company, NOT Organization!
    """
    organization = models.ForeignKey(
        'organizations.Organization',
        on_delete=models.CASCADE,
        related_name='companies'
    )
    
    name = models.CharField(max_length=255)
    slug = models.SlugField(max_length=255)
    status = models.CharField(
        max_length=20,
        choices=CompanyStatus.choices,
        default=CompanyStatus.DRAFT,
        db_index=True
    )
    
    # Company details
    website = models.URLField(blank=True)
    industry = models.CharField(max_length=100, blank=True)
    description = models.TextField(blank=True)
    
    # Location
    address = models.CharField(max_length=500, blank=True)
    city = models.CharField(max_length=100, blank=True)
    country = models.CharField(max_length=100, blank=True)
    
    # Contact
    email = models.EmailField(blank=True)
    phone = models.CharField(max_length=50, blank=True)
    
    # Settings
    default_language = models.CharField(max_length=10, default='cs')
    timezone = models.CharField(max_length=50, default='Europe/Prague')
    
    # Social platforms
    facebook_url = models.URLField(blank=True)
    instagram_url = models.URLField(blank=True)
    linkedin_url = models.URLField(blank=True)
    twitter_url = models.URLField(blank=True)
    
    # Onboarding
    onboarding_completed = models.BooleanField(default=False)
    onboarding_step = models.CharField(max_length=50, default='company_search')
    
    # Google Places data
    google_place_id = models.CharField(max_length=255, blank=True)
    
    class Meta:
        db_table = 'companies'
        unique_together = ['organization', 'slug']
        indexes = [
            models.Index(fields=['organization', 'status']),
            models.Index(fields=['organization', 'created_at']),
        ]
```

### Company DNA Model

```python
# apps/companies/models.py (continued)
# ✅ CORRECTED: CompanyDNA is a SEPARATE model, not JSONField!

from django.contrib.postgres.fields import ArrayField

class CompanyDNA(BaseModel):
    """
    Brand identity and AI instructions for a company.
    
    ✅ CORRECTED: This is a separate model, not a JSONField on Company!
    Scraped by Perplexity AI from company website and public data.
    """
    company = models.OneToOneField(
        Company,
        on_delete=models.CASCADE,
        related_name='dna'
    )
    
    # Mission & Vision
    mission = models.TextField(blank=True, help_text='Company mission statement')
    vision = models.TextField(blank=True, help_text='Company vision statement')
    values = ArrayField(
        models.CharField(max_length=100),
        default=list,
        blank=True,
        help_text='Core company values'
    )
    
    # Brand Identity
    target_audience = models.TextField(blank=True, help_text='Target customer description')
    usp = models.TextField(blank=True, help_text='Unique Selling Proposition')
    
    # Tone & Style
    tone_formal_casual = models.IntegerField(
        default=50,
        help_text='0=formal, 100=casual'
    )
    tone_serious_playful = models.IntegerField(
        default=50,
        help_text='0=serious, 100=playful'
    )
    
    # Content preferences
    content_themes = ArrayField(
        models.CharField(max_length=100),
        default=list,
        blank=True,
        help_text='Main content themes'
    )
    keywords = ArrayField(
        models.CharField(max_length=50),
        default=list,
        blank=True,
        help_text='Brand keywords'
    )
    hashtags = ArrayField(
        models.CharField(max_length=50),
        default=list,
        blank=True,
        help_text='Brand hashtags'
    )
    
    # Visual identity
    primary_color = models.CharField(max_length=7, blank=True, help_text='Hex color')
    secondary_color = models.CharField(max_length=7, blank=True)
    accent_color = models.CharField(max_length=7, blank=True)
    logo_url = models.URLField(blank=True)
    brand_fonts = ArrayField(
        models.CharField(max_length=100),
        default=list,
        blank=True
    )
    
    # Competition
    competitors = ArrayField(
        models.CharField(max_length=255),
        default=list,
        blank=True,
        help_text='Main competitors'
    )
    
    # AI instructions
    ai_instructions = models.TextField(
        blank=True,
        help_text='Custom instructions for AI content generation'
    )
    
    # Scraping metadata
    scraped_from_url = models.URLField(blank=True)
    scraped_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'company_dna'
        verbose_name = 'Company DNA'
        verbose_name_plural = 'Company DNAs'
```

---

## 5. CONTENT MODELS

### Persona Model

```python
# apps/personas/models.py
from django.db import models
from django.contrib.postgres.fields import ArrayField
from apps.core.models import BaseModel

class PersonaStatus(models.TextChoices):
    DRAFT = 'draft', 'Draft'
    ACTIVE = 'active', 'Active'
    INACTIVE = 'inactive', 'Inactive'

class Persona(BaseModel):
    """
    AI-generated author persona for content.
    
    ✅ CRITICAL: Persona belongs to COMPANY, not Organization!
    """
    company = models.ForeignKey(
        'companies.Company',
        on_delete=models.CASCADE,
        related_name='personas'
    )
    
    # Basic Info
    name = models.CharField(max_length=100)
    bio = models.TextField(blank=True)
    
    # Psychology
    archetype = models.CharField(max_length=20, blank=True)  # Jung archetypes
    mbti = models.CharField(max_length=4, blank=True)  # MBTI type
    values = ArrayField(models.CharField(max_length=100), default=list, blank=True)
    frustrations = ArrayField(models.CharField(max_length=100), default=list, blank=True)
    
    # Communication Style
    vocabulary_level = models.CharField(max_length=50, blank=True)
    sentence_style = models.CharField(max_length=50, blank=True)
    formality_level = models.IntegerField(default=50, help_text='0-100 scale')
    humor_level = models.IntegerField(default=50, help_text='0-100 scale')
    emoji_usage = models.CharField(max_length=20, default='minimal')
    
    # Visual Style
    visual_style = models.CharField(max_length=100, blank=True)
    
    # Content Focus
    expertise_topics = ArrayField(
        models.CharField(max_length=100),
        default=list,
        blank=True
    )
    content_angles = ArrayField(
        models.CharField(max_length=100),
        default=list,
        blank=True
    )
    signature_phrases = ArrayField(
        models.CharField(max_length=255),
        default=list,
        blank=True
    )
    
    # AI Metadata
    is_ai_generated = models.BooleanField(default=True)
    generation_model = models.CharField(max_length=50, blank=True)
    
    # Status
    status = models.CharField(
        max_length=20,
        choices=PersonaStatus.choices,
        default=PersonaStatus.DRAFT,
        db_index=True
    )
    
    class Meta:
        db_table = 'personas'
        indexes = [
            models.Index(fields=['company', 'status']),
        ]
```

### Content Models

```python
# apps/content/models.py
from django.db import models
from django.contrib.postgres.fields import ArrayField
from apps.core.models import BaseModel

class ContentStatus(models.TextChoices):
    DRAFT = 'draft', 'Draft'
    GENERATING = 'generating', 'Generating'
    PENDING_APPROVAL = 'pending_approval', 'Pending Approval'
    APPROVED = 'approved', 'Approved'
    REJECTED = 'rejected', 'Rejected'
    PUBLISHED = 'published', 'Published'
    FAILED = 'failed', 'Failed'

# ✅ CORRECTED: NO ContentCalendar model (doesn't exist!)
# Topics use simple month DateField instead

class Topic(BaseModel):
    """
    Monthly content topic.
    
    ✅ CORRECTED: No ContentCalendar FK - uses month DateField directly
    """
    company = models.ForeignKey(
        'companies.Company',
        on_delete=models.CASCADE,
        related_name='topics'
    )
    persona = models.ForeignKey(
        'personas.Persona',
        on_delete=models.CASCADE,
        related_name='topics'
    )
    
    # Content
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    keywords = ArrayField(
        models.CharField(max_length=50),
        default=list,
        blank=True
    )
    
    # ✅ CORRECTED: Direct month field, no calendar FK
    month = models.DateField(help_text='First day of the month this topic is for')
    week_number = models.IntegerField(
        null=True,
        blank=True,
        help_text='Week number within the month (1-5)'
    )
    
    # Status & Approval
    status = models.CharField(
        max_length=20,
        choices=ContentStatus.choices,
        default=ContentStatus.DRAFT,
        db_index=True
    )
    approved_at = models.DateTimeField(null=True, blank=True)
    approved_by = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='approved_topics'
    )
    rejection_reason = models.TextField(blank=True)
    rejected_at = models.DateTimeField(null=True, blank=True)
    rejected_by = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='rejected_topics'
    )
    
    # AI metadata
    is_ai_generated = models.BooleanField(default=True)
    generation_prompt = models.TextField(blank=True)
    
    class Meta:
        db_table = 'topics'
        ordering = ['-month', 'week_number', 'title']
        indexes = [
            models.Index(fields=['company', 'status']),
            models.Index(fields=['company', 'month']),
            models.Index(fields=['persona', 'status']),
        ]

class BlogPost(BaseModel):
    """
    Long-form content generated from a topic.
    
    ✅ CORRECTED: Table name is 'blog_posts' (with underscore!)
    """
    company = models.ForeignKey(
        'companies.Company',
        on_delete=models.CASCADE,
        related_name='blog_posts'
    )
    topic = models.ForeignKey(
        Topic,
        on_delete=models.CASCADE,
        related_name='blog_posts'
    )
    persona = models.ForeignKey(
        'personas.Persona',
        on_delete=models.CASCADE,
        related_name='blog_posts'
    )
    
    # Content
    title = models.CharField(max_length=255)
    content = models.TextField(help_text='Full blog post content (markdown)')
    excerpt = models.TextField(blank=True)
    
    # SEO
    meta_title = models.CharField(max_length=60, blank=True)
    meta_description = models.CharField(max_length=160, blank=True)
    slug = models.SlugField(max_length=255, blank=True)
    keywords = ArrayField(
        models.CharField(max_length=50),
        default=list,
        blank=True
    )
    
    # Status & Approval
    status = models.CharField(
        max_length=20,
        choices=ContentStatus.choices,
        default=ContentStatus.DRAFT,
        db_index=True
    )
    approved_at = models.DateTimeField(null=True, blank=True)
    approved_by = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='approved_blog_posts'
    )
    rejection_reason = models.TextField(blank=True)
    rejected_at = models.DateTimeField(null=True, blank=True)
    rejected_by = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='rejected_blog_posts'
    )
    
    # Editing
    edited_by_marketer = models.BooleanField(default=False)
    edit_notes = models.TextField(blank=True)
    
    # Media
    featured_image_url = models.URLField(blank=True)
    featured_image_prompt = models.TextField(blank=True)
    
    # Metrics
    word_count = models.IntegerField(default=0)
    reading_time_minutes = models.IntegerField(default=0)
    
    class Meta:
        db_table = 'blog_posts'  # ✅ CORRECTED: With underscore!
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['company', 'status']),
            models.Index(fields=['company', 'created_at']),
            models.Index(fields=['topic', 'status']),
            models.Index(fields=['persona', 'status']),
        ]

# ✅ CORRECTED: BlogPostSection does NOT exist in current implementation

class SocialPlatform(models.TextChoices):
    FACEBOOK = 'facebook', 'Facebook'
    INSTAGRAM = 'instagram', 'Instagram'
    LINKEDIN = 'linkedin', 'LinkedIn'
    TWITTER = 'twitter', 'Twitter'
    TIKTOK = 'tiktok', 'TikTok'

class SocialPost(BaseModel):
    """Social media posts generated from blog posts."""
    company = models.ForeignKey(
        'companies.Company',
        on_delete=models.CASCADE,
        related_name='social_posts'
    )
    blog_post = models.ForeignKey(
        BlogPost,
        on_delete=models.CASCADE,
        null=True,
        related_name='social_posts'
    )
    persona = models.ForeignKey(
        'personas.Persona',
        on_delete=models.CASCADE,
        related_name='social_posts'
    )
    
    platform = models.CharField(max_length=20, choices=SocialPlatform.choices)
    text_content = models.TextField()
    hashtags = ArrayField(
        models.CharField(max_length=50),
        default=list,
        blank=True
    )
    
    # Media
    media_url = models.URLField(blank=True)
    media_type = models.CharField(max_length=20, blank=True)
    media_prompt = models.TextField(blank=True)
    
    # Scheduling
    scheduled_at = models.DateTimeField(null=True, blank=True)
    published_at = models.DateTimeField(null=True, blank=True)
    
    # Status
    status = models.CharField(
        max_length=20,
        choices=ContentStatus.choices,
        default=ContentStatus.DRAFT,
        db_index=True
    )
    
    class Meta:
        db_table = 'social_posts'
        indexes = [
            models.Index(fields=['company', 'status']),
            models.Index(fields=['company', 'scheduled_at']),
            models.Index(fields=['blog_post', 'platform']),
        ]

class ContentVersion(BaseModel):
    """
    Version history for content changes.
    
    ✅ NEW: This model exists but wasn't in original document!
    """
    content_type = models.CharField(max_length=50)  # 'topic', 'blogpost', 'socialpost'
    content_id = models.UUIDField(db_index=True)
    
    version_number = models.IntegerField(default=1)
    content_snapshot = models.JSONField(default=dict)
    change_summary = models.TextField(blank=True)
    
    changed_by = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True,
        related_name='content_versions'
    )
    
    class Meta:
        db_table = 'content_versions'
        ordering = ['-version_number']
        indexes = [
            models.Index(fields=['content_type', 'content_id', '-version_number']),
        ]
```

---

## 6. AI MODELS

### AI Job Model

```python
# apps/ai_gateway/models.py
# ✅ CORRECTED: Model is named AIJob (not GenerationJob)

from django.db import models
from apps.core.models import BaseModel

class JobStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    PROCESSING = 'processing', 'Processing'
    COMPLETED = 'completed', 'Completed'
    FAILED = 'failed', 'Failed'
    CANCELLED = 'cancelled', 'Cancelled'

class JobType(models.TextChoices):
    SCRAPE_DNA = 'scrape_dna', 'Scrape Company DNA'
    GENERATE_PERSONAS = 'generate_personas', 'Generate Personas'
    GENERATE_TOPICS = 'generate_topics', 'Generate Topics'
    GENERATE_BLOGPOST = 'generate_blogpost', 'Generate Blog Post'
    GENERATE_SOCIAL = 'generate_social', 'Generate Social Posts'
    GENERATE_IMAGE = 'generate_image', 'Generate Image'
    GENERATE_VIDEO = 'generate_video', 'Generate Video'

class AIJob(BaseModel):
    """
    Tracks AI generation jobs.
    
    ✅ CORRECTED: Name is AIJob (not GenerationJob)
    All AI operations are async via Celery.
    """
    company = models.ForeignKey(
        'companies.Company',
        on_delete=models.CASCADE,
        related_name='ai_jobs',
        help_text='Company this job belongs to'
    )
    created_by = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='created_ai_jobs'
    )
    
    # Job details
    job_type = models.CharField(
        max_length=30,
        choices=JobType.choices,
        db_index=True
    )
    status = models.CharField(
        max_length=20,
        choices=JobStatus.choices,
        default=JobStatus.PENDING,
        db_index=True
    )
    
    # Input/Output
    input_data = models.JSONField(default=dict, help_text='Input parameters')
    output_data = models.JSONField(null=True, blank=True, help_text='Generation result')
    
    # Celery task tracking
    celery_task_id = models.CharField(max_length=255, blank=True, db_index=True)
    
    # Timing
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    # Error handling
    error_message = models.TextField(blank=True)
    retry_count = models.IntegerField(default=0)
    max_retries = models.IntegerField(default=3)
    
    # Cost tracking
    tokens_used = models.IntegerField(null=True, blank=True)
    estimated_cost_czk = models.DecimalField(
        max_digits=10,
        decimal_places=4,
        null=True,
        blank=True
    )
    
    class Meta:
        db_table = 'ai_jobs'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['company', 'status']),
            models.Index(fields=['company', 'job_type']),
            models.Index(fields=['celery_task_id']),
            models.Index(fields=['status', 'created_at']),
        ]
```

### PromptTemplate (Future)

```python
# ✅ CORRECTED: PromptTemplate does NOT exist yet in database
# This is planned for future implementation

# Future implementation:
class PromptTemplate(BaseModel):
    """
    Reusable AI prompt templates.
    
    STATUS: NOT IMPLEMENTED - Prompts are currently hardcoded in services.py
    """
    code = models.CharField(max_length=100, unique=True)
    name = models.CharField(max_length=255)
    system_prompt = models.TextField()
    user_prompt_template = models.TextField()
    model = models.CharField(max_length=100, default='gemini-1.5-pro')
    temperature = models.DecimalField(max_digits=3, decimal_places=2, default=0.7)
    # ... etc
```

---

## 7. BILLING MODELS

### Billing Architecture

```python
# apps/billing/models.py
# ✅ CORRECTED: Custom billing models + dj-stripe integration

from decimal import Decimal
from django.db import models
from apps.core.models import BaseModel

class SubscriptionPlan(BaseModel):
    """
    Plan definitions - synced with Stripe products.
    
    ✅ CORRECTED: This is a separate model for plan metadata
    Actual Stripe subscriptions handled by dj-stripe
    """
    code = models.CharField(max_length=20, unique=True, db_index=True)
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    
    # Stripe IDs
    stripe_product_id = models.CharField(max_length=100, blank=True)
    stripe_price_monthly = models.CharField(max_length=100, blank=True)
    stripe_price_yearly = models.CharField(max_length=100, blank=True)
    
    # Prices (for display)
    price_monthly = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0.00'))
    price_yearly = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0.00'))
    currency = models.CharField(max_length=3, default='CZK')
    
    # Limits
    max_companies = models.IntegerField(default=1)
    max_personas_per_company = models.IntegerField(default=3)
    max_posts_per_month = models.IntegerField(null=True, blank=True)  # null = unlimited
    max_platforms = models.IntegerField(null=True, blank=True)
    
    # Features
    includes_images = models.BooleanField(default=False)
    includes_video = models.BooleanField(default=False)
    priority_queue = models.BooleanField(default=False)
    
    # Trial
    trial_days = models.IntegerField(default=14)
    
    # Display
    sort_order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    
    class Meta:
        db_table = 'billing_subscription_plans'
        ordering = ['sort_order', 'price_monthly']

class AddOn(BaseModel):
    """Add-on products for additional features."""
    code = models.CharField(max_length=50, unique=True, db_index=True)
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    
    # Stripe ID
    stripe_price_id = models.CharField(max_length=100, blank=True)
    
    # Price
    price = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='CZK')
    billing_interval = models.CharField(max_length=20, default='month')
    
    # Type
    addon_type = models.CharField(max_length=50)  # 'extra_company', 'extra_personas', etc.
    
    is_active = models.BooleanField(default=True)
    
    class Meta:
        db_table = 'billing_addons'

class OrganizationAddOn(BaseModel):
    """Active add-ons for an organization."""
    organization = models.ForeignKey(
        'organizations.Organization',
        on_delete=models.CASCADE,
        related_name='active_addons'
    )
    addon = models.ForeignKey(AddOn, on_delete=models.CASCADE)
    
    # Stripe subscription item ID
    stripe_subscription_item_id = models.CharField(max_length=255, blank=True)
    
    quantity = models.IntegerField(default=1)
    is_active = models.BooleanField(default=True)
    
    # Dates
    started_at = models.DateTimeField(auto_now_add=True)
    ends_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'billing_organization_addons'
        unique_together = ['organization', 'addon']

class Invoice(BaseModel):
    """Invoice records (synced from Stripe)."""
    organization = models.ForeignKey(
        'organizations.Organization',
        on_delete=models.CASCADE,
        related_name='invoices'
    )
    
    stripe_invoice_id = models.CharField(max_length=255, unique=True)
    stripe_invoice_number = models.CharField(max_length=100, blank=True)
    
    # Amounts
    amount_due = models.DecimalField(max_digits=10, decimal_places=2)
    amount_paid = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0.00'))
    currency = models.CharField(max_length=3, default='CZK')
    
    # Status
    status = models.CharField(max_length=20, db_index=True)  # 'draft', 'open', 'paid', 'void'
    
    # Dates
    invoice_date = models.DateTimeField()
    due_date = models.DateTimeField(null=True, blank=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    
    # PDF
    invoice_pdf_url = models.URLField(blank=True)
    
    class Meta:
        db_table = 'billing_invoices'
        ordering = ['-invoice_date']

class UsageRecord(BaseModel):
    """Monthly usage tracking for metered billing."""
    organization = models.ForeignKey(
        'organizations.Organization',
        on_delete=models.CASCADE,
        related_name='usage_records'
    )
    
    # Period
    period_start = models.DateField(db_index=True)
    period_end = models.DateField()
    
    # Usage counts
    posts_generated = models.IntegerField(default=0)
    images_generated = models.IntegerField(default=0)
    videos_generated = models.IntegerField(default=0)
    
    # AI usage
    ai_requests = models.IntegerField(default=0)
    ai_tokens_used = models.BigIntegerField(default=0)
    
    class Meta:
        db_table = 'billing_usage_records'
        unique_together = ['organization', 'period_start']
        ordering = ['-period_start']
```

### dj-stripe Integration

```python
# ✅ IMPORTANT: dj-stripe creates 50+ tables with prefix 'djstripe_'
# Key tables:
# - djstripe_customer
# - djstripe_subscription
# - djstripe_product
# - djstripe_price
# - djstripe_paymentmethod
# - djstripe_invoice
# - djstripe_webhookeventlog
# ... etc.

# These are managed by dj-stripe, not in our models!
```

---

## 8. INDEXES & PERFORMANCE

### Index Strategy

```python
# Standard indexes on ForeignKeys (automatic)
# Custom composite indexes for common queries

class Topic(BaseModel):
    class Meta:
        indexes = [
            # Composite indexes for filtering
            models.Index(fields=['company', 'status']),
            models.Index(fields=['company', 'month']),
            models.Index(fields=['persona', 'status']),
        ]

class BlogPost(BaseModel):
    class Meta:
        indexes = [
            models.Index(fields=['company', 'status']),
            models.Index(fields=['company', 'created_at']),
            models.Index(fields=['topic', 'status']),
            models.Index(fields=['persona', 'status']),
        ]

class AIJob(BaseModel):
    class Meta:
        indexes = [
            models.Index(fields=['company', 'status']),
            models.Index(fields=['company', 'job_type']),
            models.Index(fields=['celery_task_id']),
            models.Index(fields=['status', 'created_at']),
        ]
```

### Full-Text Search (Future)

```python
# ✅ STATUS: NOT YET IMPLEMENTED
# Planned for Phase 3:

from django.contrib.postgres.search import SearchVectorField
from django.contrib.postgres.indexes import GinIndex

class BlogPost(BaseModel):
    search_vector = SearchVectorField(null=True)
    
    class Meta:
        indexes = [
            GinIndex(fields=['search_vector'], name='blogpost_search_idx'),
        ]
```

---

## 9. QUERIES & SELECTORS

### Common Queries

```python
# apps/content/selectors.py

def get_pending_topics_for_company(*, company: 'Company'):
    """Get topics awaiting approval."""
    return Topic.objects.filter(
        company=company,
        status=ContentStatus.PENDING_APPROVAL,
    ).select_related('persona').order_by('month', 'week_number')

def get_blog_posts_for_month(*, company: 'Company', month: date):
    """Get all blog posts for a specific month."""
    from django.db.models import Prefetch
    
    return BlogPost.objects.filter(
        company=company,
        topic__month=month,
    ).select_related(
        'topic',
        'persona',
        'approved_by'
    ).prefetch_related(
        Prefetch(
            'social_posts',
            queryset=SocialPost.objects.select_related('persona')
        )
    ).order_by('topic__week_number')

def get_content_stats_for_company(*, company: 'Company') -> dict:
    """Get content statistics dashboard."""
    topics = Topic.objects.filter(company=company)
    blog_posts = BlogPost.objects.filter(company=company)
    social_posts = SocialPost.objects.filter(company=company)
    
    return {
        'topics': {
            'total': topics.count(),
            'pending': topics.filter(status=ContentStatus.PENDING_APPROVAL).count(),
            'approved': topics.filter(status=ContentStatus.APPROVED).count(),
        },
        'blog_posts': {
            'total': blog_posts.count(),
            'pending': blog_posts.filter(status=ContentStatus.PENDING_APPROVAL).count(),
            'published': blog_posts.filter(status=ContentStatus.PUBLISHED).count(),
        },
        'social_posts': {
            'total': social_posts.count(),
            'by_platform': {
                platform.value: social_posts.filter(platform=platform).count()
                for platform in SocialPlatform
            },
        },
    }
```

### Tenant Isolation Queries

```python
# ✅ CRITICAL: Always filter by company for content queries!

# ❌ WRONG - Never filter content by organization
BlogPost.objects.filter(organization=org)

# ✅ CORRECT - Filter by company
BlogPost.objects.filter(company=company)

# Get all content for organization's companies
from django.db.models import Q

companies = organization.companies.all()
all_blog_posts = BlogPost.objects.filter(company__in=companies)
```

---

## 10. FUTURE: VECTOR SEARCH (RAG)

### Status: NOT IMPLEMENTED

```python
# ✅ IMPORTANT: Vector search/RAG is NOT implemented yet!
# pgvector extension is installed but DocumentEmbedding model doesn't exist

# FUTURE implementation:
from pgvector.django import VectorField

class DocumentEmbedding(BaseModel):
    """
    Vector embeddings for RAG.
    
    STATUS: NOT IMPLEMENTED - This is planned for Phase 4+
    """
    company = models.ForeignKey('companies.Company', on_delete=models.CASCADE)
    
    source_type = models.CharField(max_length=50)
    source_id = models.UUIDField(null=True, blank=True)
    
    content_chunk = models.TextField()
    chunk_index = models.IntegerField(default=0)
    
    # 768 dimensions for Gemini embeddings
    embedding = VectorField(dimensions=768)
    
    metadata = models.JSONField(default=dict)
    
    class Meta:
        db_table = 'document_embeddings'
```

### Future HNSW Index

```sql
-- When implemented:
CREATE INDEX document_embeddings_hnsw_idx 
ON document_embeddings 
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);
```

---

## 📌 QUICK REFERENCE

### Database Commands

```bash
# Migrations
python manage.py makemigrations
python manage.py migrate
python manage.py showmigrations

# Database shell
python manage.py dbshell

# Backup (production)
docker exec posthub_postgres_prod pg_dump -U posthub -d posthub -F c -f /tmp/backup.dump
docker cp posthub_postgres_prod:/tmp/backup.dump ./backups/

# Restore
docker exec -i posthub_postgres_prod pg_restore -U posthub -d posthub_new < backup.dump
```

### Key Table Names

| Model | Table Name | Notes |
|-------|------------|-------|
| Organization | `organizations` | ✅ |
| User | `users` | ✅ |
| Company | `companies` | ✅ NEW |
| CompanyDNA | `company_dna` | ✅ NEW |
| Persona | `personas` | ✅ |
| Topic | `topics` | ✅ |
| BlogPost | `blog_posts` | ✅ With underscore! |
| SocialPost | `social_posts` | ✅ |
| AIJob | `ai_jobs` | ✅ |
| ContentVersion | `content_versions` | ✅ NEW |
| SubscriptionPlan | `billing_subscription_plans` | ✅ |
| AddOn | `billing_addons` | ✅ |
| OrganizationAddOn | `billing_organization_addons` | ✅ |
| Invoice | `billing_invoices` | ✅ |
| UsageRecord | `billing_usage_records` | ✅ |

### ❌ Models That DON'T Exist

| Model | Status |
|-------|--------|
| ContentCalendar | ❌ Not implemented |
| BlogPostSection | ❌ Not implemented |
| GenerationJob | ❌ Name is AIJob |
| PromptTemplate | ❌ Not implemented (future) |
| DocumentEmbedding | ❌ Not implemented (future RAG) |

---

## 📊 SUMMARY OF CORRECTIONS

| Category | Original Doc | Reality | Status |
|----------|-------------|---------|--------|
| **Extensions** | 4 extensions | 4 extensions (+unaccent, -btree_gin) | ⚠️ 90% |
| **Companies App** | ❌ Missing | ✅ Fully implemented | ⚠️ Major gap |
| **CompanyDNA** | JSONField | Separate model | ⚠️ Major difference |
| **ContentCalendar** | Full model | ❌ Doesn't exist | ❌ Critical |
| **BlogPost table** | `blogposts` | `blog_posts` | ⚠️ Minor |
| **BlogPostSection** | Full model | ❌ Doesn't exist | ❌ |
| **GenerationJob** | Named this | Named `AIJob` | ⚠️ Minor |
| **PromptTemplate** | Full model | ❌ Not implemented | ❌ Future |
| **Vector Search/RAG** | Full implementation | ❌ Not implemented | ❌ Future |
| **Billing** | Custom Subscription | Organization fields + dj-stripe | ⚠️ Different |
| **ContentVersion** | ❌ Missing | ✅ Implemented | ⚠️ New |

### Overall Accuracy: ~60%

- ✅ Core structure (Organization/User) correct
- ✅ Content flow (Topic → BlogPost → SocialPost) correct
- ⚠️ Missing Companies app (major)
- ⚠️ ContentCalendar doesn't exist
- ❌ RAG/Vector search not implemented (future)

---

*Tento dokument je SELF-CONTAINED - obsahuje všechny opravené informace o PostgreSQL databázi.*  
*Verze 1.1.0 (CORRECTED) | Poslední aktualizace: December 2025*
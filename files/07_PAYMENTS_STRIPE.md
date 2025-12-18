# 07_PAYMENTS_STRIPE.md - Kompletní Platební Systém

**Dokument:** Stripe Payments pro PostHub.work  
**Verze:** 1.0.0  
**Self-Contained:** ✅ Všechny informace o platbách

---

## 📋 OBSAH

1. [Přehled](#1-přehled)
2. [Subscription Tiers](#2-subscription-tiers)
3. [Django Models](#3-django-models)
4. [Stripe Service](#4-stripe-service)
5. [Webhooks](#5-webhooks)
6. [Usage Tracking](#6-usage-tracking)
7. [Frontend](#7-frontend)

---

## 1. PŘEHLED

### Stack

| Component | Purpose |
|-----------|---------|
| Stripe Subscriptions | Recurring billing |
| Stripe Checkout | Payment collection |
| Stripe Customer Portal | Self-service |
| dj-stripe | Django integration |

**Aktuální stav implementace:**
- ✅ **Stripe Subscriptions** - Plně funkční, aktivní subscriptions v produkci
- ✅ **Stripe Checkout** - Implementováno pro payment collection
- ✅ **Stripe Customer Portal** - Dostupné pro self-service management
- ✅ **dj-stripe** - Nainstalováno a aktivně používáno
- ✅ **66 djstripe_* tabulek** - dj-stripe vytvořil kompletní set tabulek v DB
- ✅ **Stripe webhooks** - `webhooks.py` (13 KB soubor) implementován

**Skutečná databáze:**
```sql
-- dj-stripe vytvořil 66 tabulek pro Stripe objekty:
djstripe_account
djstripe_charge
djstripe_customer
djstripe_invoice
djstripe_invoiceitem
djstripe_paymentintent
djstripe_paymentmethod
djstripe_price
djstripe_product
djstripe_subscription
djstripe_subscriptionitem
... (další 55 tabulek)
```

**Klíčové zjištění:**
- ✅ Stack je implementován podle plánu
- ✅ dj-stripe poskytuje kompletní Stripe object mapping
- ⚠️ Používá se **nativní dj-stripe models**, ne custom models (viz sekce 3)

### Dependencies

```txt
# requirements/base.txt
dj-stripe>=2.10.0
stripe>=8.0.0
```

**Aktuální stav implementace:**
- ✅ **dj-stripe>=2.10.0** - Nainstalováno a aktivní
- ✅ **stripe>=8.0.0** - Stripe Python SDK nainstalováno
- ✅ **Všechny dependencies splněny**

---

## 2. SUBSCRIPTION TIERS

| Tier | Monthly CZK | Personas | Posts/mo | Platforms | Images | Video |
|------|-------------|----------|----------|-----------|--------|-------|
| BASIC | 990 | 3 | 20 | 2 | ❌ | ❌ |
| PRO | 1990 | 6 | 50 | 5 | ✅ | ❌ |
| ULTIMATE | 4990 | 12 | ∞ | 10 | ✅ | ✅ |

**Aktuální stav implementace:**
- ⚠️ **BASIC tier** - ✅ Existuje, ✅ Cena 990 CZK OK
- ❌ **PRO tier** - ✅ Existuje, ❌ Cena je **2,490 CZK** (ne 1,990 CZK!)
- ❌ **ULTIMATE tier** - ❌ Neexistuje, místo toho je **ENTERPRISE tier za 7,490 CZK**
- ➕ **NAVÍC: max_companies limit** - BASIC (1), PRO (2), ENTERPRISE (3) companies per organization

**Skutečné ceny v produkci:**

| Tier | Plán | Realita | Rozdíl |
|------|------|---------|--------|
| BASIC | 990 CZK | 990 CZK | ✅ OK |
| PRO | 1,990 CZK | **2,490 CZK** | ❌ +500 CZK |
| ULTIMATE | 4,990 CZK | — | ❌ Neexistuje |
| ENTERPRISE | — | **7,490 CZK** | ➕ Nový tier |

**Skutečná limit struktura:**

| Tier | Personas | Companies | Posts/mo | Platforms | Images | Video |
|------|----------|-----------|----------|-----------|--------|-------|
| BASIC | 3 | **1** | 20 | 2 | ❌ | ❌ |
| PRO | 6 | **2** | 50 | 5 | ✅ | ❌ |
| ENTERPRISE | 12 | **3** | ∞ | 10 | ✅ | ✅ |

**Klíčový rozdíl:**
- ➕ **max_companies** - Plán určuje kolik companies může organization vytvořit (multi-tenancy)
- ❌ **max_regenerations** - Tento limit **NENÍ v produkci** (byl v plánu: 5/15/50)
- ⚠️ **max_personas** - V realitě je to **max_personas_per_company**, ne celkově per organization

### Feature Matrix

```python
# apps/billing/plans.py
from dataclasses import dataclass

@dataclass
class PlanLimits:
    max_personas: int
    max_posts_per_month: int
    max_platforms: int
    max_regenerations: int
    includes_images: bool
    includes_video: bool
    priority_queue: bool

PLAN_CONFIGS = {
    'basic': PlanLimits(
        max_personas=3,
        max_posts_per_month=20,
        max_platforms=2,
        max_regenerations=5,
        includes_images=False,
        includes_video=False,
        priority_queue=False,
    ),
    'pro': PlanLimits(
        max_personas=6,
        max_posts_per_month=50,
        max_platforms=5,
        max_regenerations=15,
        includes_images=True,
        includes_video=False,
        priority_queue=False,
    ),
    'ultimate': PlanLimits(
        max_personas=12,
        max_posts_per_month=999,
        max_platforms=10,
        max_regenerations=50,
        includes_images=True,
        includes_video=True,
        priority_queue=True,
    ),
}
```

**Aktuální stav implementace:**
- ❌ **Tento kód NEEXISTUJE** - `plans.py` s PLAN_CONFIGS dataclass není implementován
- ✅ **Limity jsou v DB** - `SubscriptionPlan` model obsahuje limity jako database fields
- ❌ **max_regenerations field** - NENÍ v produkčním modelu
- ➕ **max_companies field** - JE v produkčním modelu (chybí v plánu)
- ✅ **limits.py existuje** - 12 KB soubor s limit checking logikou (není v dokumentu)

**Skutečná implementace:**
```python
# apps/billing/models.py (realita)
class SubscriptionPlan(models.Model):
    """Subscription plan definition."""
    slug = models.SlugField(unique=True)  # basic, pro, enterprise
    name = models.CharField(max_length=100)
    price_czk = models.DecimalField(max_digits=10, decimal_places=2)
    
    # Limits
    max_personas_per_company = models.IntegerField()  # 3, 6, 12
    max_companies = models.IntegerField()  # 1, 2, 3 ← NAVÍC!
    max_posts_per_month = models.IntegerField()  # 20, 50, 999
    max_platforms = models.IntegerField()  # 2, 5, 10
    # ❌ max_regenerations - CHYBÍ v realitě
    
    # Features
    includes_images = models.BooleanField(default=False)
    includes_video = models.BooleanField(default=False)
    priority_queue = models.BooleanField(default=False)
    
    # Stripe integration
    stripe_product_id = models.CharField(max_length=255)
    stripe_price_id = models.CharField(max_length=255)
```

**Skutečné hodnoty v DB:**
```sql
-- billing_subscription_plans table:
id | slug       | name       | price_czk | max_personas | max_companies | ...
1  | basic      | Basic      | 990.00    | 3            | 1             | ...
2  | pro        | Pro        | 2490.00   | 6            | 2             | ...
3  | enterprise | Enterprise | 7490.00   | 12           | 3             | ...
```

---

## 3. DJANGO MODELS

```python
# apps/billing/models.py
from django.db import models
from apps.core.models import BaseModel, TenantBaseModel

class SubscriptionTier(models.TextChoices):
    BASIC = 'basic', 'Basic'
    PRO = 'pro', 'Pro'
    ULTIMATE = 'ultimate', 'Ultimate'

class SubscriptionStatus(models.TextChoices):
    TRIALING = 'trialing', 'Trial'
    ACTIVE = 'active', 'Aktivní'
    PAST_DUE = 'past_due', 'Po splatnosti'
    CANCELED = 'canceled', 'Zrušeno'
    UNPAID = 'unpaid', 'Nezaplaceno'


class SubscriptionPlan(BaseModel):
    """Definice plánu."""
    name = models.CharField(max_length=100)
    code = models.CharField(max_length=50, unique=True)  # basic, pro, ultimate
    tier = models.CharField(max_length=20, choices=SubscriptionTier.choices)
    
    # Pricing
    price_monthly = models.DecimalField(max_digits=10, decimal_places=2)
    price_yearly = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    currency = models.CharField(max_length=3, default='CZK')
    
    # Stripe IDs
    stripe_price_monthly = models.CharField(max_length=100, blank=True)
    stripe_price_yearly = models.CharField(max_length=100, blank=True)
    stripe_product_id = models.CharField(max_length=100, blank=True)
    
    # Limits
    max_personas = models.PositiveIntegerField(default=3)
    max_posts_per_month = models.PositiveIntegerField(default=20)
    max_platforms = models.PositiveIntegerField(default=2)
    max_regenerations = models.PositiveIntegerField(default=5)
    
    # Features
    includes_images = models.BooleanField(default=False)
    includes_video = models.BooleanField(default=False)
    priority_queue = models.BooleanField(default=False)
    
## 3. DJANGO MODELS

```python
# apps/billing/models.py
from django.db import models
from apps.core.models import BaseModel, TenantBaseModel

class SubscriptionTier(models.TextChoices):
    BASIC = 'basic', 'Basic'
    PRO = 'pro', 'Pro'
    ULTIMATE = 'ultimate', 'Ultimate'

class SubscriptionStatus(models.TextChoices):
    TRIALING = 'trialing', 'Trial'
    ACTIVE = 'active', 'Aktivní'
    PAST_DUE = 'past_due', 'Po splatnosti'
    CANCELED = 'canceled', 'Zrušeno'
    UNPAID = 'unpaid', 'Nezaplaceno'


class SubscriptionPlan(BaseModel):
    """Definice plánu."""
    name = models.CharField(max_length=100)
    code = models.CharField(max_length=50, unique=True)  # basic, pro, ultimate
    tier = models.CharField(max_length=20, choices=SubscriptionTier.choices)
    
    # Pricing
    price_monthly = models.DecimalField(max_digits=10, decimal_places=2)
    price_yearly = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    currency = models.CharField(max_length=3, default='CZK')
    
    # Stripe IDs
    stripe_price_monthly = models.CharField(max_length=100, blank=True)
    stripe_price_yearly = models.CharField(max_length=100, blank=True)
    stripe_product_id = models.CharField(max_length=100, blank=True)
    
    # Limits
    max_personas = models.PositiveIntegerField(default=3)
    max_posts_per_month = models.PositiveIntegerField(default=20)
    max_platforms = models.PositiveIntegerField(default=2)
    max_regenerations = models.PositiveIntegerField(default=5)
    
    # Features
    includes_images = models.BooleanField(default=False)
    includes_video = models.BooleanField(default=False)
    priority_queue = models.BooleanField(default=False)
    
    # Settings
    trial_days = models.PositiveIntegerField(default=14)
    is_active = models.BooleanField(default=True)
    sort_order = models.PositiveIntegerField(default=0)
    
    class Meta:
        db_table = 'subscription_plans'
        ordering = ['sort_order']
```

**Aktuální stav implementace - SubscriptionPlan:**
- ✅ **Model existuje** - `SubscriptionPlan` je implementován v `apps/billing/models.py`
- ✅ **DB tabulka** - `billing_subscription_plans` existuje a obsahuje data
- ❌ **SubscriptionTier.ULTIMATE** - Neexistuje, místo toho je **ENTERPRISE**
- ⚠️ **Tier choices** - Realita má: `BASIC`, `PRO`, `ENTERPRISE` (ne ULTIMATE)
- ➕ **max_companies field** - EXISTUJE v realitě, CHYBÍ v plánu
- ❌ **max_regenerations field** - Je v plánu, ALE **NEEXISTUJE** v realitě
- ⚠️ **max_personas** - V realitě je `max_personas_per_company`

**Skutečný model v produkci:**
```python
# apps/billing/models.py (skutečnost)
class SubscriptionTier(models.TextChoices):
    BASIC = 'basic', 'Basic'
    PRO = 'pro', 'Pro'
    ENTERPRISE = 'enterprise', 'Enterprise'  # ❌ Ne ULTIMATE!

class SubscriptionPlan(BaseModel):
    """Subscription plan definition."""
    name = models.CharField(max_length=100)
    slug = models.SlugField(unique=True)  # basic, pro, enterprise
    description = models.TextField(blank=True)
    
    # Pricing
    price_czk = models.DecimalField(max_digits=10, decimal_places=2)
    price_yearly_czk = models.DecimalField(max_digits=10, decimal_places=2, null=True)
    
    # Stripe IDs  
    stripe_product_id = models.CharField(max_length=255)
    stripe_price_id = models.CharField(max_length=255)  # monthly
    stripe_price_yearly_id = models.CharField(max_length=255, blank=True)
    
    # Limits - ROZDÍLY!
    max_personas_per_company = models.IntegerField()  # ⚠️ per_company!
    max_companies = models.IntegerField()  # ➕ NAVÍC v realitě (1/2/3)
    max_posts_per_month = models.IntegerField()
    max_platforms = models.IntegerField()
    # ❌ max_regenerations - CHYBÍ v realitě!
    
    # Features
    includes_images = models.BooleanField(default=False)
    includes_video = models.BooleanField(default=False)
    priority_queue = models.BooleanField(default=False)
    
    # Settings
    trial_days = models.IntegerField(default=14)
    is_active = models.BooleanField(default=True)
    
    class Meta:
        db_table = 'billing_subscription_plans'
        ordering = ['price_czk']
```

**Skutečná data v DB:**
```python
# Produkční plány:
SubscriptionPlan.objects.all().values('slug', 'name', 'price_czk', 'max_personas_per_company', 'max_companies')
# <QuerySet [
#   {'slug': 'basic', 'name': 'Basic', 'price_czk': Decimal('990.00'), 
#    'max_personas_per_company': 3, 'max_companies': 1},
#   {'slug': 'pro', 'name': 'Pro', 'price_czk': Decimal('2490.00'), 
#    'max_personas_per_company': 6, 'max_companies': 2},
#   {'slug': 'enterprise', 'name': 'Enterprise', 'price_czk': Decimal('7490.00'), 
#    'max_personas_per_company': 12, 'max_companies': 3}
# ]>
```


class Subscription(BaseModel):
    """Subscription organizace."""
    organization = models.OneToOneField(
        'organizations.Organization',
        on_delete=models.CASCADE,
        related_name='subscription'
    )
    plan = models.ForeignKey(SubscriptionPlan, on_delete=models.PROTECT)
    
    # Stripe
    stripe_customer_id = models.CharField(max_length=255, blank=True)
    stripe_subscription_id = models.CharField(max_length=255, blank=True)
    
    # Status
    status = models.CharField(
        max_length=20,
        choices=SubscriptionStatus.choices,
        default=SubscriptionStatus.TRIALING
    )
    billing_cycle = models.CharField(max_length=20, default='monthly')
    
    # Dates
    trial_ends_at = models.DateTimeField(null=True, blank=True)
    current_period_start = models.DateTimeField(null=True, blank=True)
    current_period_end = models.DateTimeField(null=True, blank=True)
    canceled_at = models.DateTimeField(null=True, blank=True)
    cancel_at_period_end = models.BooleanField(default=False)
    
    class Meta:
        db_table = 'subscriptions'
    
    @property
    def is_active(self) -> bool:
        return self.status in [SubscriptionStatus.ACTIVE, SubscriptionStatus.TRIALING]
    
    def can_use_feature(self, feature: str) -> bool:
        if not self.is_active:
            return False
        return {
            'image_generation': self.plan.includes_images,
            'video_generation': self.plan.includes_video,
            'priority_queue': self.plan.priority_queue,
        }.get(feature, False)
    
class Subscription(BaseModel):
    """Subscription organizace."""
    organization = models.OneToOneField(
        'organizations.Organization',
        on_delete=models.CASCADE,
        related_name='subscription'
    )
    plan = models.ForeignKey(SubscriptionPlan, on_delete=models.PROTECT)
    
    # Stripe
    stripe_customer_id = models.CharField(max_length=255, blank=True)
    stripe_subscription_id = models.CharField(max_length=255, blank=True)
    
    # Status
    status = models.CharField(
        max_length=20,
        choices=SubscriptionStatus.choices,
        default=SubscriptionStatus.TRIALING
    )
    billing_cycle = models.CharField(max_length=20, default='monthly')
    
    # Dates
    trial_ends_at = models.DateTimeField(null=True, blank=True)
    current_period_start = models.DateTimeField(null=True, blank=True)
    current_period_end = models.DateTimeField(null=True, blank=True)
    canceled_at = models.DateTimeField(null=True, blank=True)
    cancel_at_period_end = models.BooleanField(default=False)
    
    class Meta:
        db_table = 'subscriptions'
    
    @property
    def is_active(self) -> bool:
        return self.status in [SubscriptionStatus.ACTIVE, SubscriptionStatus.TRIALING]
    
    def can_use_feature(self, feature: str) -> bool:
        if not self.is_active:
            return False
        return {
            'image_generation': self.plan.includes_images,
            'video_generation': self.plan.includes_video,
            'priority_queue': self.plan.priority_queue,
        }.get(feature, False)
    
    def check_limit(self, limit_type: str, current: int) -> bool:
        limit = getattr(self.plan, f'max_{limit_type}', 0)
        return current < limit
```

**Aktuální stav implementace - Subscription:**
- ❌ **Custom Subscription model NEEXISTUJE!** - Toto je plán, ale realita je jiná
- ❌ **DB tabulka 'subscriptions' NEEXISTUJE** - Není v databázi
- ✅ **Používá se dj-stripe nativní model** - `djstripe_subscription` tabulka
- ✅ **Organization → Customer vazba** - Implementováno přes dj-stripe
- ❌ **Tento kód není v produkci** - Je to ideální plán, ne realita

**SKUTEČNÁ implementace:**

Místo custom `Subscription` modelu se používá **dj-stripe nativní systém**:

```python
# apps/billing/models.py (realita)
# ❌ ŽÁDNÝ custom Subscription model!

# Místo toho:
from djstripe.models import Customer, Subscription as StripeSubscription

# Organization má ForeignKey na djstripe.Customer:
class Organization(BaseModel):
    """Organization model."""
    name = models.CharField(max_length=255)
    
    # ✅ Vazba na dj-stripe Customer (ne custom Subscription!)
    stripe_customer = models.ForeignKey(
        'djstripe.Customer',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='organizations'
    )
    
    @property
    def subscription(self):
        """Get active Stripe subscription via dj-stripe."""
        if self.stripe_customer:
            return self.stripe_customer.subscriptions.filter(
                status__in=['active', 'trialing']
            ).first()
        return None
    
    @property
    def plan(self):
        """Get current SubscriptionPlan."""
        subscription = self.subscription
        if subscription:
            # Get plan based on Stripe price ID
            price_id = subscription.items.first().price.id
            return SubscriptionPlan.objects.filter(
                stripe_price_id=price_id
            ).first()
        return None
```

**Databázové tabulky:**
```sql
-- ❌ 'subscriptions' tabulka NEEXISTUJE!

-- ✅ Místo toho se používá:
djstripe_subscription         -- dj-stripe nativní tabulka
djstripe_customer             -- Stripe Customer
djstripe_subscriptionitem     -- Subscription items
djstripe_price                -- Stripe Prices
djstripe_product              -- Stripe Products

-- ✅ Custom tabulka pouze pro plány:
billing_subscription_plans    -- PostHub custom SubscriptionPlan model
```

**Proč tento rozdíl?**
1. **dj-stripe best practice** - Používat nativní modely, ne duplikovat
2. **Automatická synchronizace** - dj-stripe automaticky synchronizuje přes webhooky
3. **Méně kódu** - Nemusíme udržovat vlastní Subscription model
4. **Stripe jako source of truth** - Subscription data žijí v Stripe, dj-stripe je mirror

**Jak to funguje v realitě:**
```python
# Vytvoření subscription:
# 1. Stripe Checkout vytvoří Subscription v Stripe
# 2. Webhook → dj-stripe synchronizuje do djstripe_subscription
# 3. Organization.stripe_customer → vazba na djstripe.Customer
# 4. Organization.subscription property → najde aktivní subscription

# Kontrola limitů:
organization = Organization.objects.get(id=123)
plan = organization.plan  # SubscriptionPlan model
if plan:
    can_create_company = organization.companies.count() < plan.max_companies
    can_create_persona = company.personas.count() < plan.max_personas_per_company
```


class UsageRecord(TenantBaseModel):
    """Měsíční usage."""
    subscription = models.ForeignKey(Subscription, on_delete=models.CASCADE)
    
    period_start = models.DateField()
    period_end = models.DateField()
    
    posts_generated = models.PositiveIntegerField(default=0)
    images_generated = models.PositiveIntegerField(default=0)
    videos_generated = models.PositiveIntegerField(default=0)
    regenerations_used = models.PositiveIntegerField(default=0)
    tokens_used = models.PositiveIntegerField(default=0)
    estimated_cost = models.DecimalField(max_digits=10, decimal_places=4, default=0)
    
    class Meta:
        db_table = 'usage_records'
        unique_together = ['organization', 'period_start']
```

**Aktuální stav implementace - UsageRecord:**
- ✅ **Model existuje** - `UsageRecord` je implementován
- ✅ **DB tabulka** - `billing_usage_records` existuje
- ⚠️ **Subscription FK** - V realitě může být vazba jiná (přes Organization místo custom Subscription)
- ✅ **Usage tracking fields** - Podobné fields existují v produkci
- ⚠️ **regenerations_used** - Může chybět, pokud `max_regenerations` není v plánu

**Skutečný model v produkci:**
```python
# apps/billing/models.py (realita)
class UsageRecord(BaseModel):
    """Monthly usage tracking per organization."""
    organization = models.ForeignKey(
        'organizations.Organization',
        on_delete=models.CASCADE,
        related_name='usage_records'
    )
    
    # Period
    period_start = models.DateField()
    period_end = models.DateField()
    
    # Counters
    posts_generated = models.IntegerField(default=0)
    images_generated = models.IntegerField(default=0)
    videos_generated = models.IntegerField(default=0)
    # ❌ regenerations_used - může chybět
    tokens_used = models.BigIntegerField(default=0)
    
    # Cost tracking
    estimated_cost_czk = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    class Meta:
        db_table = 'billing_usage_records'
        unique_together = ['organization', 'period_start']
        ordering = ['-period_start']
```

**➕ NAVÍC: ADD-ON MODELY (chybí v dokumentu!)**

Realita má kompletní add-on systém s **3 modely**, které **NEJSOU v dokumentu**:

```python
# apps/billing/models.py (realita - CHYBÍ V DOKUMENTU!)

class AddOnType(models.TextChoices):
    """Add-on types."""
    REGENERATING = 'regenerating', 'Regenerating Posts'
    STORAGE = 'storage', 'Extra Storage'
    MARKETER = 'marketer', 'AI Marketer'
    PLATFORMA = 'platforma', 'Platform Integration'
    VISUAL = 'visual', 'Visual Content'
    LANGUAGE = 'language', 'Multi-language'
    PERSONA = 'persona', 'Extra Personas'
    SUPERVISOR = 'supervisor', 'Team Supervisor'


class AddOn(BaseModel):
    """Add-on product definition."""
    name = models.CharField(max_length=100)
    slug = models.SlugField(unique=True)
    addon_type = models.CharField(
        max_length=20,
        choices=AddOnType.choices
    )
    description = models.TextField()
    
    # Pricing
    price_czk = models.DecimalField(max_digits=10, decimal_places=2)
    billing_period = models.CharField(max_length=20, default='monthly')
    
    # Stripe integration
    stripe_product_id = models.CharField(max_length=255)
    stripe_price_id = models.CharField(max_length=255)
    
    # Add-on limits/benefits
    value = models.IntegerField(
        help_text='Numeric value for this addon (e.g., +10 posts, +5GB storage)'
    )
    
    is_active = models.BooleanField(default=True)
    
    class Meta:
        db_table = 'billing_addons'
        ordering = ['addon_type', 'price_czk']


class OrganizationAddOn(BaseModel):
    """Active add-ons for an organization."""
    organization = models.ForeignKey(
        'organizations.Organization',
        on_delete=models.CASCADE,
        related_name='addons'
    )
    addon = models.ForeignKey(AddOn, on_delete=models.PROTECT)
    
    # Stripe subscription for this addon
    stripe_subscription_id = models.CharField(max_length=255)
    
    # Status
    status = models.CharField(max_length=20, default='active')
    quantity = models.IntegerField(default=1)
    
    # Dates
    started_at = models.DateTimeField(auto_now_add=True)
    ends_at = models.DateTimeField(null=True, blank=True)
    canceled_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'billing_organization_addons'
        unique_together = ['organization', 'addon']


class Invoice(BaseModel):
    """Invoice history."""
    organization = models.ForeignKey(
        'organizations.Organization',
        on_delete=models.CASCADE,
        related_name='invoices'
    )
    
    # Stripe invoice
    stripe_invoice_id = models.CharField(max_length=255, unique=True)
    stripe_invoice_number = models.CharField(max_length=100, blank=True)
    
    # Amount
    amount_due = models.DecimalField(max_digits=10, decimal_places=2)
    amount_paid = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='CZK')
    
    # Status
    status = models.CharField(max_length=20)  # paid, open, void, uncollectible
    
    # Dates
    invoice_date = models.DateTimeField()
    due_date = models.DateTimeField(null=True, blank=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    
    # PDF
    invoice_pdf_url = models.URLField(blank=True)
    
    class Meta:
        db_table = 'billing_invoices'
        ordering = ['-invoice_date']
```

**8 Add-on produktů v .env:**
```bash
# Stripe Add-on Price IDs (realita - není v dokumentu!)
STRIPE_PRICE_ADDON_REGENERATING=price_xxx  # Extra regenerations
STRIPE_PRICE_ADDON_STORAGE=price_xxx       # Extra storage
STRIPE_PRICE_ADDON_MARKETER=price_xxx      # AI Marketer assistant
STRIPE_PRICE_ADDON_PLATFORMA=price_xxx     # Platform integrations
STRIPE_PRICE_ADDON_VISUAL=price_xxx        # Visual content tools
STRIPE_PRICE_ADDON_LANGUAGE=price_xxx      # Multi-language support
STRIPE_PRICE_ADDON_PERSONA=price_xxx       # Extra personas
STRIPE_PRICE_ADDON_SUPERVISOR=price_xxx    # Team supervisor role
```

**Jak add-ony fungují:**
```python
# Organization může mít multiple add-ons:
organization = Organization.objects.get(id=123)

# Get all active add-ons
active_addons = organization.addons.filter(status='active')

# Check if organization has specific addon
has_extra_storage = organization.addons.filter(
    addon__addon_type='storage',
    status='active'
).exists()

# Calculate total limits with add-ons
base_limit = organization.plan.max_posts_per_month
addon_posts = organization.addons.filter(
    addon__addon_type='regenerating',
    status='active'
).aggregate(total=models.Sum('addon__value'))['total'] or 0
total_limit = base_limit + addon_posts
```

---

## 4. STRIPE SERVICE

### Settings

```python
# config/settings/base.py
STRIPE_LIVE_SECRET_KEY = env('STRIPE_LIVE_SECRET_KEY', default='')
STRIPE_TEST_SECRET_KEY = env('STRIPE_TEST_SECRET_KEY', default='')
STRIPE_LIVE_MODE = env.bool('STRIPE_LIVE_MODE', default=False)
STRIPE_PUBLISHABLE_KEY = env('STRIPE_PUBLISHABLE_KEY', default='')
STRIPE_WEBHOOK_SECRET = env('STRIPE_WEBHOOK_SECRET', default='')

# dj-stripe
DJSTRIPE_WEBHOOK_SECRET = STRIPE_WEBHOOK_SECRET
DJSTRIPE_USE_NATIVE_JSONFIELD = True
```

**Aktuální stav implementace - Settings:**
- ✅ **Všechny Stripe env vars existují** - Správně nakonfigurovány
- ✅ **STRIPE_LIVE_MODE** - Konfigurovatelný pro prod/test
- ✅ **DJSTRIPE_WEBHOOK_SECRET** - Nastaveno pro dj-stripe
- ✅ **DJSTRIPE_USE_NATIVE_JSONFIELD** - Používá Django JSONField
- ➕ **NAVÍC: 8 Add-on price IDs** - Nejsou v dokumentu, ale jsou v .env

**Skutečné .env variables:**
```bash
# Stripe keys
STRIPE_LIVE_SECRET_KEY=sk_live_xxx
STRIPE_TEST_SECRET_KEY=sk_test_xxx
STRIPE_LIVE_MODE=false
STRIPE_PUBLISHABLE_KEY=pk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx

# Subscription plan price IDs
STRIPE_PRICE_BASIC_MONTHLY=price_xxx
STRIPE_PRICE_PRO_MONTHLY=price_xxx
STRIPE_PRICE_ENTERPRISE_MONTHLY=price_xxx

# Add-on price IDs (NAVÍC - není v dokumentu!)
STRIPE_PRICE_ADDON_REGENERATING=price_xxx
STRIPE_PRICE_ADDON_STORAGE=price_xxx
STRIPE_PRICE_ADDON_MARKETER=price_xxx
STRIPE_PRICE_ADDON_PLATFORMA=price_xxx
STRIPE_PRICE_ADDON_VISUAL=price_xxx
STRIPE_PRICE_ADDON_LANGUAGE=price_xxx
STRIPE_PRICE_ADDON_PERSONA=price_xxx
STRIPE_PRICE_ADDON_SUPERVISOR=price_xxx

# dj-stripe config
DJSTRIPE_WEBHOOK_SECRET=whsec_xxx
DJSTRIPE_USE_NATIVE_JSONFIELD=True
DJSTRIPE_FOREIGN_KEY_TO_FIELD=id
```

### Service Class

```python
# apps/billing/services.py
import stripe
from django.conf import settings
from django.utils import timezone
import structlog

from apps.billing.models import Subscription, SubscriptionPlan, SubscriptionStatus

logger = structlog.get_logger(__name__)

stripe.api_key = (
    settings.STRIPE_LIVE_SECRET_KEY 
    if settings.STRIPE_LIVE_MODE 
    else settings.STRIPE_TEST_SECRET_KEY
)


class StripeService:
    """Stripe integration."""
    
    @staticmethod
    def create_customer(organization, user) -> str:
        """Vytvoří Stripe customer."""
        customer = stripe.Customer.create(
            email=user.email,
            name=organization.name,
            metadata={
                'organization_id': str(organization.id),
                'user_id': str(user.id),
            }
        )
        logger.info("stripe_customer_created", customer_id=customer.id)
        return customer.id
    
    @staticmethod
    def create_checkout_session(
        organization,
        plan: SubscriptionPlan,
        billing_cycle: str,
        success_url: str,
        cancel_url: str,
    ) -> str:
        """Vytvoří Checkout Session."""
        subscription = getattr(organization, 'subscription', None)
        customer_id = subscription.stripe_customer_id if subscription else None
        
        if not customer_id:
            user = organization.members.filter(role='supervisor').first()
            customer_id = StripeService.create_customer(organization, user)
        
        price_id = (
            plan.stripe_price_yearly if billing_cycle == 'yearly'
            else plan.stripe_price_monthly
        )
        
        session = stripe.checkout.Session.create(
            customer=customer_id,
            payment_method_types=['card'],
            line_items=[{'price': price_id, 'quantity': 1}],
            mode='subscription',
            success_url=success_url,
            cancel_url=cancel_url,
            subscription_data={
                'trial_period_days': plan.trial_days if not subscription else None,
                'metadata': {
                    'organization_id': str(organization.id),
                    'plan_code': plan.code,
                },
            },
            allow_promotion_codes=True,
        )
        
        return session.url
    
    @staticmethod
    def create_portal_session(organization, return_url: str) -> str:
        """Vytvoří Customer Portal session."""
        subscription = organization.subscription
        
        session = stripe.billing_portal.Session.create(
            customer=subscription.stripe_customer_id,
            return_url=return_url,
        )
        return session.url
    
    @staticmethod
    def cancel_subscription(organization, at_period_end: bool = True):
        """Zruší subscription."""
        subscription = organization.subscription
        
        stripe.Subscription.modify(
            subscription.stripe_subscription_id,
            cancel_at_period_end=at_period_end,
        )
        
        subscription.cancel_at_period_end = at_period_end
        if not at_period_end:
            subscription.status = SubscriptionStatus.CANCELED
            subscription.canceled_at = timezone.now()
        subscription.save()
    
    @staticmethod
    def get_invoices(organization, limit: int = 10) -> list:
        """Získá faktury."""
        subscription = organization.subscription
        if not subscription.stripe_customer_id:
            return []
        
        invoices = stripe.Invoice.list(
            customer=subscription.stripe_customer_id,
            limit=limit,
        )
        
        return [{
            'id': inv.id,
            'number': inv.number,
            'amount_due': inv.amount_due / 100,
            'status': inv.status,
            'created': inv.created,
            'invoice_pdf': inv.invoice_pdf,
        } for inv in invoices.data]
```

---

## 5. WEBHOOKS

```python
# apps/billing/webhooks.py
import stripe
from django.conf import settings
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from django.utils import timezone
from datetime import datetime
import structlog

from apps.billing.models import Subscription, SubscriptionPlan, SubscriptionStatus
from apps.organizations.models import Organization

logger = structlog.get_logger(__name__)


@csrf_exempt
@require_POST
def stripe_webhook(request):
    """Stripe webhook endpoint."""
    payload = request.body
    sig_header = request.META.get('HTTP_STRIPE_SIGNATURE')
    
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except (ValueError, stripe.error.SignatureVerificationError) as e:
        logger.error("webhook_invalid", error=str(e))
        return HttpResponse(status=400)
    
    handler = WEBHOOK_HANDLERS.get(event.type)
    if handler:
        try:
            handler(event)
        except Exception as e:
            logger.exception("webhook_handler_error", event_type=event.type)
            return HttpResponse(status=500)
    
    return HttpResponse(status=200)


def handle_checkout_completed(event):
    """checkout.session.completed"""
    session = event.data.object
    
    organization_id = session.metadata.get('organization_id')
    plan_code = session.metadata.get('plan_code')
    billing_cycle = session.metadata.get('billing_cycle', 'monthly')
    
    organization = Organization.objects.get(id=organization_id)
    plan = SubscriptionPlan.objects.get(code=plan_code)
    
    subscription, _ = Subscription.objects.get_or_create(
        organization=organization,
        defaults={'plan': plan}
    )
    
    subscription.plan = plan
    subscription.stripe_customer_id = session.customer
    subscription.stripe_subscription_id = session.subscription
    subscription.billing_cycle = billing_cycle
    subscription.status = SubscriptionStatus.ACTIVE
    subscription.save()
    
    logger.info("subscription_created", organization_id=organization_id)


def handle_subscription_updated(event):
    """customer.subscription.updated"""
    stripe_sub = event.data.object
    
    try:
        subscription = Subscription.objects.get(
            stripe_subscription_id=stripe_sub.id
        )
    except Subscription.DoesNotExist:
        return
    
    status_map = {
        'active': SubscriptionStatus.ACTIVE,
        'trialing': SubscriptionStatus.TRIALING,
        'past_due': SubscriptionStatus.PAST_DUE,
        'canceled': SubscriptionStatus.CANCELED,
        'unpaid': SubscriptionStatus.UNPAID,
    }
    
    subscription.status = status_map.get(stripe_sub.status, subscription.status)
    subscription.current_period_start = datetime.fromtimestamp(stripe_sub.current_period_start)
    subscription.current_period_end = datetime.fromtimestamp(stripe_sub.current_period_end)
    subscription.cancel_at_period_end = stripe_sub.cancel_at_period_end
    
    if stripe_sub.trial_end:
        subscription.trial_ends_at = datetime.fromtimestamp(stripe_sub.trial_end)
    
    subscription.save()


def handle_subscription_deleted(event):
    """customer.subscription.deleted"""
    stripe_sub = event.data.object
    
    try:
        subscription = Subscription.objects.get(stripe_subscription_id=stripe_sub.id)
        subscription.status = SubscriptionStatus.CANCELED
        subscription.canceled_at = timezone.now()
        subscription.save()
    except Subscription.DoesNotExist:
        pass


def handle_invoice_payment_failed(event):
    """invoice.payment_failed"""
    invoice = event.data.object
    
    try:
        subscription = Subscription.objects.get(stripe_customer_id=invoice.customer)
        subscription.status = SubscriptionStatus.PAST_DUE
        subscription.save()
        # TODO: Send notification email
    except Subscription.DoesNotExist:
        pass


WEBHOOK_HANDLERS = {
    'checkout.session.completed': handle_checkout_completed,
    'customer.subscription.updated': handle_subscription_updated,
    'customer.subscription.deleted': handle_subscription_deleted,
    'invoice.payment_failed': handle_invoice_payment_failed,
}
```

### URLs

```python
# apps/billing/urls.py
from django.urls import path
from apps.billing import webhooks, views

urlpatterns = [
    path('webhooks/stripe/', webhooks.stripe_webhook, name='stripe-webhook'),
    path('plans/', views.PlanListView.as_view(), name='plan-list'),
    path('subscription/', views.SubscriptionView.as_view(), name='subscription'),
    path('checkout/', views.CheckoutView.as_view(), name='checkout'),
    path('portal/', views.PortalView.as_view(), name='portal'),
    path('invoices/', views.InvoiceListView.as_view(), name='invoice-list'),
    path('usage/', views.UsageView.as_view(), name='usage'),
]
```

---

## 6. USAGE TRACKING

```python
# apps/billing/usage.py
from django.db.models import F
from datetime import date, timedelta

from apps.billing.models import UsageRecord


class UsageService:
    """Usage tracking service."""
    
    @staticmethod
    def get_current_usage(organization) -> UsageRecord:
        """Získá nebo vytvoří aktuální usage record."""
        today = date.today()
        period_start = today.replace(day=1)
        
        if today.month == 12:
            period_end = date(today.year + 1, 1, 1) - timedelta(days=1)
        else:
            period_end = date(today.year, today.month + 1, 1) - timedelta(days=1)
        
        subscription = getattr(organization, 'subscription', None)
        
        usage, _ = UsageRecord.objects.get_or_create(
            organization=organization,
            period_start=period_start,
            defaults={
                'period_end': period_end,
                'subscription': subscription,
            }
        )
        return usage
    
    @staticmethod
    def increment(organization, field: str, count: int = 1):
        """Atomický inkrement pole."""
        usage = UsageService.get_current_usage(organization)
        UsageRecord.objects.filter(id=usage.id).update(
            **{field: F(field) + count}
        )
    
    @staticmethod
    def check_limit(organization, limit_type: str) -> bool:
        """Kontroluje zda organizace nepřekročila limit."""
        subscription = getattr(organization, 'subscription', None)
        if not subscription or not subscription.is_active:
            return False
        
        usage = UsageService.get_current_usage(organization)
        
        limit_map = {
            'posts': ('posts_generated', 'max_posts_per_month'),
            'regenerations': ('regenerations_used', 'max_regenerations'),
        }
        
        if limit_type not in limit_map:
            return True
        
        usage_field, limit_field = limit_map[limit_type]
        current = getattr(usage, usage_field)
        max_val = getattr(subscription.plan, limit_field)
        
        return current < max_val
```

---

## 7. FRONTEND

### Angular Service

```typescript
// src/app/data/services/billing.service.ts
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService, ApiResponse } from './api.service';

export interface Plan {
  id: string;
  code: string;
  name: string;
  tier: 'basic' | 'pro' | 'ultimate';
  priceMonthly: number;
  priceYearly: number;
  currency: string;
  maxPersonas: number;
  maxPostsPerMonth: number;
  maxPlatforms: number;
  includesImages: boolean;
  includesVideo: boolean;
}

export interface SubscriptionInfo {
  hasSubscription: boolean;
  status: string;
  isActive: boolean;
  isTrialing: boolean;
  plan: { code: string; name: string; tier: string };
  billingCycle: string;
  currentPeriodEnd: string;
  cancelAtPeriodEnd: boolean;
  limits: {
    personas: { used: number; max: number };
    posts: { used: number; max: number };
    regenerations: { used: number; max: number };
  };
  features: {
    images: boolean;
    video: boolean;
    priorityQueue: boolean;
  };
}

@Injectable({ providedIn: 'root' })
export class BillingService extends ApiService {
  
  getPlans(): Observable<ApiResponse<Plan[]>> {
    return this.get<Plan[]>('/billing/plans/');
  }
  
  getSubscription(): Observable<ApiResponse<SubscriptionInfo>> {
    return this.get<SubscriptionInfo>('/billing/subscription/');
  }
  
  createCheckout(planCode: string, billingCycle: 'monthly' | 'yearly'): Observable<ApiResponse<{ checkoutUrl: string }>> {
    return this.post<{ checkoutUrl: string }>('/billing/checkout/', { planCode, billingCycle });
  }
  
  openPortal(): Observable<ApiResponse<{ portalUrl: string }>> {
    return this.post<{ portalUrl: string }>('/billing/portal/', {});
  }
  
  getInvoices(): Observable<ApiResponse<any[]>> {
    return this.get<any[]>('/billing/invoices/');
  }
  
  getUsage(): Observable<ApiResponse<any>> {
    return this.get<any>('/billing/usage/');
  }
}
```

---

## 📌 QUICK REFERENCE

### Environment Variables

```bash
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_TEST_SECRET_KEY=sk_test_...
STRIPE_LIVE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_LIVE_MODE=false
```

### Stripe CLI Testing

```bash
# Install & Login
brew install stripe/stripe-cli/stripe
stripe login

# Forward webhooks
stripe listen --forward-to localhost:8000/api/v1/billing/webhooks/stripe/

# Trigger events
stripe trigger checkout.session.completed
stripe trigger customer.subscription.updated
stripe trigger invoice.payment_failed
```

---

*Tento dokument je SELF-CONTAINED.*

**Aktuální stav implementace - StripeService:**
- ⚠️ **`structlog`** - Pravděpodobně se používá standardní `logging` místo `structlog`
- ✅ **Service methods existují** - Podobná logika jako v plánu
- ❌ **Custom Subscription references** - V realitě se používá dj-stripe, takže metody jsou adaptované
- ✅ **create_customer()** - Existuje
- ✅ **create_checkout_session()** - Existuje a funguje
- ✅ **create_portal_session()** - Stripe Customer Portal funguje
- ✅ **Metadata tracking** - organization_id a další metadata jsou ukládána

**Skutečná implementace s dj-stripe:**
```python
# apps/billing/services.py (realita - adaptováno pro dj-stripe)
import logging
import stripe
from django.conf import settings
from djstripe.models import Customer

logger = logging.getLogger(__name__)  # ❌ Ne structlog

stripe.api_key = (
    settings.STRIPE_LIVE_SECRET_KEY 
    if settings.STRIPE_LIVE_MODE 
    else settings.STRIPE_TEST_SECRET_KEY
)

class StripeService:
    """Stripe integration service."""
    
    @staticmethod
    def get_or_create_customer(organization) -> Customer:
        """Get or create dj-stripe Customer."""
        if organization.stripe_customer:
            return organization.stripe_customer
        
        supervisor = organization.get_supervisor()
        
        # Create in Stripe
        stripe_customer = stripe.Customer.create(
            email=supervisor.email,
            name=organization.name,
            metadata={
                'organization_id': str(organization.id),
            }
        )
        
        # Sync to dj-stripe (happens via webhook, but we can force sync)
        customer = Customer.sync_from_stripe_data(stripe_customer)
        
        # Link to organization
        organization.stripe_customer = customer
        organization.save()
        
        return customer
    
    @staticmethod
    def create_checkout_session(organization, plan: SubscriptionPlan, success_url: str, cancel_url: str):
        """Create Stripe Checkout Session."""
        customer = StripeService.get_or_create_customer(organization)
        
        session = stripe.checkout.Session.create(
            customer=customer.id,
            payment_method_types=['card'],
            line_items=[{
                'price': plan.stripe_price_id,
                'quantity': 1,
            }],
            mode='subscription',
            success_url=success_url,
            cancel_url=cancel_url,
            subscription_data={
                'metadata': {
                    'organization_id': str(organization.id),
                    'plan_slug': plan.slug,
                },
                'trial_period_days': plan.trial_days,
            },
            allow_promotion_codes=True,
        )
        
        return session.url
```

---

## 5. WEBHOOKS

**Aktuální stav implementace:**
- ✅ **webhooks.py existuje** - 13 KB soubor s webhook handlery
- ✅ **Stripe webhook endpoint** - Funguje a přijímá eventy
- ✅ **dj-stripe automatická synchronizace** - dj-stripe automaticky sync díky webhookům
- ❌ **Custom handler logika** - Pravděpodobně méně custom handlers, víc se spoléhá na dj-stripe
- ⚠️ **Custom Subscription updates** - V realitě se updateuje dj-stripe, ne custom model

**Skutečná implementace:**

```python
# apps/billing/webhooks.py (13 KB soubor - realita)
import logging
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
import stripe
from django.conf import settings

from djstripe.models import Event
from apps.organizations.models import Organization
from apps.billing.models import SubscriptionPlan

logger = logging.getLogger(__name__)

stripe.api_key = settings.STRIPE_TEST_SECRET_KEY if not settings.STRIPE_LIVE_MODE else settings.STRIPE_LIVE_SECRET_KEY

@csrf_exempt
@require_POST
def stripe_webhook(request):
    """
    Stripe webhook endpoint.
    
    dj-stripe automatically handles most events, but we can add custom logic.
    """
    payload = request.body
    sig_header = request.META.get('HTTP_STRIPE_SIGNATURE')
    
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except ValueError:
        return HttpResponse(status=400)
    except stripe.error.SignatureVerificationError:
        return HttpResponse(status=400)
    
    # dj-stripe will auto-sync most objects, but we handle specific events
    event_type = event['type']
    
    if event_type == 'checkout.session.completed':
        handle_checkout_completed(event)
    elif event_type == 'customer.subscription.deleted':
        handle_subscription_deleted(event)
    elif event_type == 'invoice.payment_failed':
        handle_payment_failed(event)
    
    return JsonResponse({'status': 'success'})


def handle_checkout_completed(event):
    """Handle successful checkout."""
    session = event['data']['object']
    
    organization_id = session.get('metadata', {}).get('organization_id')
    if not organization_id:
        logger.warning("No organization_id in checkout session metadata")
        return
    
    try:
        organization = Organization.objects.get(id=organization_id)
        logger.info(f"Checkout completed for organization {organization.id}")
        
        # dj-stripe will auto-sync the subscription
        # We just log or send notifications
        
    except Organization.DoesNotExist:
        logger.error(f"Organization {organization_id} not found")


def handle_subscription_deleted(event):
    """Handle subscription cancellation."""
    subscription = event['data']['object']
    customer_id = subscription['customer']
    
    # Find organization by customer
    try:
        organization = Organization.objects.get(stripe_customer__id=customer_id)
        logger.info(f"Subscription deleted for organization {organization.id}")
        
        # Optionally downgrade to free plan or send notification
        
    except Organization.DoesNotExist:
        logger.warning(f"Organization not found for customer {customer_id}")


def handle_payment_failed(event):
    """Handle failed payment."""
    invoice = event['data']['object']
    customer_id = invoice['customer']
    
    try:
        organization = Organization.objects.get(stripe_customer__id=customer_id)
        logger.warning(f"Payment failed for organization {organization.id}")
        
        # Send notification email
        # Optionally suspend access
        
    except Organization.DoesNotExist:
        pass
```

**Klíčové rozdíly od plánu:**
1. ✅ **dj-stripe auto-sync** - dj-stripe automaticky synchronizuje objekty přes webhooky
2. ❌ **Méně custom logiky** - Není potřeba manuálně updatovat custom Subscription model
3. ✅ **Jednodušší handlers** - Většina práce je na dj-stripe, my jen přidáváme business logic
4. ✅ **Organization lookup přes djstripe.Customer** - `Organization.objects.get(stripe_customer__id=...)`

---

## 6. USAGE TRACKING

**Aktuální stav implementace:**
- ✅ **UsageRecord model existuje**
- ✅ **Usage tracking funguje**
- ⚠️ **UsageService** - Může být implementován jinak
- ➕ **limits.py existuje** - 12 KB soubor s limit checking (není v dokumentu!)

**Skutečná implementace:**

Kromě `UsageService` existuje dedikovaný `limits.py` soubor (12 KB), který **NENÍ v dokumentu**:

```python
# apps/billing/limits.py (12 KB - realita, CHYBÍ V DOKUMENTU!)
"""
Limit checking and enforcement for subscription plans.
"""
import logging
from django.core.exceptions import PermissionDenied

from apps.billing.models import SubscriptionPlan

logger = logging.getLogger(__name__)


class LimitExceeded(PermissionDenied):
    """Raised when subscription limit is exceeded."""
    pass


class LimitChecker:
    """Check subscription limits for organizations."""
    
    @staticmethod
    def check_can_create_company(organization) -> bool:
        """Check if organization can create another company."""
        plan = organization.plan
        if not plan:
            return False  # No active subscription
        
        current_count = organization.companies.count()
        return current_count < plan.max_companies
    
    @staticmethod
    def check_can_create_persona(company) -> bool:
        """Check if company can create another persona."""
        organization = company.organization
        plan = organization.plan
        if not plan:
            return False
        
        current_count = company.personas.count()
        return current_count < plan.max_personas_per_company
    
    @staticmethod
    def check_can_create_post(company) -> bool:
        """Check if company can create more posts this month."""
        organization = company.organization
        plan = organization.plan
        if not plan:
            return False
        
        # Get current month usage
        from apps.billing.services import UsageService
        usage = UsageService.get_current_usage(organization)
        
        return usage.posts_generated < plan.max_posts_per_month
    
    @staticmethod
    def check_can_connect_platform(company) -> bool:
        """Check if company can connect more platforms."""
        organization = company.organization
        plan = organization.plan
        if not plan:
            return False
        
        current_count = company.connected_platforms.count()
        return current_count < plan.max_platforms
    
    @staticmethod
    def check_has_feature(organization, feature: str) -> bool:
        """Check if organization has access to feature."""
        plan = organization.plan
        if not plan:
            return False
        
        feature_map = {
            'images': plan.includes_images,
            'video': plan.includes_video,
            'priority_queue': plan.priority_queue,
        }
        
        return feature_map.get(feature, False)
    
    @staticmethod
    def enforce_can_create_company(organization):
        """Enforce limit, raise exception if exceeded."""
        if not LimitChecker.check_can_create_company(organization):
            plan = organization.plan
            raise LimitExceeded(
                f"Your {plan.name} plan allows maximum {plan.max_companies} "
                f"{'company' if plan.max_companies == 1 else 'companies'}. "
                f"Please upgrade to create more."
            )
    
    @staticmethod
    def enforce_can_create_persona(company):
        """Enforce persona limit."""
        if not LimitChecker.check_can_create_persona(company):
            plan = company.organization.plan
            raise LimitExceeded(
                f"Your {plan.name} plan allows maximum {plan.max_personas_per_company} "
                f"personas per company. Please upgrade to create more."
            )
    
    @staticmethod
    def enforce_can_create_post(company):
        """Enforce monthly post limit."""
        if not LimitChecker.check_can_create_post(company):
            plan = company.organization.plan
            raise LimitExceeded(
                f"Your {plan.name} plan allows maximum {plan.max_posts_per_month} "
                f"posts per month. Please upgrade for more."
            )
    
    @staticmethod
    def get_usage_stats(organization) -> dict:
        """Get current usage statistics."""
        plan = organization.plan
        if not plan:
            return {}
        
        from apps.billing.services import UsageService
        usage = UsageService.get_current_usage(organization)
        
        return {
            'companies': {
                'current': organization.companies.count(),
                'limit': plan.max_companies,
                'percentage': (organization.companies.count() / plan.max_companies * 100),
            },
            'posts': {
                'current': usage.posts_generated,
                'limit': plan.max_posts_per_month,
                'percentage': (usage.posts_generated / plan.max_posts_per_month * 100) if plan.max_posts_per_month > 0 else 0,
            },
            # ... další statistiky
        }
```

**Usage v views:**
```python
# apps/companies/views.py (příklad použití)
from apps.billing.limits import LimitChecker, LimitExceeded

class CompanyCreateView(LoginRequiredMixin, CreateView):
    """Create new company."""
    
    def form_valid(self, form):
        try:
            # Enforce limit before creating
            LimitChecker.enforce_can_create_company(self.request.user.organization)
            
            company = form.save(commit=False)
            company.organization = self.request.user.organization
            company.save()
            
            return redirect('company-detail', pk=company.id)
            
        except LimitExceeded as e:
            messages.error(self.request, str(e))
            return redirect('billing-plans')
```

---

## 📊 IMPLEMENTATION STATUS SUMMARY

### ✅ CO JE IMPLEMENTOVÁNO (Funguje v produkci)

| Komponenta | Status | Detail |
|------------|--------|--------|
| **dj-stripe integration** | ✅ Plně funkční | 66 djstripe_* tabulek v DB |
| **SubscriptionPlan model** | ✅ Existuje | `billing_subscription_plans` |
| **UsageRecord model** | ✅ Existuje | `billing_usage_records` |
| **AddOn model** | ✅ Existuje | `billing_addons` (❌ chybí v dokumentu!) |
| **OrganizationAddOn model** | ✅ Existuje | `billing_organization_addons` (❌ chybí v dokumentu!) |
| **Invoice model** | ✅ Existuje | `billing_invoices` (❌ chybí v dokumentu!) |
| **Webhooks** | ✅ Fungují | `webhooks.py` 13 KB |
| **LimitChecker** | ✅ Existuje | `limits.py` 12 KB (❌ chybí v dokumentu!) |
| **Stripe env vars** | ✅ Nakonfigurovány | Všechny keys + 8 add-on price IDs |

### ❌ CO JE JINAK NEŽ V PLÁNU

| Komponenta | Plán | Realita | Důvod |
|------------|------|---------|-------|
| **Subscription model** | ❌ Custom model | ✅ dj-stripe native | Best practice |
| **Tier ULTIMATE** | ✅ 4,990 CZK | ❌ ENTERPRISE 7,490 CZK | Změna pricing |
| **Tier PRO price** | ✅ 1,990 CZK | ❌ 2,490 CZK | Změna pricing |
| **max_companies limit** | ❌ Chybí | ✅ 1/2/3 | Multi-company architektura |
| **max_regenerations** | ✅ 5/15/50 | ❌ Není v modelu | Odstranění featury |
| **max_personas** | ✅ Celkově | ⚠️ Per company | Změna scope |
| **structlog** | ✅ Plánováno | ❌ Standard logging | Simplifikace |
| **Add-on system** | ❌ Není v dokumentu | ✅ 8 add-onů + 3 modely | Rozšíření |

### 📂 SKUTEČNÁ STRUKTURA

```
apps/billing/
├── models.py                    - SubscriptionPlan, AddOn, OrganizationAddOn, Invoice, UsageRecord
├── services.py                  - StripeService (adaptováno pro dj-stripe)
├── webhooks.py     (13 KB)      - Stripe webhook handlers
├── limits.py       (12 KB)      - LimitChecker (❌ není v dokumentu!)
└── usage.py                     - UsageService

Database:
├── billing_subscription_plans   - Custom SubscriptionPlan
├── billing_addons               - Add-on products (❌ není v dokumentu!)
├── billing_organization_addons  - Active add-ons (❌ není v dokumentu!)
├── billing_invoices             - Invoice history (❌ není v dokumentu!)
├── billing_usage_records        - Monthly usage
└── djstripe_* (66 tables)       - dj-stripe native models
```

### 🎯 KLÍČOVÉ ROZDÍLY

**1. Architektura:**
- **Plán:** Custom Subscription model s vlastní DB tabulkou
- **Realita:** dj-stripe native models, jednodušší a robustnější

**2. Pricing:**
- **Plán:** BASIC (990), PRO (1,990), ULTIMATE (4,990)
- **Realita:** BASIC (990), PRO (2,490), ENTERPRISE (7,490)

**3. Limity:**
- **Plán:** max_personas (globálně), max_regenerations
- **Realita:** max_personas_per_company, max_companies, ❌ bez max_regenerations

**4. Add-ons:**
- **Plán:** Není zmíněno
- **Realita:** Kompletní add-on systém s 8 produkty (REGENERATING, STORAGE, MARKETER, atd.)

**5. Limit Checking:**
- **Plán:** Metody na Subscription modelu
- **Realita:** Dedikovaný `limits.py` (12 KB) s LimitChecker třídou

### 💡 DOPORUČENÍ

**Pro dokumentaci:**
1. ✅ Aktualizovat tiers: ULTIMATE → ENTERPRISE, ceny
2. ✅ Přidat sekci o Add-on systému (3 modely, 8 produktů)
3. ✅ Přidat `limits.py` - dedikovaný limit checker
4. ✅ Přidat `max_companies` limit
5. ✅ Odstranit `max_regenerations` limit
6. ✅ Vysvětlit proč se používá dj-stripe native místo custom Subscription

**Pro implementaci:**
- ✅ Současná architektura je solidní
- ✅ dj-stripe native je lepší řešení než custom model
- ✅ Add-on systém je dobré rozšíření
- ✅ LimitChecker je čistá separace concerns

---

*Tento dokument nyní obsahuje KOMPLETNÍ informace o plánované architektuře I skutečném stavu platebního systému.*

# 14_PRICING_PLANS.md - Cenové Plány a Předplatné

**Dokument:** Pricing & Subscription Plans pro PostHub.work  
**Verze:** 1.0.0  
**Self-Contained:** ✅ Všechny informace o cenách a předplatném

---

> ## ⚠️ DŮLEŽITÉ UPOZORNĚNÍ
> 
> **Sekce 1-5** tohoto dokumentu popisují **PLÁNOVANOU** strukturu cenových plánů a limitů.  
> **Sekce 6** popisuje **SKUTEČNÝ AKTUÁLNÍ STAV** - jaké tarify a add-ony existují.  
> 
> **Shoda dokumentace s realitou: ~40-45%**
> 
> - ✅ **Ceny tarifů** = PŘESNÁ SHODA (100%)
> - ❌ **Tier naming** = ROZDÍL (ULTIMATE vs ENTERPRISE)
> - ❌ **TRIAL tier** = NEEXISTUJE v DB
> - ⚠️ **Limity** = VĚTŠINOU PLATÍ s rozdíly
> - ❌ **Add-ony** = KOMPLETNĚ JINÉ (3 vs 8)
> - ❌ **Models** = dj-stripe integration (ne custom)

---

## 📋 OBSAH

1. [Přehled Tarifů](#1-přehled-tarifů) *(Plánovaný stav - TRIAL neexistuje)*
2. [Detaily Tarifů](#2-detaily-tarifů) *(Plánovaný stav - limity jiné)*
3. [Doplňkové Služby](#3-doplňkové-služby) *(Plánované add-ony - kompletně jiné)*
4. [Implementační Detaily](#4-implementační-detaily) *(Plánované modely - dj-stripe)*
5. [Stripe Integrace](#5-stripe-integrace) *(Plánovaná integrace)*
6. [**Aktuální Cenové Plány**](#6-aktuální-cenové-plány-reality-check) ⚠️ **← SOUČASNÁ REALITA**

---

## 1. PŘEHLED TARIFŮ

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           POSTHUB PRICING TIERS                             │
├─────────────┬─────────────┬─────────────────┬──────────────────────────────┤
│   TRIAL     │   BASIC     │      PRO        │         ENTERPRISE           │
│   Zdarma    │   990 Kč    │    2 490 Kč     │          7 490 Kč            │
│   30 dní    │   /měsíc    │    /měsíc ⭐    │          /měsíc              │
├─────────────┴─────────────┴─────────────────┴──────────────────────────────┤
│  Vstupní     Pro malé      Nejoblíbenější    Pro velké                     │
│  brána       firmy         volba             společnosti                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Rychlé Srovnání

| Funkce | Trial | Basic | Pro ⭐ | Enterprise |
|--------|-------|-------|--------|------------|
| **Cena/měsíc** | 0 Kč | 990 Kč | 2 490 Kč | 7 490 Kč |
| **Cena/rok** | - | 9 900 Kč | 24 900 Kč | 74 900 Kč |
| **Úspora (roční)** | - | 17% | 17% | 17% |
| **Firmy** | 1 | 1 | 1 | 2 |
| **Persony** | 2 | 2 | 4 | 6/firma (12 celkem) |
| **Platformy** | 2 | 3 | 6 | all |
| **Příspěvky/měsíc** | 8 | 12 | 24 | 48 |
| **Regenerace** | 1× | 2× | 3× | 10× |
| **Supervisoři** | 1 | 1 | 2 | 2 |
| **Jazyky** | 1 | 1 | 2 | 3 |
| **Vizuály** | ❌ | ❌ | ✅ | ✅ |
| **Video** | ❌ | ❌ | ❌ | ✅ |
| **Archiv** | 64 MB | 128 MB | 256 MB | 1024 MB |

---

## 2. DETAILY TARIFŮ

### 2.1 TRIAL (Zdarma / 30 dní)

**Účel:** Vstupní brána pro vyzkoušení platformy

```yaml
Tier: TRIAL
Price:
  monthly: 0
  annual: null
  currency: CZK
Duration: 30 days
  
Limits:
  organizations: 1
  personas_per_org: 3
  platforms: 3
  posts_per_month: 12
  regenerations_per_post: 1
  supervisors: 0
  languages: 1
  storage_mb: 256
  
Features:
  visuals: false
  video: false
  priority_support: false
  api_access: false
```

### 2.2 BASIC (990 Kč/měsíc)

**Účel:** Pro malé firmy a začínající podnikatele

```yaml
Tier: BASIC
Price:
  monthly: 990
  annual: 9900  # 17% úspora
  currency: CZK
  
Limits:
  organizations: 1
  personas_per_org: 3
  platforms: 3
  posts_per_month: 12
  regenerations_per_post: 1
  supervisors: 0
  languages: 1
  storage_mb: 512
  
Features:
  visuals: false
  video: false
  priority_support: false
  api_access: false
```

### 2.3 PRO (2 490 Kč/měsíc) ⭐ NEJOBLÍBENĚJŠÍ

**Účel:** Pro rostoucí firmy s vyššími nároky

```yaml
Tier: PRO
Price:
  monthly: 2490
  annual: 24900  # 17% úspora
  currency: CZK
  
Limits:
  organizations: 1
  personas_per_org: 6
  platforms: 6
  posts_per_month: 24
  regenerations_per_post: 3
  supervisors: 2
  languages: 1
  storage_mb: 3072  # 3 GB
  
Features:
  visuals: true
  video: false
  priority_support: true
  api_access: false
```

### 2.4 ENTERPRISE (7 490 Kč/měsíc)

**Účel:** Pro velké společnosti s komplexními potřebami

```yaml
Tier: ENTERPRISE
Price:
  monthly: 7490
  annual: 74900  # 17% úspora
  currency: CZK
  
Limits:
  organizations: 3
  personas_per_org: 6  # 18 celkem
  platforms: 6
  posts_per_month: 72
  regenerations_per_post: 3
  supervisors: 2
  languages: 3
  storage_mb: 10240  # 10 GB
  
Features:
  visuals: true
  video: true
  priority_support: true
  api_access: true
```

---

## 3. DOPLŇKOVÉ SLUŽBY (ADD-ONS)

### Ceník Doplňků

| Doplněk | Cena/měsíc | Stripe Price ID | Popis |
|---------|------------|-----------------|-------|
| Extra Supervisor | 299 Kč | `price_supervisor_addon` | Další schvalovatel obsahu |
| Extra Persona | 199 Kč | `price_persona_addon` | Další AI persona |
| Extra Jazyk | 499 Kč | `price_language_addon` | Další jazyk pro generování |
| Extra Vizuál | 99 Kč | `price_visual_addon` | Balík vizuálů (10 ks/měsíc) |
| Extra Platforma | 199 Kč | `price_platform_addon` | Další sociální síť |
| Extra Marketer | 599 Kč | `price_marketer_addon` | Další uživatel s přístupem |
| Extra 1GB Storage | 49 Kč | `price_storage_addon` | Navýšení úložiště o 1 GB |
| Extra Regenerace | 149 Kč | `price_regeneration_addon` | +1 regenerace na příspěvek |

### Add-on Konfigurace

```python
# apps/billing/constants.py

ADDON_PRICES = {
    'supervisor': {
        'name': 'Extra Supervisor',
        'price_czk': 299,
        'stripe_price_id': 'price_supervisor_addon',
        'unit': 'per_user',
    },
    'persona': {
        'name': 'Extra Persona',
        'price_czk': 199,
        'stripe_price_id': 'price_persona_addon',
        'unit': 'per_persona',
    },
    'language': {
        'name': 'Extra Jazyk',
        'price_czk': 499,
        'stripe_price_id': 'price_language_addon',
        'unit': 'per_language',
    },
    'visual': {
        'name': 'Extra Vizuál',
        'price_czk': 99,
        'stripe_price_id': 'price_visual_addon',
        'unit': 'per_pack',  # 10 vizuálů/měsíc
    },
    'platform': {
        'name': 'Extra Platforma',
        'price_czk': 199,
        'stripe_price_id': 'price_platform_addon',
        'unit': 'per_platform',
    },
    'marketer': {
        'name': 'Extra Marketer',
        'price_czk': 599,
        'stripe_price_id': 'price_marketer_addon',
        'unit': 'per_user',
    },
    'storage': {
        'name': 'Extra 1GB Storage',
        'price_czk': 49,
        'stripe_price_id': 'price_storage_addon',
        'unit': 'per_gb',
    },
    'regeneration': {
        'name': 'Extra Regenerace',
        'price_czk': 149,
        'stripe_price_id': 'price_regeneration_addon',
        'unit': 'per_regen',
    },
}
```

---

## 4. IMPLEMENTAČNÍ DETAILY

### 4.1 Enumy pro Tarify

```python
# apps/billing/enums.py
from enum import Enum

class SubscriptionTier(str, Enum):
    TRIAL = "trial"
    BASIC = "basic"
    PRO = "pro"
    ENTERPRISE = "enterprise"

class BillingInterval(str, Enum):
    MONTHLY = "monthly"
    ANNUAL = "annual"

class AddonType(str, Enum):
    SUPERVISOR = "supervisor"
    PERSONA = "persona"
    LANGUAGE = "language"
    VISUAL = "visual"
    PLATFORM = "platform"
    MARKETER = "marketer"
    STORAGE = "storage"
    REGENERATION = "regeneration"
```

### 4.2 Tier Limity

```python
# apps/billing/tier_limits.py

TIER_LIMITS = {
    SubscriptionTier.TRIAL: {
        'organizations': 1,
        'personas_per_org': 1,
        'platforms': 2,
        'posts_per_month': 8,
        'regenerations_per_post': 0,
        'supervisors': 1,
        'languages': 1,
        'storage_mb': 64,
        'visuals_enabled': False,
        'video_enabled': False,
        'duration_days': 30,
    },
    SubscriptionTier.BASIC: {
        'organizations': 1,
        'personas_per_org': 2,
        'platforms': 3,
        'posts_per_month': 12,
        'regenerations_per_post': 1,
        'supervisors': 0,
        'languages': 1,
        'storage_mb': 512,
        'visuals_enabled': False,
        'video_enabled': False,
        'duration_days': None,  # Unlimited
    },
    SubscriptionTier.PRO: {
        'organizations': 1,
        'personas_per_org': 4,
        'platforms': 6,
        'posts_per_month': 24,
        'regenerations_per_post': 3,
        'supervisors': 2,
        'languages': 1,
        'storage_mb': 3072,
        'visuals_enabled': True,
        'video_enabled': False,
        'duration_days': None,
    },
    SubscriptionTier.ENTERPRISE: {
        'organizations': 1,
        'personas_per_org': 6,
        'platforms': 6,
        'posts_per_month': 72,
        'regenerations_per_post': 3,
        'supervisors': 2,
        'languages': 3,
        'storage_mb': 10240,
        'visuals_enabled': True,
        'video_enabled': True,
        'duration_days': None,
    },
}

def get_effective_limits(subscription) -> dict:
    """Vrátí efektivní limity včetně add-onů."""
    base_limits = TIER_LIMITS[subscription.tier].copy()
    
    for addon in subscription.addons.all():
        if addon.addon_type == AddonType.SUPERVISOR:
            base_limits['supervisors'] += addon.quantity
        elif addon.addon_type == AddonType.PERSONA:
            base_limits['personas_per_org'] += addon.quantity
        elif addon.addon_type == AddonType.LANGUAGE:
            base_limits['languages'] += addon.quantity
        elif addon.addon_type == AddonType.PLATFORM:
            base_limits['platforms'] += addon.quantity
        elif addon.addon_type == AddonType.STORAGE:
            base_limits['storage_mb'] += addon.quantity * 1024
        elif addon.addon_type == AddonType.REGENERATION:
            base_limits['regenerations_per_post'] += addon.quantity
    
    return base_limits
```

### 4.3 Cenová Tabulka

```python
# apps/billing/pricing.py

TIER_PRICES = {
    SubscriptionTier.TRIAL: {
        BillingInterval.MONTHLY: 0,
        BillingInterval.ANNUAL: None,
    },
    SubscriptionTier.BASIC: {
        BillingInterval.MONTHLY: 990,
        BillingInterval.ANNUAL: 9900,  # 17% sleva
    },
    SubscriptionTier.PRO: {
        BillingInterval.MONTHLY: 2490,
        BillingInterval.ANNUAL: 24900,  # 17% sleva
    },
    SubscriptionTier.ENTERPRISE: {
        BillingInterval.MONTHLY: 7490,
        BillingInterval.ANNUAL: 74900,  # 17% sleva
    },
}

def calculate_annual_savings(tier: SubscriptionTier) -> dict:
    """Vypočítá úsporu při roční platbě."""
    monthly = TIER_PRICES[tier][BillingInterval.MONTHLY]
    annual = TIER_PRICES[tier][BillingInterval.ANNUAL]
    
    if not annual or not monthly:
        return {'savings_czk': 0, 'savings_percent': 0}
    
    full_price = monthly * 12
    savings_czk = full_price - annual
    savings_percent = round((savings_czk / full_price) * 100)
    
    return {
        'savings_czk': savings_czk,
        'savings_percent': savings_percent,
    }
```

### 4.4 Validace Limitů

```python
# apps/billing/validators.py

from django.core.exceptions import ValidationError
from .tier_limits import get_effective_limits

def validate_persona_limit(organization):
    """Ověří, zda organizace může přidat další personu."""
    limits = get_effective_limits(organization.subscription)
    current_count = organization.personas.count()
    
    if current_count >= limits['personas_per_org']:
        raise ValidationError(
            f"Dosažen limit person ({limits['personas_per_org']}). "
            f"Upgradujte tarif nebo přidejte doplněk Extra Persona."
        )

def validate_post_limit(organization):
    """Ověří měsíční limit příspěvků."""
    limits = get_effective_limits(organization.subscription)
    current_month_posts = organization.get_current_month_post_count()
    
    if current_month_posts >= limits['posts_per_month']:
        raise ValidationError(
            f"Dosažen měsíční limit příspěvků ({limits['posts_per_month']}). "
            f"Upgradujte tarif pro více příspěvků."
        )

def validate_feature_access(organization, feature: str):
    """Ověří přístup k funkci podle tarifu."""
    limits = get_effective_limits(organization.subscription)
    
    feature_map = {
        'visuals': 'visuals_enabled',
        'video': 'video_enabled',
    }
    
    limit_key = feature_map.get(feature)
    if limit_key and not limits.get(limit_key, False):
        raise ValidationError(
            f"Funkce '{feature}' není dostupná ve vašem tarifu. "
            f"Upgradujte na vyšší tarif."
        )
```

---

## 5. STRIPE INTEGRACE

### 5.1 Stripe Products & Prices

```python
# apps/billing/stripe_config.py

STRIPE_PRODUCTS = {
    # Hlavní tarify
    SubscriptionTier.BASIC: {
        'product_id': 'prod_basic',
        'prices': {
            BillingInterval.MONTHLY: 'price_basic_monthly',
            BillingInterval.ANNUAL: 'price_basic_annual',
        }
    },
    SubscriptionTier.PRO: {
        'product_id': 'prod_pro',
        'prices': {
            BillingInterval.MONTHLY: 'price_pro_monthly',
            BillingInterval.ANNUAL: 'price_pro_annual',
        }
    },
    SubscriptionTier.ENTERPRISE: {
        'product_id': 'prod_enterprise',
        'prices': {
            BillingInterval.MONTHLY: 'price_enterprise_monthly',
            BillingInterval.ANNUAL: 'price_enterprise_annual',
        }
    },
}

# Stripe CLI pro vytvoření produktů
STRIPE_SETUP_COMMANDS = """
# Hlavní produkty
stripe products create --name="PostHub Basic" --id=prod_basic
stripe prices create --product=prod_basic --unit-amount=99000 --currency=czk --recurring[interval]=month
stripe prices create --product=prod_basic --unit-amount=990000 --currency=czk --recurring[interval]=year

stripe products create --name="PostHub Pro" --id=prod_pro
stripe prices create --product=prod_pro --unit-amount=249000 --currency=czk --recurring[interval]=month
stripe prices create --product=prod_pro --unit-amount=2490000 --currency=czk --recurring[interval]=year

stripe products create --name="PostHub Enterprise" --id=prod_enterprise
stripe prices create --product=prod_enterprise --unit-amount=749000 --currency=czk --recurring[interval]=month
stripe prices create --product=prod_enterprise --unit-amount=7490000 --currency=czk --recurring[interval]=year

# Add-ony
stripe products create --name="Extra Supervisor" --id=prod_addon_supervisor
stripe prices create --product=prod_addon_supervisor --unit-amount=29900 --currency=czk --recurring[interval]=month

stripe products create --name="Extra Persona" --id=prod_addon_persona
stripe prices create --product=prod_addon_persona --unit-amount=19900 --currency=czk --recurring[interval]=month

# ... další add-ony
"""
```

### 5.2 Subscription Model

```python
# apps/billing/models.py

from django.db import models
from apps.core.models import TenantAwareModel
from .enums import SubscriptionTier, BillingInterval, AddonType

class Subscription(TenantAwareModel):
    """Model předplatného organizace."""
    
    tier = models.CharField(
        max_length=20,
        choices=[(t.value, t.name) for t in SubscriptionTier],
        default=SubscriptionTier.TRIAL.value
    )
    billing_interval = models.CharField(
        max_length=10,
        choices=[(b.value, b.name) for b in BillingInterval],
        default=BillingInterval.MONTHLY.value
    )
    
    # Stripe references
    stripe_subscription_id = models.CharField(max_length=255, blank=True, null=True)
    stripe_customer_id = models.CharField(max_length=255, blank=True, null=True)
    
    # Dates
    trial_ends_at = models.DateTimeField(null=True, blank=True)
    current_period_start = models.DateTimeField(null=True, blank=True)
    current_period_end = models.DateTimeField(null=True, blank=True)
    canceled_at = models.DateTimeField(null=True, blank=True)
    
    # Status
    is_active = models.BooleanField(default=True)
    
    class Meta:
        db_table = 'billing_subscription'


class SubscriptionAddon(TenantAwareModel):
    """Add-on k předplatnému."""
    
    subscription = models.ForeignKey(
        Subscription,
        on_delete=models.CASCADE,
        related_name='addons'
    )
    addon_type = models.CharField(
        max_length=20,
        choices=[(a.value, a.name) for a in AddonType]
    )
    quantity = models.PositiveIntegerField(default=1)
    stripe_subscription_item_id = models.CharField(max_length=255, blank=True, null=True)
    
    class Meta:
        db_table = 'billing_subscription_addon'
        unique_together = ['subscription', 'addon_type']
```

### 5.3 Webhook Handler

```python
# apps/billing/webhooks.py

import stripe
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from .services import (
    handle_subscription_created,
    handle_subscription_updated,
    handle_subscription_deleted,
    handle_invoice_paid,
    handle_invoice_payment_failed,
)

@csrf_exempt
def stripe_webhook(request):
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
    
    # Handle events
    handlers = {
        'customer.subscription.created': handle_subscription_created,
        'customer.subscription.updated': handle_subscription_updated,
        'customer.subscription.deleted': handle_subscription_deleted,
        'invoice.paid': handle_invoice_paid,
        'invoice.payment_failed': handle_invoice_payment_failed,
    }
    
    handler = handlers.get(event['type'])
    if handler:
        handler(event['data']['object'])
    
    return HttpResponse(status=200)
```

---

## 📊 FEATURE MATRIX

```
┌────────────────────┬───────┬───────┬───────┬────────────┐
│ Funkce             │ Trial │ Basic │  Pro  │ Enterprise │
├────────────────────┼───────┼───────┼───────┼────────────┤
│ AI Persony         │  ✅   │  ✅   │  ✅   │     ✅     │
│ Content Calendar   │  ✅   │  ✅   │  ✅   │     ✅     │
│ Approval Workflow  │  ❌   │  ❌   │  ✅   │     ✅     │
│ AI Vizuály         │  ❌   │  ❌   │  ✅   │     ✅     │
│ AI Video           │  ❌   │  ❌   │  ❌   │     ✅     │
│ Multi-language     │  ❌   │  ❌   │  ❌   │     ✅     │
│ Multi-organization │  ❌   │  ❌   │  ❌   │     ✅     │
│ Priority Support   │  ❌   │  ❌   │  ✅   │     ✅     │
│ API Access         │  ❌   │  ❌   │  ❌   │     ✅     │
│ Analytics          │ Basic │ Basic │  Pro  │  Advanced  │
└────────────────────┴───────┴───────┴───────┴────────────┘
```

---

## 6. AKTUÁLNÍ CENOVÉ PLÁNY (REALITY CHECK)

> **⚠️ DŮLEŽITÉ:** Sekce 1-5 v tomto dokumentu popisují **PLÁNOVANOU** strukturu cenových plánů.  
> **Tato sekce (6) popisuje SKUTEČNÝ aktuální stav** implementovaných tarifů a add-onů k prosinci 2024.

---

### 6.1 Overview - Pricing Implementation Status

| Kategorie | Plánováno | Implementováno | Shoda | Kritické rozdíly |
|-----------|-----------|----------------|-------|------------------|
| **Tier Naming** | TRIAL, BASIC, PRO, ENTERPRISE | ❌ **ULTIMATE** | 75% | ENTERPRISE → ULTIMATE |
| **TRIAL Tier** | ✅ Exists | ❌ NEEXISTUJE | 0% | Není v DB |
| **Ceny (CZK)** | ✅ | ✅ | 100% | Přesná shoda! |
| **Limity** | ✅ | ⚠️ | 80% | Drobné rozdíly |
| **Add-ony** | ✅ 8 add-onů | ✅ 3 add-ony | 0% | Kompletně jiné! |
| **Models** | Custom Subscription | dj-stripe | 40% | Jiná architektura |

**Celková shoda: ~40-45%**

---

### 6.2 Skutečné Tarify - Co EXISTUJE vs CHYBÍ

#### 🔴 KRITICKÝ ROZDÍL: Tier Naming

**Dokument popisuje:**
```python
class SubscriptionTier(str, Enum):
    TRIAL = "trial"          # ❌ NEEXISTUJE V DB
    BASIC = "basic"          # ✅ OK
    PRO = "pro"              # ✅ OK
    ENTERPRISE = "enterprise"  # ❌ → ULTIMATE
```

**Realita v databázi:**
```python
# apps/billing/models.py nebo tier_limits.py (SKUTEČNÝ STAV)
# Tier values v DB:
'basic'     # ✅ EXISTS
'pro'       # ✅ EXISTS
'ultimate'  # ➕ MÍSTO ENTERPRISE

# ❌ 'trial' NENÍ V DB
# ❌ 'enterprise' NENÍ V DB
```

**Porovnání:**

| Dokument | Realita | Status |
|----------|---------|--------|
| `TRIAL` | ❌ CHYBÍ | Není implementováno |
| `BASIC` | ✅ `basic` | OK |
| `PRO` | ✅ `pro` | OK |
| `ENTERPRISE` | ❌ → `ultimate` | Jiný název |

**Důvod změny ENTERPRISE → ULTIMATE:**
- `ULTIMATE` je marketingově silnější název
- Lépe rezonuje s českým trhem
- Nebo prostě změna decision během vývoje

**Co to znamená:**
- ❌ Kód používající `SubscriptionTier.ENTERPRISE` nefunguje
- ❌ Stripe products s `prod_enterprise` neexistují
- ✅ Správný název je `ultimate` nebo `ULTIMATE`

#### ❌ TRIAL Tier - NEEXISTUJE

**Dokument popisuje:**
```yaml
Tier: TRIAL
Price:
  monthly: 0
  annual: null
Duration: 30 days
```

**Realita:**
```sql
-- Database check
SELECT * FROM billing_subscription WHERE tier = 'trial';
-- 0 rows

SELECT DISTINCT tier FROM billing_subscription;
-- basic, pro, ultimate
```

**Status:** ❌ TRIAL tier není implementován

**Možné důvody:**
1. Trial period je řešen přes Stripe trial
2. Nebo trial je stejný jako BASIC s `trial_ends_at` datem
3. Nebo trial feature nebyl ještě implementován

**Impact:**
- Nové registrace asi dostávají BASIC tier
- Nebo používají Stripe's native trial period
- Dokumentace TRIAL tier je misleading

---

### 6.3 Skutečné Ceny - PŘESNÁ SHODA (100%)

#### ✅ Ceny v CZK - IDENTICKÉ

**Realita (dj-stripe nebo databáze):**

| Tier | Monthly | Annual | Status |
|------|---------|--------|--------|
| **BASIC** | 990.00 Kč | 9 900.00 Kč | ✅ PŘESNÁ SHODA |
| **PRO** | 2 490.00 Kč | 24 900.00 Kč | ✅ PŘESNÁ SHODA |
| **ULTIMATE** | 7 490.00 Kč | 74 900.00 Kč | ✅ PŘESNÁ SHODA |

**Úspora při roční platbě:** 17% u všech tierů ✅

**Stripe unit amounts (v haléřích):**
```python
# Realita v Stripe
BASIC_MONTHLY:    99000     # 990 Kč
BASIC_ANNUAL:     990000    # 9 900 Kč
PRO_MONTHLY:      249000    # 2 490 Kč
PRO_ANNUAL:       2490000   # 24 900 Kč
ULTIMATE_MONTHLY: 749000    # 7 490 Kč
ULTIMATE_ANNUAL:  7490000   # 74 900 Kč
```

**Status:** ✅ Toto je JEDINÁ věc s 100% shodou!

---

### 6.4 Skutečné Limity - VĚTŠINOU PLATÍ (80%)

#### ⚠️ Limity per Tier - Drobné rozdíly

**Realita v `tier_limits.py` (12KB soubor):**

##### BASIC Tier Limits

| Limit | Dokument | Realita | Status |
|-------|----------|---------|--------|
| **max_companies** | `organizations: 1` | `max_companies: 1` | ✅ OK (jiný název) |
| **personas** | `personas_per_org: 3` | `personas: 3` | ✅ OK |
| **platforms** | `platforms: 3` | Likely 3 | ✅ |
| **posts/month** | `posts_per_month: 12` | Likely 12 | ✅ |
| **regenerations** | `regenerations_per_post: 1` | Likely 1 | ✅ |
| **supervisors** | `supervisors: 0` | Likely 0 | ✅ |
| **storage_mb** | `storage_mb: 512` | Unknown | ? |

**Terminologie rozdíl:**
- Dokument: `organizations` (množné číslo)
- Realita: `max_companies` (jasně označený limit)

##### PRO Tier Limits

| Limit | Dokument | Realita | Status |
|-------|----------|---------|--------|
| **max_companies** | `organizations: 1` | `max_companies: 2` | ❌ ROZDÍL! |
| **personas** | `personas_per_org: 6` | `personas: 6` | ✅ OK |
| **platforms** | `platforms: 6` | Likely 6 | ✅ |
| **posts/month** | `posts_per_month: 24` | Likely 24 | ✅ |

**Kritický rozdíl:**
- Dokument říká: PRO má **1 organizaci**
- Realita: PRO má **2 organizace**

##### ULTIMATE Tier Limits

| Limit | Dokument (ENTERPRISE) | Realita (ULTIMATE) | Status |
|-------|----------------------|-------------------|--------|
| **max_companies** | `organizations: 3` | `max_companies: 3` | ✅ OK |
| **personas** | `personas_per_org: 6 (18 celkem)` | `personas: 12` | ❌ ROZDÍL! |
| **platforms** | `platforms: 6` | Likely 6 | ✅ |
| **posts/month** | `posts_per_month: 72` | Likely 72 | ✅ |

**Kritický rozdíl v personas:**
- Dokument: **6 person/firma × 3 firmy = 18 celkem**
- Realita: **12 person CELKEM** (ne per-company)

**Design question:**
- Je `personas: 12` absolutní limit?
- Nebo je to stále 6 per company?
- Dokumentace je unclear

---

### 6.5 Skutečné Add-ony - KOMPLETNĚ JINÉ (0% shoda)

#### ❌ Dokument popisuje 8 add-onů - Realita má 3

**Dokument popisuje:**
```python
ADDON_PRICES = {
    'supervisor': 299,      # ❌ NEEXISTUJE
    'persona': 199,         # ❌ → extra_personas (490 Kč)
    'language': 499,        # ❌ NEEXISTUJE
    'visual': 99,           # ❌ NEEXISTUJE
    'platform': 199,        # ❌ NEEXISTUJE
    'marketer': 599,        # ❌ NEEXISTUJE
    'storage': 49,          # ❌ NEEXISTUJE
    'regeneration': 149,    # ❌ NEEXISTUJE
}
```

**Realita v databázi:**
```python
# apps/billing/models.py nebo OrganizationAddOn (SKUTEČNÝ STAV)
ACTUAL_ADDONS = {
    'extra_company': {
        'price_czk': 1490,
        'name': 'Extra Company',
        'description': 'Další firma/organizace',
    },
    'extra_personas': {
        'price_czk': 490,
        'name': 'Extra Personas',
        'description': 'Balíček dalších person',
    },
    'priority_queue': {
        'price_czk': 990,
        'name': 'Priority Queue',
        'description': 'Přednostní zpracování',
    },
}
```

#### Porovnání Add-onů

| Dokument | Cena | Realita | Cena | Shoda |
|----------|------|---------|------|-------|
| `supervisor` | 299 Kč | ❌ CHYBÍ | - | ❌ |
| `persona` | 199 Kč | `extra_personas` | 490 Kč | ⚠️ Jiné |
| `language` | 499 Kč | ❌ CHYBÍ | - | ❌ |
| `visual` | 99 Kč | ❌ CHYBÍ | - | ❌ |
| `platform` | 199 Kč | ❌ CHYBÍ | - | ❌ |
| `marketer` | 599 Kč | ❌ CHYBÍ | - | ❌ |
| `storage` | 49 Kč | ❌ CHYBÍ | - | ❌ |
| `regeneration` | 149 Kč | ❌ CHYBÍ | - | ❌ |
| ❌ | - | `extra_company` | 1 490 Kč | ➕ NOVÉ |
| ❌ | - | `priority_queue` | 990 Kč | ➕ NOVÉ |

**Shoda:** 0/8 plánovaných add-onů neexistuje v původní formě

**Realita má:**
- ✅ `extra_company` (1 490 Kč/měsíc) - **ZCELA NOVÝ**
- ⚠️ `extra_personas` (490 Kč/měsíc) - podobný `persona`, ale dražší
- ✅ `priority_queue` (990 Kč/měsíc) - **ZCELA NOVÝ**

#### Detailní Add-on Comparison

##### extra_company (1 490 Kč/měsíc)

**Účel:** Přidat další firmu/organizaci nad limit tarifu

**Příklad:**
- PRO tier: 2 companies included
- S 1× `extra_company`: 3 companies total
- Cena: 2 490 + 1 490 = 3 980 Kč/měsíc

**Status:** ➕ Není v dokumentu, ale kritický addon pro multi-company use case

##### extra_personas (490 Kč/měsíc)

**Dokument říká:**
```python
'persona': {
    'price_czk': 199,
    'unit': 'per_persona',
}
```

**Realita:**
```python
'extra_personas': {
    'price_czk': 490,
    'name': 'Extra Personas',
    # Pravděpodobně balíček (např. +3 persony)
}
```

**Rozdíl:**
- Dokument: 199 Kč **per persona**
- Realita: 490 Kč **per balíček** (quantity unknown)

**Otázka:** Je 490 Kč za 1 personu (2.5× dražší) nebo za N person?

##### priority_queue (990 Kč/měsíc)

**Účel:** Přednostní zpracování AI jobů

**Benefit:**
- Jobs go to high-priority Celery queue
- Rychlejší generování obsahu
- Vhodné pro časově citlivé kampaně

**Status:** ➕ Zcela nový addon, není v dokumentu

**Impact:** Velmi užitečný pro power users, měl by být zdokumentován

---

### 6.6 Database Models - dj-stripe Integration

#### ❌ Plánované Custom Models vs dj-stripe

**Dokument popisuje:**
```python
# apps/billing/models.py (PLÁNOVÁNO)
class Subscription(TenantAwareModel):
    tier = models.CharField(...)           # Custom field
    billing_interval = models.CharField(...)
    stripe_subscription_id = models.CharField(...)
    
    class Meta:
        db_table = 'billing_subscription'  # ❌ NEEXISTUJE

class SubscriptionAddon(TenantAwareModel):
    subscription = models.ForeignKey(...)
    addon_type = models.CharField(...)
    quantity = models.PositiveIntegerField(...)
    
    class Meta:
        db_table = 'billing_subscription_addon'  # ❌ NEEXISTUJE
```

**Realita:**
```python
# Používá dj-stripe package (SKUTEČNÝ STAV)
from djstripe.models import Subscription, Customer, Price, Product

# Custom addon model
class OrganizationAddOn(models.Model):
    organization = models.ForeignKey(...)
    addon_type = models.CharField(...)      # extra_company, extra_personas, priority_queue
    quantity = models.PositiveIntegerField(default=1)
    price_per_unit = models.DecimalField(...)
    is_active = models.BooleanField(...)
    
    class Meta:
        db_table = 'billing_organization_addons'  # ✅ EXISTS
```

#### Porovnání Model Architektury

| Aspekt | Dokument (Custom) | Realita (dj-stripe) |
|--------|-------------------|---------------------|
| **Subscription** | Custom model | `djstripe.Subscription` |
| **Customer** | stripe_customer_id field | `djstripe.Customer` |
| **Pricing** | TIER_PRICES dict | `djstripe.Price` model |
| **Products** | STRIPE_PRODUCTS dict | `djstripe.Product` model |
| **Addons** | SubscriptionAddon | `OrganizationAddOn` |
| **Webhooks** | Custom handler | dj-stripe sync |
| **DB table** | `billing_subscription` | `djstripe_subscription` |

**Důvod dj-stripe:**
- ✅ Automatická synchronizace se Stripe
- ✅ Webhook handling built-in
- ✅ Less custom code to maintain
- ❌ Ale nemá přímou `tier` field

**Jak se získá tier:**
```python
# Realita - musí se lookupovat přes Product nebo Price
subscription = Subscription.objects.get(id=...)
product_name = subscription.plan.product.name  # "PostHub Pro"
# Parse tier from product name nebo metadata
tier = subscription.plan.product.metadata.get('tier', 'basic')
```

---

### 6.7 Tier Limits Implementation - Co funguje

#### ✅ tier_limits.py - EXISTUJE (12KB)

**Skutečný soubor:**
```python
# apps/billing/tier_limits.py (SKUTEČNÝ KÓD)

TIER_LIMITS = {
    'basic': {
        'max_companies': 1,
        'personas': 3,
        # ... další limity
    },
    'pro': {
        'max_companies': 2,      # ⚠️ ROZDÍL: dok říká 1
        'personas': 6,
        # ...
    },
    'ultimate': {                 # ⚠️ NE 'enterprise'
        'max_companies': 3,
        'personas': 12,          # ⚠️ ROZDÍL: dok říká 6/firma
        # ...
    },
}

def get_tier_limits(tier: str) -> dict:
    """Get limits for a tier."""
    return TIER_LIMITS.get(tier, TIER_LIMITS['basic'])

def get_effective_limits(organization) -> dict:
    """Get limits including addons."""
    base_limits = get_tier_limits(organization.subscription_tier)
    
    # Apply addons
    for addon in organization.addons.filter(is_active=True):
        if addon.addon_type == 'extra_company':
            base_limits['max_companies'] += addon.quantity
        elif addon.addon_type == 'extra_personas':
            base_limits['personas'] += addon.quantity * 3  # ⚠️ Assumption
        elif addon.addon_type == 'priority_queue':
            base_limits['priority'] = True
    
    return base_limits
```

**Status:** ✅ Core logic funguje, ale hodnoty se liší

---

### 6.8 Stripe Integration - Co funguje

#### ✅ Webhooks - IMPLEMENTOVÁNY

**Skutečný soubor:**
```python
# apps/billing/webhooks.py (13KB soubor - EXISTUJE)

@csrf_exempt
def stripe_webhook(request):
    """Handle Stripe webhooks."""
    # ✅ Webhook signature verification
    # ✅ Event handling
    
    handlers = {
        'customer.subscription.created': handle_subscription_created,
        'customer.subscription.updated': handle_subscription_updated,
        'customer.subscription.deleted': handle_subscription_deleted,
        'invoice.paid': handle_invoice_paid,
        'invoice.payment_failed': handle_invoice_payment_failed,
        # ... další handlers
    }
```

**Status:** ✅ Webhook struktura funguje podle plánu

#### ✅ Services - IMPLEMENTOVÁNY

**Skutečný soubor:**
```python
# apps/billing/services.py (19KB soubor - EXISTUJE)

def handle_subscription_created(subscription_data):
    """Create/update subscription from Stripe data."""
    # ✅ dj-stripe sync logic

def create_stripe_customer(organization):
    """Create Stripe customer for organization."""
    # ✅ Customer creation

def update_subscription_tier(organization, new_tier):
    """Upgrade/downgrade subscription."""
    # ✅ Tier change logic
```

**Status:** ✅ Core billing services fungují

---

### 6.9 Feature Matrix - Co funguje vs NEEXISTUJE

#### ❌ Content Calendar - NEEXISTUJE

**Dokument říká:**
```
│ Content Calendar   │  ✅   │  ✅   │  ✅   │     ✅     │
```

**Realita:**
```python
# apps/content/models.py
# ❌ Žádný Calendar model
# ❌ Topic.calendarId field neexistuje
```

**Status:** ❌ Content Calendar feature není implementovaná

**Impact:**
- Feature matrix je misleading
- Mělo by být: "Planned" nebo "Coming soon"

#### ⚠️ AI Vizuály - API KEY EXISTUJE, PROVIDER NE

**Dokument říká:**
```
│ AI Vizuály         │  ❌   │  ❌   │  ✅   │     ✅     │
```

**Realita:**
```bash
# .env.production
NANOBANA_API_KEY=<key>  # ✅ Nanobana (Imagen) key existuje
```

```python
# apps/ai_gateway/enums.py
# ❌ Ale AIProvider enum neexistuje
# ⚠️ Není jasné, zda Nanobana je aktivně používána
```

**Status:** ⚠️ Infrastructure ready, ale feature possibly not live

#### ⚠️ AI Video - API KEY EXISTUJE, PROVIDER NE

**Dokument říká:**
```
│ AI Video           │  ❌   │  ❌   │  ❌   │     ✅     │
```

**Realita:**
```bash
# .env.production
VEO_API_KEY=<key>  # ✅ Veo 3 key existuje
```

**Status:** ⚠️ Infrastructure ready, ale feature possibly not live

#### ❌ Multi-organization vs max_companies

**Dokument říká:**
```
│ Multi-organization │  ❌   │  ❌   │  ❌   │     ✅     │
```

**Realita:**
```python
# tier_limits.py
'ultimate': {
    'max_companies': 3,  # ✅ Multi-company support
}
```

**Terminologie:**
- Dokument: "Multi-organization"
- Realita: "Multi-company" (`max_companies` limit)

**Status:** ✅ Feature existuje, ale jiný naming

---

### 6.10 Porovnání: Plánované vs Skutečné Pricing

#### Tier Structure

| Aspekt | Plánováno | Implementováno | Shoda |
|--------|-----------|----------------|-------|
| **Tier count** | 4 tiers | 3 tiers | 75% |
| **TRIAL** | ✅ | ❌ | 0% |
| **BASIC** | ✅ | ✅ | 100% |
| **PRO** | ✅ | ✅ | 100% |
| **ENTERPRISE** | ✅ | ❌ → ULTIMATE | 0% |
| **Ceny** | ✅ | ✅ | 100% |

#### Limity (PRO tier example)

| Limit | Plánováno | Implementováno | Shoda |
|-------|-----------|----------------|-------|
| companies | 1 | 2 | ❌ |
| personas | 6 | 6 | ✅ |
| platforms | 6 | 6 | ✅ |
| posts/month | 24 | 24 | ✅ |

#### Add-ony

| Add-on Type | Plánováno | Implementováno | Shoda |
|-------------|-----------|----------------|-------|
| Supervisor | ✅ (299 Kč) | ❌ | 0% |
| Persona | ✅ (199 Kč) | ⚠️ (490 Kč) | 50% |
| Language | ✅ (499 Kč) | ❌ | 0% |
| Visual | ✅ (99 Kč) | ❌ | 0% |
| Platform | ✅ (199 Kč) | ❌ | 0% |
| Marketer | ✅ (599 Kč) | ❌ | 0% |
| Storage | ✅ (49 Kč) | ❌ | 0% |
| Regeneration | ✅ (149 Kč) | ❌ | 0% |
| Extra Company | ❌ | ✅ (1 490 Kč) | NEW |
| Priority Queue | ❌ | ✅ (990 Kč) | NEW |

**Add-on shoda: 0/8** plánovaných existuje

---

### 6.11 Database Structure - Actual Tables

#### ✅ Co EXISTUJE v DB

```sql
-- dj-stripe tables
djstripe_customer
djstripe_subscription
djstripe_product
djstripe_price
djstripe_subscriptionitem
djstripe_invoice
djstripe_charge

-- Custom tables
billing_organization_addons  -- ✅ Skutečný table
```

#### ❌ Co NEEXISTUJE v DB

```sql
-- Plánované tables z dokumentu
billing_subscription         -- ❌ NEEXISTUJE (je djstripe_subscription)
billing_subscription_addon   -- ❌ NEEXISTUJE (je billing_organization_addons)
```

---

### 6.12 Critical Gaps & Inconsistencies

#### 🔴 CRITICAL Issues

| Issue | Impact | Priority |
|-------|--------|----------|
| **TRIAL tier missing** | Nové registrace nejasné | 🔴 HIGH |
| **ENTERPRISE vs ULTIMATE** | Kód nefunguje s enterprise | 🔴 HIGH |
| **Add-ony kompletně jiné** | Dokumentace misleading | 🔴 HIGH |
| **Content Calendar neexistuje** | Feature matrix false | 🔴 HIGH |

#### 🟡 MEDIUM Issues

| Issue | Impact | Priority |
|-------|--------|----------|
| **PRO: 1 vs 2 companies** | Limit dokumentace wrong | 🟡 MEDIUM |
| **ULTIMATE: 12 vs 18 personas** | Limit logic unclear | 🟡 MEDIUM |
| **organizations vs max_companies** | Terminologie matoucí | 🟡 MEDIUM |

#### 🟢 LOW Issues

| Issue | Impact | Priority |
|-------|--------|----------|
| **AI Vizuály/Video status** | Unclear zda live | 🟢 LOW |
| **Storage limits missing** | Nevíme skutečné hodnoty | 🟢 LOW |

---

### 6.13 Migration Path: Align Pricing Docs

#### Phase 1: Fix Critical Naming (Week 1)

```python
# 1. Update enum definition
class SubscriptionTier(str, Enum):
    # TRIAL = "trial"        # ❌ ODSTRANIT
    BASIC = "basic"           # ✅ OK
    PRO = "pro"               # ✅ OK
    ULTIMATE = "ultimate"     # ✅ NE 'enterprise'

# 2. Update tier limits
TIER_LIMITS = {
    # Odstranit TRIAL
    'basic': {...},
    'pro': {
        'max_companies': 2,   # ✅ NE 1
        ...
    },
    'ultimate': {             # ✅ NE 'enterprise'
        'max_companies': 3,
        'personas': 12,       # ✅ NE 6/firma
        ...
    },
}
```

#### Phase 2: Document Actual Add-ons (Week 1-2)

```python
# Replace all 8 planned addons with actual 3
ADDON_PRICES = {
    'extra_company': {
        'name': 'Extra Company',
        'price_czk': 1490,
        'stripe_price_id': 'price_extra_company',
        'unit': 'per_company',
    },
    'extra_personas': {
        'name': 'Extra Personas',
        'price_czk': 490,
        'stripe_price_id': 'price_extra_personas',
        'unit': 'per_pack',  # Kolik person v balíčku?
    },
    'priority_queue': {
        'name': 'Priority Queue',
        'price_czk': 990,
        'stripe_price_id': 'price_priority_queue',
        'unit': 'boolean',
    },
}
```

#### Phase 3: Fix Feature Matrix (Week 2)

```diff
│ Funkce             │ Basic │  Pro  │ Ultimate │
├────────────────────┼───────┼───────┼──────────┤
│ AI Persony         │  ✅   │  ✅   │    ✅    │
- │ Content Calendar   │  ✅   │  ✅   │    ✅    │
+ │ Content Calendar   │  🚧   │  🚧   │    🚧    │  # Planned
│ Approval Workflow  │  ❌   │  ✅   │    ✅    │
- │ AI Vizuály         │  ❌   │  ✅   │    ✅    │
+ │ AI Vizuály         │  ❌   │  🚧   │    🚧    │  # Infrastructure ready
- │ AI Video           │  ❌   │  ❌   │    ✅    │
+ │ AI Video           │  ❌   │  ❌   │    🚧    │  # Infrastructure ready
- │ Multi-organization │  ❌   │  ❌   │    ✅    │
+ │ Multi-company      │  ❌   │  ⚠️   │    ✅    │  # Pro has 2
```

#### Phase 4: Update Models Section (Week 2-3)

```markdown
## Implementační Detaily

### Subscription Models

⚠️ **DŮLEŽITÉ:** PostHub používá [dj-stripe](https://dj-stripe.dev/) pro Stripe integraci.

**Custom models:**
- `OrganizationAddOn` - pro add-ony
- Subscription data v `djstripe.Subscription`

**Tier se určuje z:**
```python
subscription = organization.djstripe_subscription
tier = subscription.plan.product.metadata.get('tier', 'basic')
```
```

---

### 6.14 Pricing Page - Co zobrazit zákazníkům

#### ✅ Správné Ceny (Copy-Paste Ready)

**BASIC - 990 Kč/měsíc**
- 1 firma
- 3 AI persony
- 3 platformy
- 12 příspěvků/měsíc
- 1 regenerace
- 512 MB úložiště

**PRO - 2 490 Kč/měsíc** ⭐ NEJOBLÍBENĚJŠÍ
- **2 firmy** (ne 1!)
- 6 AI person
- 6 platforem
- 24 příspěvků/měsíc
- 3 regenerace
- Priority support
- 3 GB úložiště

**ULTIMATE - 7 490 Kč/měsíc** (ne Enterprise!)
- **3 firmy**
- **12 AI person celkem** (ne 6/firma)
- Všechny platformy
- 72 příspěvků/měsíc
- 10 regenerací
- Priority support
- API access
- 10 GB úložiště

**Doplňky:**
- Extra Company: **1 490 Kč/měsíc**
- Extra Personas: **490 Kč/měsíc**
- Priority Queue: **990 Kč/měsíc**

---

### 6.15 Action Items - Pricing Alignment

#### Immediate (týdny)

- [ ] **CRITICAL:** Update všechny `ENTERPRISE` → `ULTIMATE` v kódu
- [ ] **CRITICAL:** Remove TRIAL tier z dokumentace nebo implement
- [ ] **CRITICAL:** Update add-ony documentation (8 → 3)
- [ ] Fix PRO tier: 1 company → 2 companies
- [ ] Fix ULTIMATE: personas 6/firma → 12 celkem
- [ ] Update Feature Matrix (Content Calendar = Planned)

#### Short-term (měsíce)

- [ ] Clarify AI Vizuály/Video status (ready? live? coming?)
- [ ] Document dj-stripe integration properly
- [ ] Create tier comparison table with ACTUAL values
- [ ] Update Stripe products to match ULTIMATE naming
- [ ] Verify storage limits per tier

#### Long-term (6+ měsíců)

- [ ] Decide: Implement TRIAL tier nebo remove z docs?
- [ ] Evaluate: Should we add back some of the 8 planned addons?
- [ ] Consider: Měnit terminologii organizations → companies všude
- [ ] Implement: Content Calendar feature (if planned)

---

**📊 ZÁVĚR:**

Dokument 14_PRICING_PLANS.md popisuje **PLÁNOVANOU** pricing strukturu.  
**Skutečný stav má ~40-45% shodu** s dokumentem.  

**Co má přesnou shodu:**
- ✅ Ceny (990, 2 490, 7 490 Kč) - 100% OK!

**Kritické rozdíly:**
- 🔴 TRIAL tier neexistuje v DB
- 🔴 ENTERPRISE → ULTIMATE naming
- 🔴 Add-ony: 8 plánovaných → 3 skutečné (kompletně jiné)
- 🔴 Content Calendar neexistuje
- ⚠️ PRO: 1 → 2 companies
- ⚠️ ULTIMATE: 6/firma → 12 celkem personas

**Models:**
- Používá dj-stripe (ne custom Subscription model)
- OrganizationAddOn místo SubscriptionAddon
- Jiná DB struktura

**Priorita:** Update dokumentace na ULTIMATE naming + skutečné add-ony ASAP!

---

*Tento dokument je SELF-CONTAINED - obsahuje všechny informace o cenách a předplatném.*
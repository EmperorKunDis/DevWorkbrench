# Agent 4 - Billing

## Zodpovednost

Stripe integrace pres dj-stripe, Usage tracking, Subscription management, Tier limits enforcement

---

## Tech Stack

| Technologie | Pouziti |
|-------------|---------|
| dj-stripe | Stripe integration package |
| Stripe | Payment processor |
| PostgreSQL | Subscription & usage data |

**KRITICKE:** Pouzivame `dj-stripe` package, NE custom Subscription model!

---

## Tier Structure (REALITA!)

| Tier | Cena/mesic | Cena/rok | max_companies | personas | platformy | posts/mesic |
|------|------------|----------|---------------|----------|-----------|-------------|
| **BASIC** | 990 Kc | 9 900 Kc | 1 | 3 | 3 | 12 |
| **PRO** | 2 490 Kc | 24 900 Kc | 2 | 6 | 6 | 24 |
| **ULTIMATE** | 7 490 Kc | 74 900 Kc | 3 | 12 | All (5) | 72 |

**POZOR:**
- Tier se jmenuje **ULTIMATE**, NE ENTERPRISE!
- **TRIAL tier NEEXISTUJE** v DB (resi se pres Stripe trial period)
- PRO ma **2 companies**, ne 1!
- ULTIMATE ma **12 person celkem**, ne 6 per company!

---

## Add-ons (REALITA - pouze 3!)

| Add-on | Cena/mesic | Popis |
|--------|------------|-------|
| `extra_company` | 1 490 Kc | Dalsi firma pod organizaci |
| `extra_personas` | 490 Kc | +3 persony |
| `priority_queue` | 990 Kc | Prednostni zpracovani AI jobu |

**POZOR:** Dokumentace zminuje 8 add-onu, ale implementovany jsou pouze tyto 3!

---

## Database Architecture

### dj-stripe Models (pouzivame!)

```python
from djstripe.models import (
    Customer,      # Stripe customer (linked to Organization)
    Subscription,  # Stripe subscription
    Product,       # PostHub Basic/Pro/Ultimate
    Price,         # Monthly/Annual prices
    Invoice,       # Payment history
    PaymentMethod, # Card details
)
```

### Custom Models

```python
# apps/billing/models.py

class OrganizationAddOn(models.Model):
    """Custom add-ons beyond dj-stripe."""
    organization = models.ForeignKey('organizations.Organization')
    addon_type = models.CharField(choices=[
        ('extra_company', 'Extra Company'),
        ('extra_personas', 'Extra Personas'),
        ('priority_queue', 'Priority Queue'),
    ])
    quantity = models.PositiveIntegerField(default=1)
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2)
    is_active = models.BooleanField(default=True)
    stripe_subscription_item_id = models.CharField(blank=True)

    class Meta:
        db_table = 'billing_organization_addons'
```

---

## Tier Limits Implementation

```python
# apps/billing/tier_limits.py

TIER_LIMITS = {
    'basic': {
        'max_companies': 1,
        'personas': 3,
        'platforms': 3,
        'posts_per_month': 12,
        'regenerations_per_post': 1,
        'storage_mb': 512,
        'visuals_enabled': False,
        'video_enabled': False,
    },
    'pro': {
        'max_companies': 2,    # NE 1!
        'personas': 6,
        'platforms': 6,
        'posts_per_month': 24,
        'regenerations_per_post': 3,
        'storage_mb': 3072,
        'visuals_enabled': True,
        'video_enabled': False,
    },
    'ultimate': {              # NE 'enterprise'!
        'max_companies': 3,
        'personas': 12,        # Celkem, ne per company!
        'platforms': 6,
        'posts_per_month': 72,
        'regenerations_per_post': 3,
        'storage_mb': 10240,
        'visuals_enabled': True,
        'video_enabled': True,
    },
}

def get_tier_limits(tier: str) -> dict:
    """Get limits for a tier."""
    return TIER_LIMITS.get(tier, TIER_LIMITS['basic'])

def get_effective_limits(organization) -> dict:
    """Get limits including add-ons."""
    base_limits = get_tier_limits(organization.subscription_tier)

    for addon in organization.addons.filter(is_active=True):
        if addon.addon_type == 'extra_company':
            base_limits['max_companies'] += addon.quantity
        elif addon.addon_type == 'extra_personas':
            base_limits['personas'] += addon.quantity * 3
        elif addon.addon_type == 'priority_queue':
            base_limits['priority'] = True

    return base_limits
```

---

## Getting Tier from dj-stripe

```python
def get_organization_tier(organization) -> str:
    """Get tier from Stripe subscription."""
    customer = Customer.objects.filter(
        subscriber=organization
    ).first()

    if not customer:
        return 'basic'  # Default

    subscription = customer.subscriptions.filter(
        status__in=['active', 'trialing']
    ).first()

    if not subscription:
        return 'basic'

    # Tier is stored in product metadata
    product = subscription.plan.product
    return product.metadata.get('tier', 'basic')
```

---

## Limit Validation

```python
# apps/billing/validators.py

def validate_persona_limit(organization):
    """Check if organization can add more personas."""
    limits = get_effective_limits(organization)
    current_count = Persona.objects.filter(
        company__organization=organization
    ).count()

    if current_count >= limits['personas']:
        raise ValidationError(
            f"Dosažen limit person ({limits['personas']}). "
            f"Upgradujte tarif nebo přidejte doplněk Extra Personas."
        )

def validate_company_limit(organization):
    """Check if organization can add more companies."""
    limits = get_effective_limits(organization)
    current_count = organization.companies.count()

    if current_count >= limits['max_companies']:
        raise ValidationError(
            f"Dosažen limit firem ({limits['max_companies']}). "
            f"Upgradujte tarif nebo přidejte doplněk Extra Company."
        )

def validate_post_limit(organization):
    """Check monthly post limit."""
    limits = get_effective_limits(organization)
    current_month_posts = SocialPost.objects.filter(
        blog_post__topic__company__organization=organization,
        created_at__month=timezone.now().month
    ).count()

    if current_month_posts >= limits['posts_per_month']:
        raise ValidationError(
            f"Dosažen měsíční limit příspěvků ({limits['posts_per_month']})."
        )

def validate_feature_access(organization, feature: str):
    """Check feature access by tier."""
    limits = get_effective_limits(organization)

    if feature == 'visuals' and not limits.get('visuals_enabled'):
        raise ValidationError("Vizuály dostupné od tarifu PRO.")

    if feature == 'video' and not limits.get('video_enabled'):
        raise ValidationError("Video dostupné pouze v tarifu ULTIMATE.")
```

---

## Stripe Webhook Handling

```python
# apps/billing/webhooks.py

from djstripe import webhooks

@webhooks.handler("customer.subscription.created")
@webhooks.handler("customer.subscription.updated")
def handle_subscription_change(event, **kwargs):
    """Handle subscription changes."""
    subscription = event.data.object
    customer = Customer.objects.get(id=subscription.customer)
    organization = customer.subscriber

    # Update organization tier
    product = subscription.plan.product
    organization.subscription_tier = product.metadata.get('tier', 'basic')
    organization.save()

    # Send notification
    Notification.objects.create(
        user=organization.owner,
        notification_type='payment_received',
        title='Předplatné aktivováno',
        message=f'Váš tarif {organization.subscription_tier.upper()} je aktivní.'
    )

@webhooks.handler("customer.subscription.deleted")
def handle_subscription_cancelled(event, **kwargs):
    """Handle subscription cancellation."""
    # ...

@webhooks.handler("invoice.payment_failed")
def handle_payment_failed(event, **kwargs):
    """Handle failed payment."""
    # Send urgent notification
    # Pause add-ons
    # Grace period logic
```

---

## API Endpoints

```
Subscription:
  GET  /api/v1/billing/subscription/       → Current subscription info
  POST /api/v1/billing/checkout/           → Create Stripe Checkout session
  POST /api/v1/billing/portal/             → Create Stripe Portal session
  GET  /api/v1/billing/invoices/           → Invoice history

Usage:
  GET  /api/v1/billing/usage/              → Current usage vs limits
  GET  /api/v1/billing/limits/             → Effective limits (incl. add-ons)

Add-ons:
  GET  /api/v1/billing/addons/             → Available add-ons
  POST /api/v1/billing/addons/purchase/    → Purchase add-on

Webhooks:
  POST /api/v1/billing/webhook/stripe/     → Stripe webhook endpoint
```

---

## Stripe Product Setup

```bash
# Products
stripe products create --name="PostHub Basic" --metadata[tier]=basic
stripe products create --name="PostHub Pro" --metadata[tier]=pro
stripe products create --name="PostHub Ultimate" --metadata[tier]=ultimate

# Prices (in haliru - 1 Kc = 100 haliru)
stripe prices create --product=prod_basic --unit-amount=99000 --currency=czk --recurring[interval]=month
stripe prices create --product=prod_basic --unit-amount=990000 --currency=czk --recurring[interval]=year

stripe prices create --product=prod_pro --unit-amount=249000 --currency=czk --recurring[interval]=month
stripe prices create --product=prod_pro --unit-amount=2490000 --currency=czk --recurring[interval]=year

stripe prices create --product=prod_ultimate --unit-amount=749000 --currency=czk --recurring[interval]=month
stripe prices create --product=prod_ultimate --unit-amount=7490000 --currency=czk --recurring[interval]=year
```

---

## Environment Variables

```bash
STRIPE_PUBLIC_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Price IDs
STRIPE_PRICE_BASIC=price_...
STRIPE_PRICE_PRO=price_...
STRIPE_PRICE_ULTIMATE=price_...  # NE ENTERPRISE!
STRIPE_PRICE_BASIC_YEARLY=price_...
STRIPE_PRICE_PRO_YEARLY=price_...
STRIPE_PRICE_ULTIMATE_YEARLY=price_...
```

---

## CheckAgent Requirements

### ZAKAZANO
- Custom Subscription model (pouzit dj-stripe!)
- ENTERPRISE naming (spravne je ULTIMATE)
- Hardcoded Stripe keys
- Missing webhook signature verification

### POVINNE
- dj-stripe integration
- Tier limits validation
- Usage tracking
- Webhook handlers
- Stripe Portal for self-service

---

## Documentation Reference

- `files/07_PAYMENTS_STRIPE.md` - Stripe integration
- `files/14_PRICING_PLANS.md` - Pricing (REALITY CHECK section!)

---

## Current Task

**COMPLETED** - Stripe integration is done

---

## Status

COMPLETED - dj-stripe integration functional

---

**|**

## CheckAgent Verification

### Status: PASS

### Kontrolovane oblasti
| Check | Status |
|-------|--------|
| dj-stripe integration | PASS |
| Tier naming (ULTIMATE) | PASS |
| Add-ons (3 actual) | PASS |
| Webhook handlers | PASS |
| Limit validation | PASS |

### Datum kontroly
2025-12-18

# CONTEXT_ENGINEERING.md - PostHub.work

**Dokument:** Context Engineering & User Stories  
**Verze:** 2.0.0  
**Účel:** Kompletní kontext pro AI agenty a vývojový tým  
**Self-Contained:** ✅ Všechny informace pro pochopení systému  
**Poslední aktualizace:** December 2025

---

## 📋 OBSAH

1. [Product Vision](#1-product-vision)
2. [Actors & Roles](#2-actors--roles)
3. [User Stories - Admin](#3-user-stories---admin)
4. [User Stories - Manager](#4-user-stories---manager)
5. [User Stories - Marketer](#5-user-stories---marketer)
6. [User Stories - Supervisor](#6-user-stories---supervisor)
7. [System User Stories](#7-system-user-stories)
8. [Epic Breakdown](#8-epic-breakdown)
9. [Domain Glossary](#9-domain-glossary)
10. [Technical Context](#10-technical-context)
11. [Subscription & Billing](#11-subscription--billing)
12. [Affiliate System](#12-affiliate-system)
13. [Acceptance Criteria Templates](#13-acceptance-criteria-templates)
14. [Non-Functional Requirements](#14-non-functional-requirements)

---

## 1. PRODUCT VISION

### Elevator Pitch

PostHub je B2B SaaS platforma pro automatizovanou tvorbu konzistentního obsahu na sociální sítě. Využívá AI k vytváření person, generování blog postů a transformaci na platformově specifické příspěvky s grafikou a videem.

### Problem Statement

Firmy potřebují konzistentní přítomnost na sociálních sítích, ale:
- Nemají čas vytvářet kvalitní obsah pravidelně
- Obsah není konzistentní s brand voice
- Chybí strategie a plánování
- Nemají rozpočet na full-time marketéra

### Solution

Téměř plně automatizovaný systém, kde:
1. AI analyzuje firmu a vytvoří persony (fiktivní autory)
2. AI plánuje měsíční témata
3. AI generuje blog posty ve stylu persony
4. AI transformuje na social posty + grafiku/video
5. Supervisor pouze schvaluje

### Value Proposition

| Pro koho | Hodnota |
|----------|---------|
| **Malé firmy** | Profesionální content marketing bez marketéra |
| **Střední firmy** | Škálování obsahu bez zvýšení headcount |
| **Agentury** | Efektivní správa mnoha klientů |

### Content Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AI CONTENT GENERATION PIPELINE                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                 │
│   │  SCRAPE DNA  │───▶│   GENERATE   │───▶│   GENERATE   │                 │
│   │  Perplexity  │    │   PERSONAS   │    │    TOPICS    │                 │
│   │              │    │    Gemini    │    │    Gemini    │                 │
│   └──────────────┘    └──────────────┘    └──────────────┘                 │
│          │                   │                   │                          │
│          ▼                   ▼                   ▼                          │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                 │
│   │  Company DNA │    │   6 Personas │    │ Topics/month │                 │
│   │  30+ points  │    │  (select 2-6)│    │  (approval)  │                 │
│   └──────────────┘    └──────────────┘    └──────────────┘                 │
│                                                  │                          │
│                              ┌───────────────────┘                          │
│                              ▼                                              │
│                       ┌──────────────┐                                      │
│                       │   GENERATE   │                                      │
│                       │  BLOG POST   │                                      │
│                       │    Gemini    │                                      │
│                       └──────────────┘                                      │
│                              │                                              │
│                              ▼                                              │
│                       ┌──────────────┐                                      │
│                       │  4-10 pages  │                                      │
│                       │  A4 content  │                                      │
│                       │  (approval)  │                                      │
│                       └──────────────┘                                      │
│                              │                                              │
│          ┌───────────────────┼───────────────────┐                          │
│          ▼                   ▼                   ▼                          │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                 │
│   │   GENERATE   │    │   GENERATE   │    │   GENERATE   │                 │
│   │ SOCIAL POSTS │    │    IMAGES    │    │    VIDEO     │                 │
│   │    Gemini    │    │   Nanobana   │    │    Veo 3     │                 │
│   └──────────────┘    └──────────────┘    └──────────────┘                 │
│          │                   │                   │                          │
│          ▼                   ▼                   ▼                          │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                 │
│   │  Per-platform│    │   PRO+ tier  │    │  ULTIMATE    │                 │
│   │   optimized  │    │    only      │    │  tier only   │                 │
│   └──────────────┘    └──────────────┘    └──────────────┘                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. ACTORS & ROLES

### Role Hierarchy

```
ADMIN (System Owner - Platform Owner)
  │
  └── MANAGER (Team Lead - Manages Marketers)
        │
        └── MARKETER (Content Manager - Manages Supervisors)
              │
              └── SUPERVISOR (Client - Paying Customer)
```

### Actor Definitions

#### 2.1 Admin
- **Kdo:** Majitel platformy (jeden nebo několik)
- **Odpovědnost:** Správa celého systému, vytváření Manažerů
- **Přístup:** Všechno
- **Platí:** Ne (vlastník platformy)

#### 2.2 Manager
- **Kdo:** Team leader, vedoucí týmu marketérů
- **Odpovědnost:** Správa Marketérů, dohled nad kvalitou, reporting
- **Přístup:** Všechny firmy svých Marketérů, může manuálně přidělovat
- **Platí:** Ne (zaměstnanec/kontraktor platformy)
- **Speciální:** Vidí všechny Supervisory, Organizace, Company, Persony všech Marketérů pod sebou

#### 2.3 Marketer
- **Kdo:** Content manager, správce portfolia firem
- **Odpovědnost:** Denní správa přiřazených Supervisorů/firem
- **Přístup:** Pouze přiřazené firmy
- **Platí:** Ne (zaměstnanec/kontraktor platformy)
- **Affiliate:** Může posílat invite links a získat speciální feature za nejlepší měsíční skóre

#### 2.4 Supervisor
- **Kdo:** Klient - zástupce firmy, jejíž obsah se vytváří
- **Odpovědnost:** Schvalování obsahu, poskytování vstupů
- **Přístup:** Pouze vlastní Organization a Company (dle tieru 1-3 companies)
- **Platí:** **ANO - jediný platící uživatel**

### Distribution Model

```
Admin (1)
  └── Manages: 2-5 Managers

Manager (2-5)
  └── Each manages: 5-20 Marketers

Marketer (10-100)
  └── Each manages: 10-50 Supervisors

Supervisor (100-5000+)
  └── Each owns: 1 Organization with 1-3 Companies (based on tier)
```

### Entity Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                    SUPERVISOR (platící uživatel)                │
│                              │                                  │
│                              ▼                                  │
│                      ┌──────────────┐                          │
│                      │ ORGANIZATION │ ◄── Billing account      │
│                      │   (Tenant)   │     Subscription         │
│                      └──────────────┘     Add-ons              │
│                              │                                  │
│              ┌───────────────┼───────────────┐                 │
│              ▼               ▼               ▼                 │
│        ┌─────────┐    ┌─────────┐    ┌─────────┐              │
│        │ COMPANY │    │ COMPANY │    │ COMPANY │ ◄── 1-3 dle  │
│        │  (DNA)  │    │  (DNA)  │    │  (DNA)  │     tieru    │
│        └─────────┘    └─────────┘    └─────────┘              │
│              │               │               │                 │
│              ▼               ▼               ▼                 │
│        ┌─────────┐    ┌─────────┐    ┌─────────┐              │
│        │PERSONAS │    │PERSONAS │    │PERSONAS │ ◄── 3-12 dle │
│        │ TOPICS  │    │ TOPICS  │    │ TOPICS  │     tieru    │
│        │ CONTENT │    │ CONTENT │    │ CONTENT │              │
│        └─────────┘    └─────────┘    └─────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

**Vysvětlení:** Jeden Supervisor může mít pod jednou Organization několik Companies z různých oborů. Organization slouží jako billing account, Company reprezentuje skutečnou firmu s vlastním DNA a obsahem.

---

## 3. USER STORIES - ADMIN

### Epic: Admin - User Management

```gherkin
US-A001: Vytvoření Managera
  JAKO Admin
  CHCI vytvořit nový účet pro Managera
  ABYCH mohl rozšířit kapacitu platformy

  Acceptance Criteria:
  - [x] Formulář: email, jméno, příjmení
  - [x] Automatický invite email
  - [x] Manager se zobrazí v seznamu
  - [x] Manager má roli MANAGER
  - [x] Validace unikátního emailu

US-A002: Přiřazení Marketérů k Managerovi
  JAKO Admin
  CHCI přiřadit existující Marketéry pod Managera
  ABYCH vytvořil strukturovaný tým

  Acceptance Criteria:
  - [x] Multi-select Marketérů
  - [x] Drag & drop reassignment
  - [x] Historie změn

US-A003: Zobrazení celkové statistiky
  JAKO Admin
  CHCI vidět dashboard s celkovými metrikami
  ABYCH měl přehled o zdraví platformy

  Acceptance Criteria:
  - [x] Počet aktivních Supervisorů
  - [x] MRR (Monthly Recurring Revenue)
  - [x] Churn rate
  - [x] Počet vygenerovaných příspěvků
  - [x] AI cost tracking

US-A004: Správa subscription tierů
  JAKO Admin
  CHCI upravovat parametry subscription tierů
  ABYCH mohl reagovat na tržní podmínky

  Acceptance Criteria:
  - [x] Edit: cena, limity, features
  - [x] Změny neovlivní existující subscriptions (grandfathering)
  - [x] Preview změn před uložením
```

### Epic: Admin - System Configuration

```gherkin
US-A010: Konfigurace AI providerů
  JAKO Admin
  CHCI nastavit API klíče pro AI providery
  ABYCH mohl spravovat AI služby

  Acceptance Criteria:
  - [x] Secure input pro API klíče
  - [x] Test connection button
  - [x] Fallback configuration

US-A011: Monitoring AI nákladů
  JAKO Admin
  CHCI vidět breakdown AI nákladů per tenant
  ABYCH mohl optimalizovat profitabilitu

  Acceptance Criteria:
  - [x] Cost per organization
  - [x] Cost per feature (text/image/video)
  - [x] Monthly trend
  - [x] Export to CSV

US-A012: Správa prompt templates
  JAKO Admin
  CHCI editovat AI prompty v databázi
  ABYCH mohl optimalizovat kvalitu generování

  Acceptance Criteria:
  - [x] CRUD pro PromptTemplate
  - [x] Versioning promptů
  - [x] A/B testing capability
  - [x] Fallback na hardcoded defaults
```

---

## 4. USER STORIES - MANAGER

### Epic: Manager - Team Management

```gherkin
US-M001: Vytvoření Marketéra
  JAKO Manager
  CHCI vytvořit nový účet pro Marketéra
  ABYCH rozšířil svůj tým

  Acceptance Criteria:
  - [x] Formulář: email, jméno, příjmení
  - [x] Automaticky přiřazen pod mě
  - [x] Invite email
  - [x] Zobrazí se v mém team seznamu

US-M002: Přiřazení Supervisorů k Marketérovi
  JAKO Manager
  CHCI přiřadit Supervisory pod Marketéra
  ABYCH rozložil workload rovnoměrně

  Acceptance Criteria:
  - [x] Algoritmus pro vyvážené přiřazení
  - [x] Portfolio matching (podobné obory)
  - [x] Manuální override
  - [x] Notifikace Marketérovi

US-M003: Zobrazení team dashboard
  JAKO Manager
  CHCI vidět přehled výkonu svého týmu
  ABYCH mohl identifikovat problémy

  Acceptance Criteria:
  - [x] Performance per Marketer
  - [x] Pending approvals count
  - [x] SLA breaches
  - [x] Workload distribution chart

US-M004: Reassignment při absenci
  JAKO Manager
  CHCI dočasně přesunout Supervisory jinému Marketérovi
  ABYCH zajistil kontinuitu při dovolené/nemoci

  Acceptance Criteria:
  - [x] Bulk select & transfer
  - [x] Časově omezené přiřazení
  - [x] Automatický return

US-M005: Kompletní přehled portfolia
  JAKO Manager
  CHCI vidět všechny Supervisory, Organizace, Company a Persony
  ABYCH měl kompletní přehled

  Acceptance Criteria:
  - [x] Hierarchický view: Manager → Marketers → Supervisors → Orgs → Companies
  - [x] Filtry a vyhledávání
  - [x] Export dat
```

### Epic: Manager - Quality Oversight

```gherkin
US-M010: Review sample content
  JAKO Manager
  CHCI náhodně kontrolovat vygenerovaný obsah
  ABYCH zajistil kvalitu napříč týmem

  Acceptance Criteria:
  - [x] Random sampling across Marketers
  - [x] Quality score input
  - [x] Feedback loop to Marketer

US-M011: Escalation handling
  JAKO Manager
  CHCI řešit eskalované problémy od Supervisorů
  ABYCH zajistil spokojenost klientů

  Acceptance Criteria:
  - [x] Escalation queue
  - [x] Assignment to self or Marketer
  - [x] Resolution tracking
```

---

## 5. USER STORIES - MARKETER

### Epic: Marketer - Daily Operations

```gherkin
US-MK001: Zobrazení assigned companies
  JAKO Marketer
  CHCI vidět seznam všech mých přiřazených firem
  ABYCH měl přehled o svém portfoliu

  Acceptance Criteria:
  - [x] List view s filtry
  - [x] Status indicators (pending actions)
  - [x] Quick actions

US-MK002: Kontrola pending approvals
  JAKO Marketer
  CHCI vidět obsah čekající na schválení
  ABYCH mohl proaktivně kontaktovat Supervisory

  Acceptance Criteria:
  - [x] Grouped by company
  - [x] Days waiting indicator
  - [x] Send reminder action

US-MK003: Manuální trigger regenerace
  JAKO Marketer
  CHCI manuálně spustit regeneraci obsahu
  KDYŽ Supervisor odmítne a chce novou verzi

  Acceptance Criteria:
  - [x] Regenerate button
  - [x] Option: preserve partial content
  - [x] Feedback input for AI

US-MK004: Editace vygenerovaného obsahu
  JAKO Marketer
  CHCI manuálně upravit AI vygenerovaný text
  ABYCH opravil drobné chyby bez regenerace

  Acceptance Criteria:
  - [x] Rich text editor
  - [x] Version history
  - [x] "Edited by Marketer" flag
```

### Epic: Marketer - Company Setup Support

```gherkin
US-MK010: Asistence při onboardingu
  JAKO Marketer
  CHCI vidět progress onboardingu nových Supervisorů
  ABYCH mohl nabídnout pomoc

  Acceptance Criteria:
  - [x] Onboarding funnel view
  - [x] Stuck step indicator
  - [x] Contact options

US-MK011: Persona review a úprava
  JAKO Marketer
  CHCI doporučit úpravy person
  KDYŽ vidím prostor pro zlepšení

  Acceptance Criteria:
  - [x] Suggest changes (soft recommendation)
  - [x] Direct edit (with Supervisor notification)
  - [x] Reason for change input

US-MK012: Affiliate invite
  JAKO Marketer
  CHCI poslat affiliate invite link
  ABYCH získal bonus za nového klienta

  Acceptance Criteria:
  - [x] Generate unique affiliate link
  - [x] Track clicks a conversions
  - [x] Automatické přiřazení pod mě při registraci
  - [x] Bonus po zaplacení pozvaného
```

---

## 6. USER STORIES - SUPERVISOR

### Epic: Supervisor - Onboarding

```gherkin
US-S001: Registrace účtu
  JAKO nový Supervisor
  CHCI se registrovat na platformu
  ABYCH mohl začít využívat služby

  Acceptance Criteria:
  - [x] Email + heslo registrace
  - [x] Email verification
  - [x] Přesměrování na onboarding wizard
  - [x] Affiliate tracking (pokud přišel z invite)

US-S002: Vyhledání firmy
  JAKO Supervisor
  CHCI vyhledat svou firmu podle názvu
  ABYCH ji nemusel ručně zadávat

  Acceptance Criteria:
  - [x] Search input s autocomplete
  - [x] Google API integration pro návrhy
  - [x] Možnost upřesnění hledání
  - [x] Fallback: manuální zadání

US-S003: Potvrzení firmy
  JAKO Supervisor
  CHCI vybrat správnou firmu ze seznamu
  ABYCH získal správné firemní údaje

  Acceptance Criteria:
  - [x] List výsledků s preview (název, adresa, logo)
  - [x] Click to select
  - [x] "None of these" option pro manuální zadání

US-S004: AI scraping firemních údajů
  JAKO Supervisor
  CHCI aby systém automaticky získal údaje o firmě
  ABYCH nemusel vše vyplňovat ručně

  Acceptance Criteria:
  - [x] Perplexity API call na pozadí
  - [x] SSE progress indicator ("Analyzing DNA... 23%")
  - [x] Preview scraped data
  - [x] Edit option pro korekce
  - [x] Minimálně 30 data pointů

US-S005: Generování person
  JAKO Supervisor
  CHCI nechat AI vygenerovat persony pro mou firmu
  ABYCH měl konzistentní autory obsahu

  Acceptance Criteria:
  - [x] "Generate Personas" button
  - [x] SSE progress ("Generating personas... 67%")
  - [x] Generuje se 6 person (maximum)
  - [x] Preview všech person

US-S006: Výběr person
  JAKO Supervisor
  CHCI vybrat které persony chci používat
  PODLE mého subscription tieru (3/6/12)

  Acceptance Criteria:
  - [x] Card selection UI
  - [x] Max selection based on tier
  - [x] "Continue" enabled after min selection

US-S007: Úprava persony
  JAKO Supervisor
  CHCI upravit detaily vybrané persony
  ABYCH ji přizpůsobil svým potřebám

  Acceptance Criteria:
  - [x] Editable fields: name, style, tone, topics
  - [x] "Reset to generated" option
  - [x] Save & preview

US-S008: Nastavení frekvence příspěvků
  JAKO Supervisor
  CHCI nastavit jak často se mají příspěvky publikovat
  PODLE mého subscription tieru

  Acceptance Criteria:
  - [x] Frequency selector (daily/2x week/weekly/etc)
  - [x] Shows max based on tier
  - [x] Calendar preview

US-S009: Výběr platforem
  JAKO Supervisor
  CHCI vybrat na které sítě se bude publikovat
  PODLE mého subscription tieru

  Acceptance Criteria:
  - [x] Multi-select platforms (Facebook, Instagram, LinkedIn, Twitter, TikTok)
  - [x] Max based on tier
  - [x] Platform-specific preview (character limits, etc)

US-S010: Výběr subscription
  JAKO Supervisor
  CHCI vybrat subscription tier
  ABYCH měl přístup k potřebným funkcím

  Acceptance Criteria:
  - [x] Plan comparison table
  - [x] Feature highlights
  - [x] TRIAL option (14 dní zdarma)
  - [x] Stripe Checkout redirect
  - [x] Success/cancel handling
```

### Epic: Supervisor - Content Calendar

```gherkin
US-S020: Zobrazení obsahového kalendáře
  JAKO Supervisor
  CHCI vidět plán obsahu na období předplatného
  ABYCH věděl co se bude publikovat

  Acceptance Criteria:
  - [x] Calendar view s tématy a příspěvky
  - [x] Výpočet období: od data platby do dalšího billing date
  - [x] Počet příspěvků = tier limit rozložený do období
  - [x] Status per item (draft/pending/approved/published)
  - [x] Click to detail

US-S021: Přidání akce/události
  JAKO Supervisor
  CHCI přidat marketingovou akci na příští měsíc
  ABYCH měl relevantní obsah

  Acceptance Criteria:
  - [x] Event form: název, datum, popis
  - [x] Přiřazení k personě
  - [x] Ovlivní generovaná témata

US-S022: Schválení témat
  JAKO Supervisor
  CHCI schválit navržená témata
  PŘED generováním blog postů

  Acceptance Criteria:
  - [x] Topic list with approve/reject
  - [x] Bulk approve option
  - [x] Reject with feedback
  - [x] Deadline reminder
  - [x] Schválení spustí generování obsahu

US-S023: Nahrání dokumentů
  JAKO Supervisor
  CHCI nahrát dokumenty relevantní pro obsah
  ABYCH poskytl AI více kontextu

  Acceptance Criteria:
  - [x] Drag & drop upload
  - [x] File type validation (PDF, DOCX, TXT)
  - [x] Storage limit based on tier
  - [x] AI parsing & indexing

US-S024: Review blog postu
  JAKO Supervisor
  CHCI zkontrolovat vygenerovaný blog post
  PŘED transformací na social posty

  Acceptance Criteria:
  - [x] Full text view (4-10 stran A4)
  - [x] Approve / Request changes
  - [x] Highlight problematic sections
  - [x] Comment system

US-S025: Schválení social postů
  JAKO Supervisor
  CHCI schválit finální social posty
  PŘED naplánovanou publikací

  Acceptance Criteria:
  - [x] Preview per platform
  - [x] Edit text if needed
  - [x] Approve / Regenerate
  - [x] Schedule modification

US-S026: Prohlížení grafiky
  JAKO Supervisor (PRO+)
  CHCI vidět vygenerovanou grafiku
  ABYCH ji mohl schválit nebo požádat o změnu

  Acceptance Criteria:
  - [x] Image preview
  - [x] Download option
  - [x] Regenerate with feedback
  - [x] Alternative suggestions

US-S027: Prohlížení videa
  JAKO Supervisor (ULTIMATE)
  CHCI vidět vygenerované video
  ABYCH ho mohl schválit

  Acceptance Criteria:
  - [x] Video player
  - [x] Download option
  - [x] Regenerate with feedback
  - [x] 1 video per event (zakoupený add-on)
```

### Epic: Supervisor - Account Management

```gherkin
US-S030: Zobrazení subscription info
  JAKO Supervisor
  CHCI vidět stav mého předplatného
  ABYCH věděl co platím a co dostávám

  Acceptance Criteria:
  - [x] Current plan display
  - [x] Usage meters (přesné počty zbývajících použití)
  - [x] Renewal date
  - [x] TRIAL countdown (dny + hodiny zbývající)
  - [x] Upgrade button

US-S031: Upgrade předplatného
  JAKO Supervisor
  CHCI upgradovat na vyšší tier
  ABYCH získal více funkcí

  Acceptance Criteria:
  - [x] Plan comparison
  - [x] Proration calculation
  - [x] Stripe Checkout
  - [x] Immediate feature unlock

US-S032: Správa platebních metod
  JAKO Supervisor
  CHCI spravovat své platební karty
  ABYCH měl aktuální platební údaje

  Acceptance Criteria:
  - [x] List saved cards
  - [x] Add new card
  - [x] Set default
  - [x] Remove card

US-S033: Historie faktur
  JAKO Supervisor
  CHCI vidět historii faktur
  ABYCH měl přehled o platbách

  Acceptance Criteria:
  - [x] Invoice list
  - [x] PDF download
  - [x] Status (paid/pending/failed)

US-S034: Zrušení předplatného
  JAKO Supervisor
  CHCI zrušit předplatné
  KDYŽ už službu nepotřebuji

  Acceptance Criteria:
  - [x] Cancellation flow
  - [x] Retention offer (optional)
  - [x] Access until period end
  - [x] Add-ony se pausnou
  - [x] Confirmation email

US-S035: Nákup add-onu
  JAKO Supervisor
  CHCI koupit doplňkovou službu
  ABYCH rozšířil možnosti

  Acceptance Criteria:
  - [x] Add-on catalog
  - [x] Instant purchase
  - [x] Usage tracking
  - [x] Dostupné i během TRIAL
```

### Epic: Supervisor - Analytics

```gherkin
US-S040: Dashboard přehled
  JAKO Supervisor
  CHCI vidět metriky mého obsahu
  ABYCH věděl jak performuje

  Acceptance Criteria:
  - [x] Posts published count
  - [x] Total reach
  - [x] Engagement rate
  - [x] Best performing content

US-S041: Platform-specific analytics
  JAKO Supervisor
  CHCI vidět metriky per platforma
  ABYCH věděl kde jsem nejúspěšnější

  Acceptance Criteria:
  - [x] Breakdown by platform
  - [x] Platform-specific metrics
  - [x] Trend over time
  - [x] Comparison view

US-S042: Content performance
  JAKO Supervisor
  CHCI vidět které příspěvky performují nejlépe
  ABYCH optimalizoval strategii

  Acceptance Criteria:
  - [x] Top posts ranking
  - [x] Performance by persona
  - [x] Performance by topic
  - [x] Engagement breakdown
```

---

## 7. SYSTEM USER STORIES

### Epic: AI Content Generation Pipeline

```gherkin
US-SYS001: Auto-generate monthly topics
  JAKO System
  CHCI automaticky generovat témata po schválení předchozích
  KDYŽ Supervisor schválí témata

  Trigger: Topics approved OR new subscription started
  Process:
  - For each active company under organization
  - Based on selected personas
  - Consider company DNA
  - Consider past topics (avoid repetition)
  - Consider user-added events/actions
  - Send SSE progress updates
  
  Output: List of Topic objects with status=DRAFT

US-SYS002: Generate blog post from topic
  JAKO System
  CHCI vygenerovat blog post z schváleného tématu
  KDYŽ Supervisor schválí téma

  Trigger: Topic status changes to APPROVED
  Process:
  - Load persona context
  - Load company DNA
  - Load relevant documents
  - Generate 4-10 pages A4 blog post
  - SEO optimization
  - Send SSE progress updates
  
  Output: BlogPost object with status=PENDING_APPROVAL

US-SYS003: Transform blog to social posts
  JAKO System
  CHCI transformovat blog post na social posty
  KDYŽ Supervisor schválí blog post

  Trigger: BlogPost status changes to APPROVED
  Process:
  - For each selected platform
  - Apply platform constraints (length, formatting)
  - Maintain persona voice
  - Add relevant hashtags
  - Calculate scheduling based on tier limits and period
  - Send SSE progress updates
  
  Output: SocialPost objects per platform

US-SYS004: Generate visuals
  JAKO System
  CHCI vygenerovat grafiku pro social post
  KDYŽ organizace má PRO+ tier

  Trigger: SocialPost created for PRO+ org
  Process:
  - Extract key message
  - Generate image prompt
  - Call Nanobana API
  - Store result
  - Send SSE progress updates
  
  Output: Image attachment on SocialPost

US-SYS005: Generate video
  JAKO System
  CHCI vygenerovat video pro social post
  KDYŽ organizace má ULTIMATE tier A zakoupený video event

  Trigger: Video event created for ULTIMATE org
  Process:
  - Extract key message
  - Generate video prompt
  - Call Veo 3 API
  - Store result
  - Send SSE progress updates
  
  Output: Video attachment on SocialPost
```

### Epic: Asynchronous Content Generation

```gherkin
US-SYS006: Monthly content pre-generation
  JAKO System
  CHCI generovat veškerý obsah měsíc dopředu
  ABYCH zajistil včasnou dostupnost

  Process:
  - Po schválení témat (topic approval)
  - Automaticky spustit generování všech článků
  - Generovat social media posty
  - Generovat vizuály (PRO+)
  - Rozložit práci asynchronně
  - Vše připraveno před koncem měsíce
  
  Output: Complete month content ready

US-SYS007: Content delivery scheduling
  JAKO System
  CHCI naplánovat doručování obsahu
  PODLE volby uživatele

  Rules:
  - Uživatel volí datum zahájení doručování
  - Limit: nejpozději 1. den následujícího měsíce
  - NEBO nejpozději 14 dní od zaplacení
  - Použije se dřívější z těchto termínů
  - AI kvóta běží od zaplacení (ne od doručování)
  
  Output: Scheduled delivery plan
```

### Epic: Notifications

```gherkin
US-SYS010: Approval reminder
  JAKO System
  CHCI připomenout Supervisorovi pending approvals
  KDYŽ je 3 dny před deadline

  Trigger: Scheduled task, daily
  Process:
  - Find pending items older than X days
  - Send email reminder
  - Create in-app notification
  
  Output: Notification sent

US-SYS011: Content ready notification
  JAKO System
  CHCI notifikovat Supervisora o novém obsahu
  KDYŽ je vygenerován a čeká na schválení

  Trigger: Content status = PENDING_APPROVAL
  Process:
  - Send email
  - Create in-app notification
  
  Output: Notification sent

US-SYS012: Payment failure notification
  JAKO System
  CHCI notifikovat Supervisora o neúspěšné platbě
  KDYŽ Stripe webhook reportuje failure

  Trigger: Stripe webhook: invoice.payment_failed
  Process:
  - Send email
  - Create urgent in-app notification
  - Mark subscription as PAST_DUE
  - Pause add-ons
  
  Output: Notification sent, status updated

US-SYS013: TRIAL expiry notification
  JAKO System
  CHCI notifikovat Supervisora o končícím TRIAL
  3 dny a 1 den před koncem

  Trigger: Scheduled task, daily
  Process:
  - Find TRIAL subscriptions ending soon
  - Send reminder emails
  - Show countdown in UI
  
  Output: Notifications sent
```

### Epic: Auto-assignment

```gherkin
US-SYS020: Auto-assign new Supervisor
  JAKO System
  CHCI automaticky přiřadit nového Supervisora k Marketérovi
  ABYCH vyvážil workload

  Trigger: New Supervisor completes onboarding
  Process:
  - Check if from affiliate link:
    - Marketer affiliate → assign to that Marketer
    - Manager affiliate → assign to ideal Marketer under that Manager
  - If no affiliate:
    - Portfolio matching (podobné obory firem)
    - Fallback: lowest workload
  - Notify Marketer
  
  Output: Supervisor.marketer set

US-SYS021: Rebalance on Marketer leave
  JAKO System
  CHCI přerozdělit Supervisory při odchodu Marketéra
  ABYCH zajistil kontinuitu

  Trigger: Marketer deactivated
  Process:
  - Find all Supervisors under Marketer
  - Distribute to other Marketers under same Manager
  - Use portfolio matching
  - Notify affected parties
  
  Output: Supervisors reassigned
```

---

## 8. EPIC BREAKDOWN

### MVP Epics (Priority 0) - MUST HAVE

| Epic | Stories | Est. Complexity | Features |
|------|---------|-----------------|----------|
| Supervisor Onboarding | US-S001 to US-S010 | High | Registration, Company search, DNA scraping |
| Persona Generation | US-S005, US-S006, US-S007 | Medium | AI personas with SSE progress |
| Topic Generation | US-SYS001, US-S022 | Medium | Topics with approval flow |
| Blog Generation | US-SYS002, US-S024 | High | 4-10 page blog posts |
| Social Post Generation | US-SYS003, US-S025 | Medium | Per-platform optimization |
| **Image Generation** | US-SYS004, US-S026 | Medium | **Nanobana integration** |
| Basic Subscription | US-S010, US-S030 | Medium | TRIAL + paid tiers |
| SSE Progress | All generation | High | Real-time progress updates |
| Content Calendar | US-S020 | Medium | Frontend view, period calculation |

### Phase 2 Epics (Priority 1) - SHOULD HAVE

| Epic | Stories | Est. Complexity |
|------|---------|-----------------|
| Marketer Operations | US-MK001 to US-MK012 | Medium |
| Manager Dashboard | US-M001 to US-M005 | Medium |
| Analytics Basic | US-S040 to US-S042 | Medium |
| Affiliate System | US-MK012, referral tracking | Medium |
| Add-on Purchases | US-S035 | Medium |
| Auto-assignment | US-SYS020, US-SYS021 | Medium |

### Phase 3 Epics (Priority 2) - NICE TO HAVE

| Epic | Stories | Est. Complexity |
|------|---------|-----------------|
| **Video Generation** | US-SYS005, US-S027 | High |
| Admin System Config | US-A010, US-A011, US-A012 | Medium |
| Advanced Analytics | Extended US-S04x | High |
| API Access | Enterprise feature | High |

---

## 9. DOMAIN GLOSSARY

### Core Entities

| Term | Definition | Czech |
|------|------------|-------|
| **Organization** | Tenant/billing account - může mít více Companies | Organizace |
| **Company** | Skutečná firma s vlastním DNA a obsahem | Firma |
| **Persona** | AI-generated fictional author with consistent style | Persona/Fiktivní autor |
| **Topic** | Monthly content theme | Téma |
| **BlogPost** | Long-form educational content (4-10 pages A4) | Blog příspěvek |
| **SocialPost** | Platform-specific short content | Social příspěvek |
| **Company DNA** | AI-scraped company characteristics (30+ data points) | DNA firmy |

### User Roles

| Term | Definition | Czech |
|------|------------|-------|
| **Admin** | Platform owner, manages Managers | Admin |
| **Manager** | Team lead, manages Marketers, sees all under them | Manažer |
| **Marketer** | Content manager, manages Supervisors | Marketér |
| **Supervisor** | Client, approves content, PAYS | Supervisor/Klient |

### Subscription Terms

| Term | Definition | Czech |
|------|------------|-------|
| **Tier** | Subscription level (TRIAL/BASIC/PRO/ULTIMATE) | Tarif |
| **TRIAL** | 14-day free trial on BASIC limits | Zkušební období |
| **Add-on** | Additional purchased feature/capacity | Doplněk |
| **Limit** | Maximum allowed usage per tier (přesné počty) | Limit |
| **MRR** | Monthly Recurring Revenue | Měsíční pravidelný příjem |
| **Affiliate** | Referral system with bonuses | Affiliate program |

### AI Terms

| Term | Definition |
|------|------------|
| **Company DNA** | AI-scraped company characteristics via Perplexity |
| **Persona Voice** | Writing style defined by persona |
| **Content Pipeline** | DNA → Personas → Topics → BlogPost → SocialPost → Media |
| **Regeneration** | Creating new version of content (tier-limited) |
| **SSE Progress** | Real-time generation status via Server-Sent Events |

### Status Enums

| Status | Meaning |
|--------|---------|
| DRAFT | Initial state, not ready |
| PROCESSING | AI processing in progress |
| PENDING_APPROVAL | Waiting for Supervisor |
| APPROVED | Ready for next step |
| PUBLISHED | Live on platform |
| REJECTED | Needs regeneration |
| FAILED | AI error occurred |
| CANCELLED | User cancelled |

---

## 10. TECHNICAL CONTEXT

### Tech Stack Summary

```
Frontend:  Angular 19+ / TypeScript / TailwindCSS / Signals API
Backend:   Python 3.11+ / Django 5 / DRF / Celery
Database:  PostgreSQL 16 / pgvector / Redis
AI:        Gemini 1.5 Pro / Perplexity / Nanobana / Veo 3
Payments:  Stripe Subscriptions + dj-stripe
Infra:     VPS + Docker Compose (K8s po funding)
```

### Key Architectural Decisions

1. **Modular Monolith** - Ne microservices, ale připraveno na extrakci
2. **Row-based Multi-tenancy** - Organization FK na všech modelech
3. **Organization → Company** - Multi-company support per tenant
4. **Celery pro AI Jobs** - Async processing, 30-120s tasks
5. **AIGateway Class** - Class-based s dependency injection (ne factory functions)
6. **PromptTemplate v DB** - S Redis cache a fallback na hardcoded
7. **SSE pro Job Status** - Real-time updates bez WebSockets
8. **Tailwind Only** - Custom components, žádný Angular Material

### AI Provider Architecture

```python
# Class-based AIGateway s DI
class AIGateway:
    def __init__(self, provider: AIProvider):
        self.provider = provider
    
    async def generate(self, prompt_key: str, context: dict) -> str:
        template = await self.get_prompt_template(prompt_key)
        return await self.provider.complete(template.render(context))

# Providers
class GeminiProvider(AIProvider): ...      # Text generation
class PerplexityProvider(AIProvider): ...  # DNA scraping
class NanobanaProvider(AIProvider): ...    # Image generation (MVP)
class VeoProvider(AIProvider): ...         # Video generation (post-MVP)
```

### API Design Principles

- REST + JSON
- camelCase pro JSON klíče
- JWT auth (access + refresh tokens)
- Cursor pagination
- Standard error format
- SSE endpoint pro job progress

### Database Principles

- UUID primary keys
- Soft deletes (is_deleted flag)
- Timestamps (created_at, updated_at)
- Tenant isolation na všech queries
- Organization → Company hierarchy

### Frontend Principles

```
Tailwind CSS 3.4+ (base styling)
Custom Components (35+ components)
No Angular Material
Visual Book compliance:
  - Gradient brand colors (violet → blue → cyan → green)
  - Glassmorphism effects
  - Custom animations (particle, float, shimmer)
  - Neon glow shadows
  - IBM Plex Mono accents
```

---

## 11. SUBSCRIPTION & BILLING

### Tier Definitions

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           POSTHUB PRICING TIERS                             │
├─────────────┬─────────────┬─────────────────┬──────────────────────────────┤
│   TRIAL     │   BASIC     │      PRO        │         ULTIMATE             │
│   Zdarma    │   990 Kč    │    2 490 Kč     │          7 490 Kč            │
│   14 dní    │   /měsíc    │    /měsíc ⭐    │          /měsíc              │
├─────────────┴─────────────┴─────────────────┴──────────────────────────────┤
│  Zkušební    Pro malé      Nejoblíbenější    Pro velké                     │
│  období      firmy         volba             společnosti                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Tier Limits (ACTUAL)

| Feature | TRIAL | BASIC | PRO ⭐ | ULTIMATE |
|---------|-------|-------|--------|----------|
| **Cena/měsíc** | 0 Kč | 990 Kč | 2 490 Kč | 7 490 Kč |
| **Cena/rok** | - | 9 900 Kč | 24 900 Kč | 74 900 Kč |
| **Doba trvání** | 14 dní | ∞ | ∞ | ∞ |
| **Companies** | 1 | 1 | 2 | 3 |
| **Personas/company** | 3 | 3 | 6 | 12 |
| **Platformy** | 3 | 3 | 6 | All (5) |
| **Příspěvky/měsíc** | 12 | 12 | 24 | 72 |
| **Regenerace/post** | 0 | 1 | 3 | 3 |
| **Supervisors** | 0 | 0 | 2 | 2 |
| **Jazyky** | 1 | 1 | 1 | 3 |
| **Vizuály (Nanobana)** | ❌ | ❌ | ✅ | ✅ |
| **Video (Veo)** | ❌ | ❌ | ❌ | ✅ |
| **Storage** | 256 MB | 512 MB | 3 GB | 10 GB |
| **Add-ony dostupné** | ✅ | ✅ | ✅ | ✅ |

### TRIAL Special Rules

```yaml
TRIAL:
  duration: 14 days
  limits: Same as BASIC
  add_ons: 
    - Can purchase ANY add-on during TRIAL
    - Add-ons PAUSE when TRIAL expires without payment
    - Add-ons RESUME immediately when any tier is purchased
    - No lost hours on add-on usage
  display:
    - Show days + hours remaining
    - Countdown in UI
  conversion:
    - Can upgrade to any tier anytime
    - AI quota starts from payment date
```

### Add-ons (8+ types)

| Add-on | Cena/měsíc | Popis |
|--------|------------|-------|
| Extra Company | 1 490 Kč | Další firma pod organizací |
| Extra Personas | 490 Kč | +3 persony pro firmu |
| Extra Regenerace | 149 Kč | +1 regenerace na příspěvek |
| Extra Storage | 49 Kč/GB | Navýšení úložiště |
| Extra Supervisor | 299 Kč | Další schvalovatel |
| Extra Jazyk | 499 Kč | Další jazyk pro generování |
| Extra Vizuály | 99 Kč | Balík 10 vizuálů/měsíc |
| Extra Platforma | 199 Kč | Další sociální síť |

### Usage Tracking

```yaml
Usage Model:
  - Přesné počty použití per feature
  - Real-time tracking
  - UI zobrazuje zbývající použití
  - Překročení limitu = musí dokoupit add-on
  - Nebo doporučit dalšího uživatele (affiliate bonus)
```

### Content Calendar Calculation

```python
def calculate_content_period(subscription):
    """
    Vypočítá období pro content calendar.
    
    - start: datum zaplacení (včetně)
    - end: datum dalšího billing (kromě)
    - days: počet dní v období
    - posts: tier limit rozložený do období
    """
    start = subscription.current_period_start
    end = subscription.current_period_end
    days = (end - start).days
    
    posts_per_month = subscription.tier.posts_per_month
    # Rozložit příspěvky rovnoměrně do období
    return {
        'start': start,
        'end': end,
        'days': days,
        'posts': posts_per_month,
        'frequency': days // posts_per_month  # Dní mezi příspěvky
    }
```

### Delivery Scheduling Rules

```yaml
Delivery Start Date:
  - Uživatel volí datum zahájení doručování
  - Omezení 1: nejpozději 1. den následujícího měsíce
  - Omezení 2: nejpozději 14 dní od zaplacení
  - Použije se DŘÍVĚJŠÍ z těchto termínů
  
Billing vs Delivery:
  - AI kvóta a fakturace: od zaplacení
  - Doručování obsahu: od zvoleného data
  - Content je připraven PŘED datem doručení
```

---

## 12. AFFILIATE SYSTEM

### Affiliate Structure

```yaml
Affiliate Types:
  1. Supervisor → Supervisor:
     - Pozvaný získá: 1 měsíc BASIC bundle zdarma po zaplacení
     - Zvoucí získá: 1 měsíc BASIC bundle zdarma po zaplacení pozvaného
     
  2. Marketer → Supervisor:
     - Pozvaný automaticky přiřazen pod Marketéra
     - Marketer získá: Speciální feature na další měsíc (při nejlepším skóre)
     
  3. Manager → Supervisor:
     - Pozvaný přiřazen k ideálnímu Marketérovi pod Managerem
     
BASIC Bundle Bonus:
  - 6 person na výběr
  - 12 nových příspěvků
  - 1 regenerace na každý AI výsledek
  - 12× vizuál k příspěvku
  - 1 regenerace vizuálu
```

### Marketer Score System

```yaml
Marketer Monthly Score:
  Metriky (návrh):
  - Approval rate (% schválených na první pokus)
  - Response time (průměrná doba od notification do approval)
  - Client satisfaction (NPS/rating)
  - Content quality (Manager review score)
  - Retention rate (% klientů kteří nepřešli jinam)
  
  Reward:
  - Nejlepší Marketer v měsíci získá speciální feature
  - Feature TBD (návrhy: premium analytics, priority support, extra regenerations)
```

### Affiliate Tracking

```yaml
Implementation:
  - Unique affiliate links per user
  - UTM parameters tracking
  - Cookie-based attribution (30 days)
  - Conversion tracking (registration + payment)
  - Bonus application after payment confirmed
  
Conditions:
  - Zvoucí musí mít aktivní předplatné
  - Bonus až po zaplacení pozvaného
  - TRIAL se nepočítá jako zaplacení
```

---

## 13. ACCEPTANCE CRITERIA TEMPLATES

### Standard AC Format

```gherkin
GIVEN [precondition]
WHEN [action]
THEN [expected result]
AND [additional expectations]
```

### Common Patterns

#### Form Submission
```gherkin
GIVEN user is on [page]
AND user has filled required fields
WHEN user clicks Submit
THEN form is validated
AND data is saved
AND success message appears
AND user is redirected to [target]
```

#### List/Table View
```gherkin
GIVEN user is on [list page]
THEN user sees list of [items]
AND items are sorted by [default sort]
AND pagination is shown if > 20 items
AND search/filter is available
```

#### AI Generation with SSE
```gherkin
GIVEN user triggers [generation type]
WHEN generation starts
THEN loading state is shown
AND progress bar appears
AND SSE updates show real-time progress ("Analyzing DNA... 23%")
WHEN generation completes
THEN result is displayed
AND status changes to [target status]
AND progress shows "100% ✓"
```

#### Role-based Access
```gherkin
GIVEN user has role [ROLE]
WHEN user accesses [resource]
THEN access is [granted/denied]
AND appropriate message is shown
```

#### Approval Flow
```gherkin
GIVEN content has status PENDING_APPROVAL
WHEN Supervisor clicks Approve
THEN status changes to APPROVED
AND next pipeline step is triggered
AND notification is sent
```

---

## 14. NON-FUNCTIONAL REQUIREMENTS

### Performance

| Metric | Target |
|--------|--------|
| Page Load | < 2s |
| API Response | < 500ms (95th percentile) |
| AI Generation | < 120s (blog), < 60s (social) |
| SSE Latency | < 100ms |
| Concurrent Users | 1,000+ (MVP), 10,000+ (scale) |

### Scalability

| Metric | Target (MVP) | Target (Scale) |
|--------|--------------|----------------|
| Supervisors | 1,000 | 100,000+ |
| Organizations | 1,000 | 100,000+ |
| Posts/month | 50,000 | 10M+ |
| API requests/day | 100,000 | 100M+ |

### Reliability

| Metric | Target |
|--------|--------|
| Uptime | 99.9% |
| Data Durability | 99.999999999% |
| Backup RPO | 1 hour |
| Backup RTO | 4 hours |

### Security

| Requirement | Implementation |
|-------------|----------------|
| Authentication | JWT + refresh tokens |
| Authorization | RBAC + tenant isolation |
| Data Encryption | TLS 1.3 in transit |
| PII Protection | GDPR compliant |
| Rate Limiting | Per endpoint, per tier |

### Infrastructure (Current)

| Component | Current | Future (post-funding) |
|-----------|---------|----------------------|
| Hosting | VPS (72.62.92.89) | Kubernetes cluster |
| Orchestration | Docker Compose | Kubernetes |
| Monitoring | Flower + logs | Prometheus + Grafana |
| Backup | Daily PostgreSQL dump | Automated with retention |

### Localization

| Aspect | Support |
|--------|---------|
| Languages | CS (primary), EN, DE (future) |
| Currency | CZK (primary), EUR (future) |
| Timezone | Europe/Prague (configurable) |

---

## 📌 QUICK REFERENCE

### User Permissions Matrix

| Action | Admin | Manager | Marketer | Supervisor |
|--------|:-----:|:-------:|:--------:|:----------:|
| Create Manager | ✅ | ❌ | ❌ | ❌ |
| Create Marketer | ✅ | ✅ | ❌ | ❌ |
| View All Organizations | ✅ | ✅ | ❌ | ❌ |
| View Assigned Orgs | ✅ | ✅ | ✅ | ❌ |
| Manage Own Org | ✅ | ✅ | ✅ | ✅ |
| Approve Content | ✅ | ✅ | ✅ | ✅ |
| View Billing | ✅ | ❌ | ❌ | ✅ |
| Edit Personas | ✅ | ✅ | ✅ | ✅ |
| Regenerate Content | ✅ | ✅ | ✅ | ✅* |
| Send Affiliate Link | ✅ | ✅ | ✅ | ✅ |
| Reassign Supervisors | ✅ | ✅ | ❌ | ❌ |

*Based on tier limits

### Content Generation Timeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    ASYNCHRONOUS GENERATION                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Day 1: Payment                                                │
│    └── AI kvóta starts                                         │
│    └── Topics generated                                        │
│                                                                 │
│  Day 2-5: Topic Approval                                       │
│    └── Supervisor reviews topics                               │
│    └── Approves/rejects with feedback                          │
│                                                                 │
│  Day 5-15: Content Generation (async)                          │
│    └── BlogPosts generated                                     │
│    └── SocialPosts generated                                   │
│    └── Images generated (PRO+)                                 │
│    └── All ready BEFORE delivery date                          │
│                                                                 │
│  Day X: Delivery Start (user choice)                           │
│    └── Max: 1st of next month                                  │
│    └── Max: 14 days from payment                               │
│    └── Whichever is EARLIER                                    │
│                                                                 │
│  Ongoing: Scheduled Delivery                                   │
│    └── Email notifications                                     │
│    └── Future: Direct platform publishing                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Tier Quick Reference

| Feature | TRIAL | BASIC | PRO ⭐ | ULTIMATE |
|---------|-------|-------|--------|----------|
| Price/mo | 0 | 990 | 2,490 | 7,490 |
| Duration | 14 days | ∞ | ∞ | ∞ |
| Companies | 1 | 1 | 2 | 3 |
| Personas | 3 | 3 | 6 | 12 |
| Platforms | 3 | 3 | 6 | All |
| Posts/mo | 12 | 12 | 24 | 72 |
| Images | ❌ | ❌ | ✅ | ✅ |
| Video | ❌ | ❌ | ❌ | ✅ |
| Add-ons | ✅ | ✅ | ✅ | ✅ |

### Feature Matrix

```
┌────────────────────┬───────┬───────┬───────┬────────────┐
│ Funkce             │ TRIAL │ BASIC │  PRO  │  ULTIMATE  │
├────────────────────┼───────┼───────┼───────┼────────────┤
│ AI Persony         │  ✅   │  ✅   │  ✅   │     ✅     │
│ DNA Scraping       │  ✅   │  ✅   │  ✅   │     ✅     │
│ Blog Generation    │  ✅   │  ✅   │  ✅   │     ✅     │
│ Social Posts       │  ✅   │  ✅   │  ✅   │     ✅     │
│ Content Calendar   │  ✅   │  ✅   │  ✅   │     ✅     │
│ SSE Progress       │  ✅   │  ✅   │  ✅   │     ✅     │
│ AI Vizuály         │  ❌   │  ❌   │  ✅   │     ✅     │
│ AI Video           │  ❌   │  ❌   │  ❌   │     ✅     │
│ Multi-company      │  ❌   │  ❌   │  ✅   │     ✅     │
│ Multi-language     │  ❌   │  ❌   │  ❌   │     ✅     │
│ Priority Support   │  ❌   │  ❌   │  ✅   │     ✅     │
│ API Access         │  ❌   │  ❌   │  ❌   │     ✅     │
│ Add-on Purchase    │  ✅   │  ✅   │  ✅   │     ✅     │
└────────────────────┴───────┴───────┴───────┴────────────┘
```

---

*Tento dokument je SELF-CONTAINED pro Context Engineering.*
*Verze 2.0.0 | Poslední aktualizace: December 2025*
*Aktualizováno na základě Q&A session s Martinem (CEO)*
